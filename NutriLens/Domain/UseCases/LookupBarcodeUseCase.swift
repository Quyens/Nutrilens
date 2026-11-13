//
//  LookupBarcodeUseCase.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Executes clean barcode lookup checking user library before bundled catalogue.
//

import Foundation

public final class LookupBarcodeUseCase: Sendable {
    private let repository: PackagedFoodRepositoryProtocol

    public init(repository: PackagedFoodRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(barcode: String) async throws -> BarcodeLookupResult {
        try await repository.lookup(barcode: barcode)
    }
}

