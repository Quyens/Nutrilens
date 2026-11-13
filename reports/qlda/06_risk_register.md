# SỔ ĐĂNG KÝ RỦI RO & BÁO CÁO TIẾN HÓA RỦI RO (RISK REGISTER EVOLUTION)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/06_risk_register.md`  
**Ngày lập:** 13 tháng 11 năm 2026  
**Phương pháp định lượng:** Ma trận Rủi ro PMBOK $P \times I = R$  
**Thang đo:** Xác suất $P$ (1 = Rất thấp, 2 = Thấp, 3 = Trung bình, 4 = Cao, 5 = Rất cao); Tác động $I$ (1 = Không đáng kể, 2 = Nhẹ, 3 = Trung bình, 4 = Nghiêm trọng, 5 = Thảm họa). Điểm rủi ro $R = P \times I$ (1–4: Thấp, 5–9: Trung bình, 10–14: Cao, 15–25: Cực kỳ nguy hiểm).

---

## 1. Case Study Thực tế: Sự cố Mất mát Mã nguồn & Kế hoạch Phục hồi (Incident Post-Mortem)

Trong quản trị dự án phần mềm, rủi ro mất mát dữ liệu và mã nguồn là một trong những rủi ro thảm họa nhất. Dự án NutriLens đã thực sự trải qua một sự cố thực tế và giải quyết thành công bằng quy trình quản trị rủi ro chuyên nghiệp:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│             CASE STUDY: SỰ CỐ MẤT MÁT MÃ NGUỒN ĐẦU THÁNG 11/2026            │
├─────────────────────────────────────────────────────────────────────────────┤
│ 1. THỜI ĐIỂM XẢY RA: Đầu tháng 11/2026 (trước mốc kiểm toán 06/11/2026).     │
│ 2. NGUYÊN NHÂN: Thao tác ghi đè thư mục cục bộ khi chưa kịp commit lên Git, │
│    dẫn đến mất các file nguồn đang phát triển từ Phase 01 đến Phase 06.     │
│ 3. HẬU QUẢ: Số lượng bài test tự động giảm từ 154 xuống còn 42 tests        │
│    (thiếu hụt 72.7% bài kiểm thử), đe dọa trực tiếp tiến độ hoàn thành môn. │
│ 4. BẰNG CHỨNG LƯU TRỮ VẬT LÝ TỒN TẠI:                                       │
│    • File zip sao lưu ngày 03/11: `NutrilensIOS 2.zip` (19.7 MB).           │
│    • Báo cáo kiểm toán kỹ thuật: `reports/nutrilens_recovery_audit.md`.     │
│ 5. HÀNH ĐỘNG ỨNG PHÓ (CONTINGENCY EXECUTION):                               │
│    • Bước 1: Tạo bản sao lưu khẩn cấp `NutrilensIOS_PreRecoveryBackup.zip`. │
│    • Bước 2: Tạo nhánh bảo vệ `checkpoint/phase00-baseline` (commit 8ec9c1d)│
│    • Bước 3: Tái thiết lập từng pha (Phase 01 -> Phase 06) kèm test tự động │
│      và lập báo cáo nghiệm thu riêng cho từng giai đoạn.                    │
│    • Bước 4: Tạo các bản snapshot zip định kỳ ngoài workspace sau mỗi pha.  │
│ 6. KẾT QUẢ ĐẠT ĐƯỢC:                                                        │
│    • Khôi phục 100% chức năng sản phẩm đạt chuẩn Clean Architecture.        │
│    • Nâng tổng số bài test lên 149 tests (139 Unit, 10 UI, 100% pass).      │
│ 7. KIỂM SOÁT PHÒNG NGỪA ÁP DỤNG (PREVENTIVE CONTROLS):                     │
│    • Thực hiện chính sách Strict Git Read-Only đối với các agent/công cụ.   │
│    • Chỉ con người (Tech Lead) mới được quyền thực hiện các lệnh Git write. │
│    • Bắt buộc backup snapshot sang thư mục ngoài trước mọi đợt sửa đổi lớn.│
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Sổ Đăng ký Rủi ro Tổng thể (Master Risk Register)

| Mã Rủi ro | Phân loại | Mô tả Rủi ro Chi tiết | Xác suất (P) | Tác động (I) | Điểm Rủi ro (R) | Mức độ | Chủ rủi ro (Owner) | Biện pháp Giảm thiểu (Mitigation) | Kế hoạch Dự phòng (Contingency Plan) | Trạng thái | Bằng chứng Thực tế (Evidence) |
| :---: | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :--- | :--- | :---: | :--- |
| **RSK-01** | Kỹ thuật / Dữ liệu | Mất mát mã nguồn cục bộ do thao tác nhầm trên workspace. | 2 | 5 | **10** | **CAO** | Tech Lead | Commit thường xuyên; đóng băng nhánh checkpoint; cấm force-push. | Khôi phục từ bản sao lưu snapshot zip ngoài workspace trong dưới 15 phút. | **ĐÃ GIẢI QUYẾT** | Các file zip sao lưu `NutriLens_backup_phase*.zip` và báo cáo audit 06/11. |
| **RSK-02** | Quản trị / Bàn giao | Khác biệt định dạng bàn giao giữa rubric mẫu (APK) và sản phẩm thật (iOS). | 3 | 4 | **12** | **CAO** | PM / Scrum Master | Soạn thảo câu hỏi chính thức gửi Giảng viên TS. Nguyễn Thanh Tuấn từ sớm; chuẩn bị TestFlight/IPA. | Chuẩn bị sẵn iPhone vật lý và Xcode Simulator để thực hiện Live Demo trước hội đồng. | **ĐANG THEO DÕI** | Mục 4 trong `01_compliance_gap_analysis.md`. |
| **RSK-03** | Công nghệ / AI | Mô hình Core ML chạy quá chậm hoặc crash bộ nhớ trên iPhone cũ. | 2 | 4 | **8** | **TRUNG BÌNH** | AI Engineer | Lượng tử hóa mô hình sang Float16; chạy tiền xử lý ảnh trên Vision Framework. | Tối ưu hóa kích thước ảnh đầu vào 299x299px; xử lý suy luận bất đồng bộ trên background thread. | **ĐÃ KIỂM SOÁT** | File `FoodClassifier.mlmodelc` chạy <200ms trên Simulator. |
| **RSK-04** | Kiến trúc / Dữ liệu | Lỗi không tương thích dữ liệu SwiftData (Migration Failure) khi thêm model mới. | 2 | 3 | **6** | **TRUNG BÌNH** | Backend / Architect | Thiết kế Schema tách biệt; sử dụng Repository Pattern để cô lập tầng lưu trữ. | Triển khai SwiftData versioned schema migration; viết unit test cho tầng migration. | **ĐÃ KIỂM SOÁT** | Bộ test `WeeklyMealPlannerTests` và `CustomFoodsAndRecipesTests` pass 100%. |
| **RSK-05** | Tiến độ (Schedule) | Trễ hạn nộp bài do khối lượng công việc kiểm thử và viết tài liệu quá lớn. | 2 | 4 | **8** | **TRUNG BÌNH** | PM | Phân tích đường găng CPM; theo dõi vận tốc Story Points qua từng Sprint; giới hạn WIP. | Cắt giảm các tính năng thứ yếu không bắt buộc (chuyển Voice Logging sang pha sau). | **ĐÃ KIỂM SOÁT** | Bản kế hoạch 15 tuần `05_15_week_schedule_and_cpm.md`. |
| **RSK-06** | Pháp lý / Quyền riêng tư | Vi phạm chính sách quyền riêng tư dữ liệu người dùng khi chụp ảnh bữa ăn. | 1 | 5 | **5** | **TRUNG BÌNH** | Tech Lead | Kiến trúc Offline-First 100%; không gửi ảnh lên server ngoại vi; chỉ lưu cục bộ. | Ban hành tài liệu `Documentation/PRIVACY.md` và `SECURITY.md` tuân thủ App Store. | **ĐÃ KIỂM SOÁT** | Mã nguồn không chứa bất kỳ network upload logic nào cho ảnh. |

---

## 3. Bảng Tiến hóa Rủi ro qua các Sprint (Risk Register Evolution)

*Bảng đối chiếu sự biến động của điểm số rủi ro ($R = P \times I$) qua các mốc Sprint:*

| Mã Rủi ro | Tên Rủi ro | Sprint 1 (Tuần 1–3) | Sprint 2 (Tuần 4–6) | Sprint 3 (Tuần 7–9) *(Thời điểm sự cố)* | Sprint 4 (Tuần 10–12) *(Sau phục hồi)* | Sprint 5 (Tuần 13–14) *(Hiện tại)* | Xu hướng Rủi ro (Trend) |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **RSK-01** | Mất mát mã nguồn | P2 x I5 = **10** (Cao) | P2 x I5 = **10** (Cao) | P5 x I5 = **25 (Thảm họa)** | P1 x I5 = **5** (Trung bình) | P1 x I4 = **4 (Thấp)** | 📉 Giảm mạnh nhờ quy trình backup đa tầng |
| **RSK-02** | Khác biệt định dạng iOS/APK | P3 x I4 = **12** (Cao) | P3 x I4 = **12** (Cao) | P3 x I4 = **12** (Cao) | P3 x I4 = **12** (Cao) | P2 x I3 = **6 (Trung bình)** | 📉 Giảm sau khi chuẩn bị sẵn các phương án nộp |
| **RSK-03** | Hiệu năng Core ML on-device | P4 x I4 = **16** (Cực cao)| P2 x I4 = **8** (Trung bình) | P2 x I3 = **6** (Trung bình) | P1 x I3 = **3** (Thấp) | P1 x I2 = **2 (Rất thấp)** | 📉 Đã đóng gói model thành công, chạy <200ms |
| **RSK-04** | Migration lỗi SwiftData | P3 x I3 = **9** (Trung bình)| P3 x I3 = **9** (Trung bình) | P4 x I3 = **12** (Cao) | P2 x I3 = **6** (Trung bình) | P1 x I2 = **2 (Rất thấp)** | 📉 Tầng persistence ổn định qua 6 phase |
| **RSK-05** | Rủi ro trễ tiến độ Đường Găng | P3 x I4 = **12** (Cao) | P3 x I4 = **12** (Cao) | P4 x I5 = **20 (Cực cao)** | P2 x I4 = **8** (Trung bình) | P1 x I3 = **3 (Thấp)** | 📉 Toàn bộ 6 phase đã xong, còn 149 tests pass |
| **RSK-06** | Bảo mật quyền riêng tư ảnh | P2 x I5 = **10** (Cao) | P1 x I5 = **5** (Trung bình) | P1 x I5 = **5** (Trung bình) | P1 x I4 = **4** (Thấp) | P1 x I4 = **4 (Thấp)** | 📉 100% offline-first, an toàn tuyệt đối |

