//
//  CustomFoodRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  SwiftData implementation of CustomFoodRepositoryProtocol.
//

import Foundation
import SwiftData

public final class CustomFoodRepository: CustomFoodRepositoryProtocol, @unchecked Sendable {
    private let container: ModelContainer

    public init(container: ModelContainer = SwiftDataStack.shared.container) {
        self.container = container
    }

    @MainActor
    public func fetchAllCustomFoods() async throws -> [CustomFood] {
        let descriptor = FetchDescriptor<CustomFoodSDModel>(
            sortBy: [
                SortDescriptor(\.createdAt, order: .reverse)
            ]
        )
        do {
            var results: [CustomFoodSDModel] = try container.mainContext.fetch(descriptor)
            if results.isEmpty && !UserDefaults.standard.bool(forKey: "custom_foods_seeded_or_cleared") {
                UserDefaults.standard.set(true, forKey: "custom_foods_seeded_or_cleared")
                for sample in MockCustomFoodRepository.sampleCustomFoods {
                    let model = CustomFoodSDModel(from: sample)
                    container.mainContext.insert(model)
                }
                try? container.mainContext.save()
                results = (try? container.mainContext.fetch(descriptor)) ?? []
            }
            return results.map { $0.toDomain() }.sorted { (a, b) -> Bool in
                if a.isFavorite != b.isFavorite {
                    return a.isFavorite && !b.isFavorite
                }
                return a.createdAt > b.createdAt
            }
        } catch {
            throw AppError.dataPersistenceFailed("Failed to fetch custom foods: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func fetchCustomFood(id: UUID) async throws -> CustomFood? {
        let descriptor = FetchDescriptor<CustomFoodSDModel>(
            predicate: #Predicate<CustomFoodSDModel> { $0.id == id }
        )
        do {
            let results = try container.mainContext.fetch(descriptor)
            return results.first?.toDomain()
        } catch {
            throw AppError.dataPersistenceFailed("Failed to fetch custom food: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func searchCustomFoods(query: String) async throws -> [CustomFood] {
        let clean = query.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()

        let all = try await fetchAllCustomFoods()
        guard !clean.isEmpty else { return all }

        return all.filter { food in
            let nameFolded = food.name.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let catFolded = food.category.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let brandFolded = food.brand?.folding(options: .diacriticInsensitive, locale: .current).lowercased() ?? ""
            return nameFolded.contains(clean) || catFolded.contains(clean) || brandFolded.contains(clean)
        }
    }

    @MainActor
    public func saveCustomFood(_ food: CustomFood) async throws {
        let context = container.mainContext
        let model = CustomFoodSDModel(from: food)
        context.insert(model)
        do {
            try context.save()
            AppLogger.data.info("Saved custom food: \(food.name)")
        } catch {
            throw AppError.dataPersistenceFailed("Failed to save custom food: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func updateCustomFood(_ food: CustomFood) async throws {
        let context = container.mainContext
        let targetId = food.id
        let descriptor = FetchDescriptor<CustomFoodSDModel>(
            predicate: #Predicate<CustomFoodSDModel> { $0.id == targetId }
        )
        do {
            if let existing = try context.fetch(descriptor).first {
                existing.name = food.name
                existing.category = food.category
                existing.brand = food.brand
                existing.servingUnit = food.servingUnit
                existing.servingSizeGrams = food.servingSizeGrams
                existing.calories = food.calories
                existing.proteinGrams = food.proteinGrams
                existing.carbGrams = food.carbGrams
                existing.fatGrams = food.fatGrams
                existing.fiberGrams = food.fiberGrams
                existing.sodiumMg = food.micronutrients?.sodiumMg
                existing.potassiumMg = food.micronutrients?.potassiumMg
                existing.calciumMg = food.micronutrients?.calciumMg
                existing.ironMg = food.micronutrients?.ironMg
                existing.vitaminAMcg = food.micronutrients?.vitaminAMcg
                existing.vitaminCMg = food.micronutrients?.vitaminCMg
                existing.sugarGrams = food.micronutrients?.sugarGrams
                existing.cholesterolMg = food.micronutrients?.cholesterolMg
                existing.notes = food.notes
                existing.isFavorite = food.isFavorite
                existing.updatedAt = Date()
                try context.save()
                AppLogger.data.info("Updated custom food: \(food.name)")
            } else {
                try await saveCustomFood(food)
            }
        } catch {
            throw AppError.dataPersistenceFailed("Failed to update custom food: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func deleteCustomFood(id: UUID) async throws {
        let context = container.mainContext
        let descriptor = FetchDescriptor<CustomFoodSDModel>(
            predicate: #Predicate<CustomFoodSDModel> { $0.id == id }
        )
        do {
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
                AppLogger.data.info("Deleted custom food ID: \(id)")
            }
        } catch {
            throw AppError.dataPersistenceFailed("Failed to delete custom food: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func toggleFavorite(id: UUID) async throws {
        let context = container.mainContext
        let descriptor = FetchDescriptor<CustomFoodSDModel>(
            predicate: #Predicate<CustomFoodSDModel> { $0.id == id }
        )
        do {
            if let existing = try context.fetch(descriptor).first {
                existing.isFavorite.toggle()
                existing.updatedAt = Date()
                try context.save()
                AppLogger.data.info("Toggled favorite for custom food ID: \(id)")
            }
        } catch {
            throw AppError.dataPersistenceFailed("Failed to toggle favorite: \(error.localizedDescription)")
        }
    }
}
