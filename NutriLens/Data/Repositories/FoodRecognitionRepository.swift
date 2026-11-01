//
//  FoodRecognitionRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import CoreGraphics

public final class FoodRecognitionRepository: FoodRecognitionRepositoryProtocol, @unchecked Sendable {
    private let preprocessor: ImagePreprocessorProtocol
    private let inferenceEngine: (any ModelInferenceProtocol)?
    private let oodDetector: any OODDetectorProtocol

    public init(
        preprocessor: ImagePreprocessorProtocol = ImagePreprocessor(),
        inferenceEngine: (any ModelInferenceProtocol)? = nil,
        oodDetector: any OODDetectorProtocol = DefaultOODDetector()
    ) {
        self.preprocessor = preprocessor
        self.inferenceEngine = inferenceEngine
        self.oodDetector = oodDetector
    }

    public func recognizeFood(from imageData: Data) async throws -> RecognitionResult {
        guard let engine = inferenceEngine else {
            // Explicitly report that the real model has not been imported yet.
            // NO fake model or fake weights are manufactured.
            AppLogger.ai.warning("Core ML inference engine is not yet configured with a compiled model.")
            throw AppError.inferenceFailed("Core ML model bundle is pending integration from AI training pipeline.")
        }

        let startTime = CFAbsoluteTimeGetCurrent()
        let pixelBuffer = try preprocessor.preparePixelBuffer(from: imageData, targetSize: CGSize(width: 224, height: 224))
        let rawResults = try await engine.infer(pixelBuffer: pixelBuffer)

        let duration = CFAbsoluteTimeGetCurrent() - startTime
        let maxConfidence = rawResults.map(\.confidence).max() ?? 0.0
        let confidences = rawResults.map(\.confidence)

        let isOOD = oodDetector.isOutOfDistribution(confidences: confidences, maxConfidence: maxConfidence)
        if isOOD {
            return RecognitionResult(candidates: [], isOutOfDistribution: true, inferenceDurationSeconds: duration)
        }

        // Map predictions to domain entities
        let candidates = rawResults.prefix(3).map { raw -> DetectedFoodCandidate in
            let item = FoodItem(
                name: raw.identifier,
                vietnameseName: raw.identifier,
                confidence: raw.confidence,
                servingSizeGrams: 200,
                calories: 250,
                proteinGrams: 15,
                carbGrams: 30,
                fatGrams: 8,
                fiberGrams: 2
            )
            return DetectedFoodCandidate(item: item)
        }

        return RecognitionResult(
            candidates: Array(candidates),
            isOutOfDistribution: false,
            inferenceDurationSeconds: duration
        )
    }
}
