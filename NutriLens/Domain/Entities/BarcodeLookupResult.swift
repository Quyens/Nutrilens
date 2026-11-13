//
//  BarcodeLookupResult.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Represents the typed result of a barcode lookup operation.
//

import Foundation

public enum LookupSource: String, Codable, Sendable, CaseIterable {
    case userLibrary = "Kho người dùng (SwiftData)"
    case bundledCatalogue = "Danh mục chuẩn Việt Nam"

    public var badgeTitle: String {
        switch self {
        case .userLibrary: return "Cá nhân"
        case .bundledCatalogue: return "Chính thức"
        }
    }
}

public enum BarcodeLookupResult: Equatable, Sendable {
    case found(PackagedFood, source: LookupSource)
    case notFound(barcode: BarcodeValue)
    case invalid(rawBarcode: String, reason: String)

    public var isFound: Bool {
        if case .found = self { return true }
        return false
    }

    public var food: PackagedFood? {
        if case let .found(food, _) = self { return food }
        return nil
    }
}

