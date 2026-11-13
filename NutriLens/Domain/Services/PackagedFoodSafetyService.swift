//
//  PackagedFoodSafetyService.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Evaluates packaged food ingredients & allergens against the user's dietary profile.
//  CRITICAL SAFETY: Never claims 100% allergen-free. Flags cross-contact & incomplete data.
//

import Foundation

public struct AllergenConflict: Equatable, Hashable, Identifiable, Sendable {
    public var id: String { allergen.rawValue }
    public let allergen: AllergenType
    public let reason: String
}

public struct FoodSafetyEvaluation: Equatable, Sendable {
    public let conflicts: [AllergenConflict]
    public let hasConflicts: Bool
    public let hasIncompleteData: Bool
    public let safetyNotice: String
    public let disclaimer: String

    public static let standardDisclaimer = "Lưu ý an toàn: Thông tin bao bì chỉ mang tính chất tham khảo dựa trên nhãn mác công bố của nhà sản xuất. Không thể loại trừ nguy cơ nhiễm chéo trong dây chuyền đóng gói. Người có cơ địa dị ứng nghiêm trọng cần kiểm tra kỹ trước khi dùng."
}

public final class PackagedFoodSafetyService: Sendable {
    public static let shared = PackagedFoodSafetyService()

    public init() {}

    public func evaluate(
        food: PackagedFood,
        userProfile: UserDietaryProfile?
    ) -> FoodSafetyEvaluation {
        guard let userProfile else {
            return FoodSafetyEvaluation(
                conflicts: [],
                hasConflicts: false,
                hasIncompleteData: food.verificationStatus != .verified,
                safetyNotice: food.verificationStatus == .verified ? "Chưa thiết lập hồ sơ dị ứng cá nhân" : "Chưa đủ thông tin thành phần để đối soát dị ứng",
                disclaimer: FoodSafetyEvaluation.standardDisclaimer
            )
        }

        var detectedConflicts: [AllergenConflict] = []

        // 1. Direct allergen matches
        let userAllergens = userProfile.declaredAllergens
        for allergen in food.allergens where userAllergens.contains(allergen) {
            detectedConflicts.append(
                AllergenConflict(
                    allergen: allergen,
                    reason: "Sản phẩm công bố có chứa thành phần: \(allergen.vietnameseName)"
                )
            )
        }

        // 2. Textual search in ingredientText for undeclared matches (e.g. "bột mì", "sữa bò", "tôm")
        let textLower = (food.ingredientText ?? food.ingredients.joined(separator: " ")).lowercased()
        for allergen in userAllergens where !detectedConflicts.contains(where: { $0.allergen == allergen }) {
            let matchedKeyword: String?
            switch allergen {
            case .peanuts:
                matchedKeyword = textLower.contains("đậu phộng") || textLower.contains("lạc") ? "đậu phộng/lạc" : nil
            case .shellfish:
                matchedKeyword = textLower.contains("tôm") || textLower.contains("cua") || textLower.contains("sò") ? "hải sản tôm/cua" : nil
            case .fish:
                matchedKeyword = textLower.contains("cá") || textLower.contains("nước mắm") ? "cá/nước mắm" : nil
            case .eggs:
                matchedKeyword = textLower.contains("trứng") ? "trứng" : nil
            case .milk:
                matchedKeyword = textLower.contains("sữa") || textLower.contains("bơ") || textLower.contains("phô mai") ? "sữa/chế phẩm sữa" : nil
            case .soy:
                matchedKeyword = textLower.contains("đậu nành") || textLower.contains("đậu hũ") || textLower.contains("tương") ? "đậu nành/đậu tương" : nil
            case .gluten:
                matchedKeyword = textLower.contains("bột mì") || textLower.contains("lúa mì") || textLower.contains("gluten") ? "bột mì/gluten" : nil
            case .sesame:
                matchedKeyword = textLower.contains("mè") || textLower.contains("vừng") ? "mè/vừng" : nil
            case .treeNuts:
                matchedKeyword = textLower.contains("hạt điều") || textLower.contains("hạnh nhân") || textLower.contains("óc chó") ? "hạt cây" : nil
            }

            if let kw = matchedKeyword {
                detectedConflicts.append(
                    AllergenConflict(
                        allergen: allergen,
                        reason: "Phát hiện từ khóa '\(kw)' trong danh sách thành phần"
                    )
                )
            }
        }

        // 3. Dietary preferences check (e.g. Vegetarian vs meat / fish / milk / eggs)
        let isVegetarian = userProfile.dietaryPreferences.contains(.vegetarian)

        if isVegetarian {
            if food.allergens.contains(.fish) || food.allergens.contains(.shellfish) || textLower.contains("thịt") || textLower.contains("tôm") || textLower.contains("cá") {
                let allg = food.allergens.contains(.shellfish) ? AllergenType.shellfish : AllergenType.fish
                if !detectedConflicts.contains(where: { $0.allergen == allg }) {
                    detectedConflicts.append(AllergenConflict(allergen: allg, reason: "Có chứa thành phần động vật/hải sản - không phù hợp chế độ Ăn chay"))
                }
            }
        }

        let hasIncomplete = food.verificationStatus == .unverified || food.verificationStatus == .partial || (food.ingredients.isEmpty && food.ingredientText == nil)

        let notice: String
        if !detectedConflicts.isEmpty {
            notice = "Cảnh báo dị ứng: Phát hiện \(detectedConflicts.count) thành phần xung đột với hồ sơ ăn kiêng của bạn!"
        } else if hasIncomplete {
            notice = "Chưa đủ thông tin thành phần để xác minh toàn bộ chất gây dị ứng."
        } else {
            notice = "Không phát hiện chất gây dị ứng nào trong hồ sơ của bạn trên nhãn mác công bố."
        }

        return FoodSafetyEvaluation(
            conflicts: detectedConflicts,
            hasConflicts: !detectedConflicts.isEmpty,
            hasIncompleteData: hasIncomplete,
            safetyNotice: notice,
            disclaimer: FoodSafetyEvaluation.standardDisclaimer
        )
    }
}
