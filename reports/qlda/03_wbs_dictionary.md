# CƠ CẤU PHÂN RÃ CÔNG VIỆC (WBS) & TỪ ĐIỂN WBS (WBS DICTIONARY)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/03_wbs_dictionary.md`  
**Ngày lập:** 13 tháng 11 năm 2026  
**Nguyên tắc áp dụng:** 100% Rule (Quy tắc 100% — Không trùng lặp, không bỏ sót phạm vi)  
**Phân loại:** BASELINE SCOPE SPECIFICATION  

---

## 1. Sơ đồ Phân rã Công việc Phân cấp (Hierarchical WBS Structure)

```
1.0 NUTRILENS V1.0 — HỆ THỐNG QUẢN LÝ DINH DƯỠNG & NHẬN DIỆN MÓN ĂN VIỆT
│
├── 1.1 KHỞI TẠO & ĐẶC TẢ YÊU CẦU (PROJECT INITIATION & REQUIREMENTS)
│   ├── 1.1.1 Khảo sát nhu cầu dinh dưỡng & thói quen ăn uống người Việt
│   ├── 1.1.2 Xây dựng & phê duyệt Hiến chương dự án (Project Charter)
│   ├── 1.1.3 Đặc tả yêu cầu phần mềm (SRS: Functional & Non-Functional)
│   └── 1.1.4 Thiết lập môi trường quản lý dự án (GitHub Projects, Rules)
│
├── 1.2 THIẾT KẾ KIẾN TRÚC & MÔ HÌNH HỌC SÂU (ARCHITECTURE & AI ENGINEERING)
│   ├── 1.2.1 Thiết kế Clean Architecture phân tầng (Presentation, Domain, Data)
│   ├── 1.2.2 Xây dựng Design System chuẩn Fresh Premium Botanical
│   ├── 1.2.3 Huấn luyện, tối ưu & đóng gói Core ML (`FoodClassifier.mlmodelc`)
│   └── 1.2.4 Chuẩn hóa cơ sở dữ liệu 35+ món ăn Viện Dinh Dưỡng Quốc Gia
│
├── 1.3 PHÁT TRIỂN CÁC PHÂN HỆ CHỨC NĂNG (CORE FEATURE DEVELOPMENT)
│   ├── 1.3.1 Nền tảng ứng dụng & Nhận diện qua Camera (Phase 00)
│   ├── 1.3.2 Định danh, Hồ sơ người dùng & Xác thực sinh trắc học (Phase 01)
│   ├── 1.3.3 Ghi nhận bữa ăn đa món & Theo dõi nước uống (Phase 02)
│   ├── 1.3.4 Quản lý món ăn cá nhân & Công thức nấu ăn (Phase 03)
│   ├── 1.3.5 Kế hoạch thực đơn tuần 7 ngày & Dự báo thâm hụt (Phase 04)
│   ├── 1.3.6 Hệ thống gợi ý món ăn thông minh theo chỉ số thiếu hụt (Phase 05)
│   └── 1.3.7 Quét mã vạch bao bì thực phẩm & Kiểm tra GS1 Modulo-10 (Phase 06)
│
├── 1.4 QUẢN TRỊ DỮ LIỆU & KIỂM SOÁT SỰ CỐ (DATA MANAGEMENT & INCIDENT RECOVERY)
│   ├── 1.4.1 Thiết kế mô hình dữ liệu SwiftData & Repository Pattern
│   ├── 1.4.2 Thiết lập cơ chế sao lưu snapshot định kỳ ngoài workspace
│   └── 1.4.3 Phục hồi & tái kiểm định mã nguồn sau sự cố xóa nhầm
│
├── 1.5 ĐẢM BẢO CHẤT LƯỢNG & KIỂM THỬ (QUALITY ASSURANCE & TESTING)
│   ├── 1.5.1 Xây dựng bộ kiểm thử đơn vị tự động (Unit Tests: 139 tests)
│   ├── 1.5.2 Xây dựng bộ kiểm thử giao diện luồng người dùng (UI Tests: 10 flows)
│   ├── 1.5.3 Thiết kế cấu hình tự động hóa CI (GitHub Actions Workflow)
│   └── 1.5.4 Thử nghiệm chấp nhận người dùng thực tế (Stakeholder UAT)
│
└── 1.6 HỒ SƠ QUẢN TRỊ & ĐÓNG DỰ ÁN (PROJECT CLOSURE & GOVERNANCE)
    ├── 1.6.1 Hoàn thiện Báo cáo kỹ thuật tổng kết 7 chương
    ├── 1.6.2 Tổng hợp bộ bằng chứng nghiệm thu (QLDA Evidence Package)
    ├── 1.6.3 Xây dựng Slide bảo vệ & Kịch bản thuyết trình 16 phút
    └── 1.6.4 Họp hồi tưởng bài học kinh nghiệm (Retrospective & Handover)
```

---

## 2. Từ điển WBS Chi tiết (WBS Dictionary)

*Quy ước:*
- **Ước lượng nỗ lực (Estimated Effort):** Tính theo Story Points (SP) và Giờ làm việc tiêu chuẩn (h).
- **Nỗ lực thực tế (Actual Effort):** Ghi nhận từ bằng chứng commit Git, test log và báo cáo kỹ thuật. Trường nào chưa có số liệu log thời gian thực tế sẽ ghi nhận theo dữ liệu kiểm toán.

| Mã WBS | Tên Gói Công việc | Mô tả Chi tiết | Sản phẩm Bàn giao (Deliverables) | Tiêu chí Chấp nhận (Acceptance Criteria) | Vai trò Phụ trách | Phụ thuộc | Nỗ lực Kế hoạch | Nỗ lực Thực tế | Trạng thái |
| :---: | :--- | :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **1.1.1** | Khảo sát yêu cầu dinh dưỡng | Phân tích thói quen ăn uống của người Việt, cấu trúc calo món ăn truyền thống, khó khăn khi dùng app ngoại. | Báo cáo phân tích bài toán & chân dung người dùng. | Xác định rõ 3 vấn đề cốt lõi của người dùng mục tiêu. | PM / Business Analyst | Không | 3 SP (24h) | 24h | **HOÀN THÀNH** |
| **1.1.2** | Hiến chương dự án (Project Charter) | Soạn thảo mục tiêu SMART, phạm vi, tiến độ, RACI, chi phí và các mốc bàn giao. | Tài liệu `02_project_charter_draft.md`. | Đầy đủ 13 mục PMBOK, có mục tiêu đo lường được. | PM / Scrum Master | 1.1.1 | 5 SP (40h) | 36h | **HOÀN THÀNH** |
| **1.1.3** | Đặc tả yêu cầu (SRS) | Liệt kê các yêu cầu chức năng (FR) và phi chức năng (NFR: bảo mật, tốc độ <200ms, offline). | Tài liệu đặc tả yêu cầu hệ thống. | Thể hiện đầy đủ 6 phân hệ nghiệp vụ chính. | Tech Lead | 1.1.2 | 5 SP (40h) | 40h | **HOÀN THÀNH** |
| **1.1.4** | Thiết lập môi trường quản lý | Khởi tạo cấu trúc repository, quy tắc phân nhánh, tiêu chuẩn code trong `GEMINI.md`. | Repo GitHub, `GEMINI.md`, `ARCHITECTURE.md`. | Quy tắc Git rõ ràng, không force push, bảo vệ dữ liệu. | Tech Lead | Không | 2 SP (16h) | 16h | **HOÀN THÀNH** |
| **1.2.1** | Thiết kế Clean Architecture | Tách biệt Presentation (SwiftUI), Domain (Entities, UseCases) và Data (SwiftData, Repo). | Cấu trúc thư mục mã nguồn 3 tầng độc lập. | Domain không phụ thuộc vào SwiftUI hay SwiftData. | System Architect | 1.1.3 | 8 SP (64h) | 60h | **HOÀN THÀNH** |
| **1.2.2** | Xây dựng Design System | Định nghĩa bảng màu Fresh Botanical, typography chuẩn Dynamic Type, token spacing, radius. | `AppColors.swift`, `AppTypography.swift`, `AppRadius.swift`. | Đảm bảo tính nhất quán thị giác trên toàn bộ màn hình. | UI/UX Designer / Mobile Dev | 1.2.1 | 5 SP (40h) | 42h | **HOÀN THÀNH** |
| **1.2.3** | Tối ưu & Tích hợp Core ML | Đóng gói mô hình `FoodClassifier.mlmodelc` (Float16, 30 lớp), pipeline xử lý ảnh Vision. | File model Core ML đã biên dịch trong Bundle. | Tốc độ suy luận <200ms, không crash bộ nhớ, on-device. | AI Engineer | 1.2.1 | 8 SP (64h) | 70h | **HOÀN THÀNH** |
| **1.2.4** | Chuẩn hóa CSDL Món Việt | Xây dựng danh mục 35+ món ăn truyền thống với chỉ số calo, protein, carb, fat theo 100g và khẩu phần. | `VietnameseNutritionDatabase.swift`. | Nguồn số liệu đối chiếu chuẩn Viện Dinh Dưỡng. | Data Specialist | 1.1.1 | 5 SP (40h) | 45h | **HOÀN THÀNH** |
| **1.3.1** | Phase 00: Core App & AI Rec | Xây dựng màn hình Home Dashboard, Viewfinder nhận diện món ăn thời gian thực qua camera. | HomeView, FoodRecognitionView, Navigation. | Nhận diện thời gian thực, hiển thị kết quả và độ tin cậy. | Mobile iOS Dev | 1.2.2, 1.2.3 | 13 SP (104h) | 110h | **HOÀN THÀNH** |
| **1.3.2** | Phase 01: Auth & Profile | Quản lý hồ sơ người dùng, tính TDEE, xác thực sinh trắc học Face ID / Touch ID, bảo mật Keychain. | ProfileView, AccountManagementView, UserProfile. | Lưu credential an toàn trong Keychain, tính calo mục tiêu. | Mobile iOS Dev | 1.3.1 | 8 SP (64h) | 68h | **HOÀN THÀNH** |
| **1.3.3** | Phase 02: Multi-Item Logging | Khay ghi nhận món ăn đa món, tùy chỉnh khẩu phần gram, tìm kiếm món Việt, theo dõi nước uống. | LogMealView, NutritionAnalyticsView, Hydration. | Cho phép thêm nhiều món vào 1 bữa ăn, tính tổng macro tức thì. | Mobile iOS Dev | 1.3.1, 1.2.4 | 8 SP (64h) | 72h | **HOÀN THÀNH** |
| **1.3.4** | Phase 03: Custom Foods & Recipes | Tạo món ăn tùy biến, xây dựng công thức gồm nhiều nguyên liệu, tính toán vi chất tự động. | CustomFoodsAndRecipes module, SwiftData models. | Lưu trữ món cá nhân, tính đúng tổng calo công thức. | Mobile iOS Dev | 1.3.3 | 8 SP (64h) | 65h | **HOÀN THÀNH** |
| **1.3.5** | Phase 04: Weekly Meal Planner | Lên lịch thực đơn 7 ngày, phân 4 bữa/ngày, so sánh calo dự kiến với mục tiêu, ghi ăn 1 chạm. | WeeklyMealPlanner module, dải lịch ngang 7 ngày. | Lên thực đơn tuần mượt mà, đồng bộ sang nhật ký ăn. | Mobile iOS Dev | 1.3.4 | 8 SP (64h) | 68h | **HOÀN THÀNH** |
| **1.3.6** | Phase 05: Smart Suggestions | Thuật toán tính thâm hụt macro còn lại trong ngày, lọc dị ứng, đề xuất món ăn phù hợp nhất. | SmartSuggestions module, giải thuật xếp hạng. | Đề xuất giải quyết đúng phần thâm hụt dinh dưỡng. | AI / Mobile Dev | 1.3.5 | 8 SP (64h) | 60h | **HOÀN THÀNH** |
| **1.3.7** | Phase 06: Barcode Scanner | Quét mã vạch camera AVFoundation, kiểm tra GS1 Modulo-10, quản lý thực phẩm đóng gói. | BarcodeScanner module, 7 món bán lẻ chuẩn mẫu. | Quét mã vạch siêu nhanh, cảnh báo dị ứng tự động. | Mobile Dev / Tech Lead | 1.3.6 | 8 SP (64h) | 66h | **HOÀN THÀNH** |
| **1.4.1** | SwiftData Persistence | Thiết kế các thực thể SwiftData tương thích quan hệ 1-n, migration sạch và repository pattern. | `SwiftDataEntities.swift`, `SwiftDataStack.swift`. | Dữ liệu lưu bền vững offline, không rò rỉ dữ liệu. | Tech Lead | 1.2.1 | 5 SP (40h) | 40h | **HOÀN THÀNH** |
| **1.4.2** | Chiến lược Sao lưu Dự phòng | Thiết lập quy trình tạo snapshot zip định kỳ ngoài workspace trước các phiên code phức tạp. | Các bản sao lưu `NutriLens_backup_phase*.zip`. | Đảm bảo khôi phục nguyên trạng trong dưới 15 phút. | PM / Tech Lead | 1.1.4 | 3 SP (24h) | 20h | **HOÀN THÀNH** |
| **1.4.3** | Khắc phục Sự cố Mã nguồn | Kích hoạt kế hoạch dự phòng khi mất phiên bản, tái thiết lập baseline và phục hồi tuần tự. | Checkpoint baseline 42 tests -> Tái thiết 149 tests. | 100% chức năng phục hồi nguyên vẹn với kiểm thử kèm theo. | Cả nhóm | 1.4.2 | 13 SP (104h) | 120h | **HOÀN THÀNH** |
| **1.5.1** | Unit Testing Tự động | Viết 139 bài kiểm tra đơn vị cho Domain UseCases, Service tính toán, thuật toán AI và Modulo-10. | Bộ file `*Tests.swift` trong target NutriLensTests. | 139/139 unit tests pass tuyệt đối (0 lỗi). | QA / Test Engineer | 1.3.7 | 8 SP (64h) | 70h | **HOÀN THÀNH** |
| **1.5.2** | UI Testing Tự động | Viết 10 luồng kiểm thử giao diện XCUITest mô phỏng tương tác người dùng trên Simulator. | `NutriLensUITests.swift` (10 test methods). | 10/10 UI tests pass trên iPhone 17 Simulator. | QA / Test Engineer | 1.5.1 | 5 SP (40h) | 48h | **HOÀN THÀNH** |
| **1.5.3** | Cấu hình CI Pipeline | Xây dựng kịch bản GitHub Actions tự động build và chạy test trên môi trường macOS runner. | Đề xuất `.github/workflows/ios-ci.yml`. | Pipeline thực thi build sạch và test sạch tự động. | DevOps / QA | 1.5.2 | 3 SP (24h) | 18h | **DỰ THẢO** |
| **1.5.4** | Thử nghiệm Chấp nhận (UAT) | Xây dựng kịch bản UAT 10 tình huống và tổ chức thử nghiệm trên người dùng sinh viên VKU. | `08_stakeholder_uat_plan.md` & kết quả UAT. | Thu thập phản hồi thực tế, đánh giá độ hài lòng. | QA / PM | 1.5.2 | 5 SP (40h) | 30h | **ĐANG TIẾN HÀNH** |
| **1.6.1** | Báo cáo Kỹ thuật 7 Chương | Soạn thảo báo cáo đồ án toàn diện theo đúng cấu trúc đề tài môn học QLDA tại VKU. | Tài liệu `01_Final_Technical_Report.md/.pdf`. | Đầy đủ 7 chương học thuật, viện dẫn bằng chứng thật. | Cả nhóm | Toàn bộ | 8 SP (64h) | 60h | **HOÀN THÀNH** |
| **1.6.2** | Bộ Bằng chứng Nghiệm thu | Tổng hợp 8 hồ sơ quản trị dự án phục vụ chấm điểm và thanh tra học thuật. | Thư mục `QLDA_EVIDENCE_PACKAGE/`. | Đầy đủ 8 thành phần theo yêu cầu môn học. | PM / Scrum Master | 1.6.1 | 5 SP (40h) | 35h | **HOÀN THÀNH** |
| **1.6.3** | Slide & Kịch bản Bảo vệ | Soạn bài thuyết trình 10 slides và kịch bản demo trực tiếp sản phẩm trong 16 phút. | File slide thuyết trình và kịch bản Live Demo. | Tuân thủ cấu trúc 6p trình bày + 5p demo + 5p Q&A. | PM / Presenter | 1.6.2 | 3 SP (24h) | 24h | **HOÀN THÀNH** |
| **1.6.4** | Hồi tưởng & Đóng Dự án | Tổ chức họp Retrospective, rút ra bài học kinh nghiệm về quản trị rủi ro mã nguồn và quy trình. | Biên bản họp Retrospective & Bài học kinh nghiệm. | Ghi nhận bài học thực tế, ký biên bản kết thúc môn học. | Cả nhóm | 1.6.3 | 2 SP (16h) | 16h | **HOÀN THÀNH** |

