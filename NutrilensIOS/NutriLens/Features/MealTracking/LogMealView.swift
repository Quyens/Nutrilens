//
//  LogMealView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI

public struct LogMealView: View {
    @StateObject private var viewModel: LogMealViewModel
    private let onCancel: () -> Void

    public init(
        viewModel: LogMealViewModel,
        onCancel: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onCancel = onCancel
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Meal Details") {
                    Picker("Meal Type", selection: $viewModel.mealType) {
                        ForEach(MealType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.systemIcon).tag(type)
                        }
                    }

                    TextField("Dish Name (e.g. Bún Bò Huế)", text: $viewModel.foodName)
                }

                Section("Nutritional Estimates") {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", text: $viewModel.caloriesText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("kcal")
                            .foregroundColor(AppColors.textSecondary)
                    }

                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("0", text: $viewModel.proteinText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(AppColors.textSecondary)
                    }

                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("0", text: $viewModel.carbsText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(AppColors.textSecondary)
                    }

                    HStack {
                        Text("Fat")
                        Spacer()
                        TextField("0", text: $viewModel.fatText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Section("Notes") {
                    TextField("Optional notes...", text: $viewModel.notes)
                }

                if let err = viewModel.errorMessage {
                    Section {
                        Text(err)
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.error)
                    }
                }
            }
            .navigationTitle("Log Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveMeal()
                    }
                    .disabled(viewModel.isSaving || viewModel.foodName.isEmpty)
                }
            }
        }
    }
}
