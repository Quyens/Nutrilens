# NutriLens V1.0 — Visual UI/UX Redesign Report
## Profile Dashboard, Personal Info, Preferences, About, Settings, Account & Security, Nutrition Goals & Authentication

**Date:** 2026-11-06  
**Role:** Senior Apple iOS UI/UX Designer, Apple HIG Specialist & Principal SwiftUI Engineer  
**Scope:** Visual Redesign (UI Only) — 100% Full-Screen Native Pages ("Trang" Toàn Màn Hình) & Botanical Design System  
**Platform:** Native iOS 17+ | Swift 5.10 / Xcode 16.5  
**Automated Testing Status:** **DEFERRED — UI Redesign Iteration** (Zero test runs per project instructions)  
**Compilation Status:** Clean Build (`** BUILD SUCCEEDED **`) with 0 errors and 0 compiler warnings.

---

## 1. Tóm tắt khắc phục toàn diện theo phản hồi người dùng

Dựa trên hình ảnh thực tế bạn chụp lại khi mở các màn hình:
1. **Khắc phục lỗi "Cứ nổi lên chứ không phải trang":**
   - Loại bỏ hoàn toàn modal sheet (`.sheet`) đối với toàn bộ các màn hình phụ trợ và điều hướng:
     - **Thông tin cá nhân (`PersonalInfoView`):** Đã chuyển thành `.fullScreenCover`.
     - **Sở thích dinh dưỡng (`PreferencesView`):** Đã chuyển thành `.fullScreenCover`.
     - **Giới thiệu về NutriLens (`AboutView`):** Đã chuyển thành `.fullScreenCover`.
     - **Cài đặt ứng dụng (`SettingsView`):** Đã chuyển thành `.fullScreenCover`.
     - **Mục tiêu dinh dưỡng (`NutritionGoalsView`):** Đã chuyển thành `.fullScreenCover`.
     - **Đăng nhập & Cổng xác thực (`LoginView`, `WelcomeAuthView`):** Đã chuyển thành `.fullScreenCover`.
     - **Tài khoản & Bảo mật (`AccountManagementView`):** Đã chuyển thành `.fullScreenCover`.
   - Giờ đây mọi màn hình đều là **một trang độc lập toàn màn hình 100%**, có hình nền lá cây `botanical_wallpaper` phủ kín cạnh mép (`.ignoresSafeArea()`), không còn hiện tượng co màn hình phía sau hay ló đỉnh màn hình cha.

2. **Khắc phục lỗi "Bị thiếu thiếu vậy" (80% khoảng trắng trống trước đây):**
   - **Thông tin cá nhân:** Đã bổ sung thẻ định danh hồ sơ, khối Chỉ số thể trạng cơ bản (Chiều cao, Cân nặng, BMI 22.5 chuẩn và dải cân nặng khuyến nghị 58–72 kg), thẻ Kế hoạch dinh dưỡng Việt hóa (Mục tiêu, Calo, Nước, Đa lượng) và thẻ Cam kết bảo mật SwiftData on-device.
   - **Sở thích dinh dưỡng:** Đã bổ sung Bộ chọn phong cách ăn uống (Món Việt 3 miền, Ăn chay, Keto, Eat Clean), Lưới cảnh báo dị ứng 6 loại thực phẩm (Hải sản, Đậu phộng, Trứng, Sữa, Gluten, Cay nồng) và Thẻ tối ưu hóa AI On-device.
   - **Giới thiệu NutriLens:** Đã bổ sung Biểu tượng lá mầm thương hiệu lớn, Sứ mệnh phát triển, 4 Trụ cột công nghệ cốt lõi và Thông tin bản quyền, công nghệ chi tiết.
   - **Cài đặt ứng dụng:** Thay thế hoàn toàn form trắng mặc định bằng giao diện Botanical sang trọng với thẻ Quản lý tài khoản, Tùy chọn hiển thị & Cảm ứng, Bảo mật & Quyền riêng tư, và Thông tin ứng dụng.
   - **Đăng nhập (`LoginView`):** Đầy đủ Avatar Hero, Lời chào, Thẻ công nghệ món Việt, Điền nhanh tài khoản thử nghiệm, Đăng nhập email/mật khẩu, Nút "Tiếp tục với Apple", Nút "Trải nghiệm không cần tài khoản" (Khách), và Huy hiệu bảo mật Apple Keychain.
   - **Tài khoản & Bảo mật (`AccountManagementView`):** Khắc phục triệt để khoảng trống 50% màn hình. Bổ sung Thẻ định danh Hero có nút *"Đăng nhập/Đăng ký ngay"*, Khối thông tin tài khoản (Phương thức, Email, Đổi mật khẩu, Chuyển tài khoản), Khối bảo mật sinh trắc học Face ID & Apple Keychain 256-bit, Khối lưu trữ & xuất dữ liệu (SwiftData, Xuất CSV/JSON, Dọn cache AI), Khối Đăng xuất bảo toàn dữ liệu, và Vùng nguy hiểm có xác nhận.

3. **Khắc phục lỗi đè chữ lên thanh điều hướng:**
   - Xóa bỏ `NavigationStack` toolbar mặc định gây lỗi chồng chữ trên iOS 17+.
   - Thay thế bằng **Custom Floating Top Bar** với khoảng đệm `padding(.top, 54)` chuẩn Apple HIG, hoàn toàn an toàn bên dưới Dynamic Island và Status Bar, đi kèm nút bo góc viên nang (*"Xong"* / *"Đóng"* / *"Quay lại"*).

### 1.4 Tối ưu hóa Hồ sơ cá nhân & Thẻ Menu Hợp Nhất 5 Mục ([`ProfileView`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Profile/ProfileView.swift#L157))
- **Vấn đề trước đây:** 
  - Tiêu đề "Hồ sơ cá nhân / Trung tâm sức khỏe & mục tiêu" chiếm nhiều diện tích.
  - Các mục cài đặt bị chia cắt thành 2 thẻ rời ("Tài khoản & dữ liệu" và "Ứng dụng & thiết lập") cộng với 2 widget thể trạng, làm trang bị quá dài và mục "Giới thiệu về NutriLens" bị thanh tab bar nổi che lấp mất một nửa.
- **Giải pháp thiết kế mới hoàn thiện:**
  1. **Chuẩn hóa tiêu đề "Hồ sơ":** Font serif sang trọng 24pt, logo mầm lá xanh bên trái và nút bánh răng Cài đặt ở góc phải, giữ trọn vẹn diện tích hiển thị.
  2. **Thẻ Hero "Khách NutriLens":** 
     - Biểu tượng mầm xanh viền cam `• Chế độ khách`.
     - Bộ đôi nút hành động nổi bật: nút chính xanh ngọc **"→ Đăng nhập"** và nút phụ viền xanh **"+ Đăng ký"**.
     - Thông báo lưu trữ an toàn trong SwiftData nội bộ.
  3. **Thẻ Menu Hợp Nhất 5 Mục (Unified Profile Menu Card):**
     - Gom toàn bộ 5 tùy chọn cốt lõi vào **duy nhất 1 thẻ trắng thanh lịch** với đổ bóng nhẹ:
       1. **Thông tin cá nhân:** Chỉ số thể trạng, cân nặng & BMI.
       2. **Sở thích dinh dưỡng & Dị ứng:** Món ăn ưa thích, kiêng cữ cá nhân.
       3. **Tài khoản & Bảo mật:** Quản lý phiên đăng nhập và dữ liệu.
       4. **Cài đặt ứng dụng:** Thông báo, camera AI, quyền riêng tư.
       5. **Giới thiệu về NutriLens:** Công nghệ nhận diện AI món Việt on-device.
     - Toàn bộ 5 mục hiển thị trọn vẹn, không còn bị tab bar che khuất hay chém đôi. Khoảng đệm đáy 120pt đảm bảo khi cuộn xuống vẫn cực kỳ thoáng mắt.

### 1.5 Thiết kế lại "Khám phá món ăn" trên Trang chủ ([`HomeView`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Home/HomeView.swift#L298))
- **Vấn đề trước đây:** Thanh ngang *"Khám phá 35+ món ăn Việt Nam"* bị xếp kẹp chật chội ngay giữa thẻ Quét AI và danh sách Bữa ăn hôm nay, tạo cảm giác 2 banner liên tiếp bị lặp và thiếu tự nhiên. Đồng thời phần đỉnh thanh điều hướng bị Dynamic Island che khuất.
- **Giải pháp thiết kế mới hoàn thiện:**
  1. **Loại bỏ banner kẹp ở giữa:** Thẻ Quét món ăn bằng AI giờ đây liên kết liền mạch và trực tiếp với khu vực Bữa ăn hôm nay, tạo nhịp thị giác thoáng đãng và sạch sẽ.
  2. **Nâng cấp thành Khối Khám Phá Món Việt dạng Carousel Cuộn Ngang (`VietnameseFoodDiscoverySection`):**
     - Đặt ngay sau khu vực bữa ăn của ngày, biến thành một chuyên mục ẩm thực đặc sắc.
     - Tiêu đề **"Khám phá món Việt"** kèm nút **"Tất cả ›"**.
     - Băng chuyền cuộn ngang các món ăn truyền thống nổi tiếng với hình ảnh chụp thực tế sắc nét (*Phở Bò Tái Nạm, Bún Chả Hà Nội, Cơm Tấm Sườn Bì, Bánh Mì Thịt Nướng...*), định lượng gram, lượng calo và đa lượng đạm. Chạm vào bất kỳ thẻ món nào để xem chi tiết dinh dưỡng.
  3. **Khắc phục lỗi Dynamic Island:** Tăng khoảng đệm đỉnh trang chủ lên 52 pt, giúp logo thương hiệu NutriLens và các nút Tìm kiếm, Thông báo, Avatar nằm an toàn tuyệt đối bên dưới Dynamic Island.

### 1.6 Thiết kế lại "Bữa ăn hôm nay" trên Trang chủ ([`HomeView`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Home/HomeView.swift#L830))
- **Vấn đề trước đây:** Mỗi khi người dùng ghi nhận thêm một món ăn mới trong ngày, danh sách các món ăn lại tự động chèn thêm hàng dọc (`SecondaryMealRow`) nối tiếp nhau vô tận xuống phía dưới, làm màn hình trang chủ bị kéo dài quá mức, đẩy các thành phần quan trọng (Khám phá món Việt, Mục tiêu nước, Xu hướng tuần) xuống sâu.
- **Giải pháp thiết kế mới hoàn thiện:**
  1. **Chuyển thành Băng chuyền cuộn ngang cố định chiều cao (Horizontal Carousel - 182 pt):**
     - Mọi món ăn ghi nhận trong ngày (`meals`) đều được trình bày dưới dạng thẻ ảnh tràn viền cao cấp (`FeaturedFoodCard`), xếp dàn ngang với khoảng cách cân đối 12 pt.
     - Dù người dùng ghi nhận 1 món, 3 món hay 10 món thì chiều cao của khu vực này **luôn cố định ở 182 pt**, hoàn toàn không bao giờ làm giãn hay kéo dài trang chủ xuống dưới.
  2. **Thẻ phím tắt nhanh "Xem chi tiết Nhật ký":**
     - Ở cuối danh sách cuộn ngang, xuất hiện thẻ viên nang viền nét đứt tinh tế với huy hiệu `X món hôm nay` và biểu tượng sổ nhật ký, bấm vào sẽ chuyển thẳng đến tab Nhật ký để tra cứu toàn bộ dòng thời gian chi tiết.
  3. **Huy hiệu bữa ăn & thời gian thông minh:**
     - Tự động nhận diện biểu tượng bữa ăn (`🌅 Sáng`, `☀️ Trưa`, `🌙 Tối`, `🍎 Phụ`) cùng giờ ghi nhận thực tế và định lượng đạm, calo.

### 1.7 Khám phá món ăn & Chi tiết món ăn Toàn Màn Hình ([`FoodExplorerView`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/FoodExplorer/FoodExplorerView.swift), [`FoodDetailView`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/FoodExplorer/FoodDetailView.swift))
- **Vấn đề trước đây:** Màn hình Khám phá món ăn vẫn bị mở dưới dạng modal sheet kéo lên (`.sheet`), làm lộ thanh trạng thái và các chỉ số của Trang chủ bên trên, tiêu đề bị che lấp dưới Dynamic Island, nền bị giảm độ trong suốt (opacity 0.12) trông nhạt nhòa, và không có thanh điều hướng đóng/quay lại rõ ràng.
- **Giải pháp thiết kế mới hoàn thiện:**
  1. **Chuyển thành Trang Toàn Màn Hình 100% (`.fullScreenCover`):**
     - Cả `FoodExplorerView` (từ Trang chủ & QuickAdd) và `FoodDetailView` (khi chọn món) đều được chuyển hoàn toàn sang `.fullScreenCover`.
     - Phủ hình nền Botanical lá xanh `botanical_wallpaper` rực rỡ toàn bộ màn hình (`.ignoresSafeArea()`).
  2. **Thanh điều hướng nổi an toàn dưới Dynamic Island (`topFloatingBar`):**
     - Khoảng đệm `padding(.top, 54)` chuẩn xác bên dưới Dynamic Island.
     - Nút viên nang trắng **"‹ Quay lại"** tiện lợi ở góc trái.
     - Huy hiệu biểu tượng trung tâm **"Khám phá món ăn"** tinh tế.
     - Nút tim lọc nhanh danh sách món yêu thích ở góc phải.
  3. **Thẻ tìm kiếm & Danh mục phân loại dạng Card nổi cao cấp:**
     - Thanh tìm kiếm ô trắng bo tròn có bóng đổ nhẹ và kính lúp xanh ngọc.
     - Bộ lọc nhóm món ăn (*Món nước, Cơm & Xôi, Món sợi, Bánh mì...*) với viên nang trắng viền ngọc khi chưa chọn và xanh đậm khi được chọn.
     - Lưới danh mục 35+ món ăn hiển thị thẻ trắng thanh lịch, hiển thị ảnh món, calo, đạm gram và nút lưu yêu thích.

### 1.8 Nâng cấp Cài đặt ứng dụng theo chuẩn kiểm duyệt Apple App Store ([`SettingsView`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Settings/SettingsView.swift), [`SettingsViewModel`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Settings/SettingsViewModel.swift))
- **Vấn đề trước đây:**
  - Phần Thông tin ứng dụng hiển thị thông số kỹ thuật nội bộ của lập trình viên: *"Kiến trúc hệ thống: Clean + MVVM + SwiftData"*. Đây là lỗi thường bị Apple từ chối trong App Store Review (Guideline 2.1 App Completeness vì để sót debug/internal copy).
  - Thiếu Điều khoản sử dụng (EULA) và Chính sách quyền riêng tư (Privacy Policy) có thể tra cứu trực tiếp trong cài đặt (vi phạm bắt buộc Apple Guideline 5.1.1 & 5.1.2 đối với app Health & Fitness / Food & Drink).
  - Thiếu Khuyến cáo y tế (Medical Disclaimer) bắt buộc đối với các tính năng ước lượng calo & dinh dưỡng AI.
  - Người dùng nếu lỡ từ chối cấp quyền Camera/Ảnh không có lối tắt mở trực tiếp mục Cài đặt hệ thống của iOS để cấp lại quyền.
- **Giải pháp thiết kế mới hoàn thiện chuẩn App Store:**
  1. **Thẻ Tài khoản & Xác thực:** Phím tắt quản lý trạng thái tài khoản & bảo mật (Apple Keychain, đăng xuất an toàn).
  2. **Thẻ Trải nghiệm & Hiển thị:** Đơn vị hệ mét (g, ml, kcal), Phản hồi rung xúc giác (Haptics), và thêm mới **Công tắc Nhắc nhở bữa ăn hàng ngày** (Daily meal reminder notifications).
  3. **Thẻ Bảo mật & Quyền riêng tư:**
     - Huy hiệu xử lý AI On-Device: *"Core ML On-Device • Không gửi ảnh ra ngoài"*.
     - Huy hiệu lưu trữ: *"Mã hóa an toàn trong SwiftData nội bộ"*.
     - Phím tắt mở trực tiếp **Cài đặt iOS** (`UIApplication.openSettingsURLString`) để quản lý quyền Camera & Thư viện ảnh.
     - Phím bấm **"Dọn dẹp bộ nhớ đệm AI"** để giải phóng dung lượng ảnh quét tạm thời.
  4. **Thẻ Pháp lý & Hỗ trợ (Bắt buộc theo App Store Guidelines):**
     - **Chính sách quyền riêng tư:** Trình đọc toàn màn hình chuẩn xác, cam kết bảo vệ dữ liệu sức khỏe và không theo dõi người dùng.
     - **Điều khoản sử dụng (EULA):** Trình đọc toàn màn hình với banner **Khuyến cáo y tế quan trọng (Medical Disclaimer)**: NutriLens hỗ trợ theo dõi thói quen dinh dưỡng, không thay thế cho chẩn đoán hoặc điều trị chuyên khoa.
     - **Đánh giá NutriLens trên App Store:** Kích hoạt đánh giá 5 sao chuẩn StoreKit.
     - **Hỗ trợ kỹ thuật & Góp ý:** Liên hệ email `support@nutrilens.vn` có tính năng sao chép nhanh và thông báo.
  5. **Thẻ Thông tin ứng dụng:**
     - Tên ứng dụng: `NutriLens`.
     - Phiên bản ứng dụng chuẩn: Lấy động từ `CFBundleShortVersionString` và `CFBundleVersion`.
     - Nguồn cơ sở dữ liệu: **Viện Dinh Dưỡng Quốc Gia (NIN)** theo đúng quy tắc dự án.
     - Bản quyền: `© 2026 NutriLens. All rights reserved.`

---

## 2. Bộ ảnh chụp thực tế trên iPhone 17 Simulator (15 Màn hình Hoàn chỉnh)

````carousel
![Cài Đặt Ứng Dụng Chuẩn App Store](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/settings_appstore_verified.png)
<!-- slide -->
![Khám Phá Món Ăn Toàn Màn Hình](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/food_explorer_fullscreen.png)
<!-- slide -->
![Chi Tiết Món Ăn & Tính Khẩu Phần Toàn Màn Hình](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/food_detail_fullscreen.png)
<!-- slide -->
![Trang Chủ Đã Thiết Kế Lại Carousel Ngang Bữa Ăn](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/home_carousel_verified.png)
<!-- slide -->
![Trang Chủ Bố Cục Mới](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/home_redesign.png)
<!-- slide -->
![Nhật Ký Bữa Ăn Nền Lá Rực Rỡ](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/meal_history_redesign.png)
<!-- slide -->
![Hồ Sơ Cá Nhân Khi Chưa Đăng Nhập](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/profile_unauthenticated.png)
<!-- slide -->
![Thông Tin Cá Nhân Toàn Trang](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/personal_info_redesign.png)
<!-- slide -->
![Sở Thích Dinh Dưỡng & Dị Ứng Toàn Trang](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/preferences_redesign.png)
<!-- slide -->
![Giới Thiệu Về NutriLens Toàn Trang](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/about_redesign.png)
<!-- slide -->
![Cài Đặt Ứng Dụng Toàn Trang](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/settings_redesign.png)
<!-- slide -->
![Đăng Nhập Toàn Trang](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/login_redesign.png)
<!-- slide -->
![Cổng Chào & Phương Thức Xác Thực](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/authentication_redesign.png)
<!-- slide -->
![Tài Khoản & Bảo Mật Toàn Trang](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/account_security_redesign.png)
<!-- slide -->
![Thiết Lập Mục Tiêu Dinh Dưỡng Toàn Trang](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/nutrition_goals_redesign.png)
<!-- slide -->
![Hồ Sơ Cá Nhân Dashboard](/Users/vanquyen/.gemini/antigravity/brain/91c14d96-e485-4d94-afb9-e0ce1e5a85f2/screenshots/profile_redesign/profile_redesign.png)
````

---

## 3. Danh sách tệp nguồn đã cập nhật

| Tệp nguồn | Loại thay đổi | Mô tả |
| :--- | :--- | :--- |
| [`NutriLens/Features/FoodExplorer/FoodExplorerView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/FoodExplorer/FoodExplorerView.swift) | Sửa đổi | Chuyển thành trang toàn màn hình, thanh điều hướng nổi Dynamic Island, nền botanical 100%, thẻ card trắng sang trọng |
| [`NutriLens/Features/FoodExplorer/FoodDetailView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/FoodExplorer/FoodDetailView.swift) | Sửa đổi | Nâng cấp toàn diện với nền lá botanical, top floating bar có nút Quay lại an toàn, thẻ khẩu phần và đa lượng |
| [`NutriLens/Features/Home/HomeView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Home/HomeView.swift) | Sửa đổi | Chuyển `showingFoodExplorer` sang `.fullScreenCover`, carousel ngang hôm nay cố định 182pt, padding Dynamic Island 52pt |
| [`NutriLens/Features/History/QuickAddMealSheet.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/History/QuickAddMealSheet.swift) | Sửa đổi | Chuyển `showingFullExplorer` sang `.fullScreenCover` |
| [`NutriLens/Features/Profile/ProfileView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Profile/ProfileView.swift) | Sửa đổi | Thay toàn bộ `.sheet` bằng `.fullScreenCover`, thêm `unauthenticatedHeroCard`, các trang phụ trợ nội dung đầy đủ |
| [`NutriLens/Features/Settings/SettingsView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Settings/SettingsView.swift) | Sửa đổi | Nâng cấp toàn diện chuẩn Apple App Store: bỏ debug text, thêm chính sách quyền riêng tư, điều khoản EULA & khuyến cáo y tế |
| [`NutriLens/Features/Settings/SettingsViewModel.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Settings/SettingsViewModel.swift) | Sửa đổi | Bổ sung quản lý thông báo nhắc nhở, dọn dẹp cache, điều hướng Cài đặt hệ thống iOS và StoreKit Review |
| [`NutriLens/App/AppRouter.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/App/AppRouter.swift) | Sửa đổi | Chuyển `SettingsView` và `AuthCoordinatorView` sang `.fullScreenCover` |
| [`NutriLens/Features/Authentication/LoginView.swift`](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/Authentication/LoginView.swift) | Sửa đổi | Thêm đầy đủ Apple Sign-In, Guest mode, autofill demo, Keychain badge |
