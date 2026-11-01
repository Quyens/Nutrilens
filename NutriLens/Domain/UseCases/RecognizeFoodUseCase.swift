//
//  RecognizeFoodUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol RecognizeFoodUseCaseProtocol: Sendable {
    func execute(imageData: Data) async throws -> RecognitionResult
}

public final class RecognizeFoodUseCase: RecognizeFoodUseCaseProtocol {
    private let repository: FoodRecognitionRepositoryProtocol

    public init(repository: FoodRecognitionRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(imageData: Data) async throws -> RecognitionResult {
        guard !imageData.isEmpty else {
            throw AppError.invalidInput("Image payload cannot be empty.")
        }
        let result = try await repository.recognizeFood(from: imageData)
        if result.isOutOfDistribution {
            throw AppError.outOfDistribution
        }
        return result
    }
}
