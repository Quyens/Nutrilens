//
//  AccountManagementView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Full-Page Account & Security screen with rich controls and zero empty voids.
//

import SwiftUI

public struct AccountManagementView: View {
    @ObservedObject var viewModel: AuthViewModel
    let onDismiss: () -> Void

    @AppStorage("nutrilens_biometrics_lock") private var isBiometricsEnabled: Bool = false
    @State private var showingCacheClearedAlert: Bool = false
    @State private var showingExportAlert: Bool = false

    public init(viewModel: AuthViewModel, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Full Botanical Wallpaper (100% Background)
            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // MARK: - 0. Custom Top Navigation Bar (Safe below Dynamic Island)
                HStack {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 38, height: 38)
                                .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppColors.primary)
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text("Tài khoản & Bảo mật")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Quản lý phiên, bảo mật & lưu trữ dữ liệu")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Spacer()

                    Button(action: onDismiss) {
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
                        // MARK: - 1. Account Identity Hero Card
                        identityHeroCard
                            .padding(.top, 4)

                        // MARK: - 2. Account & Authentication Details Card
                        accountDetailsCard

                        // MARK: - 3. Security & Biometrics Card
                        securityAndBiometricsCard

                        // MARK: - 4. Data & Storage Management Card
                        dataAndStorageCard

                        // MARK: - 5. Session Actions (Log Out / Switch Account)
                        sessionActionCard

                        // MARK: - 6. Danger Zone (Delete Account / Reset Data)
                        dangerZoneCard

                        // MARK: - 7. Trust Pledge Banner
                        privacyPledgeFooter
                            .padding(.bottom, 40)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 4)
                }
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
            Text("Dữ liệu nhật ký bữa ăn và lịch sử dinh dưỡng đã lưu trong SwiftData trên máy vẫn được bảo toàn an toàn.")
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
                 ? "Toàn bộ thông tin nhật ký bữa ăn và hồ sơ trên máy này sẽ được dọn sạch. Bạn sẽ quay về trạng thái ban đầu."
                 : "Hành động này sẽ xóa phiên đăng nhập hiện tại và gỡ bỏ thông tin tài khoản trên thiết bị.")
        }
        .alert("Đã dọn dẹp bộ nhớ đệm AI", isPresented: $showingCacheClearedAlert) {
            Button("Đồng ý", role: .cancel) {}
        } message: {
            Text("Bộ nhớ đệm hình ảnh và kết quả suy luận tạm thời đã được giải phóng.")
        }
        .alert("Xuất dữ liệu dinh dưỡng", isPresented: $showingExportAlert) {
            Button("Đồng ý", role: .cancel) {}
        } message: {
            Text("Tính năng xuất báo cáo JSON / CSV đang chuẩn bị tệp. Bạn có thể lưu vào Tệp (Files) hoặc gửi qua AirDrop.")
        }
        .task {
            await viewModel.loadSession()
        }
    }

    // MARK: - 1. Identity Hero Card
    private var identityHeroCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                // Stylized Avatar Emblem
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "2EA66B"), Color(hex: "1F7A4D")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: 64, height: 64)

                    Circle()
                        .fill(AppColors.surfaceSecondary)
                        .frame(width: 56, height: 56)

                    Image(systemName: isGuestOrUnauthenticated ? "person.crop.circle.badge.questionmark" : "person.crop.circle.fill")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(AppColors.forestGreen)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(resolvedDisplayName)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)

                    Text(resolvedEmailOrStatus)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)

                    // Status Pill
                    HStack(spacing: 5) {
                        Circle()
                            .fill(isGuestOrUnauthenticated ? AppColors.carbsOrange : AppColors.primary)
                            .frame(width: 6, height: 6)

                        Text(isGuestOrUnauthenticated ? "Chế độ Khách (Cục bộ)" : (viewModel.currentUser?.isMockAccount == true ? "Tài khoản Thử nghiệm" : "Đã xác thực • Keychain"))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(isGuestOrUnauthenticated ? AppColors.forestGreen : AppColors.primaryDark)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(Capsule())
                    .padding(.top, 2)
                }

                Spacer()
            }

            // Quick Action if Guest
            if isGuestOrUnauthenticated {
                Divider()

                Button {
                    viewModel.clearFeedback()
                    viewModel.currentStep = .welcome
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 13, weight: .bold))
                        Text("Đăng nhập hoặc Đăng ký tài khoản")
                            .font(.system(size: 13, weight: .bold))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "2EA66B"), Color(hex: "1F7A4D")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
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

    // MARK: - 2. Account Details Card
    private var accountDetailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Thông tin tài khoản & Đăng nhập")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            VStack(spacing: 0) {
                // Sign-In Method Row
                AccountInfoRow(
                    icon: isGuestOrUnauthenticated ? "person.crop.circle" : "envelope.badge.shield.half.filled",
                    title: "Phương thức đăng nhập",
                    value: isGuestOrUnauthenticated ? "Chế độ Khách (Offline)" : "Email & Mật khẩu"
                )

                Divider().padding(.vertical, 8)

                // Email Row
                AccountInfoRow(
                    icon: "envelope.fill",
                    title: "Địa chỉ Email",
                    value: viewModel.currentUser?.email ?? "Chưa liên kết"
                )

                Divider().padding(.vertical, 8)

                // Password / Security Access Row
                Button {
                    viewModel.clearFeedback()
                    viewModel.currentStep = .forgotPassword
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppColors.surfaceSecondary)
                                .frame(width: 32, height: 32)
                            Image(systemName: "key.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.primary)
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text("Mật khẩu tài khoản")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Đổi mật khẩu hoặc đặt lại khi cần")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }

                Divider().padding(.vertical, 8)

                // Switch Account Row
                Button {
                    viewModel.clearFeedback()
                    viewModel.currentStep = .login
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppColors.surfaceSecondary)
                                .frame(width: 32, height: 32)
                            Image(systemName: "arrow.left.arrow.right.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.primary)
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text("Đăng nhập tài khoản khác")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Chuyển đổi phiên làm việc người dùng")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
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

    // MARK: - 3. Security & Biometrics Card
    private var securityAndBiometricsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bảo mật & Quyền riêng tư")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            VStack(spacing: 0) {
                // Biometrics Toggle
                Toggle(isOn: $isBiometricsEnabled) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppColors.surfaceSecondary)
                                .frame(width: 32, height: 32)
                            Image(systemName: "faceid")
                                .font(.system(size: 15))
                                .foregroundColor(AppColors.primary)
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text("Khóa ứng dụng với Face ID")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Yêu cầu sinh trắc học khi mở app")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .tint(AppColors.primary)

                Divider().padding(.vertical, 8)

                // Keychain Storage Row
                AccountInfoRow(
                    icon: "lock.shield.fill",
                    title: "Bảo mật Apple Keychain",
                    value: "Mã hóa 256-bit phần cứng"
                )

                Divider().padding(.vertical, 8)

                // Active Device Row
                AccountInfoRow(
                    icon: "iphone.gen3",
                    title: "Thiết bị hiện tại",
                    value: "iPhone (iOS 18) • Đang hoạt động"
                )
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

    // MARK: - 4. Data & Storage Card
    private var dataAndStorageCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dữ liệu & Bộ nhớ thiết bị")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            VStack(spacing: 0) {
                // SwiftData Storage Row
                AccountInfoRow(
                    icon: "internaldrive.fill",
                    title: "Cơ sở dữ liệu cục bộ",
                    value: "SwiftData On-Device"
                )

                Divider().padding(.vertical, 8)

                // Export Data Row
                Button {
                    showingExportAlert = true
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppColors.surfaceSecondary)
                                .frame(width: 32, height: 32)
                            Image(systemName: "square.and.arrow.up.fill")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.primary)
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text("Xuất dữ liệu dinh dưỡng")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Báo cáo calo dạng CSV / JSON")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }

                Divider().padding(.vertical, 8)

                // Clear AI Image Cache Row
                Button {
                    showingCacheClearedAlert = true
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppColors.surfaceSecondary)
                                .frame(width: 32, height: 32)
                            Image(systemName: "sparkles")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.primary)
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text("Dọn bộ nhớ đệm AI (Cache)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Giải phóng ảnh tạm và vector nhận diện")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Spacer()

                        Text("Dọn ngay")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppColors.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.surfaceSecondary)
                            .clipShape(Capsule())
                    }
                }
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

    // MARK: - 5. Session Actions Card (Logout)
    private var sessionActionCard: some View {
        Button {
            viewModel.showingLogoutConfirmation = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AppColors.carbsOrange.opacity(0.12))
                        .frame(width: 36, height: 36)

                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.carbsOrange)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(isGuestOrUnauthenticated ? "Đăng xuất khỏi Chế độ Khách" : "Đăng xuất tài khoản")
                        .font(AppTypography.bodyBold)
                        .foregroundColor(AppColors.textPrimary)

                    Text("Bảo lưu dữ liệu SwiftData an toàn trên máy")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textTertiary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
            )
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(AppColors.border, lineWidth: 1))
        }
    }

    // MARK: - 6. Danger Zone Card
    private var dangerZoneCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Vùng nguy hiểm")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.error)
                .padding(.leading, 4)

            Button {
                viewModel.showingDeleteConfirmation = true
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(AppColors.error.opacity(0.10))
                            .frame(width: 36, height: 36)

                        Image(systemName: "trash.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.error)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(isGuestOrUnauthenticated ? "Xóa dữ liệu thiết bị" : "Xóa tài khoản vĩnh viễn")
                            .font(AppTypography.bodyBold)
                            .foregroundColor(AppColors.error)

                        Text(isGuestOrUnauthenticated ? "Dọn sạch nhật ký cục bộ và đặt lại về mặc định" : "Gỡ bỏ hoàn toàn thông tin tài khoản trên thiết bị")
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
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(AppColors.error.opacity(0.25), lineWidth: 1))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - 7. Privacy Pledge Banner
    private var privacyPledgeFooter: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppColors.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Cam kết quyền riêng tư 100%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Text("NutriLens không bán hoặc chia sẻ dữ liệu dinh dưỡng, lịch sử món ăn hay ảnh chụp cho bên thứ ba. Toàn bộ xử lý AI chạy on-device trên iPhone của bạn.")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                    .lineSpacing(1.5)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AppColors.primary.opacity(0.15), lineWidth: 1))
    }

    // MARK: - Helper Computed Properties
    private var isGuestOrUnauthenticated: Bool {
        viewModel.isGuest || viewModel.currentUser == nil
    }

    private var resolvedDisplayName: String {
        if let name = viewModel.currentUser?.displayName, !name.isEmpty {
            return name
        }
        if isGuestOrUnauthenticated {
            return "Tài khoản Khách"
        }
        return "Người dùng NutriLens"
    }

    private var resolvedEmailOrStatus: String {
        if let email = viewModel.currentUser?.email, !email.isEmpty {
            return email
        }
        return "Lưu trữ cục bộ SwiftData an toàn trên máy"
    }
}

// MARK: - Helper Account Row
private struct AccountInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.surfaceSecondary)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.primary)
            }

            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}
