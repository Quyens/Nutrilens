# BẢNG HƯỚNG DẪN KÍCH HOẠT HỆ THỐNG GITHUB (GITHUB IMPLEMENTATION CHECKLIST)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/github_audit/09_github_implementation_checklist.md`  
**Ngày lập hướng dẫn:** 13 tháng 11 năm 2026  
**Mục tiêu:** Hướng dẫn chi tiết từng bước hành động dành riêng cho Trưởng nhóm (@Quyens) để kích hoạt toàn bộ hệ thống quản trị trên GitHub một cách an toàn và đúng quy chuẩn môn học.

---

## 1. Tổng Quan Tiến Trình Chuyển Đổi (Workflow Roadmap)

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                       LỘ TRÌNH KÍCH HOẠT HỆ THỐNG GITHUB                     │
├─────────────────────────────────────────────────────────────────────────────┤
│ BƯỚC 1: Rà soát & Phê duyệt tài liệu cục bộ (Đã hoàn tất 100%)              │
│    │                                                                        │
│ BƯỚC 2: Commit & Đẩy mã nguồn các Phase 03 - 06 lên GitHub (Chờ lệnh)       │
│    │                                                                        │
│ BƯỚC 3: Xuất bản Danh mục 16 GitHub Issues & Cấu hình Projects Board v2     │
│    │                                                                        │
│ BƯỚC 4: Thiết lập Branch Protection Rules bảo vệ nhánh main                 │
│    │                                                                        │
│ BƯỚC 5: Kích hoạt Pipeline CI/CD trên GitHub Actions                        │
│    │                                                                        │
│ BƯỚC 6: Tạo Git Tag & Đóng gói Release v1.0.0 chính thức                    │
│    │                                                                        │
│ BƯỚC 7: Nộp bài, Trình Hiến chương xin chữ ký và Bảo vệ trước Hội đồng      │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Chi Tiết Từng Bước Thực Hiện Dành Cho Trưởng Nhóm

### Bước 1: Rà Soát Hồ Sơ Quản Trị Tại Thư Mục Local
- Kiểm tra toàn bộ 14 tài liệu trong `reports/qlda/` và 9 tài liệu trong `reports/qlda/github_audit/`.
- Kiểm tra gói 8 tệp tài liệu số hóa trong `QLDA_EVIDENCE_PACKAGE/`.
- **Trạng thái:** [x] ĐÃ SẴN SÀNG 100%.

---

### Bước 2: Đẩy Mã Nguồn Các Tính Năng Còn Lại Lên GitHub
*Thực hiện trên Terminal của Trưởng nhóm:*
```bash
# 1. Tạo nhánh cho Phase 06 (Barcode Scanner) và commit
git checkout -b feature/phase06-barcode-scanner
git add NutriLens NutriLensTests NutriLensUITests reports/qlda .github CONTRIBUTING.md scripts
git commit -m "feat(phase06): integrate AVFoundation barcode scanner, packaged foods and course audit"
git push origin feature/phase06-barcode-scanner

# 2. Tạo Pull Request trên GitHub hoặc Merge vào main
git checkout main
git merge feature/phase06-barcode-scanner
git push origin main
```

---

### Bước 3: Xuất Bản Danh Mục Issues & Projects Board
Nhóm có thể lựa chọn 1 trong 2 cách sau:

#### Cách 3A: Chạy Script Tự Động An Toàn (Khuyên dùng)
Kịch bản an toàn đã được soạn sẵn tại `scripts/publish_github_management.sh`. Kịch bản này có bước hỏi xác nhận tương tác (`yes/no`) trước khi gọi GitHub API:
```bash
chmod +x scripts/publish_github_management.sh
./scripts/publish_github_management.sh
```

#### Cách 3B: Tạo Thủ Công Qua Giao Diện Web GitHub
1. Truy cập `https://github.com/Quyens/Nutrilens/projects`.
2. Nhấn nút **New project** -> Chọn mẫu **Board** hoặc **Table**.
3. Đặt tên: `NutriLens V1.0 — Software Project Management`.
4. Tạo 5 cột: `Backlog`, `Ready`, `In Progress`, `In Review`, `Done`.
5. Tạo các trường Custom Fields theo đặc tả tại tài liệu `02_projects_board_design.md`.
6. Sao chép nội dung từ tài liệu `03_issue_backlog_ready_to_publish.md` để tạo 16 Issues.

---

### Bước 4: Thiết Lập Branch Protection Cho Nhánh `main`
1. Vào `https://github.com/Quyens/Nutrilens/settings/branches`.
2. Nhấn **Add branch protection rule**.
3. Tại ô **Branch name pattern**, nhập: `main`.
4. Tích chọn các mục sau:
   - [x] **Require a pull request before merging** (Require approvals: `1`).
   - [x] **Require status checks to pass before merging** (Chọn `build-and-test`).
   - [x] **Require conversation resolution before merging**.
   - [x] **Do not allow force pushes**.
   - [x] **Do not allow deletions**.
5. Nhấn **Save changes** để hoàn tất.

---

### Bước 5: Kích Hoạt GitHub Actions CI Pipeline
- Khi tệp `.github/workflows/ios-ci.yml` được đẩy lên nhánh `main`, truy cập tab **Actions** trên GitHub: `https://github.com/Quyens/Nutrilens/actions`.
- Quan sát luồng chạy `NutriLens iOS CI Pipeline`.
- Khi pipeline báo tích xanh (Green Checkmark), tải về tệp artifact `nutrilens-build-and-test-logs` để lưu trữ thêm một lớp bằng chứng.

---

### Bước 6: Đóng Gói & Xuất Bản Phiên Bản Release `v1.0.0`
1. Truy cập `https://github.com/Quyens/Nutrilens/releases/new`.
2. Chọn tag: Nhập `v1.0.0` -> Nhấn **Create new tag on publish**.
3. Target: `main`.
4. Release title: `NutriLens V1.0.0 — Fresh Botanical Production Release`.
5. Dán nội dung Release Notes từ tài liệu `07_release_readiness.md`.
6. Nhấn **Publish release**.

---

### Bước 7: Hoàn Tất Bằng Chứng Con Người & Bảo Vệ Môn Học
1. In tệp `QLDA_EVIDENCE_PACKAGE/02_Project_Charter_Draft.pdf` và mang theo tại buổi bảo vệ để xin chữ ký của **TS. Nguyễn Thanh Tuấn**.
2. Mang theo máy Mac hoặc iPhone đã cài đặt sẵn NutriLens để hội đồng kiểm tra thực tế (quét món ăn và quét mã vạch).
3. Sử dụng slide tóm tắt trong `QLDA_EVIDENCE_PACKAGE/08_Presentation_Slide_Deck.pdf` cho bài thuyết trình 15-20 phút.

