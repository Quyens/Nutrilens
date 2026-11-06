//
//  ProfileMenuCard.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Unified menu card for Profile Dashboard conforming to Fresh Premium Botanical design.
//

import SwiftUI

public struct ProfileMenuCard: View {
    private let onOpenPersonalInfo: () -> Void
    private let onOpenPreferences: () -> Void
    private let onOpenAccount: () -> Void
    private let onOpenSettings: () -> Void
    private let onOpenAbout: () -> Void

    public init(
        onOpenPersonalInfo: @escaping () -> Void,
        onOpenPreferences: @escaping () -> Void,
        onOpenAccount: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void,
        onOpenAbout: @escaping () -> Void
    ) {
        self.onOpenPersonalInfo = onOpenPersonalInfo
        self.onOpenPreferences = onOpenPreferences
        self.onOpenAccount = onOpenAccount
        self.onOpenSettings = onOpenSettings
        self.onOpenAbout = onOpenAbout
    }

    public var body: some View {
        VStack(spacing: 0) {
            ProfileMenuRow(
                icon: "person.text.rectangle.fill",
                title: "Thông tin cá nhân",
                subtitle: "Chiều cao, cân nặng, chỉ số cơ thể",
                action: onOpenPersonalInfo
            )

            Divider()
                .padding(.leading, 56)
                .background(AppColors.divider)

            ProfileMenuRow(
                icon: "leaf.arrow.circlepath",
                title: "Sở thích dinh dưỡng & Dị ứng",
                subtitle: "Món ưa thích, thực đơn kiêng cữ",
                action: onOpenPreferences
            )

            Divider()
                .padding(.leading, 56)
                .background(AppColors.divider)

            ProfileMenuRow(
                icon: "lock.shield.fill",
                title: "Tài khoản & Bảo mật",
                subtitle: "Quản lý phiên đăng nhập và dữ liệu",
                action: onOpenAccount
            )

            Divider()
                .padding(.leading, 56)
                .background(AppColors.divider)

            ProfileMenuRow(
                icon: "gearshape.fill",
                title: "Cài đặt ứng dụng",
                subtitle: "Thông báo, giao diện, quyền riêng tư",
                action: onOpenSettings
            )

            Divider()
                .padding(.leading, 56)
                .background(AppColors.divider)

            ProfileMenuRow(
                icon: "info.circle.fill",
                title: "Giới thiệu về NutriLens",
                subtitle: "Phiên bản v1.0 • AI Dinh dưỡng Việt",
                action: onOpenAbout
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
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
    }
}

public struct ProfileMenuRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let action: () -> Void

    public init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                // Leading icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AppColors.surfaceSecondary)
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.forestGreen)
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
        .buttonStyle(PlainButtonStyle())
    }
}
