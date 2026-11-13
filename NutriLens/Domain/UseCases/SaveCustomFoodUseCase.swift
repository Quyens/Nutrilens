//
//  SaveCustomFoodUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol SaveCustomFoodUseCaseProtocol: Sendable {
    func execute(_ food: CustomFood) async throws
    func toggleFavorite(id: UUID) async throws
}

public final class SaveCustomFoodUseCase: SaveCustomFoodUseCaseProtocol, Sendable {
    private let repository: CustomFoodRepositoryProtocol

    public init(repository: CustomFoodRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ food: CustomFood) async throws {
        guard !food.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AppError.invalidInput("Tên món ăn không được để trống.")
        }
        guard food.servingSizeGrams > 0 else {
            throw AppError.invalidInput("Khẩu phần phải lớn hơn 0g.")
        }
        guard food.calories >= 0 && food.proteinGrams >= 0 && food.carbGrams >= 0 && food.fatGrams >= 0 else {
            throw AppError.invalidInput("Giá trị dinh dưỡng không thể âm.")
        }

        let existing = try await repository.fetchCustomFood(id: food.id)
        if existing != nil {
            try await repository.updateCustomFood(food)
        } else {
            try await repository.saveCustomFood(food)
        }
    }

    public func toggleFavorite(id: UUID) async throws {
        try await repository.toggleFavorite(id: id)
    }
}

