//
//  IngredientReviewSheet.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Detailed inspection of documented ingredients, allergen indicators, and safety disclaimers.
//  NOTE: Strictly avoids fabricating missing ingredients; emphasizes cross-contact awareness.
//

import SwiftUI

public struct IngredientReviewSheet: View {
    public let suggestion: MealSuggestion
    public let userProfile: UserDietaryProfile
    public let onDismiss: () -> Void

    public init(
        suggestion: MealSuggestion,
        userProfile: UserDietaryProfile,
        onDismiss: @escaping () -> Void
    ) {
        self.suggestion = suggestion
        self.userProfile = userProfile
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.97, green: 0.98, blue: 0.97).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 1. Header Card with Verification Status
                        headerStatusCard

                        // 2. Allergen Risk Analysis
                        allergenAnalysisSection

                        // 3. Documented Ingredients List
                        documentedIngredientsSection

                        // 4. Nutritional Profile
                        nutritionProfileCard

                        // 5. Cross-contact & Real-world Preparation Disclaimer
                        crossContactDisclaimerCard
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Thành phần & Dị ứng")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng", action: onDismiss)
                        .font(AppTypography.bodyBold)
                        .foregroundColor(AppColors.forestGreen)
                }
            }
        }
    }

    // MARK: - Subviews
    private var headerStatusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(suggestion.displayName)
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: suggestion.ingredientVerificationStatus.systemIcon)
                    Text(suggestion.ingredientVerificationStatus.badgeLabel)
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(suggestion.ingredientVerificationStatus == .verified ? AppColors.forestGreen : Color(red: 0.70, green: 0.45, blue: 0.10))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(suggestion.ingredientVerificationStatus == .verified ? AppColors.mintSurface : Color(red: 1.0, green: 0.95, blue: 0.88))
                .clipShape(Capsule())
            }

            Text(suggestion.ingredientVerificationStatus.disclaimer)
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(2)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
    }

    private var allergenAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Phân tích dị ứng tiềm ẩn")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text("Theo dữ liệu NIN")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textTertiary)
            }

            if suggestion.allergenWarnings.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.forestGreen)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Không phát hiện nhóm dị ứng lớn phổ biến")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        Text("Theo công thức chuẩn, món này không ghi nhận các nhóm dị ứng chính như lạc, tôm cua, trứng, sữa hay lúa mì.")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(14)
                .background(Color(red: 0.94, green: 0.98, blue: 0.95))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                VStack(spacing: 8) {
                    ForEach(suggestion.allergenWarnings) { allergen in
                        let isUserAllergic = userProfile.hasDeclaredAllergen(allergen)

                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(isUserAllergic ? Color(red: 1.0, green: 0.92, blue: 0.92) : Color(red: 1.0, green: 0.96, blue: 0.88))
                                    .frame(width: 34, height: 34)
                                Image(systemName: allergen.systemIcon)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(isUserAllergic ? Color(red: 0.85, green: 0.20, blue: 0.20) : Color(red: 0.70, green: 0.45, blue: 0.10))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(allergen.vietnameseName)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(AppColors.textPrimary)

                                    if isUserAllergic {
                                        Text("BẠN ĐÃ KHAI BÁO DỊ ỨNG")
                                            .font(.system(size: 9, weight: .heavy))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 2)
                                            .background(Color(red: 0.85, green: 0.20, blue: 0.20))
                                            .clipShape(Capsule())
                                    }
                                }

                                Text(allergen.riskDescription)
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            Spacer()
                        }
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isUserAllergic ? Color(red: 0.9, green: 0.4, blue: 0.4) : Color(red: 0.90, green: 0.90, blue: 0.90), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    private var documentedIngredientsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Thành phần nguyên liệu ghi nhận")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            if suggestion.documentedIngredients.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(Color(red: 0.70, green: 0.45, blue: 0.10))
                        Text("Chưa đủ thông tin thành phần chi tiết")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    Text("Món ăn này hiện chỉ có chỉ số calo & đa lượng từ Bảng thành phần NIN/USDA, chưa lưu trữ danh sách nguyên liệu chi tiết.")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                VStack(spacing: 6) {
                    ForEach(suggestion.documentedIngredients, id: \.self) { ingredient in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(AppColors.forestGreen)
                                .frame(width: 5, height: 5)
                            Text(ingredient)
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
            }
        }
    }

    private var nutritionProfileCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Thông tin dinh dưỡng ước tính")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: 8) {
                NutrientDetailTile(title: "Năng lượng", value: "\(Int(suggestion.availableNutritionEstimate.calories))", unit: "kcal", color: AppColors.forestGreen)
                NutrientDetailTile(title: "Chất đạm", value: "\(Int(suggestion.availableNutritionEstimate.proteinGrams))", unit: "g", color: AppColors.proteinBlue)
                NutrientDetailTile(title: "Chất bột đường", value: "\(Int(suggestion.availableNutritionEstimate.carbGrams))", unit: "g", color: AppColors.carbOrange)
                NutrientDetailTile(title: "Chất béo", value: "\(Int(suggestion.availableNutritionEstimate.fatGrams))", unit: "g", color: AppColors.fatRed)
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }

    private var crossContactDisclaimerCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "shield.lefthalf.filled.trianglebadge.exclamationmark")
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.70, green: 0.45, blue: 0.10))

            VStack(alignment: .leading, spacing: 3) {
                Text("Cảnh báo nhiễm chéo & chế biến thực tế")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Text("NutriLens không tiến hành xét nghiệm hóa sinh tại cơ sở chế biến. Nước xốt, dầu chiên đi chiên lại, gia vị nêm hoặc nguy cơ nhiễm chéo trong gian bếp có thể chứa chất gây dị ứng. Người có cơ địa dị ứng nguy cấp cần luôn xác thực với nhà hàng.")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary)
                    .lineSpacing(2)
            }
        }
        .padding(14)
        .background(Color(red: 1.0, green: 0.97, blue: 0.92))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color(red: 0.92, green: 0.85, blue: 0.75), lineWidth: 1))
    }
}

private struct NutrientDetailTile: View {
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 9))
                .foregroundColor(AppColors.textSecondary)
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                Text(unit)
                    .font(.system(size: 9))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(red: 0.96, green: 0.98, blue: 0.97))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

