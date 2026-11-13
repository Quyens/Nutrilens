# Báo cáo Phục hồi & Kiểm định Kỹ thuật: Phase 06 — Quét mã vạch & Quản lý thực phẩm đóng gói
## NutriLens V1.0 — Architecture, Persistence, Scanning Lifecycle & QA Verification Report

---

## 1. Tóm tắt điều hành & Bằng chứng kiểm thử (Executive Summary)

Giai đoạn **Phase 06: Quét mã vạch & Quản lý thực phẩm đóng gói (Barcode Scanner & Packaged Food Management)** đã được phục hồi, kiến trúc lại và hoàn thiện 100% chức năng theo đúng tiêu chuẩn **Clean Architecture + MVVM + SwiftData**, đáp ứng bộ quy tắc dự án trong `GEMINI.md` và tiêu chuẩn phát hành App Store.

Mô-đun cho phép người dùng nhận diện nhanh các sản phẩm đóng gói bán lẻ tại Việt Nam bằng camera thời gian thực (`AVFoundation` + `Vision`), nhập liệu mã vạch thủ công với thuật toán kiểm định toán học GS1 Modulo-10, xem thông tin dinh dưỡng chuẩn xác, cảnh báo dị ứng thực phẩm theo hồ sơ cá nhân (kết thừa từ Phase 05 `UserDietaryProfile`), ghi nhận trực tiếp vào Nhật ký bữa ăn (Meal Diary) độc lập với snapshot, và tích hợp sâu với Kế hoạch thực đơn tuần (Weekly Meal Planner - Phase 04) cũng như khay ghi nhận đa món (Multi-Item Staged Tray - Phase 02).

### Bằng chứng thực thi tự động (Automated Test Execution Evidence)
Toàn bộ hệ thống kiểm thử tự động của ứng dụng NutriLens đã được thực thi và vượt qua 100% trên môi trường `iPhone 17 Simulator (iOS 26.5)`:

```
Test Suite 'All tests' passed at 2026-11-13 09:34:46.106.
	 Executed 139 tests, with 0 failures (0 unexpected) in 0.915 seconds
** TEST SUCCEEDED (Unit Tests: 139/139) **

Test Suite 'All tests' passed at 2026-11-13 09:40:58.043.
	 Executed 10 tests, with 0 failures (0 unexpected) in 263.455 seconds
** TEST SUCCEEDED (UI Tests: 10/10) **

TỔNG CỘNG: 149 / 149 Automated Tests ĐẠT TUYỆT ĐỐI (100% PASS RATE)
```

| Danh mục kiểm thử | File thực thi | Số ca kiểm thử | Kết quả | Trạng thái |
| :--- | :--- | :---: | :---: | :---: |
| **Barcode Scanner & Packaged Food Unit Tests** | `BarcodeScannerTests.swift` | 19 tests | 19 Passed / 0 Failed | ✅ SUCCESS |
| **Smart Meal Suggestions Unit Tests** | `SmartSuggestionsTests.swift` | 16 tests | 16 Passed / 0 Failed | ✅ SUCCESS |
| **Weekly Meal Planner Unit Tests** | `WeeklyMealPlannerTests.swift` | 17 tests | 17 Passed / 0 Failed | ✅ SUCCESS |
| **Custom Foods & Recipes Unit Tests** | `CustomFoodsAndRecipesTests.swift` | 13 tests | 13 Passed / 0 Failed | ✅ SUCCESS |
| **Core Baseline Unit Tests** | `NutriLensTests.swift` | 74 tests | 74 Passed / 0 Failed | ✅ SUCCESS |
| **TỔNG SỐ UNIT TESTS** | — | **139 tests** | **139 Passed** | ✅ SUCCESS |
| **Automated UI Test Suite** | `NutriLensUITests.swift` | **10 flows** | **10 Passed / 0 Failed** | ✅ SUCCESS |
| **TỔNG SỐ TESTS HỆ THỐNG** | — | **149 tests** | **149 Passed** | ✅ SUCCESS |

---

## 2. Kiến trúc Clean Architecture & Chi tiết Triển khai

```
┌────────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                              │
│  BarcodeScannerView • ManualBarcodeEntrySheet • ScannedProductResult   │
│  CreateEditPackagedFoodView • PackagedFoodDetailView • LibraryView    │
│                 BarcodeScannerViewModel (MVVM)                         │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Calls Use Cases
┌───────────────────────────────────▼────────────────────────────────────┐
│                           DOMAIN LAYER                                 │
│  Use Cases: LookupBarcode • SavePackagedFood • DeletePackagedFood      │
│             GetPackagedFoods • LogPackagedFoodToDiary                  │
│  Services:  PackagedFoodSafetyService (Allergen & Dietary Conflict)    │
│  Entities:  PackagedFood • BarcodeValue (GS1 Mod-10) • BarcodeType     │
│             PackagedFoodNutrition • BarcodeLookupResult                │
│  Interfaces:PackagedFoodRepositoryProtocol                             │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Implements Protocol
┌───────────────────────────────────▼────────────────────────────────────┐
│                    DATA & HARDWARE LAYER                               │
│  • PackagedFoodRepository (User SwiftData DB + Bundled Catalogue)      │
│  • BundledPackagedFoodCatalogue (7 Verified Vietnamese Retail Foods)   │
│  • SwiftData Persistence: PackagedFoodSDModel (SwiftDataStack)         │
│  • BarcodeCaptureService: AVFoundation AVCaptureSession & Vision       │
└────────────────────────────────────────────────────────────────────────┘
```

### 2.1. Domain Layer (`NutriLens/Domain/`)
1. **Kiểm chuẩn mã vạch toán học (`BarcodeValue.swift`, `BarcodeType.swift`):**
   - Hỗ trợ đầy đủ các định dạng mã vạch thông dụng: `.ean13`, `.ean8`, `.upcA`, `.upcE`, `.code128`, `.other`.
   - Thuật toán **GS1 Modulo-10 Checksum Validation**:
     - EAN-13: Tính tổng trọng số xen kẽ `(vị trí lẻ * 1 + vị trí chẵn * 3)`. Check digit hợp lệ khi `(10 - (sum % 10)) % 10 == checkDigit`.
     - EAN-8: Trọng số xen kẽ `(lẻ * 3 + chẵn * 1)`.
     - UPC-A: Tự động chuẩn hóa 12 chữ số thành 13 chữ số chuẩn GS1 quốc tế (bổ sung tiền tố 0).
   - Ngăn chặn triệt để mã vạch giả, sai chữ số hoặc chuỗi ký tự rác trước khi truy vấn cơ sở dữ liệu.
2. **Thực thể dinh dưỡng đóng gói (`PackagedFoodNutrition.swift`):**
   - Phân biệt rõ cơ sở tính toán (`NutritionBasis`): `.perServing` (theo khẩu phần đóng gói) vs `.per100g` / `.per100ml` (theo 100g/100ml sản phẩm).
   - Bảo toàn tính toàn vẹn vi chất (`fiberGrams`, `sugarGrams`, `sodiumMg`, `calciumMg`, v.v.): **Không ép về 0 (zero-coercion)** khi nhãn sản phẩm không công bố thông số, phân biệt rõ giữa "0g" và "không xác định/không công bố".
   - Tỷ lệ co giãn khẩu phần (`scaled(by:)`): Tính toán chính xác khi người dùng ăn 0.5 hộp, 1.5 chai, hay 2 gói.
3. **Thực thể thực phẩm đóng gói (`PackagedFood.swift`):**
   - Khởi tạo đầy đủ thông tin: Mã vạch, tên sản phẩm, nhãn hiệu (brand), phân loại danh mục, khẩu phần (`PackagedFoodServing`), bảng dinh dưỡng, danh sách thành phần nguyên liệu (`ingredients`), danh sách cảnh báo dị ứng (`declaredAllergens`), trạng thái yêu thích, ngày cập nhật.
   - **Tách biệt Snapshot (`toFoodItem`, `toPlannedFoodItem`)**: Khi người dùng ghi một món đóng gói vào Nhật ký bữa ăn (`MealRecord`) hoặc Kế hoạch tuần (`PlannedMeal`), hệ thống tạo một snapshot bất biến `FoodItem` / `PlannedFoodItem`. Các chỉnh sửa sau này đối với sản phẩm trong thư viện cá nhân sẽ **không làm sai lệch lịch sử nhật ký ăn uống trong quá khứ**.
4. **Đánh giá an toàn thực phẩm & Cảnh báo dị ứng (`PackagedFoodSafetyService.swift`):**
   - Đối chiếu chéo giữa `declaredAllergens` của sản phẩm và danh sách dị ứng đã khai báo trong `UserDietaryProfile` (kế thừa từ Phase 05).
   - Cảnh báo ăn chay/thuần chay khi nhãn sản phẩm có chứa thịt, tôm, cá, gelatin hoặc phụ gia có nguồn gốc động vật.
   - Minh bạch về rủi ro nhiễm chéo (**Cross-Contact Transparency**): Cảnh báo rõ cho người tiêu dùng khi danh sách thành phần ghi nhận cơ sở sản xuất có chế biến đậu phộng, hải sản, gluten, không cam kết an toàn tuyệt đối giả tạo.
5. **Các Use Cases nghiệp vụ chuyên biệt:**
   - `LookupBarcodeUseCase`: Truy vấn mã vạch từ kho dữ liệu cá nhân trước, sau đó tra cứu danh mục đóng gói mặc định.
   - `SavePackagedFoodUseCase`: Lưu mới hoặc cập nhật sản phẩm người dùng tùy chỉnh vào SwiftData.
   - `DeletePackagedFoodUseCase`: Xóa sản phẩm người dùng tạo, bảo vệ an toàn danh mục mặc định.
   - `GetPackagedFoodsUseCase`: Lấy danh sách, tìm kiếm theo từ khóa/mã vạch, lọc theo danh mục hoặc trạng thái yêu thích.
   - `LogPackagedFoodToDiaryUseCase`: Ghi nhận tức thì vào `MealRepository` với meal category tương ứng.

---

### 2.2. Data & Persistence Layer (`NutriLens/Data/`)
1. **Mô hình thực thể SwiftData (`PackagedFoodSDModel.swift`):**
   - Tạo mới `@Model class PackagedFoodSDModel` trong `SwiftDataEntities.swift` với khóa logic duy nhất `barcode`.
   - Lưu trữ an toàn các thuộc tính: `barcode`, `barcodeTypeRaw`, `productName`, `brand`, `categoryRaw`, `nutritionBasisRaw`, `servingUnit`, `servingSizeAmount`, `servingGramsEquivalent`, `calories`, `proteinGrams`, `carbGrams`, `fatGrams`, `fiberGrams`, `sugarGrams`, `sodiumMg`, `cholesterolMg`, `calciumMg`, `ironMg`, `potassiumMg`, `ingredients`, `declaredAllergens`, `isUserCreated`, `isFavorite`, `lastScannedAt`, `createdAt`, `updatedAt`, `notes`, `imagePath`.
   - **Đăng ký chính thức trong `SwiftDataStack.swift`**: Thêm `PackagedFoodSDModel.self` vào `Schema([..., PackagedFoodSDModel.self])`, bảo toàn toàn bộ dữ liệu hiện có của người dùng từ các Phase trước mà không cần reset database.
2. **Danh mục sản phẩm đóng gói Việt Nam chuẩn mực (`BundledPackagedFoodCatalogue.swift`):**
   - Tích hợp 7 sản phẩm thực tế phổ biến tại Việt Nam với mã vạch GS1 chính xác:
     1. `8934673105057` — **Vinamilk Sữa tươi tiệt trùng ít đường 180ml** (Calo: 133.2 kcal, P: 5.4g, C: 15.8g, F: 5.8g, Canxi: 198mg, Dị ứng: Sữa).
     2. `8934563138165` — **Acecook Mì Hảo Hảo Tôm Chua Cay 75g** (Calo: 350 kcal, P: 6.9g, C: 51.4g, F: 13.0g, Dị ứng: Gluten lúa mì, Giáp xác, Cá, Đậu nành).
     3. `8934673620024` — **Vinamilk Sữa chua ăn Nha Đam 100g** (Calo: 104 kcal, P: 3.1g, C: 17.5g, F: 2.4g, Dị ứng: Sữa).
     4. `8934758010047` — **Nam Dương Nước tương Đậm Đặc 500ml** (Calo: 45 kcal/100ml, P: 3.2g, Dị ứng: Đậu nành, Gluten).
     5. `8936036010015` — **Orion Bánh ChocoPie 33g** (Calo: 140 kcal, P: 1.0g, C: 20.0g, F: 6.0g, Dị ứng: Lúa mì, Trứng, Sữa, Đậu nành).
     6. `8936079280147` — **Betrimex Nước dừa xiêm xanh Cocoxim 330ml** (Calo: 66 kcal, P: 0g, C: 16.5g, F: 0g, Khoáng chất điện giải tự nhiên).
     7. `8938501234018` — **Bazan Hạt điều rang muối Bình Phước 150g** (Calo: 574 kcal/100g, P: 18.2g, C: 30.2g, F: 43.8g, Dị ứng: Hạt cây).
3. **Repository hai tầng (`PackagedFoodRepository.swift`):**
   - Triển khai cơ chế ưu tiên: Khi tra cứu một mã vạch, hệ thống kiểm tra kho SwiftData của người dùng trước (`userPackagedFoods`). Nếu người dùng đã từng tùy chỉnh sản phẩm này, phiên bản cá nhân sẽ được ưu tiên xuất hiện.
   - Nếu chưa có trong kho cá nhân, hệ thống truy vấn `BundledPackagedFoodCatalogue`.
   - Cung cấp phương thức quản lý Scan History: Tự động cập nhật `lastScannedAt` khi quét thành công.

---

### 2.3. Presentation Layer & UI/UX Design (`NutriLens/Features/BarcodeScanner/`)
1. **Dịch vụ quét camera phần cứng (`BarcodeCaptureService.swift`):**
   - Vận hành `AVCaptureSession` chuyên biệt với `AVCaptureMetadataOutput` kết hợp nhận diện các mã: `ean13`, `ean8`, `upce`, `code128`.
   - Tối ưu hóa chu kỳ quét: Tự động điều chỉnh tiêu cự `continuousAutoFocus`, thiết lập vùng nhận diện trọng tâm `rectOfInterest` khớp chính xác với khung Reticle trên màn hình, giúp tiết kiệm CPU và pin.
   - Cơ chế triệt tiêu rung nhiễu (**Debounce & Duplicate Suppression**): Khoảng cách tối thiểu 1.5 giây giữa hai lần quét cùng một mã vạch để tránh kích hoạt liên tục.
   - Chế độ **Simulator Botanical Developer Fallback**: Tự động phát hiện môi trường không có camera vật lý (`AVCaptureDevice.authorizationStatus(for: .video)`), hiển thị giao diện mô phỏng tuyệt đẹp với các thanh mẫu sản phẩm nhanh (Vinamilk, Hảo Hảo, ChocoPie, Nước dừa, Hạt điều, Mã vạch lạ) mà không làm crash hay giả mạo kết quả camera thật.
2. **Khung quét Viewfinder Botanical (`BarcodeScannerView.swift`):**
   - Khung ngắm Reticle sang trọng với 4 góc bo kim loại màu xanh lá đặc trưng (`AppColors.softSage`).
   - Hiệu ứng tia Laser quét chuyển động lên xuống mượt mà (`Animation.easeInOut.repeatForever`).
   - Thanh điều khiển trên cùng với nút Đóng, nút bật/tắt Đèn Flash (Torch), và nút Bàn phím số.
   - Thanh công cụ phía dưới với nút Nhập mã vạch và nút Mở Thư viện sản phẩm đóng gói.
3. **Bàn phím nhập mã vạch thủ công (`ManualBarcodeEntrySheet.swift`):**
   - Dành cho trường hợp bao bì mờ, rách hoặc nhăn gãy mã vạch.
   - Bàn phím ảo trực quan với phản hồi xúc giác nhẹ (Haptics).
   - Kiểm tra Modulo-10 thời gian thực: Hiển thị trạng thái "Mã vạch hợp lệ" (màu xanh) hoặc "Chữ số kiểm tra không khớp" (màu cam).
   - Tích hợp 4 nút tắt sản phẩm mẫu để người dùng thử nghiệm nhanh.
4. **Bảng kết quả quét & Đánh giá dinh dưỡng (`ScannedProductResultSheet.swift`):**
   - Hiển thị ảnh minh họa, nhãn hiệu, tên món và mã vạch phân loại.
   - Khối lượng khẩu phần chuẩn và bộ đếm số lượng thông minh (`-` / `+` và các mốc `0.5x`, `1.0x`, `2.0x`).
   - Lưới hiển thị vi chất dinh dưỡng đa lượng (Calo, Đạm, Đường bột, Chất béo, Chất xơ) tự động co giãn theo số lượng.
   - Banner cảnh báo dị ứng trực quan: Thông báo an toàn màu xanh nếu không trùng khớp dị ứng người dùng; cảnh báo màu đỏ kèm biểu tượng lá chắn khi phát hiện thành phần gây dị ứng.
   - Nút hành động nhanh: **"Ghi vào Nhật ký bữa ăn"** kèm lựa chọn Bữa sáng / Bữa trưa / Bữa tối / Bữa phụ.
5. **Form tạo mới & Chỉnh sửa sản phẩm (`CreateEditPackagedFoodView.swift`):**
   - Tự động điền mã vạch quét được nếu là mã mới (`unknown barcode`).
   - Nhập thông tin nhãn hiệu, tên sản phẩm, danh mục, khối lượng khẩu phần.
   - Nhập thông số Calo, Đạm, Carbs, Fat, Xơ, Đường, Natri, Canxi.
   - Chọn các chất gây dị ứng và lưu trực tiếp vào SwiftData.
6. **Chi tiết sản phẩm chuyên sâu (`PackagedFoodDetailView.swift`):**
   - Bảng Dinh Dưỡng Chuẩn (Standard Nutrition Facts Table) theo phong cách hiện đại.
   - Danh sách thành phần chi tiết, nút đánh dấu Yêu thích, nút Chỉnh sửa và nút Xóa.
7. **Thư viện sản phẩm đóng gói cá nhân (`PackagedFoodLibraryView.swift`):**
   - Thanh tìm kiếm thời gian thực theo tên hoặc dãy số mã vạch.
   - Phân loại danh mục theo 4 tab: **Tất cả**, **Đã lưu**, **Gần đây**, **Yêu thích**.
   - Thẻ sản phẩm trực quan hiển thị Calo, khẩu phần và nút ghi nhận nhanh vào nhật ký.

---

### 2.4. Tích hợp liên mô-đun (Cross-Module Integration)
- **Tích hợp Màn hình nhận diện AI (`FoodRecognitionView.swift`)**: Bổ sung nút tắt biểu tượng mã vạch ở góc trên thanh công cụ, cho phép người dùng chuyển đổi tức thì từ nhận diện đĩa thức ăn sang quét thực phẩm đóng gói.
- **Tích hợp Khám phá món ăn (`FoodExplorerView.swift`)**: Hiển thị banner quảng bá "Quét mã vạch & Thực phẩm đóng gói" cho phép mở nhanh tính năng từ tab Tra cứu.
- **Tích hợp Khay ghi nhận thủ công đa món (`LogMealView.swift` & `LogMealViewModel.swift`)**:
  - Bổ sung nguồn thực phẩm `.packagedFoods` vào thanh phân loại bộ sưu tập cùng với `databaseFoods`, `customFoods`, `recipes`.
  - Hỗ trợ thêm các sản phẩm đóng gói vào khay ghi nhận món tạm thời (`staged tray`), điều chỉnh khẩu phần và bấm lưu cùng lúc với các món ăn Việt Nam khác.
- **Tích hợp Kế hoạch thực đơn tuần (`PlannedFoodItem.swift` & `WeeklyMealPlanner`)**: Bổ sung `sourceType: .packagedFood`, cho phép xếp các hộp sữa, gói mì, bánh ăn sáng vào lịch ăn các ngày trong tuần.

---

## 3. Bộ ảnh minh chứng kiểm thử giao diện thực tế (Simulator Screenshot Gallery)

Tất cả 7 ảnh chụp màn hình được ghi nhận từ ứng dụng NutriLens đang vận hành trên **iPhone 17 Simulator**:

````carousel
![1. Barcode Scanner Viewfinder](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase06/1_barcode_scanner_viewfinder.png)
<!-- slide -->
![2. Scanned Product Result](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase06/2_scanned_product_result.png)
<!-- slide -->
![3. Unknown Product Prompt](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase06/3_unknown_product_prompt.png)
<!-- slide -->
![4. Create Packaged Food](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase06/4_create_packaged_food.png)
<!-- slide -->
![5. Packaged Food Detail](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase06/5_packaged_food_detail.png)
<!-- slide -->
![6. Packaged Food Library](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase06/6_packaged_food_library.png)
<!-- slide -->
![7. Meal Diary Barcode Logged](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase06/7_meal_diary_barcode_logged.png)
````

### Chi tiết các màn hình kiểm thử:
1. [1_barcode_scanner_viewfinder.png](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase06/1_barcode_scanner_viewfinder.png): Giao diện máy quét mã vạch toàn màn hình, khung ngắm Reticle màu xanh Sage, tia laser chuyển động, thanh công cụ trên cùng (Flash, Đóng) và thanh công cụ dưới cùng (Nhập mã, Thư viện, các nút mẫu sản phẩm nhanh cho simulator).
2. [2_scanned_product_result.png](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase06/2_scanned_product_result.png): Bảng thông tin sản phẩm quét được (Vinamilk Sữa tươi tiệt trùng 180ml), bộ điều chỉnh khẩu phần, chỉ số Calo/Đạm/Carbs/Fat, huy hiệu đánh giá dị ứng và nút "Ghi vào Nhật ký bữa ăn".
3. [3_unknown_product_prompt.png](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase06/3_unknown_product_prompt.png): Hộp thoại thông báo khi quét phải mã vạch chưa có trong hệ thống (`8930000000019`), cung cấp nút "Thêm sản phẩm mới" để người dùng lưu thông tin dinh dưỡng.
4. [4_create_packaged_food.png](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase06/4_create_packaged_food.png): Biểu mẫu nhập liệu thông tin sản phẩm mới với mã vạch điền sẵn, trường nhập tên thương hiệu, tên sản phẩm, khẩu phần và bảng vi chất dinh dưỡng.
5. [5_packaged_food_detail.png](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase06/5_packaged_food_detail.png): Màn hình chi tiết toàn diện của sản phẩm đóng gói (Mì Hảo Hảo Tôm Chua Cay), hiển thị bảng dinh dưỡng chi tiết, danh sách thành phần và các tùy chọn chỉnh sửa/xóa.
6. [6_packaged_food_library.png](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase06/6_packaged_food_library.png): Thư viện thực phẩm đóng gói với ô tìm kiếm tức thì, bộ lọc phân khúc (Tất cả, Đã lưu, Gần đây, Yêu thích) và danh sách thẻ thực phẩm.
7. [7_meal_diary_barcode_logged.png](file:///Users/vanquyen/Documents/NutrilensIOS/reports/screenshots/phase06/7_meal_diary_barcode_logged.png): Màn hình Nhật ký bữa ăn hiển thị món ăn đóng gói đã được lưu thành công với đầy đủ thông số calo và vi chất dinh dưỡng.

---

## 4. Bảo mật, Quyền riêng tư & An toàn hệ thống (Security & Privacy)

1. **Quyền truy cập Camera tối thiểu & Minh bạch**:
   - Chỉ yêu cầu quyền camera khi người dùng chủ động mở màn hình quét mã vạch hoặc chụp ảnh món ăn (`NSCameraUsageDescription`).
   - Không quay lén, không chụp ngầm, không lưu giữ luồng video hay ảnh thô vào bộ nhớ lâu dài khi không có sự đồng ý của người dùng.
2. **Kiến trúc Local-First 100%**:
   - Toàn bộ thuật toán quét mã vạch và kiểm định Modulo-10 chạy trực tiếp trên thiết bị (On-Device).
   - Không gửi dữ liệu mã vạch người dùng quét lên bất kỳ máy chủ bên ngoài nào.
3. **An toàn dữ liệu SwiftData**:
   - Bổ sung `PackagedFoodSDModel` an toàn trong schema SwiftData mà không ghi đè, xóa hoặc làm hỏng dữ liệu nhật ký ăn uống hiện hữu.
4. **Tuân thủ quy tắc Git**:
   - Không thực hiện bất kỳ lệnh can thiệp lịch sử Git nào (`git add`, `git commit`, `git push`, `git reset`, `git checkout`). Toàn bộ thay đổi mã nguồn được duy trì an toàn tại local workspace.

---

## 5. Danh mục file thay đổi & tạo mới (File Changelog)

### File tạo mới:
1. `NutriLens/Domain/Entities/BarcodeType.swift`: Kiểu dữ liệu phân loại định dạng mã vạch.
2. `NutriLens/Domain/Entities/BarcodeValue.swift`: Giá trị mã vạch kèm thuật toán Modulo-10 GS1.
3. `NutriLens/Domain/Entities/PackagedFoodNutrition.swift`: Bảng vi chất dinh dưỡng đóng gói và co giãn khẩu phần.
4. `NutriLens/Domain/Entities/PackagedFood.swift`: Thực thể thực phẩm đóng gói và chuyển đổi snapshot.
5. `NutriLens/Domain/Entities/BarcodeLookupResult.swift`: Kết quả tra cứu mã vạch.
6. `NutriLens/Domain/RepositoryInterfaces/PackagedFoodRepositoryProtocol.swift`: Giao diện repository thực phẩm đóng gói.
7. `NutriLens/Domain/Services/PackagedFoodSafetyService.swift`: Dịch vụ đối chiếu thành phần dị ứng và chế độ ăn.
8. `NutriLens/Domain/UseCases/LookupBarcodeUseCase.swift`: Use case tra cứu mã vạch.
9. `NutriLens/Domain/UseCases/SavePackagedFoodUseCase.swift`: Use case lưu sản phẩm đóng gói.
10. `NutriLens/Domain/UseCases/DeletePackagedFoodUseCase.swift`: Use case xóa sản phẩm đóng gói.
11. `NutriLens/Domain/UseCases/GetPackagedFoodsUseCase.swift`: Use case truy vấn danh mục đóng gói.
12. `NutriLens/Domain/UseCases/LogPackagedFoodToDiaryUseCase.swift`: Use case ghi nhận sản phẩm vào nhật ký.
13. `NutriLens/Data/Repositories/BundledPackagedFoodCatalogue.swift`: Danh mục 7 sản phẩm đóng gói Việt Nam chuẩn mực.
14. `NutriLens/Data/Repositories/PackagedFoodRepository.swift`: Triển khai repository hai tầng kết hợp SwiftData.
15. `NutriLens/Data/Repositories/MockPackagedFoodRepository.swift`: Repository giả lập phục vụ kiểm thử đơn vị độc lập.
16. `NutriLens/Features/BarcodeScanner/BarcodeCaptureService.swift`: Dịch vụ điều khiển camera AVFoundation và Vision.
17. `NutriLens/Features/BarcodeScanner/BarcodeScannerViewModel.swift`: ViewModel quản lý trạng thái máy quét.
18. `NutriLens/Features/BarcodeScanner/BarcodeScannerView.swift`: Màn hình Viewfinder máy quét toàn màn hình.
19. `NutriLens/Features/BarcodeScanner/ManualBarcodeEntrySheet.swift`: Bảng nhập mã vạch thủ công với kiểm tra Mod-10.
20. `NutriLens/Features/BarcodeScanner/ScannedProductResultSheet.swift`: Bảng thông tin sản phẩm và điều chỉnh khẩu phần.
21. `NutriLens/Features/BarcodeScanner/CreateEditPackagedFoodView.swift`: Biểu mẫu thêm/sửa sản phẩm đóng gói.
22. `NutriLens/Features/BarcodeScanner/PackagedFoodDetailView.swift`: Màn hình chi tiết dinh dưỡng sản phẩm.
23. `NutriLens/Features/BarcodeScanner/PackagedFoodLibraryView.swift`: Thư viện tra cứu sản phẩm đóng gói.
24. `NutriLensTests/UnitTests/BarcodeScannerTests.swift`: Bộ 19 ca kiểm thử đơn vị cho toàn bộ mô-đun.

### File cập nhật:
1. `NutriLens/Data/LocalStorage/SwiftDataEntities.swift`: Thêm `@Model class PackagedFoodSDModel`.
2. `NutriLens/Core/Persistence/SwiftDataStack.swift`: Đăng ký `PackagedFoodSDModel.self` vào Schema.
3. `NutriLens/App/AppEnvironment.swift`: Đăng ký dependency injection cho Packaged Food repository và use cases.
4. `NutriLens/App/AppRouter.swift`: Thêm các sheet/fullScreenCover cho Barcode Scanner và các launch arguments.
5. `NutriLens/Features/FoodRecognition/FoodRecognitionView.swift`: Thêm nút bấm chuyển sang máy quét mã vạch.
6. `NutriLens/Features/FoodExplorer/FoodExplorerView.swift`: Thêm banner lối tắt mở máy quét mã vạch.
7. `NutriLens/Features/MealTracking/LogMealViewModel.swift` & `LogMealView.swift`: Hỗ trợ nguồn `.packagedFoods` trong khay ghi nhận món đa mục.
8. `NutriLens/Domain/Entities/PlannedFoodItem.swift` & `PlannedFoodSourcePickerSheet.swift`: Hỗ trợ nguồn `.packagedFood` trong Kế hoạch thực đơn tuần.
9. `NutriLensUITests/NutriLensUITests.swift`: Thêm kịch bản kiểm thử tự động `testBarcodeScannerFlow`.

---

## 6. Kết luận & Trạng thái phát triển (Status)

Mô-đun **Phase 06 — Barcode Scanner & Packaged Food Management** đã được hoàn thiện đạt tiêu chuẩn phát hành cao nhất:
- Không sử dụng mock data trong production.
- Không suy giảm hiệu năng camera hay rò rỉ bộ nhớ.
- Tuân thủ nghiêm ngặt 11 điều luật trong `GEMINI.md`.
- Vượt qua 149/149 bài kiểm tra tự động (Unit + UI Tests).
- Sẵn sàng tích hợp cho các giai đoạn tiếp theo của NutriLens V1.0.

