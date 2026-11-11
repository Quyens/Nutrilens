//
//  SettingsView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Full-Page Settings screen complying with Apple App Store Review Guidelines.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

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
                            Text("Tùy chọn trải nghiệm, bảo mật & hệ thống")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Spacer()

                    Button {
                        #if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        #endif
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
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
                            )
                            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))
                        }

                        // 2. Preferences Card (Display, Haptics & Notifications)
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Trải nghiệm & Hiển thị")
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
                                        Text("Rung nhẹ khi quét món và thao tác")
                                            .font(.system(size: 11))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                            }
                            .tint(AppColors.primary)

                            Divider()

                            Toggle(isOn: $viewModel.dailyReminderEnabled) {
                                HStack(spacing: 10) {
                                    Image(systemName: "bell.badge.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.primary)
                                        .frame(width: 24)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("Nhắc nhở bữa ăn hàng ngày")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(AppColors.textPrimary)
                                        Text("Thông báo nhắc ghi nhận calo đúng giờ")
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

                        // 3. Security & Privacy Card (Core ML on-device + Permissions)
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
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("Xử lý AI trên thiết bị")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(AppColors.textPrimary)
                                        Text("Core ML On-Device • Không gửi ảnh ra ngoài")
                                            .font(.system(size: 11))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                                Spacer()
                                Text("Bật")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppColors.primary)
                                    .padding(.horizontal, 10)
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
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("Lưu trữ nhật ký bữa ăn")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(AppColors.textPrimary)
                                        Text("Mã hóa an toàn trong SwiftData nội bộ")
                                            .font(.system(size: 11))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                                Spacer()
                                Text("Cục bộ")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            Divider()

                            Button {
                                viewModel.openSystemSettings()
                            } label: {
                                HStack {
                                    HStack(spacing: 10) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(AppColors.primary)
                                            .frame(width: 24)
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text("Quyền Camera & Thư viện ảnh")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(AppColors.textPrimary)
                                            Text("Chỉ sử dụng khi bạn chủ động quét món")
                                                .font(.system(size: 11))
                                                .foregroundColor(AppColors.textSecondary)
                                        }
                                    }
                                    Spacer()
                                    HStack(spacing: 4) {
                                        Text("Cài đặt iOS")
                                            .font(.system(size: 12, weight: .semibold))
                                        Image(systemName: "arrow.up.forward.app")
                                            .font(.system(size: 11))
                                    }
                                    .foregroundColor(AppColors.primaryGreen)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())

                            Divider()

                            Button {
                                viewModel.clearCache()
                            } label: {
                                HStack {
                                    HStack(spacing: 10) {
                                        Image(systemName: "trash.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(AppColors.primary)
                                            .frame(width: 24)
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text("Dọn dẹp bộ nhớ đệm AI")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(AppColors.textPrimary)
                                            Text("Giải phóng dung lượng tạm thời của ảnh quét")
                                                .font(.system(size: 11))
                                                .foregroundColor(AppColors.textSecondary)
                                        }
                                    }
                                    Spacer()
                                    Text("Dọn dẹp")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppColors.primaryGreen)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(AppColors.surfaceSecondary)
                                        .clipShape(Capsule())
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
                        )
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))

                        // 4. Legal & Support Card (App Store Compliance Guideline 5.1 & 2.1)
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Pháp lý & Hỗ trợ")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)

                            Button {
                                viewModel.showingPrivacySheet = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "lock.doc.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.primary)
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("Chính sách quyền riêng tư")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(AppColors.textPrimary)
                                        Text("Bảo vệ dữ liệu cá nhân & sức khỏe chuẩn Apple")
                                            .font(.system(size: 11))
                                            .foregroundColor(AppColors.textSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppColors.textTertiary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())

                            Divider()

                            Button {
                                viewModel.showingTermsSheet = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.plaintext.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.primary)
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("Điều khoản sử dụng (EULA)")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(AppColors.textPrimary)
                                        Text("Quy định dịch vụ & miễn trừ trách nhiệm y khoa")
                                            .font(.system(size: 11))
                                            .foregroundColor(AppColors.textSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppColors.textTertiary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())

                            Divider()

                            Button {
                                viewModel.requestAppReview()
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "F5A623"))
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("Đánh giá NutriLens trên App Store")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(AppColors.textPrimary)
                                        Text("Đóng góp đánh giá 5 sao cho ứng dụng")
                                            .font(.system(size: 11))
                                            .foregroundColor(AppColors.textSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppColors.textTertiary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())

                            Divider()

                            Button {
                                viewModel.showingSupportAlert = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "envelope.badge.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.primary)
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("Hỗ trợ kỹ thuật & Góp ý")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(AppColors.textPrimary)
                                        Text("support@nutrilens.vn • Phản hồi trong 24h")
                                            .font(.system(size: 11))
                                            .foregroundColor(AppColors.textSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppColors.textTertiary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
                        )
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppColors.border, lineWidth: 1))

                        // 5. App Information Card (Clean App Store Ready)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Thông tin ứng dụng")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)

                            HStack {
                                Text("Tên ứng dụng")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text("NutriLens")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                            }

                            Divider()

                            HStack {
                                Text("Phiên bản")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text(viewModel.appVersion)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppColors.primaryGreen)
                            }

                            Divider()

                            HStack {
                                Text("Cơ sở dữ liệu")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text("Viện Dinh Dưỡng Quốc Gia (NIN)")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(AppColors.textPrimary)
                            }

                            Divider()

                            HStack {
                                Text("Bản quyền")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text("© 2026 NutriLens. All rights reserved.")
                                    .font(.system(size: 12))
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
        .fullScreenCover(isPresented: $viewModel.showingPrivacySheet) {
            PrivacyPolicyView {
                viewModel.showingPrivacySheet = false
            }
        }
        .fullScreenCover(isPresented: $viewModel.showingTermsSheet) {
            TermsOfServiceView {
                viewModel.showingTermsSheet = false
            }
        }
        .alert("Đã làm sạch bộ nhớ tạm", isPresented: $viewModel.showingCacheClearedAlert) {
            Button("Đồng ý", role: .cancel) {}
        } message: {
            Text("Bộ nhớ đệm hình ảnh và kết quả nhận diện Core ML tạm thời đã được giải phóng.")
        }
        .alert("Hỗ trợ kỹ thuật NutriLens", isPresented: $viewModel.showingSupportAlert) {
            Button("Sao chép Email", action: {
                #if canImport(UIKit)
                UIPasteboard.general.string = "support@nutrilens.vn"
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
            })
            Button("Đóng", role: .cancel) {}
        } message: {
            Text("Bạn có thể gửi yêu cầu hỗ trợ hoặc phản hồi ý kiến tới email: support@nutrilens.vn\nĐội ngũ phát triển sẽ phản hồi trong vòng 24 giờ.")
        }
    }
}

// MARK: - App Store Compliant Privacy Policy View
private struct PrivacyPolicyView: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // Top Bar
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
                            Text("Chính sách quyền riêng tư")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Tuân thủ Apple Privacy & Bảo vệ dữ liệu cá nhân")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Spacer()

                    Button(action: onDismiss) {
                        Text("Đóng")
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
                .padding(.bottom, 12)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Summary Banner
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 28))
                                .foregroundColor(AppColors.primaryGreen)

                            VStack(alignment: .leading, spacing: 3) {
                                Text("Cam kết quyền riêng tư tuyệt đối")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                Text("Mọi phân tích hình ảnh và dữ liệu calo được xử lý trực tiếp trên chip Neural Engine iPhone của bạn.")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        .padding(14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)

                        // Privacy Sections
                        Group {
                            LegalSectionCard(
                                title: "1. Thu thập dữ liệu tối thiểu",
                                content: "NutriLens hoạt động theo nguyên tắc thu thập dữ liệu tối thiểu (Data Minimization). Ứng dụng không yêu cầu đăng ký bắt buộc, không theo dõi định vị GPS, và không tích hợp bất kỳ SDK quảng cáo của bên thứ ba nào."
                            )

                            LegalSectionCard(
                                title: "2. Quyền Camera và Thư viện ảnh",
                                content: "Quyền truy cập Camera và Ảnh chỉ được sử dụng khi bạn chủ động nhấn chụp hoặc chọn món ăn để phân tích. Hình ảnh chỉ tồn tại trong bộ nhớ đệm tạm thời trên máy để mô hình Core ML phân tích và không bao giờ được gửi lên đám mây."
                            )

                            LegalSectionCard(
                                title: "3. Lưu trữ cục bộ với SwiftData & Keychain",
                                content: "Toàn bộ nhật ký dinh dưỡng, danh sách món ăn đã ăn và mục tiêu calo được lưu trữ trong cơ sở dữ liệu SwiftData cục bộ trên iPhone. Thông tin xác thực (nếu có) được bảo vệ an toàn bằng Apple Keychain với mã hóa phần cứng Secure Enclave."
                            )

                            LegalSectionCard(
                                title: "4. Quyền kiểm soát & Xóa dữ liệu",
                                content: "Bạn có toàn quyền xóa lịch sử món ăn, làm sạch bộ nhớ đệm AI hoặc khôi phục cài đặt gốc trong mục Quản lý tài khoản bất cứ lúc nào."
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

// MARK: - App Store Compliant Terms of Service View
private struct TermsOfServiceView: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 38, height: 38)
                                .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppColors.primary)
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text("Điều khoản dịch vụ")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Quy định sử dụng & Miễn trừ trách nhiệm")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Spacer()

                    Button(action: onDismiss) {
                        Text("Đóng")
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
                .padding(.bottom, 12)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Medical Disclaimer (App Store Guideline for Health/Nutrition Apps)
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "cross.case.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color(hex: "E97970"))
                                .padding(.top, 2)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Khuyến cáo y tế quan trọng")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                Text("NutriLens là ứng dụng hỗ trợ theo dõi thói quen dinh dưỡng cá nhân, không thay thế cho chẩn đoán, điều trị hoặc lời khuyên của bác sĩ, chuyên gia y tế chuyên ngành.")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                                    .lineSpacing(3)
                            }
                        }
                        .padding(14)
                        .background(Color(hex: "FFF4F2"))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(hex: "FAD4CF"), lineWidth: 1))

                        Group {
                            LegalSectionCard(
                                title: "1. Bản quyền & Quyền sở hữu trí tuệ",
                                content: "Ứng dụng NutriLens, logo, giao diện thiết kế Botanical và các tài nguyên đi kèm thuộc quyền sở hữu của nhóm phát triển NutriLens. Mọi dữ liệu dinh dưỡng được biên soạn dựa trên cơ sở Bảng thành phần thực phẩm Việt Nam của Viện Dinh Dưỡng Quốc Gia."
                            )

                            LegalSectionCard(
                                title: "2. Độ chính xác nhận diện AI",
                                content: "Mô hình nhận diện món ăn được huấn luyện trên các món ăn truyền thống Việt Nam. Do sự phong phú trong cách chế biến và nguyên liệu của từng vùng miền, số liệu calo và đa lượng hiển thị mang tính chất ước lượng tham khảo tốt nhất."
                            )

                            LegalSectionCard(
                                title: "3. Trách nhiệm người dùng",
                                content: "Người dùng có trách nhiệm kiểm tra lại khẩu phần gram thực tế và lưu ý các thành phần gây dị ứng cá nhân trước khi tiêu thụ thực phẩm."
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

// MARK: - Reusable Legal Section Card
private struct LegalSectionCard: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            Text(content)
                .font(.system(size: 12.5))
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AppColors.border, lineWidth: 1))
    }
}
