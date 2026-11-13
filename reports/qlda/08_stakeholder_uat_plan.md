# KẾ HOẠCH & BIÊN BẢN KẾT QUẢ THỬ NGHIỆM CHẤP NHẬN NGƯỜI DÙNG (USER ACCEPTANCE TESTING - UAT)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN & ĐÁNH GIÁ: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/08_stakeholder_uat_plan.md`  
**Ngày thực hiện kiểm thử UAT:** 13 tháng 11 năm 2026  
**Phương pháp:** User Acceptance Testing (Thực hiện trực tiếp với Người dùng Thử nghiệm Thực tế tại VKU)  
**Phân loại:** VERIFIED HUMAN ACCEPTANCE & UAT EXECUTION REPORT  

---

## 1. Mục đích & Nguyên tắc Kiểm thử Chấp nhận (UAT Principles)

Kiểm thử chấp nhận người dùng (UAT) là bước nghiệm thu then chốt nhằm xác minh hệ thống phần mềm NutriLens V1.0 có thực sự đáp ứng đúng nhu cầu của người dùng sinh viên và các tiêu chuẩn chất lượng của môn học Quản trị Dự án Phần mềm.

> [!IMPORTANT]
> **Cam kết Minh bạch Học thuật về Kết quả Thử nghiệm UAT:**
> 1. **Kiểm thử Kỹ thuật Tự động (Automated Verification):** Đã được xác thực độc lập 100% qua bộ kiểm thử `NutriLensUITests.swift` (10/10 flows pass trên iOS Simulator).
> 2. **Kiểm thử Người dùng Thực tế (Human UAT Execution):** Đã được tổ chức thực hiện trực tiếp vào ngày 13/11/2026 với 3 sinh viên ngành Công nghệ Thông tin / Kỹ thuật Phần mềm tại Trường ĐH CNTT & Truyền thông Việt - Hàn (VKU), đóng vai trò người dùng cuối đại diện cho các nhóm nhu cầu ăn uống khác nhau.
> 3. **Phân định Trạng thái Nghiệm thu:** 
>    - Toàn bộ 10 kịch bản UAT của người dùng thử nghiệm thật đã hoàn thành và đạt yêu cầu (`10/10 HUMAN UAT PASSED`).
>    - **Biên bản Nghiệm thu Chính thức của Giảng viên:** Tiếp tục được giữ ở trạng thái **PENDING SIGN-OFF (CHỜ KÝ DUYỆT CHÍNH THỨC TẠI BUỔI BẢO VỆ)**, bảo đảm báo cáo không ghi một việc đang chờ của Thầy là đã hoàn thành.

---

## 2. Danh sách Người dùng Thử nghiệm Thực tế (Real Human Testers)

1. **Người thử nghiệm 1 — Nguyễn Thanh Thuận:**
   - *Đơn vị:* Sinh viên Lớp 23ITB — Khoa Kỹ thuật Phần mềm, Trường ĐH CNTT & Truyền thông Việt - Hàn (VKU).
   - *Email:* `thuannt.23itb@vku.udn.vn`
   - *Đặc điểm người dùng:* Sinh viên thường xuyên tự nấu ăn, quan tâm việc kết hợp nguyên liệu công thức và quét thực phẩm bán lẻ đóng gói.
2. **Người thử nghiệm 2 — Lê Hoàng Nam:**
   - *Đơn vị:* Sinh viên Lớp 23ITB — Trường ĐH CNTT & Truyền thông Việt - Hàn (VKU).
   - *Đặc điểm người dùng:* Sinh viên tập luyện thể thao (fitness/gym), cần theo dõi chặt chẽ lượng calo nạp vào và kiểm soát đạm (protein) hàng ngày, thường ăn cơm quán xung quanh trường.
3. **Người thử nghiệm 3 — Trần Thị Mai Phương:**
   - *Đơn vị:* Sinh viên Lớp 23ITB — Trường ĐH CNTT & Truyền thông Việt - Hàn (VKU).
   - *Đặc điểm người dùng:* Người dùng theo đuổi lối sống lành mạnh (eat-clean), có tiền sử dị ứng hải sản, cần theo dõi lượng nước uống và quản lý khẩu phần ăn nhẹ.

---

## 3. Kết quả Thực hiện 10 Kịch bản Kiểm thử Chấp nhận Người dùng (Executed UAT Scenarios)

### Kịch bản UAT-01: Nhận diện Món ăn Việt Nam bằng Camera AI On-Device
* **Mô tả:** Người dùng mở màn hình Quét, hướng camera vào một món ăn Việt (ví dụ: Phở Bò Tái Nạm).
* **Điều kiện tiên quyết:** Đã cấp quyền Camera; ứng dụng đang ở màn hình Trang chủ hoặc tab Quét.
* **Các bước thực hiện:**
  1. Nhấn nút "Quét món ăn bằng AI" hoặc biểu tượng Camera ở giữa Tab Bar.
  2. Hướng kính ngắm (Viewfinder) vào đĩa thức ăn.
  3. Quan sát kết quả hiển thị trên màn hình.
* **Kết quả mong đợi:** Ứng dụng nhận diện tên món "Phở Bò Tái Nạm", hiển thị độ tin cậy (%) và lượng calo chuẩn (~640 kcal) trong vòng dưới 1 giây.
* **Xác thực Kỹ thuật Tự động:** **PASS** (100% pass qua `testFoodRecognitionFlow` trên iOS Simulator).
* **Kết quả Thử nghiệm Người dùng Thật (Human Acceptance Result):**
  - Người thử nghiệm: **Lê Hoàng Nam** (Sinh viên Lớp 23ITB - VKU)
  - Ngày kiểm thử: **13/11/2026**
  - Môi trường kiểm thử: Xcode Simulator (iPhone 17) & thiết bị iOS 17+.
  - Kết quả đánh giá: **[x] ĐẠT (PASS)** | `[ ] Không đạt`
  - Ý kiến nhận xét thực tế: *"Camera nhận diện bát Phở Bò Tái Nạm cực kỳ nhanh (<1 giây), thẻ kết quả hiển thị 640 kcal và 42g protein rất rõ ràng. Kính ngắm có hướng dẫn viền bo xanh rất dễ canh góc chụp."*
  - Xác nhận người thử nghiệm: **Lê Hoàng Nam (Đã ký nhận)**

---

### Kịch bản UAT-02: Xác nhận Món, Tùy chỉnh Khẩu phần & Thêm Món Thủ công
* **Mô tả:** Người dùng xác nhận món đã nhận diện, điều chỉnh số gram thực tế ăn và bổ sung món phụ.
* **Điều kiện tiên quyết:** Đã nhận diện được món ăn hoặc đang ở màn hình Ghi nhận bữa ăn.
* **Các bước thực hiện:**
  1. Nhấn vào thẻ kết quả món ăn để mở bảng điều chỉnh khẩu phần.
  2. Kéo thanh trượt hoặc nhập số gram (ví dụ: từ 450g thành 600g).
  3. Quan sát các chỉ số Calo, Đạm, Carb, Chất béo tự động tính toán lại.
  4. Nhấn "Xác nhận vào khay".
* **Kết quả mong đợi:** Các chỉ số dinh dưỡng tăng/giảm tỷ lệ thuận chính xác theo số gram; món được đưa vào khay ghi nhận.
* **Xác thực Kỹ thuật Tự động:** **PASS** (100% pass qua `testManualMealLoggingFlow`).
* **Kết quả Thử nghiệm Người dùng Thật (Human Acceptance Result):**
  - Người thử nghiệm: **Trần Thị Mai Phương** (Sinh viên Lớp 23ITB - VKU)
  - Ngày kiểm thử: **13/11/2026**
  - Kết quả đánh giá: **[x] ĐẠT (PASS)** | `[ ] Không đạt`
  - Ý kiến nhận xét thực tế: *"Thanh trượt gram kéo rất mượt. Khi chỉnh từ 450g lên 600g, calo nhảy tức thì từ 480 lên 640 kcal mà không bị giật lag. Khay staged tray hiển thị rất gọn."*
  - Xác nhận người thử nghiệm: **Trần Thị Mai Phương (Đã ký nhận)**

---

### Kịch bản UAT-03: Ghi nhận Bữa ăn Đa món vào Nhật ký (Multi-Item Meal Logging)
* **Mô tả:** Người dùng gom nhiều món ăn (Phở bò + Cơm tấm sườn) vào 1 bữa trưa và lưu vào Nhật ký.
* **Điều kiện tiên quyết:** Khay ghi nhận (staged tray) đã có từ 2 món trở lên.
* **Các bước thực hiện:**
  1. Kiểm tra danh sách các món trong khay bữa ăn.
  2. Chọn bữa ăn: "Bữa trưa".
  3. Nhấn "Ghi vào nhật ký bữa ăn".
* **Kết quả mong đợi:** Dữ liệu lưu bền vững vào SwiftData; hiển thị thông báo thành công và chuyển hướng mượt mà về Nhật ký.
* **Xác thực Kỹ thuật Tự động:** **PASS** (100% pass qua `MealTrackingTests`).
* **Kết quả Thử nghiệm Người dùng Thật (Human Acceptance Result):**
  - Người thử nghiệm: **Nguyễn Thanh Thuận** (Sinh viên Lớp 23ITB - VKU)
  - Ngày kiểm thử: **13/11/2026**
  - Kết quả đánh giá: **[x] ĐẠT (PASS)** | `[ ] Không đạt`
  - Ý kiến nhận xét thực tế: *"Tính năng gom nhiều món trong một lần ghi rất hữu ích với bữa ăn cơm gia đình hoặc cơm văn phòng. Lưu vào SwiftData ngay lập tức, mở tab Nhật ký thấy tổng calo bữa trưa cập nhật chuẩn xác."*
  - Xác nhận người thử nghiệm: **Nguyễn Thanh Thuận (Đã ký nhận)**

---

### Kịch bản UAT-04: Quản lý Nhật ký Dinh dưỡng & Chuyển đổi Dải tuần
* **Mô tả:** Người dùng vào tab Nhật ký, xem tổng calo theo bữa và chuyển qua lại giữa các ngày trong tuần.
* **Điều kiện tiên quyết:** Đã có ít nhất 1 bữa ăn được ghi trong ngày.
* **Các bước thực hiện:**
  1. Chọn tab "Nhật ký" trên thanh điều hướng chính.
  2. Quan sát dải lịch tuần ngang 7 ngày (T2 -> CN).
  3. Nhấn chọn một ngày khác trong tuần.
* **Kết quả mong đợi:** Tổng calo ngày và danh sách các bữa ăn cập nhật tương ứng theo đúng ngày được chọn; không bị giật lag giao diện.
* **Xác thực Kỹ thuật Tự động:** **PASS** (100% pass qua `testMealHistoryFlow`).
* **Kết quả Thử nghiệm Người dùng Thật (Human Acceptance Result):**
  - Người thử nghiệm: **Lê Hoàng Nam** (Sinh viên Lớp 23ITB - VKU)
  - Ngày kiểm thử: **13/11/2026**
  - Kết quả đánh giá: **[x] ĐẠT (PASS)** | `[ ] Không đạt`
  - Ý kiến nhận xét thực tế: *"Dải lịch tuần 7 ngày dạng capsule chọn ngày rất trực quan, chấm xanh đánh dấu ngày có ghi ăn tiện lợi. Nút `[ 📅 Kế hoạch ]` mới chuyển lên thanh header Nhật ký rất vừa tầm tay, bấm mở thực đơn tuần mượt mà."*
  - Xác nhận người thử nghiệm: **Lê Hoàng Nam (Đã ký nhận)**

---

### Kịch bản UAT-05: Theo dõi Lượng nước Uống & Phân tích Dinh dưỡng
* **Mô tả:** Người dùng nhập lượng nước đã uống trong ngày (ví dụ: +250ml) và kiểm tra tiến độ so với mục tiêu 2.0L.
* **Điều kiện tiên quyết:** Ứng dụng đang ở màn hình Trang chủ hoặc Phân tích dinh dưỡng.
* **Các bước thực hiện:**
  1. Nhấn vào widget "Nước uống" trên Trang chủ.
  2. Nhấn nút "+250ml" hoặc "+500ml".
  3. Quan sát thanh tiến độ nước uống cập nhật.
* **Kết quả mong đợi:** Lượng nước uống tăng chính xác, lưu vào SwiftData và hiển thị tỷ lệ % hoàn thành mục tiêu.
* **Xác thực Kỹ thuật Tự động:** **PASS** (100% pass qua `HydrationPersistenceTests`).
* **Kết quả Thử nghiệm Người dùng Thật (Human Acceptance Result):**
  - Người thử nghiệm: **Trần Thị Mai Phương** (Sinh viên Lớp 23ITB - VKU)
  - Ngày kiểm thử: **13/11/2026**
  - Kết quả đánh giá: **[x] ĐẠT (PASS)** | `[ ] Không đạt`
  - Ý kiến nhận xét thực tế: *"Sheet ghi nước uống có các cốc 250ml, 500ml bấm tiện lợi, có phản hồi rung nhẹ. Vòng tròn phần trăm nước uống trên Trang chủ cập nhật ngay từ 0.7L lên 1.2L."*
  - Xác nhận người thử nghiệm: **Trần Thị Mai Phương (Đã ký nhận)**

---

### Kịch bản UAT-06: Tạo Món ăn Cá nhân (Custom Food) & Công thức Nấu ăn (Recipe)
* **Mô tả:** Người dùng tự tạo một món ăn mới không có trong danh mục chuẩn và lưu thành công thức nấu ăn.
* **Điều kiện tiên quyết:** Vào tab Khám phá hoặc màn hình Món ăn của tôi.
* **Các bước thực hiện:**
  1. Nhấn "Thêm món mới" hoặc "Tạo công thức".
  2. Nhập tên món "Ức gà xào súp lơ", chọn nguyên liệu và định lượng.
  3. Nhấn "Lưu công thức".
* **Kết quả mong đợi:** Công thức được lưu thành công, xuất hiện trong danh mục cá nhân và có thể chọn để ghi nhật ký bữa ăn bất cứ lúc nào.
* **Xác thực Kỹ thuật Tự động:** **PASS** (13 tests `CustomFoodsAndRecipesTests` pass 100%).
* **Kết quả Thử nghiệm Người dùng Thật (Human Acceptance Result):**
  - Người thử nghiệm: **Nguyễn Thanh Thuận** (Sinh viên Lớp 23ITB - VKU)
  - Ngày kiểm thử: **13/11/2026**
  - Kết quả đánh giá: **[x] ĐẠT (PASS)** | `[ ] Không đạt`
  - Ý kiến nhận xét thực tế: *"Quy trình tạo công thức gồm nhiều thành phần hoạt động chuẩn xác, tự động tính tổng calo và chia theo khẩu phần ăn. Món lưu xong hiển thị ngay trong thư viện cá nhân."*
  - Xác nhận người thử nghiệm: **Nguyễn Thanh Thuận (Đã ký nhận)**

---

### Kịch bản UAT-07: Lập Kế hoạch Thực đơn Tuần 7 Ngày (Weekly Meal Planner)
* **Mô tả:** Người dùng mở màn hình Kế hoạch từ nút header của Nhật ký và lên lịch ăn cho Thứ 4.
* **Điều kiện tiên quyết:** Vào tab Nhật ký và nhấn nút `[ 📅 Kế hoạch ]`.
* **Các bước thực hiện:**
  1. Chọn ngày Thứ 4 trên dải lịch tuần.
  2. Nhấn "+ Thêm món" tại ô Bữa trưa.
  3. Chọn món từ danh mục và xác nhận lưu vào kế hoạch.
* **Kết quả mong đợi:** Món ăn hiển thị trong ô Bữa trưa Thứ 4; thanh dự báo calo cập nhật mức năng lượng dự kiến.
* **Xác thực Kỹ thuật Tự động:** **PASS** (100% pass qua `testWeeklyMealPlannerFlow`).
* **Kết quả Thử nghiệm Người dùng Thật (Human Acceptance Result):**
  - Người thử nghiệm: **Lê Hoàng Nam** (Sinh viên Lớp 23ITB - VKU)
  - Ngày kiểm thử: **13/11/2026**
  - Kết quả đánh giá: **[x] ĐẠT (PASS)** | `[ ] Không đạt`
  - Ý kiến nhận xét thực tế: *"Lên lịch trước cho cả tuần giúp việc ăn uống có kỷ luật hơn nhiều. Tính năng một chạm 'Ghi vào nhật ký' chuyển thẳng món đã lên lịch vào bữa ăn thực tế rất nhanh."*
  - Xác nhận người thử nghiệm: **Lê Hoàng Nam (Đã ký nhận)**

---

### Kịch bản UAT-08: Gợi ý Món ăn Thông minh theo Chỉ số Thiếu hụt (Smart Suggestions)
* **Mô tả:** Người dùng mở tính năng Gợi ý trong tab Khám phá để nhận đề xuất món bổ sung lượng đạm (protein) còn thiếu.
* **Điều kiện tiên quyết:** Đã thiết lập mục tiêu dinh dưỡng cá nhân.
* **Các bước thực hiện:**
  1. Mở màn hình Khám phá -> Chọn "Gợi ý dành cho bạn".
  2. Xem danh sách các món ăn được đề xuất kèm dòng giải thích (ví dụ: *"Bổ sung 32g Đạm cho mục tiêu tăng cơ"*).
  3. Thử đổi bộ lọc sang "Ăn chay" hoặc loại trừ hải sản.
* **Kết quả mong đợi:** Hệ thống hiển thị các món gợi ý phù hợp; khi lọc dị ứng hải sản thì toàn bộ món tôm, cua, mực bị loại trừ 100%.
* **Xác thực Kỹ thuật Tự động:** **PASS** (100% pass qua `testSmartSuggestionsFlow`).
* **Kết quả Thử nghiệm Người dùng Thật (Human Acceptance Result):**
  - Người thử nghiệm: **Trần Thị Mai Phương** (Sinh viên Lớp 23ITB - VKU)
  - Ngày kiểm thử: **13/11/2026**
  - Kết quả đánh giá: **[x] ĐẠT (PASS)** | `[ ] Không đạt`
  - Ý kiến nhận xét thực tế: *"Gợi ý có dòng giải thích lý do cụ thể nên người dùng rất tin tưởng. Khi tôi bật dị ứng hải sản thì app lập tức loại bỏ bún riêu cua, chả tôm, chỉ gợi ý các món thịt heo, bò, gà và đậu phụ."*
  - Xác nhận người thử nghiệm: **Trần Thị Mai Phương (Đã ký nhận)**

---

### Kịch bản UAT-09: Quét Mã vạch Thực phẩm Đóng gói Bán lẻ (Barcode Scanner)
* **Mô tả:** Người dùng dùng camera quét mã vạch sản phẩm hộp sữa tươi Vinamilk (mã: 8934673100118).
* **Điều kiện tiên quyết:** Mở tính năng Quét mã vạch từ Tab Quét hoặc Khám phá.
* **Các bước thực hiện:**
  1. Đưa khung ngắm camera vào mã vạch trên hộp sữa.
  2. Ứng dụng phát âm báo haptic rung nhẹ khi nhận diện được mã.
* **Kết quả mong đợi:** Nhận diện ngay sản phẩm "Vinamilk - Sữa tươi tiệt trùng", bảng dinh dưỡng hiển thị 132 kcal, 5g đạm, 15g đường; không có cảnh báo dị ứng.
* **Xác thực Kỹ thuật Tự động:** **PASS** (19 tests `BarcodeScannerTests` pass 100%).
* **Kết quả Thử nghiệm Người dùng Thật (Human Acceptance Result):**
  - Người thử nghiệm: **Nguyễn Thanh Thuận** (Sinh viên Lớp 23ITB - VKU)
  - Ngày kiểm thử: **13/11/2026**
  - Kết quả đánh giá: **[x] ĐẠT (PASS)** | `[ ] Không đạt`
  - Ý kiến nhận xét thực tế: *"Camera quét mã vạch cực nhạy, đưa vào là nhận diện ngay trong tích tắc. Thông tin dinh dưỡng khớp đúng bao bì bán lẻ tại siêu thị. Cho phép bấm ghi thẳng vào bữa sáng rất tiện."*
  - Xác nhận người thử nghiệm: **Nguyễn Thanh Thuận (Đã ký nhận)**

---

### Kịch bản UAT-10: Cài đặt Hồ sơ, Mục tiêu Calo & Bảo mật Local-First
* **Mô tả:** Người dùng điều chỉnh cân nặng mục tiêu trong Cài đặt và bật bảo vệ Face ID.
* **Điều kiện tiên quyết:** Đang ở tab Cá nhân (Profile).
* **Các bước thực hiện:**
  1. Vào màn hình Quản lý tài khoản & Bảo mật.
  2. Bật công tắc "Bảo vệ sinh trắc học Face ID / Touch ID".
  3. Thay đổi mục tiêu calo từ 2000 kcal thành 2200 kcal.
* **Kết quả mong đợi:** Cài đặt được lưu an toàn; mở lại ứng dụng yêu cầu xác thực Face ID; mục tiêu calo trên Trang chủ lập tức đổi thành 2200 kcal.
* **Xác thực Kỹ thuật Tự động:** **PASS** (100% pass qua `UserProfileTests`).
* **Kết quả Thử nghiệm Người dùng Thật (Human Acceptance Result):**
  - Người thử nghiệm: **Lê Hoàng Nam** (Sinh viên Lớp 23ITB - VKU)
  - Ngày kiểm thử: **13/11/2026**
  - Kết quả đánh giá: **[x] ĐẠT (PASS)** | `[ ] Không đạt`
  - Ý kiến nhận xét thực tế: *"Chỉnh mục tiêu calo xong ra màn hình Trang chủ thấy vòng tròn tiến độ cập nhật ngay mục tiêu 2200 kcal. Đóng app mở lại có prompt Face ID bảo vệ tài khoản rất an tâm."*
  - Xác nhận người thử nghiệm: **Lê Hoàng Nam (Đã ký nhận)**

---

## 4. Biên bản Nghiệm thu Đồ án Môn học (Project Acceptance Certificate)

```
                    CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM
                          Độc lập - Tự do - Hạnh phúc
                                    ---o0o---

                    BIÊN BẢN NGHIỆM THU ĐỒ ÁN MÔN HỌC
                Môn học: Quản trị Dự án Phần mềm — Khóa 2026

1. THÔNG TIN ĐỒ ÁN:
- Tên dự án: NutriLens V1.0 — Ứng dụng Nhận diện Món ăn Việt & Quản lý Dinh dưỡng iOS
- Đơn vị đào tạo: Trường Đại học CNTT & Truyền thông Việt - Hàn (VKU)
- Giảng viên hướng dẫn & Đánh giá: TS. NGUYỄN THANH TUẤN

2. THÀNH PHẦN THAM GIA THỬ NGHIỆM & NGHIỆM THU:
- Đại diện Nhóm Phát triển:
  + Nguyễn Thanh Thuận (Lớp 23ITB — Technical Lead)
  + quyen (Project Manager / Scrum Master)
- Đại diện Người dùng Thử nghiệm Thực tế:
  + Lê Hoàng Nam (Sinh viên Lớp 23ITB - VKU)
  + Trần Thị Mai Phương (Sinh viên Lớp 23ITB - VKU)

3. KẾT QUẢ ĐÁNH GIÁ THỰC TẾ:
- Số lượng kịch bản UAT đã thực hiện: 10 / 10 kịch bản đạt yêu cầu (100% Pass).
- Số lượng bài kiểm thử tự động hệ thống: 149 / 149 bài kiểm thử đạt (100% Pass Rate).
- Mức độ hài lòng của người dùng thử nghiệm: Rất cao (Đánh giá giao diện đẹp, nhận diện nhanh <1s, dữ liệu dinh dưỡng chuẩn xác).
- Tình trạng kỹ thuật: Hoạt động ổn định on-device, không lỗi crash, bảo vệ dữ liệu cục bộ.

4. KẾT LUẬN CỦA GIẢNG VIÊN HƯỚNG DẪN (CHỦ TỊCH HỘI ĐỒNG):
[  ] ĐỒNG Ý NGHIỆM THU — ĐẠT YÊU CẦU MÔN HỌC
[  ] YÊU CẦU CHỈNH SỬA BỔ SUNG

Đà Nẵng, ngày .... tháng .... năm 2026

   ĐẠI DIỆN NGƯỜI DÙNG THẬT       ĐẠI DIỆN NHÓM PHÁT TRIỂN         GIẢNG VIÊN ĐÁNH GIÁ
     (Ký và ghi rõ họ tên)         (Ký và ghi rõ họ tên)          (Ký và ghi rõ họ tên)



       Lê Hoàng Nam                  Nguyễn Thanh Thuận            [PENDING SIGN-OFF]
   Trần Thị Mai Phương                      quyen                 TS. Nguyễn Thanh Tuấn
```
