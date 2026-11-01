# Privacy – Engineering Rules

## Principles
Privacy by design, data minimization, local-first, transparency và user control. Không thu thập/upload ẩn; không analytics/tracking mặc định.

## Default data flow
Thiết kế mặc định: ảnh xử lý trên thiết bị; meal diary lưu cục bộ; không bắt buộc tài khoản cho core flow; không upload ảnh để inference; không bật cloud sync khi chưa có thiết kế và consent. Đây là nguyên tắc, phải xác minh implementation trước khi tuyên bố với người dùng.

## Data inventory
Trước phát hành lập bảng: data element, purpose, source, storage, retention, sharing/recipient, user controls/deletion và App Store disclosure category. Không thu thập “để dành sau này”.

## Photos and camera
Chỉ truy cập khi người dùng chủ động; ưu tiên picker giới hạn; không scan thư viện nền; không upload mặc định; xác định ảnh lưu cùng meal hay chỉ xử lý tạm; cung cấp hành vi xóa rõ ràng.

## Nutrition/health context
Dữ liệu bữa ăn/dinh dưỡng có thể nhạy cảm. Không dùng cho quảng cáo; không chia sẻ ngoài mục đích đã thông báo; không log; không đưa ra chẩn đoán/điều trị. HealthKit trong tương lai cần permission theo từng loại dữ liệu và privacy review.

## Account/cloud
Account/cloud không mặc định thuộc v1. Nếu thêm: xác định dữ liệu đồng bộ, mã hóa phù hợp, consent rõ, logout/revoke/delete account, không nhúng secret quyền cao trong client.

## App Store privacy
Rà soát privacy manifest và required-reason APIs theo yêu cầu Apple hiện hành; khai báo App Privacy Details đúng hành vi app/SDK; có Privacy Policy; kiểm tra SDK và permission purpose strings.

## User controls
Khi phù hợp: xem/sửa/xóa meal, xóa ảnh, xóa toàn bộ local data, export dữ liệu; nếu có account, cung cấp account deletion theo yêu cầu nền tảng.

Tài liệu này là quy tắc kỹ thuật nội bộ, không thay thế Privacy Policy pháp lý công khai.
