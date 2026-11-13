# BÁO CÁO PHÂN TÍCH HIỆN TRẠNG & KHOẢNG TRỐNG TUÂN THỦ MÔN HỌC (ĐÃ HIỆU CHỈNH)
## Môn học: Quản trị Dự án Phần mềm — Trường ĐH CNTT & Truyền thông Việt - Hàn (VKU)
### Giảng viên hướng dẫn: TS. Nguyễn Thanh Tuấn
**Dự án đối soát:** NutriLens V1.0 — Ứng dụng iOS Nhận diện Món ăn Việt & Quản lý Dinh dưỡng  
**Đơn vị thực hiện:** Nhóm sinh viên ngành CNTT / Kỹ thuật Phần mềm — VKU  
**Mã tài liệu:** `reports/qlda/01_compliance_gap_analysis.md`  
**Ngày hiệu chỉnh:** 13 tháng 11 năm 2026  
**Phân loại:** AUDIT & EVIDENCE-BASED COMPLIANCE SPECIFICATION (VERIFIED & AUDITED)  

---

## 1. Bối cảnh & Phương thức Tiếp cận Đồ án (Pathway Alignment)

### 1.1. Lựa chọn Phương thức (Project Sourcing Pathway)
Căn cứ theo hướng dẫn môn học Quản trị Dự án Phần mềm tại VKU, dự án NutriLens được định vị theo **PATHWAY 1: Kế thừa & Phát triển Song song từ Đồ án Chuyên ngành (Inheriting / Parallel Development from a Specialized Course Project)**.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       NUTRILENS V1.0 — HAI GÓC NHÌN                        │
├──────────────────────────────────────────────┬──────────────────────────────┤
│ 1. GÓC NHÌN KỸ THUẬT & CHUYÊN NGÀNH (TECH)   │ 2. GÓC NHÌN QUẢN TRỊ (PM)    │
├──────────────────────────────────────────────┼──────────────────────────────┤
│ • Xây dựng ứng dụng native iOS (SwiftUI).    │ • Lập kế hoạch dự án 15 tuần.│
│ • Huấn luyện & đóng gói Core ML on-device.   │ • Cơ cấu tổ chức & RACI nhóm.│
│ • Thiết kế Clean Architecture + SwiftData.   │ • Quản lý phạm vi (WBS 100%).│
│ • Tái hiện độc lập 149 automated tests.      │ • Lập lịch CPM & đo Velocity.│
│ • Trải nghiệm người dùng Fresh Botanical.    │ • Quản trị rủi ro & Change.  │
│ • Tối ưu hiệu năng bộ nhớ & pin trên iPhone. │ • Kế hoạch UAT & Nghiệm thu. │
└──────────────────────────────────────────────┴──────────────────────────────┘
```

> [!IMPORTANT]
> **Tuyên bố Minh bạch Học thuật:** 
> 1. Dự án NutriLens vốn có mã nguồn sản phẩm thực tế đã được phát triển kỹ thuật. Báo cáo này đóng vai trò chuyển hóa toàn bộ quá trình phát triển đó thành **hệ thống hồ sơ quản trị dự án phần mềm chính quy**, đáp ứng chuẩn đầu ra (CLO) môn học dưới sự hướng dẫn của **TS. Nguyễn Thanh Tuấn**.
> 2. **Chưa có phê duyệt chính thức bằng văn bản của Giảng viên về Pathway 1:** Đây là phương thức nhóm đề xuất dựa trên tính chất thực tế của đồ án và chuẩn bị đệ trình để Thầy xem xét, phê duyệt chính thức.
> 3. Tuyệt đối không ngụy tạo commit lịch sử, không tạo số liệu giả mạo, không chèn chữ ký khống. Toàn bộ các trường phê duyệt được giữ ở trạng thái **PENDING (CHỜ KÝ CHÍNH THỨC)**.

---

## 2. Kiểm toán Hiện trạng Thực tế (Authenticity Audit)

### 2.1. Hiện trạng Kho lưu trữ Git (Git Repository Audit)
* **URL Kho lưu trữ:** `https://github.com/Quyens/Nutrilens` (Remote: `origin = git@github.com:Quyens/Nutrilens.git`).
* **Tổng số commits trên nhánh chính (`main`):** 33 commits (Từ commit khởi tạo `e970212` ngày 31/10/2026 đến commit `7fb01c3` ngày 10/11/2026).
* **Các nhánh tính năng lịch sử trong Git:**
  - `checkpoint/phase00-baseline`: Đóng băng phiên bản phục hồi sau sự cố với 42 bài test (commit `8ec9c1d`).
  - `feature/phase01-authentication`: Tái thiết mô-đun tài khoản & hồ sơ người dùng (commit `657c4ab` -> merge commit cục bộ `30c2758`).
  - `feature/phase02-meal-logging`: Tái thiết mô-đun ghi nhận bữa ăn đa món & Hydration (commit `0fc25ef` -> merge commit cục bộ `7fb01c3`).
  - `main`: Nhánh tích hợp chính.
* **Người đóng góp thực tế được xác minh trong Git Log:**
  1. `Nguyễn Thanh Thuận` (`thuannt.23itb@vku.udn.vn`, username: `thuan5587`): Sinh viên lớp **23ITB**, Trường ĐH CNTT & Truyền thông Việt - Hàn.
  2. `quyen` (`quyen11072k5@gmail.com`): Đóng góp chính trong việc tái thiết kiến trúc, logic tính toán và các pha phát triển.
  3. `thai1123` (`changtraikhoyeu23@gmail.com`): Tích hợp ban đầu model và giao diện sơ khởi.

### 2.2. Kiểm định Mã nguồn & Tình trạng Tính năng Kỹ thuật
Toàn bộ mã nguồn ứng dụng nằm tại thư mục `NutriLens/` và `NutriLens.xcodeproj` với các pha tính năng đã kiểm chứng:
1. **Phase 00 — Core App & AI Food Recognition:** Mô hình on-device Core ML `FoodClassifier.mlmodelc` (Float16, 30 lớp món ăn Việt Nam chuẩn hóa), Vision preprocessing, Home Dashboard, Food Explorer, Diary V2, Nutrition Analytics.
2. **Phase 01 — Authentication & Account Security:** Đăng ký, đăng nhập, quản lý hồ sơ dinh dưỡng cá nhân, tính TDEE, xác thực sinh trắc học Face ID / Touch ID qua `LocalAuthentication`, bảo mật Keychain.
3. **Phase 02 — Advanced Multi-Item Meal Logging:** Khay ghi nhận món ăn đa món (Multi-Item Staged Tray), tra cứu 35+ món Việt, tính toán khẩu phần gram/calo thời gian thực, lưu trữ SwiftData Hydration.
4. **Phase 03 — Custom Foods & Recipe Builder:** Tạo món cá nhân, xây dựng công thức nấu ăn (nhiều nguyên liệu), tự động tính toán vi chất tổng hợp.
5. **Phase 04 — Weekly Meal Planner:** Dải lịch 7 ngày, lập kế hoạch 4 bữa/ngày, dự báo thâm hụt calo so với TDEE, chuyển kế hoạch sang nhật ký một chạm.
6. **Phase 05 — Smart Meal Suggestions:** Công cụ gợi ý món ăn thông minh theo thâm hụt đa lượng (protein/carb/fat) và bộ lọc loại trừ dị ứng thực phẩm.
7. **Phase 06 — Barcode Scanner & Packaged Food Management:** Quét mã vạch bằng camera (`AVFoundation` + `Vision`), thuật toán GS1 Modulo-10 Checksum, danh mục 7 món bán lẻ Việt Nam mẫu và lưu trữ SwiftData.

### 2.3. Bằng chứng Kiểm thử Tự động Độc lập (Automated Test Execution Evidence)
Thực thi kiểm thử thực tế trên `iPhone 17 Simulator (iOS 26.5)` ngày 13/11/2026:
- **Unit Tests:** 139 / 139 tests ĐẠT (`NutriLensTests.swift`, `CustomFoodsAndRecipesTests.swift`, `WeeklyMealPlannerTests.swift`, `SmartSuggestionsTests.swift`, `BarcodeScannerTests.swift`).
- **UI Tests:** 10 / 10 automated flows ĐẠT (`NutriLensUITests.swift`).
- **Tổng cộng:** **149 / 149 Automated Tests ĐẠT TUYỆT ĐỐI (100% Pass Rate)**.
- *Lưu ý:* Đây là kết quả kiểm thử tự động trong môi trường mô phỏng (Simulator). Việc kiểm thử chấp nhận người dùng thực tế (Human UAT) và kiểm thử trên máy thật iPhone được tách biệt rõ ràng và đang ở trạng thái chuẩn bị thực hiện.

### 2.4. Bằng chứng Vật lý về Sự cố Mất mã nguồn & Sao lưu (Backup Artifacts)
Phát hiện bằng chứng vật lý các gói sao lưu sau sự cố mất mát mã nguồn đầu tháng 11/2026:
- `NutrilensIOS 2.zip` (19.7 MB, 2026-11-03 18:25): Bản lưu trữ trạng thái trước sự cố.
- `NutrilensIOS_PreRecoveryBackup_20261106.zip` (19.4 MB, 2026-11-06 21:46): Bản sao lưu ngay trước khi bắt đầu khôi phục.
- Các bản snapshot theo từng pha: `NutriLens_backup_phase04_20261110_211717`, `NutriLens_backup_phase05_20261111_190844`, `NutriLens_backup_phase05_20261111_203820`, `NutriLens_backup_phase06_20261111_212114`, `NutriLens_backup_phase06_20261113_084643`.

---

## 3. Ma trận Đối soát & Khoảng trống Tuân thủ (Evidence Matrix & Gap Analysis)

| Yêu cầu Môn học (Course Requirement) | Bằng chứng Hiện có (Existing Evidence) | Vị trí Lưu trữ (Location) | Trạng thái (Status) | Thiếu sót Cần Bổ sung (Missing Evidence) | Hành động Khắc phục (Action Required) |
| :--- | :--- | :--- | :---: | :--- | :--- |
| **1. Project Charter (Hiến chương dự án)** | Bản dự thảo 13 mục PMBOK hoàn chỉnh. | `reports/qlda/02_project_charter_draft.md` | **PARTIAL** | Chữ ký phê duyệt thực tế của Giảng viên và Nhóm. | Đệ trình Giảng viên xem xét và ký duyệt chính thức. |
| **2. WBS & WBS Dictionary (Phân rã công việc)** | Bảng WBS phân cấp 4 tầng tuân thủ 100% Rule, 23 gói công việc. | `reports/qlda/03_wbs_dictionary.md` | **VERIFIED** | Chưa có đóng góp phản biện từ Giảng viên. | Trình bày tại buổi bảo vệ để bảo vệ phương án phân rã. |
| **3. GitHub Management (Backlog, Issue, PR)** | Bản thảo 7 User Story, mẫu PR Template, commit có prefix chuẩn. | `reports/qlda/04_github_projects_backlog.md` | **PARTIAL** | Chưa tạo Issue và Project Board trên GitHub Remote. | Nhóm sinh viên chủ động xuất Issue lên GitHub remote khi thống nhất. |
| **4. Lập lịch 15 tuần & CPM (Schedule & Critical Path)** | Lịch trình 15 tuần, phân tích đường găng CPM ($Slack = 0$), tiến độ thực tế. | `reports/qlda/05_15_week_schedule_and_cpm.md` | **VERIFIED** | Dữ liệu Story Points là ước lượng tái thiết lập cho học thuật. | Phân định rõ giữa ước lượng mô phỏng và dữ liệu thực tế. |
| **5. Sổ đăng ký rủi ro (Risk Register Evolution)** | Sổ rủi ro $P \times I$, case study sự cố mất code, tiến hóa qua 5 Sprint. | `reports/qlda/06_risk_register.md` | **VERIFIED** | Cần theo dõi thêm rủi ro định dạng nộp bài iOS vs Android. | Báo cáo trực tiếp Giảng viên về giải pháp nộp bản build iOS. |
| **6. Kiểm soát thay đổi phạm vi (Scope Change Control)** | Hồ sơ 2 phiếu thay đổi `CR-01` (Barcode) và `CR-02` (Home UI). | `reports/qlda/07_change_control_draft.md` | **PARTIAL** | Chữ ký phê duyệt của Giảng viên / Ban kiểm soát thay đổi. | Giữ trạng thái PENDING APPROVAL cho đến khi được duyệt. |
| **7. Kế hoạch UAT & Nghiệm thu (Stakeholder Acceptance)** | 10 kịch bản UAT chi tiết; 10 bài XCUITest tự động pass 100%. | `reports/qlda/08_stakeholder_uat_plan.md` | **PARTIAL** | Phiếu đánh giá và chữ ký của người dùng thử nghiệm thật. | Tổ chức cho 2–3 sinh viên VKU test và ký biên bản. |
| **8. Ma trận truy xuất nguồn gốc (Traceability Matrix)** | Ma trận liên kết 6 cấp độ từ Chuẩn đầu ra VKU đến Test & UAT. | `reports/qlda/09_evidence_traceability_matrix.md` | **VERIFIED** | Phân định rõ commit cục bộ vs PR remote. | Đã hiệu chỉnh chính xác thuật ngữ kỹ thuật trong ma trận. |
| **9. Tự động hóa CI/CD (GitHub Actions)** | Bản thảo kịch bản CI trên runner macOS/Xcode. | `reports/qlda/04_github_projects_backlog.md` | **DRAFT** | Chưa kích hoạt workflow trên GitHub Actions remote. | Giữ ở dạng đề xuất, không tự ý đẩy file khi chưa có lệnh. |
| **10. Bàn giao Ứng dụng Di động (Mobile Deliverable)** | Ứng dụng Native iOS chạy mượt mà trên Simulator và sẵn sàng build máy thật. | `NutriLens.xcodeproj` | **PARTIAL** | Rubric mẫu ghi nộp file APK (Android). | Gửi câu hỏi xin ý kiến Giảng viên về hình thức nộp iOS. |

---

## 4. Làm rõ Hình thức Bàn giao Sản phẩm Di động (Mobile Deliverable Clarification)

Trong đề cương hoặc rubric mẫu của môn học tại trường, mục bàn giao ứng dụng di động thường ghi là **"File cài đặt (APK)"** do đa số sinh viên sử dụng nền tảng Android.

Tuy nhiên, **NutriLens là ứng dụng Native iOS (Swift / SwiftUI / Core ML)**. Để đảm bảo tính chuyên nghiệp và tuân thủ quy định đánh giá, nhóm chuẩn bị câu hỏi chính thức gửi tới **TS. Nguyễn Thanh Tuấn**:

> **Đề xuất câu hỏi gửi Giảng viên hướng dẫn:**  
> *"Kính thưa Thầy TS. Nguyễn Thanh Tuấn, đồ án NutriLens của nhóm em được phát triển Native trên nền tảng iOS (sử dụng SwiftUI, Core ML và SwiftData để tận dụng tối đa Neural Engine on-device của chip Apple Silicon). Để phục vụ cho việc chấm điểm và nghiệm thu sản phẩm, nhóm em xin phép Thầy cho nhóm được bàn giao theo một trong các hình thức phù hợp với hệ sinh thái iOS dưới đây:*
> 1. *Phân phối bản thử nghiệm qua **Apple TestFlight** (mời email của Thầy trực tiếp vào nhóm Internal Testers).*
> 2. *Xuất gói cài đặt **`.ipa` (Ad-hoc / Development Distribution)** kèm tài liệu hướng dẫn cài qua Apple Configurator / AltStore.*
> 3. *Cài đặt trực tiếp lên thiết bị iPhone vật lý và mang tới buổi bảo vệ để Thầy và hội đồng trực tiếp trải nghiệm.*
> 4. *Thực hiện Live Demonstration trên Xcode Simulator (iPhone 17 / iOS 26.5) trong buổi báo cáo.*
> *Nhóm em rất mong nhận được sự định hướng và chấp thuận của Thầy để chuẩn bị hình thức nghiệm thu chu đáo nhất."*

---

## 5. Kết luận Đánh giá Tính Toàn vẹn (Integrity Audit Conclusion)

Dự án NutriLens sở hữu lợi thế vượt trội về **chất lượng kỹ thuật thực tế** (149 tests tự động, kiến trúc Clean Architecture hoàn chỉnh, model Core ML on-device thực tế).

Báo cáo phân tích hiện trạng này xác lập một ranh giới minh bạch:
- **Những gì đã được chứng minh:** Mã nguồn, kiến trúc, 149 tests tự động, lịch sử commit Git và các gói backup vật lý.
- **Những gì đang chờ con người hành động:** Chữ ký phê duyệt Hiến chương, phê duyệt Change Requests, và đánh giá thực tế từ người dùng thử nghiệm sinh viên VKU.
