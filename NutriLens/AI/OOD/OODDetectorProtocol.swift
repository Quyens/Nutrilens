//
//  OODDetectorProtocol.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol OODDetectorProtocol: Sendable {
    /// Determines whether the prediction or embedding is Out-Of-Distribution (non-food).
    func isOutOfDistribution(confidences: [Double], maxConfidence: Double) -> Bool
}

public final class DefaultOODDetector: OODDetectorProtocol {
    private let minimumConfidenceThreshold: Double

    public init(minimumConfidenceThreshold: Double = 0.45) {
        self.minimumConfidenceThreshold = minimumConfidenceThreshold
    }

    public func isOutOfDistribution(confidences: [Double], maxConfidence: Double) -> Bool {
        // If the highest prediction confidence is below the threshold, treat as OOD
        return maxConfidence < minimumConfidenceThreshold
    }
}
