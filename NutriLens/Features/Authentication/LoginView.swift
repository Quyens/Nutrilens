//
//  LoginView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical Full-Page Login screen with complete authentication options.
//

import SwiftUI

public struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel

    public init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Full Botanical Wallpaper Background
            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // MARK: - 0. Custom Top Navigation Bar (Safe below Dynamic Island)
                HStack {
                    Button {
                        viewModel.clearFeedback()
                        viewModel.currentStep = .welcome
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                            Text("Quay lại")
                                .font(AppTypography.bodyBold)
                        }
                        .foregroundColor(AppColors.forestGreen)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
                    }
                    .accessibilityLabel("Quay lại màn hình chào mừng")

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 38, height: 38)
                            .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, 54)
                .padding(.bottom, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // MARK: - 1. Greeting & Brand Hero
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 68, height: 68)
                                    .shadow(color: Color.black.opacity(0.06), radius: 8, y: 3)

                                Circle()
                                    .stroke(AppColors.primary.opacity(0.2), lineWidth: 2)
                                    .frame(width: 68, height: 68)

                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 38))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "2EA66B"), Color(hex: "1F7A4D")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }

                            VStack(spacing: 4) {
                                Text("Chào mừng trở lại! 👋")
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)

                                Text("Đăng nhập để tiếp tục theo dõi và phân tích dinh dưỡng bữa ăn món Việt.")
                                    .font(AppTypography.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 10)
                            }
                        }
                        .padding(.top, 4)

                        // MARK: - 2. Feature Banner
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppColors.surfaceSecondary)
                                    .frame(width: 40, height: 40)
                                Image(systemName: "sparkles")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppColors.primary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Dinh dưỡng món Việt chuẩn calo")
                                    .font(AppTypography.captionBold)
                                    .foregroundColor(AppColors.textPrimary)
                                Text("AI On-Device nhận diện hơn 5.000 món ăn truyền thống")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            Spacer()
                        }
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AppColors.border, lineWidth: 1))

                        // MARK: - 3. Development Mock Notice & Quick Autofill
                        if viewModel.isMockMode {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "wrench.and.screwdriver.fill")
                                            .font(.system(size: 11))
                                        Text("Chế độ Thử nghiệm (Mock)")
                                            .font(AppTypography.captionBold)
                                    }
                                    .foregroundColor(AppColors.carbsOrange)

                                    Text("Chạm để điền tài khoản mẫu")
                                        .font(.system(size: 11))
                                        .foregroundColor(AppColors.textSecondary)
                                }

                                Spacer()

                                Button {
                                    viewModel.email = "demo@nutrilens.vn"
                                    viewModel.password = "NutriLens2026!"
                                    viewModel.clearFeedback()
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "bolt.fill")
                                            .font(.system(size: 11))
                                        Text("Điền nhanh")
                                            .font(AppTypography.captionBold)
                                    }
                                    .foregroundColor(AppColors.forestGreen)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(AppColors.surfaceSecondary)
                                    .clipShape(Capsule())
                                }
                            }
                            .padding(12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AppColors.carbsOrange.opacity(0.3), lineWidth: 1))
                        }

                        // MARK: - 4. Error Banner
                        if let err = viewModel.errorMessage {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(AppColors.error)
                                    Text(err)
                                        .font(AppTypography.caption)
                                        .foregroundColor(AppColors.error)
                                }
                                if let suggestion = viewModel.errorRecoverySuggestion {
                                    Text(suggestion)
                                        .font(AppTypography.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                        .padding(.leading, 24)
                                }
                            }
                            .padding(AppSpacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                            .overlay(RoundedRectangle(cornerRadius: AppRadius.md).stroke(AppColors.error.opacity(0.3), lineWidth: 1))
                        }

                        // MARK: - 5. Main Floating Form Card
                        VStack(spacing: 16) {
                            BotanicalTextField(
                                title: "Địa chỉ Email",
                                placeholder: "name@example.com",
                                text: $viewModel.email,
                                icon: "envelope.fill",
                                keyboardType: .emailAddress,
                                autocapitalization: .never
                            )

                            VStack(alignment: .trailing, spacing: 6) {
                                BotanicalTextField(
                                    title: "Mật khẩu",
                                    placeholder: "Nhập mật khẩu của bạn",
                                    text: $viewModel.password,
                                    icon: "lock.fill",
                                    isSecure: true
                                )

                                Button {
                                    viewModel.clearFeedback()
                                    viewModel.currentStep = .forgotPassword
                                } label: {
                                    Text("Quên mật khẩu?")
                                        .font(AppTypography.captionBold)
                                        .foregroundColor(AppColors.forestGreen)
                                }
                                .padding(.top, 4)
                            }

                            // Primary Login Button
                            PrimaryButton("Đăng nhập", icon: "arrow.right", isLoading: viewModel.isLoading) {
                                Task {
                                    await viewModel.login()
                                }
                            }
                            .disabled(!viewModel.isLoginFormValid || viewModel.isLoading)
                            .padding(.top, 2)

                            // Divider
                            HStack(spacing: 12) {
                                Rectangle()
                                    .fill(AppColors.border)
                                    .frame(height: 1)
                                Text("HOẶC TIẾP TỤC VỚI")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppColors.textTertiary)
                                Rectangle()
                                    .fill(AppColors.border)
                                    .frame(height: 1)
                            }
                            .padding(.vertical, 2)

                            // Apple Sign-In Button directly on Login screen
                            Button {
                                Task {
                                    await viewModel.signInWithApple()
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "applelogo")
                                        .font(.system(size: 17, weight: .semibold))
                                    Text("Tiếp tục với Apple")
                                        .font(AppTypography.button)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .shadow(color: Color.black.opacity(0.12), radius: 4, y: 2)
                            }
                            .disabled(viewModel.isLoading)

                            // Guest mode shortcut
                            Button {
                                Task {
                                    await viewModel.continueAsGuest()
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.primary)
                                    Text("Trải nghiệm không cần tài khoản")
                                        .font(AppTypography.captionBold)
                                        .foregroundColor(AppColors.forestGreen)
                                }
                                .padding(.vertical, 4)
                            }
                            .disabled(viewModel.isLoading)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 14, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(AppColors.border, lineWidth: 1)
                        )

                        // MARK: - 6. Switch to Register
                        HStack(spacing: 4) {
                            Text("Chưa có tài khoản?")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)

                            Button {
                                viewModel.clearFeedback()
                                viewModel.currentStep = .register
                            } label: {
                                Text("Đăng ký ngay")
                                    .font(AppTypography.bodyBold)
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                        .padding(.top, 4)

                        // MARK: - 7. Trust & Security Badge
                        HStack(spacing: 6) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.primary)
                            Text("Bảo mật dữ liệu 100% trên thiết bị với Apple Keychain")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.top, 2)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 4)
                }
            }
        }
    }
}
