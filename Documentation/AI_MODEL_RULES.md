# AI Model Rules – NutriLens

## Objective
Nhận diện món ăn on-device bằng Core ML. Model hiện có được nhắc đến trong dự án nghiên cứu là EfficientNet-B0 Experiment B; phải xác minh artifact thực tế trước khi tích hợp.

## Source of truth
Kiểm tra checkpoint + SHA-256, class mapping/order, metadata, model card, preprocessing config, tensor shape/dtype, báo cáo đánh giá và quyền sử dụng. License của code repository không tự động cấp quyền ảnh/weights/model. Core ML conversion không thay đổi license.

## Locked artifacts
Không tự huấn luyện/fine-tune, ghi đè checkpoint, đổi class order, preprocessing, OOD threshold, quantize/prune hoặc đổi precision trước baseline parity nếu chưa được duyệt. Mọi thay đổi phải có version, checksum và report riêng.

## Preprocessing
Xác minh color order, EXIF orientation, resize/crop/interpolation, input shape/dtype/range và normalization từ cấu hình đã audit. Test RGB, RGBA, grayscale, orientation khác nhau, ảnh lỗi và kích thước khác nhau. Không suy đoán cấu hình từ tên model.

## Conversion and parity
Giữ model gốc; export vào output riêng; lưu tool versions và conversion config. So sánh PyTorch/Core ML trên cùng input. Đánh giá Top-1/Top-5 agreement, logit error, confidence drift và outliers. Ngưỡng chấp nhận phải ghi rõ là tiêu chí dự án, không phải bảo đảm chung. Không tích hợp production nếu parity chưa đạt hoặc sai lệch chưa giải thích.

## Inference API
Service validate input; trả class ID/slug, display name, confidence, model version và Top-K khi cần. Lỗi có kiểu: model unavailable, invalid image, unsupported input, inference failure, cancelled. Không block main thread, không log ảnh.

## Confidence and OOD
Phân biệt classifier confidence với OOD score. Không gọi confidence là xác suất đúng đã calibration nếu chưa chứng minh. Threshold phải có provenance, tập calibration và trade-off false accept/reject. Không tune trên test set độc lập. OOD phải có hướng dẫn chọn thủ công/thử lại.

## Performance
Đo cold-start, first/warm inference, P50/P95 latency, peak memory, package size trên thiết bị thật. `.all` không chứng minh Neural Engine; chỉ kết luận theo profiling/measurement.

## Nutrition boundary
Classifier nhận diện nhãn, không tự xác định khối lượng hay dinh dưỡng chính xác. Nutrition cần nguồn dữ liệu riêng, khẩu phần/đơn vị, phương pháp ánh xạ/tính toán, sai số và khả năng chỉnh sửa của người dùng.

## Release gate
Xác minh quyền phân phối; checksum; class mapping/preprocessing; parity; OOD; performance trên thiết bị; model card và limitations trước khi phát hành.
