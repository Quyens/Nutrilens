# Testing Strategy – NutriLens

## Goals
Ngăn regression; xác minh business rules, data integrity và AI behavior. Test phải lặp lại được, kết quả báo cáo trung thực.

## Test pyramid
- **Unit:** entities, use cases, validation, business rules, ViewModel transitions, mappers.
- **Integration:** repositories, SwiftData, file storage/deletion, Core ML loading/inference, dependency wiring.
- **UI:** onboarding/navigation, camera/photo permission, recognition, edit result/portion, save/history, empty/error/retry, accessibility identifiers.

## AI tests
Model loading; valid/invalid/corrupt images; orientation/color channels; input shape/dtype/preprocessing; Top-K/class mapping; OOD; cancellation/error; PyTorch/Core ML parity on identical prepared inputs. Test set phải có nguồn/version và tách biệt phù hợp.

## Persistence tests
Create/read/update/delete; relaunch persistence; migration; missing image; duplicate save; deletion consistency; date/time/locale edge cases.

## Performance
Đo launch, cold/warm inference, P50/P95, memory, preprocessing, database và scrolling. Simulator chỉ dùng kiểm tra cơ bản; kết luận hiệu năng thiết bị phải đo trên thiết bị thật.

## Test data
Dùng fixtures nhỏ có kiểm soát; không commit dữ liệu cá nhân; ghi nguồn/license test images; mock chỉ ở Preview/unit/UI test; integration test dùng implementation thật khi cần; không để mock repository trong production.

## CI
Build đúng scheme/configuration; chạy unit tests và UI tests khả thi; lưu test results; không bỏ qua failure để pipeline xanh giả.

## Bug report
Environment/device/OS, build/commit, steps, expected/actual, redacted logs, severity và regression test.

## Done
Test liên quan đã chạy; command/result được ghi; không che failure; test mới bao phủ logic quan trọng.
