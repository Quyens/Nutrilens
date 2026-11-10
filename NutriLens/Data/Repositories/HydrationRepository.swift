//
//  HydrationRepository.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  SwiftData implementation of HydrationRepositoryProtocol with safe legacy migration.
//

import Foundation
import SwiftData

public final class HydrationRepository: HydrationRepositoryProtocol, @unchecked Sendable {
    private let container: ModelContainer

    public init(container: ModelContainer = SwiftDataStack.shared.container) {
        self.container = container
    }

    @MainActor
    public func fetchHydration(for date: Date) async throws -> [HydrationRecord] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let descriptor = FetchDescriptor<HydrationRecordSDModel>(
            predicate: #Predicate<HydrationRecordSDModel> {
                $0.timestamp >= startOfDay && $0.timestamp < endOfDay
            },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )

        do {
            let results = try container.mainContext.fetch(descriptor)
            return results.map { $0.toDomain() }
        } catch {
            throw AppError.dataPersistenceFailed("Failed to fetch hydration: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func fetchHydration(from startDate: Date, to endDate: Date) async throws -> [HydrationRecord] {
        let start = startDate
        let end = endDate

        let descriptor = FetchDescriptor<HydrationRecordSDModel>(
            predicate: #Predicate<HydrationRecordSDModel> {
                $0.timestamp >= start && $0.timestamp <= end
            },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )

        do {
            let results = try container.mainContext.fetch(descriptor)
            return results.map { $0.toDomain() }
        } catch {
            throw AppError.dataPersistenceFailed("Failed to fetch hydration range: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func fetchDailyTotal(for date: Date) async throws -> Double {
        let records = try await fetchHydration(for: date)
        let total = records.reduce(0.0) { $0 + $1.amountLiters }
        return (total * 10).rounded() / 10
    }

    @MainActor
    public func saveHydration(_ record: HydrationRecord) async throws {
        let context = container.mainContext
        let sdModel = HydrationRecordSDModel(from: record)
        context.insert(sdModel)
        do {
            try context.save()
        } catch {
            throw AppError.dataPersistenceFailed("Failed to save hydration entry: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func deleteHydration(id: UUID) async throws {
        let targetId = id
        let context = container.mainContext
        let descriptor = FetchDescriptor<HydrationRecordSDModel>(
            predicate: #Predicate<HydrationRecordSDModel> { $0.id == targetId }
        )

        do {
            let results = try context.fetch(descriptor)
            for model in results {
                context.delete(model)
            }
            try context.save()
        } catch {
            throw AppError.dataPersistenceFailed("Failed to delete hydration entry: \(error.localizedDescription)")
        }
    }

    @MainActor
    public func migrateLegacyUserDefaultsIfNeeded() async throws {
        let migrationKey = "nutrilens_hydration_migrated_v2"
        let defaults = UserDefaults.standard

        guard !defaults.bool(forKey: migrationKey) else {
            return
        }

        let prefix = "nutrilens_water_intake_"
        let formatterDash = DateFormatter()
        formatterDash.dateFormat = "yyyy-MM-dd"
        formatterDash.locale = Locale(identifier: "en_US_POSIX")

        let formatterUnderscore = DateFormatter()
        formatterUnderscore.dateFormat = "yyyy_MM_dd"
        formatterUnderscore.locale = Locale(identifier: "en_US_POSIX")

        let allEntries = defaults.dictionaryRepresentation()
        let context = container.mainContext
        var migratedCount = 0

        for (key, value) in allEntries where key.hasPrefix(prefix) {
            let dateStr = String(key.dropFirst(prefix.count))
            guard let date = formatterDash.date(from: dateStr) ?? formatterUnderscore.date(from: dateStr),
                  let amount = value as? Double, amount > 0 else {
                continue
            }

            // Check if a record already exists for this day to avoid duplicate migrations
            let existing = try await fetchHydration(for: date)
            if existing.isEmpty {
                let model = HydrationRecordSDModel(
                    timestamp: date,
                    amountLiters: amount,
                    notes: "Dữ liệu nước uống chuyển tiếp từ bộ nhớ cục bộ"
                )
                context.insert(model)
                migratedCount += 1
            }
            defaults.removeObject(forKey: key)
        }

        if migratedCount > 0 {
            try? context.save()
            AppLogger.data.info("Successfully migrated \(migratedCount) legacy hydration records into SwiftData.")
        }

        // Mark migration as completed
        defaults.set(true, forKey: migrationKey)
    }
}
