# NutriLens iOS

Ứng dụng iOS nhận diện món ăn Việt Nam bằng AI, ước tính giá trị dinh dưỡng và hỗ trợ ghi nhật ký bữa ăn.

## Mục tiêu
- Chụp/chọn ảnh món ăn.
- Nhận diện on-device bằng Core ML.
- Cho phép xác nhận/chỉnh sửa món và khẩu phần.
- Ước tính dinh dưỡng có nguồn/phương pháp.
- Lưu nhật ký cục bộ, ưu tiên offline và quyền riêng tư.

NutriLens cung cấp thông tin ước tính tham khảo, không phải công cụ chẩn đoán hay thay thế tư vấn chuyên môn.

## Tech stack
| Layer | Công nghệ |
|---|---|
| Platform | iOS |
| Language/UI | Swift, SwiftUI |
| Architecture | MVVM + Clean Architecture |
| AI | Core ML |
| Image | Vision / Core Image khi phù hợp |
| Persistence | SwiftData |
| Secrets | Keychain |
| Networking | URLSession khi cần |
| Tests | XCTest / Swift Testing / XCUITest |

## Repository boundary
Repository này chỉ chứa ứng dụng iOS. Dataset, training pipeline và PyTorch checkpoints nằm ở repository riêng. Chỉ đưa artifact cần thiết, đã xác minh quyền phân phối, vào app.

## Tài liệu
- [Project rules](GEMINI.md)
- [Architecture](Documentation/ARCHITECTURE.md)
- [Swift style](Documentation/SWIFT_STYLE.md)
- [UI/UX](Documentation/UI_UX_RULES.md)
- [AI model](Documentation/AI_MODEL_RULES.md)
- [Security](Documentation/SECURITY.md)
- [Privacy](Documentation/PRIVACY.md)
- [Testing](Documentation/TESTING.md)
- [Git workflow](Documentation/GIT_WORKFLOW.md)
- [Release checklist](Documentation/RELEASE_CHECKLIST.md)
- [ADR](Documentation/ADR/README.md)

Các tài liệu là quy tắc/định hướng, không chứng minh tính năng đã được triển khai.
