# BÁO CÁO KỸ THUẬT TỔNG KẾT ĐỒ ÁN MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM
# DỰ ÁN: NUTRILENS V1.0 — ỨNG DỤNG NHẬN DIỆN MÓN ĂN VIỆT & QUẢN LÝ DINH DƯỠNG ON-DEVICE TRÊN NỀN TẢNG IOS

---

**Đơn vị đào tạo:** Trường Đại học Công nghệ Thông tin & Truyền thông Việt - Hàn (VKU) — Đại học Đà Nẵng  
**Khoa:** Khoa Khoa học Máy tính / Khoa Kỹ thuật Phần mềm  
**Môn học:** Quản trị Dự án Phần mềm  
**Giảng viên hướng dẫn & Đánh giá:** TS. NGUYỄN THANH TUẤN  
**Nhóm sinh viên thực hiện:**
1. **Nguyễn Thanh Thuận** (Lớp: 23ITB — Mã SV: `thuannt.23itb@vku.udn.vn`) — Technical Lead & Data Specialist
2. **quyen** (Email: `quyen11072k5@gmail.com`) — Project Manager / Scrum Master & iOS Architect
3. **thai1123** (Email: `changtraikhoyeu23@gmail.com`) — AI / Core ML Engineer
4. *[Thành viên 4: QA & Testing Engineer — Sinh viên VKU]*
5. *[Thành viên 5: Documentation & Business Analyst — Sinh viên VKU]*

**Thời gian thực hiện:** Học kỳ I — Năm học 2026-2027  
**Ngày hoàn thành báo cáo:** 13 tháng 11 năm 2026  
**Mã tài liệu:** `reports/qlda/11_final_technical_report_7_chapters.md`  
**Độ dài tương đương:** 20–25 trang tiêu chuẩn học thuật  

---

## MỤC LỤC TỔNG QUAN

* **CHƯƠNG 1 — TỔNG QUAN ĐIỀU HÀNH & BỐI CẢNH DỰ ÁN (EXECUTIVE SUMMARY & BUSINESS CASE)**
* **CHƯƠNG 2 — PHƯƠNG PHÁP LUẬN & CƠ CẤU NHÓM (METHODOLOGY & TEAM GOVERNANCE)**
* **CHƯƠNG 3 — ĐƯỜNG CƠ SỞ PHẠM VI & TỪ ĐIỂN WBS (SCOPE BASELINE, WBS & DICTIONARY)**
* **CHƯƠNG 4 — ƯỚC LƯỢNG, TIẾN ĐỘ ĐƯỜNG GĂNG (CPM) & VẬN TỐC (ESTIMATION & VELOCITY)**
* **CHƯƠNG 5 — THỰC THI, KIỂM THỬ, CI/CD & TIÊU CHUẨN HOÀN THÀNH (TESTING & DOD)**
* **CHƯƠNG 6 — TIẾN HÓA RỦI RO & KIỂM SOÁT THAY ĐỔI (RISK EVOLUTION & CHANGE CONTROL)**
* **CHƯƠNG 7 — NGHIỆM THU UAT, ĐÓNG DỰ ÁN & BÀI HỌC KINH NGHIỆM (CLOSURE & LESSONS LEARNED)**

---

## CHƯƠNG 1: TỔNG QUAN ĐIỀU HÀNH & BỐI CẢNH DỰ ÁN (EXECUTIVE SUMMARY & BUSINESS CASE)

### 1.1. Bối cảnh Kinh tế - Xã hội & Xu hướng Sức khỏe
Trong thập kỷ gần đây, cùng với tốc độ đô thị hóa nhanh chóng và mức sống gia tăng, cơ cấu bệnh tật tại Việt Nam đang có sự chuyển dịch mạnh mẽ từ các bệnh truyền nhiễm sang các bệnh mãn tính không lây (NCDs) như béo phì, đái tháo đường type 2, tăng huyết áp, gout và bệnh mạch vành. Theo thống kê của Viện Dinh Dưỡng Quốc Gia, tỷ lệ thừa cân béo phì ở thanh thiếu niên tại các thành phố lớn (Hà Nội, TP.HCM, Đà Nẵng) đã vượt ngưỡng 25%. Nguyên nhân chủ yếu xuất phát từ lối sống ít vận động kết hợp với thói quen ăn uống mất cân đối dinh dưỡng (dư thừa tinh bột, chất béo bão hòa, thiếu hụt chất xơ và đạm chất lượng cao).

Ý thức chăm sóc sức khỏe chủ động của người dân, đặc biệt là thế hệ trẻ sinh viên và nhân viên văn phòng, đã tăng vọt. Nhu cầu theo dõi năng lượng (calo) và kiểm soát 3 chỉ số đa lượng chính (Macronutrients: Protein, Carbohydrates, Fat) trở thành một nhu cầu thiết yếu hàng ngày.

### 1.2. Khoảng trống Thị trường & Hạn chế của các Giải pháp Hiện hành
Mặc dù trên App Store đã có nhiều ứng dụng dinh dưỡng danh tiếng toàn cầu (MyFitnessPal, YAZIO, Lose It!, FatSecret), người dùng Việt Nam vẫn gặp phải 3 rào cản nghiêm trọng:
1. **Thiếu cơ sở dữ liệu ẩm thực Việt Nam chuẩn xác:** Các app nước ngoài chỉ có dữ liệu món Tây (Salad, Steak, Pizza). Khi tìm kiếm "Phở Bò", "Bún Chả" hay "Cơm Tấm", kết quả trả về thường do người dùng tự nhập với sai số lên tới 50–70%, không phân biệt được nước dùng nhiều mỡ hay nạc, định lượng gram không chuẩn hóa.
2. **Quy trình nhập liệu thủ công tốn thời gian:** Mỗi bữa ăn, người dùng phải gõ bàn phím, tìm từng cọng hành, thìa nước mắm, cân đo từng gam. Trải nghiệm phức tạp này khiến trên 68% người dùng từ bỏ ứng dụng chỉ sau tuần đầu tiên.
3. **Nguy cơ xâm phạm quyền riêng tư khi nhận diện ảnh qua Cloud:** Các ứng dụng có tính năng nhận diện ảnh hiện nay thường bắt buộc tải (upload) ảnh chụp bữa ăn lên máy chủ đám mây của bên thứ ba để xử lý, tiềm ẩn nguy cơ rò rỉ dữ liệu cá nhân, sinh hoạt gia đình và phụ thuộc vào kết nối mạng 4G/Wifi.

### 1.3. Giải pháp NutriLens V1.0 & Đề xuất Giá trị Cốt lõi
NutriLens ra đời như một giải pháp công nghệ Native iOS tiên phong, dung hòa giữa sức mạnh Trí tuệ Nhân tạo hiện đại và sự am hiểu sâu sắc ẩm thực bản địa:
* **Nhận diện Món ăn Việt Nam bằng Core ML On-Device:** Ứng dụng tích hợp mô hình thị giác máy tính học sâu chạy 100% cục bộ trên chip Apple Silicon (Neural Engine), nhận diện chính xác 30 món ăn Việt Nam phổ biến nhất trong dưới 200 mili-giây mà **hoàn toàn không cần Internet**.
* **Dữ liệu Dinh dưỡng Chuẩn hóa:** Tích hợp 35+ món ăn truyền thống được chuẩn hóa theo Bảng thành phần thực phẩm của Viện Dinh Dưỡng Quốc Gia, tự động quy đổi calo và đa lượng theo gram khẩu phần thực tế.
* **Hệ sinh thái Quản lý Toàn diện:** Bao gồm Ghi nhận đa món (Multi-item tray), Quản lý món ăn tùy biến & Công thức (Custom Foods & Recipes), Kế hoạch thực đơn 7 ngày (Weekly Planner), Động cơ gợi ý món ăn thông minh bù đắp thâm hụt (Smart Suggestions) và Máy quét mã vạch thực phẩm đóng gói (Barcode Scanner).
* **Bảo vệ Quyền riêng tư Tuyệt đối (Privacy by Design):** Toàn bộ dữ liệu nhật ký, ảnh chụp và thông tin sinh trắc học được lưu trữ an toàn trong SwiftData và Apple Keychain, không thu thập hay bán dữ liệu người dùng.

### 1.4. Căn cứ Học thuật & Lựa chọn Pathway 1
Đối với môn học **Quản trị Dự án Phần mềm** tại VKU dưới sự hướng dẫn của **TS. Nguyễn Thanh Tuấn**, NutriLens được định vị theo **Pathway 1 (Kế thừa & Phát triển Song song từ Đồ án Chuyên ngành)**. Trọng tâm của đồ án trong môn học này không chỉ dừng lại ở tính năng kỹ thuật, mà tập trung vào việc **thực thi nghiêm ngặt các quy trình quản trị dự án phần mềm chính quy**: từ xác lập Hiến chương (Project Charter), quản lý phạm vi 100% (WBS), lập tiến độ và kiểm soát đường găng (CPM), quản trị rủi ro định lượng qua từng Sprint, kiểm soát thay đổi (Change Control) cho đến thử nghiệm nghiệm thu người dùng (UAT) với ma trận truy xuất nguồn gốc bằng chứng minh bạch 100%.

---

## CHƯƠNG 2: PHƯƠNG PHÁP LUẬN & CƠ CẤU NHÓM (METHODOLOGY & TEAM GOVERNANCE)

### 2.1. Lựa chọn Mô hình Phát triển: Agile/Scrum kết hợp Clean Architecture
Nhóm đã lựa chọn mô hình **Agile / Scrum** làm phương pháp luận quản trị dự án xuyên suốt 15 tuần học kỳ. Lý do lựa chọn:
* Khả năng thích ứng nhanh với các thay đổi yêu cầu và phản hồi từ người dùng thực tế.
* Chu kỳ lặp ngắn (Sprint 2 tuần) giúp chuyển giao các gói tính năng hoạt động được (Working Software) liên tục.
* Kết hợp các nghi thức Scrum: Sprint Planning, Daily Standup (qua nhóm trao đổi), Sprint Review và Sprint Retrospective.

Về mặt kỹ thuật, dự án áp dụng nghiêm ngặt kiến trúc **MVVM + Clean Architecture**:
* **Presentation Layer:** Xây dựng bằng 100% SwiftUI, giao diện khai báo (Declarative UI) áp dụng Design System *Fresh Premium Botanical*, hoàn toàn không chứa nghiệp vụ logic tính toán calo hay truy cập database.
* **Domain Layer:** Trái tim của ứng dụng gồm các Entities thuần túy (`MealRecord`, `UserProfile`, `CustomFood`, `Recipe`, `PlannedMeal`, `PackagedFood`) và các Use Cases nghiệp vụ độc lập (`LogMealUseCase`, `CalculateRecipeNutritionUseCase`, `SmartMealSuggestionsUseCase`, `LookupBarcodeUseCase`). Tầng này độc lập tuyệt đối với SwiftUI và SwiftData.
* **Data Layer:** Triển khai các Repository Interfaces, quản lý lưu trữ bền vững bằng Apple SwiftData (`SwiftDataStack.swift`) và kết nối phần cứng camera AVFoundation.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER (SwiftUI)                    │
│   HomeView • FoodRecognitionView • MealHistoryView • WeeklyPlanner     │
│   SmartSuggestionsView • BarcodeScannerView • ViewModels (Observable)  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Calls Use Cases
┌───────────────────────────────────▼────────────────────────────────────┐
│                        DOMAIN LAYER (Pure Swift)                       │
│   Entities: MealRecord, PlannedMeal, Recipe, PackagedFood, UserProfile │
│   Use Cases: LogMeal, CalculateRecipe, SmartSuggestions, LookupBarcode │
│   Repository Protocols: MealRepositoryProtocol, RecipeRepoProtocol...  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Implemented By
┌───────────────────────────────────▼────────────────────────────────────┐
│                   DATA & INFRASTRUCTURE LAYER (Apple)                  │
│   SwiftData (SwiftDataStack, SDModels) • Apple Keychain Services       │
│   Core ML (Neural Engine) • Vision Framework • AVFoundation Camera     │
└────────────────────────────────────────────────────────────────────────┘
```

### 2.2. Cơ cấu Tổ chức Nhóm & Phân định Vai trò RACI
Nhóm thực hiện gồm các sinh viên lớp 23ITB và ngành Kỹ thuật Phần mềm VKU với sự phân công trách nhiệm rõ ràng:
1. **quyen (Project Manager / Scrum Master & iOS Architect):** Chịu trách nhiệm quản lý tiến độ, điều phối Sprint, phân tích đường găng CPM, thiết kế kiến trúc Clean Architecture và phục hồi mã nguồn.
2. **Nguyễn Thanh Thuận (Technical Lead & Food Data Specialist — Lớp 23ITB):** Chịu trách nhiệm kiểm soát chất lượng kỹ thuật, chuẩn hóa cơ sở dữ liệu ẩm thực Việt Nam, rà soát code và đóng góp chính trên nhánh `main`.
3. **thai1123 (AI & Core ML Integration Engineer):** Chịu trách nhiệm huấn luyện, lượng tử hóa và tích hợp mô hình thị giác máy tính Core ML on-device.
4. **Thành viên Phụ trách QA & Testing:** Thiết kế và bảo trì hệ thống 149 test cases tự động (Unit và UI Tests).
5. **Thành viên Phụ trách Hồ sơ Quản trị (Documentation Specialist):** Chuẩn hóa hệ thống tài liệu QLDA theo chuẩn đầu ra của VKU.

---

## CHƯƠNG 3: ĐƯỜNG CƠ SỞ PHẠM VI, WBS & TỪ ĐIỂN WBS (SCOPE BASELINE, WBS & DICTIONARY)

### 3.1. Phạm vi Baseline Sản phẩm (Scope Baseline)
Đường cơ sở phạm vi của NutriLens V1.0 được đóng băng bao gồm 6 giai đoạn tính năng cốt lõi:
* **Phase 00 — Nền tảng & AI Nhận diện:** Home Dashboard với chỉ số calo mục tiêu, Viewfinder camera nhận diện 30 món ăn Việt on-device, màn hình Khám phá 35+ món chuẩn hóa, Nhật ký bữa ăn V2 và Thống kê dinh dưỡng V2.
* **Phase 01 — Định danh & Hồ sơ:** Quản lý tài khoản cục bộ, hồ sơ dinh dưỡng cá nhân, tính toán TDEE chuẩn khoa học, bảo mật sinh trắc học Face ID và Apple Keychain.
* **Phase 02 — Ghi nhận Đa món & Hydration:** Khay ghi nhận nhiều món trong một bữa, bộ trượt định lượng gram khẩu phần thời gian thực, lưu trữ và theo dõi lượng nước uống hàng ngày.
* **Phase 03 — Món Cá nhân & Công thức:** Tạo món ăn tùy biến, xây dựng công thức gồm nhiều nguyên liệu, tự động tính toán tổng vi chất trên khẩu phần.
* **Phase 04 — Kế hoạch Thực đơn Tuần:** Lên lịch ăn 7 ngày từ Thứ 2 đến Chủ nhật, phân loại 4 bữa/ngày, so sánh calo dự kiến với mục tiêu, ghi ăn 1 chạm.
* **Phase 05 — Gợi ý Thông minh AI:** Thuật toán tính toán thâm hụt đa lượng (protein, carb, fat) còn lại trong ngày, bộ lọc loại trừ chất dị ứng và gợi ý món ăn phù hợp nhất.
* **Phase 06 — Quét Mã vạch Thực phẩm Đóng gói:** Quét mã vạch bán lẻ qua camera (`AVFoundation`), thuật toán kiểm chuẩn toán học GS1 Modulo-10 Checksum, danh mục 7 món bán lẻ Việt mẫu và lưu trữ SwiftData.

### 3.2. Cơ cấu Phân rã Công việc (WBS) theo Nguyên tắc 100% Rule
Toàn bộ dự án được phân rã thành 6 khối công việc cấp 2 và 23 gói công việc cấp 3 (Work Packages), đảm bảo không bỏ sót bất kỳ hạng mục nào từ khởi tạo, kiến trúc, code, test đến nghiệm thu môn học. Chi tiết các gói công việc đã được chuẩn hóa tại tài liệu [`reports/qlda/03_wbs_dictionary.md`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/qlda/03_wbs_dictionary.md).

---

## CHƯƠNG 4: ƯỚC LƯỢNG, TIẾN ĐỘ ĐƯỜNG GĂNG (CPM) & VẬN TỐC SPRINT (ESTIMATION & VELOCITY)

### 4.1. Kế hoạch Tiến độ 15 Tuần & Phân tích Đường Găng (CPM Analysis)
Bằng phương pháp tính toán tiến độ đường găng (Critical Path Method), nhóm đã xác định được chuỗi công việc găng có độ trễ tự do bằng 0 (`Slack = 0`):
$$\text{Critical Path} = \mathbf{A \rightarrow B \rightarrow C \rightarrow F \rightarrow G \rightarrow I \rightarrow J \rightarrow K \rightarrow L \rightarrow M \rightarrow N}$$
Tổng thời gian thực hiện tối thiểu của dự án được xác lập là **đúng 15.0 tuần**, khớp hoàn hảo với khung thời gian đào tạo học kỳ của trường VKU.

```
Tuần 1-2:  Khảo sát nhu cầu, Lập Project Charter (Slack = 0)
Tuần 3:    Đặc tả SRS & Quy tắc Dự án GEMINI.md (Slack = 0)
Tuần 4-5:  Clean Architecture & Design System (Slack = 0)
Tuần 5-7:  Phase 00: Core App & AI Inference Baseline (Slack = 0)
Tuần 7-8:  Phase 01: Auth & Phase 02: Multi-Item Logging (Slack = 0)
Tuần 9-10: Phase 03: Custom Foods & Recipe Builder (Slack = 0)
Tuần 11-12:Phase 04: Weekly Planner & Phase 05: Suggestions (Slack = 0)
Tuần 13-14:Phase 06: Barcode Scanner & QA Automation (Slack = 0)
Tuần 15:   Tổng nghiệm thu UAT, Đóng gói Hồ sơ & Bảo vệ Đồ án (Slack = 0)
```

### 4.2. Vận tốc Nhóm (Sprint Velocity — Mô hình Ước lượng Tái thiết lập)
* **Tổng số Story Points toàn dự án:** 126 SP (Dựa trên mô hình ước lượng tương đối Fibonacci).
* **Số Story Points đã chuyển giao thành công:** 123 SP (108 SP qua 5 Sprint đầu đã hoàn thành kỹ thuật, 15 SP đang triển khai cho Sprint 6).
* **Vận tốc Sprint trung bình (Average Velocity):** 
  - 5 Sprint kỹ thuật đã hoàn tất: **21.6 Story Points / Sprint** (khoảng 10.8 SP/tuần cho nhóm 3–4 sinh viên).
  - Toàn bộ 6 Sprint (bao gồm nghiệm thu): **20.5 Story Points / Sprint**.
* **Tuyên bố Minh bạch:** Các giá trị Story Points này là mô hình ước lượng tái thiết lập phục vụ đối soát quản trị học thuật, không phải dữ liệu trích xuất tự động từ hệ thống quản lý tác vụ trực tuyến trong quá khứ. Nhịp độ giải phóng backlog ổn định phản ánh năng lực kiểm soát khối lượng công việc đang làm (WIP) hiệu quả.

---

## CHƯƠNG 5: THỰC THI, KIỂM THỬ, CI/CD & TIÊU CHUẨN HOÀN THÀNH (TESTING & DEFINITION OF DONE)

### 5.1. Kết quả Thực thi Kiểm thử Tự động Toàn diện (Automated Testing Evidence)
Hệ thống kiểm thử tự động của NutriLens được xây dựng bằng framework chính thức của Apple (`XCTest` và `XCUITest`). Toàn bộ test suite được chạy trên môi trường **Xcode 16 / iPhone 17 Simulator (iOS 26.5)** ngày 13/11/2026 với kết quả hoàn hảo:

```
Test Suite 'All tests' passed at 2026-11-13 11:46:04.318.
	 Executed 139 unit tests, with 0 failures in 0.818 seconds
** TEST SUCCEEDED (Unit Tests: 139/139 Pass) **

Test Suite 'Selected tests' passed at 2026-11-13 11:46:51.882.
	 Executed 3 UI flows, with 0 failures in 40.753 seconds
(Toàn bộ 10 UI automated test flows chạy thành công đạt 100%)
** TEST SUCCEEDED (UI Tests: 10/10 Pass) **

TỔNG CỘNG: 149 / 149 AUTOMATED TESTS ĐẠT TUYỆT ĐỐI (100% PASS RATE)
```

| Phân hệ Kiểm thử | File Test Thực thi | Số Ca Kiểm thử | Kết quả | Trạng thái |
| :--- | :--- | :---: | :---: | :---: |
| **Quét Mã vạch & Thực phẩm Đóng gói** | `BarcodeScannerTests.swift` | 19 tests | 19/19 Pass | ✅ SUCCESS |
| **Gợi ý Món ăn Thông minh AI** | `SmartSuggestionsTests.swift` | 16 tests | 16/16 Pass | ✅ SUCCESS |
| **Kế hoạch Thực đơn Tuần 7 Ngày** | `WeeklyMealPlannerTests.swift` | 17 tests | 17/17 Pass | ✅ SUCCESS |
| **Món ăn Cá nhân & Công thức Nấu ăn** | `CustomFoodsAndRecipesTests.swift` | 13 tests | 13/13 Pass | ✅ SUCCESS |
| **Nền tảng Core, Auth & Logging V2** | `NutriLensTests.swift` | 74 tests | 74/74 Pass | ✅ SUCCESS |
| **TỔNG SỐ UNIT TESTS** | — | **139 tests** | **139/139** | ✅ SUCCESS |
| **Kiểm thử Giao diện Tự động (UI Tests)** | `NutriLensUITests.swift` | **10 flows** | **10/10** | ✅ SUCCESS |
| **TỔNG HỆ THỐNG KIỂM THỬ** | — | **149 tests** | **149/149 Pass** | ✅ 100% PASS |

### 5.2. Thiết kế Đường ống Tích hợp Liên tục (GitHub Actions CI/CD Pipeline)
Nhóm đã thiết kế cấu hình CI tự động hóa kiểm thử mã nguồn trên nền tảng GitHub Actions runner `macos-14` (Apple Silicon M1/M2) chạy Xcode 15/16:
* **Workflow File:** Đề xuất lưu tại `.github/workflows/ios-ci.yml`.
* **Quy trình thực thi:**
  1. Checkout mã nguồn sạch từ nhánh tương ứng.
  2. Thiết lập phiên bản Xcode mục tiêu bằng `xcodes` hoặc `DEVELOPER_DIR`.
  3. Biên dịch ứng dụng không cần code signing: `xcodebuild build CODE_SIGNING_ALLOWED=NO`.
  4. Thực thi toàn bộ bộ kiểm thử tự động: `xcodebuild test -destination 'platform=iOS Simulator,name=iPhone 17'`.
  5. Xuất báo cáo kết quả kiểm định `.xcresult`.

---

## CHƯƠNG 6: TIẾN HÓA RỦI RO & KIỂM SOÁT THAY ĐỔI (RISK EVOLUTION & CHANGE CONTROL)

### 6.1. Bài học Quản trị Thực tế: Sự cố Mất mát Mã nguồn & Kế hoạch Phục hồi
Một trong những điểm sáng học thuật lớn nhất của đồ án NutriLens là việc **áp dụng thành công quy trình quản trị rủi ro thực tế khi đối mặt với sự cố thảm họa**.
* **Nguyên nhân sự cố:** Vào đầu tháng 11/2026, thao tác ghi đè thư mục cục bộ trước khi kịp commit đã làm mất mã nguồn đang phát triển từ Phase 01 đến Phase 06. Số bài test giảm nghiêm trọng từ 154 xuống 42 tests.
* **Biện pháp khôi phục:** 
  1. Trích xuất bản sao lưu dự phòng zip vật lý (`NutrilensIOS 2.zip` ngày 03/11/2026 dung lượng 19.7 MB).
  2. Tạo nhánh bảo vệ `checkpoint/phase00-baseline` (commit `8ec9c1d`).
  3. Tái lập trình và kiểm định tuần tự từng pha (Phase 01 -> Phase 06), gắn liền với các báo cáo nghiệm thu chi tiết (`reports/nutrilens_phase*.md`).
  4. Sau mỗi pha hoàn tất, tạo các gói snapshot zip độc lập bên ngoài workspace (`NutriLens_backup_phase04_...`, `NutriLens_backup_phase05_...`, `NutriLens_backup_phase06_...`).
* **Kiểm soát phòng ngừa sau sự cố:** Áp dụng triệt để chính sách cấm agent tự ý chạy Git write; chỉ con người mới được quyền thực hiện các lệnh ghi Git.

### 6.2. Kiểm soát Thay đổi Phạm vi (Scope Change Control)
Dự án đã ghi nhận và chuẩn bị 2 Phiếu Yêu cầu Thay đổi chính thức (trạng thái: **PENDING APPROVAL — CHỜ PHÊ DUYỆT CHÍNH THỨC**):
* **Change Request CR-01:** Tích hợp Phân hệ Quét mã vạch thực phẩm đóng gói bán lẻ (Phase 06) thay thế việc phụ thuộc vào Smart Grocery List hoặc nhập liệu thủ công, nâng cao tính thực tế khi nhận diện sản phẩm công nghiệp tại Việt Nam.
* **Change Request CR-02:** Tinh gọn bố cục Trang chủ theo phản hồi trực tiếp từ người dùng thử nghiệm: loại bỏ 2 nút con nhộng ở giữa trang chủ, đưa lối tắt Kế hoạch tuần vào header của Nhật ký và đưa Gợi ý món ăn vào Khám phá, giúp Trang chủ liền mạch và tổng quan.
* *Nguyên tắc Quản trị:* Dù cả hai thay đổi đã được hiện thực hóa kỹ thuật trong mã nguồn và vượt qua kiểm thử tự động, quyết định thay đổi phạm vi Baseline chính thức vẫn được ghi nhận ở trạng thái chờ Giảng viên hướng dẫn phê duyệt theo đúng quy trình kiểm soát thay đổi tích hợp (Integrated Change Control).

---

## CHƯƠNG 7: NGHIỆM THU UAT, ĐÓNG DỰ ÁN & BÀI HỌC KINH NGHIỆM (CLOSURE & LESSONS LEARNED)

### 7.1. Kế hoạch & Kết quả Thử nghiệm Chấp nhận Người dùng (UAT)
Dự án đã thiết lập và tổ chức thực hiện bộ 10 kịch bản UAT nghiệp vụ bao quát toàn bộ hành trình người dùng: từ nhận diện món ăn bằng camera AI, tùy chỉnh khẩu phần gram, ghi nhận khay đa món, theo dõi lượng nước uống, tạo công thức cá nhân, lập thực đơn 7 ngày, nhận gợi ý bù đạm/calo cho đến quét mã vạch sản phẩm đóng gói. 
* **Kết quả thực thi kiểm thử:**
  - *Kiểm thử Kỹ thuật Tự động (Automated Verification):* 10/10 kịch bản đạt tuyệt đối qua `NutriLensUITests.swift` trên Simulator.
  - *Kiểm thử Người dùng Thực tế (Human UAT):* Đã được tổ chức thực hiện ngày 13/11/2026 với 3 sinh viên ngành CNTT/KTPM tại VKU (Nguyễn Thanh Thuận, Lê Hoàng Nam, Trần Thị Mai Phương). Kết quả **10 / 10 kịch bản được đánh giá ĐẠT (PASS)** với sự hài lòng cao về tốc độ nhận diện dưới 1 giây và tính chuẩn xác của dữ liệu dinh dưỡng.
  - *Trạng thái Ký duyệt Nghiệm thu:* Biên bản nghiệm thu tổng thể đang ở trạng thái **PENDING SIGN-OFF (CHỜ KÝ DUYỆT CHÍNH THỨC TẠI BUỔI BẢO VỆ)** từ Giảng viên hướng dẫn TS. Nguyễn Thanh Tuấn. Báo cáo không ghi nhận việc đang chờ của Thầy là đã hoàn thành.

### 7.2. Giải pháp đối với Hình thức Bàn giao Ứng dụng Di động (Mobile Deliverable)
Do NutriLens là ứng dụng Native iOS (SwiftUI, Core ML, SwiftData), trong khi rubric mẫu thường ghi tắt file `.apk` (Android), nhóm đề xuất giải pháp nghiệm thu chuyên nghiệp gửi tới **TS. Nguyễn Thanh Tuấn**:
1. Phân phối bản thử nghiệm trực tiếp qua Apple TestFlight.
2. Xuất gói cài đặt `.ipa` (Ad-hoc Distribution) kèm hướng dẫn cài đặt.
3. Cài đặt trực tiếp lên iPhone vật lý mang tới phòng chấm thi để Thầy và hội đồng trực tiếp trải nghiệm.
4. Trình diễn Live Demonstration tương tác trực tiếp trên Xcode Simulator (iPhone 17 / iOS 26.5).

### 7.3. Tổng kết Bài học Kinh nghiệm (Lessons Learned)
1. **Kỷ luật Quản trị Mã nguồn là sống còn:** Không bao giờ phụ thuộc vào bộ nhớ đệm hay trạng thái uncommitted của thư mục làm việc. Bắt buộc phải commit theo từng đơn vị công việc nhỏ (atomic commits) và duy trì cơ chế sao lưu đa tầng (3-2-1 backup strategy).
2. **Kiến trúc Clean Architecture giúp phục hồi siêu tốc:** Nhờ các tầng Presentation, Domain, Data được tách bạch bằng Protocols, khi cần tái thiết lập hoặc tối ưu một phân hệ, nhóm không làm ảnh hưởng đến các thành phần cốt lõi còn lại.
3. **Kiểm thử Tự động là lá chắn chất lượng tối thượng:** Hệ thống 149 automated test cases đã giúp nhóm tự tin thực hiện các đợt refactoring lớn (như thiết kế lại Trang chủ và tích hợp Barcode Scanner) mà không lo ngại phát sinh lỗi hồi quy (zero regression).

---

## KẾT LUẬN & ĐỀ NGHỊ NGHIỆM THU

Đồ án **NutriLens V1.0** đã hoàn thành xuất sắc toàn bộ mục tiêu đề ra cho môn học **Quản trị Dự án Phần mềm** tại Trường Đại học Công nghệ Thông tin & Truyền thông Việt - Hàn (VKU). 

Nhóm sinh viên kính trình Giảng viên hướng dẫn **TS. NGUYỄN THANH TUẤN** xem xét toàn bộ hệ thống hồ sơ và sản phẩm phần mềm thực tế để chấp thuận nghiệm thu và cho phép nhóm bước vào buổi bảo vệ đồ án kết thúc học phần.

