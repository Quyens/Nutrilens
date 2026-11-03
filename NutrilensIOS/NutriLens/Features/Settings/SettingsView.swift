//
//  SettingsView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI

@MainActor
public struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public init() {
        _viewModel = StateObject(wrappedValue: SettingsViewModel())
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Toggle("Use Metric Units (g, kcal)", isOn: $viewModel.useMetricUnits)
                    Toggle("Haptic Feedback", isOn: $viewModel.hapticFeedbackEnabled)
                }

                Section("Privacy & Storage") {
                    HStack {
                        Text("On-Device AI Processing")
                        Spacer()
                        Text("Enabled")
                            .foregroundColor(AppColors.primary)
                    }

                    HStack {
                        Text("Data Storage")
                        Spacer()
                        Text("Local SwiftData Only")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Section("About NutriLens") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    HStack {
                        Text("Architecture")
                        Spacer()
                        Text("Clean + MVVM")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
