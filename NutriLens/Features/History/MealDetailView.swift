//
//  MealDetailView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Presents comprehensive nutritional details for a logged meal with Edit and Delete actions.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct MealDetailView: View {
    let meal: MealRecord
    let onEdit: (MealRecord) -> Void
    let onDelete: (MealRecord) -> Void
    let onDismiss: () -> Void

    public init(
        meal: MealRecord,
        onEdit: @escaping (MealRecord) -> Void,
        onDelete: @escaping (MealRecord) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.meal = meal
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onDismiss = onDismiss
    }

    private var primaryFood: FoodItem? {
        meal.items.first
    }

    private var matchedProfile: VietnameseDishProfile? {
        guard let name = primaryFood?.vietnameseName else { return nil }
        return VietnameseNutritionDatabase.dishes.first {
            $0.vietnameseName.lowercased() == name.lowercased() ||
            $0.slug.lowercased() == (meal.imagePath ?? "").lowercased()
        }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppColors.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.md) {
                        // 1. Hero Food Photography Card
                        heroImageSection

                        // 2. Title & Metadata
                        titleSection

                        // 3. Calories Hero Summary
                        caloriesCard

                        // 4. Detailed Macronutrient Breakdown (4 Cards)
                        macronutrientsSection

                        // 5. Traceable Nutrition Source
                        provenanceCitationCard

                        // 6. User Notes (if any)
                        if let notes = meal.notes, !notes.isEmpty {
                            notesCard(notes: notes)
                        }

                        // 7. Action Dock (Edit & Delete)
                        actionButtonsSection
                            .padding(.top, AppSpacing.sm)
                            .padding(.bottom, AppSpacing.xl)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.sm)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .accessibilityIdentifier("detail_close_button")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onEdit(meal)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                            Text("Sửa")
                        }
                        .font(AppTypography.captionBold)
                        .foregroundColor(AppColors.primaryAction)
                    }
                    .accessibilityIdentifier("detail_top_edit_button")
                }
            }
        }
    }

    // MARK: - Subviews

    private var heroImageSection: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let path = meal.imagePath, (path.contains("com_tam") || path == "com_tam") {
                    Image("com_tam_photo")
                        .resizable()
                        .scaledToFill()
                } else if let path = meal.imagePath, (path.contains("salad") || path.contains("goi")) {
                    Image("banner_salad")
                        .resizable()
                        .scaledToFill()
                } else {
                    // Sophisticated botanical gradient surface
                    LinearGradient(
                        colors: [
                            Color(red: 0.16, green: 0.42, blue: 0.28),
                            Color(red: 0.08, green: 0.26, blue: 0.16)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: meal.mealType.systemIcon)
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(Color.white.opacity(0.8))
                            Text(meal.displayTitle)
                                .font(AppTypography.headlineBold)
                                .foregroundColor(.white)
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.cardLarge, style: .continuous))

            // Dark vignette gradient for contrast
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.75)],
                startPoint: .center,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.cardLarge, style: .continuous))

            // Category & Timestamp badge
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: meal.mealType.systemIcon)
                        .font(.system(size: 11, weight: .bold))
                    Text(meal.mealType.vietnameseName)
                        .font(AppTypography.captionBold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.ultraThinMaterial)
                .foregroundColor(.white)
                .clipShape(Capsule())

                Spacer()

                Text(meal.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(AppTypography.captionBold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Capsule())
            }
            .padding(AppSpacing.md)
        }
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.cardLarge, style: .continuous)
                .stroke(AppColors.borderSubtle, lineWidth: 1)
        )
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(meal.displayTitle)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            if let english = primaryFood?.name, english != meal.displayTitle {
                Text(english)
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }

            HStack(spacing: 12) {
                Label(
                    title: { Text("\(Int(meal.totalServingGrams))g khẩu phần") },
                    icon: { Image(systemName: "scalemass.fill") }
                )
                .font(AppTypography.captionBold)
                .foregroundColor(AppColors.primaryAction)

                Text("•")
                    .foregroundColor(AppColors.textTertiary)

                Label(
                    title: { Text(meal.timestamp.formatted(date: .abbreviated, time: .omitted)) },
                    icon: { Image(systemName: "calendar") }
                )
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var caloriesCard: some View {
        CardView(padding: AppSpacing.md, cornerRadius: AppRadius.card) {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryGreen.opacity(0.14))
                        .frame(width: 58, height: 58)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppColors.primaryGreen)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Năng lượng bữa ăn")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)

                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(Int(meal.totalCalories))")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)

                        Text("kcal")
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Tỷ lệ mục tiêu ngày")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textTertiary)

                    let percent = min(Int((meal.totalCalories / 2000.0) * 100), 100)
                    Text("\(percent)%")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryGreen)
                }
            }
        }
    }

    private var macronutrientsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Dinh dưỡng chi tiết")
                .font(AppTypography.headlineBold)
                .foregroundColor(AppColors.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                NutrientDetailCard(
                    title: "Chất đạm (Protein)",
                    amountGrams: meal.totalProteinGrams,
                    targetGrams: 125,
                    color: AppColors.proteinOcean,
                    icon: "bolt.fill"
                )

                NutrientDetailCard(
                    title: "Tinh bột (Carbs)",
                    amountGrams: meal.totalCarbGrams,
                    targetGrams: 250,
                    color: AppColors.carbAmber,
                    icon: "leaf.fill"
                )

                NutrientDetailCard(
                    title: "Chất béo (Fat)",
                    amountGrams: meal.totalFatGrams,
                    targetGrams: 55,
                    color: AppColors.fatCoral,
                    icon: "drop.fill"
                )

                NutrientDetailCard(
                    title: "Chất xơ (Fiber)",
                    amountGrams: meal.totalFiberGrams,
                    targetGrams: 30,
                    color: AppColors.primaryGreen,
                    icon: "doc.text.fill"
                )
            }
        }
    }

    private var provenanceCitationCard: some View {
        CardView(padding: AppSpacing.md, cornerRadius: AppRadius.card) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(AppColors.primaryGreen)
                    Text("Nguồn dữ liệu dinh dưỡng chuẩn")
                        .font(AppTypography.captionBold)
                        .foregroundColor(AppColors.textPrimary)
                }

                let profile = matchedProfile
                Text(profile?.provenance ?? "Bảng Thành Phần Thực Phẩm Việt Nam – Viện Dinh Dưỡng Quốc Gia")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)

                if let code = profile?.referenceCode {
                    Text("Mã tham chiếu: \(code)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(AppColors.textTertiary)
                }

                if let limitations = profile?.limitations {
                    Divider()
                        .padding(.vertical, 2)
                    Text("Lưu ý: \(limitations)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }

    private func notesCard(notes: String) -> some View {
        CardView(padding: AppSpacing.md, cornerRadius: AppRadius.card) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "note.text")
                        .foregroundColor(AppColors.textSecondary)
                    Text("Ghi chú bữa ăn")
                        .font(AppTypography.captionBold)
                        .foregroundColor(AppColors.textPrimary)
                }

                Text(notes)
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var actionButtonsSection: some View {
        VStack(spacing: AppSpacing.sm) {
            PrimaryButton("Chỉnh sửa bữa ăn", icon: "pencil") {
                onEdit(meal)
            }
            .accessibilityIdentifier("detail_edit_meal_button")

            SecondaryButton("Xóa khỏi nhật ký", icon: "trash") {
                onDelete(meal)
            }
            .accessibilityIdentifier("detail_delete_meal_button")
        }
    }
}

// MARK: - Nutrient Detail Card
private struct NutrientDetailCard: View {
    let title: String
    let amountGrams: Double
    let targetGrams: Double
    let color: Color
    let icon: String

    var body: some View {
        CardView(padding: AppSpacing.sm + 2, cornerRadius: AppRadius.card) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(color)
                    Text(title)
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }

                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(String(format: "%.1f", amountGrams))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    Text("g")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                // Mini Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(color.opacity(0.18))
                            .frame(height: 5)

                        let progress = min(CGFloat(amountGrams / targetGrams), 1.0)
                        Capsule()
                            .fill(color)
                            .frame(width: geo.size.width * progress, height: 5)
                    }
                }
                .frame(height: 5)

                Text("\(Int((amountGrams / targetGrams) * 100))% mục tiêu ngày")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
    }
}
