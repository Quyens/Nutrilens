# NutriLens V1.0 — Visual UI/UX Redesign Report
## Profile Dashboard, Account & Security, Nutrition Goals & Authentication

**Date:** 2026-11-06  
**Role:** Senior Apple iOS UI/UX Designer, Apple HIG Specialist & Principal SwiftUI Engineer  
**Scope:** Visual Redesign (UI Only) — Fresh Premium Botanical Identity with Full Wallpaper Integration  
**Platform:** Native iOS 17+ | Swift 5.10 / Xcode 16.5  
**Automated Testing Status:** **DEFERRED — UI Redesign Iteration** (Zero test runs per project instructions)  
**Compilation Status:** Clean Build (`** BUILD SUCCEEDED **`) with 0 errors and 0 compiler warnings.

---

## 1. Executive Summary & Design Pivot

Following user feedback (*"tôi không ưng thiết kế profile và login kiểu này hayx thiết kế lại đi và app tôi có dùng background mà sao bạn không dunngf"*), a comprehensive audit of background handling was conducted across the application.

### Key Finding & Fix
In [`HomeView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Home/HomeView.swift) and [`MainTabView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/App/AppRouter.swift), NutriLens uses `Image("botanical_wallpaper").resizable().scaledToFill().ignoresSafeArea()` at 100% full opacity, allowing signature lush green tropical leaves to organically frame the screen around pure white floating cards.

In the previous iteration, an opaque canvas background (`AppColors.canvasBackground`) combined with a reduced wallpaper opacity (8–12%) was washing out the botanical artwork.

**In this iteration:**
1. **Full Wallpaper Integration:** All redesigned screens ([`ProfileView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Profile/ProfileView.swift), [`WelcomeAuthView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/WelcomeAuthView.swift), [`LoginView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/LoginView.swift), [`AccountManagementView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/AccountManagementView.swift), [`NutritionGoalsView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Profile/NutritionGoalsView.swift)) now use `Image("botanical_wallpaper")` at full opacity without blocking canvas layers.
2. **Floating Pure White Cards:** All interactive content is packaged in crisp, pure white rounded cards (`Color.white`) with subtle borders (`AppColors.border`) and soft elevation shadows (`shadow(color: Color.black.opacity(0.04), radius: 10, y: 3)`).
3. **Dynamic Island Safe Alignment:** Fixed header positions across all views with custom top bars that clear the Dynamic Island and status bar gracefully.
4. **Calorie & Macro Typography Stability:** Calorie display formatted on a single crisp line (`2.000 kcal / ngày`) with 3 macro pills (Đạm, Carb, Béo).

---

## 2. Visual Identity & Screen Details

````carousel
![Profile Dashboard](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/profile_redesign.png)
<!-- slide -->
![Account & Security](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/account_security_redesign.png)
<!-- slide -->
![Personal Nutrition Goals](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/nutrition_goals_redesign.png)
<!-- slide -->
![Authentication Gateway](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/authentication_redesign.png)
<!-- slide -->
![Email Login](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/login_redesign.png)
````

### Screen 01: Profile Dashboard (`ProfileView.swift`)
- **Background:** Full native `botanical_wallpaper` background visible at top corners, edges, and behind floating cards.
- **Top Bar:** Floating custom bar with white circle leaf badge, title "Hồ sơ cá nhân", subtitle "Trung tâm sức khỏe & mục tiêu", and a floating white circle settings gear button.
- **Personal Hero Card:** White rounded card (radius 22) featuring an avatar ring with botanical accents, initials or guest icon, active state indicator, and dual pills (`[Đã xác thực / Chế độ Khách]` and `[Ăn uống lành mạnh]`).
- **Nutrition Targets Card:** Highlighting daily energy budget (`2.000 kcal / ngày`) alongside three macro mini pills: Đạm (125g), Carb (250g), and Béo (55g) with accent color bars. Includes a quick "Thiết lập >" pill button opening the goals editor.
- **Quick Metrics Widgets:** Side-by-side cards for *Thể trạng* (Cân nặng & BMI) and *Nước uống* (2.000 ml / ngày).
- **Grouped Settings:** Two floating white cards for *Tài khoản & Dữ liệu* and *Ứng dụng & Thiết lập*.
- **Bottom Clearance:** 130 pt clearance ensuring floating bottom navigation never obscures content.

### Screen 02: Account & Security (`AccountManagementView.swift`)
- **Truthful Identity:** Accurately reflects authentication state. Guest mode clearly displays "Tài khoản Khách" with zero fake emails or false claims.
- **On-Device Storage Callout:** Reassuring card explaining that local SwiftData storage protects user meal logs and nutrition history 100% on the iPhone.
- **Account Actions:** Clean navigation rows for account creation/linking and local data inspection.
- **Destructive Zone:** Distinct red-accented danger zone separating device reset from account deletion.

### Screen 03: Nutrition Goals (`NutritionGoalsView.swift`)
- **Botanical Header:** Leaf circle badge and concise guidance text.
- **Dietary Goal Selector:** Interactive radio options (*Duy trì cân nặng*, *Giảm cân an toàn*, *Tăng cơ săn chắc*, *Ăn uống lành mạnh*) with active botanical green rings.
- **Daily Calorie Target Stepper:** Large monospaced display with interactive `-` and `+` 50 kcal buttons.
- **Macro Breakdown Cards:** Dynamic calculation for Protein (25%), Carbs (50%), and Fat (25%).
- **Save Action:** Primary botanical button wired directly to `ProfileViewModel.updateProfile(...)`.

### Screen 04: Authentication Gateway (`WelcomeAuthView.swift`)
- **Hero Branding:** Floating white circular leaf emblem with emerald-to-forest gradient, large rounded NutriLens title, and subtitle.
- **Feature Tags:** Mini white capsules highlighting *AI On-Device*, *5.000+ Món Việt*, and *Bảo Mật Cục Bộ*.
- **Floating Action Card:**
  - High-contrast native Apple Sign-In button (`Tiếp tục với Apple`).
  - Subtle divider ("HOẶC").
  - Primary button: `Đăng nhập với Email`.
  - Secondary button: `Tạo tài khoản mới`.
  - Text action: `Tiếp tục với vai trò khách`.

### Screen 05: Email Login (`LoginView.swift`)
- **Navigation:** Floating capsule back button (`< Quay lại`) and brand mark.
- **Greeting:** "Chào mừng trở lại! 👋" and descriptive subtitle.
- **Feature Strip:** Food recognition highlight ("Dinh dưỡng món Việt chuẩn calo • Quét AI & ghi nhận 5.000+ món").
- **Floating Form Card:** Soft-mint botanical text fields for Email and Password (with interactive show/hide toggle), "Quên mật khẩu?" link, and "Đăng nhập" button.
- **Mock Autofill:** When mock mode is enabled, displays a clear test helper pill (`demo@nutrilens.vn`).

---

## 3. Simulator Screenshots Deliverable

All 5 screenshots were captured on **iPhone 17 (iOS Simulator 26.5 SDK)**:

| Screen | File Name | Size | Resolution | Preview Description |
|---|---|---|---|---|
| **1. Profile Dashboard** | `profile_redesign.png` | 1.6 MB | 1206 × 2622 | Custom top bar clear of Dynamic Island, hero card, 2000 kcal target, macro pills, metrics widgets, grouped menu, and floating tab bar. |
| **2. Account & Security** | `account_security_redesign.png` | 2.4 MB | 1206 × 2622 | Identity card, on-device SwiftData security banner, account options, and danger zone. |
| **3. Nutrition Goals** | `nutrition_goals_redesign.png` | 1.8 MB | 1206 × 2622 | Header banner, 4 dietary goal radio cards, 2000 kcal stepper, and macro breakdown cards. |
| **4. Authentication Welcome** | `authentication_redesign.png` | 2.1 MB | 1206 × 2622 | Circular leaf emblem, NutriLens title, 3 feature capsules, Apple Sign-In, Email login, Register, and Guest mode. |
| **5. Email Login** | `login_redesign.png` | 2.1 MB | 1206 × 2622 | Capsule back button, greeting, feature banner, floating card with email & password fields, and login button. |

All screenshot files are saved at:
- `reports/screenshots/profile_redesign/`
- `<appDataDir>/brain/<conversation-id>/screenshots/profile_redesign/`

---

## 4. Architecture & Integrity Checklist

1. **Wallpaper Fidelity:** `botanical_wallpaper` used directly at 100% opacity without canvas overlay washing out the artwork.
2. **Clean Architecture:** Zero changes to SwiftData schemas, domain entities, use cases, or repository interfaces.
3. **No Backend Simulation:** No fake cloud sync, no mock production JWTs, no hardcoded secrets.
4. **Automated Tests:** **Strictly DEFERRED** per redesign task instructions. Build succeeded with zero compiler warnings/errors.
