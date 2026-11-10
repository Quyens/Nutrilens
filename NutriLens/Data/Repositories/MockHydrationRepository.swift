//
//  MockHydrationRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public final class MockHydrationRepository: HydrationRepositoryProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var records: [HydrationRecord]

    public init(initialRecords: [HydrationRecord] = []) {
        self.records = initialRecords
    }

    public func fetchHydration(for date: Date) async throws -> [HydrationRecord] {
        lock.lock()
        defer { lock.unlock() }
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        return records.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
    }

    public func fetchHydration(from startDate: Date, to endDate: Date) async throws -> [HydrationRecord] {
        lock.lock()
        defer { lock.unlock() }
        return records.filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
    }

    public func fetchDailyTotal(for date: Date) async throws -> Double {
        let daily = try await fetchHydration(for: date)
        let total = daily.reduce(0.0) { $0 + $1.amountLiters }
        return (total * 100).rounded() / 100
    }

    public func saveHydration(_ record: HydrationRecord) async throws {
        lock.lock()
        defer { lock.unlock() }
        records.append(record)
    }

    public func deleteHydration(id: UUID) async throws {
        lock.lock()
        defer { lock.unlock() }
        records.removeAll { $0.id == id }
    }

    public func migrateLegacyUserDefaultsIfNeeded() async throws {
        // No-op for mock testing
    }
}
