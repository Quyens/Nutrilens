//
//  PackagedFoodRepositoryProtocol.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Boundary protocol for packaged food persistence and barcode lookup.
//

import Foundation

public protocol PackagedFoodRepositoryProtocol: Sendable {
    /// Look up a product by raw or normalized barcode string.
    /// Checks user's SwiftData library first, then falls back to bundled verified Vietnamese catalogue.
    func lookup(barcode: String) async throws -> BarcodeLookupResult

    /// Fetches all packaged foods in the user's library (SwiftData)
    func fetchAll() async throws -> [PackagedFood]

    /// Fetches a specific packaged food by UUID from user's library or bundled catalogue
    func fetchById(id: UUID) async throws -> PackagedFood?

    /// Fetches a specific packaged food by normalized barcode string
    func fetchByBarcode(barcode: String) async throws -> PackagedFood?

    /// Searches both user's library and catalogue by keyword (name, brand, barcode)
    func search(query: String) async throws -> [PackagedFood]

    /// Saves or inserts a new packaged food to SwiftData
    func save(_ food: PackagedFood) async throws

    /// Updates an existing packaged food in SwiftData
    func update(_ food: PackagedFood) async throws

    /// Deletes a packaged food by UUID from SwiftData
    func delete(id: UUID) async throws

    /// Toggles favorite status for a packaged food and returns new state
    func toggleFavorite(id: UUID) async throws -> Bool

    /// Records a scan timestamp for recent scans history
    func recordScan(barcode: String) async throws

    /// Fetches recent scans up to limit
    func fetchRecentScans(limit: Int) async throws -> [PackagedFood]
}

