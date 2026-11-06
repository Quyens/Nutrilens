//
//  AccountManagementView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Account management screen providing session inspection, guest upgrade, logout, and deletion confirmations.
//

import SwiftUI

public struct AccountManagementView: View {
    @ObservedObject var viewModel: AuthViewModel
    let onDismiss: () -> Void

    public init(viewModel: AuthViewModel, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // MARK: - User Info Card
                        userHeaderCard

                        // MARK: - Account Status / Upgrade Section
                        if viewModel.isGuest {
                            guestUpgradeCard
                        } else {
                            authenticatedDetailsCard
                        }

                        // MARK: - Security & Session Actions Card
                        sessionActionsCard

                        // MARK: - Danger Zone Card (Delete Account)
                        dangerZoneCard
                    }
                    .padding(AppSpacing.screenHorizontal)
                }
            }
            .navigationTitle("Tài khoản")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong", action: onDismiss)
                        .foregroundColor(AppColors.primaryDark)
                }
            }
            .confirmationDialog(
                "Đăng xuất khỏi NutriLens?",
                isPresented: $viewModel.showingLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Đăng xuất", role: .destructive) {
                    Task {
                        await viewModel.logout()
                        onDismiss()
                    }
                }
                Button("Hủy", role: .cancel) {}
            } message: {
                Text("Dữ liệu nhật ký bữa ăn và lịch sử dinh dưỡng đã lưu trên máy sẽ vẫn được bảo lưu an toàn.")
            }
            .confirmationDialog(
                "Xác nhận xóa tài khoản?",
                isPresented: $viewModel.showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Xác nhận xóa", role: .destructive) {
                    Task {
                        await viewModel.deleteAccount()
                        onDismiss()
                    }
                }
                Button("Hủy", role: .cancel) {}
            } message: {
                Text("Hành động này sẽ xóa phiên đăng nhập hiện tại. Dữ liệu trên thiết bị sẽ không bị ảnh hưởng.")
            }
        }
    }

    // MARK: - Subviews

    private var userHeaderCard: some View {
        CardView {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(AppColors.primarySubtle)
                        .frame(width: 64, height: 64)

                    Image(systemName: viewModel.isGuest ? "person.crop.circle.badge.questionmark" : "person.crop.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(AppColors.primary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.currentUser?.displayName ?? "Khách NutriLens")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text(viewModel.currentUser?.email ?? "guest@nutrilens.local")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)

                    // Badge
                    HStack(spacing: 4) {
                        Circle()
                            .fill(viewModel.isGuest ? AppColors.carbsOrange : AppColors.primary)
                            .frame(width: 6, height: 6)

                        Text(viewModel.isGuest ? "Chế độ Khách" : (viewModel.currentUser?.isMockAccount == true ? "Thử nghiệm (Mock)" : "Đã xác thực"))
                            .font(AppTypography.captionBold)
                            .foregroundColor(viewModel.isGuest ? AppColors.carbsOrange : AppColors.primaryDark)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(viewModel.isGuest ? AppColors.carbsOrange.opacity(0.12) : AppColors.primarySubtle)
                    .clipShape(Capsule())
                }

                Spacer()
            }
        }
    }

    private var guestUpgradeCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(AppColors.primary)
                    Text("Đăng ký tài khoản đầy đủ")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                }

                Text("Bạn đang sử dụng ứng dụng với tư cách Khách. Dữ liệu bữa ăn được lưu 100% trên thiết bị này. Đăng nhập hoặc tạo tài khoản để sẵn sàng cho tính năng đồng bộ đám mây trong tương lai.")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)

                Button {
                    viewModel.currentStep = .welcome
                } label: {
                    Text("Đăng nhập / Đăng ký ngay")
                        .font(AppTypography.button)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(AppColors.primary)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.button))
                }
                .padding(.top, 4)
            }
        }
    }

    private var authenticatedDetailsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Thông tin tài khoản")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)

                HStack {
                    Text("Trạng thái email")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Text(viewModel.currentUser?.isEmailVerified == true ? "Đã xác thực" : "Chưa xác thực")
                        .font(AppTypography.captionBold)
                        .foregroundColor(viewModel.currentUser?.isEmailVerified == true ? AppColors.primaryDark : AppColors.carbsOrange)
                }

                Divider()

                HStack {
                    Text("Ngày tham gia")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Text(formattedDate(viewModel.currentUser?.createdAt ?? Date()))
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
    }

    private var sessionActionsCard: some View {
        CardView {
            VStack(spacing: 0) {
                Button {
                    viewModel.showingLogoutConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(AppColors.carbsOrange)
                            .frame(width: 24)
                        Text("Đăng xuất")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textTertiary)
                    }
                    .padding(.vertical, AppSpacing.sm)
                }
            }
        }
    }

    private var dangerZoneCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Vùng nguy hiểm")
                    .font(AppTypography.captionBold)
                    .foregroundColor(AppColors.error)

                Button {
                    viewModel.showingDeleteConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(AppColors.error)
                            .frame(width: 24)
                        Text("Xóa tài khoản")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.error)
                        Spacer()
                    }
                    .padding(.vertical, AppSpacing.xs)
                }
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: date)
    }
}
