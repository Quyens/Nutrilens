//
//  BotanicalTextField.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Fresh Premium Botanical text field with soft mint surface, subtle border, and clear icons.
//

import SwiftUI

public struct BotanicalTextField: View {
    private let title: String
    private let placeholder: String
    @Binding private var text: String
    private let icon: String
    private let isSecure: Bool
    private let keyboardType: UIKeyboardType
    private let autocapitalization: TextInputAutocapitalization
    
    @State private var isPasswordVisible: Bool = false
    @FocusState private var isFocused: Bool

    public init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        icon: String,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .never
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppTypography.captionBold)
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isFocused ? AppColors.primary : AppColors.textSecondary)
                    .frame(width: 22)

                if isSecure && !isPasswordVisible {
                    SecureField(placeholder, text: $text)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                        .focused($isFocused)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(autocapitalization)
                        .autocorrectionDisabled()
                } else {
                    TextField(placeholder, text: $text)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                        .focused($isFocused)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(autocapitalization)
                        .autocorrectionDisabled()
                }

                if isSecure {
                    Button {
                        isPasswordVisible.toggle()
                        #if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        #endif
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 15))
                            .foregroundColor(AppColors.textTertiary)
                    }
                    .accessibilityLabel(isPasswordVisible ? "Ẩn mật khẩu" : "Hiện mật khẩu")
                } else if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(AppColors.textTertiary)
                    }
                    .accessibilityLabel("Xóa nội dung")
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                    .fill(isFocused ? AppColors.surfacePrimary : AppColors.surfaceSecondary.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                    .stroke(
                        isFocused ? AppColors.primary : AppColors.border,
                        lineWidth: isFocused ? 1.5 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)
        }
    }
}
