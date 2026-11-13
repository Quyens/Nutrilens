# Quy Chuẩn Đóng Góp & Quy Trình Phát Triển NutriLens V1.0 (Contributing Guidelines)

Tài liệu này quy định quy chuẩn làm việc cộng tác mã nguồn, quản lý nhánh Git, quy tắc đặt tên commit và quy trình kiểm duyệt Pull Request trong dự án **NutriLens V1.0** — phục vụ môn học **Quản trị dự án phần mềm — VKU** (Giảng viên hướng dẫn: **TS. Nguyễn Thanh Tuấn**).

---

## 1. Nguyên Tắc Quản Trị Nhánh (Branching Strategy)

Dự án áp dụng mô hình phân nhánh chuẩn **GitHub Flow / Feature Branching**:

- `main`: Nhánh chính phản ánh phiên bản mã nguồn ổn định, đã qua kiểm định tự động và kiểm duyệt ngang hàng (peer review). Tuyệt đối **không push trực tiếp** lên nhánh `main`.
- `feature/<tên-tính-năng>`: Nhánh phát triển tính năng mới (ví dụ: `feature/phase06-barcode-scanner`, `feature/smart-suggestions`).
- `fix/<tên-lỗi>`: Nhánh sửa lỗi phát sinh từ kết quả kiểm thử hoặc phản hồi người dùng.
- `checkpoint/<mốc-kiểm-định>`: Nhánh ghi nhận các điểm mốc kiến trúc ổn định đã vượt qua bộ test suite.

---

## 2. Quy Chuẩn Đặt Tên Commit (Conventional Commits Standard)

Toàn bộ các thành viên nhóm (`Quyens`, `thuan5587`, `Thai1123`) thống nhất tuân thủ chuẩn **Conventional Commits v1.0.0** cho các commit mới:

### 2.1. Cấu Trúc Thông Điệp Commit
```text
<type>(<scope>): <mô tả ngắn gọn về thay đổi>

[Phần mô tả chi tiết nếu cần]

[Liên kết Issue / Mã WBS: e.g., Resolves #12, Ref: WBS 1.3.7]
```

### 2.2. Các Tiền Tố (Commit Types) Được Chấp Thuận
- `feat`: Thêm mới một tính năng hoặc use case nghiệp vụ (ví dụ: `feat(scanner): add AVFoundation camera viewfinder`).
- `fix`: Sửa lỗi logic, lỗi giao diện hoặc lỗi persistent data (ví dụ: `fix(diary): resolve macro calculation for portion slider`).
- `refactor`: Tái cấu trúc mã nguồn mà không làm thay đổi hành vi nghiệp vụ (ví dụ: `refactor(domain): decouple Core ML dependency from presentation`).
- `test`: Thêm mới hoặc cải thiện bộ kiểm thử tự động Unit/UI Test (ví dụ: `test(barcode): add 14 unit test cases for EAN-13 checksum`).
- `docs`: Cập nhật tài liệu quản trị dự án, báo cáo kỹ thuật, hướng dẫn sử dụng (ví dụ: `docs(qlda): add WBS dictionary and CPM schedule`).
- `chore`: Các tác vụ bảo trì cấu hình Xcode, kịch bản build, CI pipeline (ví dụ: `chore(ci): configure macos-14 runner for Xcode 16`).

---

## 3. Quy Trình Tạo & Thẩm Định Pull Request (PR & Peer Review)

1. **Chuẩn bị:** Trước khi tạo PR, nhà phát triển phải đảm bảo:
   - Ứng dụng biên dịch thành công `0 errors, 0 warnings`.
   - Toàn bộ Unit Tests và UI Tests liên quan đã vượt qua 100% trên iOS Simulator.
   - Mã nguồn tuân thủ Clean Architecture + MVVM (Domain độc lập hoàn toàn với SwiftUI/SwiftData).
2. **Khởi tạo PR:**
   - Sử dụng đúng mẫu `.github/PULL_REQUEST_TEMPLATE.md`.
   - Liên kết rõ ràng đến GitHub Issue và mã WBS tương ứng.
   - Đính kèm ảnh chụp màn hình minh chứng giao diện (nếu có thay đổi UI).
3. **Kiểm duyệt ngang hàng (Peer Review):**
   - Yêu cầu tối thiểu **01 thành viên khác trong nhóm** thực hiện review và phê duyệt (Approve) trước khi merge.
   - Thẩm định viên kiểm tra kỹ các tiêu chí: bảo mật (không lộ credentials), xử lý lỗi có kiểu (không force unwrap `!`), tuân thủ Design System Botanical.
4. **Hợp nhất (Merge):**
   - Chỉ được hợp nhất vào nhánh `main` khi CI pipeline thông qua và PR được duyệt.
   - Khuyến khích sử dụng *Squash and Merge* hoặc *Merge Commit* giữ nguyên lịch sử đóng góp.

---

## 4. Bảng Phân Công Vai Trò & Thẩm Quyền (RACI Matrix)

| Thành viên | GitHub Account | Vai trò dự án | Thẩm quyền chính |
| :--- | :--- | :--- | :--- |
| **Trần Văn Quyền** | `@Quyens` | Project Manager / Tech Lead | Quản trị Repo, Duyệt PR chính, Cấu hình CI/CD, Điều phối WBS |
| **Nguyễn Thanh Thuận** | `@thuan5587` | Data & Backend Lead / QA | Quản trị Dữ liệu Món ăn, Kiểm thử UAT, Review PR Domain & Data |
| **Thái** | `@Thai1123` | Mobile UI/UX & AI Engineer | Thiết kế giao diện Botanical, Tích hợp Model Core ML, Review UI |

---

## 5. Chính Sách Bảo Mật & Liêm Chính Học Thuật (Academic Integrity)

- Tuyệt đối **không hardcode** bất kỳ API keys, tokens, mật khẩu hoặc chứng chỉ cá nhân vào kho mã nguồn.
- Mọi bằng chứng kiểm thử, kết quả UAT và số liệu Velocity trong báo cáo phải dựa trên dữ liệu đo lường thực tế, không tạo số liệu giả mạo.

