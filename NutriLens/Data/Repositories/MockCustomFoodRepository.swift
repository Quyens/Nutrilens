//
//  MockCustomFoodRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public final class MockCustomFoodRepository: CustomFoodRepositoryProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var foods: [CustomFood]

    public init(initialFoods: [CustomFood]? = nil) {
        if let initialFoods {
            self.foods = initialFoods
        } else {
            self.foods = Self.sampleCustomFoods
        }
    }

    public func fetchAllCustomFoods() async throws -> [CustomFood] {
        lock.lock()
        defer { lock.unlock() }
        return foods.sorted { (a, b) -> Bool in
            if a.isFavorite != b.isFavorite {
                return a.isFavorite && !b.isFavorite
            }
            return a.createdAt > b.createdAt
        }
    }

    public func fetchCustomFood(id: UUID) async throws -> CustomFood? {
        lock.lock()
        defer { lock.unlock() }
        return foods.first { $0.id == id }
    }

    public func searchCustomFoods(query: String) async throws -> [CustomFood] {
        lock.lock()
        defer { lock.unlock() }
        let clean = query.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
        guard !clean.isEmpty else { return foods }

        return foods.filter { food in
            let nameFolded = food.name.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let catFolded = food.category.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            return nameFolded.contains(clean) || catFolded.contains(clean)
        }
    }

    public func saveCustomFood(_ food: CustomFood) async throws {
        lock.lock()
        defer { lock.unlock() }
        foods.removeAll { $0.id == food.id }
        foods.insert(food, at: 0)
    }

    public func updateCustomFood(_ food: CustomFood) async throws {
        lock.lock()
        defer { lock.unlock() }
        if let index = foods.firstIndex(where: { $0.id == food.id }) {
            foods[index] = food
        } else {
            foods.insert(food, at: 0)
        }
    }

    public func deleteCustomFood(id: UUID) async throws {
        lock.lock()
        defer { lock.unlock() }
        foods.removeAll { $0.id == id }
    }

    public func toggleFavorite(id: UUID) async throws {
        lock.lock()
        defer { lock.unlock() }
        if let index = foods.firstIndex(where: { $0.id == id }) {
            var item = foods[index]
            item.isFavorite.toggle()
            item.updatedAt = Date()
            foods[index] = item
        }
    }

    // MARK: - Sample Data for SwiftUI Previews & Tests
    public static let sampleCustomFoods: [CustomFood] = [
        CustomFood(
            name: "Sữa Hạt Óc Chó Hạnh Nhân Nhà Làm",
            category: "Đồ uống",
            brand: "Tự nấu",
            servingUnit: "ml",
            servingSizeGrams: 250,
            calories: 165,
            proteinGrams: 5.5,
            carbGrams: 12.0,
            fatGrams: 11.0,
            fiberGrams: 2.5,
            micronutrients: MicronutrientProfile(calciumMg: 120, ironMg: 1.2, sugarGrams: 4.0),
            notes: "Nấu từ hạt óc chó và hạnh nhân nguyên chất, không đường tinh luyện.",
            isFavorite: true
        ),
        CustomFood(
            name: "Granola Yến Mạch Mật Ong Táo Đỏ",
            category: "Đồ ăn nhẹ",
            brand: "Bếp Nhà Làm",
            servingUnit: "g",
            servingSizeGrams: 50,
            calories: 215,
            proteinGrams: 6.0,
            carbGrams: 28.0,
            fatGrams: 9.0,
            fiberGrams: 4.5,
            micronutrients: MicronutrientProfile(ironMg: 2.1, sugarGrams: 6.5),
            notes: "Nướng vàng giòn với dầu dừa ép lạnh và mật hoa dừa.",
            isFavorite: true
        ),
        CustomFood(
            name: "Ức Gà Nướng Tiêu Chanh Áp Chảo",
            category: "Món chính",
            brand: nil,
            servingUnit: "g",
            servingSizeGrams: 150,
            calories: 220,
            proteinGrams: 36.0,
            carbGrams: 1.5,
            fatGrams: 7.0,
            fiberGrams: 0.5,
            micronutrients: MicronutrientProfile(sodiumMg: 280, potassiumMg: 350),
            notes: "Ức gà ướp sốt tiêu đen, muối hồng và nước cốt chanh.",
            isFavorite: false
        )
    ]
}

