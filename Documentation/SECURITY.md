# Security Policy – NutriLens

## Principles
Bảo vệ dữ liệu người dùng, tính toàn vẹn ứng dụng và chuỗi cung ứng phần mềm. Bảo mật phải được thiết kế từ đầu.

## Secrets
Không hardcode/commit API keys, tokens, passwords, certificates, private keys hoặc signing credentials. Dùng Keychain cho credentials trên thiết bị; không dùng UserDefaults/SwiftData. Nếu lộ secret: revoke/rotate và đánh giá phạm vi, không chỉ xóa khỏi file hiện tại.

## Data protection
Thu thập tối thiểu; lưu cục bộ phù hợp; xem xét Data Protection class; có retention/lifecycle cho ảnh. Xóa dữ liệu phải xử lý cả file và metadata. Không log dữ liệu cá nhân, ảnh hoặc token.

## Permissions
Chỉ xin camera/photo khi cần, giải thích mục đích, ưu tiên Photos Picker khi phù hợp. Xử lý denied/restricted. Không xin microphone/location/contacts nếu không có use case.

## Networking
Nếu có: HTTPS/TLS, validate input/output, timeout/retry giới hạn, không upload ảnh nhận diện theo mặc định, không log body nhạy cảm, không tắt TLS validation. Không nhúng credential backend quyền cao trong client.

## Dependencies
Trước khi thêm: xác minh nguồn/publisher, license, maintenance, security advisories, quyền truy cập dữ liệu, binary size và transitive dependencies.

## Local files/database
Validate dữ liệu import; migration có strategy; ngăn path traversal; giới hạn loại/kích thước file; không thực thi nội dung tải về.

## Logging
Redact dữ liệu nhạy cảm; không verbose logging production. Crash/diagnostic SDK cần privacy review và consent phù hợp.

## Release checklist
- [ ] Không có secrets trong source/build.
- [ ] Entitlements tối thiểu.
- [ ] Permission strings đúng.
- [ ] Privacy manifest/required-reason APIs được rà soát.
- [ ] Dependencies được rà soát.
- [ ] Logs đã redact.
- [ ] Data deletion hoạt động.
- [ ] Network dùng HTTPS.
- [ ] Threat review cho feature mới.
