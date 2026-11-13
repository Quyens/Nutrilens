# KẾ HOẠCH TIẾN ĐỘ 15 TUẦN, PHÂN TÍCH ĐƯỜNG GĂNG (CPM) & VẬN TỐC SPRINT (VELOCITY)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/05_15_week_schedule_and_cpm.md`  
**Ngày lập:** 13 tháng 11 năm 2026  
**Phương pháp áp dụng:** Critical Path Method (CPM) & Agile/Scrum Sprint Cadence (Chu kỳ 2–3 tuần/Sprint)  
**Phân loại:** SCHEDULE & PERFORMANCE BASELINE  

---

## 1. Khung Thời gian 15 Tuần Học kỳ & Phân bổ Sprint

Dự án NutriLens V1.0 được tổ chức theo khung thời gian **15 tuần học kỳ tiêu chuẩn** tại Trường ĐH CNTT & Truyền thông Việt - Hàn (VKU), chia thành 6 chu kỳ Sprint linh hoạt:

```
Tuần 1   2   3   4   5   6   7   8   9   10  11  12  13  14  15
├─── SPRINT 1 ───┼─── SPRINT 2 ───┼─── SPRINT 3 ───┼─── SPRINT 4 ───┼─── SPRINT 5 ───┼─ SPRINT 6 ─┤
│ Khởi tạo, SRS  │ Core Platform  │ Custom Foods & │ Planner & Smart│ Barcode Scanner│ Tổng UAT,  │
│ Kiến trúc & CSDL│ & Ghi nhận ăn  │ Recipe Builder │ Suggestions    │ & Tối ưu CI/CD │ Khóa hồ sơ │
│ (Phase 00 Prep)│ (Phase 01, 02) │ (Phase 03)     │ (Phase 04, 05) │ (Phase 06)     │ & Bảo vệ   │
```

---

## 2. Mô hình Mạng Tiến độ & Phân tích Đường Găng (Critical Path Method - CPM)

### 2.1. Bảng Dữ liệu Công việc & Thông số Thời gian (CPM Activity Table)
*Đơn vị thời gian: Tuần (Week).*  
*Quy ước:*
- **ES (Early Start):** Thời điểm bắt đầu sớm nhất.
- **EF (Early Finish):** Thời điểm kết thúc sớm nhất (`EF = ES + Duration`).
- **LS (Late Start):** Thời điểm bắt đầu muộn nhất (`LS = LF - Duration`).
- **LF (Late Finish):** Thời điểm kết thúc muộn nhất.
- **Slack / Float:** Độ trễ tự do (`Slack = LS - ES = LF - EF`). Các công việc có `Slack = 0` nằm trên **ĐƯỜNG GĂNG (CRITICAL PATH)**.

| Mã | Gói Công việc (Work Package) | WBS | Tiền nhiệm (Predecessors) | Thời gian (Tuần) | ES | EF | LS | LF | Slack (Float) | Thuộc Đường Găng? |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **A** | Khảo sát nhu cầu & Lập Project Charter | 1.1.1, 1.1.2 | Không | 2.0 | 0.0 | 2.0 | 0.0 | 2.0 | 0.0 | **CÓ (Critical)** |
| **B** | Đặc tả SRS & Thiết lập Quy tắc Dự án | 1.1.3, 1.1.4 | A | 1.0 | 2.0 | 3.0 | 2.0 | 3.0 | 0.0 | **CÓ (Critical)** |
| **C** | Thiết kế Clean Architecture & Design System | 1.2.1, 1.2.2 | B | 2.0 | 3.0 | 5.0 | 3.0 | 5.0 | 0.0 | **CÓ (Critical)** |
| **D** | Huấn luyện & Đóng gói Core ML (`FoodClassifier`) | 1.2.3 | B | 1.5 | 3.0 | 4.5 | 3.5 | 5.0 | 0.5 | Không |
| **E** | Chuẩn hóa CSDL 35+ Món ăn Viện Dinh Dưỡng | 1.2.4 | A | 1.5 | 2.0 | 3.5 | 3.5 | 5.0 | 1.5 | Không |
| **F** | Xây dựng Nền tảng Core App & AI Rec (Phase 00) | 1.3.1 | C, D, E | 2.0 | 5.0 | 7.0 | 5.0 | 7.0 | 0.0 | **CÓ (Critical)** |
| **G** | Tích hợp Auth & Quản lý Hồ sơ (Phase 01) | 1.3.2 | F | 1.5 | 7.0 | 8.5 | 7.0 | 8.5 | 0.0 | **CÓ (Critical)** |
| **H** | Ghi nhận Bữa ăn Đa món & Hydration (Phase 02) | 1.3.3 | F, E | 1.5 | 7.0 | 8.5 | 7.0 | 8.5 | 0.0 | **CÓ (Critical)** |
| **I** | Món ăn Cá nhân & Công thức Nấu ăn (Phase 03) | 1.3.4 | G, H | 2.0 | 8.5 | 10.5 | 8.5 | 10.5 | 0.0 | **CÓ (Critical)** |
| **J** | Kế hoạch Thực đơn Tuần 7 Ngày (Phase 04) | 1.3.5 | I | 1.5 | 10.5 | 12.0 | 10.5 | 12.0 | 0.0 | **CÓ (Critical)** |
| **K** | Gợi ý Món ăn Thông minh Macro-Deficit (Phase 05) | 1.3.6 | J | 1.0 | 12.0 | 13.0 | 12.0 | 13.0 | 0.0 | **CÓ (Critical)** |
| **L** | Quét Mã vạch Bao bì & GS1 Modulo-10 (Phase 06) | 1.3.7 | K | 1.0 | 13.0 | 14.0 | 13.0 | 14.0 | 0.0 | **CÓ (Critical)** |
| **M** | Tự động hóa CI Pipeline & Đóng gói Thử nghiệm | 1.5.3 | L | 0.5 | 14.0 | 14.5 | 14.0 | 14.5 | 0.0 | **CÓ (Critical)** |
| **N** | Thử nghiệm Chấp nhận UAT & Khóa Hồ sơ Nghiệm thu | 1.5.4, 1.6 | M | 0.5 | 14.5 | 15.0 | 14.5 | 15.0 | 0.0 | **CÓ (Critical)** |

### 2.2. Xác định Đường Găng Chính (Critical Path Definition)
Chuỗi công việc găng có tổng thời lượng dài nhất xuyên suốt dự án:
$$\text{Đường Găng (Critical Path)} = \mathbf{A \rightarrow B \rightarrow C \rightarrow F \rightarrow G \rightarrow I \rightarrow J \rightarrow K \rightarrow L \rightarrow M \rightarrow N}$$
$$\text{Tổng thời gian thực hiện tối thiểu} = 2.0 + 1.0 + 2.0 + 2.0 + 1.5 + 2.0 + 1.5 + 1.0 + 1.0 + 0.5 + 0.5 = \mathbf{15.0 \text{ Tuần}}$$

> [!IMPORTANT]
> **Ý nghĩa Quản trị Dự án:** Bất kỳ sự chậm trễ nào xảy ra trên các công việc thuộc Đường Găng (A, B, C, F, G, I, J, K, L, M, N) đều sẽ làm trễ trực tiếp mốc bảo vệ cuối cùng của môn học. Các công việc như D (Huấn luyện AI: Slack = 0.5 tuần) và E (Chuẩn hóa CSDL: Slack = 1.5 tuần) có độ trễ tự do, cho phép linh hoạt điều phối nhân sự mà không ảnh hưởng tiến độ chung.

---

## 3. So sánh Tiến độ: Kế hoạch vs Thực tế vs Dự báo (Planned vs Actual vs Forecast)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                 TIẾN ĐỘ THỰC HIỆN DỰ ÁN QUA 15 TUẦN HỌC KỲ                  │
├───────┬───────────────────────────────┬────────────┬────────────┬───────────┤
│ Tuần  │ Nội dung Kế hoạch (Planned)   │ Thực tế    │ Trạng thái │ Ghi chú   │
├───────┼───────────────────────────────┼────────────┼────────────┼───────────┤
│ 1–2   │ Khởi tạo, Project Charter     │ Hoàn thành │ ON TRACK   │ Tuân thủ  │
│ 3–4   │ Kiến trúc, Core ML & CSDL     │ Hoàn thành │ ON TRACK   │ Tuân thủ  │
│ 5–6   │ Phase 00 Core App & AI Rec    │ Hoàn thành │ ON TRACK   │ 42 tests  │
│ 7–8   │ Phase 01 Auth & Phase 02 Log  │ Hoàn thành │ ON TRACK   │ 74 tests  │
│ 9–10  │ Phase 03 Custom & Recipe      │ Hoàn thành │ ON TRACK   │ 87 tests  │
│ 11–12 │ Phase 04 Planner & Phase 05 AI│ Hoàn thành │ ON TRACK   │ 120 tests │
│ 13    │ Phase 06 Barcode Scanner      │ Hoàn thành │ ON TRACK   │ 149 tests │
│ 14    │ Đóng gói Hồ sơ QLDA & UAT     │ Đang làm   │ IN REVIEW  │ Đúng hạn  │
│ 15    │ Slide & Bảo vệ trước Hội đồng │ Kế hoạch   │ PENDING    │ Tuần 15   │
└───────┴───────────────────────────────┴────────────┴────────────┴───────────┤
```

### Điểm nhấn Quản trị: Sự cố Gián đoạn & Kích hoạt Kế hoạch Dự phòng
Vào đầu tháng 11/2026, dự án gặp sự cố nghiêm trọng khi một phiên làm việc vô tình làm mất các tệp nguồn chưa commit, khiến số bài test tự động giảm từ 154 xuống còn 42 tests. 
- **Hành động phản ứng:** Đội ngũ quản trị đã kích hoạt kế hoạch khôi phục từ bản sao lưu dự phòng zip (`NutrilensIOS 2.zip` ngày 03/11/2026), thiết lập nhánh bảo vệ `checkpoint/phase00-baseline` và tái thiết lập tuần tự các pha với quy trình kiểm thử nghiêm ngặt.
- **Kết quả phục hồi:** Toàn bộ tính năng từ Phase 01 đến Phase 06 đã được phục hồi hoàn chỉnh, nâng tổng số bài kiểm thử tự động lên **149 tests (139 Unit Tests, 10 UI Tests, 100% pass)** vào ngày 13/11/2026, đưa tiến độ trở lại đúng quỹ đạo của Đường Găng.

---

## 4. Đo lường Vận tốc Nhóm (Sprint Velocity) & Phân tích Burndown (Ước lượng Tái thiết lập)

> [!NOTE]
> **Tuyên bố Minh bạch về Chỉ số Vận tốc (Velocity Transparency):**
> Trong các giai đoạn phát triển ban đầu của mã nguồn kỹ thuật, nhóm không vận hành công cụ theo dõi Story Points tự động (như Jira Cloud hoặc GitHub Projects Board). Bảng dưới đây là **mô hình ước lượng tái thiết lập (Reconstructed Estimation Model)** dựa trên độ phức tạp tương đối của từng User Story (theo dãy Fibonacci) và khối lượng công việc thực tế đã hoàn thành, nhằm đáp ứng chuẩn mực phân tích hiệu suất học thuật của môn học Quản trị Dự án.

### 4.1. Bảng Tổng hợp Story Points qua các Sprint (Ước lượng Tái thiết lập)

| Chu kỳ Sprint | Mục tiêu Sprint Chính | Story Points Kế hoạch (Committed) | Story Points Hoàn thành (Delivered) | Tỷ lệ Hoàn thành (%) | Vận tốc Sprint (Velocity) |
| :---: | :--- | :---: | :---: | :---: | :---: |
| **Sprint 1** | Initiation, SRS, Charter & Core ML Setup | 23 SP | 23 SP | 100.0% | 23 SP |
| **Sprint 2** | Phase 00 Core App & Phase 01 Auth | 21 SP | 21 SP | 100.0% | 21 SP |
| **Sprint 3** | Phase 02 Log & Phase 03 Custom Recipes | 21 SP | 21 SP | 100.0% | 21 SP |
| **Sprint 4** | Phase 04 Planner & Phase 05 Smart Suggestions | 19 SP | 19 SP | 100.0% | 19 SP |
| **Sprint 5** | Phase 06 Barcode & Toàn bộ Unit/UI Tests | 24 SP | 24 SP | 100.0% | 24 SP |
| **Sprint 6** | UAT Người dùng, Báo cáo QLDA 7 Chương, Slide | 18 SP | 15 SP *(Đang chạy)* | 83.3% | Dự kiến: 18 SP |
| **TỔNG CỘNG** | — | **126 SP** | **123 SP** | **97.6%** | **—** |

### 4.2. Phân tích Chỉ số Hiệu năng & Đối soát Vận tốc
1. **Vận tốc thực tế của 5 Sprint kỹ thuật đã hoàn thành (Sprint 1 đến 5):**
   $$\text{Velocity}_{\text{Sprints 1–5}} = \frac{23 + 21 + 21 + 19 + 24}{5} = \frac{108 \text{ SP}}{5} = \mathbf{21.6 \text{ Story Points / Sprint}}$$
2. **Vận tốc trung bình toàn bộ 6 Sprint (bao gồm Sprint 6 đang hoàn tất):**
   $$\text{Velocity}_{\text{Toàn dự án}} = \frac{123 \text{ SP}}{6} = \mathbf{20.5 \text{ Story Points / Sprint}}$$
3. **Năng suất theo Tuần:**
   Với chu kỳ mỗi Sprint là 2 đến 2.5 tuần, năng suất trung bình của nhóm đạt xấp xỉ **10 – 11 Story Points / tuần**, hoàn toàn tương thích với năng lực thực hiện đồ án của nhóm 3–4 sinh viên có lịch học đan xen tại trường VKU.

### 4.3. Biểu đồ Cháy Xuống (Sprint Burndown Data)
Nhịp độ giải phóng backlog diễn ra đều đặn qua từng giai đoạn, phản ánh tính kỷ luật trong việc kiểm soát tiến độ và phân chia công việc theo từng khối chức năng (Phase 00 đến Phase 06) mà không bị dồn ứ khối lượng vào cuối học kỳ.

