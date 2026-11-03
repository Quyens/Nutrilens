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
        inferenceEngine: (any ModelInferenceProtocol)? = CoreMLFoodInferenceEngine(),
        oodDetector: any OODDetectorProtocol = DefaultOODDetector()
    ) {
        self.preprocessor = preprocessor
        self.inferenceEngine = inferenceEngine
        self.oodDetector = oodDetector
    }

    public func recognizeFood(from imageData: Data) async throws -> RecognitionResult {
        guard let engine = inferenceEngine else {
            AppLogger.ai.warning("Core ML inference engine is not configured.")
            throw AppError.inferenceFailed("Core ML model bundle is pending integration from AI training pipeline.")
        }

        let startTime = CFAbsoluteTimeGetCurrent()
        let pixelBuffer = try preprocessor.preparePixelBuffer(from: imageData, targetSize: CGSize(width: 224, height: 224))
        let rawResults = try await engine.infer(pixelBuffer: pixelBuffer)

        let duration = CFAbsoluteTimeGetCurrent() - startTime
        let maxConfidence = rawResults.map(\.confidence).max() ?? 0.0
        let confidences = rawResults.map(\.confidence)

        let isCustomModel = engine.isCustomModelActive
        let engineDesc = engine.activeEngineDescription
        let modelVer = isCustomModel ? "1.0.0-phase4" : "Apple Vision OS Fallback"

        let isOOD = oodDetector.isOutOfDistribution(confidences: confidences, maxConfidence: maxConfidence)
        if isOOD || rawResults.isEmpty {
            return RecognitionResult(
                candidates: [],
                isOutOfDistribution: true,
                inferenceDurationSeconds: duration,
                modelVersion: modelVer,
                inferenceEngineName: engineDesc
            )
        }

        // Map predictions to authentic Vietnamese dishes from the traceable nutrition database
        var seenNames = Set<String>()
        var candidates: [DetectedFoodCandidate] = []

        for raw in rawResults.prefix(3) {
            let matchedItem = VietnameseNutritionDatabase.findBestMatch(
                for: raw.identifier,
                confidence: raw.confidence
            )
            if !seenNames.contains(matchedItem.vietnameseName) {
                seenNames.insert(matchedItem.vietnameseName)
                candidates.append(DetectedFoodCandidate(item: matchedItem))
            }
        }

        // If duplicate mappings reduced count, fill with top Vietnamese dishes
        if candidates.isEmpty {
            let defaultPho = VietnameseNutritionDatabase.findBestMatch(for: "pho", confidence: maxConfidence)
            candidates.append(DetectedFoodCandidate(item: defaultPho))
        }

        return RecognitionResult(
            candidates: candidates,
            isOutOfDistribution: false,
            inferenceDurationSeconds: duration,
            modelVersion: modelVer,
            inferenceEngineName: engineDesc
        )
    }
}
