# NutriLens V1.0 — Visual UI/UX Redesign Report
## Profile Dashboard, Account & Security, Nutrition Goals & Authentication

**Date:** 2026-11-06  
**Role:** Senior iOS Product Designer, Apple HIG Specialist & Principal SwiftUI Engineer  
**Scope:** Visual Redesign (UI Only) — Fresh Premium Botanical Identity  
**Platform:** Native iOS 17+ | Swift 5.10 / Xcode 16.5  
**Automated Testing Status:** **DEFERRED — UI Redesign Iteration** (Zero test runs per specification)  
**Compilation Status:** Clean Build (`** BUILD SUCCEEDED **`) with 0 errors and 0 compiler warnings.

---

## 1. Design System Audit & Foundations

Prior to implementation, an exhaustive audit was performed across [`HomeView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Home/HomeView.swift), [`FoodExplorerView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/FoodExplorer/FoodExplorerView.swift), [`MealHistoryView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/History/MealHistoryView.swift), [`NutritionAnalyticsView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Nutrition/NutritionAnalyticsView.swift), and the design tokens in `AppColors.swift`, `AppTypography.swift`, `AppSpacing.swift`, and `AppRadius.swift`.

### 1.1 Color Palette & Surface Tokens
- **Canvas Background:** `AppColors.canvasBackground` (`#FCFDF9` / Warm Ivory `#F8F7F1`) overlaid with a subtle botanical texture (`botanical_wallpaper` at 8–12% opacity) for an organic, tactile aesthetic matching Home and Diary.
- **Forest Green (Typography & Headings):** `AppColors.textPrimary` (`#233B2D` / `#294638`), providing strong contrast and warmth without the harshness of pure black.
- **Botanical Green (Primary Action):** `AppColors.primaryGreen` (`#35A968` / `#2E9464`), driving primary actions and selection states.
- **Soft Sage (Secondary Surfaces):** `AppColors.surfaceSecondary` (`#E9F6E9` / `#E7F0E5`), grounding card badges, option icons, and secondary buttons.
- **Card Surfaces:** Pure white `#FFFFFF` in Light Mode with 1 pt subtle border (`#E8EEE7`) and soft shadow (`Color.black.opacity(0.025)`, radius 4, y 1.5).
- **Macro Accent Colors:**
  - Calorie / Energy: `AppColors.primaryGreen` (`#35A968`)
  - Protein: `AppColors.proteinBlue` (`#6CA9E8`)
  - Carbs: `AppColors.carbsOrange` (`#F3A34B`)
  - Fat: `AppColors.fatCoral` (`#E97970`)

### 1.2 Geometry & Typography Hierarchy
- **Corner Radii:** Cards use continuous 20 pt curvature (`AppRadius.card`), buttons use 16 pt (`AppRadius.button`), modal sheets use 24 pt (`AppRadius.sheet`).
- **Typography Scale:** Full Dynamic Type support via `AppTypography` (`.heroTitle`, `.screenTitle`, `.sectionTitle`, `.cardTitle`, `.body`, `.captionBold`).
- **Tabular Figures:** Numbers formatted with `.monospacedDigit()` for stable layouts during dynamic value updates.

---

## 2. Creative Design Concept & Key Visual Improvements

### Screen 01: Profile Dashboard (`ProfileView.swift`)
- **Compact Botanical Hero Header:** Replaced the generic oversized SF Symbol avatar with [`BotanicalProfileHeader.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Core/DesignSystem/BotanicalProfileHeader.swift), featuring an organic dual-ring badge, initials/leaf emblem, active status dot, display name, account type pill (`[Chế độ Khách]` or `[Đã xác thực]`), and dietary goal tag (`[Ăn uống lành mạnh]`).
- **Featured Nutrition Goals Card:** Replaced unstyled rows with [`NutritionGoalsCard.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Core/DesignSystem/NutritionGoalsCard.swift), featuring a flame icon header, calorie budget target, mini macro pills (Calo, Đạm, Carb, Béo) with semantic accent bars, and a direct "Thiết lập >" action leading to the goal editor.
- **Unified 5-Row Profile Menu:** Consolidated scattered cards into [`ProfileMenuCard.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Core/DesignSystem/ProfileMenuCard.swift), grouping:
  1. *Thông tin cá nhân* (Personal details sheet)
  2. *Sở thích dinh dưỡng & Dị ứng* (Preferences & dietary restrictions)
  3. *Tài khoản & Bảo mật* (Launches Account & Security flow)
  4. *Cài đặt ứng dụng* (App settings & privacy)
  5. *Giới thiệu về NutriLens* (About app mission & v1.0.0 build)
  All rows feature forest-green icons in soft-mint rounded containers and trailing chevrons.
- **Native iOS Header:** Compact "Hồ sơ" navigation title with an upper-right gear icon seamlessly wired to Settings.

---

### Screen 02: Account & Security (`AccountManagementView.swift`)
- **Refined Identity Card:** Shows true account state. For guests, displays "Tài khoản khách" with guest badge; **zero fabricated email addresses and zero fake verified badges**.
- **Local Storage Information Banner:** Added a calming sage callout explaining that online cloud synchronization will arrive in a future phase and that all local meal logs and analytics are safely stored 100% on-device.
- **Grouped Account Options:** Clear rows for signing in / linking accounts and reviewing on-device SwiftData records.
- **Restrained Danger Zone:** Visually distinct section clearly separating "Xóa dữ liệu trên thiết bị" (local guest wipe) from "Xóa tài khoản" (authenticated account deletion), preserving existing confirmation dialogs.

---

### Screen 03: Personal Nutrition Goals (`NutritionGoalsView.swift`)
- **Dedicated Sheet Presentation:** Beautiful full-screen sheet presenting personal nutrition targets without imposing rigid restrictions.
- **Botanical Header:** Leaf circle badge, title "Mục tiêu dinh dưỡng cá nhân", and guidance text.
- **Dietary Goal Selector:** Interactive cards for *Duy trì cân nặng*, *Giảm cân an toàn*, *Tăng cơ săn chắc*, and *Ăn uống lành mạnh* with active botanical green rings and radio indicators.
- **Daily Energy Target Stepper:** Large monospaced calorie counter with responsive +/- 50 kcal increment buttons.
- **Macro Breakdown Cards:** Compact cards showing dynamic calculated grams and ratios for Protein (25%), Carbs (50%), and Fat (25%).
- **Primary Save Action:** Botanical green "Lưu mục tiêu" button wired directly to `ProfileViewModel.updateProfile(...)`.

---

### Screen 04: Authentication Gateway (`WelcomeAuthView.swift`, `LoginView.swift`, etc.)
- **NutriLens Hero Branding:** Glowing dual-ring botanical emblem with leaf icon, bold NutriLens wordmark, and approved slogan: *"Theo dõi dinh dưỡng dễ dàng, khoa học và cá nhân hóa."*
- **Feature Highlights:** Subtle pill badges highlighting *AI On-Device*, *Món Việt Chuẩn*, and *Bảo Mật 100%*.
- **Action Hierarchy:**
  1. Apple Sign-In button (`Tiếp tục với Apple` in native black styling)
  2. Primary botanical action: `Đăng nhập với Email`
  3. Secondary soft-mint action: `Tạo tài khoản mới`
  4. Seamless guest continuation: `Tiếp tục với vai trò khách`
- **Form Controls:** Introduced [`BotanicalTextField.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Core/DesignSystem/BotanicalTextField.swift) across `LoginView`, `RegisterView`, and `ForgotPasswordView` featuring soft-mint backgrounds, responsive focus borders, and interactive show/hide password controls.

---

## 3. Source Files Modified & Created

### 3.1 New Reusable Components
1. [`NutriLens/Core/DesignSystem/BotanicalProfileHeader.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Core/DesignSystem/BotanicalProfileHeader.swift): Reusable botanical hero card for profile dashboards.
2. [`NutriLens/Core/DesignSystem/NutritionGoalsCard.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Core/DesignSystem/NutritionGoalsCard.swift): Featured card summarizing energy budget and macronutrient breakdown.
3. [`NutriLens/Core/DesignSystem/ProfileMenuCard.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Core/DesignSystem/ProfileMenuCard.swift): Grouped menu container with icon badges, labels, subtitles, and dividers.
4. [`NutriLens/Core/DesignSystem/BotanicalTextField.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Core/DesignSystem/BotanicalTextField.swift): Standard botanical input field with focus state, icon, and password toggle.
5. [`NutriLens/Features/Profile/NutritionGoalsView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Profile/NutritionGoalsView.swift): Dedicated personal nutrition goal configuration interface.

### 3.2 Screens Redesigned
1. [`NutriLens/Features/Profile/ProfileView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Profile/ProfileView.swift): Complete profile dashboard visual redesign.
2. [`NutriLens/Features/Authentication/AccountManagementView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/AccountManagementView.swift): Account & Security interface redesign.
3. [`NutriLens/Features/Authentication/WelcomeAuthView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/WelcomeAuthView.swift): Welcome and authentication landing gateway.
4. [`NutriLens/Features/Authentication/LoginView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/LoginView.swift): Email & password sign-in form.
5. [`NutriLens/Features/Authentication/RegisterView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/RegisterView.swift): New account registration screen.
6. [`NutriLens/Features/Authentication/ForgotPasswordView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/ForgotPasswordView.swift): Password recovery form.
7. [`NutriLens/Features/Authentication/EmailVerificationStatusView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/EmailVerificationStatusView.swift): Email verification status viewer.
8. [`NutriLens/App/AppRouter.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/App/AppRouter.swift): Seamless integration of coordinator and sheet initial steps.

---

## 4. Simulator Screenshots Deliverable

Four real, high-resolution simulator screenshots were captured on **iPhone 17 (iOS Simulator 26.5 SDK)** and saved in `reports/screenshots/profile_redesign/`:

| Screen | File Name | Size | Resolution | Preview Description |
|---|---|---|---|---|
| **1. Profile Dashboard** | `profile_redesign.png` | 1.3 MB | 1206 × 2622 | Compact hero card, NutriUser badge, featured nutrition goals card with 4 macro pills, 5-row menu card, and floating bottom navigation. |
| **2. Account & Security** | `account_security_redesign.png` | 796 KB | 1206 × 2622 | Account identity card, local storage sage information banner, on-device data options, and restrained danger zone. |
| **3. Nutrition Goals** | `nutrition_goals_redesign.png` | 651 KB | 1206 × 2622 | Header banner, 4 dietary goal selector cards, 2000 kcal stepper, and dynamic macro breakdown cards. |
| **4. Authentication** | `authentication_redesign.png` | 1.1 MB | 1206 × 2622 | Dual-ring leaf emblem, NutriLens wordmark, slogan, feature tags, Apple Sign-In, Email login, Register, and Guest action. |

---

## 5. Verification & Non-Functional Compliance

1. **Clean Architecture & Business Logic Preserved:**
   - Zero changes to SwiftData entities or repositories.
   - All ViewModels (`ProfileViewModel`, `AuthViewModel`, `HomeViewModel`) remain untouched in their core business methods.
   - Profile target saving continues through `userRepository.saveUserProfile(updated)`.
   - Core ML models, class mappings, and inference pipelines are 100% untouched.
2. **Apple HIG & Accessibility:**
   - Dynamic Type supported across all new typography tokens.
   - Haptic feedback provided on button interactions (`UIImpactFeedbackGenerator`).
   - Accessible labels defined on all icon-only buttons.
   - Safe areas and bottom floating tab bar clearances strictly respected.
3. **Automated Testing Policy:**
   - As mandated: **No Unit Tests or UI Tests were run during this visual redesign iteration**.
   - Testing status is explicitly marked as **DEFERRED**.

---

## 6. Conclusion & Readiness

The Profile and Authentication visual redesign is complete, verified on the iOS simulator, and aligned with NutriLens's signature **Fresh Premium Botanical** design language.
