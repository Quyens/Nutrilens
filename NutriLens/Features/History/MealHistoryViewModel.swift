//
//  MealHistoryViewModel.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import SwiftUI

@MainActor
public final class MealHistoryViewModel: ObservableObject {
    @Published public private(set) var state: AsyncState<[MealRecord]> = .idle
    @Published public var selectedFilter: MealType? = nil

    private let getMealHistoryUseCase: GetMealHistoryUseCaseProtocol

    public init(getMealHistoryUseCase: GetMealHistoryUseCaseProtocol) {
        self.getMealHistoryUseCase = getMealHistoryUseCase
    }

    public var filteredMeals: [MealRecord] {
        guard let list = state.value else { return [] }
        guard let filter = selectedFilter else { return list }
        return list.filter { $0.mealType == filter }
    }

    public func loadHistory() async {
        state = .loading
        do {
            let meals = try await getMealHistoryUseCase.execute()
            state = .success(meals)
        } catch let err as AppError {
            state = .failure(err)
        } catch {
            state = .failure(.unknown(error.localizedDescription))
        }
    }

    public func deleteMeal(id: UUID) async {
        do {
            try await getMealHistoryUseCase.delete(id: id)
            await loadHistory()
        } catch {
            // Log or handle deletion error
        }
    }
}
