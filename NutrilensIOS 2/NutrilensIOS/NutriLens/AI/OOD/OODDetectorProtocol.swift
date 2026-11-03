//
//  OODDetectorProtocol.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol OODDetectorProtocol: Sendable {
    var threshold: Double { get }
    var isValidated: Bool { get }
    var calibrationDescription: String { get }

    /// Determines whether the prediction or embedding is Out-Of-Distribution (non-food).
    func isOutOfDistribution(confidences: [Double], maxConfidence: Double) -> Bool
}

/// Validated OOD Detector for NutriLens EfficientNet-B0 (Experiment B)
/// Evaluated in Phase 4 research with Temperature Scaling T=1.5.
public final class ValidatedEfficientNetB0OODDetector: OODDetectorProtocol {
    public let threshold: Double = 0.70
    public let temperature: Double = 1.5
    public let isValidated: Bool = true
    public let calibrationDescription: String = "Validated in Phase 4 (Experiment B) on 3,012 test images with 89.71% unknown rejection rate and AUROC 0.872."

    public init() {}

    public func isOutOfDistribution(confidences: [Double], maxConfidence: Double) -> Bool {
        return maxConfidence < threshold
    }
}

/// Fallback OOD Detector for Apple Vision Framework
/// Explicitly flagged as unvalidated heuristic because Apple Vision uses an open multi-label taxonomy.
public final class UnvalidatedVisionFallbackOODDetector: OODDetectorProtocol {
    public let threshold: Double
    public let isValidated: Bool = false
    public let calibrationDescription: String = "UNVALIDATED: Heuristic threshold for Apple Vision open-set taxonomy to prevent total rejection. Not calibrated for clinical or production use."

    public init(threshold: Double = 0.45) {
        self.threshold = threshold
    }

    public func isOutOfDistribution(confidences: [Double], maxConfidence: Double) -> Bool {
        return maxConfidence < threshold
    }
}

/// Universal OOD Detector adapter that delegates to validated or fallback implementation based on engine
public final class DefaultOODDetector: OODDetectorProtocol {
    private let underlyingDetector: any OODDetectorProtocol

    public var threshold: Double { underlyingDetector.threshold }
    public var isValidated: Bool { underlyingDetector.isValidated }
    public var calibrationDescription: String { underlyingDetector.calibrationDescription }

    public init(minimumConfidenceThreshold: Double = 0.45) {
        self.underlyingDetector = UnvalidatedVisionFallbackOODDetector(threshold: minimumConfidenceThreshold)
    }

    public init(forCustomModel: Bool) {
        if forCustomModel {
            self.underlyingDetector = ValidatedEfficientNetB0OODDetector()
        } else {
            self.underlyingDetector = UnvalidatedVisionFallbackOODDetector()
        }
    }

    public init(customThreshold: Double, isValidated: Bool = false, description: String = "Custom threshold") {
        struct CustomOOD: OODDetectorProtocol {
            let threshold: Double
            let isValidated: Bool
            let calibrationDescription: String
            func isOutOfDistribution(confidences: [Double], maxConfidence: Double) -> Bool {
                maxConfidence < threshold
            }
        }
        self.underlyingDetector = CustomOOD(threshold: customThreshold, isValidated: isValidated, calibrationDescription: description)
    }

    public func isOutOfDistribution(confidences: [Double], maxConfidence: Double) -> Bool {
        underlyingDetector.isOutOfDistribution(confidences: confidences, maxConfidence: maxConfidence)
    }
}
