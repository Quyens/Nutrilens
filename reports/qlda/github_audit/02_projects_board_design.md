# BẢN THIẾT KẾ BẢNG QUẢN TRỊ DỰ ÁN GITHUB PROJECTS (GITHUB PROJECTS BOARD DESIGN)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/github_audit/02_projects_board_design.md`  
**Ngày thiết kế:** 13 tháng 11 năm 2026  
**Trạng thái triển khai:** `PENDING USER AUTHORIZATION` (Chỉ tạo trên remote khi được người dùng cấp phép)  
**Nền tảng mục tiêu:** GitHub Projects v2 (Memex Table & Board Engine)

---

## 1. Thông Tin Định Danh Dự Án (Project Identity)

- **Tên Dự Án (Project Title):** `NutriLens V1.0 — Software Project Management`
- **Mô tả (Description):** Bảng quản trị Agile/Scrum theo dõi tiến độ phân rã WBS, quản lý Sprint backlog, kiểm định chất lượng QA/UAT và truy vết tính xác thực cho đồ án Quản trị dự án phần mềm — VKU.
- **Phạm vi hiển thị (Visibility):** `Public` (Để Giảng viên hướng dẫn TS. Nguyễn Thanh Tuấn có thể thẩm định trực tiếp qua trình duyệt).
- **Liên kết kho mã nguồn:** Liên kết trực tiếp với repository `https://github.com/Quyens/Nutrilens`.

---

## 2. Cấu Trúc Các Cột Trạng Thái (Status Columns / Workflow States)

Quy trình làm việc (Workflow) tuân thủ mô hình Scrum & Kanban tinh gọn gồm 5 trạng thái:

```text
┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│   BACKLOG   │──>│    READY    │──>│ IN PROGRESS │──>│  IN REVIEW  │──>│    DONE     │
│ (Tồn đọng)  │   │ (Sẵn sàng)  │   │(Đang làm)   │   │ (Kiểm duyệt)│   │ (Hoàn tất)  │
└─────────────┘   └─────────────┘   └─────────────┘   └─────────────┘   └─────────────┘
```

1. **Backlog (Sản phẩm Tồn đọng):** Chứa toàn bộ các yêu cầu người dùng, tính năng WBS và hạng mục công việc đã được phân rã nhưng chưa phân bổ vào Sprint hiện tại.
2. **Ready (Sẵn sàng triển khai):** Các công việc đã được làm rõ yêu cầu, định nghĩa tiêu chí chấp nhận (Acceptance Criteria), ước lượng Story Points và sẵn sàng để lập trình viên bắt đầu.
3. **In Progress (Đang thực hiện):** Công việc đang được một thành viên lập trình, viết mã nguồn hoặc xây dựng giao diện.
4. **In Review (Đang thẩm định & Kiểm thử):** Công việc đã hoàn thành mã nguồn, đã mở Pull Request và đang chờ:
   - Chạy kiểm thử tự động CI pipeline (build & test).
   - Kiểm duyệt chéo (Peer Review) từ ít nhất 01 thành viên khác.
5. **Done (Hoàn thành theo DoD):** Hạng mục chỉ được chuyển sang Done khi thỏa mãn trọn vẹn **Definition of Done (DoD)**:
   - Đã merge vào nhánh chính qua PR được phê duyệt.
   - 100% kiểm thử Unit/UI Test liên quan pass.
   - Tài liệu kỹ thuật và truy vết WBS đã cập nhật.
   - Đối với tính năng cốt lõi: Đã có biên bản kiểm thử UAT xác nhận.

---

## 3. Hệ Thống Trường Tùy Chỉnh (Custom Fields Specification)

Để đáp ứng toàn diện tiêu chí đánh giá môn học của Thầy Tuấn, Bảng được cấu hình 8 trường dữ liệu chuyên sâu:

| Tên trường (Field Name) | Loại dữ liệu (Type) | Tùy chọn / Quy chuẩn (Options / Format) | Mục đích quản trị |
| :--- | :--- | :--- | :--- |
| **Status** | Single Select | `Backlog`, `Ready`, `In Progress`, `In Review`, `Done` | Theo dõi trạng thái tiến trình |
| **Priority** | Single Select | `🔴 P0 - Critical`, `🟠 P1 - High`, `🟡 P2 - Medium`, `⚪ P3 - Low` | Phân cấp độ ưu tiên xử lý |
| **Sprint** | Iteration | `Sprint 0: Project Setup`<br>`Sprint 1: Core AI & Food DB`<br>`Sprint 2: Multi-Item & Plans`<br>`Sprint 3: Smart AI & Barcode`<br>`Sprint 4: Hardening & UAT` | Phân đoạn chu kỳ Scrum |
| **Story Points** | Number | Dãy Fibonacci: `1, 2, 3, 5, 8, 13` | Định lượng kích thước công việc |
| **WBS Code** | Text | e.g., `WBS 1.1.1`, `WBS 1.3.1`, `WBS 1.3.7` | Ánh xạ trực tiếp Từ điển WBS |
| **Assignee** | Assignee (User) | `@Quyens`, `@thuan5587`, `@Thai1123` | Phân công trách nhiệm cá nhân |
| **Target Date** | Date | `YYYY-MM-DD` | Kiểm soát tiến độ so với CPM |
| **Acceptance Status** | Single Select | `Pending`, `Auto-Verified (149 Tests)`, `Human-UAT-Passed` | Bằng chứng nghiệm thu thực tế |

---

## 4. Các Chế Độ Xem Chuyên Biệt (Custom Board Views)

### 4.1. View 1: "Kanban Board — Tổng quan Tiến độ"
- **Kiểu hiển thị:** Board (bố trí theo các cột `Status`).
- **Phân nhóm phụ:** Swimlanes theo `Priority` (P0, P1, P2).
- **Bộ lọc:** `is:open` (để theo dõi các việc đang chạy) hoặc hiển thị toàn bộ.

### 4.2. View 2: "Sprint Planning & Burndown"
- **Kiểu hiển thị:** Board được nhóm theo trường `Sprint`.
- **Thống kê:** Tự động tính tổng `Story Points` của từng cột Sprint để so sánh dung lượng (Capacity) với vận tốc thực tế (Velocity ~21.6 SP/Sprint).

### 4.3. View 3: "WBS Traceability Table"
- **Kiểu hiển thị:** Table View phân cấp.
- **Sắp xếp:** Nhóm theo mã `WBS Code` từ 1.1 đến 1.5.
- **Cột hiển thị:** Issue Title, Assignee, Status, Story Points, Acceptance Status, PR/Commit Ref.

### 4.4. View 4: "QA & UAT Quality Gate"
- **Kiểu hiển thị:** Table View lọc theo `Acceptance Status`.
- **Mục đích:** Minh chứng cho Giảng viên thấy 100% các tính năng nghiệp vụ đã được xác nhận qua tự động hóa hoặc thử nghiệm người dùng thật.

---

## 5. Phương Pháp Theo Dõi Biểu Đồ Burndown (Burndown Tracking Approach)

Dự án áp dụng phương pháp kết hợp:
1. **GitHub Insights Burndown:** Sử dụng tính năng Insights tích hợp sẵn trong GitHub Projects v2 để biểu diễn lượng Story Points giảm dần qua từng ngày của Sprint.
2. **Bảng Đối soát Burndown Dự phòng:** Lưu trữ trong tệp `reports/qlda/05_15_week_schedule_and_cpm.md` và `QLDA_EVIDENCE_PACKAGE/` nhằm bảo đảm dữ liệu vẫn trình diễn được đầy đủ ngay cả khi thiết bị báo cáo tại buổi bảo vệ không có kết nối Internet.

---

## 6. Lệnh Triển Khai Tự Động Khi Được Cấp Phép (Activation Plan)

Khi Trưởng nhóm phê duyệt thực hiện ghi lên remote, việc khởi tạo Projects Board có thể thực hiện thông qua giao diện Web GitHub hoặc chạy đoạn mã kích hoạt:
```bash
# Lệnh tham khảo khởi tạo GitHub Project v2 (PENDING AUTHORIZATION)
gh project create --owner Quyens --title "NutriLens V1.0 — Software Project Management"
```
*(Hiện tại không thực hiện lệnh nào trên remote để bảo đảm an toàn dữ liệu tuyệt đối).*

