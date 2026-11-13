# DANH MỤC PRODUCT BACKLOG & GITHUB ISSUES SẴN SÀNG CÔNG BỐ (ISSUE INVENTORY)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/github_audit/03_issue_backlog_ready_to_publish.md`  
**Ngày lập danh mục:** 13 tháng 11 năm 2026  
**Trạng thái phát hành:** `PENDING USER AUTHORIZATION` (Lưu cục bộ dạng Draft, chưa tạo trên GitHub)  
**Quy chuẩn định danh:** Dùng mã tạm thời `DRAFT-ISSUE-xxx`, không tự gán số ID remote để tránh sai lệch.

---

## 1. Nguyên Tắc Quản Trị Danh Mục Backlog & Liêm Chính Học Thuật

> [!IMPORTANT]
> **Quy định Liêm chính Học thuật:**
> - Toàn bộ các tính năng kỹ thuật đã được viết mã và vượt qua bộ test suite trước đây khi công bố lên GitHub sẽ được gắn nhãn rõ ràng: `[Retrospective - Verified in Code]` (Tài liệu hóa hồi cố các hạng mục đã hoàn thành).
> - Nhóm **tuyệt đối không làm giả ngày tạo issue (không backdate issues)** để đánh lừa thời gian. Mọi Issue khi tạo mới trên GitHub sẽ phản ánh đúng thời điểm tạo thực tế, đồng thời ghi chú chi tiết ngày hoàn thành thực tế và mã commit minh chứng trong phần nội dung.

---

## 2. Bảng Tổng Hợp Danh Mục 16 Issues Toàn Diện Theo WBS & Sprint

| Mã Draft | Mã WBS | Tiêu đề Issue (Title) | Sprint | SP | Ưu tiên | Người phụ trách | Trạng thái kỹ thuật |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `DRAFT-001` | WBS 1.1.1 | Project Charter, Phạm vi dự án & Hồ sơ Kiến trúc Clean Arch | Sprint 0 | 5 | P0 | @Quyens | Tài liệu Draft hoàn chỉnh |
| `DRAFT-002` | WBS 1.2.1 | Thiết lập Design System Fresh Botanical & Tokens (Màu, Font, Bo) | Sprint 1 | 3 | P1 | @Thai1123 | Verified (`AppColors.swift`) |
| `DRAFT-003` | WBS 1.2.2 | Cơ sở dữ liệu 35+ món ăn Việt Nam chuẩn Viện Dinh Dưỡng | Sprint 1 | 5 | P0 | @thuan5587 | Verified (`FoodExplorerView`) |
| `DRAFT-004` | WBS 1.3.1 | Tích hợp Core ML Food Classifier & Camera AI Viewfinder on-device | Sprint 1 | 8 | P0 | @Thai1123 | Verified (`FoodRecognitionView`) |
| `DRAFT-005` | WBS 1.3.2 | Quản lý Hồ sơ người dùng, Mục tiêu Calo & Xác thực Offline | Sprint 1 | 5 | P1 | @Quyens | Verified (`ProfileView`, Commit `30c2758`) |
| `DRAFT-006` | WBS 1.3.3 | Ghi nhận bữa ăn đa món (Multi-Item Logging) & Khay ghi nhận | Sprint 2 | 8 | P0 | @Quyens | Verified (`LogMealView`, Commit `7fb01c3`) |
| `DRAFT-007` | WBS 1.3.4 | Nhật ký dinh dưỡng theo tuần, phân tích Macro & Theo dõi Nước | Sprint 2 | 5 | P1 | @Quyens | Verified (`MealHistoryView`) |
| `DRAFT-008` | WBS 1.3.5 | Cơ sở dữ liệu món ăn tự tạo (Custom Foods) & Thư viện Công thức | Sprint 2 | 8 | P1 | @thuan5587 | Verified (`CustomFoodRepository`) |
| `DRAFT-009` | WBS 1.3.6 | Kế hoạch thực đơn tuần 7 ngày (Weekly Meal Planner) | Sprint 3 | 8 | P1 | @Quyens | Verified (`WeeklyMealPlannerView`) |
| `DRAFT-010` | WBS 1.3.7 | Gợi ý món ăn thông minh cá nhân hóa, khẩu vị & cảnh báo dị ứng | Sprint 3 | 8 | P1 | @Thai1123 | Verified (`SmartSuggestionsView`) |
| `DRAFT-011` | WBS 1.3.8 | Quét mã vạch bao bì thực phẩm EAN-13 & Quản lý thực phẩm siêu thị | Sprint 3 | 8 | P0 | @Quyens | Verified (`BarcodeScannerView`) |
| `DRAFT-012` | WBS 1.4.1 | Xây dựng bộ kiểm thử tự động Unit Tests (139 ca kiểm thử) | Sprint 4 | 5 | P0 | @Quyens | Verified (`NutriLensTests`) |
| `DRAFT-013` | WBS 1.4.2 | Xây dựng bộ kiểm thử giao diện UI Tests (10 luồng nghiệp vụ) | Sprint 4 | 5 | P0 | @Quyens | Verified (`NutriLensUITests`) |
| `DRAFT-014` | WBS 1.4.3 | Tổ chức User Acceptance Testing (UAT) với 3 sinh viên VKU | Sprint 4 | 5 | P0 | @thuan5587 | Executed (10/10 PASS) |
| `DRAFT-015` | WBS 1.5.1 | Thiết lập Pipeline GitHub Actions CI/CD trên macos-14 | Sprint 4 | 3 | P1 | @Quyens | Draft `.github/workflows/` |
| `DRAFT-016` | WBS 1.5.2 | Đóng gói sản phẩm Release v1.0.0 & Slide báo cáo bảo vệ môn học | Sprint 4 | 5 | P0 | Cả nhóm | Hoàn tất bộ tài liệu QLDA |

---

## 3. Nội Dung Chi Tiết Từng Issue Sẵn Sàng Tạo Trên GitHub (Chi Tiết Mẫu)

Dưới đây là đặc tả chi tiết của các Issue trọng yếu sẵn sàng được nạp tự động lên GitHub:

### Issue `DRAFT-004` [Retrospective - Verified in Code]
- **Tiêu đề:** `[WBS 1.3.1] [FEAT] Nhận diện món ăn Việt Nam bằng Core ML on-device & Kính ngắm AI`
- **User Story:**
  > Là một người dùng theo dõi sức khỏe,  
  > Tôi muốn hướng camera vào đĩa thức ăn Việt Nam để hệ thống tự động nhận diện tên món và calo ước tính,  
  > Để tôi không phải tra cứu danh sách thủ công mất thời gian.
- **Tiêu chí Chấp nhận (Acceptance Criteria):**
  - [x] **Given:** Người dùng đã mở ứng dụng và cấp quyền Camera.
  - [x] **When:** Hướng kính ngắm AI vào món ăn (Phở bò, Bún chả, Cơm tấm).
  - [x] **Then:** Khung nhận diện hiển thị tên món chính xác, độ tin cậy (%) và calo chuẩn trong vòng dưới 1.0 giây.
  - [x] **Then:** Quá trình suy luận chạy 100% on-device qua Core ML, không gửi ảnh lên máy chủ đám mây.
- **Ước lượng:** 8 Story Points | **Ưu tiên:** P0 (Critical) | **Sprint:** Sprint 1
- **Người phụ trách:** `@Thai1123` | **Phản biện / Reviewer:** `@Quyens`
- **Minh chứng kỹ thuật:**
  - File mã nguồn: `NutriLens/Features/FoodRecognition/FoodRecognitionView.swift`
  - Unit Test: `NutriLensTests/UnitTests/FoodRecognitionTests.swift` (100% PASS)
  - Thử nghiệm thực tế: Kịch bản `UAT-01` (Lê Hoàng Nam ký nhận ĐẠT)

---

### Issue `DRAFT-006` [Retrospective - Verified in Code]
- **Tiêu đề:** `[WBS 1.3.3] [FEAT] Ghi nhận bữa ăn đa món (Multi-Item Logging) & Khay chọn linh hoạt`
- **User Story:**
  > Là một sinh viên ăn bữa cơm có nhiều món (cơm, canh, thịt),  
  > Tôi muốn gom nhiều món vào cùng một khay và điều chỉnh khẩu phần từng món trước khi ghi,  
  > Để nhật ký dinh dưỡng phản ánh chính xác bữa ăn thực tế.
- **Tiêu chí Chấp nhận (Acceptance Criteria):**
  - [x] **Given:** Người dùng đang ở màn hình ghi nhận bữa ăn.
  - [x] **When:** Thêm nhiều món vào khay và kéo thanh trượt điều chỉnh số gram.
  - [x] **Then:** Lượng Calo, Đạm, Carb, Chất béo tự động tính toán lại tức thì.
  - [x] **Then:** Nhấn "Ghi vào nhật ký", dữ liệu lưu bền vững vào SwiftData.
- **Ước lượng:** 8 Story Points | **Ưu tiên:** P0 (Critical) | **Sprint:** Sprint 2
- **Người phụ trách:** `@Quyens` | **Phản biện / Reviewer:** `@thuan5587`
- **Minh chứng kỹ thuật:**
  - File mã nguồn: `NutriLens/Features/MealTracking/LogMealView.swift`
  - Merge Commit: `7fb01c3` (Merge branch 'feature/phase02-meal-logging' into main)
  - Unit Test: `NutriLensTests/UnitTests/MealTrackingTests.swift` (100% PASS)
  - Thử nghiệm thực tế: Kịch bản `UAT-02` và `UAT-03` (Trần Thị Mai Phương & Nguyễn Thanh Thuận ký nhận)

---

### Issue `DRAFT-011` [Retrospective - Verified in Code]
- **Tiêu đề:** `[WBS 1.3.8] [FEAT] Quét mã vạch bao bì thực phẩm EAN-13 & Quản lý thực phẩm siêu thị`
- **User Story:**
  > Là một người tiêu dùng mua sắm thực phẩm đóng gói tại siêu thị,  
  > Tôi muốn quét mã vạch sản phẩm (sữa, bánh mì, đồ hộp) bằng camera,  
  > Để tra cứu bảng thành phần dinh dưỡng và ghi nhanh vào nhật ký.
- **Tiêu chí Chấp nhận (Acceptance Criteria):**
  - [x] **Given:** Người dùng cầm hộp sữa Vinamilk có mã vạch EAN-13.
  - [x] **When:** Đưa mã vạch vào khung quét camera AVFoundation.
  - [x] **Then:** Hệ thống kiểm tra thuật toán Modulo-10 checksum hợp lệ và hiển thị thông tin sản phẩm tức thì.
  - [x] **Then:** Người dùng có thể nhấn "Thêm vào nhật ký" hoặc lưu sản phẩm mới nếu mã vạch chưa có trong thư viện.
- **Ước lượng:** 8 Story Points | **Ưu tiên:** P0 (Critical) | **Sprint:** Sprint 3
- **Người phụ trách:** `@Quyens` | **Phản biện / Reviewer:** `@Thai1123`
- **Minh chứng kỹ thuật:**
  - File mã nguồn: `NutriLens/Features/BarcodeScanner/BarcodeScannerView.swift`
  - Unit Test: `NutriLensTests/UnitTests/BarcodeScannerTests.swift` (14/14 Unit Tests PASS)
  - Thử nghiệm thực tế: Kịch bản `UAT-10` (Nguyễn Thanh Thuận ký nhận ĐẠT)

