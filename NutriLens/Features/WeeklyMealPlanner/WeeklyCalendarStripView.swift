//
//  WeeklyCalendarStripView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  7-Day Monday-to-Sunday interactive calendar strip.
//

import SwiftUI

public struct WeeklyCalendarStripView: View {
    @ObservedObject var viewModel: WeeklyMealPlannerViewModel

    public init(viewModel: WeeklyMealPlannerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.daysInCurrentWeek, id: \.self) { date in
                DayPillView(
                    date: date,
                    isSelected: viewModel.calendarHelper.isSameDay(date, viewModel.selectedDate),
                    isToday: viewModel.calendarHelper.isToday(date),
                    hasMeals: viewModel.weeklyPlan.hasMeals(for: date, calendar: viewModel.calendarHelper.calendar),
                    isCompleted: viewModel.weeklyPlan.isDayCompleted(for: date, calendar: viewModel.calendarHelper.calendar),
                    weekdayShort: viewModel.calendarHelper.vietnameseWeekdayShort(for: date),
                    dayNumber: "\(viewModel.calendarHelper.calendar.component(.day, from: date))",
                    onSelect: {
                        #if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        #endif
                        viewModel.selectDate(date)
                    }
                )
            }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.vertical, 8)
    }
}

private struct DayPillView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasMeals: Bool
    let isCompleted: Bool
    let weekdayShort: String
    let dayNumber: String
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 4) {
                // Short weekday (T2, T3...)
                Text(weekdayShort)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .white.opacity(0.9) : (isToday ? AppColors.primaryGreen : AppColors.textSecondary))

                // Day number (10, 11...)
                Text(dayNumber)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .white : AppColors.textPrimary)

                // Indicator dot or status
                ZStack {
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(isSelected ? .white : AppColors.primaryGreen)
                    } else if hasMeals {
                        Circle()
                            .fill(isSelected ? Color.white : AppColors.primaryGreen)
                            .frame(width: 5, height: 5)
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 5, height: 5)
                    }
                }
                .frame(height: 10)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [AppColors.primaryGreen, AppColors.forestGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.white.opacity(0.85)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isSelected ? Color.clear : (isToday ? AppColors.primaryGreen.opacity(0.6) : Color(red: 0.90, green: 0.93, blue: 0.91)),
                        lineWidth: isToday ? 1.5 : 1
                    )
            )
            .shadow(
                color: isSelected ? AppColors.primaryGreen.opacity(0.28) : Color.black.opacity(0.03),
                radius: isSelected ? 6 : 2,
                x: 0,
                y: isSelected ? 3 : 1
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("calendar_day_\(dayNumber)")
        .accessibilityLabel("\(weekdayShort) ngày \(dayNumber)")
    }
}

