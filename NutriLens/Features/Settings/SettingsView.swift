//
//  SettingsView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Full-Page Settings screen.
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
        ZStack(alignment: .top) {
            // Full Botanical Wallpaper Background
            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // Top Navigation Bar (Safe below Dynamic Island)
                HStack {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 38, height: 38)
                                .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.primary)
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text("Cài đặt ứng dụng")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Tùy chọn hiển thị, bảo mật & hệ thống")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Text("Xong")
                            .font(AppTypography.bodyBold)
                            .foregroundColor(AppColors.forestGreen)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, 54)
                .padding(.bottom, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 1. Account Section Card
                        if let openAccount = onOpenAccount {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Tài khoản & Xác thực")
                                    .font(AppTypography.headline)
                                    .foregroundColor(AppColors.textPrimary)

                                Button {
                                    dismiss()
                                    openAccount()
                                } label: {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(AppColors.surfaceSecondary)
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "person.badge.shield.checkmark.fill")
                                                .font(.system(size: 18))
                                                .foregroundColor(AppColors.primary)
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Quản lý tài khoản & Bảo mật")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(AppColors.textPrimary)
                                            Text("Phiên đăng nhập, Apple Keychain, hồ sơ")
                                                .font(.system(size: 11))
                                                .foregroundColor(AppColors.textSecondary)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(AppColors.textTertiary)
                                    }
                                    .padding(12)
                                    .background(AppColors.surfaceSecondary.opacity(0.4))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
                            )
                            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))
                        }

                        // 2. Preferences Card
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Tùy chọn hiển thị & Cảm ứng")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)

                            Toggle(isOn: $viewModel.useMetricUnits) {
                                HStack(spacing: 10) {
                                    Image(systemName: "scalemass.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.primary)
                                        .frame(width: 24)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("Sử dụng hệ mét")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(AppColors.textPrimary)
                                        Text("g, ml, kcal chuẩn quốc tế")
                                            .font(.system(size: 11))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                            }
                            .tint(AppColors.primary)

                            Divider()

                            Toggle(isOn: $viewModel.hapticFeedbackEnabled) {
                                HStack(spacing: 10) {
                                    Image(systemName: "hand.tap.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.primary)
                                        .frame(width: 24)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("Phản hồi xúc giác (Haptics)")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(AppColors.textPrimary)
                                        Text("Rung nhẹ khi quét và chọn món")
                                            .font(.system(size: 11))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                            }
                            .tint(AppColors.primary)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
                        )
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))

                        // 3. Security & Storage Card
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Bảo mật & Quyền riêng tư")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)

                            HStack {
                                HStack(spacing: 10) {
                                    Image(systemName: "cpu.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.primary)
                                        .frame(width: 24)
                                    Text("Xử lý AI trên thiết bị")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppColors.textPrimary)
                                }
                                Spacer()
                                Text("Bật (On-Device)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppColors.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AppColors.surfaceSecondary)
                                    .clipShape(Capsule())
                            }

                            Divider()

                            HStack {
                                HStack(spacing: 10) {
                                    Image(systemName: "internaldrive.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.primary)
                                        .frame(width: 24)
                                    Text("Lưu trữ dữ liệu")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppColors.textPrimary)
                                }
                                Spacer()
                                Text("Cục bộ (SwiftData)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            Divider()

                            HStack {
                                HStack(spacing: 10) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.primary)
                                        .frame(width: 24)
                                    Text("Quyền Camera & Ảnh")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppColors.textPrimary)
                                }
                                Spacer()
                                Text("Chỉ khi quét món")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
                        )
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))

                        // 4. App Information Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Thông tin ứng dụng")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)

                            HStack {
                                Text("Phiên bản")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text(viewModel.appVersion)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                            }

                            Divider()

                            HStack {
                                Text("Kiến trúc hệ thống")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text("Clean + MVVM + SwiftData")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppColors.primary)
                            }

                            Divider()

                            HStack {
                                Text("Bản quyền")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text("© 2026 NutriLens")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
                        )
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 4)
                }
            }
        }
    }
}
