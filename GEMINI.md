# NutriLens – Project Rules

Version: 1.0 | Scope: toàn bộ repository NutriLens-iOS

## 1. Product
NutriLens là ứng dụng iOS nhận diện món ăn Việt Nam bằng AI, ước tính dinh dưỡng và ghi nhật ký bữa ăn. Mục tiêu là sản phẩm có chất lượng phát hành App Store.

## 2. Approved stack
- Swift, SwiftUI.
- MVVM + Clean Architecture, tổ chức theo feature.
- Core ML; Vision/Core Image khi phù hợp.
- SwiftData cho dữ liệu cục bộ.
- Keychain cho secrets/credentials.
- URLSession chỉ khi thực sự cần networking.
- XCTest, Swift Testing, XCUITest.
- Git/GitHub.

Không tự ý thay đổi stack. Đề xuất thay đổi phải nêu lý do, tác động, lựa chọn thay thế và chờ phê duyệt.

## 3. AI Agent workflow
Trước khi sửa: đọc file này và tài liệu liên quan; kiểm tra repository, trạng thái Git, code và cấu hình thực tế; xác định phạm vi và kế hoạch.
Trong khi sửa: chỉ thay đổi phạm vi cần thiết; tái sử dụng code; không tạo file rỗng; không thêm dependency tùy tiện; không dùng mock trong production; không xóa/ghi đè dữ liệu hoặc code quan trọng khi chưa được duyệt.
Sau khi sửa: chạy build/test phù hợp; báo chính xác lệnh và kết quả; liệt kê file tạo/sửa/xóa; nêu hạn chế và rủi ro. Không tuyên bố thành công nếu chưa kiểm chứng.

## 4. Architecture
- View chỉ trình bày UI và chuyển tiếp hành động.
- ViewModel quản lý presentation state, gọi Use Case.
- Domain không phụ thuộc SwiftUI, SwiftData, Core ML.
- Repository protocol tách khỏi implementation.
- Data triển khai repository.
- AI được truy cập qua abstraction; không gọi Core ML trực tiếp từ View.
- Dependency Injection rõ ràng; tránh global mutable state/Singleton tùy tiện.
- Ưu tiên async/await; cập nhật UI đúng MainActor.
- Xử lý lỗi có kiểu; tránh nuốt lỗi bằng try? và tránh force unwrap.

## 5. AI and data integrity
- Inference nhận diện chạy on-device; không upload ảnh để nhận diện.
- Không tự huấn luyện lại, ghi đè checkpoint, đổi class mapping, preprocessing hoặc OOD threshold đã khóa.
- Không tạo model giả hoặc trình bày mock như AI thật.
- Phân biệt nhãn dự đoán, confidence, khẩu phần và dinh dưỡng.
- Confidence classifier không đồng nghĩa độ chính xác dinh dưỡng.
- Dữ liệu dinh dưỡng phải có nguồn/phương pháp.
- Xác minh quyền sử dụng dataset, ảnh, weights và model trước phân phối. MIT của code không tự động cấp quyền ảnh/model; chuyển sang Core ML không thay đổi license.

## 6. UI/UX
Fresh & Healthy, xanh lá làm màu nhấn, nền sáng/trung tính, SF system fonts, Dynamic Type, Dark Mode, Accessibility. Token màu/spacing/typography/radius tập trung trong Design System. Màn hình xử lý loading, success, empty, error, permission-denied và offline state phù hợp.

## 7. Security and privacy
- Không hardcode/commit API keys, tokens, passwords, certificates.
- Keychain cho credentials; không lưu secrets trong UserDefaults/SwiftData.
- Không log ảnh, token hoặc dữ liệu nhạy cảm.
- Chỉ xin quyền camera/photo khi cần; ưu tiên picker giới hạn.
- Thu thập tối thiểu; không bật analytics/tracking hoặc cloud upload âm thầm.
- Cloud sync là tính năng tùy chọn, cần consent và thiết kế bảo vệ dữ liệu.
- Tuân thủ SECURITY.md và PRIVACY.md.

## 8. Git
Không force-push, rewrite shared history, xóa branch chính hoặc ghi đè thay đổi chưa commit. Không commit secrets, dữ liệu cá nhân, build artifacts. Theo GIT_WORKFLOW.md.

## 9. Phải xin phép trước
Thay đổi kiến trúc/stack; xóa hoặc di chuyển dữ liệu; migration/schema đã phát hành; model/class mapping/preprocessing/OOD; thêm cloud, analytics, tracking, SDK; thay đổi privacy/entitlements/signing/Bundle ID; thêm dependency lớn; thao tác có nguy cơ mất dữ liệu.

## 10. Definition of Done
Đúng phạm vi và kiến trúc; build thành công; test liên quan đã chạy; có xử lý lỗi và UI states; không regression; không còn rủi ro privacy/security chưa xử lý; tài liệu cập nhật; báo cáo trung thực.

## 11. Priority
1. Data integrity 2. Security & privacy 3. Correctness 4. Maintainability 5. Accessibility/UX 6. Performance 7. Speed.

Khi thiếu thông tin, nêu giả định và hỏi; không biến đề xuất thành quyết định chính thức.
