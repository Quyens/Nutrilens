# ĐÁNH GIÁ PIPELINE KIỂM THỬ TỰ ĐỘNG GITHUB ACTIONS (IOS CI WORKFLOW REVIEW)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/github_audit/06_ios_ci_workflow_review.md`  
**Tệp cấu hình kiểm tra:** `.github/workflows/ios-ci.yml`  
**Ngày thẩm định:** 13 tháng 11 năm 2026  
**Trạng thái kích hoạt:** `DRAFT READY (LOCAL)` | Chờ lệnh push của người dùng để thực thi trên GitHub Actions.

---

## 1. Mục Đích & Chuẩn Mực Tự Động Hóa (CI/CD Objectives)

Trong quản trị dự án phần mềm hiện đại, quy trình Tích hợp Liên tục (Continuous Integration - CI) bảo đảm:
1. Mọi commit và Pull Request đều được biên dịch độc lập trên máy chủ sạch (clean runner), loại bỏ tình trạng *"chạy được trên máy tôi nhưng lỗi trên máy bạn"*.
2. Bộ kiểm thử hồi quy (Regression Testing) được kích hoạt tự động, ngăn chặn các lỗi phá vỡ tính tương thích khi bổ sung tính năng mới.
3. Xuất file bằng chứng thực thi (Test Artifacts) phục vụ thanh tra và đánh giá học thuật của Giảng viên.

---

## 2. Phân Tích Kỹ Thuật Tệp Cấu Hình `.github/workflows/ios-ci.yml`

### 2.1. Cấu Hình Máy Chủ Chạy (Runner Environment)
- **Hệ điều hành runner:** `macos-14` (Chạy trên chip Apple Silicon M1/M2 của hạ tầng GitHub Hosted Runner).
- **Môi trường phát triển:** Tự động phát hiện và chọn **Xcode 16.0** (hoặc fallback về Xcode 15.4 nếu hạ tầng GitHub chưa nạp đủ bản 16):
  ```bash
  sudo xcode-select -s /Applications/Xcode_16.0.app/Contents/Developer || sudo xcode-select -s /Applications/Xcode_15.4.app/Contents/Developer
  ```

### 2.2. Kiểm Soát Sự Kiện Kích Hoạt (Triggers)
- Tự động chạy khi có sự kiện `push` lên các nhánh:
  - `main`: Nhánh chính sản phẩm.
  - `feature/**`: Các nhánh tính năng đang phát triển.
  - `checkpoint/**`: Các mốc kiểm định kiến trúc.
- Tự động chạy khi có sự kiện `pull_request` mở vào nhánh `main`.

### 2.3. Các Bước Thực Thi (Step-by-Step Execution Flow)
1. **Checkout Source Code:** Dùng action tiêu chuẩn `actions/checkout@v4`.
2. **Clean DerivedData:** Xóa sạch bộ nhớ đệm cũ nhằm tránh rủi ro biên dịch sai lệch `rm -rf ~/Library/Developer/Xcode/DerivedData/NutriLens*`.
3. **Build NutriLens (Simulator Destination):**
   - Lệnh: `xcodebuild clean build -project NutriLens.xcodeproj -scheme NutriLens -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" CODE_SIGNING_ALLOWED=NO`
   - Ghi toàn bộ log biên dịch vào `build/logs/xcodebuild-build.log`.
4. **Run Unit Tests Suite:**
   - Thực thi độc lập 139 bài kiểm thử đơn vị thông qua tham số `-only-testing:NutriLensTests`.
   - Xuất gói kết quả kiểm thử chuẩn Apple: `build/test-results/UnitTests.xcresult`.
5. **Run UI Tests Suite:**
   - Chạy 10 luồng kiểm thử giao diện `NutriLensUITests`.
   - Xuất gói kết quả: `build/test-results/UITests.xcresult`.
6. **Lưu trữ & Đính kèm Bằng chứng (Upload Artifacts):**
   - Sử dụng `actions/upload-artifact@v4` để đóng gói log và file `.xcresult` lưu trữ trong 14 ngày.

---

## 3. Thẩm Định An Toàn & Bảo Mật (Security & Secrets Compliance)

- **Không sử dụng Certificates / Provisioning Profile giả:** Do chạy trên môi trường iOS Simulator, lệnh build sử dụng cờ `CODE_SIGNING_ALLOWED=NO`, tuyệt đối không cần chứng chỉ trả phí và không yêu cầu nạp bí mật (Secrets) lên GitHub Repository Settings.
- **Không để lộ khóa bảo mật:** Không có bất kỳ token, secret key hay dữ liệu đăng nhập nào xuất hiện trong tệp cấu hình YAML.

---

## 4. Kết Quả Kiểm Tra Tính Đúng Đắn Cú Pháp (Syntax Validation)

Đã kiểm tra cấu trúc cú pháp YAML bằng bộ parser độc lập:
- Cú pháp YAML: **HỢP LỆ (SYNTAX VALID)**.
- Khả năng tương thích Xcode Scheme: Khớp chính xác tên scheme `NutriLens` và project `NutriLens.xcodeproj`.
- Bộ targets kiểm thử: Khớp chính xác 2 bundle `NutriLensTests` và `NutriLensUITests`.

> [!NOTE]
> **Trạng thái thực thi:** Hiện tại pipeline chưa chạy trên máy chủ GitHub do mã nguồn `.github/workflows/ios-ci.yml` chưa được đẩy lên remote theo yêu cầu an toàn. Ngay khi người dùng cho phép push, GitHub Actions sẽ tự động ghi nhận workflow này.

