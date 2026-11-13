//
//  BarcodeValue.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Validates, cleans, and normalizes standard retail barcodes (EAN-13, EAN-8, UPC-A, UPC-E).
//

import Foundation

public struct BarcodeValue: Equatable, Hashable, Codable, Sendable {
    public let rawValue: String
    public let normalizedValue: String
    public let type: BarcodeType
    public let isValid: Bool
    public let validationError: String?

    public init(rawValue: String) {
        self.rawValue = rawValue

        // 1. Clean whitespace, hyphens, and invisible control characters
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleaned = trimmed.filter { $0.isLetter || $0.isNumber }

        guard !cleaned.isEmpty else {
            self.normalizedValue = ""
            self.type = .other
            self.isValid = false
            self.validationError = "Mã vạch không được để trống"
            return
        }

        // 2. Infer Type & Normalize (e.g. UPC-A 12 digits -> EAN-13 13 digits with leading zero)
        let isAllDigits = cleaned.allSatisfy { $0.isNumber }

        if isAllDigits {
            switch cleaned.count {
            case 13:
                self.type = .ean13
                self.normalizedValue = cleaned
                if Self.validateEAN13CheckDigit(cleaned) {
                    self.isValid = true
                    self.validationError = nil
                } else {
                    self.isValid = false
                    self.validationError = "Sai số kiểm tra (Check digit) chuẩn EAN-13"
                }

            case 12:
                // UPC-A: canonical GTIN-13 is formed by prepending '0'
                let eanEquivalent = "0" + cleaned
                self.type = .upcA
                self.normalizedValue = eanEquivalent
                if Self.validateEAN13CheckDigit(eanEquivalent) {
                    self.isValid = true
                    self.validationError = nil
                } else {
                    self.isValid = false
                    self.validationError = "Sai số kiểm tra (Check digit) chuẩn UPC-A"
                }

            case 8:
                self.type = .ean8
                self.normalizedValue = cleaned
                if Self.validateEAN8CheckDigit(cleaned) {
                    self.isValid = true
                    self.validationError = nil
                } else {
                    self.isValid = false
                    self.validationError = "Sai số kiểm tra (Check digit) chuẩn EAN-8"
                }

            default:
                // Other numeric barcode lengths (e.g., internal Code 128 / Code 39)
                self.type = .code128
                self.normalizedValue = cleaned
                self.isValid = cleaned.count >= 3 && cleaned.count <= 48
                self.validationError = self.isValid ? nil : "Độ dài mã vạch không hợp lệ (\(cleaned.count) ký tự)"
            }
        } else {
            // Alphanumeric barcode (Code 128)
            self.type = .code128
            self.normalizedValue = cleaned
            self.isValid = cleaned.count >= 3 && cleaned.count <= 48
            self.validationError = self.isValid ? nil : "Mã vạch ký tự không hợp lệ (\(cleaned.count) ký tự)"
        }
    }

    // MARK: - GS1 Modulo-10 Check Digit Validators

    /// Validates EAN-13 (and 13-digit zero-prefixed UPC-A) checksum
    public static func validateEAN13CheckDigit(_ code: String) -> Bool {
        guard code.count == 13, code.allSatisfy({ $0.isNumber }) else { return false }
        let digits = code.compactMap { $0.wholeNumberValue }
        guard digits.count == 13 else { return false }

        // Sum positions 1-12 with weights alternating 1 and 3 (from left: weights 1, 3, 1, 3...)
        var sum = 0
        for i in 0..<12 {
            let weight = (i % 2 == 0) ? 1 : 3
            sum += digits[i] * weight
        }
        let remainder = sum % 10
        let expectedCheck = (remainder == 0) ? 0 : (10 - remainder)
        return digits[12] == expectedCheck
    }

    /// Validates EAN-8 checksum
    public static func validateEAN8CheckDigit(_ code: String) -> Bool {
        guard code.count == 8, code.allSatisfy({ $0.isNumber }) else { return false }
        let digits = code.compactMap { $0.wholeNumberValue }
        guard digits.count == 8 else { return false }

        // For 8 digits: weights alternating 3 and 1 (from left: weights 3, 1, 3, 1...)
        var sum = 0
        for i in 0..<7 {
            let weight = (i % 2 == 0) ? 3 : 1
            sum += digits[i] * weight
        }
        let remainder = sum % 10
        let expectedCheck = (remainder == 0) ? 0 : (10 - remainder)
        return digits[7] == expectedCheck
    }
}

