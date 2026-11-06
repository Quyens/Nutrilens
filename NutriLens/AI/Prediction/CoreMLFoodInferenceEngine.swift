//
//  CoreMLFoodInferenceEngine.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Runs 100% on-device AI inference with offline support, Core ML & Apple Vision fallback.
//

import Foundation
import CoreGraphics
import CoreVideo
import Vision
#if canImport(CoreML)
import CoreML
#endif

public final class CoreMLFoodInferenceEngine: ModelInferenceProtocol, @unchecked Sendable {
    private let minimumConfidence: Double

    public var isCustomModelActive: Bool {
        Bundle.main.url(forResource: "FoodClassifier", withExtension: "mlmodelc") != nil
    }

    public var activeEngineDescription: String {
        if isCustomModelActive {
            return "NutriLens EfficientNet-B0 (v1.0.0-phase4)"
        } else {
            return "Apple Vision Fallback (Experimental)"
        }
    }

    public init(minimumConfidence: Double = 0.20) {
        self.minimumConfidence = minimumConfidence
    }

    public func infer(pixelBuffer: CVPixelBuffer) async throws -> [RawClassificationResult] {
        return try await withCheckedThrowingContinuation { continuation in
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])

            // 1. Check if a compiled Core ML model is embedded in the application bundle
            if let customModelURL = Bundle.main.url(forResource: "FoodClassifier", withExtension: "mlmodelc"),
               let customMLModel = try? MLModel(contentsOf: customModelURL),
               let vnCoreMLModel = try? VNCoreMLModel(for: customMLModel) {

                let coreMLRequest = VNCoreMLRequest(model: vnCoreMLModel) { request, error in
                    if let error = error {
                        continuation.resume(throwing: AppError.inferenceFailed("Core ML evaluation error: \(error.localizedDescription)"))
                        return
                    }

                    guard let observations = request.results as? [VNClassificationObservation] else {
                        continuation.resume(throwing: AppError.inferenceFailed("Malformed Core ML classification output."))
                        return
                    }

                    let results = observations.prefix(5).map { obs in
                        RawClassificationResult(identifier: obs.identifier, confidence: Double(obs.confidence))
                    }
                    continuation.resume(returning: results)
                }
                coreMLRequest.imageCropAndScaleOption = .centerCrop

                do {
                    try handler.perform([coreMLRequest])
                } catch {
                    continuation.resume(throwing: AppError.inferenceFailed("Handler execution failed: \(error.localizedDescription)"))
                }
                return
            }

            // 2. Built-in on-device Apple Vision Classifier (100% offline fallback)
            AppLogger.ai.warning("⚠️ NutriLens Core ML model (FoodClassifier.mlmodelc) not found in bundle. Using Apple Vision fallback classifier.")

            let classifyRequest = VNClassifyImageRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: AppError.inferenceFailed("Vision classification error: \(error.localizedDescription)"))
                    return
                }

                guard let observations = request.results as? [VNClassificationObservation] else {
                    continuation.resume(throwing: AppError.inferenceFailed("No classification observations returned."))
                    return
                }

                // Filter for food-related observations in Apple's built-in taxonomy
                let foodKeywords = ["food", "dish", "noodle", "soup", "rice", "sandwich", "bread", "salad", "meat", "pork", "beef", "chicken", "seafood", "egg", "vegetable", "pastry", "curry", "broth"]

                let relevant = observations.filter { obs in
                    let id = obs.identifier.lowercased()
                    return foodKeywords.contains { kw in id.contains(kw) }
                }

                if !relevant.isEmpty {
                    let results = relevant.prefix(3).map { obs in
                        RawClassificationResult(identifier: obs.identifier, confidence: Double(obs.confidence))
                    }
                    continuation.resume(returning: results)
                } else {
                    // Return raw top observations even if not strictly tagged as food to allow OOD detector to evaluate
                    let top = observations.prefix(3).map { obs in
                        RawClassificationResult(identifier: obs.identifier, confidence: Double(obs.confidence))
                    }
                    continuation.resume(returning: top)
                }
            }

            do {
                try handler.perform([classifyRequest])
            } catch {
                continuation.resume(throwing: AppError.inferenceFailed("Vision request execution failed: \(error.localizedDescription)"))
            }
        }
    }
}
