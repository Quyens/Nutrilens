# ĐỀ CƯƠNG VÀ NỘI DUNG SLIDE THUYẾT TRÌNH BẢO VỆ ĐỒ ÁN (10 SLIDES)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/12_presentation_slide_deck_outline.md`  
**Ngày lập:** 13 tháng 11 năm 2026  
**Khung thời lượng bảo vệ:** Chuẩn 16 Phút (6 phút Thuyết trình + 5 phút Live Demo + 5 phút Q&A)  
**Phân loại:** FINAL PRESENTATION DEFENSE DECK  

---

## SLIDE 1: TRANG TIÊU ĐỀ & ĐỊNH DANH NHÓM (TITLE & TEAM IDENTITY)
* **Tiêu đề lớn:** NUTRILENS V1.0 — Ứng Dụng iOS Nhận Diện Món Ăn Việt & Quản Lý Dinh Dưỡng On-Device
* **Phụ đề:** Đồ án Môn học Quản trị Dự án Phần mềm — Học kỳ I, Năm học 2026-2027
* **Đơn vị:** Trường Đại học Công nghệ Thông tin & Truyền thông Việt - Hàn (VKU) — Đại học Đà Nẵng
* **Giảng viên hướng dẫn & Đánh giá:** TS. NGUYỄN THANH TUẤN
* **Nhóm sinh viên thực hiện:**
  - Nguyễn Thanh Thuận (Lớp 23ITB) — Technical Lead & Food Data Specialist
  - quyen — Project Manager / Scrum Master & iOS Architect
  - thai1123 — AI & Core ML Integration Engineer
* **Thời lượng trình bày:** 0:30 (Giây 0 – Giây 30)

---

## SLIDE 2: BÀI TOÁN THỰC TIỄN & ĐỀ XUẤT GIÁ TRỊ (PROBLEM & BUSINESS CASE)
* **3 Rào cản lớn của người dùng Việt:**
  1. *Thiếu dữ liệu ẩm thực Việt:* App ngoại (MyFitnessPal, Yazio) không có công thức món Việt chuẩn xác.
  2. *Quy trình nhập liệu thủ công rườm rà:* Cân đo từng gam khiến >68% người dùng từ bỏ sau 7 ngày.
  3. *Nguy cơ lộ lọt quyền riêng tư:* Hầu hết ứng dụng gửi ảnh bữa ăn lên cloud server ngoại vi.
* **Đề xuất Giá trị Đột phá của NutriLens:**
  - Nhận diện 30 món ăn Việt Nam on-device bằng Apple Core ML trong dưới 200ms không cần Internet.
  - Cơ sở dữ liệu 35+ món chuẩn hóa theo Viện Dinh Dưỡng Quốc Gia.
  - Bảo mật dữ liệu tuyệt đối (Local-First với Apple SwiftData & Keychain).
* **Thời lượng trình bày:** 0:45 (Giây 30 – Phút 1:15)

---

## SLIDE 3: KIẾN TRÚC HỆ THỐNG & PHÂN RÃ CÔNG VIỆC (ARCHITECTURE & WBS)
* **Kiến trúc MVVM + Clean Architecture:**
  - *Presentation Layer:* 100% SwiftUI khai báo, Design System Fresh Botanical.
  - *Domain Layer:* Thực thể và Use Case thuần túy độc lập với UI/Database.
  - *Data Layer:* Apple SwiftData, Apple Keychain, Core ML Neural Engine.
* **Cơ cấu Phân rã Công việc (WBS 100% Rule):**
  - 6 Khối công việc lớn (Khởi tạo, Kiến trúc, Tính năng cốt lõi, Quản trị dữ liệu, QA Testing, Đóng dự án).
  - 23 Gói công việc WBS chi tiết với đầy đủ Acceptance Criteria và định lượng Story Points.
* **Thời lượng trình bày:** 0:45 (Phút 1:15 – Phút 2:00)

---

## SLIDE 4: TIẾN ĐỘ 15 TUẦN & PHÂN TÍCH ĐƯỜNG GĂNG (SCHEDULE & CPM)
* **Khung thời gian 15 tuần học kỳ VKU chia 6 Sprints linh hoạt.**
* **Đường Găng CPM (Critical Path):**
  $$\mathbf{A \rightarrow B \rightarrow C \rightarrow F \rightarrow G \rightarrow I \rightarrow J \rightarrow K \rightarrow L \rightarrow M \rightarrow N} = \mathbf{15.0 \text{ Tuần}}$$
* **Kiểm soát độ trễ:** Các công việc như Huấn luyện AI (Slack = 0.5w) và CSDL dinh dưỡng (Slack = 2.0w) được điều phối linh hoạt, đảm bảo toàn bộ tiến độ dự án không bao giờ bị trễ hạn.
* **Thời lượng trình bày:** 0:45 (Phút 2:00 – Phút 2:45)

---

## SLIDE 5: VẬN TỐC NHÓM & QUẢN TRỊ AGILE (VELOCITY & METRICS)
* **Chỉ số Vận tốc (Sprint Velocity — Mô hình Tái thiết lập):**
  - Tổng điểm bàn giao: 123 / 126 Story Points (Đạt 97.6% kế hoạch mô phỏng).
  - Vận tốc trung bình 5 Sprint kỹ thuật: **21.6 SP / Sprint** (~10.8 SP/tuần cho nhóm 3–4 sinh viên).
  - Vận tốc toàn bộ 6 Sprint (bao gồm nghiệm thu): **20.5 SP / Sprint**.
* **Năng suất Git & Bằng chứng thực tế:**
  - 33 commits trên nhánh `main`, 3 nhánh tính năng lịch sử.
  - Thiết kế sẵn quy trình GitHub Projects Kanban (Backlog, Ready, In Progress, In Review, Done) và Pull Request Template chuẩn hóa.
* **Thời lượng trình bày:** 0:45 (Phút 2:45 – Phút 3:30)

---

## SLIDE 6: QUẢN TRỊ RỦI RO & BÀI HỌC SỰ CỐ THỰC TẾ (RISK MANAGEMENT & CASE STUDY)
* **Case Study Thực tế: Sự cố mất mát mã nguồn đầu tháng 11/2026:**
  - *Tình huống:* Thao tác nhầm làm mất code chưa commit, số bài test giảm từ 154 xuống 42 tests.
  - *Ứng phó rủi ro:* Kích hoạt bản sao lưu zip ngày 03/11, đóng băng nhánh `checkpoint/phase00-baseline` và phục hồi tuần tự từng pha kèm báo cáo kiểm định riêng.
  - *Kết quả:* Khôi phục 100% tính năng, nâng số bài test lên **149 tests pass tuyệt đối**.
* **Kiểm soát Thay đổi (Scope Change Control):**
  - CR-01: Bổ sung Quét mã vạch thực phẩm đóng gói bán lẻ (Phase 06) — *Trạng thái: PENDING APPROVAL*.
  - CR-02: Tinh gọn bố cục Trang chủ theo feedback người dùng — *Trạng thái: PENDING APPROVAL*.
* **Thời lượng trình bày:** 1:00 (Phút 3:30 – Phút 4:30)

---

## SLIDE 7: CHẤT LƯỢNG, KIỂM THỬ & TIÊU CHUẨN HOÀN THÀNH (QA & DEFINITION OF DONE)
* **149 / 149 Automated Tests Đạt Tuyệt Đối (100% Pass Rate trên iPhone 17 Simulator):**
  - 139 Unit Tests (UseCase, Domain, Modulo-10 Checksum, SwiftData).
  - 10 UI Automated Tests (XCUITest kiểm tra luồng người dùng thực tế).
* **Đường ống Tích hợp Liên tục (CI/CD Pipeline):**
  - Kịch bản GitHub Actions tự động hóa build sạch và test sạch trên runner macOS Apple Silicon.
* **Thời lượng trình bày:** 0:45 (Phút 4:30 – Phút 5:15)

---

## SLIDE 8: THỬ NGHIỆM CHẤP NHẬN NGƯỜI DÙNG & TRACEABILITY (UAT & TRACEABILITY)
* **Bộ 10 Kịch bản Kiểm thử Chấp nhận (UAT Scenarios):**
  - Xác thực tự động: 10/10 kịch bản đạt yêu cầu kỹ thuật trên Simulator.
  - Nghiệm thu thực tế: Biểu mẫu sẵn sàng để thu thập chữ ký người dùng sinh viên VKU tại buổi bảo vệ.
* **Ma trận Truy xuất Nguồn gốc 6 Cấp độ:**
  - Chuẩn đầu ra VKU $\rightarrow$ WBS $\rightarrow$ Issue Draft $\rightarrow$ Commit/Merge $\rightarrow$ Automated Test $\rightarrow$ UAT Sign-off.
  - Minh bạch 100%, phân định rõ ràng giữa tự động hóa và xác nhận của con người.
* **Thời lượng trình bày:** 0:45 (Phút 5:15 – Phút 6:00)

---

## SLIDE 9: TRÌNH DIỄN SẢN PHẨM TRỰC TIẾP (LIVE DEMONSTRATION — 5 PHÚT)
* **Thời lượng Demo:** Đúng 5:00 (Phút 6:00 – Phút 11:00)
* **5 Kịch bản tương tác trực tiếp trên iPhone Simulator / Máy thật iOS:**
  1. *Demo 1 (1:00):* Nhận diện bát Phở Bò qua camera bằng Core ML on-device (<200ms).
  2. *Demo 2 (1:00):* Tùy chỉnh khẩu phần gram và lưu khay đa món vào Nhật ký bữa ăn.
  3. *Demo 3 (1:00):* Mở nút `[ 📅 Kế hoạch ]` trên header Nhật ký, lên thực đơn tuần 7 ngày.
  4. *Demo 4 (1:00):* Nhận gợi ý món ăn thông minh bù đạm và kiểm tra bộ lọc dị ứng thức ăn.
  5. *Demo 5 (1:00):* Quét mã vạch hộp sữa Vinamilk bằng camera với kiểm chuẩn GS1 Modulo-10.

---

## SLIDE 10: BÀI HỌC KINH NGHIỆM & KẾT LUẬN (LESSONS LEARNED & CONCLUSION)
* **3 Bài học Quản trị Xương máu:**
  1. *Kỷ luật Git & Sao lưu đa tầng là sống còn:* Đảm bảo an toàn tài sản trí tuệ dự án.
  2. *Clean Architecture giúp tái thiết kế và bảo trì siêu tốc:* Cô lập lỗi hiệu quả.
  3. *Kiểm thử tự động là thước đo tin cậy duy nhất:* Ngăn chặn triệt để lỗi hồi quy.
* **Thông điệp Kết luận:** NutriLens V1.0 sẵn sàng 100% để nghiệm thu và phát hành chính thức.
* **Chuyển sang phần Vấn đáp (Q&A):** Phút 11:00 – Phút 16:00 (Sẵn sàng trả lời câu hỏi của TS. Nguyễn Thanh Tuấn và Hội đồng).

