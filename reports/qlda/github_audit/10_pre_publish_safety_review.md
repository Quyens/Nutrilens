# BÁO CÁO KIỂM TRA AN TOÀN TRƯỚC XUẤT BẢN GITHUB (PRE-FLIGHT SAFETY REVIEW)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/github_audit/10_pre_publish_safety_review.md`  
**Ngày thực hiện kiểm tra:** 13 tháng 11 năm 2026  
**Chuyên viên thực hiện:** Senior GitHub DevOps Engineer & Software Project Auditor  
**Kho lưu trữ đối soát:** `https://github.com/Quyens/Nutrilens` (Public)  
**Thư mục làm việc cục bộ:** `/Users/vanquyen/Documents/NutrilensIOS`  
**Trạng thái quyết định:** `STOPPED — PENDING USER AUTHORIZATION` (Không thực hiện bất kỳ thao tác ghi nào lên remote)

---

## 1. Kiểm Toán Hiện Trạng Git & Độ Lệch Nhánh (Git State & Divergence Verification)

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                   ĐỐI SOÁT ĐỘ LỆCH GIỮA LOCAL VÀ REMOTE GITHUB             │
├──────────────────────────┬─────────────────────────┬────────────────────────┤
│ THUỘC TÍNH               │ LOCAL WORKSPACE         │ REMOTE GITHUB (ORIGIN) │
├──────────────────────────┼─────────────────────────┼────────────────────────┤
│ Tên nhánh hiện tại       │ `main`                  │ `main`                 │
├──────────────────────────┼─────────────────────────┼────────────────────────┤
│ Commit HEAD              │ `7fb01c36161730169...`  │ `9723e6337c768997f...` │
│                          │ (Merge Phase 02)        │ (feat: design system)  │
├──────────────────────────┼─────────────────────────┼────────────────────────┤
│ Tác giả commit HEAD      │ `quyen` (10/11/2026)    │ `thai1123` (13/11/2026)│
├──────────────────────────┼─────────────────────────┼────────────────────────┤
│ Tình trạng đồng bộ       │ BEHIND 3 COMMITS        │ AHEAD 3 COMMITS        │
├──────────────────────────┼─────────────────────────┼────────────────────────┤
│ Thay đổi chưa commit     │ 27 files modified       │ 0 (Working tree sạch)  │
│                          │ 71 files untracked      │                        │
│                          │ (Phase 03-06 + QLDA)    │                        │
├──────────────────────────┼─────────────────────────┼────────────────────────┤
│ Bản sao lưu an toàn      │ Đã tạo & xác thực tại:  │ N/A                    │
│                          │ `/Users/vanquyen/       │                        │
│                          │ Documents/NutriLens_    │                        │
│                          │ backup_github_audit_    │                        │
│                          │ 20261113_123240`        │                        │
└──────────────────────────┴─────────────────────────┴────────────────────────┘
```

> [!WARNING]
> **CẢNH BÁO XUNG ĐỘT PHÁT HIỆN TỪ KIỂM TOÁN (CRITICAL DIVERGENCE):**
> 1. Trên remote GitHub, nhánh `main` đã nhận thêm **03 commit mới** từ các thành viên khác (`thai1123` và `Nguyễn Thanh Thuận`):
>    - `fc14067`: `feat: add settings module`
>    - `57b4628`: `feat(ios): add Profile folder with nutrition goals and profile features`
>    - `9723e63`: `feat: add design system module`
> 2. Các commit trên đã tạo thêm các thư mục độc lập ở thư mục gốc của repository (`DesignSystem/`, `Profile/`, `Settings/`).
> 3. Trong khi đó, mã nguồn chính của ứng dụng tại máy local đang nằm trong kiến trúc chuẩn hóa Clean Architecture tại thư mục `NutriLens/Core/DesignSystem/`, `NutriLens/Features/Profile/`, `NutriLens/Features/Settings/`.
> 4. **Hệ quả nếu chạy `git push origin main` trực tiếp:** Git sẽ **từ chối ngay lập tức** do lỗi `non-fast-forward rejection`. Nếu người dùng cố tình dùng cờ `--force`, sẽ **ghi đè và làm mất 3 commit đóng góp của bạn Thuận và bạn Thái** (vi phạm Cổng Xác thực Authenticity Gate).

---

## 2. Kiểm Toán Kịch Bản Xuất Bản `scripts/publish_github_management.sh`

Kiểm toán mã nguồn kịch bản xuất bản cho thấy các kết luận an toàn sau:

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                 KẾT QUẢ KIỂM TOÁN SCRIPT publish_github_management.sh       │
├─────────────────────────┬───────────┬───────────────────────────────────────┤
│ HẠNG MỤC KIỂM TRA       │ KẾT QUẢ   │ PHÂN TÍCH CHI TIẾT                    │
├─────────────────────────┼───────────┼───────────────────────────────────────┤
│ Yêu cầu xác nhận người  │ ĐẠT (PASS)│ Có lệnh `read -p` yêu cầu gõ 'yes'    │
│ dùng trước khi chạy     │           │ trước khi thực hiện.                  │
├─────────────────────────┼───────────┼───────────────────────────────────────┤
│ Thao tác Git bất thường │ CẢNH BÁO  │ Script tự động thực hiện `git push`   │
│ (Unexpected Git Ops)    │ NGUY HIỂM │ lên 3 nhánh remote ở dòng 30-32       │
│                         │           │ mà không kiểm tra độ lệch HEAD.       │
├─────────────────────────┼───────────┼───────────────────────────────────────┤
│ Phụ thuộc công cụ ngoài │ CHƯA SẴN  │ Script yêu cầu GitHub CLI (`gh`), tuy │
│ (CLI Requirements)      │ SÀNG      │ nhiên máy tính hiện chưa cài đặt `gh`.│
├─────────────────────────┼───────────┼───────────────────────────────────────┤
│ Chống trùng lặp Issue   │ THIẾU     │ Không có cơ chế kiểm tra Issue đã tồn │
│ (Duplicate Prevention)  │ (MISSING) │ tại hay chưa trước khi gọi lệnh tạo.  │
├─────────────────────────┼───────────┼───────────────────────────────────────┤
│ Chống trùng lặp Project │ THIẾU     │ Chưa hỗ trợ tạo GitHub Projects v2.   │
├─────────────────────────┼───────────┼───────────────────────────────────────┤
│ Hỗ trợ chạy thử         │ THIẾU     │ Không có cờ `--dry-run` để kiểm tra   │
│ (Dry-Run Support)       │ (MISSING) │ payload trước khi ghi lên API.        │
├─────────────────────────┼───────────┼───────────────────────────────────────┤
│ Xử lý lỗi (Error Handle)│ HẠN CHẾ   │ Sử dụng `|| true` che giấu lỗi thực tế│
├─────────────────────────┼───────────┼───────────────────────────────────────┤
│ Phạm vi Issue xuất bản  │ THIẾU     │ Chỉ tạo thử 01 Issue thay vì 16 Issues│
│                         │           │ theo chuẩn môn học VKU.               │
└─────────────────────────┴───────────┴───────────────────────────────────────┘
```

> [!CAUTION]
> **PHÁN QUYẾT AN TOÀN VỀ SCRIPT (SAFETY VERDICT):**
> - **KẾT LUẬN:** **UNSAFE FOR DIRECT EXECUTION (KHÔNG AN TOÀN ĐỂ CHẠY TRỰC TIẾP)**.
> - **Lý do:** Script cố gắng đẩy nhánh Git tự động và thiếu công cụ `gh`.
> - **Chỉ đạo:** Tuyệt đối không chạy file này tại thời điểm hiện tại. Toàn bộ quy trình sẽ được phân đoạn thành các bước có kiểm soát chặt chẽ dưới đây.

---

## 3. Bản Kế Hoạch Xuất Bản An Toàn Phân Đoạn (Phased Publishing Plan)

Kế hoạch xuất bản được chia thành 5 giai đoạn, tuân thủ nguyên tắc: **Không viết đè lịch sử, không đẩy thẳng vào main, và mọi tính năng đều qua Pull Request**:

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                        LỘ TRÌNH 5 GIAI ĐOẠN XUẤT BẢN AN TOÀN                │
├─────────────────────────────────────────────────────────────────────────────┤
│ GIAI ĐOẠN 1: Chuẩn bị Cục bộ & Khởi tạo Bảng Dự án trên Web (An toàn 100%)  │
│    - Tạo GitHub Projects Board v2 trên giao diện Web: "NutriLens V1.0"      │
│    - Cấu hình 5 cột (Backlog -> Ready -> In Progress -> In Review -> Done)  │
│    - Cấu hình 8 trường Custom Fields (Status, Priority, Sprint, SP, WBS...) │
├─────────────────────────────────────────────────────────────────────────────┤
│ GIAI ĐOẠN 2: Xuất bản Danh mục 16 Issues có Kiểm soát Trùng lặp             │
│    - Nạp 16 Issues từ '03_issue_backlog_ready_to_publish.md'                │
│    - Gắn thẻ '[Retrospective - Verified in Code]' cho các mốc đã hoàn thành│
│    - Phân bổ chính xác Milestone và Sprint Backlog                          │
├─────────────────────────────────────────────────────────────────────────────┤
│ GIAI ĐOẠN 3: Tách Nhánh Tính Năng (Feature Branching) Cho Phase 03 - 06     │
│    - Tách riêng 4 nhánh tính năng tương ứng 4 Pull Request độc lập          │
│    - Đồng bộ hóa 3 commit của bạn Thuận & Thái trên remote vào nhánh chính  │
├─────────────────────────────────────────────────────────────────────────────┤
│ GIAI ĐOẠN 4: Thiết lập Bảo vệ Nhánh & Kích hoạt GitHub Actions CI/CD        │
│    - Kích hoạt Branch Protection Ruleset cho main (Require 1 Approval)      │
│    - Đẩy pipeline `.github/workflows/ios-ci.yml` lên nhánh chính            │
│    - Chạy kiểm thử tự động 149 test trên hạ tầng macos-14 sạch              │
├─────────────────────────────────────────────────────────────────────────────┤
│ GIAI ĐOẠN 5: Đóng Gói Release v1.0.0 & Slide Báo Cáo Bảo Vệ Môn Học         │
│    - Gắn tag Git chính thức: `v1.0.0`                                       │
│    - Xuất bản Release Notes mô tả 7 tính năng cốt lõi                       │
│    - Chuẩn bị máy chiếu và tệp PDF bảo vệ trước Hội đồng VKU                │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Xác Định Ranh Giới 5 Pull Request Độc Lập (Proposed PR Boundaries)

Nhằm đáp ứng yêu cầu thẩm định mã nguồn và kiểm duyệt ngang hàng (Peer Review), thay vì gom toàn bộ vào một commit khổng lồ trên `main`, mã nguồn cục bộ được phân định thành **05 Pull Request rõ ràng**:

### PR 1: Phase 03 — Custom Foods, Recipes & User Food Database
- **Nhánh nguồn:** `feature/phase03-custom-foods` | **Nhánh đích:** `main`
- **Mã WBS liên kết:** `WBS 1.3.5` | **Issue dự thảo:** `DRAFT-ISSUE-008`
- **Tập tin chính:** `CustomFoodRepository.swift`, `RecipeRepository.swift`, `CustomFoodsAndRecipesView.swift`.
- **Bằng chứng kiểm định:** 13 Unit Tests trong `CustomFoodsAndRecipesTests` pass 100%.
- **Người thẩm định chỉ định:** `@thuan5587` (Data Lead).

### PR 2: Phase 04 — Weekly Meal Planner (Kế hoạch Thực đơn Tuần)
- **Nhánh nguồn:** `feature/phase04-weekly-planner` | **Nhánh đích:** `main`
- **Mã WBS liên kết:** `WBS 1.3.6` | **Issue dự thảo:** `DRAFT-ISSUE-009`
- **Tập tin chính:** `WeeklyMealPlannerView.swift`, `MealPlanRepository.swift`, `MealHistoryView.swift` (Nút lối tắt).
- **Bằng chứng kiểm định:** 17 Unit Tests trong `WeeklyMealPlannerTests` pass 100%.
- **Người thẩm định chỉ định:** `@Thai1123` (UI/UX Designer).

### PR 3: Phase 05 — Smart Meal Suggestions (Gợi ý Món ăn Thông minh)
- **Nhánh nguồn:** `feature/phase05-smart-suggestions` | **Nhánh đích:** `main`
- **Mã WBS liên kết:** `WBS 1.3.7` | **Issue dự thảo:** `DRAFT-ISSUE-010`
- **Tập tin chính:** `SmartMealSuggestionsUseCase.swift`, `SmartSuggestionsView.swift`, `FoodExplorerView.swift`.
- **Bằng chứng kiểm định:** 16 Unit Tests trong `SmartSuggestionsTests` pass 100%.
- **Người thẩm định chỉ định:** `@thuan5587` (QA Lead).

### PR 4: Phase 06 — Barcode Scanner & Packaged Foods (Quét Mã vạch Bao bì)
- **Nhánh nguồn:** `feature/phase06-barcode-scanner` | **Nhánh đích:** `main`
- **Mã WBS liên kết:** `WBS 1.3.8` | **Issue dự thảo:** `DRAFT-ISSUE-011`
- **Tập tin chính:** `BarcodeScannerView.swift`, `PackagedFoodRepository.swift`, `BundledPackagedFoodCatalogue.swift`.
- **Bằng chứng kiểm định:** 14 Unit Tests trong `BarcodeScannerTests` pass 100% (Thuật toán Modulo-10).
- **Người thẩm định chỉ định:** `@Thai1123` (Mobile Engineer).

### PR 5: DevOps, CI/CD Pipeline & QLDA Course Evidence Package
- **Nhánh nguồn:** `feature/project-management-cicd` | **Nhánh đích:** `main`
- **Mã WBS liên kết:** `WBS 1.1.1`, `WBS 1.5.1`, `WBS 1.5.2` | **Issues:** `DRAFT-ISSUE-001`, `015`, `016`
- **Tập tin chính:** `.github/workflows/ios-ci.yml`, `.github/PULL_REQUEST_TEMPLATE.md`, `CONTRIBUTING.md`, `reports/qlda/`.
- **Bằng chứng kiểm định:** Cú pháp YAML hợp lệ, cấu trúc 8 tệp PDF số hóa hoàn tất.
- **Người thẩm định chỉ định:** `@Quyens` (Project Lead).

---

## 5. Xác Minh Bằng Chứng Thử Nghiệm Người Dùng (UAT Evidence Verification)

Kiểm toán hồ sơ tại `reports/qlda/08_stakeholder_uat_plan.md` xác nhận:
1. **Dữ liệu kiểm thử người thật (Human Testing):**
   - Đã tổ chức kiểm thử thực tế vào ngày **13/11/2026**.
   - Có đầy đủ họ tên, lớp và email của **03 sinh viên VKU**:
     - *Nguyễn Thanh Thuận* (`thuannt.23itb@vku.udn.vn` - Lớp 23ITB)
     - *Lê Hoàng Nam* (Lớp 23ITB)
     - *Trần Thị Mai Phương* (Lớp 23ITB)
2. **Đánh giá 10 Kịch bản:** Đạt **10/10 PASS**, mỗi kịch bản đều có trích dẫn trực tiếp lời nhận xét của người thử nghiệm về giao diện, tốc độ và độ mượt mà.
3. **Biên bản Nghiệm thu Giảng viên:** Tiếp tục được giữ nguyên ở trạng thái minh bạch:  
   `[PENDING SIGN-OFF TẠI BUỔI BẢO VỆ]` — Tuyệt đối không tạo chữ ký giả hoặc tuyên bố việc nghiệm thu của Thầy đã xong khi chưa bảo vệ.

---

## 6. Các Điểm Tuân Thủ Học Thuật Còn Lại Cần Lưu Ý (Remaining Compliance Items)

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DANH SÁCH 3 VIỆC CẦN SỰ THAM GIA CỦA CON NGƯỜI           │
├────┬─────────────────────────────┬──────────────────┬───────────────────────┤
│ STT│ HẠNG MỤC CẦN HÀNH ĐỘNG      │ NGƯỜI CHỊU TRÁCH │ THỜI ĐIỂM THỰC HIỆN   │
│    │                             │ NHIỆM CHÍNH      │                       │
├────┼─────────────────────────────┼──────────────────┼───────────────────────┤
│ 1  │ Ký phê duyệt Hiến chương    │ Trưởng nhóm &    │ Trình Thầy Tuấn ký    │
│    │ (Project Charter Draft)     │ TS. Nguyễn Thanh │ trước hoặc tại buổi   │
│    │                             │ Tuấn             │ bảo vệ chính thức.    │
├────┼─────────────────────────────┼──────────────────┼───────────────────────┤
│ 2  │ Phê duyệt 2 Phiếu Thay đổi  │ Trưởng nhóm &    │ Trình Ban CCB / Thầy  │
│    │ Phạm vi (CR-01 & CR-02)     │ Ban CCB          │ duyệt phương án phạm vi│
├────┼─────────────────────────────┼──────────────────┼───────────────────────┤
│ 3  │ Giải trình hình thức nộp bài│ Cả nhóm          │ Trình diễn thiết bị   │
│    │ ứng dụng iOS (Thay thế APK) │                  │ thật / iOS Simulator. │
└────┴─────────────────────────────┴──────────────────┴───────────────────────┘
```

---

## 7. Danh Mục Các Thao Tác Bắt Buộc Phải Chờ Lệnh Của Người Dùng (Operations Requiring Authorization)

Để tuân thủ tuyệt đối quy định an toàn của dự án, các thao tác sau đây **CHỈ ĐƯỢC PHÉP THỰC HIỆN KHI NGƯỜI DÙNG CHỦ ĐỘNG YÊU CẦU**:
- `git add`, `git commit`, `git push`, `git merge`, `git checkout`, `git rebase`.
- Tạo hoặc sửa đổi bất kỳ Issue hoặc Project Board nào trên `https://github.com/Quyens/Nutrilens`.
- Thiết lập Branch Protection Rules trong mục Settings của repository.
- Gắn thẻ tag Git hoặc công bố Release `v1.0.0`.
- Chạy bất kỳ file script nào có lệnh gọi mạng hoặc API ghi dữ liệu.

---

## 8. Kết Luận & Khuyến Nghị Về Bước Tiếp Theo

1. **Về mặt kỹ thuật:** Toàn bộ hệ thống mã nguồn, bộ test 149 ca, kết quả UAT người thật, hồ sơ 15 chuẩn đầu ra WBS và bộ tài liệu QLDA đã đạt mức **SẴN SÀNG 100% CỤC BỘ**.
2. **Về mặt GitHub:** Đã có đầy đủ bản thiết kế Projects Board, danh mục 16 Issues, mẫu PR, quy chuẩn Conventional Commits và kịch bản phân chia 5 PR độc lập.
3. **Khuyến nghị:** Khi bạn sẵn sàng xuất bản, hãy cho tôi biết: Bạn muốn tôi hướng dẫn bạn tự thực hiện từng lệnh an toàn trên máy, hay hỗ trợ bạn kiểm tra từng bước đẩy mã nguồn lên GitHub.

