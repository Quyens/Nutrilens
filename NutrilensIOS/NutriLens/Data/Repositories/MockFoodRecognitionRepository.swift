//
//  MockFoodRecognitionRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  IMPORTANT: This is a test/preview mock repository strictly used for SwiftUI Previews
//  and automated UI testing. It does NOT claim that the real AI model is integrated or functioning.
//

import Foundation

public final class MockFoodRecognitionRepository: FoodRecognitionRepositoryProtocol, @unchecked Sendable {
    public var shouldSimulateOOD: Bool
    public var simulatedDelaySeconds: TimeInterval

    public init(shouldSimulateOOD: Bool = false, simulatedDelaySeconds: TimeInterval = 0.5) {
        self.shouldSimulateOOD = shouldSimulateOOD
        self.simulatedDelaySeconds = simulatedDelaySeconds
    }

    public func recognizeFood(from imageData: Data) async throws -> RecognitionResult {
        if simulatedDelaySeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelaySeconds * 1_000_000_000))
        }

        if shouldSimulateOOD {
            return RecognitionResult(
                candidates: [],
                isOutOfDistribution: true,
                inferenceDurationSeconds: simulatedDelaySeconds
            )
        }

        let samplePho = FoodItem(
            name: "Vietnamese Beef Pho",
            vietnameseName: "Phở Bò Tái",
            confidence: 0.94,
            servingSizeGrams: 450,
            calories: 480,
            proteinGrams: 32,
            carbGrams: 62,
            fatGrams: 12,
            fiberGrams: 3
        )

        let candidate = DetectedFoodCandidate(
            item: samplePho,
            boundingBox: BoundingBox(x: 0.1, y: 0.15, width: 0.8, height: 0.7)
        )

        return RecognitionResult(
            candidates: [candidate],
            isOutOfDistribution: false,
            inferenceDurationSeconds: simulatedDelaySeconds
        )
    }
}
