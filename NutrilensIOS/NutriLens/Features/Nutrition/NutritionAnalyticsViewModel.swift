//
//  NutritionAnalyticsViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Coordinates Nutrition Analytics V2: Period selection, interactive chart scrubbing,
//  macronutrient breakdown, and explainable insight generation.
//

import Foundation
import SwiftUI

@MainActor
public final class NutritionAnalyticsViewModel: ObservableObject {
    // MARK: - Published State
    @Published public var selectedPeriod: AnalyticsPeriodType = .week
    @Published public var anchorDate: Date = Date()
    @Published public private(set) var state: AsyncState<PeriodAnalyticsData> = .idle
    @Published public var selectedChartPoint: DailyCaloriePoint? = nil

    // MARK: - Dependencies
    private let getNutritionAnalyticsUseCase: GetNutritionAnalyticsUseCaseProtocol
    private let calendar: Calendar

    public init(
        getNutritionAnalyticsUseCase: GetNutritionAnalyticsUseCaseProtocol,
        calendar: Calendar = Calendar.current
    ) {
        self.getNutritionAnalyticsUseCase = getNutritionAnalyticsUseCase
        self.calendar = calendar
    }

    // MARK: - Computed Convenience
    public var analyticsData: PeriodAnalyticsData? {
        state.value
    }

    public var isLoading: Bool {
        state.isLoading
    }

    /// Determines if navigation forward in time is allowed (disallow navigating past current period)
    public var canGoForward: Bool {
        let now = Date()
        switch selectedPeriod {
        case .day:
            return !calendar.isDate(anchorDate, inSameDayAs: now) && anchorDate < now
        case .week:
            let isCurrentWeek = calendar.isDate(anchorDate, equalTo: now, toGranularity: .weekOfYear)
                && calendar.isDate(anchorDate, equalTo: now, toGranularity: .yearForWeekOfYear)
            return !isCurrentWeek && anchorDate < now
        case .month:
            let isCurrentMonth = calendar.isDate(anchorDate, equalTo: now, toGranularity: .month)
                && calendar.isDate(anchorDate, equalTo: now, toGranularity: .year)
            return !isCurrentMonth && anchorDate < now
        }
    }

    public var periodSubtitle: String {
        guard let data = analyticsData else { return "" }
        return data.formattedPeriodTitle
    }

    // MARK: - Actions

    public func loadAnalytics() async {
        state = .loading
        do {
            let data = try await getNutritionAnalyticsUseCase.execute(
                periodType: selectedPeriod,
                anchorDate: anchorDate,
                calendar: calendar
            )
            state = .success(data)
            // Auto-select latest recorded point or nil
            selectedChartPoint = nil
        } catch {
            state = .failure(.dataPersistenceFailed(error.localizedDescription))
        }
    }

    public func selectPeriod(_ period: AnalyticsPeriodType) {
        guard selectedPeriod != period else { return }
        selectedPeriod = period
        anchorDate = Date()
        Task {
            await loadAnalytics()
        }
    }

    public func shiftPeriod(by offset: Int) {
        var comp = DateComponents()
        switch selectedPeriod {
        case .day:
            comp.day = offset
        case .week:
            comp.weekOfYear = offset
        case .month:
            comp.month = offset
        }

        if let newDate = calendar.date(byAdding: comp, to: anchorDate) {
            // Guard against navigating into the future
            let now = Date()
            if offset > 0 && newDate > now {
                switch selectedPeriod {
                case .day where calendar.isDate(newDate, inSameDayAs: now):
                    anchorDate = newDate
                case .week where calendar.isDate(newDate, equalTo: now, toGranularity: .weekOfYear):
                    anchorDate = newDate
                case .month where calendar.isDate(newDate, equalTo: now, toGranularity: .month):
                    anchorDate = newDate
                default:
                    return
                }
            } else {
                anchorDate = newDate
            }

            Task {
                await loadAnalytics()
            }
        }
    }

    public func resetToCurrentPeriod() {
        anchorDate = Date()
        Task {
            await loadAnalytics()
        }
    }

    public func selectPoint(_ point: DailyCaloriePoint?) {
        withAnimation(.easeInOut(duration: 0.15)) {
            selectedChartPoint = point
        }
    }
}
