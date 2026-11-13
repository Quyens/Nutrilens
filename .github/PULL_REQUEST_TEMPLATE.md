## 1. Thông Tin Định Danh & Công Việc (Identification & Traceability)
- **Liên kết Issue:** Resolves #<Issue_Number>
- **Mã gói WBS:** `<WBS_Code>` (Ví dụ: `WBS 1.3.7 - Barcode Scanner & Packaged Food`)
- **Nhánh đích:** `main` | **Nhánh nguồn:** `<feature_branch>`
- **Người thực hiện (Author):** @<github_username>
- **Người thẩm định chỉ định (Assigned Reviewer):** @<github_username>

---

## 2. Tóm Tắt Thay Đổi (Summary of Changes)
- [ ] Bổ sung tính năng mới (New Feature)
- [ ] Sửa lỗi phần mềm (Bug Fix)
- [ ] Tái cấu trúc mã nguồn (Refactoring)
- [ ] Bổ sung / Cải tiến kiểm thử tự động (Testing)
- [ ] Cập nhật tài liệu quản trị dự án (Documentation)

*Mô tả tóm tắt nội dung thay đổi:*
...

---

## 3. Đánh Giá Rủi Ro & Ảnh Hưởng Hệ Thống (Risk Assessment)
- **Mức độ rủi ro:** [ ] Thấp (Low) | [ ] Trung bình (Medium) | [ ] Cao (High)
- **Khu vực có thể bị ảnh hưởng:** (Ví dụ: SwiftData migration, Camera AVFoundation permission, Core ML memory footprint, Tab Bar navigation flow)
- **Kế hoạch giảm thiểu / Rollback:** ...

---

## 4. Bằng Chứng Kiểm Định Kỹ Thuật (QA & Verification Evidence)
- [ ] Ứng dụng biên dịch thành công 0 errors, 0 warnings: `xcodebuild clean build`
- [ ] Bộ kiểm thử Unit Tests liên quan đã chạy thành công: `.../.. tests passed`
- [ ] Bộ kiểm thử UI Tests liên quan đã chạy thành công trên iOS Simulator
- [ ] Đính kèm ảnh chụp màn hình / video demo minh chứng (nếu có thay đổi UI):

| Trước khi thay đổi (Before) | Sau khi thay đổi (After) |
| :---: | :---: |
| *(Kéo thả ảnh hoặc dán link)* | *(Kéo thả ảnh hoặc dán link)* |

---

## 5. Bảng Kiểm Tra Duyệt Code (Reviewer Checklist)
*Người thẩm định độc lập kiểm tra và tích chọn trước khi phê duyệt:*
- [ ] Tuân thủ kiến trúc Clean Architecture + MVVM theo quy định dự án (`GEMINI.md`).
- [ ] Tầng Domain hoàn toàn độc lập, không phụ thuộc vào SwiftUI, SwiftData hoặc Core ML.
- [ ] Không có API keys, mật khẩu, credentials hoặc dữ liệu nhạy cảm hardcode trong mã nguồn.
- [ ] Không sử dụng force unwrap (`!`) hoặc `try?` nuốt lỗi nguy hiểm không có logging.
- [ ] Giao diện tuân thủ chuẩn Apple Human Interface Guidelines và Design System Fresh Botanical.
- [ ] Đã chạy kiểm thử tự động trên máy local hoặc CI pipeline báo xanh (Green).

---

## 6. Kết Quả Thẩm Định & Phê Duyệt (Peer Review Sign-off)
- **Trạng thái:** [ ] APPROVED | [ ] CHANGES REQUESTED
- **Thẩm định viên (Reviewer):** @<github_username>
- **Ngày thẩm định:** DD/MM/YYYY
- **Nhận xét chuyên môn:** ...
