//
//  SavePackagedFoodUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Validates and persists packaged food items into user SwiftData storage.
//

import Foundation

public final class SavePackagedFoodUseCase: Sendable {
    private let repository: PackagedFoodRepositoryProtocol

    public init(repository: PackagedFoodRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ food: PackagedFood) async throws {
        let cleanName = food.productName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else {
            throw AppError.invalidInput("Tên sản phẩm không được để trống")
        }

        let barcodeVal = BarcodeValue(rawValue: food.barcode)
        guard barcodeVal.isValid else {
            throw AppError.invalidInput(barcodeVal.validationError ?? "Mã vạch không hợp lệ")
        }

        guard food.serving.servingSize > 0 else {
            throw AppError.invalidInput("Kích thước khẩu phần phải lớn hơn 0")
        }

        var normalizedFood = food
        normalizedFood.productName = cleanName
        normalizedFood.barcode = barcodeVal.normalizedValue
        normalizedFood.barcodeType = barcodeVal.type
        normalizedFood.updatedAt = Date()

        try await repository.save(normalizedFood)
    }
}

