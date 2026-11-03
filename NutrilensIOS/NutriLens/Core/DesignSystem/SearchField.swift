//
//  SearchField.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Standardized search and editable text input field with clear action.
//

import SwiftUI

public struct SearchField: View {
    @Binding private var text: String
    private let placeholder: LocalizedStringKey
    private let onCommit: (() -> Void)?

    public init(
        text: Binding<String>,
        placeholder: LocalizedStringKey = "Search Vietnamese dishes...",
        onCommit: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onCommit = onCommit
    }

    public var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColors.textSecondary)

            TextField(placeholder, text: $text)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
                .autocorrectionDisabled()
                .onSubmit {
                    onCommit?()
                }

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.textTertiary)
                }
                .accessibilityLabel("Clear text")
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 12)
        .background(AppColors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}
