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
    /// True if the compiled NutriLens Core ML model (.mlmodelc) is bundled and active
    var isCustomModelActive: Bool { get }

    /// Human-readable description of the active inference engine
    var activeEngineDescription: String { get }

    /// Executes prediction against preprocessed pixel buffer.
    func infer(pixelBuffer: CVPixelBuffer) async throws -> [RawClassificationResult]
}
