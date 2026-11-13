//
//  RecommendationExplanationSheet.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Provides transparent, human-readable explanations of recommendation factors.
//  NOTE: Explicitly clarifies scoring is algorithmic context-matching, NOT clinical prescription.
//

import SwiftUI

public struct RecommendationExplanationSheet: View {
    public let suggestion: MealSuggestion
    public let onDismiss: () -> Void

    public init(suggestion: MealSuggestion, onDismiss: @escaping () -> Void) {
        self.suggestion = suggestion
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.97, green: 0.98, blue: 0.97).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 1. Dish Overview Header Card
                        headerOverviewCard

                        // 2. Recommendation Match Score & Status
                        matchScoreCard

                        // 3. Algorithmic Factors Breakdown
                        factorsBreakdownSection

                        // 4. Variety & Recency Context
                        varietyContextCard

                        // 5. Medical Non-Prescription Transparency Disclaimer
                        transparencyDisclaimerCard
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Tại sao gợi ý món này?")
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
    private var headerOverviewCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppColors.mintSurface)
                    .frame(width: 50, height: 50)
                Image(systemName: suggestion.foodSource.systemIcon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppColors.forestGreen)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(suggestion.displayName)
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(AppColors.textPrimary)

                HStack(spacing: 6) {
                    Text(suggestion.dishCategory)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppColors.forestGreen)

                    Text("•")
                        .foregroundColor(AppColors.textTertiary)

                    Text(suggestion.suggestedServing)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
    }

    private var matchScoreCard: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Điểm phù hợp")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                    Text(suggestion.scoreDescription)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.12, green: 0.45, blue: 0.28))
                }

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(suggestion.recommendationScore)")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(AppColors.forestGreen)
                    Text("/100")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textTertiary)
                }
            }

            ProgressView(value: Double(suggestion.recommendationScore), total: 100.0)
                .tint(AppColors.forestGreen)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
    }

    private var factorsBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Các yếu tố thúc đẩy gợi ý")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            if suggestion.explanationFactors.isEmpty {
                Text("Gợi ý dựa trên tiêu chí dinh dưỡng chung và đặc sản món Việt.")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                VStack(spacing: 8) {
                    ForEach(suggestion.explanationFactors) { factor in
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(factor.scoreImpact >= 0 ? AppColors.mintSurface : Color(red: 1.0, green: 0.94, blue: 0.94))
                                    .frame(width: 32, height: 32)
                                Image(systemName: factor.systemIcon)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(factor.scoreImpact >= 0 ? AppColors.forestGreen : Color(red: 0.85, green: 0.3, blue: 0.3))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(factor.title)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                Text(factor.detail)
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                                    .lineSpacing(2)
                            }

                            Spacer()

                            if factor.scoreImpact != 0 {
                                Text(factor.scoreImpact > 0 ? "+\(factor.scoreImpact)" : "\(factor.scoreImpact)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(factor.scoreImpact > 0 ? AppColors.forestGreen : Color(red: 0.85, green: 0.3, blue: 0.3))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(factor.scoreImpact > 0 ? AppColors.mintSurface : Color(red: 1.0, green: 0.92, blue: 0.92))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
        }
    }

    private var varietyContextCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.swap")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColors.forestGreen)
                Text("Đa dạng thực đơn tuần")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
            }

            Text("NutriLens đối chiếu các món bạn đã ghi trong Nhật ký và Kế hoạch tuần này để ưu tiên đổi món, tránh lặp lại cùng một món quá nhiều bữa liên tiếp.")
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.94, green: 0.97, blue: 0.95))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color(red: 0.86, green: 0.92, blue: 0.88), lineWidth: 1))
    }

    private var transparencyDisclaimerCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.bubble.fill")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textTertiary)

            VStack(alignment: .leading, spacing: 3) {
                Text("Minh bạch thuật toán")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)
                Text("Điểm phù hợp được tính toán theo quy tắc toán học minh bạch, không sử dụng mô hình xác suất đen hay trí tuệ nhân tạo tạo sinh giả định. Gợi ý mang tính tham khảo dinh dưỡng thông thường, không thay thế phác đồ điều trị hay chỉ định của bác sĩ.")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textTertiary)
                    .lineSpacing(2)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

