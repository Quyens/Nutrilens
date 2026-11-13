//
//  MockPackagedFoodRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  In-memory mock implementation of PackagedFoodRepositoryProtocol for unit tests and previews.
//

import Foundation

public final class MockPackagedFoodRepository: PackagedFoodRepositoryProtocol, @unchecked Sendable {
    public var storage: [PackagedFood]
    public var bundledStorage: [PackagedFood]
    public var shouldThrowError: Bool = false

    public init(
        initialStorage: [PackagedFood] = [],
        bundledItems: [PackagedFood] = BundledPackagedFoodCatalogue.shared.items
    ) {
        self.storage = initialStorage
        self.bundledStorage = bundledItems
    }

    public func lookup(barcode: String) async throws -> BarcodeLookupResult {
        if shouldThrowError {
            throw AppError.networkUnavailable
        }
        let val = BarcodeValue(rawValue: barcode)
        guard val.isValid else {
            return .invalid(rawBarcode: barcode, reason: val.validationError ?? "Mã vạch không hợp lệ")
        }

        let target = val.normalizedValue
        let raw = val.rawValue.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1. User storage priority
        if let userItem = storage.first(where: { $0.barcode == target || $0.rawBarcode == raw || $0.barcode == raw }) {
            return .found(userItem, source: .userLibrary)
        }

        // 2. Bundled storage
        if let bundledItem = bundledStorage.first(where: { $0.barcode == target || $0.rawBarcode == raw || $0.barcode == raw }) {
            return .found(bundledItem, source: .bundledCatalogue)
        }

        // 3. Not found
        return .notFound(barcode: val)
    }

    public func fetchAll() async throws -> [PackagedFood] {
        if shouldThrowError {
            throw AppError.dataPersistenceFailed("Mock error")
        }
        return storage.sorted { (a, b) -> Bool in
            if a.isFavorite != b.isFavorite {
                return a.isFavorite && !b.isFavorite
            }
            return a.updatedAt > b.updatedAt
        }
    }

    public func fetchById(id: UUID) async throws -> PackagedFood? {
        if let found = storage.first(where: { $0.id == id }) {
            return found
        }
        return bundledStorage.first(where: { $0.id == id })
    }

    public func fetchByBarcode(barcode: String) async throws -> PackagedFood? {
        let clean = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        if let found = storage.first(where: { $0.barcode == clean || $0.rawBarcode == clean }) {
            return found
        }
        return bundledStorage.first(where: { $0.barcode == clean || $0.rawBarcode == clean })
    }

    public func search(query: String) async throws -> [PackagedFood] {
        let clean = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !clean.isEmpty else {
            return storage + bundledStorage.filter { b in !storage.contains(where: { $0.barcode == b.barcode }) }
        }

        let combined = storage + bundledStorage.filter { b in !storage.contains(where: { $0.barcode == b.barcode }) }
        return combined.filter {
            $0.productName.lowercased().contains(clean) ||
            ($0.brand?.lowercased().contains(clean) ?? false) ||
            $0.barcode.contains(clean) ||
            $0.category.lowercased().contains(clean)
        }
    }

    public func save(_ food: PackagedFood) async throws {
        if shouldThrowError {
            throw AppError.dataPersistenceFailed("Mock error")
        }
        if let idx = storage.firstIndex(where: { $0.id == food.id || $0.barcode == food.barcode }) {
            storage[idx] = food
        } else {
            storage.append(food)
        }
    }

    public func update(_ food: PackagedFood) async throws {
        try await save(food)
    }

    public func delete(id: UUID) async throws {
        storage.removeAll { $0.id == id }
    }

    public func toggleFavorite(id: UUID) async throws -> Bool {
        if let idx = storage.firstIndex(where: { $0.id == id }) {
            storage[idx].isFavorite.toggle()
            return storage[idx].isFavorite
        } else if let bundled = bundledStorage.first(where: { $0.id == id }) {
            var copy = bundled
            copy.isFavorite = true
            storage.append(copy)
            return true
        }
        return false
    }

    public func recordScan(barcode: String) async throws {
        let clean = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        if let idx = storage.firstIndex(where: { $0.barcode == clean || $0.rawBarcode == clean }) {
            storage[idx].lastScannedAt = Date()
        }
    }

    public func fetchRecentScans(limit: Int = 10) async throws -> [PackagedFood] {
        let scanned = storage.filter { $0.lastScannedAt != nil }
            .sorted { ($0.lastScannedAt ?? .distantPast) > ($1.lastScannedAt ?? .distantPast) }
        return Array(scanned.prefix(limit))
    }
}

