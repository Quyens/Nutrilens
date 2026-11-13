//
//  WeeklyMealPlannerViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Presentation ViewModel for Weekly Meal Planner.
//

import Foundation
import SwiftUI

@MainActor
public final class WeeklyMealPlannerViewModel: ObservableObject {
    // MARK: - Published State
    @Published public var selectedDate: Date
    @Published public var currentWeekStartDate: Date
    @Published public var weeklyPlan: WeeklyMealPlan
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil

    // Sheets & Dialogs Presentation
    @Published public var isShowingAddMealSheet: Bool = false
    @Published public var presetCategoryForAdd: PlannedMealCategory? = nil
    @Published public var selectedMealForDetail: PlannedMeal? = nil
    @Published public var mealToEdit: PlannedMeal? = nil
    @Published public var isShowingCopyDaySheet: Bool = false
    @Published public var mealToLogToDiary: PlannedMeal? = nil
    @Published public var alertMessage: String? = nil
    @Published public var showAlert: Bool = false

    // MARK: - Dependencies
    private let getWeeklyMealPlanUseCase: GetWeeklyMealPlanUseCaseProtocol
    private let savePlannedMealUseCase: SavePlannedMealUseCaseProtocol
    private let deletePlannedMealUseCase: DeletePlannedMealUseCaseProtocol
    private let markPlannedMealStatusUseCase: MarkPlannedMealStatusUseCaseProtocol
    private let copyDayPlanUseCase: CopyDayPlanUseCaseProtocol
    private let logPlannedMealToDiaryUseCase: LogPlannedMealToDiaryUseCaseProtocol
    public let calendarHelper: MealPlanCalendarHelper

    public init(
        getWeeklyMealPlanUseCase: GetWeeklyMealPlanUseCaseProtocol,
        savePlannedMealUseCase: SavePlannedMealUseCaseProtocol,
        deletePlannedMealUseCase: DeletePlannedMealUseCaseProtocol,
        markPlannedMealStatusUseCase: MarkPlannedMealStatusUseCaseProtocol,
        copyDayPlanUseCase: CopyDayPlanUseCaseProtocol,
        logPlannedMealToDiaryUseCase: LogPlannedMealToDiaryUseCaseProtocol,
        calendarHelper: MealPlanCalendarHelper = MealPlanCalendarHelper(),
        initialDate: Date = Date()
    ) {
        self.getWeeklyMealPlanUseCase = getWeeklyMealPlanUseCase
        self.savePlannedMealUseCase = savePlannedMealUseCase
        self.deletePlannedMealUseCase = deletePlannedMealUseCase
        self.markPlannedMealStatusUseCase = markPlannedMealStatusUseCase
        self.copyDayPlanUseCase = copyDayPlanUseCase
        self.logPlannedMealToDiaryUseCase = logPlannedMealToDiaryUseCase
        self.calendarHelper = calendarHelper

        let normalizedToday = calendarHelper.startOfDay(for: initialDate)
        self.selectedDate = normalizedToday
        let monday = calendarHelper.startOfWeek(for: normalizedToday)
        self.currentWeekStartDate = monday
        self.weeklyPlan = WeeklyMealPlan(
            weekStartDate: monday,
            weekEndDate: calendarHelper.endOfWeek(for: normalizedToday)
        )
    }

    public convenience init(environment: AppEnvironment? = nil, initialDate: Date = Date()) {
        let env = environment ?? .live()
        self.init(
            getWeeklyMealPlanUseCase: env.getWeeklyMealPlanUseCase,
            savePlannedMealUseCase: env.savePlannedMealUseCase,
            deletePlannedMealUseCase: env.deletePlannedMealUseCase,
            markPlannedMealStatusUseCase: env.markPlannedMealStatusUseCase,
            copyDayPlanUseCase: env.copyDayPlanUseCase,
            logPlannedMealToDiaryUseCase: env.logPlannedMealToDiaryUseCase,
            calendarHelper: MealPlanCalendarHelper(),
            initialDate: initialDate
        )
    }

    // MARK: - Calendar Navigation
    public var daysInCurrentWeek: [Date] {
        calendarHelper.daysOfWeek(for: currentWeekStartDate)
    }

    public var currentWeekRangeString: String {
        calendarHelper.formatWeekRange(for: currentWeekStartDate)
    }

    public var isCurrentWeekToday: Bool {
        let thisWeekMonday = calendarHelper.startOfWeek(for: Date())
        return calendarHelper.isSameDay(currentWeekStartDate, thisWeekMonday)
    }

    public func selectDate(_ date: Date) {
        selectedDate = calendarHelper.startOfDay(for: date)
    }

    public func goToPreviousWeek() {
        currentWeekStartDate = calendarHelper.addingWeeks(-1, to: currentWeekStartDate)
        // If selectedDate is not in the new week, update selectedDate to new week's Monday
        let newWeekDays = daysInCurrentWeek
        if !newWeekDays.contains(where: { calendarHelper.isSameDay($0, selectedDate) }) {
            selectedDate = currentWeekStartDate
        }
        Task { await loadWeeklyPlan() }
    }

    public func goToNextWeek() {
        currentWeekStartDate = calendarHelper.addingWeeks(1, to: currentWeekStartDate)
        let newWeekDays = daysInCurrentWeek
        if !newWeekDays.contains(where: { calendarHelper.isSameDay($0, selectedDate) }) {
            selectedDate = currentWeekStartDate
        }
        Task { await loadWeeklyPlan() }
    }

    public func goToToday() {
        let today = calendarHelper.startOfDay(for: Date())
        selectedDate = today
        currentWeekStartDate = calendarHelper.startOfWeek(for: today)
        Task { await loadWeeklyPlan() }
    }

    // MARK: - Daily Meal Queries
    public var mealsForSelectedDate: [PlannedMeal] {
        weeklyPlan.meals(for: selectedDate, calendar: calendarHelper.calendar)
    }

    public func mealsForSelectedDate(category: PlannedMealCategory) -> [PlannedMeal] {
        weeklyPlan.meals(for: selectedDate, category: category, calendar: calendarHelper.calendar)
    }

    public var dailyPlannedNutrition: PlannedNutritionSnapshot {
        weeklyPlan.estimatedDailyNutrition(for: selectedDate, calendar: calendarHelper.calendar)
    }

    public var completedMealsCountForSelectedDate: Int {
        mealsForSelectedDate.filter { $0.status == .completed }.count
    }

    public var totalMealsCountForSelectedDate: Int {
        mealsForSelectedDate.count
    }

    // MARK: - Operations
    public func loadWeeklyPlan() async {
        isLoading = true
        errorMessage = nil
        do {
            let plan = try await getWeeklyMealPlanUseCase.execute(forWeekContaining: currentWeekStartDate)
            self.weeklyPlan = plan
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    public func openAddMeal(category: PlannedMealCategory? = nil) {
        presetCategoryForAdd = category
        isShowingAddMealSheet = true
    }

    public func saveMeal(_ meal: PlannedMeal) async {
        do {
            try await savePlannedMealUseCase.execute(meal)
            await loadWeeklyPlan()
        } catch {
            displayError(error.localizedDescription)
        }
    }

    public func deleteMeal(_ meal: PlannedMeal) async {
        do {
            try await deletePlannedMealUseCase.execute(id: meal.id)
            if selectedMealForDetail?.id == meal.id {
                selectedMealForDetail = nil
            }
            await loadWeeklyPlan()
        } catch {
            displayError(error.localizedDescription)
        }
    }

    public func markMealSkipped(_ meal: PlannedMeal) async {
        do {
            try await markPlannedMealStatusUseCase.markSkipped(mealId: meal.id)
            await loadWeeklyPlan()
        } catch {
            displayError(error.localizedDescription)
        }
    }

    public func restorePlannedStatus(_ meal: PlannedMeal) async {
        do {
            try await markPlannedMealStatusUseCase.restorePlanned(mealId: meal.id)
            await loadWeeklyPlan()
        } catch {
            displayError(error.localizedDescription)
        }
    }

    public func duplicateMealToTomorrow(_ meal: PlannedMeal) async {
        guard let tomorrow = calendarHelper.calendar.date(byAdding: .day, value: 1, to: meal.scheduledDate) else { return }
        let duplicated = meal.duplicate(forDate: calendarHelper.startOfDay(for: tomorrow))
        await saveMeal(duplicated)
    }

    public func copyDay(from sourceDate: Date, to targetDate: Date, mode: CopyDayPlanMode) async {
        do {
            let count = try await copyDayPlanUseCase.execute(from: sourceDate, to: targetDate, mode: mode)
            await loadWeeklyPlan()
            isShowingCopyDaySheet = false
            alertMessage = "Đã sao chép thành công \(count) bữa ăn sang ngày mới."
            showAlert = true
        } catch {
            displayError(error.localizedDescription)
        }
    }

    public func logMealToDiary(
        plannedMeal: PlannedMeal,
        actualFoodItems: [FoodItem]?,
        loggedDate: Date,
        mealType: MealType,
        notes: String?
    ) async {
        do {
            try await logPlannedMealToDiaryUseCase.execute(
                plannedMeal: plannedMeal,
                actualFoodItems: actualFoodItems,
                loggedDate: loggedDate,
                mealType: mealType,
                notes: notes
            )
            await loadWeeklyPlan()
            mealToLogToDiary = nil
            if selectedMealForDetail?.id == plannedMeal.id {
                selectedMealForDetail = nil
            }
            alertMessage = "Đã ghi nhận bữa ăn vào Nhật ký dinh dưỡng thành công!"
            showAlert = true
        } catch {
            displayError(error.localizedDescription)
        }
    }

    private func displayError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}

