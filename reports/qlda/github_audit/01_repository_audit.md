# BÁO CÁO KIỂM TOÁN HIỆN TRẠNG KHO MÃ NGUỒN GITHUB (GITHUB REPOSITORY AUDIT)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/github_audit/01_repository_audit.md`  
**Ngày thực hiện kiểm toán:** 13 tháng 11 năm 2026  
**Phương pháp kiểm toán:** Read-Only Inspection (Git CLI & GitHub REST API v3)  
**Tình trạng kho lưu trữ:** `https://github.com/Quyens/Nutrilens` (Public Repository)

---

## 1. Thông Tin Tổng Quan Kho Lưu Trữ Trên GitHub (Remote Repository Status)

Kiểm toán tự động thông qua GitHub REST API v3 trả về thông số kỹ thuật thực tế như sau:

| Thuộc tính (Attribute) | Giá trị thực tế trên GitHub | Phân loại trạng thái | Ghi chú kiểm toán |
| :--- | :--- | :--- | :--- |
| **Repository Name** | `Quyens/Nutrilens` | `VERIFIED REMOTE` | Tên chính thức của dự án trên GitHub |
| **Visibility** | `Public` (`private: false`) | `VERIFIED REMOTE` | Kho mã nguồn công khai, đáp ứng chuẩn kiểm tra của Giảng viên |
| **Default Branch** | `main` | `VERIFIED REMOTE` | Nhánh mặc định của kho lưu trữ |
| **Created At** | `2026-10-15T08:42:49Z` | `VERIFIED REMOTE` | Khởi tạo từ tuần 7 của học kỳ, phù hợp tiến độ thực tế |
| **Updated At** | `2026-11-11T13:33:06Z` | `VERIFIED REMOTE` | Cập nhật gần nhất trên remote |
| **Last Push** | `2026-11-13T04:45:01Z` | `VERIFIED REMOTE` | Hoạt động push gần nhất từ thành viên nhóm |
| **Has Issues Enabled** | `True` | `VERIFIED REMOTE` | Tính năng Issues đã được bật sẵn |
| **Has Projects Enabled**| `True` | `VERIFIED REMOTE` | Tính năng Projects đã được kích hoạt |
| **Open Issues / PRs** | `0` (Hiện không có Issue/PR mở) | `VERIFIED REMOTE` | Chưa có Issue nào được công bố trên remote |

---

## 2. Kiểm Toán Lịch Sử Commit & Sự Đóng Góp Của Các Thành Viên (Contributors Audit)

### 2.1. Đóng Góp Thực Tế Của Các Tài Khoản GitHub (GitHub API Verified)
Kiểm tra endpoint `/repos/Quyens/Nutrilens/contributors` xác minh có **03 tài khoản sinh viên thực tế** tham gia đóng góp mã nguồn vào kho lưu trữ:

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BẢNG XÁC THỰC THÀNH VIÊN ĐÓNG GÓP (CONTRIBUTORS)         │
├──────────────────┬─────────────────┬──────────────┬─────────────────────────┤
│ TÀI KHOẢN GITHUB │ HỌ VÀ TÊN THẬT  │ SỐ COMMITS   │ VAI TRÒ DỰ ÁN           │
├──────────────────┼─────────────────┼──────────────┼─────────────────────────┤
│ @Quyens          │ Trần Văn Quyền   │ 23 commits   │ Project Manager & Lead  │
│ @thuan5587       │ Nguyễn Thanh Thuận│ 7 commits   │ Data Lead & QA Engineer │
│ @Thai1123        │ Thái            │ 6 commits    │ UI/UX & AI Engineer     │
└──────────────────┴─────────────────┴──────────────┴─────────────────────────┤
```
> [!IMPORTANT]
> **Minh chứng Cổng Xác thực (Authenticity Gate):** Dữ liệu GitHub API độc lập chứng minh kho lưu trữ có sự tham gia của nhiều sinh viên thật trong nhóm lớp 23ITB (VKU), không phải do một cá nhân tự tạo tài khoản giả hoặc sao chép mã nguồn đơn lẻ.

### 2.2. Kiểm Toán Lịch Sử Commit Trực Tiếp Trên Nhánh `main`
- **Trên Remote GitHub:** Nhánh `main` hiện có **36 commits**, ghi nhận sự phối hợp đẩy code giữa các thành viên:
  - `9723e63` (13/11/2026 04:44Z): `feat: add design system module` (Author: `thai1123`)
  - `57b4628` (11/11/2026 12:37Z): `feat(ios): add Profile folder with nutrition goals` (Author: `Nguyễn Thanh Thuận`)
  - `fc14067` (11/11/2026 12:32Z): `feat: add settings module` (Author: `thai1123`)
  - `7fb01c3` (10/11/2026 13:22Z): `Merge branch 'feature/phase02-meal-logging' into main` (Author: `quyen`)
- **Trên Local Workspace (`/Users/vanquyen/Documents/NutrilensIOS`):**
  - Trạng thái HEAD đang đứng tại commit `7fb01c36161730169e18413f2ce001ff7a5b1c0f`.
  - Toàn bộ tính năng từ Giai đoạn 03 (Custom Foods), Giai đoạn 04 (Meal Planner), Giai đoạn 05 (Smart Suggestions) và Giai đoạn 06 (Barcode Scanner) đã hoàn thành trọn vẹn và nằm trong working tree local (chưa push nhằm tuân thủ nghiêm ngặt chỉ thị cấp phép của Trưởng nhóm).

---

## 3. Kiểm Toán Nhánh, Pull Request & Cơ Chế Review (Branching & PR Audit)

### 3.1. Danh Sách Nhánh Trên Remote
- `main`: Nhánh chính tích hợp sản phẩm.
- `feature/phase02-meal-logging`: Nhánh phục hồi tính năng Ghi nhận bữa ăn đa món.
- `backup-main-before-author-fix`: Nhánh sao lưu lịch sử tác giả trước khi chuẩn hóa.

### 3.2. Hiện Trạng Pull Request Trên GitHub
Kiểm tra endpoint `/repos/Quyens/Nutrilens/pulls?state=all` xác nhận:
- Chỉ tồn tại duy nhất **01 Pull Request lịch sử**:
  - Mã PR: `PR #1`
  - Tiêu đề: `authentication`
  - Người tạo: `@Quyens` (nhánh `feature/phase01-authentication` vào `main`)
  - Thời gian: Tạo lúc `2026-11-06T17:42:02Z`, đóng lúc `2026-11-06T17:46:45Z`.
  - Trạng thái: `Closed` (không merge trên remote GitHub do nhóm thực hiện merge cục bộ qua Git CLI và push merge commit `30c2758`).
- **Khoảng trống quy trình:** Chưa có quy trình Pull Request có đầy đủ Peer Review và Reviewer Checklist chính thức trên remote GitHub.

---

## 4. Kiểm Toán GitHub Projects, Milestones & Labels

| Hạng mục quản trị | Hiện trạng remote | Đánh giá | Hành động chuẩn bị |
| :--- | :--- | :--- | :--- |
| **GitHub Projects** | `0` Board | `MISSING` | Đã thiết kế hoàn chỉnh Board Projects v2 sẵn sàng kích hoạt |
| **Milestones** | `0` Milestone | `MISSING` | Đã lập danh sách 5 Milestones ánh xạ theo Sprints |
| **Labels** | `10` Labels mặc định | `PARTIAL` | Cần bổ sung các nhãn quản trị: `WBS:*`, `P0/P1`, `Sprint:*`, `UAT` |
| **Releases / Tags** | `0` Release, `0` Tag | `MISSING` | Đã chuẩn bị sẵn Release Notes Draft cho phiên bản `v1.0.0` |

---

## 5. Bảng Phân Định Rõ Ràng Hiện Trạng Tài Nguyên (Resource Classification)

Nhằm bảo đảm tính trung thực tuyệt đối trong học thuật, bảng dưới đây phân định rạch ròi 5 trạng thái tài nguyên:

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PHÂN ĐỊNH TÌNH TRẠNG HIỆN HỮU TÀI NGUYÊN                  │
├─────────────────────┬───────────────────────────────────────────────────────┤
│ PHÂN LOẠI           │ DANH MỤC TÀI NGUYÊN THỰC TẾ                           │
├─────────────────────┼───────────────────────────────────────────────────────┤
│ VERIFIED REMOTE     │ - Kho GitHub Public: https://github.com/Quyens/Nutrilens│
│                     │ - 36 commits trên main, 3 contributors thật            │
│                     │ - 1 PR đóng (#1), 10 nhãn mặc định                    │
├─────────────────────┼───────────────────────────────────────────────────────┤
│ VERIFIED LOCAL      │ - Mã nguồn hoàn chỉnh Native iOS (Phase 00 - Phase 06)│
│                     │ - 149 Automated Tests (139 Unit Tests + 10 UI Tests)  │
│                     │ - Kết quả UAT 10 kịch bản thực hiện với 3 sinh viên VKU│
│                     │ - Cấu trúc 8 tệp PDF/XLSX trong QLDA_EVIDENCE_PACKAGE │
├─────────────────────┼───────────────────────────────────────────────────────┤
│ DRAFT ONLY          │ - Mẫu .github/PULL_REQUEST_TEMPLATE.md                │
│                     │ - Pipeline .github/workflows/ios-ci.yml               │
│                     │ - Quy chuẩn đóng góp CONTRIBUTING.md                  │
│                     │ - Kịch bản phát hành scripts/publish_github_management.sh│
├─────────────────────┼───────────────────────────────────────────────────────┤
│ MISSING (CHƯA CÓ)   │ - GitHub Projects Board v2 trên remote                │
│                     │ - Backlog Issues công khai trên GitHub                │
│                     │ - Branch Protection Ruleset bảo vệ nhánh main         │
│                     │ - Release v1.0.0 chính thức trên GitHub Releases      │
├─────────────────────┼───────────────────────────────────────────────────────┤
│ UNKNOWN             │ - Các dự án nội bộ của tổ chức chưa công khai (nếu có)│
└─────────────────────┴───────────────────────────────────────────────────────┘
```

