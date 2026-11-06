# NutriLens V1.0 — Visual UI/UX Redesign Report
## Profile Dashboard, Account & Security, Nutrition Goals & Authentication

**Date:** 2026-11-06  
**Role:** Senior Apple iOS UI/UX Designer, Apple HIG Specialist & Principal SwiftUI Engineer  
**Scope:** Visual Redesign (UI Only) — Full-Screen Native Pages ("Trang" Toàn Màn Hình) & Full Botanical Wallpaper Integration  
**Platform:** Native iOS 17+ | Swift 5.10 / Xcode 16.5  
**Automated Testing Status:** **DEFERRED — UI Redesign Iteration** (Zero test runs per project instructions)  
**Compilation Status:** Clean Build (`** BUILD SUCCEEDED **`) with 0 errors and 0 compiler warnings.

---

## 1. Executive Summary & User Feedback Resolution

Following user review (*"sao màn lại kiểu này bị thiếu thiếu vậy cứ nổi lên chứ không phai r trang"*), two critical UX flaws were diagnosed and thoroughly resolved:

### 1. "Cứ nổi lên chứ không phải trang" (Chuyển đổi từ Modal Sheet sang Trang Toàn Màn Hình)
- **Vấn đề trước đó:** Luồng xác thực ([`AuthCoordinatorView`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/AuthCoordinatorView.swift)) và mục tiêu dinh dưỡng ([`NutritionGoalsView`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Profile/NutritionGoalsView.swift)) được trình chiếu dạng `.sheet(...)`. Khi mở ra, iOS 17 thu nhỏ màn hình phía sau và trồi lên dạng thẻ lửng (sheet modal) với góc bo lọt thỏm, để lộ header của màn hình trước.
- **Giải pháp:** Chuyển đổi toàn bộ sang `.fullScreenCover(...)` trong [`AppRouter.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/App/AppRouter.swift) và [`ProfileView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Profile/ProfileView.swift). Hiện tại, Đăng nhập, Chào mừng, Đăng ký, Tài khoản & Bảo mật, và Thiết lập mục tiêu đều là **Trang độc lập toàn màn hình 100% (Full-Screen Page)**, phủ kín từ mép trên tai thỏ/Dynamic Island đến đáy màn hình mà không bị nửa vời hay co cụm.

### 2. "Bị thiếu thiếu vậy" (Lấp đầy bố cục, bổ sung phương thức xác thực chuẩn iOS)
- **Vấn đề trước đó:** Màn hình `LoginView` chỉ có 2 ô nhập liệu đơn độc và để lại một khoảng trống hoang vắng chiếm gần 50% chiều cao màn hình.
- **Giải pháp:** Thiết kế lại toàn diện layout:
  1. Thêm biểu tượng đại diện Hero và lời chào *"Chào mừng trở lại! 👋"*.
  2. Banner điểm nhấn: *"Dinh dưỡng món Việt chuẩn calo • AI On-Device nhận diện hơn 5.000 món"*.
  3. Bổ sung nút **"Tiếp tục với Apple"** (Apple Sign-In) ngay trên màn hình Đăng nhập để người dùng có lựa chọn đăng nhập nhanh chuẩn Apple.
  4. Lối tắt **"Trải nghiệm không cần tài khoản"** (Guest mode) trực tiếp.
  5. Huy hiệu bảo mật chuẩn Apple Keychain: *"Bảo mật dữ liệu 100% trên thiết bị với Apple Keychain"*.
  6. Toàn bộ hình nền `botanical_wallpaper` ôm trọn trang một cách cân đối, hài hòa và đầy đặn.

---

## 2. Bộ ảnh chụp thực tế trên iPhone 17 Simulator (Full-Screen Pages)

````carousel
![Full-Page Email Login](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/login_redesign.png)
<!-- slide -->
![Full-Page Authentication Gateway](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/authentication_redesign.png)
<!-- slide -->
![Full-Page Account & Security](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/account_security_redesign.png)
<!-- slide -->
![Full-Page Nutrition Goals](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/nutrition_goals_redesign.png)
<!-- slide -->
![Profile Dashboard](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/profile_redesign.png)
````

---

## 3. Chi tiết thiết kế các trang

### Trang 01: Đăng nhập hoàn chỉnh ([`LoginView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/LoginView.swift))
- **Thanh đỉnh:** Nút `< Quay lại` màu xanh rừng trong viên nang trắng và logo lá mầm NutriLens, cách Dynamic Island đúng 54 pt.
- **Phần Hero:** Biểu tượng Avatar tròn, tiêu đề *"Chào mừng trở lại! 👋"* và mô tả định hướng.
- **Thẻ điểm nhấn:** Banner xanh ngọc giới thiệu AI nhận diện 5.000+ món ăn Việt chuẩn calo.
- **Thẻ Form đăng nhập:**
  - Ô nhập liệu Email với icon thư và tự động xóa.
  - Ô nhập liệu Mật khẩu kèm icon mắt ẩn/hiện mật khẩu.
  - Liên kết *"Quên mật khẩu?"*.
  - Nút chính *"Đăng nhập"* màu xanh botanical.
  - Đường phân cách *"HOẶC TIẾP TỤC VỚI"*.
  - Nút đen chuẩn Apple: *"Tiếp tục với Apple"*.
  - Tùy chọn *"Trải nghiệm không cần tài khoản"*.
- **Chân trang:** Nút chuyển *"Chưa có tài khoản? Đăng ký ngay"* và huy hiệu uy tín Apple Keychain.

### Trang 02: Cổng chào & Phương thức xác thực ([`WelcomeAuthView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/WelcomeAuthView.swift))
- Trang toàn màn hình với biểu tượng lá mầm xanh ngọc lớn, 3 viên nang tính năng (*AI On-Device*, *5.000+ Món Việt*, *Bảo Mật Cục Bộ*), nút đóng `x` phía góc trên bên phải, và thẻ trắng chứa đầy đủ các phương thức Apple, Email, Đăng ký và Khách.

### Trang 03: Tài khoản & Bảo mật ([`AccountManagementView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/AccountManagementView.swift))
- Trang toàn màn hình với thanh đỉnh tùy biến (icon khiên bảo mật, tiêu đề "Tài khoản & Bảo mật", nút "Xong" góc phải).
- Thẻ danh tính người dùng, banner an tâm lưu trữ SwiftData cục bộ, các tùy chọn liên kết và vùng nguy hiểm tách biệt.

### Trang 04: Thiết lập mục tiêu dinh dưỡng ([`NutritionGoalsView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Profile/NutritionGoalsView.swift))
- Trang toàn màn hình với thanh đỉnh tùy biến (icon ngọn lửa calo, nút "Đóng" góc phải).
- 4 thẻ chọn mục tiêu thể trạng với nút radio viền xanh nổi bật.
- Bộ điều chỉnh calo số lớn kèm nút `- / +` 50 kcal.
- 3 thẻ phân bổ đa lượng (Đạm, Carb, Béo) và nút "Lưu mục tiêu".

### Trang 05: Hồ sơ cá nhân ([`ProfileView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Profile/ProfileView.swift))
- Trang bảng điều khiển chính với thanh đỉnh cách ly hoàn toàn cụm Dynamic Island, thẻ thông tin cá nhân với vòng đại diện lá cây, ngân sách `2.000 kcal / ngày` trên một dòng duy nhất, 2 widget thể trạng & nước uống, và 2 nhóm cài đặt nổi phía trên thanh tab bar.

---

## 4. Danh sách tệp đã cập nhật

1. [`NutriLens/App/AppRouter.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/App/AppRouter.swift): Chuyển `.sheet` thành `.fullScreenCover` cho `AuthCoordinatorView`.
2. [`NutriLens/Features/Authentication/LoginView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/LoginView.swift): Tái cấu trúc thành trang toàn màn hình đầy đủ với Apple Sign-In, banner AI, hero avatar và bảo mật Keychain.
3. [`NutriLens/Features/Authentication/WelcomeAuthView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/WelcomeAuthView.swift): Tinh chỉnh padding an toàn Dynamic Island cho trang toàn màn hình.
4. [`NutriLens/Features/Authentication/RegisterView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/RegisterView.swift): Tinh chỉnh padding an toàn Dynamic Island.
5. [`NutriLens/Features/Authentication/ForgotPasswordView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/ForgotPasswordView.swift): Tinh chỉnh padding an toàn Dynamic Island.
6. [`NutriLens/Features/Authentication/AccountManagementView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/AccountManagementView.swift): Thay thế toolbar bằng custom top bar an toàn, chuyển thành trang toàn màn hình.
7. [`NutriLens/Features/Profile/NutritionGoalsView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Profile/NutritionGoalsView.swift): Thay thế toolbar bằng custom top bar an toàn, chuyển thành trang toàn màn hình.
8. [`NutriLens/Features/Profile/ProfileView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Profile/ProfileView.swift): Cập nhật `.fullScreenCover` cho `NutritionGoalsView`, căn lề Dynamic Island và chống ngắt dòng Calo.
