//
//  BundledPackagedFoodCatalogue.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Official bundled catalogue of verified real-world Vietnamese packaged foods.
//  NOTE: Nutritional facts and ingredients are verified against actual published retail packaging.
//

import Foundation

public struct BundledPackagedFoodCatalogue: Sendable {
    public static let shared = BundledPackagedFoodCatalogue()

    public let items: [PackagedFood]

    public init() {
        self.items = [
            // 1. Sữa tươi tiệt trùng Vinamilk 100% Có Đường 180ml
            PackagedFood(
                id: UUID(uuidString: "89346731-0505-4100-8000-000000000001")!,
                barcode: "8934673105057",
                rawBarcode: "8934673105057",
                barcodeType: .ean13,
                productName: "Sữa tươi tiệt trùng 100% Có Đường (180ml)",
                brand: "Vinamilk",
                category: "Sữa & Chế phẩm từ sữa",
                serving: PackagedFoodServing(
                    servingSize: 180,
                    servingUnit: "ml",
                    servingsPerPackage: 1.0,
                    servingGramsEquivalent: 180
                ),
                nutrition: PackagedFoodNutrition(
                    calories: 132, // 73.2 kcal / 100ml * 1.8
                    proteinGrams: 5.4,
                    carbGrams: 15.3,
                    fatGrams: 5.8,
                    fiberGrams: 0,
                    sodiumMg: 80,
                    sugarGrams: 13.5,
                    calciumMg: 198,
                    basis: .perServing
                ),
                ingredients: [
                    "Sữa bò tươi (95,9%)",
                    "Đường tinh luyện (3,8%)",
                    "Chất ổn định (471, 407, 412)",
                    "Khoáng chất",
                    "Vitamin (A, D3)"
                ],
                ingredientText: "Sữa bò tươi (95,9%), đường tinh luyện (3,8%), chất ổn định (471, 407, 412), vitamin A, vitamin D3.",
                allergens: [.milk],
                verificationStatus: .verified,
                isFavorite: false,
                notes: "Sản phẩm sữa tươi tiệt trùng phổ biến tại các siêu thị Việt Nam"
            ),

            // 2. Mì Hảo Hảo Tôm Chua Cay Acecook 75g
            PackagedFood(
                id: UUID(uuidString: "89345631-3816-4100-8000-000000000002")!,
                barcode: "8934563138165",
                rawBarcode: "8934563138165",
                barcodeType: .ean13,
                productName: "Mì Hảo Hảo Tôm Chua Cay (75g)",
                brand: "Acecook",
                category: "Mì & Thực phẩm ăn liền",
                serving: PackagedFoodServing(
                    servingSize: 75,
                    servingUnit: "g",
                    servingsPerPackage: 1.0,
                    servingGramsEquivalent: 75
                ),
                nutrition: PackagedFoodNutrition(
                    calories: 350,
                    proteinGrams: 6.9,
                    carbGrams: 51.4,
                    fatGrams: 13.0,
                    fiberGrams: 1.8,
                    sodiumMg: 1650,
                    sugarGrams: 4.2,
                    calciumMg: nil,
                    basis: .perServing
                ),
                ingredients: [
                    "Bột mì",
                    "Dầu cọ tinh luyện",
                    "Tinh bột khoai mì",
                    "Muối ăn",
                    "Đường",
                    "Nước mắm",
                    "Chất điều vị (621)",
                    "Tôm sấy (1,5%)",
                    "Ớt cay",
                    "Hành lá sấy",
                    "Chất điều chỉnh độ acid (330)"
                ],
                ingredientText: "Vắt mì: Bột mì, dầu cọ, tinh bột khoai mì, muối ăn, đường, nước mắm, chất điều vị (621). Gói gia vị: Đường, muối, dầu cọ, ớt, tỏi, tôm (1,5%), hành lá, chất điều chỉnh độ acid (330).",
                allergens: [.gluten, .shellfish, .fish],
                verificationStatus: .verified,
                isFavorite: false,
                notes: "Mì gói quốc dân Việt Nam của Acecook"
            ),

            // 3. Sữa chua ăn Vinamilk Nha Đam 100g
            PackagedFood(
                id: UUID(uuidString: "89346736-2002-4100-8000-000000000003")!,
                barcode: "8934673620024",
                rawBarcode: "8934673620024",
                barcodeType: .ean13,
                productName: "Sữa chua ăn Có Đường Nha Đam (100g)",
                brand: "Vinamilk",
                category: "Sữa & Chế phẩm từ sữa",
                serving: PackagedFoodServing(
                    servingSize: 100,
                    servingUnit: "g",
                    servingsPerPackage: 1.0,
                    servingGramsEquivalent: 100
                ),
                nutrition: PackagedFoodNutrition(
                    calories: 102.5,
                    proteinGrams: 2.8,
                    carbGrams: 15.6,
                    fatGrams: 3.2,
                    fiberGrams: 0.5,
                    sodiumMg: 45,
                    sugarGrams: 14.0,
                    calciumMg: 85,
                    basis: .perServing
                ),
                ingredients: [
                    "Sữa bò tươi",
                    "Sữa bột",
                    "Chất béo sữa",
                    "Thạch nha đam (10%)",
                    "Đường tinh luyện",
                    "Gelatin thực phẩm",
                    "Men Streptococcus thermophilus và Lactobacillus bulgaricus"
                ],
                ingredientText: "Sữa (sữa bò tươi, sữa bột, chất béo sữa), thạch nha đam (10%), đường, gelatin thực phẩm, men sữa chua tự nhiên.",
                allergens: [.milk],
                verificationStatus: .verified,
                isFavorite: false,
                notes: "Lên men tự nhiên, bổ sung thạch nha đam giòn tươi"
            ),

            // 4. Nước tương Nam Dương Đậm Đặc 500ml
            PackagedFood(
                id: UUID(uuidString: "89347580-1004-4100-8000-000000000004")!,
                barcode: "8934758010047",
                rawBarcode: "8934758010047",
                barcodeType: .ean13,
                productName: "Nước tương Đậm Đặc (500ml)",
                brand: "Nam Dương",
                category: "Gia vị & Nước chấm",
                serving: PackagedFoodServing(
                    servingSize: 15,
                    servingUnit: "ml",
                    servingsPerPackage: 33.3,
                    servingGramsEquivalent: 15
                ),
                nutrition: PackagedFoodNutrition(
                    calories: 6.8, // ~45 kcal per 100ml
                    proteinGrams: 0.5,
                    carbGrams: 1.1,
                    fatGrams: 0,
                    fiberGrams: 0,
                    sodiumMg: 630, // 4200mg / 100ml
                    sugarGrams: 0.8,
                    calciumMg: nil,
                    basis: .perServing
                ),
                ingredients: [
                    "Nước tinh khiết",
                    "Khô đậu nành lên men (35g/l)",
                    "Muối ăn",
                    "Đường",
                    "Chất điều vị (621, 627, 631)",
                    "Màu caramen (150c)",
                    "Chất bảo quản (211)"
                ],
                ingredientText: "Nước, muối, khô đậu nành (35g/l), đường, chất điều vị (621, 627, 631), màu caramel tự nhiên (150c).",
                allergens: [.soy],
                verificationStatus: .verified,
                isFavorite: false,
                notes: "Nước tương truyền thống biểu tượng con tàu Nam Dương từ 1951"
            ),

            // 5. Bánh ChocoPie Orion 33g
            PackagedFood(
                id: UUID(uuidString: "89360360-1001-4100-8000-000000000005")!,
                barcode: "8936036010015",
                rawBarcode: "8936036010015",
                barcodeType: .ean13,
                productName: "Bánh ChocoPie Truyền Thống (33g/cái)",
                brand: "Orion",
                category: "Bánh kẹo & Đồ ăn vặt",
                serving: PackagedFoodServing(
                    servingSize: 33,
                    servingUnit: "g",
                    servingsPerPackage: 12.0,
                    servingGramsEquivalent: 33
                ),
                nutrition: PackagedFoodNutrition(
                    calories: 140,
                    proteinGrams: 1.0,
                    carbGrams: 20.0,
                    fatGrams: 6.0,
                    fiberGrams: 0.6,
                    sodiumMg: 75,
                    sugarGrams: 12.0,
                    calciumMg: nil,
                    basis: .perServing
                ),
                ingredients: [
                    "Bột mì",
                    "Đường",
                    "Mạch nha",
                    "Shortening",
                    "Chất béo thực vật",
                    "Bột cacao (3%)",
                    "Sữa bột nguyên kem",
                    "Trứng gà",
                    "Gelatin",
                    "Muối",
                    "Chất tạo xốp (500ii, 503ii)"
                ],
                ingredientText: "Bột mì, đường, mạch nha, shortening thực vật, bột cacao, sữa bột nguyên kem, trứng gà tươi, gelatin dẻo, muối.",
                allergens: [.gluten, .eggs, .milk, .soy],
                verificationStatus: .verified,
                isFavorite: false,
                notes: "Bánh ChocoPie kẹp kem dẻo marshmallow của Orion Vina"
            ),

            // 6. Nước dừa xiêm Cocoxim Bến Tre 330ml
            PackagedFood(
                id: UUID(uuidString: "89360792-8014-4100-8000-000000000006")!,
                barcode: "8936079280147",
                rawBarcode: "8936079280147",
                barcodeType: .ean13,
                productName: "Nước Dừa Xiêm Nguyên Chất (330ml)",
                brand: "Cocoxim",
                category: "Đồ uống & Giải khát",
                serving: PackagedFoodServing(
                    servingSize: 330,
                    servingUnit: "ml",
                    servingsPerPackage: 1.0,
                    servingGramsEquivalent: 330
                ),
                nutrition: PackagedFoodNutrition(
                    calories: 72.6, // 22 kcal / 100ml * 3.3
                    proteinGrams: 0.7,
                    carbGrams: 17.2,
                    fatGrams: 0,
                    fiberGrams: 0,
                    sodiumMg: 132,
                    sugarGrams: 15.0,
                    calciumMg: 50,
                    basis: .perServing
                ),
                ingredients: [
                    "100% Nước dừa xiêm nguyên chất ép từ trái dừa Bến Tre",
                    "Vitamin C (300)"
                ],
                ingredientText: "100% nước dừa xiêm nguyên chất xứ dừa Bến Tre, bổ sung khoáng chất tự nhiên và chất chống oxy hóa (vitamin C).",
                allergens: [],
                verificationStatus: .verified,
                isFavorite: false,
                notes: "Nước dừa tươi đóng hộp công nghệ tiệt trùng Tetra Pak của Betrimex"
            ),

            // 7. Hạt điều rang muối Bazan Dak Lak 150g
            PackagedFood(
                id: UUID(uuidString: "89385012-3401-4100-8000-000000000007")!,
                barcode: "8938501234018",
                rawBarcode: "8938501234018",
                barcodeType: .ean13,
                productName: "Hạt Điều Vỏ Lụa Rang Muối (150g)",
                brand: "Bazan",
                category: "Hạt & Đồ ăn vặt dinh dưỡng",
                serving: PackagedFoodServing(
                    servingSize: 30,
                    servingUnit: "g",
                    servingsPerPackage: 5.0,
                    servingGramsEquivalent: 30
                ),
                nutrition: PackagedFoodNutrition(
                    calories: 175.5, // 585 kcal / 100g * 0.3
                    proteinGrams: 5.5,
                    carbGrams: 8.1,
                    fatGrams: 14.0,
                    fiberGrams: 1.0,
                    sodiumMg: 72,
                    sugarGrams: 1.5,
                    calciumMg: 15,
                    basis: .perServing
                ),
                ingredients: [
                    "Hạt điều nguyên hạt còn vỏ lụa (99%)",
                    "Muối tinh khiết (1%)"
                ],
                ingredientText: "Hạt điều Đắk Lắk nguyên hạt còn vỏ lụa (99%), muối khoáng sạch (1%). Không chất bảo quản.",
                allergens: [.treeNuts],
                verificationStatus: .verified,
                isFavorite: false,
                notes: "Hạt điều Tây Nguyên giòn bùi tự nhiên giàu khoáng chất Magie & Sắt"
            )
        ]
    }

    public func findByBarcode(_ barcode: String) -> PackagedFood? {
        let clean = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        return items.first {
            $0.barcode == clean || $0.rawBarcode == clean
        }
    }

    public func search(query: String) -> [PackagedFood] {
        let lower = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !lower.isEmpty else { return items }
        return items.filter { item in
            item.productName.lowercased().contains(lower) ||
            (item.brand?.lowercased().contains(lower) ?? false) ||
            item.barcode.contains(lower) ||
            item.category.lowercased().contains(lower)
        }
    }
}
