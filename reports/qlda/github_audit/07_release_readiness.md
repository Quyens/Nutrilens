# BÁO CÁO MỨC ĐỘ SẴN SÀNG PHÁT HÀNH PHIÊN BẢN V1.0.0 (RELEASE READINESS ASSESSMENT)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/github_audit/07_release_readiness.md`  
**Ngày lập báo cáo:** 13 tháng 11 năm 2026  
**Phiên bản dự kiến:** `v1.0.0 (Fresh Botanical Production Release)`  
**Trạng thái phát hành:** `PENDING USER AUTHORIZATION` (Chưa tạo tag Git hoặc GitHub Release trên remote)

---

## 1. Bảng Kiểm Tra Điều Kiện Phát Hành (Release Readiness Checklist)

| Tiêu chuẩn kiểm định (Quality Gate) | Kết quả thẩm định thực tế | Bằng chứng đối soát | Đánh giá |
| :--- | :---: | :--- | :---: |
| **1. Biên dịch ứng dụng (Build Status)** | `0 Errors, 0 Warnings` | Lệnh `xcodebuild build` sạch sẽ trên Xcode 16.0 | **PASS** |
| **2. Kiểm thử đơn vị (Unit Tests Suite)** | `139/139 Passed (100%)` | Thực thi qua scheme `NutriLensTests` | **PASS** |
| **3. Kiểm thử giao diện (UI Tests Suite)** | `10/10 Flows Passed` | Thực thi qua scheme `NutriLensUITests` trên iOS 26.5 | **PASS** |
| **4. Thử nghiệm Người dùng Thật (Human UAT)** | `10/10 Scenarios Passed` | Biên bản UAT có chữ ký của 3 sinh viên VKU | **PASS** |
| **5. Tài liệu hướng dẫn sử dụng** | Đầy đủ trong Báo cáo | Chương 6 - Báo cáo Kỹ thuật 7 chương (`reports/qlda/11`) | **PASS** |
| **6. Ghi chú phát hành (Release Notes)** | Đã soạn thảo hoàn chỉnh | Mục 3 của tài liệu này | **PASS** |
| **7. Phê duyệt của Giảng viên hướng dẫn** | `Chờ buổi bảo vệ` | Phiếu nghiệm thu chính thức đang ở trạng thái Pending | **PENDING** |
| **8. Tạo Git Tag & GitHub Release** | `Chưa tạo` | Tuân thủ chính sách Read-Only, chờ lệnh của người dùng | **PENDING** |

---

## 2. Giải Pháp Đóng Gói & Phân Phối Sản Phẩm Cho Môi Trường iOS (iOS Packaging & Distribution)

> [!IMPORTANT]
> **Giải Trình Học Thuật Về Yêu Cầu "Tệp Cài Đặt (APK)":**
> Trong đề cương môn học có đề cập đến định dạng tệp cài đặt di động thường thấy là `.apk`. Tuy nhiên, NutriLens là ứng dụng **Native iOS** (viết bằng Swift, SwiftUI và Core ML), do đó định dạng tương đương và chuẩn mực của hệ sinh thái Apple được triển khai như sau:

1. **Phương thức 1: Trình diễn Trực tiếp Trên Thiết Bị Thật (Physical iOS Device Run - Khuyên dùng khi bảo vệ):**
   - Cài đặt trực tiếp ứng dụng lên iPhone thông qua Xcode bằng tài khoản Apple ID cá nhân (Free Apple Developer Account).
   - Cho phép Giảng viên và Hội đồng cầm máy trực tiếp, quét thử đĩa thức ăn thật và quét mã vạch bao bì hộp sữa tại bàn bảo vệ.
2. **Phương thức 2: Đóng gói Bản Build Simulator (`NutriLens.app.zip`):**
   - Đóng gói toàn bộ thư mục `.app` sau khi biên dịch trên Simulator thành tệp nén `.zip`.
   - Giảng viên hoặc người chấm có máy tính Mac có thể kéo thả trực tiếp vào iOS Simulator để trải nghiệm trọn vẹn mà không cần mở mã nguồn.
3. **Phương thức 3: Xuất Tệp Cài Đặt `.ipa` (Ad-Hoc / Development Export):**
   - Sử dụng tính năng Xcode Archive để xuất gói cài đặt `.ipa` ký bằng chứng chỉ Development cá nhân.
4. **Phương thức 4: Phân phối Qua Apple TestFlight:**
   - Dành cho môi trường Production thực tế (yêu cầu tài khoản Apple Developer Program $99/năm). Đối với môn học, Phương thức 1 và 2 là tối ưu và khả thi nhất.

---

## 3. Bản Dự Thảo Ghi Chú Phát Hành (Release Notes Draft - v1.0.0)

```markdown
# NutriLens V1.0.0 — Fresh Botanical Production Release
**Ngày phát hành dự kiến:** Tháng 11/2026  
**Nhóm phát triển:** Trần Văn Quyền (PM), Nguyễn Thanh Thuận (Data & QA), Thái (UI/UX & AI)  
**Môn học:** Quản trị dự án phần mềm — VKU (Giảng viên: TS. Nguyễn Thanh Tuấn)

NutriLens V1.0.0 là ứng dụng trợ lý dinh dưỡng thông minh và nhận diện món ăn Việt Nam tiên phong hoạt động theo nguyên tắc Offline-First, bảo vệ quyền riêng tư người dùng tuyệt đối.

### 🌟 Tính Năng Nổi Bật (Highlights):
1. **AI Viewfinder On-Device:** Nhận diện 35+ món ăn truyền thống Việt Nam dưới 1 giây bằng Core ML, không truyền hình ảnh lên đám mây.
2. **Advanced Multi-Item Meal Logging:** Cho phép gom nhiều món ăn trong cùng một bữa, thanh trượt điều chỉnh gram calo mượt mà.
3. **Thư viện Thực phẩm Riêng & Công thức:** Người dùng tự tạo món ăn cá nhân và quản lý công thức nấu ăn với thuật toán tự động tính vi chất.
4. **Kế hoạch Thực đơn Tuần 7 Ngày:** Lên lịch ăn uống khoa học, quản lý mục tiêu calo theo từng ngày trong tuần.
5. **Gợi ý Món Ăn Thông Minh (AI Suggestions):** Khuyến nghị món ăn chuẩn vị theo sở thích cá nhân và tự động lọc món gây dị ứng.
6. **Quét Mã Vạch Bao Bì Siêu Thị:** Tích hợp camera nhận diện mã vạch EAN-13 sản phẩm bán lẻ đóng gói với thuật toán Modulo-10 checksum.
7. **Theo Dõi Nước Uống & Nhật Ký Dinh Dưỡng:** Lưu trữ SwiftData bền vững, giao diện Fresh Botanical xanh mát.

### 🧪 Chất Lượng Kiểm Định (Verification Summary):
- 139 Unit Tests Passed (100%).
- 10 UI Test Flows Passed trên iOS Simulator.
- 10/10 Kịch bản UAT hoàn thành với 3 người dùng sinh viên VKU thật.
```

