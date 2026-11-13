//
//  PackagedFoodRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Implementation of PackagedFoodRepositoryProtocol backed by SwiftData & Bundled Catalogue.
//

import Foundation
import SwiftData

public final class PackagedFoodRepository: PackagedFoodRepositoryProtocol, @unchecked Sendable {
    private let container: ModelContainer
    private let bundledCatalogue: BundledPackagedFoodCatalogue

    public init(
        container: ModelContainer = SwiftDataStack.shared.container,
        bundledCatalogue: BundledPackagedFoodCatalogue = .shared
    ) {
        self.container = container
        self.bundledCatalogue = bundledCatalogue
    }

    // MARK: - Barcode Lookup (User Library First -> Bundled Catalogue -> Not Found)
    @MainActor
    public func lookup(barcode: String) async throws -> BarcodeLookupResult {
        let val = BarcodeValue(rawValue: barcode)
        guard val.isValid else {
            return .invalid(rawBarcode: barcode, reason: val.validationError ?? "Mã vạch không hợp lệ")
        }

        let targetCode = val.normalizedValue
        let rawCode = val.rawValue.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1. Check user's SwiftData library first
        let allUserFoods = try await fetchAll()
        if var userItem = allUserFoods.first(where: {
            $0.barcode == targetCode || $0.rawBarcode == rawCode || $0.barcode == rawCode
        }) {
            userItem.lastScannedAt = Date()
            try? await update(userItem)
            return .found(userItem, source: .userLibrary)
        }

        // 2. Check bundled verified Vietnamese catalogue
        if let bundledItem = bundledCatalogue.findByBarcode(targetCode) ?? bundledCatalogue.findByBarcode(rawCode) {
            return .found(bundledItem, source: .bundledCatalogue)
        }

        // 3. Not found in either source
        return .notFound(barcode: val)
    }

    @MainActor
    public func fetchAll() async throws -> [PackagedFood] {
        let descriptor = FetchDescriptor<PackagedFoodSDModel>(
            sortBy: [
                SortDescriptor(\.createdAt, order: .reverse)
            ]
        )
        do {
            let results = try container.mainContext.fetch(descriptor)
            return results.map { $0.toDomain() }.sorted { (a, b) -> Bool in
                if a.isFavorite != b.isFavorite {
                    return a.isFavorite && !b.isFavorite
                }
                return a.updatedAt > b.updatedAt
            }
        } catch {
            throw AppError.dataPersistenceFailed("Không thể tải danh sách sản phẩm đóng gói: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func fetchById(id: UUID) async throws -> PackagedFood? {
        let descriptor = FetchDescriptor<PackagedFoodSDModel>(
            predicate: #Predicate<PackagedFoodSDModel> { $0.id == id }
        )
        do {
            if let userFood = try container.mainContext.fetch(descriptor).first {
                return userFood.toDomain()
            }
            return bundledCatalogue.items.first { $0.id == id }
        } catch {
            throw AppError.dataPersistenceFailed("Không thể tìm sản phẩm theo ID: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func fetchByBarcode(barcode: String) async throws -> PackagedFood? {
        let clean = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        let allUser = try await fetchAll()
        if let match = allUser.first(where: { $0.barcode == clean || $0.rawBarcode == clean }) {
            return match
        }
        return bundledCatalogue.findByBarcode(clean)
    }

    @MainActor
    public func search(query: String) async throws -> [PackagedFood] {
        let clean = query.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()

        let userFoods = try await fetchAll()
        let bundledFoods = bundledCatalogue.items

        guard !clean.isEmpty else {
            // Deduplicate: user foods take precedence over bundled foods with identical barcode
            var combined: [PackagedFood] = userFoods
            let userBarcodes = Set(userFoods.map { $0.barcode })
            for item in bundledFoods where !userBarcodes.contains(item.barcode) {
                combined.append(item)
            }
            return combined
        }

        func matches(_ item: PackagedFood) -> Bool {
            let name = item.productName.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let brand = (item.brand ?? "").folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let cat = item.category.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let bar = item.barcode
            let rawBar = item.rawBarcode
            return name.contains(clean) || brand.contains(clean) || cat.contains(clean) || bar.contains(clean) || rawBar.contains(clean)
        }

        var results: [PackagedFood] = userFoods.filter(matches)
        let userBarcodes = Set(results.map { $0.barcode })

        for item in bundledFoods.filter(matches) where !userBarcodes.contains(item.barcode) {
            results.append(item)
        }

        return results
    }

    @MainActor
    public func save(_ food: PackagedFood) async throws {
        let context = container.mainContext
        let targetId = food.id
        let targetBarcode = food.barcode

        // Check if item already exists by ID or by barcode
        let descriptor = FetchDescriptor<PackagedFoodSDModel>(
            predicate: #Predicate<PackagedFoodSDModel> {
                $0.id == targetId || $0.barcode == targetBarcode
            }
        )

        do {
            let existing = try context.fetch(descriptor).first
            if let existing {
                // Update in place
                existing.productName = food.productName
                existing.brand = food.brand
                existing.category = food.category
                existing.barcode = food.barcode
                existing.rawBarcode = food.rawBarcode
                existing.barcodeTypeRaw = food.barcodeType.rawValue
                existing.servingSize = food.serving.servingSize
                existing.servingUnit = food.serving.servingUnit
                existing.servingsPerPackage = food.serving.servingsPerPackage
                existing.servingGramsEquivalent = food.serving.servingGramsEquivalent
                existing.calories = food.nutrition.calories
                existing.proteinGrams = food.nutrition.proteinGrams
                existing.carbGrams = food.nutrition.carbGrams
                existing.fatGrams = food.nutrition.fatGrams
                existing.fiberGrams = food.nutrition.fiberGrams
                existing.sodiumMg = food.nutrition.sodiumMg
                existing.sugarGrams = food.nutrition.sugarGrams
                existing.calciumMg = food.nutrition.calciumMg
                existing.ironMg = food.nutrition.ironMg
                existing.nutritionBasisRaw = food.nutrition.basis.rawValue

                let ingData = (try? JSONEncoder().encode(food.ingredients)) ?? Data()
                existing.ingredientsJSON = String(data: ingData, encoding: .utf8) ?? "[]"
                existing.ingredientText = food.ingredientText
                existing.allergensRaw = food.allergens.map { $0.rawValue }
                existing.verificationStatusRaw = food.verificationStatus.rawValue
                existing.isFavorite = food.isFavorite
                existing.updatedAt = Date()
                existing.notes = food.notes
                existing.imagePath = food.imagePath
            } else {
                let model = PackagedFoodSDModel(from: food)
                context.insert(model)
            }
            try context.save()
            AppLogger.data.info("Saved packaged food: \(food.productName) (\(food.barcode))")
        } catch {
            throw AppError.dataPersistenceFailed("Không thể lưu sản phẩm đóng gói: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func update(_ food: PackagedFood) async throws {
        try await save(food)
    }

    @MainActor
    public func delete(id: UUID) async throws {
        let context = container.mainContext
        let descriptor = FetchDescriptor<PackagedFoodSDModel>(
            predicate: #Predicate<PackagedFoodSDModel> { $0.id == id }
        )
        do {
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
                AppLogger.data.info("Deleted packaged food id: \(id)")
            }
        } catch {
            throw AppError.dataPersistenceFailed("Không thể xóa sản phẩm đóng gói: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func toggleFavorite(id: UUID) async throws -> Bool {
        let context = container.mainContext
        let descriptor = FetchDescriptor<PackagedFoodSDModel>(
            predicate: #Predicate<PackagedFoodSDModel> { $0.id == id }
        )
        do {
            if let existing = try context.fetch(descriptor).first {
                existing.isFavorite.toggle()
                existing.updatedAt = Date()
                try context.save()
                return existing.isFavorite
            } else if let bundled = bundledCatalogue.items.first(where: { $0.id == id }) {
                // If toggling favorite on a bundled item, save a copy into SwiftData as favorite
                var copy = bundled
                copy.isFavorite = true
                copy.updatedAt = Date()
                let model = PackagedFoodSDModel(from: copy)
                context.insert(model)
                try context.save()
                return true
            }
            return false
        } catch {
            throw AppError.dataPersistenceFailed("Không thể đổi trạng thái yêu thích: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func recordScan(barcode: String) async throws {
        let clean = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        let context = container.mainContext
        let descriptor = FetchDescriptor<PackagedFoodSDModel>(
            predicate: #Predicate<PackagedFoodSDModel> {
                $0.barcode == clean || $0.rawBarcode == clean
            }
        )
        if let existing = try? context.fetch(descriptor).first {
            existing.lastScannedAt = Date()
            try? context.save()
        }
    }

    @MainActor
    public func fetchRecentScans(limit: Int = 10) async throws -> [PackagedFood] {
        let all = try await fetchAll()
        let scanned = all.filter { $0.lastScannedAt != nil }
            .sorted { ($0.lastScannedAt ?? .distantPast) > ($1.lastScannedAt ?? .distantPast) }
        return Array(scanned.prefix(limit))
    }
}

