//
//  BarcodeScannerViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Presentation logic for barcode scanning, product lookup, allergen conflict checking,
//  and logging into Meal Diary.
//

import Foundation
import SwiftUI
import Combine

@MainActor
public final class BarcodeScannerViewModel: ObservableObject {
    // MARK: - Dependencies
    private let lookupUseCase: LookupBarcodeUseCase
    private let saveUseCase: SavePackagedFoodUseCase
    private let deleteUseCase: DeletePackagedFoodUseCase
    private let getFoodsUseCase: GetPackagedFoodsUseCase
    private let logDiaryUseCase: LogPackagedFoodToDiaryUseCase
    private let userProfileRepository: UserDietaryProfileRepositoryProtocol?
    private let safetyService: PackagedFoodSafetyService
    public let captureService: BarcodeCaptureServiceProtocol

    // MARK: - Published State
    @Published public var isScanning: Bool = false
    @Published public var isTorchOn: Bool = false
    @Published public var hasTorch: Bool = false
    @Published public var permissionState: CameraPermissionState = .notDetermined

    // Current Scanned / Selected Product
    @Published public var activeProduct: PackagedFood?
    @Published public var activeLookupSource: LookupSource?
    @Published public var activeSafetyEvaluation: FoodSafetyEvaluation?
    @Published public var servingMultiplier: Double = 1.0
    @Published public var selectedMealType: MealType = .snack
    @Published public var selectedLogDate: Date = Date()

    // Sheets & Dialogs
    @Published public var showResultSheet: Bool = false
    @Published public var showUnknownSheet: Bool = false
    @Published public var showManualEntrySheet: Bool = false
    @Published public var showCreateEditSheet: Bool = false
    @Published public var showLibrarySheet: Bool = false
    @Published public var showDetailSheet: Bool = false
    @Published public var productToEdit: PackagedFood?

    // Unknown Barcode Workflow
    @Published public var unknownBarcodeNumber: String = ""

    // Library State
    @Published public var libraryFoods: [PackagedFood] = []
    @Published public var librarySearchQuery: String = ""
    @Published public var selectedLibraryFilter: LibraryFilter = .all

    // Feedback & Loading
    @Published public var isLoading: Bool = false
    @Published public var statusMessage: String?
    @Published public var errorMessage: String?
    @Published public var toastMessage: String?

    // Profile Cache
    public var currentUserProfile: UserDietaryProfile?

    public enum LibraryFilter: String, CaseIterable, Identifiable {
        case all = "Tất cả"
        case saved = "Đã lưu"
        case recent = "Gần đây"
        case favorites = "Yêu thích"
        public var id: String { rawValue }
    }

    public init(
        lookupUseCase: LookupBarcodeUseCase,
        saveUseCase: SavePackagedFoodUseCase,
        deleteUseCase: DeletePackagedFoodUseCase,
        getFoodsUseCase: GetPackagedFoodsUseCase,
        logDiaryUseCase: LogPackagedFoodToDiaryUseCase,
        userProfileRepository: UserDietaryProfileRepositoryProtocol? = nil,
        safetyService: PackagedFoodSafetyService = .shared,
        captureService: BarcodeCaptureServiceProtocol? = nil
    ) {
        self.lookupUseCase = lookupUseCase
        self.saveUseCase = saveUseCase
        self.deleteUseCase = deleteUseCase
        self.getFoodsUseCase = getFoodsUseCase
        self.logDiaryUseCase = logDiaryUseCase
        self.userProfileRepository = userProfileRepository
        self.safetyService = safetyService
        self.captureService = captureService ?? BarcodeCaptureService()

        setupCaptureService()
        loadUserProfile()
    }

    private func setupCaptureService() {
        self.permissionState = captureService.permissionState
        self.hasTorch = captureService.hasTorch
        self.isTorchOn = captureService.isTorchOn

        captureService.setBarcodeHandler { [weak self] rawCode, barcodeType in
            guard let self = self else { return }
            self.handleDetectedBarcode(rawCode: rawCode)
        }
    }

    public func onAppear() {
        captureService.checkPermission()
        permissionState = captureService.permissionState
        hasTorch = captureService.hasTorch
        if permissionState == .authorized {
            startScanning()
        }
        loadUserProfile()
    }

    public func onDisappear() {
        stopScanning()
    }

    public func requestCameraPermission() async {
        let granted = await captureService.requestPermission()
        permissionState = captureService.permissionState
        if granted {
            startScanning()
        }
    }

    public func startScanning() {
        captureService.startScanning()
        isScanning = true
    }

    public func stopScanning() {
        captureService.stopScanning()
        isScanning = false
        isTorchOn = false
    }

    public func toggleTorch() {
        captureService.toggleTorch()
        isTorchOn = captureService.isTorchOn
    }

    // MARK: - Barcode Detection & Lookup Flow
    public func handleDetectedBarcode(rawCode: String) {
        guard !isLoading else { return }
        stopScanning()
        HapticFeedbackService.shared.success()

        Task {
            await lookupBarcode(code: rawCode)
        }
    }

    public func lookupBarcode(code: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await lookupUseCase.execute(barcode: code)
            isLoading = false

            switch result {
            case let .found(food, source):
                self.activeProduct = food
                self.activeLookupSource = source
                self.servingMultiplier = 1.0
                self.evaluateSafety(for: food)
                self.showResultSheet = true
                self.showUnknownSheet = false

            case let .notFound(barcodeVal):
                self.unknownBarcodeNumber = barcodeVal.normalizedValue.isEmpty ? code : barcodeVal.normalizedValue
                self.activeProduct = nil
                self.showUnknownSheet = true
                self.showResultSheet = false

            case let .invalid(rawBarcode, reason):
                self.errorMessage = "\(reason) (\(rawBarcode))"
                self.resumeScanning()
            }
        } catch {
            isLoading = false
            self.errorMessage = "Lỗi khi tra cứu mã vạch: \(error.localizedDescription)"
            self.resumeScanning()
        }
    }

    public func evaluateSafety(for food: PackagedFood) {
        activeSafetyEvaluation = safetyService.evaluate(food: food, userProfile: currentUserProfile)
    }

    public func loadUserProfile() {
        guard let userProfileRepository else { return }
        Task {
            do {
                self.currentUserProfile = try await userProfileRepository.getDietaryProfile()
                if let activeProduct {
                    evaluateSafety(for: activeProduct)
                }
            } catch {
                AppLogger.data.error("Failed to load user dietary profile: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Log to Meal Diary
    public func logCurrentProductToDiary() async -> Bool {
        guard let product = activeProduct else { return false }
        isLoading = true
        do {
            _ = try await logDiaryUseCase.execute(
                packagedFood: product,
                portionMultiplier: servingMultiplier,
                mealType: selectedMealType,
                timestamp: selectedLogDate
            )
            isLoading = false
            showResultSheet = false
            HapticFeedbackService.shared.success()
            toastMessage = "Đã ghi '\(product.fullDisplayTitle)' vào nhật ký bữa ăn!"
            resumeScanning()
            return true
        } catch {
            isLoading = false
            errorMessage = "Không thể ghi nhật ký: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Save Product Locally
    public func saveProductToLibrary(_ food: PackagedFood) async -> Bool {
        isLoading = true
        do {
            try await saveUseCase.execute(food)
            isLoading = false
            toastMessage = "Đã lưu '\(food.productName)' vào kho cá nhân!"
            HapticFeedbackService.shared.success()
            await loadLibrary()
            if activeProduct?.id == food.id {
                activeProduct = food
                activeLookupSource = .userLibrary
            }
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Delete Product
    public func deleteProduct(id: UUID) async {
        isLoading = true
        do {
            try await deleteUseCase.execute(id: id)
            isLoading = false
            toastMessage = "Đã xóa sản phẩm khỏi kho cá nhân"
            await loadLibrary()
            if activeProduct?.id == id {
                showResultSheet = false
                showDetailSheet = false
                activeProduct = nil
            }
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Toggle Favorite
    public func toggleFavorite(id: UUID) async {
        do {
            _ = try await getFoodsUseCase.executeToggleFavorite(id: id)
            await loadLibrary()
            if let active = activeProduct, active.id == id {
                activeProduct?.isFavorite.toggle()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Library Operations
    public func loadLibrary() async {
        do {
            switch selectedLibraryFilter {
            case .all:
                libraryFoods = try await getFoodsUseCase.executeSearch(query: librarySearchQuery)
            case .saved:
                let all = try await getFoodsUseCase.executeAll()
                if librarySearchQuery.isEmpty {
                    libraryFoods = all
                } else {
                    libraryFoods = all.filter { $0.productName.localizedCaseInsensitiveContains(librarySearchQuery) }
                }
            case .recent:
                libraryFoods = try await getFoodsUseCase.executeRecentScans(limit: 20)
            case .favorites:
                let all = try await getFoodsUseCase.executeAll()
                let favs = all.filter { $0.isFavorite }
                libraryFoods = favs
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func resumeScanning() {
        if permissionState == .authorized {
            startScanning()
        }
    }
}
