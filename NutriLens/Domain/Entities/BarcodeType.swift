//
//  BarcodeType.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Represents supported 1D barcode symbologies for packaged foods.
//

import Foundation

public enum BarcodeType: String, CaseIterable, Codable, Hashable, Sendable {
    case ean13 = "EAN-13"
    case ean8 = "EAN-8"
    case upcA = "UPC-A"
    case upcE = "UPC-E"
    case code128 = "Code 128"
    case other = "Khác"

    public var displayName: String {
        rawValue
    }

    public var expectedLength: Int? {
        switch self {
        case .ean13: return 13
        case .ean8: return 8
        case .upcA: return 12
        case .upcE: return 8
        case .code128, .other: return nil
        }
    }
}

