//
//  HydrationRepositoryProtocol.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public protocol HydrationRepositoryProtocol: Sendable {
    func fetchHydration(for date: Date) async throws -> [HydrationRecord]
    func fetchHydration(from startDate: Date, to endDate: Date) async throws -> [HydrationRecord]
    func fetchDailyTotal(for date: Date) async throws -> Double
    func saveHydration(_ record: HydrationRecord) async throws
    func deleteHydration(id: UUID) async throws
    func migrateLegacyUserDefaultsIfNeeded() async throws
}
