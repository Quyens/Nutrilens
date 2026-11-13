# DỰ THẢO BÀI HỌC KINH NGHIỆM & HỒI TƯỞNG SPRINT TÁI THIẾT LẬP (RECONSTRUCTED SPRINT RETROSPECTIVE & LESSONS LEARNED DRAFT)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/13_sprint_retrospectives.md`  
**Ngày hiệu chỉnh:** 13 tháng 11 năm 2026  
**Phương pháp:** Scrum Retrospective Framework (Tái thiết lập từ Lịch sử Phát triển Thực tế)  
**Phân loại:** RECONSTRUCTED AGILE RETROSPECTIVE & LESSONS LEARNED SPECIFICATION  

---

> [!IMPORTANT]
> **Tuyên bố Minh bạch về Dữ liệu Hồi tưởng (Authenticity Statement):**
> Các nội dung dưới đây là **Bản tổng hợp Bài học Kinh nghiệm và Hồi tưởng Sprint Tái thiết lập (Reconstructed Retrospectives)**, được đúc kết trực tiếp từ các sự kiện kỹ thuật thực tế, báo cáo kiểm toán hiện trạng (`reports/nutrilens_recovery_audit.md`, `reports/nutrilens_phase*.md`) và lịch sử commit trên kho lưu trữ Git. 
> Nhóm sinh viên không giả mạo rằng đã tổ chức 6 buổi lễ nghi thức Scrum chính quy với biên bản ký sống; tài liệu này phản ánh trung thực quá trình học hỏi, va vấp kỹ thuật, sự cố mã nguồn và các giải pháp điều chỉnh thực tế của nhóm trong suốt 15 tuần học kỳ.

---

## 1. Khung Phân tích Bài học Kinh nghiệm (Scrum Retrospective Framework)
Mỗi chu kỳ phát triển được tổng kết theo 4 trụ cột chuẩn mực:
1. **What Went Well (Điểm làm tốt):** Các thành tựu kiến trúc, tính năng kỹ thuật hoặc sự phối hợp đạt kết quả.
2. **What Could Be Improved (Điểm tồn tại / Khó khăn):** Sai sót kỹ thuật, rủi ro quản trị hoặc gián đoạn phát sinh.
3. **Key Learnings (Bài học kinh nghiệm):** Nhận thức quản trị và nguyên tắc kỹ thuật được đúc kết.
4. **Action Items (Biện pháp điều chỉnh):** Hành động khắc phục cụ thể cho các giai đoạn kế tiếp.

---

## 2. Mốc Sprint 1 (Khởi tạo, Đặc tả Yêu cầu & CSDL Dinh dưỡng Món Việt)
* **Khung thời gian tương ứng:** Tuần 1 – Tuần 3 (Cuối tháng 10/2026)
* **Thành viên đóng góp chính:** quyen, Nguyễn Thanh Thuận, thai1123
* **Điểm làm tốt:**
  - Khảo sát nhanh nhu cầu dinh dưỡng người Việt, xác định đúng 3 bài toán rào cản của app ngoại.
  - Chuẩn hóa thành công cơ sở dữ liệu 35+ món ăn theo bảng thành phần thực phẩm Viện Dinh Dưỡng Quốc Gia (`VietnameseNutritionDatabase.swift`).
  - Thiết lập nền tảng kiến trúc Clean Architecture tách lớp Presentation, Domain, Data.
* **Điểm tồn tại / Khó khăn:**
  - Chưa thiết lập bảng quản trị GitHub Projects chính thức; các thành viên làm việc phân tán, chưa đồng bộ quy ước đặt tên commit.
* **Bài học kinh nghiệm:** Cần thống nhất quy ước commit có tiền tố chuẩn (`feat`, `fix`, `chore`, `docs`) để đảm bảo tính truy xuất nguồn gốc.
* **Biện pháp điều chỉnh:** Ban hành tài liệu quy tắc phát triển trong `GEMINI.md` và `Documentation/GIT_WORKFLOW.md`.

---

## 3. Mốc Sprint 2 (Core App, AI Baseline & Authentication)
* **Khung thời gian tương ứng:** Tuần 4 – Tuần 6 (Đầu tháng 11/2026)
* **Thành viên đóng góp chính:** quyen, Nguyễn Thanh Thuận, thai1123
* **Điểm làm tốt:**
  - Đóng gói thành công mô hình Core ML `FoodClassifier.mlmodelc` (Float16, 30 lớp món ăn) chạy <200ms trên chip Apple Silicon.
  - Xây dựng kính ngắm camera 30fps (`AVFoundation` + `Vision`), màn hình Home Dashboard và bảo mật sinh trắc học Face ID qua Keychain.
* **Điểm tồn tại / Khó khăn (Được kiểm chứng qua `reports/ai_v1_technical_audit.md` ngày 03/11/2026):**
  - Quá trình tích hợp ban đầu bị từ chối do thiếu tệp trọng số nhị phân của Core ML, gây lỗi khi biên dịch Bundle.
* **Bài học kinh nghiệm:** Mọi tệp nhị phân nặng phải được kiểm tra tính tương thích và kiểm tra file bundle kỹ lưỡng trên Xcode trước khi xác nhận hoàn tất.
* **Biện pháp điều chỉnh:** Đóng băng phiên bản kiểm tra sạch với 42 automated tests trên nhánh `checkpoint/phase00-baseline` (commit `8ec9c1d`).

---

## 4. Mốc Sprint 3 (Sự cố Mất mát Mã nguồn & Kế hoạch Phục hồi Khẩn cấp)
* **Khung thời gian tương ứng:** Tuần 7 – Tuần 9 (Giữa tháng 11/2026)
* **Thành viên tham gia khắc phục:** quyen, Nguyễn Thanh Thuận
* **Sự cố Kỹ thuật Thực tế (Incident Post-Mortem):**
  - *Sự việc:* Một thao tác ghi đè thư mục cục bộ khi chưa kịp commit lên Git đã làm mất các tệp nguồn đang viết dở từ Phase 01 đến Phase 06. Số bài test tự động giảm từ 154 xuống còn 42 tests.
  - *Phản ứng khẩn cấp:* Nhóm đã kích hoạt bản sao lưu zip vật lý ngày 03/11 (`NutrilensIOS 2.zip` 19.7 MB), lập báo cáo kiểm toán hiện trạng `reports/nutrilens_recovery_audit.md` ngày 06/11, đóng băng nhánh an toàn và tái thiết lập tuần tự từng pha có kiểm thử tự động đi kèm.
* **Điểm làm tốt:** Nhóm giữ bình tĩnh, kích hoạt kế hoạch dự phòng hiệu quả, phục hồi 100% Phase 01 (Auth) và Phase 02 (Meal Logging) trong 48 giờ.
* **Điểm tồn tại / Khó khăn:** Nhận ra lỗ hổng lớn khi phụ thuộc vào bộ nhớ đệm cục bộ mà không có chính sách snapshot ra thư mục ngoài.
* **Bài học kinh nghiệm:** Kỷ luật quản trị mã nguồn và sao lưu đa tầng (3-2-1 backup strategy) là sinh mạng của dự án phần mềm.
* **Biện pháp điều chỉnh:** Áp dụng chính sách Strict Git Read-Only đối với các công cụ tự động; bắt buộc tạo snapshot zip độc lập ngoài workspace sau mỗi pha phát triển.

---

## 5. Mốc Sprint 4 (Kế hoạch Thực đơn Tuần & Gợi ý Thông minh AI)
* **Khung thời gian tương ứng:** Tuần 10 – Tuần 12 (Đầu tháng 11/2026)
* **Thành viên đóng góp chính:** quyen, Nguyễn Thanh Thuận
* **Điểm làm tốt:**
  - Hoàn thiện dải lịch tuần 7 ngày cho Weekly Meal Planner với 17 Unit Tests chuyên biệt.
  - Thuật toán tính thâm hụt đa lượng (protein/carb/fat) và gợi ý món kèm lời giải thích (Explainable AI) hoạt động mượt mà với 16 Unit Tests.
* **Điểm tồn tại / Khó khăn:**
  - Màn hình Trang chủ bắt đầu xuất hiện quá nhiều nút bấm con nhộng (pills) ở giữa trang, gây rối mắt và làm đứt đoạn luồng trải nghiệm.
* **Bài học kinh nghiệm:** Cần lắng nghe phản hồi của người dùng sớm để tránh nhồi nhét quá nhiều widget phụ lên màn hình Trang chủ.
* **Biện pháp điều chỉnh:** Lập phiếu đề xuất thay đổi phạm vi `CR-02` để tinh gọn Trang chủ.

---

## 6. Mốc Sprint 5 (Quét Mã vạch Bao bì Thực phẩm & Tối ưu Bố cục Giao diện)
* **Khung thời gian tương ứng:** Tuần 13 – Tuần 14 (Tháng 11/2026)
* **Thành viên đóng góp chính:** quyen, Nguyễn Thanh Thuận
* **Điểm làm tốt:**
  - Hoàn thành máy quét mã vạch bằng camera (`AVFoundation`), thuật toán GS1 Modulo-10 Checksum và danh mục 7 món bán lẻ mẫu (Vinamilk, Hảo Hảo...).
  - Toàn bộ 149 bài kiểm thử tự động (139 Unit Tests, 10 UI Tests) đạt tỷ lệ vượt qua tuyệt đối 100%.
  - Tinh gọn thành công Trang chủ, chuyển nút `[ 📅 Kế hoạch ]` vào header Nhật ký bữa ăn.
* **Điểm tồn tại / Khó khăn:**
  - Rubric mẫu của môn học yêu cầu file APK (Android), trong khi NutriLens là Native iOS.
* **Bài học kinh nghiệm:** Cần chủ động chuẩn bị các phương án bàn giao linh hoạt (TestFlight, `.ipa`, Live demo máy thật) trước khi bảo vệ.
* **Biện pháp điều chỉnh:** Soạn thảo thư ngỏ xin ý kiến hướng dẫn của Thầy TS. Nguyễn Thanh Tuấn.

---

## 7. Mốc Sprint 6 (Kế hoạch Triển khai: UAT Người dùng Thật, Đóng gói Hồ sơ & Bảo vệ)
* **Khung thời gian tương ứng:** Tuần 15 (Tuần kết thúc môn học)
* **Nhiệm vụ trọng tâm:**
  - Tổ chức cho 2–3 sinh viên VKU thử nghiệm trực tiếp theo 10 kịch bản UAT và lấy chữ ký thực tế.
  - Trình nộp bộ 10 hồ sơ QLDA và gói bằng chứng nghiệm thu `QLDA_EVIDENCE_PACKAGE/`.
  - Thực hiện bảo vệ đồ án 16 phút (6 phút thuyết trình + 5 phút live demo + 5 phút vấn đáp) trước Hội đồng và Thầy TS. Nguyễn Thanh Tuấn.
