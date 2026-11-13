//
//  SmartMealSuggestionEngine.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Deterministic, explainable rule-based recommendation engine for personalized meal suggestions.
//  NOTE: Pure rule-based scoring. Does NOT use LLM or simulate clinical probability.
//

import Foundation

public struct RecommendationContext: Sendable {
    public let targetDate: Date
    public let targetCategory: PlannedMealCategory?
    public let userProfile: UserDietaryProfile
    public let favoriteIds: Set<String>
    public let recentDiaryDishNames: [String] // Logged within last 7 days
    public let todayDiaryDishNames: [String]  // Logged today
    public let plannedDishNamesThisWeek: [String] // Scheduled this week
    public let todayPlannedDishNames: [String]    // Scheduled today

    public init(
        targetDate: Date = Date(),
        targetCategory: PlannedMealCategory? = nil,
        userProfile: UserDietaryProfile = UserDietaryProfile(),
        favoriteIds: Set<String> = [],
        recentDiaryDishNames: [String] = [],
        todayDiaryDishNames: [String] = [],
        plannedDishNamesThisWeek: [String] = [],
        todayPlannedDishNames: [String] = []
    ) {
        self.targetDate = targetDate
        self.targetCategory = targetCategory
        self.userProfile = userProfile
        self.favoriteIds = favoriteIds
        self.recentDiaryDishNames = recentDiaryDishNames
        self.todayDiaryDishNames = todayDiaryDishNames
        self.plannedDishNamesThisWeek = plannedDishNamesThisWeek
        self.todayPlannedDishNames = todayPlannedDishNames
    }
}

public final class SmartMealSuggestionEngine: Sendable {

    public init() {}

    /// Main ranking entry point. Guaranteed deterministic for the same inputs.
    public func rankSuggestions(
        vietnameseDishes: [VietnameseDishProfile],
        customFoods: [CustomFood],
        recipes: [Recipe],
        filter: SmartSuggestionsFilter,
        context: RecommendationContext
    ) -> [MealSuggestion] {

        var candidateSuggestions: [MealSuggestion] = []

        // 1. Process standard Vietnamese database dishes
        for dish in vietnameseDishes {
            if let suggestion = evaluateVietnameseDish(dish, filter: filter, context: context) {
                candidateSuggestions.append(suggestion)
            }
        }

        // 2. Process user Custom Foods
        for customFood in customFoods {
            if let suggestion = evaluateCustomFood(customFood, filter: filter, context: context) {
                candidateSuggestions.append(suggestion)
            }
        }

        // 3. Process user Recipes
        for recipe in recipes {
            if let suggestion = evaluateRecipe(recipe, filter: filter, context: context) {
                candidateSuggestions.append(suggestion)
            }
        }

        // 4. Stable deterministic sort: Score descending, then DisplayName ascending
        let sorted = candidateSuggestions.sorted { first, second in
            if first.recommendationScore != second.recommendationScore {
                return first.recommendationScore > second.recommendationScore
            }
            return first.displayName.localizedStandardCompare(second.displayName) == .orderedAscending
        }

        return sorted
    }

    // MARK: - Candidate Evaluation: Vietnamese Dish
    private func evaluateVietnameseDish(
        _ dish: VietnameseDishProfile,
        filter: SmartSuggestionsFilter,
        context: RecommendationContext
    ) -> MealSuggestion? {
        let meta = VietnameseDishIngredientMetadata.metadata(forSlug: dish.slug)
        let ingredients = meta?.documentedIngredients ?? []
        let allergens = meta?.allergens ?? []
        let typicalCategories = meta?.typicalMealCategories ?? [.lunch, .dinner]
        let isVegetarian = meta?.isVegetarian ?? false
        let isPescatarian = meta?.isPescatarian ?? false

        // Search Query Filter
        if !filter.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let cleanQuery = filter.searchQuery.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let dishName = dish.vietnameseName.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let keywords = dish.keywords.map { $0.folding(options: .diacriticInsensitive, locale: .current).lowercased() }
            let matchesName = dishName.contains(cleanQuery)
            let matchesKeyword = keywords.contains { $0.contains(cleanQuery) }
            if !matchesName && !matchesKeyword {
                return nil
            }
        }

        // Food Category Filter
        if let targetFoodCategory = filter.foodCategory, !targetFoodCategory.isEmpty, targetFoodCategory != "Tất cả" {
            if dish.category != targetFoodCategory {
                return nil
            }
        }

        // Favorite Only Filter
        let isFavorite = context.favoriteIds.contains(dish.id) || context.favoriteIds.contains(dish.slug)
        if filter.favoriteOnly && !isFavorite {
            return nil
        }

        // Dietary Lifestyle Compatibility Check
        let activeStyles = effectiveDietaryStyles(filter: filter, profile: context.userProfile)

        if activeStyles.contains(.vegetarian) && !isVegetarian {
            return nil // Exclude non-vegetarian dishes
        }

        if activeStyles.contains(.pescatarian) && !isVegetarian && !isPescatarian {
            return nil // Exclude land meat dishes for pescatarians
        }

        // Allergen Conflict Evaluation
        let conflictingAllergens = allergens.filter { context.userProfile.hasDeclaredAllergen($0) }
        let hasConflict = !conflictingAllergens.isEmpty

        if filter.excludeKnownAllergens && hasConflict {
            return nil // Hard exclude for safety
        }

        // Disliked Ingredients Evaluation
        for disliked in context.userProfile.dislikedIngredients {
            let cleanDisliked = disliked.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            guard !cleanDisliked.isEmpty else { continue }
            let nameMatch = dish.vietnameseName.folding(options: .diacriticInsensitive, locale: .current).lowercased().contains(cleanDisliked)
            let ingMatch = ingredients.contains { $0.folding(options: .diacriticInsensitive, locale: .current).lowercased().contains(cleanDisliked) }
            if nameMatch || ingMatch {
                return nil // Exclude dishes with disliked ingredients
            }
        }

        // Target Meal Category Compatibility
        let targetCat = filter.mealCategory ?? context.targetCategory
        if let targetCat, !typicalCategories.contains(targetCat) {
            // When user explicitly selects a meal category (e.g. Breakfast, Snack), only return suitable dishes
            if filter.mealCategory != nil {
                return nil
            }
            if dish.category == "Tráng Miệng" && (targetCat == .breakfast || targetCat == .lunch) {
                return nil
            }
        }

        // Calculate Deterministic Score & Explanations
        var score = 50
        var factors: [SuggestionExplanationFactor] = []
        var reasons: [String] = []

        // Factor 1: Meal Category Fit
        if let targetCat {
            if typicalCategories.contains(targetCat) {
                let pts = 25
                score += pts
                factors.append(SuggestionExplanationFactor(
                    title: "Phù hợp với \(targetCat.vietnameseName.lowercased())",
                    detail: "Món ăn truyền thống thường được ưa chuộng cho \(targetCat.vietnameseName.lowercased()).",
                    systemIcon: targetCat.systemIcon,
                    scoreImpact: pts
                ))
                reasons.append("Phù hợp bữa \(targetCat.vietnameseName.lowercased())")
            }
        }

        // Factor 2: User Favorite Boost
        if isFavorite {
            let pts = 20
            score += pts
            factors.append(SuggestionExplanationFactor(
                title: "Món ăn bạn yêu thích",
                detail: "Món này nằm trong danh sách đã lưu yêu thích của bạn.",
                systemIcon: "heart.fill",
                scoreImpact: pts
            ))
            reasons.append("Món bạn yêu thích")
        }

        // Factor 3: Active Dietary Preferences
        for style in activeStyles {
            switch style {
            case .highProtein where dish.proteinPerServing >= 25.0:
                let pts = 20
                score += pts
                factors.append(SuggestionExplanationFactor(
                    title: "Hàm lượng đạm cao (\(Int(dish.proteinPerServing))g Protein)",
                    detail: "Cung cấp lượng đạm dồi dào, phù hợp mục tiêu dinh dưỡng cơ bắp và no lâu.",
                    systemIcon: "figure.strengthtraining.traditional",
                    scoreImpact: pts
                ))
                reasons.append("Giàu đạm (\(Int(dish.proteinPerServing))g)")
            case .lowCarb where dish.carbPerServing <= 25.0:
                let pts = 18
                score += pts
                factors.append(SuggestionExplanationFactor(
                    title: "Lượng tinh bột thấp (\(Int(dish.carbPerServing))g Carb)",
                    detail: "Phù hợp chế độ ăn hạn chế tinh bột hoặc cân đối carb buổi tối.",
                    systemIcon: "bolt.fill",
                    scoreImpact: pts
                ))
                reasons.append("Ít tinh bột (\(Int(dish.carbPerServing))g)")
            case .balanced where dish.proteinPerServing >= 15.0 && dish.carbPerServing <= 65.0:
                let pts = 15
                score += pts
                factors.append(SuggestionExplanationFactor(
                    title: "Cân đối đa lượng NIN",
                    detail: "Tỉ lệ đạm, tinh bột và chất béo hài hòa theo khuyến nghị Viện Dinh Dưỡng.",
                    systemIcon: "scale.3d",
                    scoreImpact: pts
                ))
                reasons.append("Cân đối dinh dưỡng")
            case .vietnamese:
                let pts = 12
                score += pts
                factors.append(SuggestionExplanationFactor(
                    title: "Đặc sản món Việt chuẩn vị",
                    detail: "Hương vị ẩm thực truyền thống thân thuộc từ cơ sở dữ liệu NIN.",
                    systemIcon: "fork.knife",
                    scoreImpact: pts
                ))
            case .eatClean where dish.fiberPerServing >= 3.0:
                let pts = 15
                score += pts
                factors.append(SuggestionExplanationFactor(
                    title: "Thanh đạm & giàu chất xơ",
                    detail: "Cung cấp chất xơ tự nhiên từ rau củ và gia vị tươi nguyên bản.",
                    systemIcon: "sparkles",
                    scoreImpact: pts
                ))
            default:
                break
            }
        }

        // Factor 4: Variety & Recency
        let normalizedDishName = dish.vietnameseName.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        let eatenToday = context.todayDiaryDishNames.contains { $0.folding(options: .diacriticInsensitive, locale: .current).lowercased() == normalizedDishName }
        let plannedToday = context.todayPlannedDishNames.contains { $0.folding(options: .diacriticInsensitive, locale: .current).lowercased() == normalizedDishName }

        if eatenToday || plannedToday {
            score -= 25
            factors.append(SuggestionExplanationFactor(
                title: "Đã có trong thực đơn hôm nay",
                detail: "Món này đã được ghi nhận hoặc lên lịch hôm nay. Điểm phù hợp giảm để ưu tiên các món khác.",
                systemIcon: "arrow.triangle.2.circlepath",
                scoreImpact: -25
            ))
        } else {
            let eatenRecently = context.recentDiaryDishNames.contains { $0.folding(options: .diacriticInsensitive, locale: .current).lowercased() == normalizedDishName }
            if !eatenRecently {
                let pts = 10
                score += pts
                factors.append(SuggestionExplanationFactor(
                    title: "Giúp đổi vị & đa dạng thực đơn",
                    detail: "Bạn chưa dùng món này gần đây, thích hợp để làm mới khẩu vị trong tuần.",
                    systemIcon: "leaf.arrow.triangle.circlepath",
                    scoreImpact: pts
                ))
                reasons.append("Làm mới khẩu vị")
            }
        }

        // Ingredient verification status
        let verificationStatus = meta?.verificationStatus ?? .partial

        let snapshot = PlannedNutritionSnapshot(
            calories: dish.caloriesPerServing,
            proteinGrams: dish.proteinPerServing,
            carbGrams: dish.carbPerServing,
            fatGrams: dish.fatPerServing,
            fiberGrams: dish.fiberPerServing
        )

        return MealSuggestion(
            foodSource: .vietnameseDatabase,
            sourceId: dish.slug,
            displayName: dish.vietnameseName,
            dishCategory: dish.category,
            suggestedServing: "1 phần chuẩn (\(Int(dish.standardServingGrams))g)",
            suggestedServingGrams: dish.standardServingGrams,
            availableNutritionEstimate: snapshot,
            recommendationScore: score,
            explanationReasons: reasons.isEmpty ? ["Món ngon gợi ý"] : reasons,
            explanationFactors: factors,
            ingredientVerificationStatus: verificationStatus,
            documentedIngredients: ingredients,
            allergenWarnings: allergens,
            hasAllergenConflict: hasConflict,
            isFavorite: isFavorite,
            imageName: dish.slug
        )
    }

    // MARK: - Candidate Evaluation: Custom Food
    private func evaluateCustomFood(
        _ food: CustomFood,
        filter: SmartSuggestionsFilter,
        context: RecommendationContext
    ) -> MealSuggestion? {
        // Search Query Filter
        if !filter.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let cleanQuery = filter.searchQuery.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let name = food.name.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            if !name.contains(cleanQuery) {
                return nil
            }
        }

        // Favorite Only Filter
        if filter.favoriteOnly && !food.isFavorite {
            return nil
        }

        // Disliked Ingredients Filter on food name & notes
        for disliked in context.userProfile.dislikedIngredients {
            let cleanDisliked = disliked.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            guard !cleanDisliked.isEmpty else { continue }
            if food.name.folding(options: .diacriticInsensitive, locale: .current).lowercased().contains(cleanDisliked) {
                return nil
            }
        }

        var score = 55 // Slight personal library base boost
        var factors: [SuggestionExplanationFactor] = []
        var reasons: [String] = ["Món ăn của bạn"]

        factors.append(SuggestionExplanationFactor(
            title: "Món ăn từ thư viện cá nhân",
            detail: "Món ăn tự lưu với thông tin dinh dưỡng do bạn thiết lập.",
            systemIcon: "person.crop.circle.fill",
            scoreImpact: 15
        ))
        score += 15

        if food.isFavorite {
            score += 20
            factors.append(SuggestionExplanationFactor(
                title: "Món ăn yêu thích",
                detail: "Bạn đã đánh dấu yêu thích món ăn này.",
                systemIcon: "heart.fill",
                scoreImpact: 20
            ))
            reasons.append("Yêu thích")
        }

        if food.proteinGrams >= 25 {
            score += 15
            factors.append(SuggestionExplanationFactor(
                title: "Giàu đạm (\(Int(food.proteinGrams))g Protein)",
                detail: "Món ăn cung cấp nguồn protein cao theo khẩu phần đã lưu.",
                systemIcon: "figure.strengthtraining.traditional",
                scoreImpact: 15
            ))
            reasons.append("Giàu đạm")
        }

        let snapshot = PlannedNutritionSnapshot(
            calories: food.calories,
            proteinGrams: food.proteinGrams,
            carbGrams: food.carbGrams,
            fatGrams: food.fatGrams,
            fiberGrams: food.fiberGrams
        )

        return MealSuggestion(
            foodSource: .customFood,
            sourceId: food.id.uuidString,
            displayName: food.name,
            dishCategory: food.category,
            suggestedServing: "1 phần (\(Int(food.servingSizeGrams))\(food.servingUnit))",
            suggestedServingGrams: food.servingSizeGrams,
            availableNutritionEstimate: snapshot,
            recommendationScore: score,
            explanationReasons: reasons,
            explanationFactors: factors,
            ingredientVerificationStatus: .partial, // Custom food ingredients are user-entered, not NIN verified
            documentedIngredients: food.notes != nil ? [food.notes!] : [],
            allergenWarnings: [],
            hasAllergenConflict: false,
            isFavorite: food.isFavorite
        )
    }

    // MARK: - Candidate Evaluation: Recipe
    private func evaluateRecipe(
        _ recipe: Recipe,
        filter: SmartSuggestionsFilter,
        context: RecommendationContext
    ) -> MealSuggestion? {
        // Search Query Filter
        if !filter.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let cleanQuery = filter.searchQuery.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let name = recipe.name.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            if !name.contains(cleanQuery) {
                return nil
            }
        }

        // Favorite Only Filter
        if filter.favoriteOnly && !recipe.isFavorite {
            return nil
        }

        // Allergen & Disliked check on recipe ingredients
        let ingredientNames = recipe.ingredients.map { $0.name }
        for disliked in context.userProfile.dislikedIngredients {
            let cleanDisliked = disliked.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            guard !cleanDisliked.isEmpty else { continue }
            if recipe.name.folding(options: .diacriticInsensitive, locale: .current).lowercased().contains(cleanDisliked) {
                return nil
            }
            let hasMatch = ingredientNames.contains { ing in
                ing.folding(options: .diacriticInsensitive, locale: .current).lowercased().contains(cleanDisliked)
            }
            if hasMatch {
                return nil
            }
        }

        var score = 60 // Personal creative recipe boost
        var factors: [SuggestionExplanationFactor] = []
        var reasons: [String] = ["Công thức sáng tạo"]

        factors.append(SuggestionExplanationFactor(
            title: "Công thức bạn tự sáng tạo",
            detail: "Công thức gồm \(recipe.ingredients.count) nguyên liệu được tính toán dinh dưỡng chính xác.",
            systemIcon: "book.closed.fill",
            scoreImpact: 15
        ))
        score += 15

        if recipe.isFavorite {
            score += 20
            factors.append(SuggestionExplanationFactor(
                title: "Công thức yêu thích",
                detail: "Bạn đã đánh dấu yêu thích công thức này.",
                systemIcon: "heart.fill",
                scoreImpact: 20
            ))
            reasons.append("Yêu thích")
        }

        let servingCal = recipe.perServingCalories
        let servingPro = recipe.perServingProteinGrams
        let servingCarb = recipe.perServingCarbGrams
        let servingFat = recipe.perServingFatGrams
        let servingFiber = recipe.perServingFiberGrams

        if servingPro >= 25 {
            score += 15
            factors.append(SuggestionExplanationFactor(
                title: "Giàu đạm (\(Int(servingPro))g Protein/khẩu phần)",
                detail: "Cung cấp dinh dưỡng phù hợp cho bữa ăn chính giàu dưỡng chất.",
                systemIcon: "figure.strengthtraining.traditional",
                scoreImpact: 15
            ))
            reasons.append("Giàu đạm")
        }

        let snapshot = PlannedNutritionSnapshot(
            calories: servingCal,
            proteinGrams: servingPro,
            carbGrams: servingCarb,
            fatGrams: servingFat,
            fiberGrams: servingFiber
        )

        return MealSuggestion(
            foodSource: .recipe,
            sourceId: recipe.id.uuidString,
            displayName: recipe.name,
            dishCategory: "Công thức (\(recipe.servings) phần)",
            suggestedServing: "1 khẩu phần (trong \(recipe.servings) phần)",
            suggestedServingGrams: recipe.totalWeightGrams > 0 ? recipe.totalWeightGrams / Double(max(1, recipe.servings)) : 250,
            availableNutritionEstimate: snapshot,
            recommendationScore: score,
            explanationReasons: reasons,
            explanationFactors: factors,
            ingredientVerificationStatus: .verified,
            documentedIngredients: ingredientNames,
            allergenWarnings: [],
            hasAllergenConflict: false,
            isFavorite: recipe.isFavorite
        )
    }

    // MARK: - Helper: Extract Active Dietary Preferences
    private func effectiveDietaryStyles(filter: SmartSuggestionsFilter, profile: UserDietaryProfile) -> Set<DietaryPreferenceType> {
        var styles = profile.dietaryPreferences
        if let explicit = filter.activeDietaryStyle {
            styles.insert(explicit)
        }
        return styles
    }
}
