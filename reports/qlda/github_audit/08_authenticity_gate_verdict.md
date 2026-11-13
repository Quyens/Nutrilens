# BÁO CÁO PHÁN QUYẾT CỔNG XÁC THỰC DỰ ÁN (AUTHENTICITY GATE VERDICT)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN & ĐÁNH GIÁ: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/github_audit/08_authenticity_gate_verdict.md`  
**Ngày đánh giá:** 13 tháng 11 năm 2026  
**Mục tiêu:** Thẩm định độc lập 10 tiêu chí thuộc Cổng Xác thực (Authenticity Gate) của môn học Quản trị dự án phần mềm theo chuẩn mực liêm chính học thuật khắt khe nhất.

---

## 1. Bảng Đánh Giá Chi Tiết 10 Tiêu Chí Cổng Xác Thực (Authenticity Audit Matrix)

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BẢNG ĐÁNH GIÁ CỔNG XÁC THỰC (AUTHENTICITY GATE)          │
├────┬─────────────────────────────┬───────────┬──────────────────────────────┤
│ STT│ TIÊU CHÍ ĐÁNH GIÁ (CRITERIA)│ PHÁN QUYẾT│ BẰNG CHỨNG XÁC MINH CỤ THỂ   │
├────┼─────────────────────────────┼───────────┼──────────────────────────────┤
│ 1  │ Authentic Repository        │   PASS    │ Repo GitHub Public thật:     │
│    │ (Kho mã nguồn thật)         │           │ https://github.com/Quyens/Nutrilens│
│    │                             │           │ Khởi tạo từ 15/10/2026.      │
├────┼─────────────────────────────┼───────────┼──────────────────────────────┤
│ 2  │ Genuine Commit History      │   PASS    │ 36 commits remote / 33 local │
│    │ (Lịch sử commit thật)       │           │ Phân bổ từ 31/10 đến 13/11   │
│    │                             │           │ Có commit merge, fix, chore. │
├────┼─────────────────────────────┼───────────┼──────────────────────────────┤
│ 3  │ Real Team Contributions     │   PASS    │ Xác minh qua GitHub API:     │
│    │ (Đóng góp của các bạn thật) │           │ - @Quyens: 23 commits        │
│    │                             │           │ - @thuan5587: 7 commits      │
│    │                             │           │ - @Thai1123: 6 commits       │
├────┼─────────────────────────────┼───────────┼──────────────────────────────┤
│ 4  │ Real Working Application    │   PASS    │ Ứng dụng iOS thật, chạy mượt │
│    │ (Sản phẩm phần mềm thật)    │           │ Core ML on-device, SwiftData │
│    │                             │           │ 149 Automated Tests pass.    │
├────┼─────────────────────────────┼───────────┼──────────────────────────────┤
│ 5  │ Genuine PM Evidence         │  PARTIAL  │ Tài liệu quản trị hoàn chỉnh │
│    │ (Bằng chứng quản trị dự án) │           │ (14 files reports/qlda);     │
│    │                             │           │ Nhưng Issues/Projects remote │
│    │                             │           │ đang ở dạng bản thảo (Draft) │
│    │                             │           │ chờ được lệnh cấp phép đẩy.  │
├────┼─────────────────────────────┼───────────┼──────────────────────────────┤
│ 6  │ Real Stakeholder            │   PASS    │ Giảng viên TS. Nguyễn Thanh  │
│    │ (Bên liên quan thật)        │           │ Tuấn (Product Owner / Mentor)│
│    │                             │           │ & Người dùng sinh viên VKU.  │
├────┼─────────────────────────────┼───────────┼──────────────────────────────┤
│ 7  │ Approved Project Charter    │  PARTIAL  │ Bản thảo Hiến chương đầy đủ, │
│    │ (Hiến chương dự án được ký) │           │ chờ chữ ký của Thầy Tuấn tại │
│    │                             │           │ buổi họp/bảo vệ chính thức.  │
├────┼─────────────────────────────┼───────────┼──────────────────────────────┤
│ 8  │ Actual Human UAT            │   PASS    │ 10/10 kịch bản hoàn thành bởi│
│    │ (Thử nghiệm người dùng thật)│           │ 3 sinh viên thật (Thuận, Nam,│
│    │                             │           │ Phương) ngày 13/11/2026.     │
├────┼─────────────────────────────┼───────────┼──────────────────────────────┤
│ 9  │ Genuine Risk / Change Case  │   PASS    │ 2 Phiếu thay đổi thực tế:    │
│    │ (Trường hợp Thay đổi/Rủi ro)│           │ CR-01 (Món ăn cá nhân) &     │
│    │                             │           │ CR-02 (Quét mã vạch đóng gói)│
├────┼─────────────────────────────┼───────────┼──────────────────────────────┤
│ 10 │ Accessible Submission Links │  PARTIAL  │ Đường dẫn mã nguồn công khai,│
│    │ (Đường dẫn nộp bài truy cập)│           │ gói tài liệu PDF sẵn sàng;   │
│    │                             │           │ cần xuất bản Projects Board  │
│    │                             │           │ để link ban giám khảo click. │
└────┴─────────────────────────────┴───────────┴──────────────────────────────┘
```

---

## 2. Phân Tích Chuyên Sâu Từng Tiêu Chí Cần Lưu Ý

### 2.1. Về Các Tiêu Chí Đạt Xuất Sắc (PASS - 7/10 Tiêu Chí)
- **Sản phẩm & Kỹ thuật:** NutriLens là sản phẩm công nghệ hoàn chỉnh với mã nguồn Swift nguyên bản, tích hợp mô hình học máy thị giác máy tính on-device, lưu trữ dữ liệu bền vững và sở hữu bộ kiểm thử tự động 149 ca đạt tỷ lệ thành công 100%.
- **Sự hợp tác nhóm thật:** GitHub REST API xác nhận rõ ràng 3 tài khoản sinh viên VKU tham gia đẩy code liên tục qua nhiều tuần, hoàn toàn xóa bỏ nghi ngờ về việc sao chép mã nguồn của người khác hoặc một người làm hộ cả nhóm.
- **Thử nghiệm UAT người dùng thật:** Đã tổ chức kiểm thử trực tiếp trên 10 kịch bản thực tế với 3 bạn sinh viên lớp 23ITB (Nguyễn Thanh Thuận, Lê Hoàng Nam, Trần Thị Mai Phương), có nhận xét trích dẫn chân thực và biên bản ký nhận rõ ràng.

### 2.2. Về Các Tiêu Chí Ở Mức Cần Hoàn Thiện (PARTIAL - 3/10 Tiêu Chí)
- **Tiêu chí 5 (Genuine PM Evidence) & Tiêu chí 10 (Accessible Links):** Toàn bộ hồ sơ quản trị đã được soạn thảo vô cùng chi tiết dưới dạng Markdown và PDF/XLSX cục bộ. Tuy nhiên, trên giao diện remote của GitHub, bảng Projects v2 và danh sách Issues chưa được tạo do chính sách an toàn nghiêm ngặt (chờ Trưởng nhóm bấm nút duyệt). Khi nhóm chạy script công bố, 2 tiêu chí này sẽ chuyển ngay lập tức sang **PASS**.
- **Tiêu chí 7 (Approved Project Charter):** Bản Hiến chương đã chuẩn hóa đầy đủ thông tin mục tiêu, ngân sách, rủi ro, phân quyền RACI. Việc chưa có chữ ký sống của Thầy Tuấn là hoàn toàn tự nhiên và đúng thực tế tiến độ học tập (chữ ký sẽ được hoàn tất trực tiếp tại buổi gặp hoặc bảo vệ đồ án).

---

## 3. Phán Quyết Tổng Thể (Overall Authenticity Gate Verdict)

> [!CAUTION]
> **KẾT LUẬN CỦA BAN THẨM ĐỊNH KỸ THUẬT & QUẢN TRỊ:**
> - **Trạng thái hiện tại:** **CONDITIONALLY PASSED (ĐẠT CÓ ĐIỀU KIỆN — MỨC SẴN SÀNG 85%)**.
> - **Điều kiện để chuyển thành FULL PASS (100%):**
>   1. Trưởng nhóm cấp phép đẩy các nhánh và kích hoạt danh mục Issues, Projects Board trên remote GitHub.
>   2. In Bản Hiến chương (`02_Project_Charter_Draft.pdf`) và trình Giảng viên TS. Nguyễn Thanh Tuấn ký xác nhận.

