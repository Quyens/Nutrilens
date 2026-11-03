//
//  FoodRecognitionViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Coordinates the end-to-end AI Food Recognition flow:
//  Camera/Picker -> AI Inference -> Result Review -> Nutrition Confirmation -> SwiftData Persistence.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public enum FoodRecognitionStep: Equatable {
    case camera
    case analyzing(stage: String)
    case recognitionResult
    case nutritionReview
    case saving
    case saveSuccess(MealRecord)
    case error(AppError)

    public static func == (lhs: FoodRecognitionStep, rhs: FoodRecognitionStep) -> Bool {
        switch (lhs, rhs) {
        case (.camera, .camera),
             (.recognitionResult, .recognitionResult),
             (.nutritionReview, .nutritionReview),
             (.saving, .saving):
            return true
        case (.analyzing(let a), .analyzing(let b)):
            return a == b
        case (.saveSuccess(let a), .saveSuccess(let b)):
            return a.id == b.id
        case (.error(let a), .error(let b)):
            return a.localizedDescription == b.localizedDescription
        default:
            return false
        }
    }
}

@MainActor
public final class FoodRecognitionViewModel: ObservableObject {
    // Flow state
    @Published public private(set) var currentStep: FoodRecognitionStep = .camera
    @Published public private(set) var capturedImage: UIImage?
    @Published public private(set) var capturedImageData: Data?
    @Published public private(set) var recognitionResult: RecognitionResult?
    @Published public private(set) var activeFoodItem: FoodItem?
    @Published public private(set) var alternativeCandidates: [DetectedFoodCandidate] = []

    // Nutrition & Meal adjustments
    @Published public var servingSizeGrams: Double = 400 {
        didSet {
            if let active = activeFoodItem {
                scaledFoodItem = active.scaled(to: servingSizeGrams)
            }
        }
    }
    @Published public private(set) var scaledFoodItem: FoodItem?
    @Published public var selectedMealType: MealType = .lunch
    @Published public var mealNotes: String = ""

    // Manual dish search & correction sheet
    @Published public var isPresentingDishPicker: Bool = false
    @Published public var dishSearchQuery: String = "" {
        didSet {
            searchResults = VietnameseNutritionDatabase.search(query: dishSearchQuery)
        }
    }
    @Published public private(set) var searchResults: [FoodItem] = []

    // Model provenance & engine transparency
    public var isUsingFallbackEngine: Bool {
        guard let res = recognitionResult else { return true }
        return res.inferenceEngineName.contains("Fallback") || res.inferenceEngineName.contains("Apple Vision")
    }

    public var activeEngineDescription: String {
        recognitionResult?.inferenceEngineName ?? "Apple Vision Fallback (Experimental)"
    }

    public var activeModelVersion: String {
        recognitionResult?.modelVersion ?? "Pending Core ML Integration"
    }

    // Dependencies
    private let recognizeFoodUseCase: RecognizeFoodUseCaseProtocol
    private let logMealUseCase: LogMealUseCaseProtocol?

    public init(
        recognizeFoodUseCase: RecognizeFoodUseCaseProtocol,
        logMealUseCase: LogMealUseCaseProtocol? = nil
    ) {
        self.recognizeFoodUseCase = recognizeFoodUseCase
        self.logMealUseCase = logMealUseCase
        self.selectedMealType = Self.defaultMealTypeForCurrentTime()
        self.searchResults = VietnameseNutritionDatabase.search(query: "")
    }

    // MARK: - Flow Actions

    public func analyzeImage(data: Data, uiImage: UIImage? = nil) async {
        guard !data.isEmpty else {
            currentStep = .error(.invalidInput("Dữ liệu hình ảnh trống. Vui lòng thử lại."))
            return
        }

        self.capturedImageData = data
        self.capturedImage = uiImage ?? UIImage(data: data)

        // Stage 1: Preprocessing & Neural Inference
        currentStep = .analyzing(stage: "Đang phân tích hình ảnh...")

        do {
            try await Task.sleep(nanoseconds: 200_000_000) // Brief smooth transition for UX
            currentStep = .analyzing(stage: "Nhận diện món ăn bằng Core ML...")

            let result = try await recognizeFoodUseCase.execute(imageData: data)
            self.recognitionResult = result

            guard let primary = result.primaryFood else {
                throw AppError.outOfDistribution
            }

            self.activeFoodItem = primary
            self.servingSizeGrams = primary.servingSizeGrams
            self.scaledFoodItem = primary.scaled(to: primary.servingSizeGrams)

            // Setup alternative candidates (excluding primary)
            self.alternativeCandidates = result.candidates.filter { $0.item.name != primary.name }

            currentStep = .analyzing(stage: "Hoàn tất tra cứu dinh dưỡng...")
            try await Task.sleep(nanoseconds: 150_000_000)

            self.currentStep = .recognitionResult

        } catch let err as AppError {
            self.currentStep = .error(err)
        } catch {
            self.currentStep = .error(.unknown(error.localizedDescription))
        }
    }

    /// Select one of the quick Vietnamese sample dishes (great for simulator testing)
    public func selectSampleDish(_ item: FoodItem, sampleImage: UIImage? = nil) async {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif

        let payload = Data("sample_\(item.vietnameseName)".utf8)
        self.capturedImageData = payload
        self.capturedImage = sampleImage ?? UIImage(named: "banner_salad")

        currentStep = .analyzing(stage: "Mô phỏng quét món: \(item.vietnameseName)...")
        try? await Task.sleep(nanoseconds: 300_000_000)

        self.activeFoodItem = item
        self.servingSizeGrams = item.servingSizeGrams
        self.scaledFoodItem = item.scaled(to: item.servingSizeGrams)

        // Provide realistic alternative dishes
        let others = VietnameseNutritionDatabase.dishes
            .filter { $0.vietnameseName != item.vietnameseName }
            .prefix(2)
            .map { DetectedFoodCandidate(item: $0.toFoodItem(confidence: 0.28)) }

        self.alternativeCandidates = Array(others)
        self.recognitionResult = RecognitionResult(
            candidates: [DetectedFoodCandidate(item: item)] + others,
            isOutOfDistribution: false,
            inferenceDurationSeconds: 0.12,
            modelVersion: "Sample Simulator Preset",
            inferenceEngineName: "Simulator Sample Mode"
        )

        self.currentStep = .recognitionResult
    }

    /// Switch active dish to one of the alternative candidates
    public func selectAlternativeCandidate(_ candidate: DetectedFoodCandidate) {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif

        guard let currentPrimary = activeFoodItem else { return }

        // Swap primary and candidate
        let previous = currentPrimary
        self.activeFoodItem = candidate.item
        self.servingSizeGrams = candidate.item.servingSizeGrams
        self.scaledFoodItem = candidate.item.scaled(to: candidate.item.servingSizeGrams)

        var updatedAlternatives = alternativeCandidates.filter { $0.item.name != candidate.item.name }
        updatedAlternatives.insert(DetectedFoodCandidate(item: previous), at: 0)
        self.alternativeCandidates = updatedAlternatives
    }

    /// Update dish to a manually selected dish from search
    public func selectCustomDish(_ item: FoodItem) {
        self.activeFoodItem = item
        self.servingSizeGrams = item.servingSizeGrams
        self.scaledFoodItem = item.scaled(to: item.servingSizeGrams)
        self.isPresentingDishPicker = false
    }

    public func proceedToNutritionReview() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        self.currentStep = .nutritionReview
    }

    public func returnToRecognitionResult() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        self.currentStep = .recognitionResult
    }

    public func adjustServing(delta: Double) {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        let updated = max(50, servingSizeGrams + delta)
        self.servingSizeGrams = updated
    }

    public func setServingGrams(_ grams: Double) {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        self.servingSizeGrams = max(50, grams)
    }

    public func setMealType(_ type: MealType) {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        self.selectedMealType = type
    }

    public func confirmAndSave() async throws -> MealRecord {
        guard let finalItem = scaledFoodItem ?? activeFoodItem else {
            throw AppError.invalidInput("Không có thông tin món ăn hợp lệ để lưu.")
        }

        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        #endif

        self.currentStep = .saving

        let record = MealRecord(
            mealType: selectedMealType,
            items: [finalItem],
            notes: mealNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : mealNotes
        )

        if let logMealUseCase {
            try await logMealUseCase.execute(meal: record)
        }

        self.currentStep = .saveSuccess(record)
        return record
    }

    public func retake() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        reset()
    }

    public func reset() {
        currentStep = .camera
        capturedImage = nil
        capturedImageData = nil
        recognitionResult = nil
        activeFoodItem = nil
        scaledFoodItem = nil
        alternativeCandidates = []
        servingSizeGrams = 400
        mealNotes = ""
        isPresentingDishPicker = false
        selectedMealType = Self.defaultMealTypeForCurrentTime()
    }

    // MARK: - Helpers

    public static func defaultMealTypeForCurrentTime() -> MealType {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<11:
            return .breakfast
        case 11..<15:
            return .lunch
        case 15..<18:
            return .snack
        case 18..<23:
            return .dinner
        default:
            return .snack
        }
    }
}
