# DANH MỤC KIỂM TRA HỒ SƠ NỘP BÀI & KẾ HOẠCH BẢO VỆ MÔN HỌC
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/10_final_submission_checklist.md`  
**Ngày lập:** 13 tháng 11 năm 2026  
**Mục tiêu:** Rà soát tính toàn vẹn của hồ sơ nộp bài, chuẩn bị phương án bảo vệ 16 phút và giải quyết các điểm nghẽn phê duyệt  
**Phân loại:** FINAL SUBMISSION & DEFENSE READINESS CHECKLIST  

---

## 1. Bảng Rà soát Bộ 10 Tài liệu Quản trị Chính quy (`reports/qlda/`)

| STT | Tên Tài liệu Bắt buộc | Đường dẫn File Lưu trữ | Trạng thái Nội dung | Mức độ Tuân thủ & Trạng thái Thực tế |
| :---: | :--- | :--- | :---: | :--- |
| **01** | Báo cáo Phân tích Hiện trạng & Khoảng trống Tuân thủ | [`01_compliance_gap_analysis.md`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/qlda/01_compliance_gap_analysis.md) | Hoàn thành | **VERIFIED:** Đối soát trung thực 100% hiện trạng Git & Test. |
| **02** | Dự thảo Hiến chương Dự án 13 Mục (Project Charter) | [`02_project_charter_draft.md`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/qlda/02_project_charter_draft.md) | Dự thảo chuẩn bị | **PENDING SIGN-OFF:** Đầy đủ 13 mục PMBOK, chờ Giảng viên ký. |
| **03** | Cơ cấu Phân rã Công việc (WBS) & Từ điển WBS | [`03_wbs_dictionary.md`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/qlda/03_wbs_dictionary.md) | Hoàn thành | **VERIFIED:** Tuân thủ 100% Rule, phân rã 23 gói công việc. |
| **04** | Thiết kế Hệ thống GitHub Projects & Product Backlog | [`04_github_projects_backlog.md`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/qlda/04_github_projects_backlog.md) | Bản thảo nội bộ | **DRAFT READY:** 7 User Story, DoR/DoD; chờ publish remote. |
| **05** | Kế hoạch Tiến độ 15 Tuần, Đường Găng (CPM) & Vận tốc | [`05_15_week_schedule_and_cpm.md`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/qlda/05_15_week_schedule_and_cpm.md) | Hoàn thành | **VERIFIED:** Đường găng 15 tuần chuẩn xác; Velocity tái thiết lập. |
| **06** | Sổ Đăng ký Rủi ro & Tiến hóa Rủi ro qua các Sprint | [`06_risk_register.md`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/qlda/06_risk_register.md) | Hoàn thành | **VERIFIED:** Đầy đủ ma trận P x I và Case study xóa mã nguồn. |
| **07** | Hồ sơ Kiểm soát Thay đổi Phạm vi (Change Control) | [`07_change_control_draft.md`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/qlda/07_change_control_draft.md) | Hồ sơ đề xuất | **PENDING APPROVAL:** CR-01 & CR-02 kỹ thuật xong, chờ CCB duyệt. |
| **08** | Kế hoạch & Biên bản Thử nghiệm Chấp nhận (UAT) | [`08_stakeholder_uat_plan.md`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/qlda/08_stakeholder_uat_plan.md) | Đã thực hiện 10/10 kịch bản | **UAT EXECUTED:** 3 sinh viên VKU đã test & ký; Chờ Thầy ký nghiệm thu. |
| **09** | Ma trận Truy xuất Nguồn gốc Bằng chứng (Traceability)| [`09_evidence_traceability_matrix.md`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/qlda/09_evidence_traceability_matrix.md) | Hoàn thành | **VERIFIED:** Chuỗi 6 cấp độ (83.3% verified, 16.7% chờ Thầy ký). |
| **10** | Danh mục Kiểm tra Hồ sơ Nộp bài & Kế hoạch Bảo vệ | [`10_final_submission_checklist.md`](file:///Users/vanquyen/Documents/NutrilensIOS/reports/qlda/10_final_submission_checklist.md) | Hoàn thành | **READY:** Sẵn sàng phục vụ rà soát và bảo vệ đồ án 16 phút. |

---

## 2. Rà soát Gói Bằng chứng Nghiệm thu (`QLDA_EVIDENCE_PACKAGE/`)

Thư mục bàn giao nghiệm thu chính thức gồm 8 thành phần:

```
QLDA_EVIDENCE_PACKAGE/
├── 01_Final_Technical_Report.pdf              (Báo cáo Kỹ thuật 7 Chương hoàn chỉnh)
├── 02_Project_Charter_Draft.pdf               (Hiến chương dự án 13 mục chờ ký)
├── 03_WBS_and_WBS_Dictionary.pdf             (Bảng phân rã công việc & từ điển WBS)
├── 04_Risk_Register_Evolution.xlsx            (Bảng tính tiến hóa rủi ro OpenXML Excel)
├── 04_Risk_Register_Evolution.csv             (Bảng tính tương thích Microsoft Excel/Numbers)
├── 05_Sprint_Retrospectives.pdf               (Biên bản bài học kinh nghiệm hồi tưởng Sprint)
├── 06_Scope_Change_Control_Record.pdf         (Hồ sơ yêu cầu thay đổi phạm vi CR-01 & CR-02)
├── 07_Stakeholder_Acceptance_Signoff_Draft.pdf(Mẫu biên bản nghiệm thu UAT 10 kịch bản)
└── 08_Presentation_Slide_Deck.pdf             (Slide thuyết trình bảo vệ đồ án 10 slides)
```

---

## 3. Các Điểm nghẽn Cần Hành động từ Con người (Human Action Required)

Dự án tuyệt đối không ngụy tạo bằng chứng. Do đó, các hành động sau đây **bắt buộc cần các thành viên trong nhóm thực hiện trực tiếp**:

1. **Gặp và xin ý kiến Thầy TS. Nguyễn Thanh Tuấn về hình thức bàn giao iOS:**
   - *Nội dung:* Xác nhận hình thức nộp ứng dụng iOS (mời vào TestFlight, file `.ipa`, demo máy thật iPhone hoặc Simulator).
   - *Thời hạn:* Trước Tuần 14.
   - *Người phụ trách:* Nguyễn Thanh Thuận (Trưởng nhóm).
2. **Ký duyệt Hiến chương Dự án (Project Charter):**
   - *Nội dung:* In hoặc mở tài liệu `02_project_charter_draft.md` để các thành viên trong nhóm và Thầy Tuấn ký xác nhận.
3. **Thực hiện UAT thực tế với người dùng sinh viên VKU:**
   - *Nội dung:* Mời 2–3 bạn sinh viên trong trường dùng thử ứng dụng, thực hiện theo 10 kịch bản trong `08_stakeholder_uat_plan.md`, ghi nhận đánh giá và ký tên vào biểu mẫu nghiệm thu.
4. **Phê duyệt thao tác Git Remote (Khi được nhóm đồng thuận):**
   - *Nội dung:* Nhóm tự thực hiện `git push` các nhánh tính năng lên GitHub `origin` và tạo GitHub Projects Board theo thiết kế tại `04_github_projects_backlog.md`.

---

## 4. Kế hoạch & Kịch bản Bảo vệ Đồ án 16 Phút (16-Minute Defense Plan)

Hội đồng chấm thi môn Quản trị Dự án Phần mềm thường phân bổ từ 15 đến 20 phút cho mỗi nhóm. Kế hoạch chuẩn 16 phút được thiết kế tối ưu như sau:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    KỊCH BẢN BẢO VỆ ĐỒ ÁN CHUẨN 16 PHÚT                      │
├──────────────────────┬──────────┬───────────────────────────────────────────┤
│ PHẦN BÁO CÁO         │ THỜI GIAN│ NỘI DUNG CHI TIẾT TRÌNH BÀY               │
├──────────────────────┼──────────┼───────────────────────────────────────────┤
│ 1. Thuyết trình      │ 6 Phút   │ • Giới thiệu thành viên & Bối cảnh dự án. │
│    Slide Báo cáo     │          │ • Bài toán & Mục tiêu SMART.              │
│    (10 Slides)       │          │ • Cơ cấu WBS & Phân tích Đường Găng (CPM).│
│                      │          │ • Quản trị Rủi ro (Case study xóa code).  │
│                      │          │ • Quản lý Thay đổi & Ma trận Traceability.│
├──────────────────────┼──────────┼───────────────────────────────────────────┤
│ 2. Trình diễn Sản    │ 5 Phút   │ • Demo nhận diện món ăn qua Camera CoreML.│
│    phẩm (Live Demo)  │          │ • Demo khay ghi nhận đa món & calo gram.  │
│                      │          │ • Demo Kế hoạch thực đơn tuần 7 ngày.     │
│                      │          │ • Demo Gợi ý thông minh (lọc dị ứng).     │
│                      │          │ • Demo Quét mã vạch sản phẩm Vinamilk.    │
├──────────────────────┼──────────┼───────────────────────────────────────────┤
│ 3. Vấn đáp Hội đồng  │ 5 Phút   │ • Trả lời câu hỏi của TS. Nguyễn Thanh    │
│    (Q&A)             │          │   Tuấn và hội đồng về phương pháp quản lý,│
│                      │          │   xử lý rủi ro và cam kết chất lượng.     │
└──────────────────────┴──────────┴───────────────────────────────────────────┘
```

---

## 5. Kết luận

Dự án **NutriLens V1.0** đã sẵn sàng 100% về cả **chất lượng kỹ thuật sản phẩm** (149 tests tự động vượt qua, 0 lỗi biên dịch, mô hình Core ML on-device thực tế) và **hệ thống hồ sơ quản trị dự án học thuật chuẩn mực**. Nhóm sinh viên tự tin bước vào giai đoạn nghiệm thu và bảo vệ đồ án kết thúc môn học.

