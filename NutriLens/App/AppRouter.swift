//
//  AppRouter.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import SwiftUI

public enum AppTab: Int, CaseIterable, Identifiable {
    case home = 0
    case history = 1
    case scan = 2
    case stats = 3
    case profile = 4

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .home: return "Trang chủ"
        case .history: return "Nhật ký"
        case .scan: return "Quét"
        case .stats: return "Thống kê"
        case .profile: return "Cá nhân"
        }
    }

    public var icon: String {
        switch self {
        case .home: return "house.fill"
        case .history: return "book.pages"
        case .scan: return "camera.fill"
        case .stats: return "chart.bar"
        case .profile: return "person"
        }
    }
}

public struct MainTabView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @State private var selectedTab: AppTab = .home
    @State private var isPresentingManualLog: Bool = false
    @State private var isPresentingSettings: Bool = false
    @State private var isPresentingAuth: Bool = false
    @State private var authInitialStep: AuthStep = .accountManagement
    @State private var isPresentingMyFoods: Bool = false
    @State private var isPresentingCreateFood: Bool = false
    @State private var isPresentingSampleRecipeDetail: Bool = false
    @State private var isPresentingWeeklyPlanner: Bool = false
    @State private var isPresentingAddPlannedMeal: Bool = false
    @State private var isPresentingPlannedFoodPicker: Bool = false
    @State private var isPresentingPlannedMealDetail: Bool = false
    @State private var isPresentingCopyDayPlan: Bool = false
    @State private var isPresentingLogPlannedMealConfirmation: Bool = false
    @State private var isPresentingSmartSuggestions: Bool = false
    @State private var isPresentingSuggestionExplanation: Bool = false
    @State private var isPresentingIngredientReview: Bool = false
    @State private var isPresentingDietaryPreferences: Bool = false
    @State private var isPresentingAddSuggestionToPlan: Bool = false
    @State private var isPresentingBarcodeScanner: Bool = false
    @State private var isPresentingPackagedFoodLibrary: Bool = false
    @State private var isPresentingScannedProductResult: Bool = false
    @State private var isPresentingCreatePackagedFood: Bool = false
    @State private var isPresentingPackagedFoodDetail: Bool = false
    @State private var isPresentingUnknownBarcodePrompt: Bool = false

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Global Botanical Wallpaper Background (Image 4 across all screens)
            Image("botanical_wallpaper")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // Screen content switching based on selectedTab
            Group {
                switch selectedTab {
                case .home:
                    HomeView(
                        viewModel: HomeViewModel(
                            getDailySummaryUseCase: environment.getDailySummaryUseCase,
                            mealRepository: environment.mealRepository,
                            userRepository: environment.userRepository,
                            getDailyHydrationUseCase: environment.getDailyHydrationUseCase,
                            addHydrationUseCase: environment.addHydrationUseCase
                        ),
                        onScanTapped: {
                            selectedTab = .scan
                        },
                        onLogManualTapped: {
                            isPresentingManualLog = true
                        },
                        onOpenSettings: {
                            isPresentingSettings = true
                        },
                        onQuickLogDish: { item in
                            let meal = MealRecord(mealType: .lunch, items: [item])
                            Task {
                                try? await environment.logMealUseCase.execute(meal: meal)
                            }
                        },
                        onOpenDiary: {
                            selectedTab = .history
                        }
                    )

                case .scan:
                    FoodRecognitionView(
                        viewModel: FoodRecognitionViewModel(
                            recognizeFoodUseCase: environment.recognizeFoodUseCase,
                            logMealUseCase: environment.logMealUseCase
                        ),
                        onMealSaved: { _ in
                            // Seamlessly switch to Meal Diary to inspect the logged meal
                            selectedTab = .history
                        },
                        onDismiss: {
                            selectedTab = .home
                        }
                    )

                case .history:
                    MealHistoryView(
                        viewModel: MealHistoryViewModel(
                            getMealHistoryUseCase: environment.getMealHistoryUseCase
                        )
                    )

                case .stats:
                    NutritionAnalyticsView(
                        viewModel: NutritionAnalyticsViewModel(
                            getNutritionAnalyticsUseCase: environment.getNutritionAnalyticsUseCase
                        ),
                        onNavigateToLog: {
                            isPresentingManualLog = true
                        },
                        onNavigateToScan: {
                            selectedTab = .scan
                        }
                    )

                case .profile:
                    ProfileView(
                        viewModel: ProfileViewModel(
                            userRepository: environment.userRepository,
                            authenticationRepository: environment.authenticationRepository
                        ),
                        onOpenSettings: {
                            isPresentingSettings = true
                        },
                        onOpenAccount: {
                            authInitialStep = .accountManagement
                            isPresentingAuth = true
                        },
                        onOpenLogin: {
                            authInitialStep = .login
                            isPresentingAuth = true
                        },
                        onOpenRegister: {
                            authInitialStep = .register
                            isPresentingAuth = true
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Floating Bottom Navigation Bar (Matching Visual Reference)
            CustomFloatingTabBar(
                selectedTab: $selectedTab,
                onScanTapped: {
                    selectedTab = .scan
                }
            )
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .fullScreenCover(isPresented: $isPresentingManualLog) {
            LogMealView(
                viewModel: LogMealViewModel(
                    logMealUseCase: environment.logMealUseCase,
                    getCustomFoodsUseCase: environment.getCustomFoodsUseCase,
                    getRecipesUseCase: environment.getRecipesUseCase,
                    getPackagedFoodsUseCase: environment.getPackagedFoodsUseCase,
                    unitFormattingService: environment.unitFormattingService,
                    hapticFeedbackService: environment.hapticFeedbackService,
                    onDismiss: { isPresentingManualLog = false }
                ),
                onCancel: { isPresentingManualLog = false }
            )
        }
        .fullScreenCover(isPresented: $isPresentingSettings) {
            SettingsView(onOpenAccount: {
                isPresentingAuth = true
            })
        }
        .fullScreenCover(isPresented: $isPresentingAuth, onDismiss: {
            NotificationCenter.default.post(name: NSNotification.Name("NutriLensAuthSessionChanged"), object: nil)
        }) {
            AuthCoordinatorView(
                viewModel: environment.makeAuthViewModel(
                    initialStep: ProcessInfo.processInfo.arguments.contains("-startAuthLogin") ? .login : (ProcessInfo.processInfo.arguments.contains("-startAuthWelcome") ? .welcome : authInitialStep),
                    onAuthCompleted: {
                        isPresentingAuth = false
                    }
                ),
                onDismiss: {
                    isPresentingAuth = false
                }
            )
        }
        .fullScreenCover(isPresented: $isPresentingMyFoods) {
            MyFoodsAndRecipesView()
        }
        .sheet(isPresented: $isPresentingCreateFood) {
            CreateEditCustomFoodView()
        }
        .fullScreenCover(isPresented: $isPresentingSampleRecipeDetail) {
            RecipeDetailView(recipe: MockRecipeRepository.sampleRecipes.first ?? Recipe(name: "Salad Ức Gà Thảo Mộc", servings: 2))
        }
        .fullScreenCover(isPresented: $isPresentingWeeklyPlanner) {
            WeeklyMealPlannerView()
        }
        .sheet(isPresented: $isPresentingAddPlannedMeal) {
            AddPlannedMealSheet(initialDate: Date(), initialCategory: .lunch) { _ in }
        }
        .sheet(isPresented: $isPresentingPlannedFoodPicker) {
            PlannedFoodSourcePickerSheet { _ in }
        }
        .sheet(isPresented: $isPresentingPlannedMealDetail) {
            let sampleDish = VietnameseNutritionDatabase.dishes.first!
            let sampleMeal = PlannedMeal(
                scheduledDate: Date(),
                mealCategory: .lunch,
                foodItems: [
                    PlannedFoodItem.fromVietnameseDish(sampleDish, quantityGrams: 450)
                ],
                notes: "Bữa trưa công sở giàu đạm",
                status: .planned
            )
            PlannedMealDetailSheet(
                meal: sampleMeal,
                onLogToDiary: {},
                onMarkSkipped: {},
                onRestore: {},
                onDuplicateToTomorrow: {},
                onEdit: {},
                onDelete: {}
            )
        }
        .sheet(isPresented: $isPresentingCopyDayPlan) {
            CopyDayPlanSheet(sourceDate: Date(), mealsCount: 3) { _, _, _ in }
        }
        .sheet(isPresented: $isPresentingLogPlannedMealConfirmation) {
            let sampleDish = VietnameseNutritionDatabase.dishes.first!
            let sampleMeal = PlannedMeal(
                scheduledDate: Date(),
                mealCategory: .lunch,
                foodItems: [
                    PlannedFoodItem.fromVietnameseDish(sampleDish, quantityGrams: 450)
                ],
                notes: "Bữa trưa dinh dưỡng",
                status: .planned
            )
            LogPlannedMealConfirmationSheet(plannedMeal: sampleMeal) { _, _, _, _ in }
        }
        .fullScreenCover(isPresented: $isPresentingSmartSuggestions) {
            SmartSuggestionsView(viewModel: environment.makeSmartSuggestionsViewModel())
        }
        .sheet(isPresented: $isPresentingSuggestionExplanation) {
            let sampleDish = VietnameseNutritionDatabase.dishes.first!
            let sampleSuggestion = MealSuggestion(
                foodSource: .vietnameseDatabase,
                sourceId: sampleDish.slug,
                displayName: sampleDish.vietnameseName,
                dishCategory: sampleDish.category,
                suggestedServing: "1 phần chuẩn (\(Int(sampleDish.standardServingGrams))g)",
                suggestedServingGrams: sampleDish.standardServingGrams,
                availableNutritionEstimate: PlannedNutritionSnapshot(
                    calories: sampleDish.caloriesPerServing,
                    proteinGrams: sampleDish.proteinPerServing,
                    carbGrams: sampleDish.carbPerServing,
                    fatGrams: sampleDish.fatPerServing,
                    fiberGrams: sampleDish.fiberPerServing
                ),
                recommendationScore: 88,
                explanationReasons: ["Phù hợp bữa trưa", "Giàu đạm (32g)", "Đổi món so với hôm qua"],
                explanationFactors: [
                    SuggestionExplanationFactor(title: "Phù hợp với bữa trưa", detail: "Món ăn truyền thống thường được ưa chuộng cho bữa trưa.", systemIcon: "sun.max.fill", scoreImpact: 25),
                    SuggestionExplanationFactor(title: "Hàm lượng đạm cao (32g Protein)", detail: "Cung cấp lượng đạm dồi dào, phù hợp mục tiêu dinh dưỡng cơ bắp.", systemIcon: "figure.strengthtraining.traditional", scoreImpact: 20),
                    SuggestionExplanationFactor(title: "Giúp đổi vị & đa dạng thực đơn", detail: "Bạn chưa dùng món này gần đây, thích hợp để làm mới khẩu vị trong tuần.", systemIcon: "leaf.arrow.triangle.circlepath", scoreImpact: 10)
                ],
                ingredientVerificationStatus: .verified,
                documentedIngredients: VietnameseDishIngredientMetadata.metadata(forSlug: sampleDish.slug)?.documentedIngredients ?? [],
                allergenWarnings: VietnameseDishIngredientMetadata.metadata(forSlug: sampleDish.slug)?.allergens ?? []
            )
            RecommendationExplanationSheet(suggestion: sampleSuggestion) {
                isPresentingSuggestionExplanation = false
            }
        }
        .sheet(isPresented: $isPresentingIngredientReview) {
            let sampleDish = VietnameseNutritionDatabase.dishes.first!
            let meta = VietnameseDishIngredientMetadata.metadata(forSlug: sampleDish.slug)
            let sampleSuggestion = MealSuggestion(
                foodSource: .vietnameseDatabase,
                sourceId: sampleDish.slug,
                displayName: sampleDish.vietnameseName,
                dishCategory: sampleDish.category,
                suggestedServing: "1 phần chuẩn (\(Int(sampleDish.standardServingGrams))g)",
                suggestedServingGrams: sampleDish.standardServingGrams,
                availableNutritionEstimate: PlannedNutritionSnapshot(
                    calories: sampleDish.caloriesPerServing,
                    proteinGrams: sampleDish.proteinPerServing,
                    carbGrams: sampleDish.carbPerServing,
                    fatGrams: sampleDish.fatPerServing,
                    fiberGrams: sampleDish.fiberPerServing
                ),
                recommendationScore: 88,
                explanationReasons: ["Phù hợp bữa trưa"],
                ingredientVerificationStatus: .verified,
                documentedIngredients: meta?.documentedIngredients ?? [],
                allergenWarnings: meta?.allergens ?? []
            )
            IngredientReviewSheet(
                suggestion: sampleSuggestion,
                userProfile: UserDietaryProfile()
            ) {
                isPresentingIngredientReview = false
            }
        }
        .sheet(isPresented: $isPresentingDietaryPreferences) {
            EditDietaryPreferencesSheet(
                initialProfile: UserDietaryProfile(),
                onSave: { _ in isPresentingDietaryPreferences = false },
                onClear: { isPresentingDietaryPreferences = false }
            )
        }
        .sheet(isPresented: $isPresentingAddSuggestionToPlan) {
            let sampleDish = VietnameseNutritionDatabase.dishes.first!
            let sampleSuggestion = MealSuggestion(
                foodSource: .vietnameseDatabase,
                sourceId: sampleDish.slug,
                displayName: sampleDish.vietnameseName,
                dishCategory: sampleDish.category,
                suggestedServing: "1 phần chuẩn (\(Int(sampleDish.standardServingGrams))g)",
                suggestedServingGrams: sampleDish.standardServingGrams,
                availableNutritionEstimate: PlannedNutritionSnapshot(
                    calories: sampleDish.caloriesPerServing,
                    proteinGrams: sampleDish.proteinPerServing,
                    carbGrams: sampleDish.carbPerServing,
                    fatGrams: sampleDish.fatPerServing,
                    fiberGrams: sampleDish.fiberPerServing
                ),
                recommendationScore: 88,
                explanationReasons: ["Phù hợp bữa trưa"],
                ingredientVerificationStatus: .verified
            )
            AddSuggestionToPlanSheet(
                suggestion: sampleSuggestion,
                initialDate: Date(),
                initialCategory: .lunch
            ) { _, _, _, _, _ in
                isPresentingAddSuggestionToPlan = false
            }
        }
        // Phase 06: Barcode Scanner & Packaged Food Management
        .fullScreenCover(isPresented: $isPresentingBarcodeScanner) {
            BarcodeScannerView(viewModel: environment.makeBarcodeScannerViewModel())
        }
        .fullScreenCover(isPresented: $isPresentingPackagedFoodLibrary) {
            PackagedFoodLibraryView(viewModel: environment.makeBarcodeScannerViewModel())
        }
        .sheet(isPresented: $isPresentingScannedProductResult) {
            let vm = environment.makeBarcodeScannerViewModel()
            let sampleProduct = BundledPackagedFoodCatalogue.shared.items.first!
            let _ = {
                vm.activeProduct = sampleProduct
                vm.activeLookupSource = .bundledCatalogue
                vm.evaluateSafety(for: sampleProduct)
            }()
            ScannedProductResultSheet(viewModel: vm)
        }
        .sheet(isPresented: $isPresentingCreatePackagedFood) {
            let vm = environment.makeBarcodeScannerViewModel()
            CreateEditPackagedFoodView(viewModel: vm, initialBarcode: "8939999888882")
        }
        .sheet(isPresented: $isPresentingPackagedFoodDetail) {
            let vm = environment.makeBarcodeScannerViewModel()
            let sampleProduct = BundledPackagedFoodCatalogue.shared.items[1] // Mì Hảo Hảo
            NavigationStack {
                PackagedFoodDetailView(viewModel: vm, product: sampleProduct)
            }
        }
        .alert("Chưa tìm thấy thông tin sản phẩm", isPresented: $isPresentingUnknownBarcodePrompt) {
            Button("Thêm sản phẩm mới") {}
            Button("Thử lại", role: .cancel) {}
        } message: {
            Text("Mã vạch 8930000000019 chưa có trong danh mục của NutriLens. Bạn có muốn tự thêm vào thư viện cá nhân?")
        }
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("-startTabHistory") {
                selectedTab = .history
            } else if ProcessInfo.processInfo.arguments.contains("-startTabProfile") {
                selectedTab = .profile
            } else if ProcessInfo.processInfo.arguments.contains("-startAccountSecurity") {
                selectedTab = .profile
                authInitialStep = .accountManagement
                isPresentingAuth = true
            } else if ProcessInfo.processInfo.arguments.contains("-startAuthWelcome") {
                authInitialStep = .welcome
                isPresentingAuth = true
            } else if ProcessInfo.processInfo.arguments.contains("-startAuthLogin") {
                authInitialStep = .login
                isPresentingAuth = true
            } else if ProcessInfo.processInfo.arguments.contains("-startSettings") {
                isPresentingSettings = true
            } else if ProcessInfo.processInfo.arguments.contains("-startManualLog") {
                isPresentingManualLog = true
            } else if ProcessInfo.processInfo.arguments.contains("-startMyFoods") {
                isPresentingMyFoods = true
            } else if ProcessInfo.processInfo.arguments.contains("-startCreateCustomFood") {
                isPresentingCreateFood = true
            } else if ProcessInfo.processInfo.arguments.contains("-startRecipeDetail") {
                isPresentingSampleRecipeDetail = true
            } else if ProcessInfo.processInfo.arguments.contains("-startMealPlanner") {
                isPresentingWeeklyPlanner = true
            } else if ProcessInfo.processInfo.arguments.contains("-startAddPlannedMeal") {
                isPresentingAddPlannedMeal = true
            } else if ProcessInfo.processInfo.arguments.contains("-startPlannedFoodPicker") {
                isPresentingPlannedFoodPicker = true
            } else if ProcessInfo.processInfo.arguments.contains("-startPlannedMealDetail") {
                isPresentingPlannedMealDetail = true
            } else if ProcessInfo.processInfo.arguments.contains("-startCopyDayPlan") {
                isPresentingCopyDayPlan = true
            } else if ProcessInfo.processInfo.arguments.contains("-startDiaryLoggingConfirmation") {
                isPresentingLogPlannedMealConfirmation = true
            } else if ProcessInfo.processInfo.arguments.contains("-startSmartSuggestions") {
                isPresentingSmartSuggestions = true
            } else if ProcessInfo.processInfo.arguments.contains("-startSuggestionExplanation") {
                isPresentingSuggestionExplanation = true
            } else if ProcessInfo.processInfo.arguments.contains("-startIngredientReview") {
                isPresentingIngredientReview = true
            } else if ProcessInfo.processInfo.arguments.contains("-startDietaryPreferences") {
                isPresentingDietaryPreferences = true
            } else if ProcessInfo.processInfo.arguments.contains("-startAddSuggestionToPlan") {
                isPresentingAddSuggestionToPlan = true
            } else if ProcessInfo.processInfo.arguments.contains("-startBarcodeScanner") {
                isPresentingBarcodeScanner = true
            } else if ProcessInfo.processInfo.arguments.contains("-startScannedProductResult") {
                isPresentingScannedProductResult = true
            } else if ProcessInfo.processInfo.arguments.contains("-startCreatePackagedFood") {
                isPresentingCreatePackagedFood = true
            } else if ProcessInfo.processInfo.arguments.contains("-startPackagedFoodDetail") {
                isPresentingPackagedFoodDetail = true
            } else if ProcessInfo.processInfo.arguments.contains("-startPackagedFoodLibrary") {
                isPresentingPackagedFoodLibrary = true
            } else if ProcessInfo.processInfo.arguments.contains("-startUnknownBarcode") {
                isPresentingBarcodeScanner = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isPresentingUnknownBarcodePrompt = true
                }
            } else if ProcessInfo.processInfo.arguments.contains("-startTabHistoryWithBarcodeMeal") {
                selectedTab = .history
                let sampleProduct = BundledPackagedFoodCatalogue.shared.items.first!
                let mealItem = sampleProduct.toFoodItem()
                let meal = MealRecord(
                    timestamp: Date(),
                    mealType: .breakfast,
                    items: [mealItem]
                )
                Task {
                    try? await environment.mealRepository.saveMeal(meal)
                }
            }
        }
    }
}

// MARK: - Custom Floating Tab Bar
private struct CustomFloatingTabBar: View {
    @Binding var selectedTab: AppTab
    let onScanTapped: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Tab 1: Trang chủ
            TabBarItemButton(
                title: "Trang chủ",
                icon: "house.fill",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }

            // Tab 2: Nhật ký (Open book outline matching reference)
            TabBarItemButton(
                title: "Nhật ký",
                icon: "book",
                isSelected: selectedTab == .history
            ) {
                selectedTab = .history
            }

            // Tab 3 (Center Elevated Button): Quét with Viewfinder Brackets
            Button {
                #if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                #endif
                onScanTapped()
            } label: {
                VStack(spacing: 3) {
                    ZStack {
                        // White opaque protective dome backing (prevents any scroll content or text from showing behind button)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 58, height: 58)
                            .shadow(color: Color.black.opacity(0.06), radius: 5, x: 0, y: 2)

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.22, green: 0.72, blue: 0.44), // #38B770
                                        Color(red: 0.10, green: 0.58, blue: 0.34)  // #1A9457
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)
                            .shadow(color: Color(red: 0.12, green: 0.58, blue: 0.34).opacity(0.38), radius: 8, x: 0, y: 4)

                        // Viewfinder 4 corner brackets + camera icon matching reference
                        ZStack {
                            CornerBracketsShape(bracketLength: 6.5, cornerRadius: 2.5)
                                .stroke(Color.white, style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                                .frame(width: 25, height: 25)

                            Image(systemName: "camera.fill")
                                .font(.system(size: 11.5, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(y: -14)

                    Text("Quét")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.10, green: 0.25, blue: 0.18))
                        .offset(y: -12)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)

            // Tab 4: Thống kê
            TabBarItemButton(
                title: "Thống kê",
                icon: "chart.bar",
                isSelected: selectedTab == .stats
            ) {
                selectedTab = .stats
            }

            // Tab 5: Cá nhân
            TabBarItemButton(
                title: "Cá nhân",
                icon: "person",
                isSelected: selectedTab == .profile
            ) {
                selectedTab = .profile
            }
        }
        .frame(height: 64)
        .padding(.horizontal, 10)
        .background(
            FloatingTabBarShape()
                .fill(Color.white)
        )
        .overlay(
            FloatingTabBarShape()
                .stroke(Color(red: 0.93, green: 0.95, blue: 0.94), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 6)
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
}

// MARK: - Shapes for Floating Tab Bar
private struct FloatingTabBarShape: Shape {
    var cornerRadius: CGFloat = 34
    var bumpHeight: CGFloat = 16
    var bumpWidth: CGFloat = 80

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let r = cornerRadius
        let cx = w / 2
        let halfBump = bumpWidth / 2

        path.move(to: CGPoint(x: r, y: 0))

        // Left straight top edge
        path.addLine(to: CGPoint(x: cx - halfBump, y: 0))

        // Smooth cubic hill over center button
        path.addCurve(
            to: CGPoint(x: cx, y: -bumpHeight),
            control1: CGPoint(x: cx - halfBump + 18, y: 0),
            control2: CGPoint(x: cx - 20, y: -bumpHeight)
        )
        path.addCurve(
            to: CGPoint(x: cx + halfBump, y: 0),
            control1: CGPoint(x: cx + 20, y: -bumpHeight),
            control2: CGPoint(x: cx + halfBump - 18, y: 0)
        )

        // Right straight top edge
        path.addLine(to: CGPoint(x: w - r, y: 0))

        // Top-right corner
        path.addArc(
            center: CGPoint(x: w - r, y: r),
            radius: r,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        // Right edge
        path.addLine(to: CGPoint(x: w, y: h - r))

        // Bottom-right corner
        path.addArc(
            center: CGPoint(x: w - r, y: h - r),
            radius: r,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: r, y: h))

        // Bottom-left corner
        path.addArc(
            center: CGPoint(x: r, y: h - r),
            radius: r,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        // Left edge
        path.addLine(to: CGPoint(x: 0, y: r))

        // Top-left corner
        path.addArc(
            center: CGPoint(x: r, y: r),
            radius: r,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        path.closeSubpath()
        return path
    }
}

private struct CornerBracketsShape: Shape {
    var bracketLength: CGFloat = 7
    var cornerRadius: CGFloat = 2.5

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let l = min(bracketLength, rect.width / 2)
        let r = min(cornerRadius, l / 2)
        let w = rect.width
        let h = rect.height

        // Top-Left ┌
        path.move(to: CGPoint(x: 0, y: l))
        path.addLine(to: CGPoint(x: 0, y: r))
        path.addQuadCurve(to: CGPoint(x: r, y: 0), control: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: l, y: 0))

        // Top-Right ┐
        path.move(to: CGPoint(x: w - l, y: 0))
        path.addLine(to: CGPoint(x: w - r, y: 0))
        path.addQuadCurve(to: CGPoint(x: w, y: r), control: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: w, y: l))

        // Bottom-Right ┘
        path.move(to: CGPoint(x: w, y: h - l))
        path.addLine(to: CGPoint(x: w, y: h - r))
        path.addQuadCurve(to: CGPoint(x: w - r, y: h), control: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: w - l, y: h))

        // Bottom-Left └
        path.move(to: CGPoint(x: l, y: h))
        path.addLine(to: CGPoint(x: r, y: h))
        path.addQuadCurve(to: CGPoint(x: 0, y: h - r), control: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: 0, y: h - l))

        return path
    }
}

private struct TabBarItemButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            action()
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? Color(red: 0.12, green: 0.60, blue: 0.35) : Color(red: 0.35, green: 0.40, blue: 0.45))
                    .frame(height: 24)

                Text(title)
                    .font(.system(size: 10.5, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? Color(red: 0.12, green: 0.60, blue: 0.35) : Color(red: 0.35, green: 0.40, blue: 0.45))

                // Active Indicator bar under selected tab
                if isSelected {
                    Capsule()
                        .fill(Color(red: 0.12, green: 0.60, blue: 0.35))
                        .frame(width: 24, height: 3)
                        .padding(.top, 1)
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(width: 24, height: 3)
                        .padding(.top, 1)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
