//
//  CopyDayPlanUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Copies planned meals from a source day to a target day (append or replace).
//

import Foundation

public enum CopyDayPlanMode: String, CaseIterable, Sendable {
    case append = "append"
    case replace = "replace"

    public var vietnameseTitle: String {
        switch self {
        case .append: return "Thêm tiếp vào ngày đích (Giữ món cũ)"
        case .replace: return "Ghi đè ngày đích (Xóa món cũ của ngày đích)"
        }
    }
}

public protocol CopyDayPlanUseCaseProtocol: Sendable {
    func execute(
        from sourceDate: Date,
        to targetDate: Date,
        mode: CopyDayPlanMode
    ) async throws -> Int
}

public final class CopyDayPlanUseCase: CopyDayPlanUseCaseProtocol {
    private let repository: MealPlanRepositoryProtocol
    private let calendarHelper: MealPlanCalendarHelper

    public init(
        repository: MealPlanRepositoryProtocol,
        calendarHelper: MealPlanCalendarHelper = MealPlanCalendarHelper()
    ) {
        self.repository = repository
        self.calendarHelper = calendarHelper
    }

    public func execute(
        from sourceDate: Date,
        to targetDate: Date,
        mode: CopyDayPlanMode
    ) async throws -> Int {
        if calendarHelper.isSameDay(sourceDate, targetDate) {
            throw AppError.invalidInput("Ngày nguồn và ngày đích không được trùng nhau.")
        }

        let sourceMeals = try await repository.getPlannedMeals(forDay: sourceDate)
        guard !sourceMeals.isEmpty else {
            throw AppError.invalidInput("Không có bữa ăn nào trong ngày được chọn để sao chép.")
        }

        // If replace mode, delete all existing meals in target day first
        if mode == .replace {
            let targetMeals = try await repository.getPlannedMeals(forDay: targetDate)
            for targetMeal in targetMeals {
                try await repository.deletePlannedMeal(id: targetMeal.id)
            }
        }

        var copiedCount = 0
        let normalizedTargetDate = calendarHelper.startOfDay(for: targetDate)

        for sourceMeal in sourceMeals {
            // Duplicate meal with clean ID, scheduled on targetDate, reset to .planned, clear linkedDiaryRecordId
            let duplicated = sourceMeal.duplicate(forDate: normalizedTargetDate)
            try await repository.savePlannedMeal(duplicated)
            copiedCount += 1
        }

        return copiedCount
    }
}
