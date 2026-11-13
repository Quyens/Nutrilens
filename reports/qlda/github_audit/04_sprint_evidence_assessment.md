# BÁO CÁO ĐÁNH GIÁ BẰNG CHỨNG SPRINT 1 & SPRINT 2 (SPRINT EVIDENCE ASSESSMENT)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/github_audit/04_sprint_evidence_assessment.md`  
**Ngày thực hiện đánh giá:** 13 tháng 11 năm 2026  
**Mục tiêu:** Thẩm định tính xác thực của các chu kỳ Sprint, phân định rạch ròi bằng chứng kỹ thuật và ước lượng học thuật.

---

## 1. Phân Định Minh Bạch 3 Nhóm Thông Tin Về Sprint (Three-Tier Classification)

Theo đúng tinh thần chỉ đạo liêm chính học thuật của môn học, toàn bộ hồ sơ quản trị Sprint được phân định thành 3 nhóm rõ rệt:

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PHÂN ĐỊNH 3 TẦNG BẰNG CHỨNG SPRINT                       │
├─────────────────────────┬───────────────────────────────────────────────────┤
│ TẦNG THÔNG TIN          │ BẢN CHẤT DỮ LIỆU & BẰNG CHỨNG ĐỐI SOÁT            │
├─────────────────────────┼───────────────────────────────────────────────────┤
│ TẦNG A: HOẠT ĐỘNG THỰC TẾ│ - Lịch sử commits thật trên GitHub (33-36 commits)│
│ (Có bằng chứng xác minh)│ - Dữ liệu tác giả thật (@Quyens, @thuan, @thai)   │
│                         │ - Mã nguồn các tính năng thực thi trên iOS        │
│                         │ - 149 Automated Tests pass & 10 kịch bản UAT thật │
├─────────────────────────┼───────────────────────────────────────────────────┤
│ TẦNG B: ƯỚC LƯỢNG HỒI CỐ│ - Số lượng Story Points (Fibonacci) quy đổi ngược  │
│ (Reconstructed Estimate)│ - Bảng tính CPM 15 tuần chuẩn hóa môn học         │
│                         │ - Chỉ số vận tốc trung bình (Velocity: 21.6 SP)   │
├─────────────────────────┼───────────────────────────────────────────────────┤
│ TẦNG C: CHƯA DIỄN RA    │ - Biên bản cuộc họp Sprint Retrospective có ghi âm│
│ (Chưa có ghi chép cứng) │ - Chữ ký trực tiếp của Thầy Tuấn trên chứng nhận  │
└─────────────────────────┴───────────────────────────────────────────────────┘
```

---

## 2. Báo Cáo Thực Tế Sprint 1 (Sprint 1 Review: Tuần 1 – Tuần 6)

- **Mục tiêu Sprint (Sprint Goal):** Thiết lập nền tảng dự án, xây dựng cơ sở dữ liệu thực phẩm Việt Nam, tích hợp mô hình AI Core ML nhận diện món ăn on-device và hoàn thiện hệ thống Profile/Xác thực.
- **Bằng chứng kỹ thuật thực tế đối soát:**
  1. *Khởi tạo dự án & Dataset:* Commit `e970212` (31/10/2026 by Nguyễn Thanh Thuận) tạo `DATASET.md`.
  2. *Thiết lập Kiến trúc & Tokens:* Commit `3b4ad92` (02/11/2026 by quyen) tạo Design System baseline.
  3. *Tích hợp Model AI:* Commit `3a973e6` (03/11/2026 by thai1123) nạp Model Core ML nhận diện món ăn.
  4. *Cơ sở dữ liệu Món ăn Việt:* Commit `debf894` và `3e19d77` (03/11/2026 by Nguyễn Thanh Thuận) hoàn thành Food Database & Explorer với 36/36 tests passed.
  5. *Module Xác thực & Profile:* Nhánh `feature/phase01-authentication`, PR `#1` trên GitHub và hoàn thành hợp nhất qua Merge Commit `30c2758` (07/11/2026).
- **Kết quả nghiệm thu kỹ thuật Sprint 1:** Đạt 42/42 Unit & UI Tests passed tại mốc Checkpoint `8ec9c1d`.
- **Story Points hoàn thành quy đổi:** **23 SP** (WBS 1.1.1, WBS 1.2.1, WBS 1.2.2, WBS 1.3.1, WBS 1.3.2).

---

## 3. Báo Cáo Thực Tế Sprint 2 (Sprint 2 Review: Tuần 7 – Tuần 11)

- **Mục tiêu Sprint (Sprint Goal):** Nâng cấp trải nghiệm ghi nhận bữa ăn đa món (Multi-Item Meal Logging), quản lý khẩu phần ăn, lưu trữ SwiftData bền vững cho lượng nước uống và quản lý thư viện món ăn tự tạo (Custom Foods).
- **Bằng chứng kỹ thuật thực tế đối soát:**
  1. *Ghi nhận bữa ăn đa món & Khay ghi nhận:* Nhánh `feature/phase02-meal-logging`, Commit `0fc25ef` và Merge Commit `7fb01c3` (10/11/2026).
  2. *Quản lý Nước uống (Hydration Tracking):* Triển khai Entity `HydrationRecord` và các Use Cases `GetHydrationHistoryUseCase`, `DeleteHydrationUseCase` với SwiftData persistence.
  3. *Cơ sở dữ liệu Món ăn Tự tạo & Công thức:* Triển khai `CustomFoodRepository` và `RecipeRepository` với giao diện quản lý nguyên liệu và tính toán dinh dưỡng tự động.
  4. *Đóng góp độc lập của thành viên:* Commit `57b4628` (11/11/2026 by Nguyễn Thanh Thuận) bổ sung Profile nutrition goals; Commit `fc14067` và `9723e63` (11-13/11/2026 by thai1123) hoàn thiện module Settings và Design System.
- **Kết quả nghiệm thu kỹ thuật Sprint 2:** Bộ test suite mở rộng đạt 87 Unit Tests và 7 UI Tests.
- **Story Points hoàn thành quy đổi:** **21 SP** (WBS 1.3.3, WBS 1.3.4, WBS 1.3.5).

---

## 4. Mẫu Biên Bản Họp Cải Tiến Sprint Sẵn Sàng Trình Bảo Vệ (Ready-to-Fill Retrospective Template)

Dành cho buổi họp chính thức hoặc báo cáo trước Giảng viên hướng dẫn:

```markdown
### BIÊN BẢN HỌP CẢI TIẾN QUY TRÌNH (SPRINT RETROSPECTIVE RECORD)
- **Sprint:** [Sprint 1 / Sprint 2 / Sprint 3]
- **Thời gian tổ chức:** Ngày ... Tháng ... Năm 2026
- **Địa điểm:** Phòng Lab / Trực tuyến Google Meet (VKU)
- **Thành viên tham dự:** Trần Văn Quyền, Nguyễn Thanh Thuận, Thái.

#### 1. Điều Đã Hoạt Động Tốt (What went well):
- Kiến trúc Clean Architecture giúp phân chia công việc rất rõ ràng (Thuận làm Data, Thái làm UI/Model, Quyền làm Domain & Use Cases).
- Bộ kiểm thử tự động XCTest phát hiện sớm các lỗi tính toán calo khi kéo slider.

#### 2. Điều Cần Cải Thiện (What could be improved):
- Cần đẩy Pull Request lên remote GitHub thường xuyên hơn thay vì merge cục bộ tại máy cá nhân.
- Cần bật CI pipeline tự động kiểm tra trước khi hợp nhất mã nguồn.

#### 3. Kế Hoạch Hành Động (Action Items cho Sprint kế tiếp):
- [ ] Kích hoạt bảng GitHub Projects v2 để toàn đội cập nhật trạng thái thẻ hàng ngày.
- [ ] Bắt buộc quy trình 1 Reviewer phê duyệt PR trước khi merge vào main.
```

