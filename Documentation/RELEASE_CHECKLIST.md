# Release Checklist – NutriLens

> Kiểm tra lại yêu cầu Apple hiện hành tại thời điểm phát hành.

## Product
- [ ] Core flow hoạt động end-to-end.
- [ ] Sửa được kết quả nhận diện.
- [ ] Khẩu phần/đơn vị rõ ràng.
- [ ] Dinh dưỡng được trình bày là ước tính.
- [ ] Loading/empty/error/offline đầy đủ.
- [ ] Không còn mock/placeholder trong production.
- [ ] Localization và nội dung được rà soát.

## AI/model
- [ ] Artifact đúng version/checksum.
- [ ] Quyền sử dụng/phân phối dataset, ảnh, weights, model đã xác minh.
- [ ] Conversion report có thể tái lập.
- [ ] Numerical parity đạt tiêu chí.
- [ ] Class mapping/preprocessing được khóa.
- [ ] OOD trade-off được đánh giá.
- [ ] Performance đo trên thiết bị thật.
- [ ] Model limitations được ghi nhận.

## Data
- [ ] CRUD hoạt động.
- [ ] Migration được kiểm thử.
- [ ] Xóa dữ liệu bao gồm file liên quan.
- [ ] Export hoạt động nếu có.
- [ ] Kiểm tra các luồng đóng app bất thường.

## Security/privacy
- [ ] Không có secrets trong source/build.
- [ ] Keychain dùng đúng mục đích.
- [ ] Permissions tối thiểu và đúng.
- [ ] Không upload ảnh ngoài hành vi đã thông báo/đồng ý.
- [ ] Logging đã redact.
- [ ] Dependencies/SDK được rà soát.
- [ ] Privacy manifest/required-reason APIs được rà soát.
- [ ] App Privacy Details khớp implementation.
- [ ] Privacy Policy công khai sẵn sàng.
- [ ] Account deletion nếu có account.

## Quality
- [ ] Unit tests pass.
- [ ] Integration tests pass.
- [ ] UI tests core flows pass.
- [ ] Regression tests pass.
- [ ] Không có crash blocker.
- [ ] Accessibility/Dark Mode/Dynamic Type review.
- [ ] Performance/memory review trên thiết bị thật.

## App Store
- [ ] Bundle ID được xác nhận.
- [ ] Signing/provisioning hợp lệ.
- [ ] App icon và launch experience.
- [ ] Version/build number.
- [ ] Supported devices/orientations.
- [ ] Screenshots/metadata.
- [ ] Age rating/content declarations.
- [ ] Export compliance được trả lời chính xác.
- [ ] Privacy URL/support URL.
- [ ] TestFlight review.
- [ ] App Review notes nếu cần.

## Final gate
Không phát hành nếu còn vấn đề nghiêm trọng về quyền model/dataset, crash/mất dữ liệu, sai lệch AI chưa hiểu, khai báo privacy sai hoặc secret bị lộ. Ghi ngày, version, commit SHA, test evidence và risk acceptance.
