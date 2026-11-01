# Swift Coding Style

## General
Tuân thủ Swift API Design Guidelines. Code rõ nghĩa, dễ đọc; một type/file có trách nhiệm chính. Ưu tiên composition. Access control ở mức tối thiểu cần thiết.

## Naming
- Types/protocols: UpperCamelCase.
- Properties/functions/cases: lowerCamelCase.
- Boolean: isLoading, hasPermission, canSave.
- Tránh viết tắt khó hiểu và tên chung chung.

## Types and safety
Ưu tiên struct cho value types; enum cho trạng thái đóng; final class khi cần reference semantics. Tránh force unwrap, try!, as! trong production. Dùng guard/early return; tránh trạng thái không hợp lệ.

## Error handling
Định nghĩa lỗi theo miền chức năng. Không nuốt lỗi bằng try? nếu ảnh hưởng kết quả. Chuyển lỗi kỹ thuật thành thông báo thân thiện ở Presentation. Không đưa stack trace/path nội bộ/dữ liệu nhạy cảm ra UI.

## Concurrency
Ưu tiên async/await. Dùng @MainActor cho UI-facing state. Dùng actor khi cần bảo vệ mutable shared state. Quản lý task/cancellation. Không dùng DispatchQueue.main.async thay thế tùy tiện cho actor isolation.

## SwiftUI
View nhỏ, chỉ trình bày. Không đặt business logic/truy vấn database phức tạp trong body. Stable identity cho ForEach. Tránh AnyView nếu không cần. Preview dùng fixtures/mock riêng, không kết nối production data.

## Constants and localization
Không hardcode magic numbers/strings. Gom cấu hình có ý nghĩa. Localize UI text; không rải literal ngôn ngữ trong logic. Định dạng ngày/giờ/số theo locale.

## Dependencies
Ưu tiên Apple frameworks. Trước khi thêm package, đánh giá lý do, nguồn, license, maintenance, security, privacy, binary footprint và phương án thay thế; dependency lớn cần phê duyệt.

## Review
Kiểm tra naming, force unwrap, error handling, cancellation, layer boundaries, sensitive logs, test coverage và khả năng đơn giản hóa.
