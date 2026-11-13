//
//  PackagedFoodLibraryView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Library view for browsing, searching, and managing saved packaged foods.
//

import SwiftUI

public struct PackagedFoodLibraryView: View {
    @ObservedObject var viewModel: BarcodeScannerViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showCreateSheet: Bool = false
    @State private var selectedProductForDetail: PackagedFood?

    public init(viewModel: BarcodeScannerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.sm) {
                // Filter tabs
                Picker("Bộ lọc", selection: $viewModel.selectedLibraryFilter) {
                    ForEach(BarcodeScannerViewModel.LibraryFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppSpacing.md)
                .onChange(of: viewModel.selectedLibraryFilter) { _, _ in
                    Task { await viewModel.loadLibrary() }
                }

                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Tìm theo tên, hãng hoặc mã vạch...", text: $viewModel.librarySearchQuery)
                        .font(AppTypography.body)
                        .onChange(of: viewModel.librarySearchQuery) { _, _ in
                            Task { await viewModel.loadLibrary() }
                        }
                    if !viewModel.librarySearchQuery.isEmpty {
                        Button {
                            viewModel.librarySearchQuery = ""
                            Task { await viewModel.loadLibrary() }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(AppSpacing.sm)
                .background(AppColors.surfaceBackground)
                .cornerRadius(AppRadius.medium)
                .padding(.horizontal, AppSpacing.md)

                // Product List
                if viewModel.libraryFoods.isEmpty {
                    emptyStateView()
                } else {
                    List {
                        ForEach(viewModel.libraryFoods) { product in
                            productRow(product: product)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedProductForDetail = product
                                }
                        }
                        .onDelete { indexSet in
                            deleteProducts(at: indexSet)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Kho thực phẩm đóng gói")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .task {
                await viewModel.loadLibrary()
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateEditPackagedFoodView(viewModel: viewModel)
            }
            .sheet(item: $selectedProductForDetail) { product in
                NavigationStack {
                    PackagedFoodDetailView(viewModel: viewModel, product: product)
                }
            }
        }
    }

    private func productRow(product: PackagedFood) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    if let brand = product.brand, !brand.isEmpty {
                        Text(brand.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(AppColors.primary)
                    }
                    Text(product.productName)
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textPrimary)
                }

                Spacer()

                Button {
                    Task {
                        await viewModel.toggleFavorite(id: product.id)
                    }
                } label: {
                    Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(product.isFavorite ? .red : .gray)
                        .font(.body)
                }
                .buttonStyle(.plain)
            }

            HStack {
                Text("\(Int(product.nutrition.calories)) kcal")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.primary)

                Text("• P: \(String(format: "%.1f", product.nutrition.proteinGrams))g • C: \(String(format: "%.1f", product.nutrition.carbGrams))g • F: \(String(format: "%.1f", product.nutrition.fatGrams))g")
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)

                Spacer()

                Text(product.barcode)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.medium)
                .stroke(AppColors.leafGreen.opacity(0.12), lineWidth: 1)
        )
    }

    private func emptyStateView() -> some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 54))
                .foregroundColor(AppColors.primary.opacity(0.6))

            Text("Chưa có sản phẩm nào")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text("Quét mã vạch hoặc bấm dấu (+) ở góc trên để thêm sản phẩm đóng gói mới.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)

            Button {
                showCreateSheet = true
            } label: {
                Text("Tạo sản phẩm mới")
                    .font(AppTypography.buttonText)
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColors.primary)
                    .cornerRadius(AppRadius.large)
            }
            .padding(.top, AppSpacing.sm)

            Spacer()
        }
    }

    private func deleteProducts(at offsets: IndexSet) {
        for index in offsets {
            let product = viewModel.libraryFoods[index]
            Task {
                await viewModel.deleteProduct(id: product.id)
            }
        }
    }
}

