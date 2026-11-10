//
//  HydrationRecord.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Domain model representing a logged water intake entry.
//

import Foundation

public struct HydrationRecord: Identifiable, Equatable, Hashable, Codable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let amountLiters: Double
    public let notes: String?

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        amountLiters: Double,
        notes: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.amountLiters = amountLiters
        self.notes = notes
    }
}
