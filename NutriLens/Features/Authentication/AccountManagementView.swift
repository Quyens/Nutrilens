//
//  AccountManagementView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Account & Security screen.
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
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    // MARK: - 1. Account Identity Card
                    accountIdentityCard
                        .padding(.top, AppSpacing.sm)

                    // MARK: - 2. Guest Information Banner
                    if viewModel.isGuest || viewModel.currentUser == nil || viewModel.currentUser?.isMockAccount == true {
                        guestInformationBanner
                    }

                    // MARK: - 3. Account Options Section
                    accountOptionsSection

                    // MARK: - 4. Session Action (Logout - Only for real sessions)
                    if !viewModel.isGuest && viewModel.currentUser != nil {
                        sessionActionSection
                    }

                    // MARK: - 5. Destructive Danger Zone
                    destructiveSection
                }
                .padding(AppSpacing.screenHorizontal)
                .padding(.bottom, AppSpacing.xl)
            }
            .background(
                ZStack {
                    AppColors.canvasBackground.ignoresSafeArea()

                    Image("botanical_wallpaper")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.08)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            )
            .navigationTitle("Tài khoản & Bảo mật")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong", action: onDismiss)
                        .font(AppTypography.bodyBold)
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
                viewModel.isGuest ? "Xác nhận xóa dữ liệu thiết bị?" : "Xác nhận xóa tài khoản?",
                isPresented: $viewModel.showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(viewModel.isGuest ? "Xóa dữ liệu thiết bị" : "Xóa vĩnh viễn tài khoản", role: .destructive) {
                    Task {
                        await viewModel.deleteAccount()
                        onDismiss()
                    }
                }
                Button("Hủy", role: .cancel) {}
            } message: {
                Text(viewModel.isGuest
                     ? "Toàn bộ thông tin nhật ký bữa ăn trên máy này sẽ được dọn sạch. Bạn sẽ quay về trạng thái ban đầu."
                     : "Hành động này sẽ xóa phiên đăng nhập hiện tại và gỡ bỏ thông tin tài khoản trên thiết bị.")
            }
            .task {
                await viewModel.loadSession()
            }
        }
    }

    // MARK: - Subviews

    private var accountIdentityCard: some View {
        HStack(spacing: AppSpacing.md) {
            // Stylized Identity Emblem
            ZStack {
                Circle()
                    .fill(AppColors.surfaceSecondary)
                    .frame(width: 60, height: 60)

                Image(systemName: viewModel.isGuest ? "person.badge.shield.checkmark.fill" : "person.crop.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.isGuest ? "Tài khoản khách" : (viewModel.currentUser?.displayName ?? "Người dùng NutriLens"))
                    .font(AppTypography.headlineBold)
                    .foregroundColor(AppColors.textPrimary)

                if viewModel.isGuest {
                    Text("Bạn đang sử dụng NutriLens dưới chế độ khách.")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                } else if let email = viewModel.currentUser?.email {
                    Text(email)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                // Account Type Tag
                HStack(spacing: 4) {
                    Circle()
                        .fill(viewModel.isGuest ? AppColors.forestGreen : AppColors.primary)
                        .frame(width: 6, height: 6)

                    Text(viewModel.isGuest ? "Chế độ Khách" : (viewModel.currentUser?.isMockAccount == true ? "Thử nghiệm (Mock)" : "Đã kích hoạt"))
                        .font(AppTypography.captionBold)
                        .foregroundColor(viewModel.isGuest ? AppColors.forestGreen : AppColors.primaryDark)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(AppColors.surfaceSecondary)
                .clipShape(Capsule())
                .padding(.top, 2)
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColors.surfacePrimary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
    }

    private var guestInformationBanner: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(AppColors.primary)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 3) {
                Text("Lưu trữ dữ liệu cục bộ")
                    .font(AppTypography.captionBold)
                    .foregroundColor(AppColors.textPrimary)

                Text("Tài khoản trực tuyến sẽ được bổ sung trong giai đoạn sau. Mọi dữ liệu nhật ký dinh dưỡng hiện tại được lưu an toàn 100% trên thiết bị của bạn.")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .lineSpacing(2)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surfaceSecondary.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
        )
    }

    private var accountOptionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Tùy chọn tài khoản")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            VStack(spacing: 0) {
                if viewModel.isGuest {
                    Button {
                        viewModel.currentStep = .welcome
                    } label: {
                        OptionRow(
                            icon: "arrow.up.circle.fill",
                            title: "Đăng nhập hoặc tạo tài khoản",
                            subtitle: "Sẵn sàng liên kết khi có kết nối máy chủ",
                            iconColor: AppColors.primary
                        )
                    }

                    Divider()
                        .padding(.leading, 56)
                        .background(AppColors.divider)
                }

                OptionRow(
                    icon: "externaldrive.fill",
                    title: "Dữ liệu trên thiết bị",
                    subtitle: "Quản lý qua bộ nhớ SwiftData nội bộ",
                    iconColor: AppColors.forestGreen
                )
            }
            .background(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .fill(AppColors.surfacePrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
    }

    private var sessionActionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Phiên đăng nhập")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            Button {
                viewModel.showingLogoutConfirmation = true
            } label: {
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(AppColors.carbsOrange.opacity(0.12))
                            .frame(width: 36, height: 36)

                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.carbsOrange)
                    }

                    Text("Đăng xuất")
                        .font(AppTypography.bodyBold)
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textTertiary)
                }
                .padding(AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .fill(AppColors.surfacePrimary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .stroke(AppColors.border, lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var destructiveSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Vùng thao tác an toàn")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            Button {
                viewModel.showingDeleteConfirmation = true
            } label: {
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(AppColors.error.opacity(0.12))
                            .frame(width: 36, height: 36)

                        Image(systemName: "trash.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.error)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.isGuest ? "Xóa dữ liệu trên thiết bị" : "Xóa tài khoản")
                            .font(AppTypography.bodyBold)
                            .foregroundColor(AppColors.error)

                        Text(viewModel.isGuest ? "Đặt lại dữ liệu cục bộ về mặc định" : "Gỡ bỏ phiên đăng nhập và dữ liệu liên kết")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Spacer()
                }
                .padding(AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .fill(AppColors.surfacePrimary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .stroke(AppColors.error.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

private struct OptionRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let iconColor: Color

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppColors.surfaceSecondary)
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.bodyBold)
                    .foregroundColor(AppColors.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColors.textTertiary)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
