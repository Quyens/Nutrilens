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
    private let onOpenAccount: (() -> Void)?

    public init(viewModel: SettingsViewModel, onOpenAccount: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onOpenAccount = onOpenAccount
    }

    public init(onOpenAccount: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel())
        self.onOpenAccount = onOpenAccount
    }

    public var body: some View {
        NavigationStack {
            Form {
                if let openAccount = onOpenAccount {
                    Section("Tài khoản") {
                        Button {
                            dismiss()
                            openAccount()
                        } label: {
                            HStack {
                                Label("Quản lý tài khoản & Xác thực", systemImage: "person.badge.shield.checkmark.fill")
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                    }
                }

                Section("Tùy chọn") {
                    Toggle("Sử dụng hệ mét (g, kcal)", isOn: $viewModel.useMetricUnits)
                    Toggle("Phản hồi rung (Haptics)", isOn: $viewModel.hapticFeedbackEnabled)
                }

                Section("Bảo mật & Lưu trữ") {
                    HStack {
                        Text("Xử lý AI trên thiết bị")
                        Spacer()
                        Text("Bật (On-Device)")
                            .foregroundColor(AppColors.primary)
                    }

                    HStack {
                        Text("Lưu trữ dữ liệu")
                        Spacer()
                        Text("Cục bộ (SwiftData)")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Section("Về NutriLens") {
                    HStack {
                        Text("Phiên bản")
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    HStack {
                        Text("Kiến trúc")
                        Spacer()
                        Text("Clean + MVVM")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .navigationTitle("Cài đặt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryDark)
                }
            }
        }
    }
}
