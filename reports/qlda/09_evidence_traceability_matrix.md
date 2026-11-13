# MA TRẬN TRUY XUẤT NGUỒN GỐC BẰNG CHỨNG (EVIDENCE TRACEABILITY MATRIX)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/09_evidence_traceability_matrix.md`  
**Ngày cập nhật hiệu chỉnh:** 13 tháng 11 năm 2026  
**Nguyên tắc liên kết:** Chuỗi giá trị 6 cấp độ (Course LO -> WBS -> GitHub Issue Draft -> Commit/File -> Test -> UAT)  
**Phân loại:** AUDIT & COMPLIANCE VERIFICATION MATRIX  

---

## 1. Mục Đích & Nguyên Tắc Truy Xuất Nguồn Gốc Bằng Chứng

Ma trận Truy xuất Nguồn gốc Bằng chứng (Traceability Matrix) là công cụ kiểm toán học thuật quan trọng nhất nhằm chứng minh tính xác thực, minh bạch và nhất quán của toàn bộ dự án NutriLens V1.0.

> [!IMPORTANT]
> **Quy chuẩn Liêm chính Học thuật Về Định danh Bằng chứng:**
> 1. **Không sử dụng số Issue giả:** Trên remote GitHub hiện chưa công bố danh mục Issues (`0 open issues`). Mọi tham chiếu đề mục công việc đều sử dụng mã dự thảo chính thức `DRAFT-ISSUE-xxx` (được định nghĩa tại `reports/qlda/github_audit/03_issue_backlog_ready_to_publish.md`).
> 2. **Phân định rõ 5 trạng thái bằng chứng:**
>    - `VERIFIED REMOTE`: Bằng chứng đã tồn tại và đối soát được trên máy chủ GitHub.
>    - `VERIFIED LOCAL`: Bằng chứng kỹ thuật đã chạy thực tế trên máy local (Mã nguồn, 149 Tests, UAT người dùng thật).
>    - `RECONSTRUCTED ESTIMATE`: Ước lượng học thuật hồi cố (Story Points, CPM Schedule).
>    - `PENDING APPROVAL`: Đang chờ phê duyệt từ Giảng viên hướng dẫn (Hiến chương, Change Request, Nghiệm thu tổng thể).
>    - `MISSING REMOTE`: Chưa xuất bản lên máy chủ GitHub.

---

## 2. Bảng Ma Trận Truy Xuất Nguồn Gốc Chi Tiết (Detailed Traceability Table)

| Chuẩn Đầu ra Môn học (CLO) | Mã Gói WBS | Mã GitHub Issue Dự thảo | Bằng chứng Mã nguồn / Commit Thực tế | Bằng chứng Kiểm thử Tự động (Automated Test) | Bằng chứng Nghiệm thu (UAT / Visual Evidence) | Phân loại Trạng thái Bằng chứng (Evidence Status) |
| :--- | :---: | :---: | :--- | :--- | :--- | :---: |
| **CLO 1: Khởi tạo & Lập Hiến chương** | WBS 1.1.1 | `DRAFT-ISSUE-001` | Commit: `3b4ad92` (02/11/2026)<br>File: `reports/qlda/02_project_charter_draft.md` | Kiểm toán cấu trúc 13 mục chuẩn PMBOK đạt yêu cầu. | Bản thảo Hiến chương dự án hoàn chỉnh. | **PENDING APPROVAL**<br>*(Chờ chữ ký Thầy Tuấn)* |
| **CLO 2: Phân rã Phạm vi (WBS & CPM)** | WBS 1.1.2 | `DRAFT-ISSUE-001` | Files: `reports/qlda/03_wbs_dictionary.md`<br>`reports/qlda/05_15_week_schedule_and_cpm.md` | Đối soát 100% Rule, phân cấp 4 tầng WBS không chồng chéo. | Bảng CPM 15 tuần đường găng chuẩn xác 15.0w. | **RECONSTRUCTED ESTIMATE**<br>*(Ước lượng học thuật)* |
| **CLO 3: Design System & CSDL Món Việt** | WBS 1.2.1, 1.2.2 | `DRAFT-ISSUE-002`<br>`DRAFT-ISSUE-003` | Commits: `e970212`, `debf894`, `3e19d77`<br>Files: `AppColors.swift`, `FoodExplorerView.swift` | 36 Unit tests baseline pass tuyệt đối trên Xcode. | Khám phá 35+ món Việt chuẩn Viện Dinh Dưỡng. | **VERIFIED REMOTE** (Commits)<br>& **VERIFIED LOCAL** (Code/Tests) |
| **CLO 4: Tích hợp AI On-Device (Phase 00)** | WBS 1.3.1 | `DRAFT-ISSUE-004` | Commit: `3a973e6`, `8ec9c1d`<br>File: `FoodRecognitionView.swift` | `testFoodRecognitionFlow` pass 100% trên iOS Simulator. | Kính ngắm AI nhận diện Phở Bò <1s; UAT-01 Lê Hoàng Nam ký nhận. | **VERIFIED LOCAL**<br>*(UAT Đạt 100%)* |
| **CLO 5: Định danh & Hồ sơ (Phase 01)** | WBS 1.3.2 | `DRAFT-ISSUE-005` | Commits: `657c4ab`, `b27b89d`<br>Merge commit: `30c2758` (PR #1 remote) | `UserProfileTests`: 12/12 tests pass;<br>LocalAuthentication mock pass. | Hồ sơ người dùng, tính TDEE, sinh trắc học Face ID; UAT-06 Đạt. | **VERIFIED REMOTE** (PR #1)<br>& **VERIFIED LOCAL** (Tests/UAT) |
| **CLO 6: Ghi nhận Đa món (Phase 02)** | WBS 1.3.3, 1.3.4 | `DRAFT-ISSUE-006`<br>`DRAFT-ISSUE-007` | Commit: `0fc25ef`<br>Merge commit: `7fb01c3` (10/11/2026) | `MealTrackingTests`: 22/22 tests pass;<br>`testManualMealLoggingFlow` pass. | Khay ghi nhận đa món, thanh slider gram; UAT-02 & UAT-03 ký nhận. | **VERIFIED REMOTE** (Commits)<br>& **VERIFIED LOCAL** (Tests/UAT) |
| **CLO 7: Món Cá nhân & Công thức (Phase 03)** | WBS 1.3.5 | `DRAFT-ISSUE-008` | Files: `CustomFoodRepository.swift`<br>`RecipeRepository.swift` | `CustomFoodsAndRecipesTests`: 13/13 tests pass tuyệt đối. | Thư viện món ăn riêng, tính calo công thức; UAT-07 Đạt. | **VERIFIED LOCAL**<br>*(Chờ tạo PR remote)* |
| **CLO 8: Kế hoạch Tuần 7 Ngày (Phase 04)** | WBS 1.3.6 | `DRAFT-ISSUE-009` | Files: `WeeklyMealPlannerView.swift`<br>`MealPlanRepository.swift` | `WeeklyMealPlannerTests`: 17/17 tests pass;<br>`testWeeklyMealPlannerFlow` pass. | Lên lịch ăn 7 ngày, nút Kế hoạch trên tab Diary; UAT-08 Đạt. | **VERIFIED LOCAL**<br>*(Chờ tạo PR remote)* |
| **CLO 9: Gợi ý Thông minh AI (Phase 05)** | WBS 1.3.7 | `DRAFT-ISSUE-010` | Files: `SmartMealSuggestionsUseCase.swift`<br>`SmartSuggestionsView.swift` | `SmartSuggestionsTests`: 16/16 tests pass;<br>`testSmartSuggestionsFlow` pass. | Gợi ý món bù đạm/calo thiếu, lọc dị ứng hải sản; UAT-09 Đạt. | **VERIFIED LOCAL**<br>*(Chờ tạo PR remote)* |
| **CLO 10: Quét Mã vạch Bao bì (Phase 06)** | WBS 1.3.8 | `DRAFT-ISSUE-011` | Files: `BarcodeScannerView.swift`<br>`PackagedFoodRepository.swift` | `BarcodeScannerTests`: 14/14 tests pass;<br>GS1 Modulo-10 checksum verified. | Quét mã vạch Vinamilk qua camera; UAT-10 Nguyễn Thanh Thuận ký nhận. | **VERIFIED LOCAL**<br>*(Chờ tạo PR remote)* |
| **CLO 11: Kiểm thử Tự động & Chất lượng** | WBS 1.4.1, 1.4.2 | `DRAFT-ISSUE-012`<br>`DRAFT-ISSUE-013` | Suites: `NutriLensTests` (139 tests)<br>`NutriLensUITests` (10 flows) | 149/149 Automated Tests pass (100%) trên iPhone 17 Simulator. | Báo cáo kiểm thử tự động, không có regression. | **VERIFIED LOCAL** |
| **CLO 12: Thử nghiệm Người dùng Thật (UAT)** | WBS 1.4.3 | `DRAFT-ISSUE-014` | File: `reports/qlda/08_stakeholder_uat_plan.md`<br>Date: 13/11/2026 | Đối soát 10 kịch bản UAT tương ứng 10 luồng kiểm thử giao diện. | 10/10 kịch bản UAT hoàn thành bởi 3 sinh viên VKU thật (Thuận, Nam, Phương). | **VERIFIED LOCAL** (Human UAT)<br>& **PENDING SIGN-OFF** (Giảng viên) |
| **CLO 13: Quản trị Rủi ro & Sự cố** | WBS 1.4.4 | `DRAFT-ISSUE-001` | Files: `reports/qlda/06_risk_register.md`<br>Thư mục sao lưu: `NutriLens_backup_*` | Đối soát phục hồi: Bộ test tăng trưởng từ 42 -> 87 -> 112 -> 129 -> 149 tests. | Sổ đăng ký rủi ro tiến hóa qua các Sprint. | **VERIFIED LOCAL** |
| **CLO 14: Kiểm soát Thay đổi (Scope Change)** | WBS 1.1.4 | `DRAFT-ISSUE-008`<br>`DRAFT-ISSUE-011` | Files: `reports/qlda/07_change_control_draft.md`<br>Mã phiếu: `CR-01`, `CR-02` | 149 tests tự động hồi quy chạy lại đạt 100%. | Phiếu Change Request chính quy (CR-01, CR-02). | **PENDING APPROVAL**<br>*(Chờ ký duyệt CCB)* |
| **CLO 15: Quy trình CI/CD & Đóng gói v1.0.0** | WBS 1.5.1, 1.5.2 | `DRAFT-ISSUE-015`<br>`DRAFT-ISSUE-016` | Files: `.github/workflows/ios-ci.yml`<br>`CONTRIBUTING.md`, `QLDA_EVIDENCE_PACKAGE/` | Cú pháp workflow YAML đã kiểm tra hợp lệ; 8 tệp PDF số hóa hoàn tất. | Sẵn sàng xuất bản Release Notes v1.0.0 và slide bảo vệ. | **DRAFT LOCAL**<br>& **MISSING REMOTE** |

---

## 3. Tổng Kết Mức Độ Tuân Thủ & Minh Bạch Học Thuật (Compliance Summary)

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TỔNG KẾT ĐỐI SOÁT 15 CHUẨN ĐẦU RA MÔN HỌC                │
├────────────────────────────────────────┬─────────────┬──────────────────────┤
│ PHÂN LOẠI TRẠNG THÁI BẰNG CHỨNG        │ SỐ LƯỢNG    │ TỶ LỆ PHẦN TRĂM      │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ ĐÃ XÁC THỰC BẰNG CHỨNG KỸ THUẬT & CODE │ 10 / 15     │ 66.7%                │
│ (VERIFIED REMOTE & VERIFIED LOCAL)     │             │                      │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ ƯỚC LƯỢNG HỒI CỐ HỌC THUẬT             │ 1 / 15      │ 6.7%                 │
│ (RECONSTRUCTED PLANNING ESTIMATE)      │             │                      │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ CHỜ PHÊ DUYỆT TỪ GIẢNG VIÊN / CCB      │ 3 / 15      │ 20.0%                │
│ (PENDING APPROVAL / SIGN-OFF)          │             │                      │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ DỰ THẢO SẴN SÀNG CHỜ LỆNH ĐẨY REMOTE   │ 1 / 15      │ 6.7%                 │
│ (DRAFT LOCAL / MISSING REMOTE)         │             │                      │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ NGỤY TẠO BẰNG CHỨNG (FABRICATED)       │ 0 / 15      │ 0.0% (TUYỆT ĐỐI)     │
└────────────────────────────────────────┴─────────────┴──────────────────────┘
```

> [!NOTE]
> **Cam kết của Nhóm sinh viên:**
> 1. Không ghi nhận một hạng mục đang chờ (Pending) là đã hoàn tất (Done).
> 2. Không tạo issue/commit lùi ngày giả mạo.
> 3. Toàn bộ 10/10 kịch bản UAT đều là kết quả trải nghiệm thật của 3 sinh viên VKU ngày 13/11/2026.
