# THIẾT KẾ HỆ THỐNG GITHUB PROJECTS & PRODUCT BACKLOG
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/04_github_projects_backlog.md`  
**Ngày lập:** 13 tháng 11 năm 2026  
**Nguyên tắc vận hành:** Agile / Scrum kết hợp Kanban Board trên GitHub Projects  
**Phân loại:** AGILE PROJECT GOVERNANCE SPECIFICATION  

---

## 1. Thiết kế Bảng Quản trị GitHub Projects (Kanban Board Architecture)

Bảng quản trị dự án được cấu hình với 5 cột trạng thái (Columns / Swimlanes) tiêu chuẩn để kiểm soát luồng công việc (Work In Progress - WIP):

```
┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│  1. BACKLOG  │──>│   2. READY   │──>│3. IN PROGRESS│──>│ 4. IN REVIEW │──>│   5. DONE    │
├──────────────┤   ├──────────────┤   ├──────────────┤   ├──────────────┤   ├──────────────┤
│ Các User     │   │ User Stories │   │ Tác vụ đang  │   │ Đang mở PR,  │   │ Test 100%    │
│ Stories chưa │   │ đã tinh chế  │   │ được code,   │   │ chạy CI test │   │ pass, review │
│ lên lịch     │   │ đạt DoR, sẵn │   │ giới hạn WIP │   │ tự động và   │   │ approved, đã │
│ Sprint       │   │ sàng Sprint  │   │ = 3 issues   │   │ code review  │   │ merge nhánh  │
└──────────────┘   └──────────────┘   └──────────────┘   └──────────────┘   └──────────────┘
```

### 1.1. Tiêu chuẩn Sẵn sàng (Definition of Ready - DoR)
Một User Story chỉ được chuyển từ cột **Backlog** sang cột **Ready** khi thỏa mãn:
1. Đã được viết theo cấu trúc chuẩn: *"Là một [người dùng], tôi muốn [hành động] để [lợi ích]"*.
2. Có Tiêu chuẩn chấp nhận (Acceptance Criteria) rõ ràng, kiểm thử được.
3. Đã được ước lượng độ phức tạp bằng Story Points (dãy Fibonacci: 1, 2, 3, 5, 8, 13).
4. Các phụ thuộc kỹ thuật (dependencies) đã được giải quyết hoặc xác định rõ.
5. Đã liên kết với mã gói công việc WBS tương ứng.

### 1.2. Tiêu chuẩn Hoàn thành (Definition of Done - DoD)
Một User Story chỉ được chuyển từ cột **In Review** sang cột **Done** khi thỏa mãn:
1. Mã nguồn tuân thủ tiêu chuẩn Swift và kiến trúc MVVM + Clean Architecture (`GEMINI.md`).
2. Không còn lỗi biên dịch (0 compiler errors, 0 serious warnings).
3. Đã viết Unit Tests bổ sung; toàn bộ test suite chạy thành công trên Xcode Simulator.
4. Giao diện đáp ứng Dynamic Type, Dark Mode và Design System Fresh Botanical.
5. Pull Request được ít nhất một thành viên khác xem xét (code review) và phê duyệt.
6. Tài liệu và báo cáo tiến độ được cập nhật tương ứng.

---

## 2. Danh mục Product Backlog & Bản thảo GitHub Issues Chuẩn hóa (Local Issue Drafts)

> [!NOTE]
> Các Issue dưới đây là **bản thảo User Story & Issue chuẩn hóa tại máy cục bộ (Local Drafts)**, phục vụ công tác quản trị và chuẩn bị sẵn sàng để nhóm sinh viên xuất bản lên GitHub Projects khi được thống nhất. Các commit được ghi nhận trung thực theo mã băm Git (commit hash) và nhánh cục bộ; không ngụy tạo mã Pull Request trên remote khi chưa thực hiện PR trên GitHub.

### Issue #01 — [Phase 00] On-Device AI Food Recognition Viewfinder
* **Mã WBS:** `1.3.1` | **Milestone:** `M2 — Baseline Phase 00` | **Độ ưu tiên:** `P0 - Critical`
* **Ước lượng Tái thiết lập:** `13 Story Points` | **Người thực hiện:** `thai1123 / quyen`
* **User Story:**
  > Là một người dùng quan tâm dinh dưỡng, tôi muốn đưa camera hướng vào món ăn Việt Nam để ứng dụng tự động nhận diện tên món và ước tính lượng calo tức thì mà không cần kết nối mạng.
* **Tiêu chuẩn chấp nhận (Acceptance Criteria):**
  - [x] Tích hợp mô hình `FoodClassifier.mlmodelc` (Float16, 30 lớp món ăn) vào Bundle.
  - [x] Camera hoạt động ở tốc độ 30fps sử dụng `AVFoundation`, trích xuất khung hình qua `Vision`.
  - [x] Hiển thị thẻ kết quả gồm: Tên món tiếng Việt, độ tin cậy (confidence %), lượng calo trung bình theo khẩu phần chuẩn.
  - [x] Thời gian suy luận AI trên chip Apple Silicon dưới 200ms (kiểm tra trên Simulator).
* **Phụ thuộc:** WBS `1.2.3` (Mô hình Core ML).
* **Trạng thái Kỹ thuật:** **HOÀN THÀNH (VERIFIED)** — Commit `8ec9c1d` (Nhánh `checkpoint/phase00-baseline`).

---

### Issue #02 — [Phase 01] User Authentication & Nutritional Profile Management
* **Mã WBS:** `1.3.2` | **Milestone:** `M3 — Core Features` | **Độ ưu tiên:** `P1 - High`
* **Ước lượng Tái thiết lập:** `8 Story Points` | **Người thực hiện:** `quyen`
* **User Story:**
  > Là một người dùng mới, tôi muốn đăng ký hồ sơ dinh dưỡng cá nhân (chiều cao, cân nặng, độ tuổi, mức độ vận động) và bảo vệ dữ liệu bằng Face ID để hệ thống tính toán chính xác nhu cầu năng lượng hàng ngày (TDEE).
* **Tiêu chuẩn chấp nhận (Acceptance Criteria):**
  - [x] Biểu mẫu đăng ký/đăng nhập hỗ trợ tài khoản cục bộ và tích hợp sinh trắc học Face ID / Touch ID qua `LocalAuthentication`.
  - [x] Lưu trữ mật khẩu và khóa bảo mật trong Apple Keychain; thông tin hồ sơ lưu trong SwiftData.
  - [x] Thuật toán tính toán chỉ số BMR và TDEE theo công thức Mifflin-St Jeor chuẩn y khoa.
  - [x] Giao diện màn hình Hồ sơ cá nhân (Profile) và Quản lý tài khoản (AccountManagement) theo phong cách Fresh Botanical.
* **Phụ thuộc:** WBS `1.3.1`.
* **Trạng thái Kỹ thuật:** **HOÀN THÀNH (VERIFIED)** — Commit `657c4ab`, Merge commit nhánh cục bộ `30c2758` vào `main`.

---

### Issue #03 — [Phase 02] Advanced Multi-Item Meal Logging & Hydration Tracking
* **Mã WBS:** `1.3.3` | **Milestone:** `M3 — Core Features` | **Độ ưu tiên:** `P1 - High`
* **Ước lượng Tái thiết lập:** `8 Story Points` | **Người thực hiện:** `quyen / Nguyễn Thanh Thuận`
* **User Story:**
  > Là một người dùng ăn một bữa gồm nhiều món, tôi muốn thêm nhiều món ăn vào một khay ghi nhận (staged tray), tùy chỉnh số gram từng món và ghi nhận lượng nước uống để nhật ký phản ánh chính xác bữa ăn thực tế.
* **Tiêu chuẩn chấp nhận (Acceptance Criteria):**
  - [x] Thay thế form đơn lẻ bằng khay ghi nhận đa món (Multi-Item Cart System).
  - [x] Tích hợp thanh tìm kiếm trực tiếp vào cơ sở dữ liệu 35+ món Việt Nam (`VietnameseNutritionDatabase.swift`).
  - [x] Bộ trượt/nhập liệu tùy chỉnh khối lượng gram khẩu phần với tính toán calo, đạm, carb, chất béo theo thời gian thực.
  - [x] Lưu trữ và truy vấn lịch sử uống nước (Hydration Tracking) bằng SwiftData.
* **Phụ thuộc:** WBS `1.3.1`, `1.2.4`.
* **Trạng thái Kỹ thuật:** **HOÀN THÀNH (VERIFIED)** — Commit `0fc25ef`, Merge commit nhánh cục bộ `7fb01c3` vào `main`.

---

### Issue #04 — [Phase 03] Custom Foods & Personal Recipe Management System
* **Mã WBS:** `1.3.4` | **Milestone:** `M3 — Core Features` | **Độ ưu tiên:** `P1 - High`
* **Ước lượng Tái thiết lập:** `8 Story Points` | **Người thực hiện:** `quyen`
* **User Story:**
  > Là một người thường tự nấu ăn tại nhà, tôi muốn tạo món ăn riêng hoặc kết hợp nhiều nguyên liệu thành một công thức nấu ăn cá nhân để tái sử dụng nhanh khi ghi nhật ký.
* **Tiêu chuẩn chấp nhận (Acceptance Criteria):**
  - [x] Tạo thực thể `CustomFoodSDModel` và `RecipeSDModel` trong SwiftData với migration sạch.
  - [x] Giao diện Wizard tạo công thức nấu ăn: Đặt tên, thêm nguyên liệu từ cơ sở dữ liệu hoặc tự tạo, nhập số khẩu phần.
  - [x] Tự động tính toán tổng calo và dinh dưỡng trên từng khẩu phần ăn của công thức.
  - [x] Hiển thị món tự tạo và công thức ngay trong Khám phá món ăn (Food Explorer) và khay ghi nhận.
* **Phụ thuộc:** WBS `1.3.3`.
* **Trạng thái Kỹ thuật:** **HOÀN THÀNH (VERIFIED)** — Đã kiểm chứng độc lập bằng 13 Unit Tests (`CustomFoodsAndRecipesTests`).

---

### Issue #05 — [Phase 04] Weekly Meal Planner & Nutritional Budgeting
* **Mã WBS:** `1.3.5` | **Milestone:** `M3 — Core Features` | **Độ ưu tiên:** `P2 - Medium`
* **Ước lượng Tái thiết lập:** `8 Story Points` | **Người thực hiện:** `quyen`
* **User Story:**
  > Là một người có lối sống bận rộn, tôi muốn lên trước thực đơn cho 7 ngày trong tuần theo từng bữa sáng, trưa, tối, phụ và dễ dàng chuyển món đã lên lịch vào nhật ký sau khi ăn.
* **Tiêu chuẩn chấp nhận (Acceptance Criteria):**
  - [x] Giao diện dải lịch tuần 7 ngày (Weekly Calendar Strip) linh hoạt từ Thứ 2 đến Chủ nhật.
  - [x] Phân chia 4 khung bữa ăn (Sáng, Trưa, Tối, Phụ) cho phép gắn món ăn chuẩn, món cá nhân hoặc công thức.
  - [x] Thanh tiến độ so sánh tổng calo dự kiến của ngày với mục tiêu TDEE.
  - [x] Nút "Ghi vào nhật ký" chuyển nhanh món đã lên lịch sang Meal Diary với 1 chạm.
* **Phụ thuộc:** WBS `1.3.4`.
* **Trạng thái Kỹ thuật:** **HOÀN THÀNH (VERIFIED)** — Đã kiểm chứng độc lập bằng 17 Unit Tests (`WeeklyMealPlannerTests`) và 1 UI Test (`testWeeklyMealPlannerFlow`).

---

### Issue #06 — [Phase 05] Smart Meal Suggestions Engine (Macro-Deficit Based)
* **Mã WBS:** `1.3.6` | **Milestone:** `M4 — Advanced Features` | **Độ ưu tiên:** `P2 - Medium`
* **Ước lượng Tái thiết lập:** `8 Story Points` | **Người thực hiện:** `quyen / thai1123`
* **User Story:**
  > Là một người theo đuổi chế độ ăn tăng cơ/giảm mỡ, tôi muốn hệ thống gợi ý các món ăn phù hợp với lượng calo và chất đạm còn thiếu trong ngày, đồng thời tự động loại trừ các món tôi bị dị ứng.
* **Tiêu chuẩn chấp nhận (Acceptance Criteria):**
  - [x] Thuật toán tính toán lượng thiếu hụt dinh dưỡng: `Remaining = Target - Consumed`.
  - [x] Bộ lọc loại trừ món ăn chứa thành phần dị ứng (hải sản, đậu phộng, trứng, gluten...) theo hồ sơ người dùng.
  - [x] Đánh giá và xếp hạng các món ăn trong cơ sở dữ liệu dựa trên độ tương thích với lượng thiếu hụt.
  - [x] Trình bày gợi ý kèm theo lời giải thích lý do cụ thể (Explainable AI Recommendations).
* **Phụ thuộc:** WBS `1.3.5`.
* **Trạng thái Kỹ thuật:** **HOÀN THÀNH (VERIFIED)** — Đã kiểm chứng độc lập bằng 16 Unit Tests (`SmartSuggestionsTests`) và 1 UI Test (`testSmartSuggestionsFlow`).

---

### Issue #07 — [Phase 06] Barcode Scanner & Packaged Food Management
* **Mã WBS:** `1.3.7` | **Milestone:** `M4 — Advanced Features` | **Độ ưu tiên:** `P1 - High`
* **Ước lượng Tái thiết lập:** `8 Story Points` | **Người thực hiện:** `quyen / Nguyễn Thanh Thuận`
* **User Story:**
  > Là một người tiêu dùng thực phẩm đóng hộp/gói, tôi muốn dùng camera quét mã vạch sản phẩm để xem ngay bảng thông tin dinh dưỡng và kiểm tra thành phần gây dị ứng.
* **Tiêu chuẩn chấp nhận (Acceptance Criteria):**
  - [x] Nhận diện camera thời gian thực các chuẩn mã vạch EAN-13, EAN-8, UPC-A qua `AVFoundation`.
  - [x] Kiểm tra tính hợp lệ của mã số bằng thuật toán toán học GS1 Modulo-10 Checksum.
  - [x] Tích hợp danh mục 7 sản phẩm bán lẻ phổ biến tại Việt Nam (Vinamilk, Hảo Hảo, TH True Milk...).
  - [x] Cảnh báo tức thì nếu sản phẩm chứa chất dị ứng của người dùng; cho phép ghi trực tiếp vào Nhật ký bữa ăn.
* **Phụ thuộc:** WBS `1.3.6`.
* **Trạng thái Kỹ thuật:** **HOÀN THÀNH (VERIFIED)** — Đã kiểm chứng độc lập bằng 19 Unit Tests (`BarcodeScannerTests`).

---

## 3. Bản thảo Mẫu Pull Request Chuẩn mực (Pull Request Template)

Được thiết kế để lưu tại `.github/PULL_REQUEST_TEMPLATE.md` khi triển khai hạ tầng:

```markdown
### 1. Liên kết Issue / Work Package
- Resolves Issue: #<Số_Issue>
- WBS Code: <Mã_WBS> (ví dụ: WBS 1.3.7)

### 2. Tóm tắt Thay đổi Kỹ thuật (Summary of Changes)
- [ ] Bổ sung tính năng mới (Feature)
- [ ] Sửa lỗi (Bug Fix)
- [ ] Tái cấu trúc mã nguồn (Refactoring)
- [ ] Bổ sung / Nâng cấp kiểm thử (Testing)
- [ ] Cập nhật tài liệu (Documentation)

*Mô tả chi tiết những gì đã được sửa đổi hoặc bổ sung:*
...

### 3. Bằng chứng Kiểm định Chất lượng (Testing & QA Evidence)
- [ ] Mã nguồn biên dịch thành công 0 errors, 0 warnings.
- [ ] Đã chạy Unit Tests liên quan: `<Tên_Test_Suite>` (Số test pass: .../...).
- [ ] Đã chạy UI Tests trên iPhone Simulator: ...
- [ ] Đính kèm ảnh chụp màn hình / video demo (nếu có thay đổi UI).

### 4. Bảng Kiểm Tra của Người Phê Duyệt (Reviewer Checklist)
- [ ] Tuân thủ kiến trúc MVVM + Clean Architecture (`GEMINI.md`).
- [ ] Domain không phụ thuộc vào SwiftUI hay SwiftData.
- [ ] Không có API key, secret, mật khẩu hardcode trong mã nguồn.
- [ ] Không có force unwrap (`!`) hoặc `try?` nuốt lỗi nguy hiểm.
- [ ] Đạt chuẩn thiết kế Fresh Premium Botanical & Dynamic Type.
```

