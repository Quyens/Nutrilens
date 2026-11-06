//
//  AccountManagementView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Account & Security screen with full wallpaper integration.
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
                // MARK: - Full Botanical Wallpaper (Matching HomeView)
                Image("botanical_wallpaper")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

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
            }
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
                    .stroke(AppColors.primary.opacity(0.25), lineWidth: 2)
                    .frame(width: 66, height: 66)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.surfaceSecondary, AppColors.softGreen.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 58, height: 58)

                Image(systemName: viewModel.isGuest ? "person.crop.circle.badge.questionmark" : "person.crop.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(AppColors.forestGreen)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.isGuest ? "Tài khoản Khách" : (viewModel.currentUser?.displayName ?? "Người dùng NutriLens"))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                if viewModel.isGuest {
                    Text("Thiết bị lưu trữ cục bộ SwiftData")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                } else if let email = viewModel.currentUser?.email {
                    Text(email)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                // Account Type Tag
                HStack(spacing: 5) {
                    Circle()
                        .fill(viewModel.isGuest ? AppColors.forestGreen : AppColors.primary)
                        .frame(width: 6, height: 6)

                    Text(viewModel.isGuest ? "Chế độ Khách" : (viewModel.currentUser?.isMockAccount == true ? "Thử nghiệm (Mock)" : "Đã xác thực"))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(viewModel.isGuest ? AppColors.forestGreen : AppColors.primaryDark)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(AppColors.surfaceSecondary)
                .clipShape(Capsule())
                .padding(.top, 2)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }

    private var guestInformationBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.surfaceSecondary)
                    .frame(width: 32, height: 32)
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppColors.primary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Bảo mật dữ liệu trên máy")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Text("Toàn bộ nhật ký bữa ăn và mục tiêu calo được lưu trữ an toàn trong SwiftData nội bộ của iPhone. Không đồng bộ hay gửi dữ liệu ra bên ngoài.")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                    .lineSpacing(2)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppColors.primary.opacity(0.18), lineWidth: 1)
        )
    }

    private var accountOptionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tùy chọn tài khoản")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                if viewModel.isGuest {
                    Button {
                        viewModel.currentStep = .welcome
                    } label: {
                        OptionRow(
                            icon: "arrow.up.circle.fill",
                            title: "Đăng nhập hoặc tạo tài khoản",
                            subtitle: "Sẵn sàng liên kết khi có dịch vụ đám mây",
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
                    subtitle: "Bộ nhớ SwiftData độc lập, tốc độ cao",
                    iconColor: AppColors.forestGreen
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
    }

    private var sessionActionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Phiên đăng nhập")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
                .padding(.leading, 4)

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
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AppColors.border, lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var destructiveSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Vùng nguy hiểm")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
                .padding(.leading, 4)

            Button {
                viewModel.showingDeleteConfirmation = true
            } label: {
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(AppColors.error.opacity(0.10))
                            .frame(width: 36, height: 36)

                        Image(systemName: "trash.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.error)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.isGuest ? "Xóa dữ liệu thiết bị" : "Xóa tài khoản")
                            .font(AppTypography.bodyBold)
                            .foregroundColor(AppColors.error)

                        Text(viewModel.isGuest ? "Dọn sạch nhật ký cục bộ về mặc định" : "Gỡ bỏ thông tin tài khoản trên máy")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
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
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
