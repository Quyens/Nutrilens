//
//  FoodRecognitionView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI
import PhotosUI

public struct FoodRecognitionView: View {
    @StateObject private var viewModel: FoodRecognitionViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?
    private let onResultConfirmed: (FoodItem) -> Void

    public init(
        viewModel: FoodRecognitionViewModel,
        onResultConfirmed: @escaping (FoodItem) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onResultConfirmed = onResultConfirmed
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                // Camera viewfinder background
                Color.black.ignoresSafeArea()

                VStack(spacing: AppSpacing.lg) {
                    // Top guidance bar
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(AppColors.primaryLight)
                        Text("Point camera at your meal")
                            .font(AppTypography.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color.black.opacity(0.4))

                    Spacer()

                    // Center Targeting Reticle
                    ViewfinderReticleView(isScanning: viewModel.recognitionState.isLoading)
                        .frame(width: 280, height: 280)

                    Spacer()

                    // Bottom controls & state handling
                    VStack(spacing: AppSpacing.md) {
                        if case .failure(let error) = viewModel.recognitionState {
                            ErrorBannerView(error: error) {
                                viewModel.reset()
                            }
                        }

                        HStack(spacing: AppSpacing.xl) {
                            // Photo library picker
                            PhotosPicker(
                                selection: $selectedPhotoItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .onChange(of: selectedPhotoItem) { _, newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        await viewModel.analyzeImage(data: data)
                                    }
                                }
                            }

                            // Capture trigger button
                            Button(action: {
                                // Trigger sample scan payload for validation
                                let placeholderData = Data("NutriLens_Food_Scan_Payload".utf8)
                                Task {
                                    await viewModel.analyzeImage(data: placeholderData)
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 4)
                                        .frame(width: 76, height: 76)

                                    Circle()
                                        .fill(AppColors.primary)
                                        .frame(width: 64, height: 64)

                                    if viewModel.recognitionState.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    }
                                }
                            }
                            .disabled(viewModel.recognitionState.isLoading)
                            .accessibilityLabel("Capture Food Photo")

                            // Flash / Info toggle placeholder
                            Button(action: {
                                viewModel.reset()
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("Reset Scanner")
                        }
                    }
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .navigationTitle("Food Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.isPresentingNutritionResult) {
                if let candidate = viewModel.selectedResult?.primaryFood {
                    NutritionResultView(
                        item: candidate,
                        onConfirm: { confirmedItem in
                            viewModel.isPresentingNutritionResult = false
                            onResultConfirmed(confirmedItem)
                        },
                        onCancel: {
                            viewModel.isPresentingNutritionResult = false
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Viewfinder Reticle with Scanning Corners
private struct ViewfinderReticleView: View {
    let isScanning: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                .stroke(isScanning ? AppColors.primary : Color.white.opacity(0.6), lineWidth: 2.5)

            if isScanning {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primary.opacity(0), AppColors.primary.opacity(0.5), AppColors.primary.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 30)
                    .padding(.horizontal, 4)
            }
        }
    }
}

private struct ErrorBannerView: View {
    let error: AppError
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(AppColors.error)

            VStack(alignment: .leading, spacing: 2) {
                Text(error.localizedDescription)
                    .font(AppTypography.captionBold)
                    .foregroundColor(.white)

                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(AppTypography.caption)
                        .foregroundColor(Color.white.opacity(0.8))
                }
            }

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding(4)
            }
        }
        .padding(AppSpacing.sm)
        .background(Color.black.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .padding(.horizontal, AppSpacing.md)
    }
}
