//
//  ModelInferenceProtocol.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import CoreGraphics
import CoreVideo

public struct RawClassificationResult: Sendable {
    public let identifier: String
    public let confidence: Double

    public init(identifier: String, confidence: Double) {
        self.identifier = identifier
        self.confidence = confidence
    }
}

public protocol ModelInferenceProtocol: Sendable {
    /// Executes Core ML prediction against preprocessed pixel buffer.
    func infer(pixelBuffer: CVPixelBuffer) async throws -> [RawClassificationResult]
}
