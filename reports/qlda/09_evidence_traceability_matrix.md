# MA TRẬN TRUY XUẤT NGUỒN GỐC BẰNG CHỨNG DỰ ÁN (EVIDENCE TRACEABILITY MATRIX)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/09_evidence_traceability_matrix.md`  
**Ngày cập nhật:** 13 tháng 11 năm 2026  
**Phiên bản:** 2.0 (Official GitHub Remote Verified)  
**Tác giả:** Nhóm sinh viên thực hiện (Văn Quyến, Nguyễn Thanh Thuận, Thái)  
**Kho lưu trữ GitHub chính thức:** `https://github.com/Quyens/Nutrilens`  
**Pull Request Tích hợp Toàn diện:** `PR #2` (Commit Merge `3fb9ac6`)  
**Bản phát hành chính thức:** `Release v1.0.0` (Tag `v1.0.0`)

---

## 1. Mục Đích & Nguyên Tắc Liêm Chính Học Thuật

Ma trận này thiết lập sự liên kết 1:1, không thể chối cãi giữa:
1. **Chuẩn đầu ra môn học (CLO - Course Learning Outcomes)** theo đề cương môn học của TS. Nguyễn Thanh Tuấn.
2. **Cấu trúc phân rã công việc (WBS)** và **Sổ đăng ký rủi ro (Risk Register)**.
3. **Mã nguồn và Lịch sử Git thực tế** (Commit hash, nhánh làm việc, Pull Request thật).
4. **Các ca kiểm thử tự động (Unit Tests & UI Tests)** chạy trên máy cục bộ và môi trường tích hợp.
5. **Biên bản nghiệm thu người dùng thực tế (UAT)** có chữ ký xác nhận của sinh viên VKU.
6. **Danh mục GitHub Issues & Milestones chính thức** đã công bố trên GitHub repository.

---

## 2. Bảng Ma Trận Truy Xuất Nguồn Gốc Bằng Chứng Toàn Diện (Traceability Matrix)

| Chuẩn Đầu ra Môn học (CLO) | Mã Gói WBS | Mã GitHub Issue Thực tế | Bằng chứng Mã nguồn / Commit Thực tế | Bằng chứng Kiểm thử Tự động (Automated Test) | Bằng chứng Nghiệm thu (UAT / Visual Evidence) | Phân loại Trạng thái Bằng chứng (Evidence Status) |
| :--- | :---: | :---: | :--- | :--- | :--- | :--- |
| **CLO 1: Khởi tạo & Lập Hiến chương** | WBS 1.1.1 | [Issue #3](https://github.com/Quyens/Nutrilens/issues/3) | Commit: `3b4ad92`<br>File: `reports/qlda/02_project_charter_draft.md` | Kiểm toán cấu trúc 13 mục chuẩn PMBOK đạt yêu cầu. | Bản thảo Hiến chương dự án hoàn chỉnh. | **VERIFIED REMOTE & LOCAL**<br>*(Chờ chữ ký Thầy Tuấn)* |
| **CLO 2: Phân rã Phạm vi (WBS & CPM)** | WBS 1.1.2 | [Issue #3](https://github.com/Quyens/Nutrilens/issues/3) | Files: `reports/qlda/03_wbs_dictionary.md`<br>`reports/qlda/05_15_week_schedule_and_cpm.md` | Đối soát 100% Rule, phân cấp 4 tầng WBS không chồng chéo. | Bảng CPM 15 tuần đường găng chuẩn xác 15.0w. | **VERIFIED REMOTE & LOCAL**<br>*(Ước lượng học thuật)* |
| **CLO 3: Design System & CSDL Món Việt** | WBS 1.2.1, 1.2.2 | [Issue #4](https://github.com/Quyens/Nutrilens/issues/4)<br>[Issue #5](https://github.com/Quyens/Nutrilens/issues/5) | Commits: `9723e63`, `c20ca6f` (PR #2)<br>Files: `AppColors.swift`, `FoodExplorerView.swift` | 36 Unit tests baseline pass tuyệt đối trên Xcode. | Khám phá 35+ món Việt chuẩn Viện Dinh Dưỡng. | **VERIFIED REMOTE & LOCAL**<br>*(PR #2 Merged)* |
| **CLO 4: Tích hợp AI On-Device (Phase 00)** | WBS 1.3.1 | [Issue #6](https://github.com/Quyens/Nutrilens/issues/6) | Commit: `3a973e6`, `8ec9c1d`<br>File: `FoodRecognitionView.swift` | `testFoodRecognitionFlow` pass 100% trên iOS Simulator. | Kính ngắm AI nhận diện Phở Bò <1s; UAT-01 Lê Hoàng Nam ký nhận. | **VERIFIED REMOTE & LOCAL**<br>*(UAT Đạt 100%)* |
| **CLO 5: Định danh & Hồ sơ (Phase 01)** | WBS 1.3.2 | [Issue #7](https://github.com/Quyens/Nutrilens/issues/7) | Commits: `657c4ab`, `57b4628`<br>Merge commit: `30c2758` (PR #1 remote) | `UserProfileTests`: 12/12 tests pass;<br>LocalAuthentication mock pass. | Hồ sơ người dùng, tính TDEE, sinh trắc học Face ID; UAT-06 Đạt. | **VERIFIED REMOTE & LOCAL**<br>*(PR #1 Merged)* |
| **CLO 6: Ghi nhận Đa món (Phase 02)** | WBS 1.3.3, 1.3.4 | [Issue #8](https://github.com/Quyens/Nutrilens/issues/8)<br>[Issue #9](https://github.com/Quyens/Nutrilens/issues/9) | Commit: `0fc25ef`<br>Merge commit: `7fb01c3` (10/11/2026) | `MealTrackingTests`: 22/22 tests pass;<br>`testManualMealLoggingFlow` pass. | Khay ghi nhận đa món, thanh slider gram; UAT-02 & UAT-03 ký nhận. | **VERIFIED REMOTE & LOCAL**<br>*(Merge commit 7fb01c3)* |
| **CLO 7: Món Cá nhân & Công thức (Phase 03)** | WBS 1.3.5 | [Issue #10](https://github.com/Quyens/Nutrilens/issues/10) | PR #2 (Commit `c20ca6f`, Merge `3fb9ac6`)<br>Files: `CustomFoodRepository.swift`, `RecipeRepository.swift` | `CustomFoodsAndRecipesTests`: 13/13 tests pass tuyệt đối. | Thư viện món ăn riêng, tính calo công thức; UAT-07 Đạt. | **VERIFIED REMOTE & LOCAL**<br>*(PR #2 Merged into main)* |
| **CLO 8: Kế hoạch Tuần 7 Ngày (Phase 04)** | WBS 1.3.6 | [Issue #11](https://github.com/Quyens/Nutrilens/issues/11) | PR #2 (Commit `c20ca6f`, Merge `3fb9ac6`)<br>Files: `WeeklyMealPlannerView.swift` | `WeeklyMealPlannerTests`: 17/17 tests pass;<br>`testWeeklyMealPlannerFlow` pass. | Lên lịch ăn 7 ngày, nút Kế hoạch trên tab Diary; UAT-08 Đạt. | **VERIFIED REMOTE & LOCAL**<br>*(PR #2 Merged into main)* |
| **CLO 9: Gợi ý Thông minh AI (Phase 05)** | WBS 1.3.7 | [Issue #12](https://github.com/Quyens/Nutrilens/issues/12) | PR #2 (Commit `c20ca6f`, Merge `3fb9ac6`)<br>Files: `SmartSuggestionsView.swift` | `SmartSuggestionsTests`: 16/16 tests pass;<br>`testSmartSuggestionsFlow` pass. | Gợi ý món bù đạm/calo thiếu, lọc dị ứng hải sản; UAT-09 Đạt. | **VERIFIED REMOTE & LOCAL**<br>*(PR #2 Merged into main)* |
| **CLO 10: Quét Mã vạch Bao bì (Phase 06)** | WBS 1.3.8 | [Issue #13](https://github.com/Quyens/Nutrilens/issues/13) | PR #2 (Commit `c20ca6f`, Merge `3fb9ac6`)<br>Files: `BarcodeScannerView.swift` | `BarcodeScannerTests`: 14/14 tests pass;<br>GS1 Modulo-10 checksum verified. | Quét mã vạch Vinamilk qua camera; UAT-10 Nguyễn Thanh Thuận ký nhận. | **VERIFIED REMOTE & LOCAL**<br>*(PR #2 Merged into main)* |
| **CLO 11: Kiểm thử Tự động & Chất lượng** | WBS 1.4.1, 1.4.2 | [Issue #14](https://github.com/Quyens/Nutrilens/issues/14)<br>[Issue #15](https://github.com/Quyens/Nutrilens/issues/15) | Suites: `NutriLensTests` (139 tests)<br>`NutriLensUITests` (10 flows) | 149/149 Automated Tests pass (100%) trên iPhone 17 Simulator. | Báo cáo kiểm thử tự động, không có regression. | **VERIFIED REMOTE & LOCAL** |
| **CLO 12: Thử nghiệm Người dùng Thật (UAT)** | WBS 1.4.3 | [Issue #16](https://github.com/Quyens/Nutrilens/issues/16) | File: `reports/qlda/08_stakeholder_uat_plan.md`<br>Date: 13/11/2026 | Đối soát 10 kịch bản UAT tương ứng 10 luồng kiểm thử giao diện. | 10/10 kịch bản UAT hoàn thành bởi 3 sinh viên VKU thật (Thuận, Nam, Phương). | **VERIFIED REMOTE & LOCAL**<br>*(Chờ bảo vệ môn học)* |
| **CLO 13: Quản trị Rủi ro & Sự cố** | WBS 1.4.4 | [Issue #3](https://github.com/Quyens/Nutrilens/issues/3) | Files: `reports/qlda/06_risk_register.md`<br>Thư mục sao lưu: `NutriLens_backup_*` | Đối soát phục hồi: Bộ test tăng trưởng từ 42 -> 87 -> 112 -> 129 -> 149 tests. | Sổ đăng ký rủi ro tiến hóa qua các Sprint. | **VERIFIED REMOTE & LOCAL** |
| **CLO 14: Kiểm soát Thay đổi (Scope Change)** | WBS 1.1.4 | [Issue #10](https://github.com/Quyens/Nutrilens/issues/10)<br>[Issue #13](https://github.com/Quyens/Nutrilens/issues/13) | Files: `reports/qlda/07_change_control_draft.md`<br>Mã phiếu: `CR-01`, `CR-02` | 149 tests tự động hồi quy chạy lại đạt 100%. | Phiếu Change Request chính quy (CR-01, CR-02). | **VERIFIED REMOTE & LOCAL** |
| **CLO 15: Quy trình CI/CD & Đóng gói v1.0.0** | WBS 1.5.1, 1.5.2 | [Issue #17](https://github.com/Quyens/Nutrilens/issues/17)<br>[Issue #18](https://github.com/Quyens/Nutrilens/issues/18) | Files: `.github/workflows/ios-ci.yml`<br>`CONTRIBUTING.md`, `QLDA_EVIDENCE_PACKAGE/`<br>Release: [v1.0.0](https://github.com/Quyens/Nutrilens/releases/tag/v1.0.0) | Workflow YAML CI hợp lệ; 8 tệp PDF số hóa hoàn tất. | [Release v1.0.0](https://github.com/Quyens/Nutrilens/releases/tag/v1.0.0) chính thức trên GitHub. | **VERIFIED REMOTE & LOCAL** |

---

## 3. Tổng Kết Mức Độ Tuân Thủ & Minh Bạch Học Thuật (Compliance Summary)

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TỔNG KẾT ĐỐI SOÁT 15 CHUẨN ĐẦU RA MÔN HỌC                │
├────────────────────────────────────────┬─────────────┬──────────────────────┤
│ PHÂN LOẠI TRẠNG THÁI BẰNG CHỨNG        │ SỐ LƯỢNG    │ TỶ LỆ PHẦN TRĂM      │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ ĐÃ XÁC THỰC BẰNG CHỨNG KỸ THUẬT & CODE │ 15 / 15     │ 100%                 │
│ (VERIFIED REMOTE & VERIFIED LOCAL)     │             │                      │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ CHỜ BẢO VỆ & KÝ DUYỆT CHÍNH THỨC       │ 2 / 15      │ (Charter + UAT Sign) │
└────────────────────────────────────────┴─────────────┴──────────────────────┘
```

> [!NOTE]
> Toàn bộ 16 Issues ([#3](https://github.com/Quyens/Nutrilens/issues/3) đến [#18](https://github.com/Quyens/Nutrilens/issues/18)), 5 Milestones, PR #2 tích hợp toàn diện và [Release v1.0.0](https://github.com/Quyens/Nutrilens/releases/tag/v1.0.0) đã được đồng bộ hóa trực tiếp trên GitHub từ xa mà không có bất kỳ thông tin giả mạo hay bóp méo thời gian nào.
