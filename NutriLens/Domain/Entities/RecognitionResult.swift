//
//  RecognitionResult.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public struct BoundingBox: Equatable, Hashable, Sendable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

public struct DetectedFoodCandidate: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public let item: FoodItem
    public let boundingBox: BoundingBox?

    public init(id: UUID = UUID(), item: FoodItem, boundingBox: BoundingBox? = nil) {
        self.id = id
        self.item = item
        self.boundingBox = boundingBox
    }
}

public struct RecognitionResult: Equatable, Sendable {
    public let candidates: [DetectedFoodCandidate]
    public let isOutOfDistribution: Bool
    public let inferenceDurationSeconds: TimeInterval
    public let modelVersion: String
    public let inferenceEngineName: String

    public init(
        candidates: [DetectedFoodCandidate],
        isOutOfDistribution: Bool,
        inferenceDurationSeconds: TimeInterval,
        modelVersion: String = "1.0.0-phase4",
        inferenceEngineName: String = "NutriLens Core ML"
    ) {
        self.candidates = candidates
        self.isOutOfDistribution = isOutOfDistribution
        self.inferenceDurationSeconds = inferenceDurationSeconds
        self.modelVersion = modelVersion
        self.inferenceEngineName = inferenceEngineName
    }

    public var primaryFood: FoodItem? {
        candidates.first?.item
    }
}
