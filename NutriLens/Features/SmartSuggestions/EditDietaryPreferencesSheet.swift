//
//  EditDietaryPreferencesSheet.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Allows users to customize dietary preferences, declare allergens, and specify disliked ingredients.
//  NOTE: Nonjudgmental, flexible, preserves settings locally.
//

import SwiftUI

public struct EditDietaryPreferencesSheet: View {
    @Environment(\.dismiss) private var dismiss

    public let initialProfile: UserDietaryProfile
    public let onSave: (UserDietaryProfile) -> Void
    public let onClear: () -> Void

    @State private var selectedPreferences: Set<DietaryPreferenceType>
    @State private var selectedAllergens: Set<AllergenType>
    @State private var dislikedIngredients: [String]
    @State private var newDislikedIngredientText: String = ""

    public init(
        initialProfile: UserDietaryProfile,
        onSave: @escaping (UserDietaryProfile) -> Void,
        onClear: @escaping () -> Void
    ) {
        self.initialProfile = initialProfile
        self.onSave = onSave
        self.onClear = onClear
        _selectedPreferences = State(initialValue: initialProfile.dietaryPreferences)
        _selectedAllergens = State(initialValue: initialProfile.declaredAllergens)
        _dislikedIngredients = State(initialValue: initialProfile.dislikedIngredients)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.97, green: 0.98, blue: 0.97).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // 1. Dietary Lifestyles
                        dietaryStyleSection

                        // 2. Declared Allergens
                        allergensSection

                        // 3. Disliked Ingredients
                        dislikedIngredientsSection

                        // 4. Reset to Default Button
                        resetSection

                        // 5. Educational Disclaimer
                        disclaimerSection
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Sở thích dinh dưỡng")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        var updated = initialProfile
                        updated.dietaryPreferences = selectedPreferences
                        updated.declaredAllergens = selectedAllergens
                        updated.dislikedIngredients = dislikedIngredients
                        onSave(updated)
                        dismiss()
                    }
                    .font(AppTypography.bodyBold)
                    .foregroundColor(AppColors.forestGreen)
                    .accessibilityIdentifier("save_preferences_button")
                }
            }
        }
    }

    // MARK: - Subviews
    private var dietaryStyleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Trường phái dinh dưỡng & ẩm thực")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                Text("Chọn phong cách ẩm thực bạn muốn ưu tiên khi nhận gợi ý món ăn:")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }

            VStack(spacing: 8) {
                ForEach(DietaryPreferenceType.allCases) { style in
                    let isSelected = selectedPreferences.contains(style)

                    Button {
                        if isSelected {
                            selectedPreferences.remove(style)
                        } else {
                            selectedPreferences.insert(style)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(isSelected ? AppColors.forestGreen : Color(red: 0.95, green: 0.97, blue: 0.95))
                                    .frame(width: 34, height: 34)
                                Image(systemName: style.systemIcon)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(isSelected ? .white : AppColors.forestGreen)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(style.title)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                Text(style.subtitle)
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            Spacer()

                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 18))
                                .foregroundColor(isSelected ? AppColors.forestGreen : AppColors.textTertiary)
                        }
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isSelected ? AppColors.forestGreen : AppColors.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var allergensSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Cảnh báo dị ứng thực phẩm")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                Text("Hệ thống sẽ chủ động lọc bỏ hoặc cảnh báo các món có chứa thành phần tương ứng:")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(AllergenType.allCases) { allergen in
                    let isSelected = selectedAllergens.contains(allergen)

                    Button {
                        if isSelected {
                            selectedAllergens.remove(allergen)
                        } else {
                            selectedAllergens.insert(allergen)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: allergen.systemIcon)
                                .font(.system(size: 14))
                                .foregroundColor(isSelected ? Color(red: 0.85, green: 0.20, blue: 0.20) : AppColors.textSecondary)

                            Text(allergen.shortName)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(isSelected ? Color(red: 0.85, green: 0.20, blue: 0.20) : AppColors.textPrimary)
                                .lineLimit(1)

                            Spacer()

                            Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                .font(.system(size: 14))
                                .foregroundColor(isSelected ? Color(red: 0.85, green: 0.20, blue: 0.20) : AppColors.textTertiary)
                        }
                        .padding(10)
                        .background(isSelected ? Color(red: 1.0, green: 0.94, blue: 0.94) : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(isSelected ? Color(red: 0.9, green: 0.5, blue: 0.5) : AppColors.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var dislikedIngredientsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Nguyên liệu không thích / Kiêng cá nhân")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                Text("Ví dụ: hành lá, sả, rau mùi, ớt, mắm tôm...")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }

            // Input Row
            HStack(spacing: 8) {
                TextField("Thêm nguyên liệu cần tránh...", text: $newDislikedIngredientText)
                    .font(.system(size: 14))
                    .padding(10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(AppColors.border, lineWidth: 1))

                Button(action: addDislikedIngredient) {
                    Text("Thêm")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(AppColors.forestGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .disabled(newDislikedIngredientText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            // Tag Cloud
            if !dislikedIngredients.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(dislikedIngredients, id: \.self) { item in
                        HStack(spacing: 4) {
                            Text(item)
                                .font(.system(size: 12, weight: .medium))
                            Button {
                                dislikedIngredients.removeAll { $0 == item }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 9, weight: .bold))
                            }
                        }
                        .foregroundColor(AppColors.forestGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(AppColors.mintSurface)
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private func addDislikedIngredient() {
        let clean = newDislikedIngredientText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        if !dislikedIngredients.contains(where: { $0.caseInsensitiveCompare(clean) == .orderedSame }) {
            dislikedIngredients.append(clean)
        }
        newDislikedIngredientText = ""
    }

    private var resetSection: some View {
        Button(action: {
            selectedPreferences = [.vietnamese]
            selectedAllergens = []
            dislikedIngredients = []
            onClear()
            dismiss()
        }) {
            HStack {
                Image(systemName: "arrow.counterclockwise")
                Text("Đặt lại sở thích về mặc định")
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(Color(red: 0.85, green: 0.30, blue: 0.30))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color(red: 0.95, green: 0.85, blue: 0.85), lineWidth: 1))
        }
    }

    private var disclaimerSection: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 12))
                .foregroundColor(AppColors.textTertiary)

            Text("Sở thích dinh dưỡng chỉ được sử dụng nội bộ để cá nhân hóa gợi ý trên thiết bị của bạn. Không bắt buộc tuân theo bất kỳ chế độ kiêng cữ khắt khe nào.")
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(2)
        }
        .padding(.top, 4)
    }
}

// MARK: - FlowLayout Helper for Tag Cloud
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeightInRow: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0
                y += maxHeightInRow + spacing
                maxHeightInRow = 0
            }
            maxHeightInRow = max(maxHeightInRow, size.height)
            x += size.width + spacing
        }
        height = y + maxHeightInRow
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeightInRow: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += maxHeightInRow + spacing
                maxHeightInRow = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            maxHeightInRow = max(maxHeightInRow, size.height)
            x += size.width + spacing
        }
    }
}

