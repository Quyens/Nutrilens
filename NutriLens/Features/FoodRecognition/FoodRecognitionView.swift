//
//  FoodRecognitionView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Implements the complete Fresh Premium AI Food Recognition user flow:
//  Scan -> Image Capture/Selection -> AI Processing -> Recognition Result -> Nutrition Review -> Confirm & Save -> Meal Diary.
//

import SwiftUI
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif

public struct FoodRecognitionView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: FoodRecognitionViewModel
    @StateObject private var cameraService = CameraService()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var scanLaserOffset: CGFloat = -120
    @State private var isPresentingBarcodeScanner: Bool = false

    private let onMealSaved: ((MealRecord) -> Void)?
    private let onDismiss: (() -> Void)?

    public init(
        viewModel: FoodRecognitionViewModel,
        onMealSaved: ((MealRecord) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onMealSaved = onMealSaved
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            // Background
            Color(red: 0.07, green: 0.09, blue: 0.08)
                .ignoresSafeArea()

            switch viewModel.currentStep {
            case .camera:
                cameraScanView

            case .analyzing(let stage):
                analyzingView(stage: stage)

            case .recognitionResult:
                recognitionResultView

            case .nutritionReview:
                nutritionReviewView

            case .saving:
                savingView

            case .saveSuccess(let record):
                saveSuccessView(record: record)

            case .error(let error):
                errorView(error: error)
            }
        }
        .sheet(isPresented: $viewModel.isPresentingDishPicker) {
            dishPickerSheet
        }
        .fullScreenCover(isPresented: $isPresentingBarcodeScanner) {
            BarcodeScannerView(viewModel: environment.makeBarcodeScannerViewModel())
        }
        .onAppear {
            cameraService.startSession()
        }
        .onDisappear {
            cameraService.stopSession()
        }
    }

    // MARK: - 1. CAMERA SCAN VIEW

    private var cameraScanView: some View {
        ZStack {
            // 1. Camera live feed or simulated viewfinder
            if cameraService.isCameraAvailable && cameraService.permissionState == .authorized {
                CameraPreviewView(session: cameraService.session)
                    .ignoresSafeArea()
            } else {
                // Subtle botanical dark viewfinder backdrop
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0.06, green: 0.12, blue: 0.08),
                            Color(red: 0.08, green: 0.15, blue: 0.10)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    // Faint botanical grid pattern
                    VStack(spacing: 40) {
                        ForEach(0..<12) { _ in
                            Divider().background(Color.white.opacity(0.04))
                        }
                    }
                    .allowsHitTesting(false)
                }
            }

            // Dark vignette overlay
            RadialGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.6)]),
                center: .center,
                startRadius: 160,
                endRadius: 400
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // 2. Foreground scan controls
            VStack(spacing: 0) {
                // Top Navigation & Status Bar
                topCameraBar

                Spacer()

                // Center Reticle
                centerReticle

                Spacer()

                // Bottom Controls & Quick Sample Selector
                bottomCameraControls
            }
        }
    }

    private var topCameraBar: some View {
        HStack(spacing: AppSpacing.sm) {
            // Dismiss button if modal
            if let onDismiss {
                Button {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Đóng máy quét")
            }

            // Engine Status Pill
            HStack(spacing: 6) {
                Circle()
                    .fill(viewModel.isUsingFallbackEngine ? AppColors.carbAmber : AppColors.accentSage)
                    .frame(width: 7, height: 7)

                Text(viewModel.isUsingFallbackEngine ? "APPLE VISION" : "NUTRILENS AI")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(viewModel.isUsingFallbackEngine ? "• FALLBACK" : "• ON-DEVICE")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(viewModel.isUsingFallbackEngine ? AppColors.carbAmber : AppColors.accentSage)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())

            Spacer()

            // Barcode Scanner shortcut
            Button {
                isPresentingBarcodeScanner = true
            } label: {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Quét mã vạch thực phẩm")

            // Flash button (only if camera hardware available)
            if cameraService.isCameraAvailable {
                Button {
                    cameraService.toggleFlash()
                } label: {
                    Image(systemName: cameraService.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(cameraService.isFlashOn ? AppColors.calorieGold : .white)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Bật tắt đèn flash")
            }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, 54)
    }

    private var centerReticle: some View {
        VStack(spacing: 12) {
            ZStack {
                // Viewfinder frame
                RoundedRectangle(cornerRadius: AppRadius.cardLarge, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    .frame(width: 280, height: 280)

                // 4 Botanical Corner Brackets
                ReticleCornerBrackets()
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.accentSage, Color(red: 0.22, green: 0.72, blue: 0.44)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3.5
                    )
                    .frame(width: 280, height: 280)

                // Animated Laser Scanning Line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.22, green: 0.72, blue: 0.44).opacity(0),
                                Color(red: 0.22, green: 0.72, blue: 0.44).opacity(0.7),
                                Color(red: 0.22, green: 0.72, blue: 0.44).opacity(0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 260, height: 22)
                    .offset(y: scanLaserOffset)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                            scanLaserOffset = 120
                        }
                    }

                // If running in simulator or camera denied, show helper text
                if !cameraService.isCameraAvailable || cameraService.permissionState == .denied {
                    VStack(spacing: 8) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(AppColors.accentSage.opacity(0.85))

                        Text("Đặt món ăn vào khung hình")
                            .font(AppTypography.captionBold)
                            .foregroundColor(.white)

                        Text("Chụp hoặc chọn ảnh từ thư viện")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color.white.opacity(0.65))
                    }
                    .padding()
                }
            }

            // Quick instruction pill
            Text("Căn chỉnh món ăn Việt Nam vào chính giữa khung hình")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.white.opacity(0.85))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
    }

    private var bottomCameraControls: some View {
        VStack(spacing: AppSpacing.md) {
            // Simulator or Demo Testing Dishes Carousel
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.accentSage)
                    Text("Món ăn mẫu thử nghiệm nhanh:")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.75))
                    Spacer()
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(VietnameseNutritionDatabase.sampleDishes) { dish in
                            Button {
                                Task {
                                    await viewModel.selectSampleDish(dish)
                                }
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 10))
                                    Text(dish.vietnameseName)
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Color.white.opacity(0.12))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(Color.white.opacity(0.2), lineWidth: 0.8)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                }
            }
            .padding(.bottom, 2)

            // Primary Shutter and Photo Picker Action Row
            HStack(spacing: 40) {
                // 1. Photo Library Picker
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 54, height: 54)
                            .overlay(
                                Circle().stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )

                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(.white)
                    }
                }
                .onChange(of: selectedPhotoItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            await viewModel.analyzeImage(data: data, uiImage: uiImage)
                        }
                    }
                }
                .accessibilityLabel("Chọn ảnh từ Thư viện")

                // 2. Main Shutter Button
                Button {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    #endif

                    if cameraService.isCameraAvailable && cameraService.isSessionRunning {
                        Task {
                            do {
                                let (image, data) = try await cameraService.capturePhoto()
                                await viewModel.analyzeImage(data: data, uiImage: image)
                            } catch {
                                // Fallback to sample dish if hardware capture fails
                                if let sample = VietnameseNutritionDatabase.sampleDishes.first {
                                    await viewModel.selectSampleDish(sample)
                                }
                            }
                        }
                    } else {
                        // On simulator or camera unavailable, trigger default sample dish scan
                        if let sample = VietnameseNutritionDatabase.sampleDishes.first {
                            Task {
                                await viewModel.selectSampleDish(sample)
                            }
                        }
                    }
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 80, height: 80)

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.22, green: 0.72, blue: 0.44),
                                        Color(red: 0.12, green: 0.58, blue: 0.34)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 66, height: 66)
                            .shadow(color: Color(red: 0.22, green: 0.72, blue: 0.44).opacity(0.4), radius: 10, x: 0, y: 4)

                        Image(systemName: "camera.fill")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .accessibilityLabel("Chụp ảnh món ăn")

                // 3. Search / Manual Dish Entry
                Button {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    viewModel.isPresentingDishPicker = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 54, height: 54)
                            .overlay(
                                Circle().stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )

                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(.white)
                    }
                }
                .accessibilityLabel("Tìm kiếm món ăn thủ công")
            }
            .padding(.bottom, 105)
        }
    }

    // MARK: - 2. AI ANALYZING VIEW

    private func analyzingView(stage: String) -> some View {
        ZStack {
            // Botanical dark backdrop
            Color(red: 0.07, green: 0.10, blue: 0.08).ignoresSafeArea()

            VStack(spacing: AppSpacing.lg) {
                Spacer()

                // Pulsing Food Image or AI Icon
                ZStack {
                    // Outer pulsing rings
                    Circle()
                        .stroke(AppColors.accentSage.opacity(0.25), lineWidth: 2)
                        .frame(width: 180, height: 180)
                        .scaleEffect(1.15)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: stage)

                    Circle()
                        .stroke(AppColors.accentSage.opacity(0.45), lineWidth: 2)
                        .frame(width: 140, height: 140)

                    if let image = viewModel.capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(color: AppColors.forestGreen.opacity(0.4), radius: 16)
                    } else {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.12, green: 0.60, blue: 0.35), Color(red: 0.08, green: 0.42, blue: 0.24)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "sparkles")
                                    .font(.system(size: 44, weight: .light))
                                    .foregroundColor(.white)
                            )
                    }
                }

                VStack(spacing: 8) {
                    Text("NutriLens AI Vision")
                        .font(AppTypography.headlineBold)
                        .foregroundColor(.white)

                    Text(stage)
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.accentSage)
                        .multilineTextAlignment(.center)
                }

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentSage))
                    .scaleEffect(1.2)
                    .padding(.top, 4)

                Spacer()

                // Informative privacy guarantee footer
                HStack(spacing: 6) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.accentSage)

                    Text("Xử lý 100% On-Device — Không tải ảnh lên máy chủ")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.75))
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
        }
    }

    // MARK: - 3. RECOGNITION RESULT VIEW

    private var recognitionResultView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppSpacing.md) {
                // Top header with Back / Retake button
                HStack {
                    Button {
                        viewModel.retake()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Chụp lại")
                        }
                        .font(AppTypography.captionBold)
                        .foregroundColor(AppColors.accentSage)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                    }

                    Spacer()

                    Text("Kết quả nhận diện AI")
                        .font(AppTypography.subheadlineBold)
                        .foregroundColor(.white)

                    Spacer()

                    // Invisible placeholder for balanced layout
                    Color.clear.frame(width: 70, height: 32)
                }
                .padding(.top, 54)

                // 1. Food Image Presentation Hero Card
                ZStack(alignment: .bottomLeading) {
                    if let image = viewModel.capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 230)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.cardLarge, style: .continuous))
                    } else {
                        // Fallback botanical gradient
                        LinearGradient(
                            colors: [Color(red: 0.15, green: 0.28, blue: 0.20), Color(red: 0.08, green: 0.16, blue: 0.11)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 230)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.cardLarge, style: .continuous))
                        .overlay(
                            Image(systemName: "fork.knife")
                                .font(.system(size: 48))
                                .foregroundColor(AppColors.accentSage.opacity(0.5))
                        )
                    }

                    // Gradient shade for readability
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.8)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.cardLarge, style: .continuous))

                    // Floating Dish Name & Badge
                    VStack(alignment: .leading, spacing: 4) {
                        if let dish = viewModel.activeFoodItem {
                            Text(dish.vietnameseName)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.6), radius: 4, x: 0, y: 2)

                            Text(dish.name)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.85))
                        }
                    }
                    .padding(AppSpacing.md)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.cardLarge, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

                // 2. AI Confidence Indicator Card
                if let dish = viewModel.activeFoodItem {
                    CardView(padding: AppSpacing.sm, cornerRadius: AppRadius.card) {
                        VStack(spacing: 8) {
                            HStack(spacing: AppSpacing.sm) {
                                AIConfidenceIndicator(confidence: dish.confidence)

                                Spacer()

                                Button {
                                    viewModel.isPresentingDishPicker = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 11, weight: .semibold))
                                        Text("Đổi món khác")
                                            .font(AppTypography.captionBold)
                                    }
                                    .foregroundColor(AppColors.forestGreen)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(AppColors.accentSage.opacity(0.2))
                                    .clipShape(Capsule())
                                }
                            }

                            Divider()

                            // Provenance disclosure
                            HStack {
                                Text("Nguồn mô hình:")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text(viewModel.activeEngineDescription)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(viewModel.isUsingFallbackEngine ? AppColors.carbAmber : AppColors.primaryGreen)
                            }
                        }
                    }

                    // Research-calibrated OOD warning (< 0.70)
                    if dish.confidence < 0.70 {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(AppColors.carbAmber)
                            Text("Độ tin cậy \(Int(dish.confidence * 100))% dưới ngưỡng chuẩn 70%. Vui lòng kiểm tra lại góc chụp hoặc chọn món từ gợi ý.")
                                .font(.system(size: 11.5, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(AppSpacing.sm)
                        .background(AppColors.carbAmber.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous))
                    }
                }

                // 3. Alternative Predictions (Top-2 & Top-3 Candidates)
                if !viewModel.alternativeCandidates.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gợi ý tương tự khác:")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.white.opacity(0.85))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(viewModel.alternativeCandidates) { candidate in
                                    Button {
                                        viewModel.selectAlternativeCandidate(candidate)
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.triangle.swap")
                                                .font(.system(size: 10))
                                                .foregroundColor(AppColors.accentSage)

                                            VStack(alignment: .leading, spacing: 1) {
                                                Text(candidate.item.vietnameseName)
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(AppColors.textPrimary)

                                                Text("\(Int(candidate.item.confidence * 100))% phù hợp")
                                                    .font(.system(size: 10, weight: .medium))
                                                    .foregroundColor(AppColors.textSecondary)
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous))
                                        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }

                // 4. Action Buttons Dock
                VStack(spacing: AppSpacing.sm) {
                    PrimaryButton("Tiếp tục: Xem & Chỉnh Dinh Dưỡng", icon: "arrow.right.circle.fill") {
                        viewModel.proceedToNutritionReview()
                    }

                    SecondaryButton("Chụp lại ảnh khác", icon: "camera.viewfinder") {
                        viewModel.retake()
                    }
                }
                .padding(.top, AppSpacing.sm)

                // Mandatory Transparent AI Disclaimer per GEMINI.md
                Text("Độ tin cậy AI phản ánh kết quả phân loại hình ảnh on-device. Giá trị dinh dưỡng sẽ được chuẩn hóa theo khẩu phần tại bước tiếp theo.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, 130)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
        }
    }

    // MARK: - 4. NUTRITION REVIEW & MEAL CONFIRMATION VIEW

    private var nutritionReviewView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppSpacing.md) {
                // Top Navigation Bar
                HStack {
                    Button {
                        viewModel.returnToRecognitionResult()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Quay lại")
                        }
                        .font(AppTypography.captionBold)
                        .foregroundColor(AppColors.accentSage)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                    }

                    Spacer()

                    Text("Xác nhận dinh dưỡng")
                        .font(AppTypography.subheadlineBold)
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear.frame(width: 70, height: 32)
                }
                .padding(.top, 54)

                // Dish summary compact pill
                if let dish = viewModel.scaledFoodItem ?? viewModel.activeFoodItem {
                    HStack(spacing: AppSpacing.sm) {
                        if let image = viewModel.capturedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(dish.vietnameseName)
                                .font(AppTypography.cardTitle)
                                .foregroundColor(AppColors.textPrimary)

                            Text(dish.name)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Spacer()

                        Button {
                            viewModel.isPresentingDishPicker = true
                        } label: {
                            Text("Đổi món")
                                .font(AppTypography.captionBold)
                                .foregroundColor(AppColors.primaryAction)
                        }
                    }
                    .padding(AppSpacing.sm)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))

                    // 1. Interactive Portion Size Adjuster
                    CardView(padding: AppSpacing.md, cornerRadius: AppRadius.card) {
                        VStack(spacing: AppSpacing.sm) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Khẩu phần ăn")
                                        .font(AppTypography.cardTitle)
                                        .foregroundColor(AppColors.textPrimary)
                                    Text("Điều chỉnh trọng lượng theo bữa ăn thực tế")
                                        .font(AppTypography.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }

                                Spacer()

                                HStack(spacing: AppSpacing.xs) {
                                    IconButton("minus", size: 36) {
                                        viewModel.adjustServing(delta: -50)
                                    }

                                    Text("\(Int(viewModel.servingSizeGrams))g")
                                        .font(AppTypography.nutritionValueSmall)
                                        .foregroundColor(AppColors.textPrimary)
                                        .frame(minWidth: 54)

                                    IconButton("plus", size: 36) {
                                        viewModel.adjustServing(delta: 50)
                                    }
                                }
                            }

                            // Quick preset weight chips
                            HStack(spacing: AppSpacing.xs) {
                                PortionChip(label: "Nhẹ (300g)", targetGrams: 300, currentGrams: viewModel.servingSizeGrams) {
                                    viewModel.setServingGrams(300)
                                }
                                PortionChip(label: "Chuẩn (450g)", targetGrams: 450, currentGrams: viewModel.servingSizeGrams) {
                                    viewModel.setServingGrams(450)
                                }
                                PortionChip(label: "Đầy đặn (600g)", targetGrams: 600, currentGrams: viewModel.servingSizeGrams) {
                                    viewModel.setServingGrams(600)
                                }
                            }
                        }
                    }

                    // 2. Calorie Energy Hero Card
                    CardView(padding: AppSpacing.md, cornerRadius: AppRadius.card) {
                        HStack(spacing: AppSpacing.md) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.calorieGold.opacity(0.18))
                                    .frame(width: 56, height: 56)

                                Image(systemName: "flame.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(AppColors.calorieGold)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Năng lượng ước tính")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)

                                HStack(alignment: .lastTextBaseline, spacing: 4) {
                                    Text("\(Int(dish.calories))")
                                        .font(AppTypography.nutritionValueLarge)
                                        .foregroundColor(AppColors.textPrimary)

                                    Text("kcal")
                                        .font(AppTypography.subheadline)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Theo \(Int(viewModel.servingSizeGrams))g")
                                    .font(AppTypography.captionBold)
                                    .foregroundColor(AppColors.textPrimary)
                                Text("khẩu phần")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                    }

                    // 3. Macronutrients Grid
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Dinh dưỡng chính")
                            .font(AppTypography.sectionTitle)
                            .foregroundColor(.white)

                        HStack(spacing: AppSpacing.sm) {
                            NutrientCard(
                                title: "Chất đạm",
                                value: String(format: "%.1fg", dish.proteinGrams),
                                icon: "bolt.fill",
                                color: AppColors.proteinOcean
                            )
                            NutrientCard(
                                title: "Tinh bột",
                                value: String(format: "%.1fg", dish.carbGrams),
                                icon: "leaf.fill",
                                color: AppColors.carbAmber
                            )
                            NutrientCard(
                                title: "Chất béo",
                                value: String(format: "%.1fg", dish.fatGrams),
                                icon: "drop.fill",
                                color: AppColors.fatCoral
                            )
                        }

                        HStack(spacing: AppSpacing.sm) {
                            NutrientCard(
                                title: "Chất xơ",
                                value: String(format: "%.1fg", dish.fiberGrams),
                                icon: "chart.bar.doc.horizontal",
                                color: AppColors.forestGreen
                            )
                        }
                    }

                    // 4. Meal Category Picker (Sáng, Trưa, Tối, Phụ)
                    CardView(padding: AppSpacing.md, cornerRadius: AppRadius.card) {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Bữa ăn")
                                .font(AppTypography.cardTitle)
                                .foregroundColor(AppColors.textPrimary)

                            HStack(spacing: 8) {
                                ForEach(MealType.allCases, id: \.self) { type in
                                    let isSelected = viewModel.selectedMealType == type
                                    Button {
                                        viewModel.setMealType(type)
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: type.systemIcon)
                                                .font(.system(size: 11))
                                            Text(typeVN(type))
                                                .font(AppTypography.captionBold)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(isSelected ? AppColors.forestGreen : AppColors.surfaceSecondary)
                                        .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // 5. Meal Notes (Optional)
                    CardView(padding: AppSpacing.sm, cornerRadius: AppRadius.card) {
                        HStack(spacing: 8) {
                            Image(systemName: "note.text")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)

                            TextField("Ghi chú (vd: ít dầu mỡ, ăn tại quán...)", text: $viewModel.mealNotes)
                                .font(AppTypography.subheadline)
                        }
                        .padding(4)
                    }

                    // 6. Action Button Dock
                    VStack(spacing: AppSpacing.sm) {
                        PrimaryButton("Lưu vào nhật ký bữa ăn", icon: "checkmark.circle.fill") {
                            Task {
                                do {
                                    let record = try await viewModel.confirmAndSave()
                                    // Allow user to see the success checkmark screen briefly before transitioning
                                    try? await Task.sleep(nanoseconds: 1_200_000_000)
                                    onMealSaved?(record)
                                } catch {
                                    // Handle save error
                                }
                            }
                        }

                        SecondaryButton("Quay lại", icon: "arrow.left") {
                            viewModel.returnToRecognitionResult()
                        }
                    }
                    .padding(.top, AppSpacing.xs)

                    // Provenance Footnote
                    Text("Nguồn dinh dưỡng: Bảng Thành Phần Thực Phẩm Việt Nam (Viện Dinh Dưỡng Quốc Gia - Bộ Y Tế).")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.bottom, 130)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
        }
    }

    // MARK: - 5. SAVING & SUCCESS VIEWS

    private var savingView: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentSage))
                .scaleEffect(1.3)

            Text("Đang lưu bữa ăn vào Nhật ký...")
                .font(AppTypography.headline)
                .foregroundColor(.white)
        }
    }

    private func saveSuccessView(record: MealRecord) -> some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppColors.forestGreen.opacity(0.2))
                    .frame(width: 110, height: 110)

                Circle()
                    .fill(AppColors.forestGreen)
                    .frame(width: 80, height: 80)
                    .shadow(color: AppColors.forestGreen.opacity(0.5), radius: 12, x: 0, y: 4)

                Image(systemName: "checkmark")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 8) {
                Text("Đã ghi nhận bữa ăn!")
                    .font(AppTypography.screenTitle)
                    .foregroundColor(.white)

                if let primary = record.items.first {
                    Text("\(primary.vietnameseName) • \(Int(record.totalCalories)) kcal")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.accentSage)
                }

                Text("Dữ liệu dinh dưỡng trong ngày đã được cập nhật.")
                    .font(AppTypography.subheadline)
                    .foregroundColor(Color.white.opacity(0.75))
            }

            Spacer()

            VStack(spacing: AppSpacing.sm) {
                PrimaryButton("Xem trong Nhật ký bữa ăn", icon: "book.pages.fill") {
                    onMealSaved?(record)
                }

                SecondaryButton("Quét thêm món khác", icon: "camera.viewfinder") {
                    viewModel.reset()
                }
            }
            .padding(.bottom, 110)
        }
        .padding(.top, 54)
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }

    // MARK: - 6. ERROR VIEW

    private func errorView(error: AppError) -> some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 54))
                .foregroundColor(AppColors.carbAmber)

            Text("Không thể nhận diện món ăn")
                .font(AppTypography.headlineBold)
                .foregroundColor(.white)

            Text(error.localizedDescription)
                .font(AppTypography.subheadline)
                .foregroundColor(Color.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.md)

            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.accentSage)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.md)
            }

            Spacer()

            VStack(spacing: AppSpacing.sm) {
                PrimaryButton("Thử lại", icon: "arrow.counterclockwise") {
                    viewModel.reset()
                }

                SecondaryButton("Tìm kiếm món ăn thủ công", icon: "magnifyingglass") {
                    viewModel.reset()
                    viewModel.isPresentingDishPicker = true
                }
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }

    // MARK: - 7. DISH PICKER SEARCH SHEET

    private var dishPickerSheet: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.textSecondary)
                    TextField("Tìm món ăn Việt Nam...", text: $viewModel.dishSearchQuery)
                        .font(AppTypography.subheadline)
                    if !viewModel.dishSearchQuery.isEmpty {
                        Button {
                            viewModel.dishSearchQuery = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppColors.textTertiary)
                        }
                    }
                }
                .padding(10)
                .background(AppColors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous))
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, 8)

                // Dishes list
                List {
                    ForEach(viewModel.searchResults) { dish in
                        Button {
                            viewModel.selectCustomDish(dish)
                            if viewModel.currentStep == .camera {
                                viewModel.proceedToNutritionReview()
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(dish.vietnameseName)
                                        .font(AppTypography.cardTitle)
                                        .foregroundColor(AppColors.textPrimary)

                                    Text("\(dish.name) • \(Int(dish.servingSizeGrams))g • \(Int(dish.calories)) kcal")
                                        .font(AppTypography.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Chọn món ăn")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        viewModel.isPresentingDishPicker = false
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func typeVN(_ type: MealType) -> String {
        switch type {
        case .breakfast: return "Sáng"
        case .lunch: return "Trưa"
        case .dinner: return "Tối"
        case .snack: return "Phụ"
        }
    }
}

// MARK: - Reticle 4 Corner Brackets Shape
private struct ReticleCornerBrackets: Shape {
    var bracketLength: CGFloat = 32
    var cornerRadius: CGFloat = 18

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Top-Left ┌
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + bracketLength))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.minX + bracketLength, y: rect.minY))

        // Top-Right ┐
        path.move(to: CGPoint(x: rect.maxX - bracketLength, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + bracketLength))

        // Bottom-Right ┘
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - bracketLength))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - bracketLength, y: rect.maxY))

        // Bottom-Left └
        path.move(to: CGPoint(x: rect.minX + bracketLength, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - bracketLength))

        return path
    }
}

// MARK: - Portion Preset Chip Component
private struct PortionChip: View {
    let label: String
    let targetGrams: Double
    let currentGrams: Double
    let action: () -> Void

    private var isSelected: Bool {
        abs(currentGrams - targetGrams) < 5
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(AppTypography.captionBold)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? AppColors.forestGreen : AppColors.surfaceSecondary)
                .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(isSelected ? Color.clear : AppColors.borderSubtle, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Nutrient Card Component
private struct NutrientCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        CardView(padding: AppSpacing.sm, cornerRadius: AppRadius.card) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(color)
                    Text(title)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Text(value)
                    .font(AppTypography.cardTitle)
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
