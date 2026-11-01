//
//  MealHistoryView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI

public struct MealHistoryView: View {
    @StateObject private var viewModel: MealHistoryViewModel

    public init(viewModel: MealHistoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.xs) {
                        FilterChip(
                            title: "All",
                            isSelected: viewModel.selectedFilter == nil,
                            action: { viewModel.selectedFilter = nil }
                        )

                        ForEach(MealType.allCases, id: \.self) { type in
                            FilterChip(
                                title: type.rawValue,
                                isSelected: viewModel.selectedFilter == type,
                                action: { viewModel.selectedFilter = type }
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xs)
                }

                // Content list
                Group {
                    switch viewModel.state {
                    case .idle, .loading:
                        LoadingView("Loading meal history...")
                    case .failure(let error):
                        ErrorStateView(
                            title: "Failed to Load History",
                            message: error.localizedDescription
                        ) {
                            Task { await viewModel.loadHistory() }
                        }
                    case .success:
                        if viewModel.filteredMeals.isEmpty {
                            EmptyStateView(
                                icon: "calendar.badge.clock",
                                title: "No Meals Recorded",
                                message: "Logged meals will appear here chronologically."
                            )
                        } else {
                            List {
                                ForEach(viewModel.filteredMeals) { meal in
                                    MealHistoryItemRow(meal: meal)
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        let meal = viewModel.filteredMeals[index]
                                        Task { await viewModel.deleteMeal(id: meal.id) }
                                    }
                                }
                            }
                            .listStyle(.insetGrouped)
                        }
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Meal History")
            .task {
                await viewModel.loadHistory()
            }
            .refreshable {
                await viewModel.loadHistory()
            }
        }
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.captionBold)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
                .background(isSelected ? AppColors.primary : AppColors.surface)
                .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(isSelected ? Color.clear : AppColors.border.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct MealHistoryItemRow: View {
    let meal: MealRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Label(meal.mealType.rawValue, systemImage: meal.mealType.systemIcon)
                    .font(AppTypography.captionBold)
                    .foregroundColor(AppColors.primary)

                Spacer()

                Text(meal.timestamp, format: .dateTime.month().day().hour().minute())
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textTertiary)
            }

            Text(meal.items.map(\.vietnameseName).joined(separator: ", "))
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            HStack {
                Text("\(Int(meal.totalCalories)) kcal")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.primaryDark)

                Text("• P: \(Int(meal.totalProteinGrams))g • C: \(Int(meal.totalCarbGrams))g • F: \(Int(meal.totalFatGrams))g")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.vertical, 4)
    }
}
