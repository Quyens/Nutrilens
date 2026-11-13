# HỒ SƠ KIỂM SOÁT THAY ĐỔI PHẠM VI (SCOPE CHANGE CONTROL RECORD)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/07_change_control_draft.md`  
**Ngày lập:** 13 tháng 11 năm 2026  
**Quy trình áp dụng:** Integrated Change Control (Kiểm soát Thay đổi Tích hợp theo chuẩn PMBOK)  
**Phân loại:** SCOPE GOVERNANCE & CHANGE MANAGEMENT  

---

## 1. Nguyên tắc Phân định Quản trị (Governance Distinction)

Trong quản trị dự án phần mềm, cần phân biệt rạch ròi giữa hai khái niệm:
1. **Sự cố Kỹ thuật (Technical Incident):** Các biến cố bất ngờ làm gián đoạn hệ thống hoặc mất mát dữ liệu (như sự cố xóa nhầm code đầu tháng 11/2026). Các sự cố này được xử lý theo **Kế hoạch Ứng phó Rủi ro (Risk Contingency Plan)** và không làm thay đổi phạm vi ban đầu của dự án.
2. **Yêu cầu Thay đổi Phạm vi (Scope Change Request - CR):** Các đề xuất chính thức nhằm bổ sung, sửa đổi hoặc loại bỏ một phần chức năng/yêu cầu đã được phê duyệt trong bản Scope Baseline. Mọi CR đều phải trải qua phân tích tác động toàn diện và được phê duyệt chính thức.

---

## 2. Phiếu Yêu cầu Thay đổi Số 01 (Change Request CR-01)

### 2.1. Thông tin Chung
* **Mã yêu cầu:** `CR-01`
* **Tên thay đổi:** Tích hợp Phân hệ Quét Mã vạch Thực phẩm Đóng gói Bán lẻ (Phase 06: Barcode Scanner & Packaged Foods).
* **Người yêu cầu (Requester):** Nhóm Kỹ thuật & Khảo sát Người dùng (VKU).
* **Ngày đề xuất:** 08 tháng 11 năm 2026.
* **Mức độ ưu tiên:** `High` (Quan trọng).

### 2.2. Chi tiết Yêu cầu
* **Phạm vi ban đầu (Original Scope):** Ứng dụng chỉ tập trung vào việc chụp ảnh nhận diện các món ăn truyền thống nấu chín tại bàn (cơm, phở, bún...). Đối với các sản phẩm đóng hộp/gói bán lẻ (sữa, mì ăn liền, bánh kẹo), người dùng phải nhập liệu hoàn toàn thủ công.
* **Thay đổi đề xuất (Requested Change):** Bổ sung phân hệ quét mã vạch bằng camera (`AVFoundation` + `Vision`), tích hợp thuật toán kiểm chuẩn toán học GS1 Modulo-10 Checksum, kết nối danh mục 7 sản phẩm bán lẻ mẫu tại thị trường Việt Nam và cho phép lưu trữ sản phẩm đóng gói tùy tạo vào SwiftData.
* **Lý do kinh doanh & Nghiệp vụ (Business Justification):** Người tiêu dùng trẻ và sinh viên tiêu thụ lượng lớn thực phẩm đóng gói tiện lợi hàng ngày. Việc bổ sung quét mã vạch giúp giảm thời gian ghi nhận bữa ăn từ ~45 giây xuống dưới 2 giây, tăng độ chuẩn xác dinh dưỡng từ bao bì của nhà sản xuất, đồng thời tăng tính cạnh tranh và ứng dụng thực tiễn của đồ án.

### 2.3. Đánh giá Tác động (Impact Analysis)
* **Tác động đến Tiến độ (Schedule Impact):** Bổ sung 1 tuần vào Sprint 5 (Tuần 13–14). Nhờ tối ưu hóa các công việc trước đó trên đường găng, việc bổ sung này không làm thay đổi mốc bàn giao cuối cùng vào Tuần 15.
* **Tác động đến Nỗ lực (Effort Impact):** Tăng thêm 8 Story Points (~64 giờ làm việc kỹ thuật).
* **Tác động đến Rủi ro (Risk Impact):** Phát sinh rủi ro quét camera không nét hoặc mã vạch không hợp lệ. Đã được khắc phục bằng thuật toán kiểm chuẩn GS1 Modulo-10 và cơ chế nhập mã thủ công dự phòng.
* **Tác động đến Kiến trúc & Kiểm thử:** Tăng 19 bài Unit Test và 1 kịch bản UI Test tự động. Toàn bộ mã nguồn mới tuân thủ nghiêm ngặt Clean Architecture.

### 2.4. Trạng thái Đề xuất & Quyết định Phê duyệt (Decision & Sign-off)
* **Các phương án thay thế đã xem xét (Alternatives):** 
  - *Phương án A:* Giữ nguyên chỉ nhận diện ảnh nấu chín, bỏ qua mã vạch -> *Bị từ chối vì trải nghiệm người dùng kém trọn vẹn.*
  - *Phương án B:* Gọi API đám mây OpenFoodFacts trực tuyến -> *Bị từ chối vì vi phạm cam kết bảo vệ dữ liệu Offline-First của dự án.*
  - *Phương án C (Được chọn):* Xây dựng máy quét mã vạch cục bộ với cơ sở dữ liệu mẫu on-device.
* **Trạng thái Quản trị (Governance Status):** **CHỜ PHÊ DUYỆT CHÍNH THỨC (PENDING APPROVAL)**.
  - *Ghi chú Kiểm toán:* Mặc dù mã nguồn phân hệ Quét mã vạch đã được lập trình hoàn chỉnh và vượt qua 19 bài kiểm thử đơn vị, việc bổ sung này làm thay đổi phạm vi Baseline của đồ án và bắt buộc phải được Giảng viên hướng dẫn TS. Nguyễn Thanh Tuấn phê duyệt chính thức bằng văn bản. Tuyệt đối không coi việc đã viết code là tương đương với việc đã được duyệt phạm vi.
* **Bảng Ký duyệt Đề xuất:**
  - *Đại diện Nhóm Kỹ thuật:* Nguyễn Thanh Thuận — *[PENDING FORMAL SIGN-OFF]*
  - *Quản lý Dự án:* quyen — *[PENDING FORMAL SIGN-OFF]*
  - *Giảng viên Hướng dẫn (Chủ tịch CCB):* **TS. Nguyễn Thanh Tuấn** — *[PENDING FORMAL SIGN-OFF]*

---

## 3. Phiếu Yêu cầu Thay đổi Số 02 (Change Request CR-02)

### 3.1. Thông tin Chung
* **Mã yêu cầu:** `CR-02`
* **Tên thay đổi:** Tinh gọn Bố cục Trang chủ & Tối ưu hóa Luồng Điều hướng Thẻ Bento (Home Layout Simplification & Bento Navigation Refinement).
* **Người yêu cầu (Requester):** Đại diện Người dùng Thử nghiệm (Feedback từ Tester).
* **Ngày đề xuất:** 12 tháng 11 năm 2026.
* **Mức độ ưu tiên:** `Medium` (Trung bình).

### 3.2. Chi tiết Yêu cầu
* **Phạm vi ban đầu (Original Scope):** Trang chủ hiển thị 2 khối nút con nhộng (Pills) lớn gồm "Kế hoạch thực đơn tuần" và "Gợi ý món ăn thông minh" chèn ngay giữa danh sách "Bữa ăn hôm nay" và "Khám phá món Việt".
* **Thay đổi đề xuất (Requested Change):** Loại bỏ 2 nút con nhộng gây rối mắt khỏi Trang chủ. Chuyển nút truy cập nhanh **`[ 📅 Kế hoạch ]`** vào thanh tiêu đề của màn hình **Nhật ký (Meal Diary)**, và đặt tính năng **Gợi ý món ăn thông minh** vào màn hình **Khám phá (Food Explorer)**.
* **Lý do kinh doanh & Nghiệp vụ (Business Justification):** Người dùng thử nghiệm phản ánh giao diện Trang chủ bị phân mảnh, kém trực quan (*"nó không được tổng quan cho lắm, đổi vị trí đừng để nằm đó được không"*). Việc điều chỉnh đưa tính năng về đúng ngữ cảnh sử dụng (Lên kế hoạch đi kèm Nhật ký; Gợi ý đi kèm Khám phá món) giúp Trang chủ thông thoáng, liền mạch và chuyên nghiệp.

### 3.3. Đánh giá Tác động (Impact Analysis)
* **Tác động đến Tiến độ (Schedule Impact):** 0 ngày trễ (hoàn thành trong 4 giờ làm việc).
* **Tác động đến Nỗ lực (Effort Impact):** 1 Story Point.
* **Tác động đến Kiểm thử:** Toàn bộ 149 bài tests tự động kiểm tra lại và vượt qua 100%, không gây ra bất kỳ lỗi hồi quy (zero regression).

### 3.4. Trạng thái Đề xuất & Quyết định Phê duyệt (Decision & Sign-off)
* **Trạng thái Quản trị (Governance Status):** **CHỜ PHÊ DUYỆT CHÍNH THỨC (PENDING APPROVAL)**.
  - *Ghi chú Kiểm toán:* Mặc dù mã nguồn đã được điều chỉnh trên nhánh làm việc cục bộ và xác thực qua ảnh chụp màn hình Simulator, việc thay đổi giao diện theo feedback người dùng cần được Giảng viên và Nhóm thông qua chính thức trong biên bản nghiệm thu.
* **Bằng chứng Triển khai Kỹ thuật (Technical Implementation Evidence):**
  - File sửa đổi: `NutriLens/Features/Home/HomeView.swift` và `NutriLens/Features/History/MealHistoryView.swift`.
  - Ảnh chụp màn hình kiểm định: `home_screen_clean_redesign.png` và `diary_screen_with_planner_button.png`.
* **Bảng Ký duyệt Đề xuất:**
  - *Quản lý Dự án:* quyen — *[PENDING FORMAL SIGN-OFF]*
  - *Trưởng nhóm Kỹ thuật:* Nguyễn Thanh Thuận — *[PENDING FORMAL SIGN-OFF]*
  - *Giảng viên Hướng dẫn:* **TS. Nguyễn Thanh Tuấn** — *[PENDING FORMAL SIGN-OFF]*

