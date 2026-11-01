# UI/UX Rules – NutriLens

## Product experience
Phong cách Fresh & Healthy: hiện đại, tin cậy, thân thiện, phù hợp iOS. Tối ưu luồng chụp/chọn ảnh → nhận diện → xác nhận/chỉnh sửa → chỉnh khẩu phần → xem dinh dưỡng → lưu bữa ăn.

## Visual system
- Xanh lá làm màu nhấn; nền sáng/trung tính, tương phản đủ.
- SF system fonts, Dynamic Type.
- Màu, typography, spacing, radius, elevation tập trung trong Design System.
- Dark Mode cần được kiểm tra riêng.
- Không dùng màu làm tín hiệu duy nhất.

## Reusable components
Primary/secondary buttons, inputs, cards, section headers, loading/empty/error states, confirmation dialogs và nutrition components khi có nhu cầu tái sử dụng thực tế. Không abstraction hóa một trường hợp đơn lẻ không cần thiết.

## Screen states
Xác định trạng thái initial/loading/content/empty/error/retry/permission denied/offline/disabled phù hợp. Không để màn hình trắng hoặc spinner vô hạn.

## Recognition flow
1. Người dùng chủ động mở camera hoặc picker.
2. Chụp/chọn ảnh.
3. Hiển thị đang phân tích.
4. Hiển thị kết quả và confidence theo cách dễ hiểu.
5. Cho phép sửa/chọn món nếu nhận diện sai.
6. Cho phép chỉnh khẩu phần/đơn vị.
7. Hiển thị dinh dưỡng ước tính và nguồn/phương pháp.
8. Chỉ lưu sau khi người dùng xác nhận.

Ảnh ngoài phạm vi mô hình phải được thông báo rõ; có thể chọn thủ công hoặc thử lại.

## Accessibility
Hỗ trợ Dynamic Type, VoiceOver, contrast, tap targets phù hợp, Reduce Motion, focus order và mô tả biểu đồ bằng văn bản.

## Motion
Animation ngắn, có mục đích; không cản trở thao tác; tôn trọng Reduce Motion.

## Localization and trust
Ưu tiên tiếng Việt nếu là thị trường đầu tiên. Ngày/giờ/số/đơn vị theo locale. Gọi kết quả là “ước tính” khi không đo trực tiếp. Không tuyên bố chẩn đoán/điều trị.
