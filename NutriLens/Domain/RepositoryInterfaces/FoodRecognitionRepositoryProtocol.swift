//
//  FoodRecognitionRepositoryProtocol.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol FoodRecognitionRepositoryProtocol: Sendable {
    /// Runs food detection and nutritional inference on image binary data.
    func recognizeFood(from imageData: Data) async throws -> RecognitionResult
}
