# HIẾN CHƯƠNG DỰ ÁN (PROJECT CHARTER)
## DỰ ÁN: NUTRILENS V1.0 — ỨNG DỤNG NHẬN DIỆN MÓN ĂN VIỆT & QUẢN LÝ DINH DƯỠNG ON-DEVICE
### MÔN HỌC: QUẢN TRỊ DỰ ÁN PHẦN MỀM — TRƯỜNG ĐẠI HỌC CNTT & TRUYỀN THÔNG VIỆT - HÀN (VKU)

**Mã tài liệu:** `reports/qlda/02_project_charter_draft.md`  
**Ngày ban hành dự thảo:** 13 tháng 11 năm 2026  
**Phiên bản:** Draft 1.0 (Chờ ký duyệt)  
**Giảng viên hướng dẫn:** TS. Nguyễn Thanh Tuấn  

---

## 1. Thông tin Định danh Dự án (Project Identification)

* **Tên dự án tiếng Việt:** Ứng dụng iOS nhận diện món ăn Việt Nam bằng Trí tuệ Nhân tạo và Quản trị Dinh dưỡng Cá nhân hóa.
* **Tên thương mại quốc tế:** NutriLens — Vietnamese AI Food Recognition & Smart Nutrition Diary.
* **Mã dự án (Project Code):** `VKU-QLDA-2026-NUTRILENS`
* **Học kỳ thực hiện:** Học kỳ I — Năm học 2026-2027.
* **Tổ chức chủ quản:** Khoa Khoa học Máy tính / Khoa Kỹ thuật Phần mềm — Trường Đại học Công nghệ Thông tin & Truyền thông Việt - Hàn (VKU), Đại học Đà Nẵng.
* **Đơn vị tiếp nhận đánh giá:** Bộ môn Quản trị Dự án Phần mềm — Giảng viên: **TS. Nguyễn Thanh Tuấn**.

---

## 2. Bối cảnh Kinh doanh & Chiến lược (Business Context & Strategic Alignment)

Trong bối cảnh mức sống người dân đô thị tại Việt Nam ngày càng tăng cao, các bệnh mãn tính không lây liên quan đến lối sống và chế độ ăn (như béo phì, đái tháo đường type 2, tim mạch, mỡ máu) có xu hướng trẻ hóa nhanh chóng. Tuy nhiên, các ứng dụng theo dõi dinh dưỡng quốc tế nổi tiếng (MyFitnessPal, LoseIt, FatSecret) gặp phải rào cản nghiêm trọng tại Việt Nam:
1. **Thiếu hụt dữ liệu ẩm thực bản địa:** Dữ liệu món ăn Việt Nam trong các app ngoại bị nghèo nàn, định lượng sai lệch (quy đổi gượng ép theo món Tây), không phản ánh đúng cấu trúc dinh dưỡng của món ăn có nước dùng, rau thơm và gia vị truyền thống.
2. **Quy trình nhập liệu thủ công phiền hà:** Người dùng phải gõ chữ, tìm kiếm và cân đo từng thành phần rời rạc, dẫn đến tỷ lệ từ bỏ ứng dụng sau 7 ngày lên tới hơn 68%.
3. **Nguy cơ xâm phạm quyền riêng tư:** Hầu hết các ứng dụng yêu cầu tải ảnh chụp bữa ăn cá nhân lên máy chủ đám mây (cloud server) để nhận diện, tiềm ẩn rủi ro lộ lọt hình ảnh sinh hoạt riêng tư.

**NutriLens** ra đời nhằm giải quyết triệt để 3 bài toán trên bằng giải pháp công nghệ Native iOS đột phá: Nhận diện tức thì món ăn Việt Nam qua camera sử dụng mô hình học sâu **Core ML chạy 100% on-device (cục bộ trên máy)**, tự động ước tính calo theo khẩu phần chuẩn hóa của Viện Dinh dưỡng Quốc gia, đồng thời tôn trọng tuyệt đối quyền riêng tư dữ liệu người dùng.

---

## 3. Tuyên bố Bài toán (Problem Statement)

> *"Làm thế nào để người Việt Nam có thể theo dõi và quản lý dinh dưỡng bữa ăn hàng ngày một cách chuẩn xác, tự động và liền mạch nhất chỉ trong dưới 3 giây qua camera điện thoại, mà không phụ thuộc vào kết nối Internet và không chia sẻ dữ liệu nhạy cảm ra ngoài thiết bị?"*

NutriLens tập trung vào đối tượng sinh viên, nhân viên văn phòng, người tập luyện thể thao (fitness) và những người cần kiểm soát năng lượng theo chế độ ăn (eat clean, giảm cân, tăng cơ).

---

## 4. Mục tiêu Dự án (SMART Objectives)

| Tiêu chí | Nội dung Cam kết của Dự án NutriLens V1.0 | Chỉ số Đo lường Cụ thể |
| :--- | :--- | :--- |
| **S (Specific - Cụ thể)** | Phát triển ứng dụng Native iOS theo kiến trúc MVVM + Clean Architecture, tích hợp mô hình Core ML nhận diện món ăn Việt, quản lý nhật ký bữa ăn, công thức nấu ăn, thực đơn tuần và quét mã vạch sản phẩm. | Hoàn thiện 6 phân hệ cốt lõi (Phase 00 đến Phase 06). |
| **M (Measurable - Đo lường được)** | Hệ thống đạt tối thiểu **120 bài kiểm thử tự động (Unit Tests & UI Tests)** với tỷ lệ vượt qua 100%. Độ trễ suy luận AI trên chip Apple Silicon dưới 200ms. Độ chính xác nhận diện Top-1 > 82%. | Đã đạt **149/149 test cases pass** thực tế trên iOS 26.5 Simulator. |
| **A (Achievable - Khả thi)** | Tận dụng công nghệ Native Apple (SwiftUI, SwiftData, Core ML, Vision) không tốn chi phí thuê server ngoại vi, phù hợp ngân sách sinh viên và khung năng lực lập trình viên iOS. | Đã chứng minh qua bản build thực tế thành công không lỗi biên dịch. |
| **R (Relevant - Phù hợp)** | Phù hợp trực tiếp với chuẩn đầu ra môn học Quản trị Dự án Phần mềm tại VKU: Quản lý phạm vi (WBS), lập lịch (CPM), kiểm thử (QA), kiểm soát thay đổi và bảo vệ trước hội đồng. | Đáp ứng 100% các tiêu chí trong rubric đánh giá của môn học. |
| **T (Time-bound - Có thời hạn)** | Toàn bộ các mốc phát triển, kiểm thử, đóng gói hồ sơ quản trị và chuẩn bị bảo vệ hoàn thành trong khuôn khổ **15 tuần học kỳ**. | Khóa sổ toàn bộ hồ sơ nghiệm thu vào Tuần 15. |

---

## 5. Ranh giới Phạm vi (Scope Boundaries)

### 5.1. Thuộc Phạm vi Dự án (In-Scope)
* **Nền tảng mục tiêu:** iOS 17.0+ (Tương thích iPhone vật lý và Simulator).
* **Kiến trúc phần mềm:** MVVM + Clean Architecture phân lớp độc lập (Presentation, Domain, Data).
* **Mô hình Trí tuệ Nhân tạo:** Mô hình học sâu Core ML (`FoodClassifier.mlmodelc`) nhận diện 30 lớp món ăn truyền thống phổ biến của Việt Nam.
* **Cơ sở dữ liệu dinh dưỡng:** 35+ món ăn chuẩn hóa theo bảng số liệu của Viện Dinh dưỡng Quốc gia Việt Nam.
* **Nhật ký & Phân tích:** Ghi nhận đa món (Multi-item tray), theo dõi calo, 4 chỉ số đa lượng (Protein, Carbs, Fat, Fiber), theo dõi nước uống (Hydration).
* **Cá nhân hóa:** Tạo món ăn tùy biến (Custom Food), tạo công thức món (Recipe Builder), gợi ý món theo thâm hụt calo (Smart Suggestions).
* **Kế hoạch bữa ăn:** Lập kế hoạch thực đơn 7 ngày trong tuần (Weekly Meal Planner).
* **Quét mã vạch:** Quét mã vạch bao bì thực phẩm bán lẻ (EAN-13, EAN-8, UPC-A) với kiểm tra GS1 Modulo-10 và cơ sở dữ liệu mẫu 7 sản phẩm Việt Nam.
* **Lưu trữ dữ liệu:** Lưu trữ cục bộ an toàn bằng Apple SwiftData; lưu thông tin xác thực qua iOS Keychain.

### 5.2. Ngoài Phạm vi Dự án (Out-of-Scope)
* Không xây dựng phiên bản Android hoặc Web trong phạm vi môn học này (chỉ tập trung tối ưu Native iOS).
* Không xây dựng hệ thống đám mây (Cloud Backend) đa người dùng phức tạp hoặc trả phí (duy trì kiến trúc Offline-First).
* Không cung cấp chẩn đoán y khoa hay đơn thuốc lâm sàng (chỉ đóng vai trò công cụ hỗ trợ theo dõi lối sống).

---

## 6. Sản phẩm Bàn giao Cốt lõi (Key Deliverables)

1. **Sản phẩm Phần mềm (Software Deliverable):**
   - Bộ mã nguồn hoàn chỉnh NutriLens trên Xcode.
   - Bản build ứng dụng có thể kiểm thử thực tế trên iPhone Simulator / Máy thật iOS.
   - Bộ kiểm thử tự động 149 test cases (139 Unit Tests, 10 UI Tests).
2. **Bộ Hồ sơ Quản trị Dự án (PM Documentation Package):**
   - Đầy đủ 10 tài liệu quản trị chuyên sâu tại thư mục `reports/qlda/`.
   - Gói bằng chứng nghiệm thu chuẩn hóa tại thư mục `QLDA_EVIDENCE_PACKAGE/`.
   - Bài thuyết trình bảo vệ 10 slides và kịch bản Live Demo 16 phút.

---

## 7. Các Mốc Tiến độ Chính (High-Level Milestones)

| Mã mốc | Tên Mốc Tiến độ | Thời hạn Kế hoạch | Sản phẩm Bàn giao Yêu cầu |
| :---: | :--- | :---: | :--- |
| **M1** | Khởi tạo Dự án & Phê duyệt Hiến chương | Tuần 2 | Project Charter, Khảo sát yêu cầu, Kiến trúc sơ bộ. |
| **M2** | Hoàn thành Nền tảng Core & AI Baseline (Phase 00) | Tuần 5 | Core ML model, Home & Camera Viewfinder, 42 tests. |
| **M3** | Hoàn thành Quản lý Dinh dưỡng & Thực đơn (Phase 01–04) | Tuần 9 | Auth, Multi-item Log, Custom Recipes, Weekly Planner, 104 tests. |
| **M4** | Tích hợp Gợi ý AI & Quét Mã vạch (Phase 05–06) | Tuần 12 | Smart Suggestions, Barcode Scanner, 149 tests. |
| **M5** | Nghiệm thu UAT & Khóa sổ Hồ sơ Bảo vệ | Tuần 15 | Báo cáo kỹ thuật tổng kết, Biên bản UAT, Slide bảo vệ. |

---

## 8. Phân tích Các bên Liên quan (Stakeholders Analysis)

| Bên liên quan (Stakeholder) | Vai trò trong Dự án | Mức độ Quan tâm | Quyền hạn | Kỳ vọng Chính |
| :--- | :--- | :---: | :---: | :--- |
| **TS. Nguyễn Thanh Tuấn** | Giảng viên hướng dẫn & Chấm thi môn QLDA | Rất cao | Phê duyệt cao nhất | Đảm bảo tính khoa học, chuẩn mực quản trị, minh bạch bằng chứng và tuân thủ rubric. |
| **Nhóm Sinh viên Thực hiện** | Đội ngũ quản trị & Kỹ thuật phát triển | Rất cao | Quyết định triển khai | Hoàn thành đồ án xuất sắc, tích lũy năng lực quản trị dự án phần mềm thực chiến. |
| **Người dùng Thử nghiệm (Sinh viên VKU)** | Đối tượng tham gia thử nghiệm chấp nhận (UAT) | Trung bình | Đóng góp phản hồi | Giao diện đẹp, dễ dùng, nhận diện món ăn nhanh và chính xác. |

---

## 9. Các Giả định & Ràng buộc (Assumptions & Constraints)

### 9.1. Giả định (Assumptions)
* Môi trường phát triển của nhóm có trang bị máy tính macOS chạy được Xcode 15/16.
* Thiết bị kiểm thử mục tiêu hỗ trợ iOS 17.0 trở lên.
* Dữ liệu hình ảnh món ăn Việt Nam dùng huấn luyện Core ML đảm bảo bản quyền học thuật.

### 9.2. Ràng buộc (Constraints)
* **Thời gian:** Cố định đúng 15 tuần theo khung thời gian học kỳ của trường VKU.
* **Ngân sách:** Ngân sách sinh viên (0 VNĐ), không sử dụng hạ tầng cloud trả phí.
* **Bảo mật:** Tuân thủ quy định bảo vệ dữ liệu người dùng của Apple, không gửi dữ liệu hình ảnh ra ngoài thiết bị.

---

## 10. Đánh giá Rủi ro Ban đầu (Initial Risk Assessment)

1. **Rủi ro Mất mát Mã nguồn (Source Code Loss Risk):** Sự cố thao tác sai trên kho lưu trữ hoặc ổ cứng. *Giải pháp:* Thiết lập quy trình sao lưu snapshot định kỳ ra ngoài workspace và đóng băng checkpoint.
2. **Rủi ro Định dạng Bàn giao iOS vs Android (Platform Deliverable Risk):** Rubric môn học thường yêu cầu file `.apk`. *Giải pháp:* Làm rõ sớm với Giảng viên về cơ chế nộp bản build iOS (`.ipa`, TestFlight hoặc Demo trực tiếp).
3. **Rủi ro Phức tạp hóa Mô hình Dữ liệu SwiftData:** Khó khăn khi nâng cấp schema giữa các phase. *Giải pháp:* Sử dụng mô hình Schema Versioning và thiết kế Repository trung gian.

---

## 11. Cơ cấu Nhóm & Ma trận Trách nhiệm RACI (Team Roles & RACI Matrix)

### 11.1. Danh sách Phân công Nhân sự
Căn cứ vào dữ liệu thực tế đóng góp trên kho lưu trữ Git và phân nhiệm nhóm sinh viên:
* **Thành viên 1 — Nguyễn Thanh Thuận** (Email: `thuannt.23itb@vku.udn.vn`, Lớp: 23ITB - VKU):
  - *Chức danh đề xuất:* Trưởng nhóm Kỹ thuật (Technical Lead) & Kỹ sư Dữ liệu Ẩm thực.
* **Thành viên 2 — quyen** (Email: `quyen11072k5@gmail.com`):
  - *Chức danh đề xuất:* Quản lý Dự án (Project Manager / Scrum Master) & Kiến trúc sư Phần mềm iOS.
* **Thành viên 3 — thai1123** (Email: `changtraikhoyeu23@gmail.com`):
  - *Chức danh đề xuất:* Kỹ sư Tích hợp Trí tuệ Nhân tạo (AI & Core ML Engineer).
* **Thành viên 4 & 5 (Vị trí dự phòng theo chuẩn nhóm 3–5 sinh viên VKU):**
  - Chuyên viên Kiểm định Chất lượng (QA & Test Lead) / Chuyên viên Quản trị Hồ sơ (Documentation Specialist) — *Chờ nhóm xác nhận danh sách sinh viên chính thức bổ sung nếu có*.

### 11.2. Ma trận Phân định Trách nhiệm (RACI Matrix)
*Ý nghĩa: **R** (Responsible - Thực hiện), **A** (Accountable - Chịu trách nhiệm chính/Phê duyệt), **C** (Consulted - Tham vấn), **I** (Informed - Nhận thông tin).*

| Hạng mục Công việc (WBS Category) | PM / Scrum Master | Tech Lead / Architect | AI / Mobile Engineer | QA / Test Engineer | Giảng viên Hướng dẫn |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Xây dựng Project Charter & Kế hoạch 15 tuần** | **A / R** | C | C | I | **A (Duyệt)** |
| **Thiết kế Kiến trúc Clean Architecture** | C | **A / R** | C | I | I |
| **Huấn luyện & Tích hợp Core ML on-device** | I | C | **A / R** | C | I |
| **Phát triển UI/UX SwiftUI Fresh Botanical** | C | R | **A / R** | I | I |
| **Cơ sở dữ liệu SwiftData & Repository Layer** | I | **A / R** | R | I | I |
| **Viết Unit Tests & UI Automated Tests** | I | C | R | **A / R** | I |
| **Xử lý Sự cố & Sao lưu Dữ liệu Dự phòng** | **A** | R | R | I | I |
| **Thực hiện Thử nghiệm UAT với Người dùng** | R | I | I | **A / R** | C |
| **Đóng gói Hồ sơ Báo cáo Cuối kỳ & Bảo vệ** | **A / R** | R | R | R | **A (Chấm)** |

---

## 12. Phê duyệt & Ký nhận (Approvals & Sign-off)

> [!CAUTION]
> **Quy định Nghiêm ngặt về Tính Minh bạch:** Để đảm bảo tính trung thực học thuật, các chữ ký dưới đây đang ở trạng thái **DỰ THẢO CHỜ KÝ DUYỆT (PENDING SIGNATURE)**. Tuyệt đối không tự ý ký thay hoặc chèn chữ ký số giả mạo của Giảng viên và các thành viên.

| Đại diện Phê duyệt | Họ và Tên | Chức vụ / Vai trò | Chữ ký & Ngày xác nhận |
| :--- | :--- | :--- | :---: |
| **Giảng viên Hướng dẫn** | **TS. Nguyễn Thanh Tuấn** | Giảng viên Phụ trách Môn học | *[PENDING — CHỜ XÁC NHẬN]*<br>Ngày: ..../..../2026 |
| **Đại diện Nhóm Sinh viên** | **Nguyễn Thanh Thuận** | Trưởng nhóm Kỹ thuật (VKU 23ITB) | *[PENDING — CHỜ KÝ]*<br>Ngày: ..../..../2026 |
| **Quản lý Dự án** | **quyen** | Project Manager / Scrum Master | *[PENDING — CHỜ KÝ]*<br>Ngày: ..../..../2026 |

