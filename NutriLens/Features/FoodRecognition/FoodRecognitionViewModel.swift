//
//  FoodRecognitionViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import SwiftUI

@MainActor
public final class FoodRecognitionViewModel: ObservableObject {
    @Published public private(set) var recognitionState: AsyncState<RecognitionResult> = .idle
    @Published public var isPresentingNutritionResult: Bool = false
    @Published public private(set) var selectedResult: RecognitionResult?
    @Published public var isSimulatingDemoScan: Bool = false

    private let recognizeFoodUseCase: RecognizeFoodUseCaseProtocol

    public init(recognizeFoodUseCase: RecognizeFoodUseCaseProtocol) {
        self.recognizeFoodUseCase = recognizeFoodUseCase
    }

    public func analyzeImage(data: Data) async {
        recognitionState = .loading
        do {
            let result = try await recognizeFoodUseCase.execute(imageData: data)
            self.selectedResult = result
            self.recognitionState = .success(result)
            self.isPresentingNutritionResult = true
        } catch let err as AppError {
            self.recognitionState = .failure(err)
        } catch {
            self.recognitionState = .failure(.unknown(error.localizedDescription))
        }
    }

    public func reset() {
        recognitionState = .idle
        selectedResult = nil
        isPresentingNutritionResult = false
    }
}
