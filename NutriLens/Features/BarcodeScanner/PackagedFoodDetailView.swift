//
//  PackagedFoodDetailView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Detailed view of a packaged food with nutritional analysis and diary logging.
//

import SwiftUI

public struct PackagedFoodDetailView: View {
    @ObservedObject var viewModel: BarcodeScannerViewModel
    let product: PackagedFood
    @Environment(\.dismiss) private var dismiss
    @State private var showEditSheet: Bool = false
    @State private var showDeleteConfirmation: Bool = false

    public init(viewModel: BarcodeScannerViewModel, product: PackagedFood) {
        self.viewModel = viewModel
        self.product = product
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        if let brand = product.brand, !brand.isEmpty {
                            Text(brand.uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(AppColors.primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(AppColors.primary.opacity(0.12))
                                .cornerRadius(6)
                        }
                        Spacer()
                        Button {
                            Task {
                                await viewModel.toggleFavorite(id: product.id)
                            }
                        } label: {
                            Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(product.isFavorite ? .red : .gray)
                                .font(.title3)
                        }
                    }

                    Text(product.productName)
                        .font(AppTypography.title)
                        .foregroundStyle(AppColors.textPrimary)

                    HStack {
                        Label(product.category, systemImage: "tag.fill")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                        Spacer()
                        Text("Mã: \(product.barcode)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .padding(AppSpacing.md)
                .background(AppColors.cardBackground)
                .cornerRadius(AppRadius.large)

                // Nutrition Summary Card
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Thông tin dinh dưỡng (\(product.nutrition.basis.rawValue))")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textPrimary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                        nutritionBox(title: "Calo", value: "\(Int(product.nutrition.calories))", unit: "kcal", color: AppColors.primary)
                        nutritionBox(title: "Đạm", value: String(format: "%.1f", product.nutrition.proteinGrams), unit: "g", color: .blue)
                        nutritionBox(title: "Carb", value: String(format: "%.1f", product.nutrition.carbGrams), unit: "g", color: .orange)
                        nutritionBox(title: "Béo", value: String(format: "%.1f", product.nutrition.fatGrams), unit: "g", color: .purple)
                    }

                    Divider().padding(.vertical, 4)

                    VStack(spacing: 4) {
                        detailRow("Kích thước khẩu phần", "\(Int(product.serving.servingSize)) \(product.serving.servingUnit)")
                        if let count = product.serving.servingsPerPackage {
                            detailRow("Khẩu phần mỗi gói", String(format: "%.1f", count))
                        }
                        if let fiber = product.nutrition.fiberGrams {
                            detailRow("Chất xơ", "\(String(format: "%.1f", fiber)) g")
                        }
                        if let sodium = product.nutrition.sodiumMg {
                            detailRow("Natri (Sodium)", "\(Int(sodium)) mg")
                        }
                        if let sugar = product.nutrition.sugarGrams {
                            detailRow("Đường", "\(String(format: "%.1f", sugar)) g")
                        }
                        if let calcium = product.nutrition.calciumMg {
                            detailRow("Canxi", "\(Int(calcium)) mg")
                        }
                    }
                }
                .padding(AppSpacing.md)
                .background(AppColors.cardBackground)
                .cornerRadius(AppRadius.large)

                // Ingredients & Allergens
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Thành phần & Dị ứng")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textPrimary)

                    if !product.allergens.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Chất gây dị ứng công bố:")
                                .font(AppTypography.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)

                            HStack(spacing: 6) {
                                ForEach(product.allergens) { allergen in
                                    Text(allergen.shortName)
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.red.opacity(0.12))
                                        .foregroundColor(.red)
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }

                    if let text = product.ingredientText, !text.isEmpty {
                        Text(text)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.cardBackground)
                .cornerRadius(AppRadius.large)

                // Actions
                VStack(spacing: AppSpacing.sm) {
                    Button {
                        viewModel.activeProduct = product
                        viewModel.servingMultiplier = 1.0
                        viewModel.evaluateSafety(for: product)
                        viewModel.showResultSheet = true
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "plus.circle.fill")
                            Text("Ghi vào Nhật ký bữa ăn")
                        }
                        .font(AppTypography.buttonText)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(AppColors.primary)
                        .cornerRadius(AppRadius.large)
                    }

                    Button {
                        showEditSheet = true
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "pencil")
                            Text("Chỉnh sửa thông tin")
                        }
                        .font(AppTypography.buttonText)
                        .foregroundColor(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(AppColors.surfaceBackground)
                        .cornerRadius(AppRadius.large)
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                            Text("Xóa khỏi kho")
                        }
                        .font(AppTypography.caption)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                    }
                }
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Chi tiết sản phẩm")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditSheet) {
            CreateEditPackagedFoodView(viewModel: viewModel, existingFood: product)
        }
        .alert("Xác nhận xóa", isPresented: $showDeleteConfirmation) {
            Button("Hủy", role: .cancel) {}
            Button("Xóa", role: .destructive) {
                Task {
                    await viewModel.deleteProduct(id: product.id)
                    dismiss()
                }
            }
        } message: {
            Text("Bạn có chắc chắn muốn xóa '\(product.productName)' khỏi kho thực phẩm cá nhân không?")
        }
    }

    private func nutritionBox(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(title).font(.caption).foregroundStyle(AppColors.textSecondary)
            Text(value).font(.system(.title3, design: .rounded, weight: .bold)).foregroundColor(color)
            Text(unit).font(.caption2).foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(AppColors.surfaceBackground)
        .cornerRadius(AppRadius.medium)
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).font(AppTypography.caption).foregroundStyle(AppColors.textSecondary)
            Spacer()
            Text(value).font(AppTypography.caption).fontWeight(.medium).foregroundStyle(AppColors.textPrimary)
        }
    }
}

