//
//  SwiftDataEntities.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import SwiftData

@Model
public final class FoodItemSDModel {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var vietnameseName: String
    public var confidence: Double
    public var servingSizeGrams: Double
    public var calories: Double
    public var proteinGrams: Double
    public var carbGrams: Double
    public var fatGrams: Double
    public var fiberGrams: Double

    public init(
        id: UUID = UUID(),
        name: String,
        vietnameseName: String,
        confidence: Double,
        servingSizeGrams: Double,
        calories: Double,
        proteinGrams: Double,
        carbGrams: Double,
        fatGrams: Double,
        fiberGrams: Double
    ) {
        self.id = id
        self.name = name
        self.vietnameseName = vietnameseName
        self.confidence = confidence
        self.servingSizeGrams = servingSizeGrams
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbGrams = carbGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
    }

    public convenience init(from entity: FoodItem) {
        self.init(
            id: entity.id,
            name: entity.name,
            vietnameseName: entity.vietnameseName,
            confidence: entity.confidence,
            servingSizeGrams: entity.servingSizeGrams,
            calories: entity.calories,
            proteinGrams: entity.proteinGrams,
            carbGrams: entity.carbGrams,
            fatGrams: entity.fatGrams,
            fiberGrams: entity.fiberGrams
        )
    }

    public func toDomain() -> FoodItem {
        FoodItem(
            id: id,
            name: name,
            vietnameseName: vietnameseName,
            confidence: confidence,
            servingSizeGrams: servingSizeGrams,
            calories: calories,
            proteinGrams: proteinGrams,
            carbGrams: carbGrams,
            fatGrams: fatGrams,
            fiberGrams: fiberGrams
        )
    }
}

@Model
public final class MealSDModel {
    @Attribute(.unique) public var id: UUID
    public var timestamp: Date
    public var mealTypeRaw: String
    @Relationship(deleteRule: .cascade) public var items: [FoodItemSDModel]
    public var notes: String?
    public var imagePath: String?

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        mealTypeRaw: String,
        items: [FoodItemSDModel] = [],
        notes: String? = nil,
        imagePath: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.mealTypeRaw = mealTypeRaw
        self.items = items
        self.notes = notes
        self.imagePath = imagePath
    }

    public convenience init(from domain: MealRecord) {
        self.init(
            id: domain.id,
            timestamp: domain.timestamp,
            mealTypeRaw: domain.mealType.rawValue,
            items: domain.items.map { FoodItemSDModel(from: $0) },
            notes: domain.notes,
            imagePath: domain.imagePath
        )
    }

    public func toDomain() -> MealRecord {
        let mealType = MealType(rawValue: mealTypeRaw) ?? .breakfast
        return MealRecord(
            id: id,
            timestamp: timestamp,
            mealType: mealType,
            items: items.map { $0.toDomain() },
            notes: notes,
            imagePath: imagePath
        )
    }
}

@Model
public final class HydrationRecordSDModel {
    @Attribute(.unique) public var id: UUID
    public var timestamp: Date
    public var amountLiters: Double
    public var notes: String?

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        amountLiters: Double,
        notes: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.amountLiters = amountLiters
        self.notes = notes
    }

    public convenience init(from domain: HydrationRecord) {
        self.init(
            id: domain.id,
            timestamp: domain.timestamp,
            amountLiters: domain.amountLiters,
            notes: domain.notes
        )
    }

    public func toDomain() -> HydrationRecord {
        HydrationRecord(
            id: id,
            timestamp: timestamp,
            amountLiters: amountLiters,
            notes: notes
        )
    }
}

// MARK: - Phase 03: Custom Food SD Model
@Model
public final class CustomFoodSDModel {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var category: String
    public var brand: String?
    public var servingUnit: String
    public var servingSizeGrams: Double
    public var calories: Double
    public var proteinGrams: Double
    public var carbGrams: Double
    public var fatGrams: Double
    public var fiberGrams: Double

    // Optional Micronutrients
    public var sodiumMg: Double?
    public var potassiumMg: Double?
    public var calciumMg: Double?
    public var ironMg: Double?
    public var vitaminAMcg: Double?
    public var vitaminCMg: Double?
    public var sugarGrams: Double?
    public var cholesterolMg: Double?

    public var notes: String?
    public var isFavorite: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        category: String = "Món chính",
        brand: String? = nil,
        servingUnit: String = "g",
        servingSizeGrams: Double,
        calories: Double,
        proteinGrams: Double,
        carbGrams: Double,
        fatGrams: Double,
        fiberGrams: Double = 0,
        sodiumMg: Double? = nil,
        potassiumMg: Double? = nil,
        calciumMg: Double? = nil,
        ironMg: Double? = nil,
        vitaminAMcg: Double? = nil,
        vitaminCMg: Double? = nil,
        sugarGrams: Double? = nil,
        cholesterolMg: Double? = nil,
        notes: String? = nil,
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.brand = brand
        self.servingUnit = servingUnit
        self.servingSizeGrams = servingSizeGrams
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbGrams = carbGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
        self.sodiumMg = sodiumMg
        self.potassiumMg = potassiumMg
        self.calciumMg = calciumMg
        self.ironMg = ironMg
        self.vitaminAMcg = vitaminAMcg
        self.vitaminCMg = vitaminCMg
        self.sugarGrams = sugarGrams
        self.cholesterolMg = cholesterolMg
        self.notes = notes
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public convenience init(from domain: CustomFood) {
        self.init(
            id: domain.id,
            name: domain.name,
            category: domain.category,
            brand: domain.brand,
            servingUnit: domain.servingUnit,
            servingSizeGrams: domain.servingSizeGrams,
            calories: domain.calories,
            proteinGrams: domain.proteinGrams,
            carbGrams: domain.carbGrams,
            fatGrams: domain.fatGrams,
            fiberGrams: domain.fiberGrams,
            sodiumMg: domain.micronutrients?.sodiumMg,
            potassiumMg: domain.micronutrients?.potassiumMg,
            calciumMg: domain.micronutrients?.calciumMg,
            ironMg: domain.micronutrients?.ironMg,
            vitaminAMcg: domain.micronutrients?.vitaminAMcg,
            vitaminCMg: domain.micronutrients?.vitaminCMg,
            sugarGrams: domain.micronutrients?.sugarGrams,
            cholesterolMg: domain.micronutrients?.cholesterolMg,
            notes: domain.notes,
            isFavorite: domain.isFavorite,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }

    public func toDomain() -> CustomFood {
        let micro = MicronutrientProfile(
            sodiumMg: sodiumMg,
            potassiumMg: potassiumMg,
            calciumMg: calciumMg,
            ironMg: ironMg,
            vitaminAMcg: vitaminAMcg,
            vitaminCMg: vitaminCMg,
            sugarGrams: sugarGrams,
            cholesterolMg: cholesterolMg
        )
        return CustomFood(
            id: id,
            name: name,
            category: category,
            brand: brand,
            servingUnit: servingUnit,
            servingSizeGrams: servingSizeGrams,
            calories: calories,
            proteinGrams: proteinGrams,
            carbGrams: carbGrams,
            fatGrams: fatGrams,
            fiberGrams: fiberGrams,
            micronutrients: micro.hasAnyData ? micro : nil,
            notes: notes,
            isFavorite: isFavorite,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Phase 03: Recipe Ingredient SD Model
@Model
public final class RecipeIngredientSDModel {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var sourceTypeRaw: String
    public var sourceReferenceId: String?
    public var amountGrams: Double
    public var servingUnit: String
    public var calories: Double
    public var proteinGrams: Double
    public var carbGrams: Double
    public var fatGrams: Double
    public var fiberGrams: Double
    public var notes: String?

    public init(
        id: UUID = UUID(),
        name: String,
        sourceTypeRaw: String,
        sourceReferenceId: String? = nil,
        amountGrams: Double,
        servingUnit: String = "g",
        calories: Double,
        proteinGrams: Double,
        carbGrams: Double,
        fatGrams: Double,
        fiberGrams: Double = 0,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.sourceTypeRaw = sourceTypeRaw
        self.sourceReferenceId = sourceReferenceId
        self.amountGrams = amountGrams
        self.servingUnit = servingUnit
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbGrams = carbGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
        self.notes = notes
    }

    public convenience init(from domain: RecipeIngredient) {
        self.init(
            id: domain.id,
            name: domain.name,
            sourceTypeRaw: domain.sourceType.rawValue,
            sourceReferenceId: domain.sourceReferenceId,
            amountGrams: domain.amountGrams,
            servingUnit: domain.servingUnit,
            calories: domain.calories,
            proteinGrams: domain.proteinGrams,
            carbGrams: domain.carbGrams,
            fatGrams: domain.fatGrams,
            fiberGrams: domain.fiberGrams,
            notes: domain.notes
        )
    }

    public func toDomain() -> RecipeIngredient {
        RecipeIngredient(
            id: id,
            name: name,
            sourceType: IngredientSourceType(rawValue: sourceTypeRaw) ?? .manual,
            sourceReferenceId: sourceReferenceId,
            amountGrams: amountGrams,
            servingUnit: servingUnit,
            calories: calories,
            proteinGrams: proteinGrams,
            carbGrams: carbGrams,
            fatGrams: fatGrams,
            fiberGrams: fiberGrams,
            notes: notes
        )
    }
}

// MARK: - Phase 03: Recipe SD Model
@Model
public final class RecipeSDModel {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var servings: Int
    public var prepTimeMinutes: Int?
    public var cookingTimeMinutes: Int?
    @Relationship(deleteRule: .cascade) public var ingredients: [RecipeIngredientSDModel]
    public var instructionsRaw: String?
    public var notes: String?
    public var isFavorite: Bool
    public var imagePath: String?
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        servings: Int = 2,
        prepTimeMinutes: Int? = nil,
        cookingTimeMinutes: Int? = nil,
        ingredients: [RecipeIngredientSDModel] = [],
        instructionsRaw: String? = nil,
        notes: String? = nil,
        isFavorite: Bool = false,
        imagePath: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.servings = servings
        self.prepTimeMinutes = prepTimeMinutes
        self.cookingTimeMinutes = cookingTimeMinutes
        self.ingredients = ingredients
        self.instructionsRaw = instructionsRaw
        self.notes = notes
        self.isFavorite = isFavorite
        self.imagePath = imagePath
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public convenience init(from domain: Recipe) {
        let instructionsJoined = domain.instructions.isEmpty ? nil : domain.instructions.joined(separator: "\n---STEP---\n")
        self.init(
            id: domain.id,
            name: domain.name,
            servings: domain.servings,
            prepTimeMinutes: domain.prepTimeMinutes,
            cookingTimeMinutes: domain.cookingTimeMinutes,
            ingredients: domain.ingredients.map { RecipeIngredientSDModel(from: $0) },
            instructionsRaw: instructionsJoined,
            notes: domain.notes,
            isFavorite: domain.isFavorite,
            imagePath: domain.imagePath,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }

    public func toDomain() -> Recipe {
        let parsedInstructions: [String]
        if let raw = instructionsRaw, !raw.isEmpty {
            parsedInstructions = raw.components(separatedBy: "\n---STEP---\n")
        } else {
            parsedInstructions = []
        }

        return Recipe(
            id: id,
            name: name,
            servings: servings,
            prepTimeMinutes: prepTimeMinutes,
            cookingTimeMinutes: cookingTimeMinutes,
            ingredients: ingredients.map { $0.toDomain() },
            instructions: parsedInstructions,
            notes: notes,
            isFavorite: isFavorite,
            imagePath: imagePath,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Phase 04: Planned Food Item SwiftData Model
@Model
public final class PlannedFoodItemSDModel {
    @Attribute(.unique) public var id: UUID
    public var sourceTypeRaw: String
    public var sourceId: String?
    public var displayName: String
    public var quantity: Double
    public var servingUnit: String
    public var portionMultiplier: Double
    public var calories: Double
    public var proteinGrams: Double
    public var carbGrams: Double
    public var fatGrams: Double
    public var fiberGrams: Double

    public init(
        id: UUID = UUID(),
        sourceTypeRaw: String,
        sourceId: String? = nil,
        displayName: String,
        quantity: Double,
        servingUnit: String = "g",
        portionMultiplier: Double = 1.0,
        calories: Double = 0,
        proteinGrams: Double = 0,
        carbGrams: Double = 0,
        fatGrams: Double = 0,
        fiberGrams: Double = 0
    ) {
        self.id = id
        self.sourceTypeRaw = sourceTypeRaw
        self.sourceId = sourceId
        self.displayName = displayName
        self.quantity = quantity
        self.servingUnit = servingUnit
        self.portionMultiplier = portionMultiplier
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbGrams = carbGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
    }

    public convenience init(from domain: PlannedFoodItem) {
        self.init(
            id: domain.id,
            sourceTypeRaw: domain.sourceType.rawValue,
            sourceId: domain.sourceId,
            displayName: domain.displayName,
            quantity: domain.quantity,
            servingUnit: domain.servingUnit,
            portionMultiplier: domain.portionMultiplier,
            calories: domain.nutritionSnapshot.calories,
            proteinGrams: domain.nutritionSnapshot.proteinGrams,
            carbGrams: domain.nutritionSnapshot.carbGrams,
            fatGrams: domain.nutritionSnapshot.fatGrams,
            fiberGrams: domain.nutritionSnapshot.fiberGrams
        )
    }

    public func toDomain() -> PlannedFoodItem {
        let sourceType = PlannedFoodSourceType(rawValue: sourceTypeRaw) ?? .vietnameseDatabase
        let snapshot = PlannedNutritionSnapshot(
            calories: calories,
            proteinGrams: proteinGrams,
            carbGrams: carbGrams,
            fatGrams: fatGrams,
            fiberGrams: fiberGrams
        )
        return PlannedFoodItem(
            id: id,
            sourceType: sourceType,
            sourceId: sourceId,
            displayName: displayName,
            quantity: quantity,
            servingUnit: servingUnit,
            portionMultiplier: portionMultiplier,
            nutritionSnapshot: snapshot
        )
    }
}

// MARK: - Phase 04: Planned Meal SwiftData Model
@Model
public final class PlannedMealSDModel {
    @Attribute(.unique) public var id: UUID
    public var scheduledDate: Date
    public var mealCategoryRaw: String
    @Relationship(deleteRule: .cascade) public var foodItems: [PlannedFoodItemSDModel]
    public var notes: String?
    public var statusRaw: String
    public var linkedDiaryRecordId: UUID?
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        scheduledDate: Date,
        mealCategoryRaw: String,
        foodItems: [PlannedFoodItemSDModel] = [],
        notes: String? = nil,
        statusRaw: String = PlannedMealStatus.planned.rawValue,
        linkedDiaryRecordId: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.scheduledDate = scheduledDate
        self.mealCategoryRaw = mealCategoryRaw
        self.foodItems = foodItems
        self.notes = notes
        self.statusRaw = statusRaw
        self.linkedDiaryRecordId = linkedDiaryRecordId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public convenience init(from domain: PlannedMeal) {
        self.init(
            id: domain.id,
            scheduledDate: domain.scheduledDate,
            mealCategoryRaw: domain.mealCategory.rawValue,
            foodItems: domain.foodItems.map { PlannedFoodItemSDModel(from: $0) },
            notes: domain.notes,
            statusRaw: domain.status.rawValue,
            linkedDiaryRecordId: domain.linkedDiaryRecordId,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }

    public func toDomain() -> PlannedMeal {
        let category = PlannedMealCategory(rawValue: mealCategoryRaw) ?? .lunch
        let status = PlannedMealStatus(rawValue: statusRaw) ?? .planned
        return PlannedMeal(
            id: id,
            scheduledDate: scheduledDate,
            mealCategory: category,
            foodItems: foodItems.map { $0.toDomain() },
            notes: notes,
            status: status,
            linkedDiaryRecordId: linkedDiaryRecordId,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Phase 06: Packaged Food SwiftData Model
@Model
public final class PackagedFoodSDModel {
    @Attribute(.unique) public var id: UUID
    public var barcode: String
    public var rawBarcode: String
    public var barcodeTypeRaw: String
    public var productName: String
    public var brand: String?
    public var category: String
    public var servingSize: Double
    public var servingUnit: String
    public var servingsPerPackage: Double?
    public var servingGramsEquivalent: Double
    public var calories: Double
    public var proteinGrams: Double
    public var carbGrams: Double
    public var fatGrams: Double
    public var fiberGrams: Double?
    public var sodiumMg: Double?
    public var sugarGrams: Double?
    public var calciumMg: Double?
    public var ironMg: Double?
    public var nutritionBasisRaw: String
    public var ingredientsJSON: String
    public var ingredientText: String?
    public var allergensRaw: [String]
    public var verificationStatusRaw: String
    public var isFavorite: Bool
    public var lastScannedAt: Date?
    public var createdAt: Date
    public var updatedAt: Date
    public var notes: String?
    public var imagePath: String?

    public init(
        id: UUID = UUID(),
        barcode: String,
        rawBarcode: String,
        barcodeTypeRaw: String,
        productName: String,
        brand: String? = nil,
        category: String = "Thực phẩm đóng gói",
        servingSize: Double = 100,
        servingUnit: String = "g",
        servingsPerPackage: Double? = 1.0,
        servingGramsEquivalent: Double = 100,
        calories: Double = 0,
        proteinGrams: Double = 0,
        carbGrams: Double = 0,
        fatGrams: Double = 0,
        fiberGrams: Double? = nil,
        sodiumMg: Double? = nil,
        sugarGrams: Double? = nil,
        calciumMg: Double? = nil,
        ironMg: Double? = nil,
        nutritionBasisRaw: String = NutritionBasis.perServing.rawValue,
        ingredientsJSON: String = "[]",
        ingredientText: String? = nil,
        allergensRaw: [String] = [],
        verificationStatusRaw: String = IngredientVerificationStatus.partial.rawValue,
        isFavorite: Bool = false,
        lastScannedAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        notes: String? = nil,
        imagePath: String? = nil
    ) {
        self.id = id
        self.barcode = barcode
        self.rawBarcode = rawBarcode
        self.barcodeTypeRaw = barcodeTypeRaw
        self.productName = productName
        self.brand = brand
        self.category = category
        self.servingSize = servingSize
        self.servingUnit = servingUnit
        self.servingsPerPackage = servingsPerPackage
        self.servingGramsEquivalent = servingGramsEquivalent
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbGrams = carbGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
        self.sodiumMg = sodiumMg
        self.sugarGrams = sugarGrams
        self.calciumMg = calciumMg
        self.ironMg = ironMg
        self.nutritionBasisRaw = nutritionBasisRaw
        self.ingredientsJSON = ingredientsJSON
        self.ingredientText = ingredientText
        self.allergensRaw = allergensRaw
        self.verificationStatusRaw = verificationStatusRaw
        self.isFavorite = isFavorite
        self.lastScannedAt = lastScannedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.notes = notes
        self.imagePath = imagePath
    }

    public convenience init(from domain: PackagedFood) {
        let ingData = (try? JSONEncoder().encode(domain.ingredients)) ?? Data()
        let ingString = String(data: ingData, encoding: .utf8) ?? "[]"

        self.init(
            id: domain.id,
            barcode: domain.barcode,
            rawBarcode: domain.rawBarcode,
            barcodeTypeRaw: domain.barcodeType.rawValue,
            productName: domain.productName,
            brand: domain.brand,
            category: domain.category,
            servingSize: domain.serving.servingSize,
            servingUnit: domain.serving.servingUnit,
            servingsPerPackage: domain.serving.servingsPerPackage,
            servingGramsEquivalent: domain.serving.servingGramsEquivalent,
            calories: domain.nutrition.calories,
            proteinGrams: domain.nutrition.proteinGrams,
            carbGrams: domain.nutrition.carbGrams,
            fatGrams: domain.nutrition.fatGrams,
            fiberGrams: domain.nutrition.fiberGrams,
            sodiumMg: domain.nutrition.sodiumMg,
            sugarGrams: domain.nutrition.sugarGrams,
            calciumMg: domain.nutrition.calciumMg,
            ironMg: domain.nutrition.ironMg,
            nutritionBasisRaw: domain.nutrition.basis.rawValue,
            ingredientsJSON: ingString,
            ingredientText: domain.ingredientText,
            allergensRaw: domain.allergens.map { $0.rawValue },
            verificationStatusRaw: domain.verificationStatus.rawValue,
            isFavorite: domain.isFavorite,
            lastScannedAt: domain.lastScannedAt,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt,
            notes: domain.notes,
            imagePath: domain.imagePath
        )
    }

    public func toDomain() -> PackagedFood {
        let bType = BarcodeType(rawValue: barcodeTypeRaw) ?? .ean13
        let nBasis = NutritionBasis(rawValue: nutritionBasisRaw) ?? .perServing
        let vStatus = IngredientVerificationStatus(rawValue: verificationStatusRaw) ?? .partial

        let serving = PackagedFoodServing(
            servingSize: servingSize,
            servingUnit: servingUnit,
            servingsPerPackage: servingsPerPackage,
            servingGramsEquivalent: servingGramsEquivalent
        )

        let nutrition = PackagedFoodNutrition(
            calories: calories,
            proteinGrams: proteinGrams,
            carbGrams: carbGrams,
            fatGrams: fatGrams,
            fiberGrams: fiberGrams,
            sodiumMg: sodiumMg,
            sugarGrams: sugarGrams,
            calciumMg: calciumMg,
            ironMg: ironMg,
            basis: nBasis
        )

        var parsedIngredients: [String] = []
        if let data = ingredientsJSON.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            parsedIngredients = decoded
        }

        let parsedAllergens = allergensRaw.compactMap { AllergenType(rawValue: $0) }

        return PackagedFood(
            id: id,
            barcode: barcode,
            rawBarcode: rawBarcode,
            barcodeType: bType,
            productName: productName,
            brand: brand,
            category: category,
            serving: serving,
            nutrition: nutrition,
            ingredients: parsedIngredients,
            ingredientText: ingredientText,
            allergens: parsedAllergens,
            verificationStatus: vStatus,
            isFavorite: isFavorite,
            lastScannedAt: lastScannedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            notes: notes,
            imagePath: imagePath
        )
    }
}


