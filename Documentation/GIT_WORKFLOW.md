# Git Workflow – NutriLens

## Branches
- `main`: trạng thái ổn định.
- `develop`: nhánh tích hợp nếu nhóm cần.
- `feature/<name>`, `fix/<name>`, `docs/<name>`.
- `release/<version>` khi chuẩn bị phát hành.

Không cần tạo tất cả branch cho dự án nhỏ; giữ workflow đơn giản.

## Commit convention
Dùng Conventional Commits:
- `feat: ...`
- `fix: ...`
- `refactor: ...`
- `test: ...`
- `docs: ...`
- `build: ...`
- `chore: ...`

Ví dụ: `feat: add meal history screen`.

## Pull request
Mô tả mục tiêu/phạm vi, thay đổi, ảnh UI nếu có, test và kết quả, migration/config impact, privacy/security impact, limitations. Review correctness, architecture, data integrity, privacy, accessibility, maintainability.

## Protected operations
Không force-push, xóa branch chính, rewrite shared history, xóa tag/release, ghi đè thay đổi chưa commit, commit secrets hoặc dữ liệu cá nhân.

## .gitignore
Rà soát Xcode build/DerivedData, user-specific settings, secrets/local config, temporary exports, dataset/training artifacts không thuộc app. Không ignore nhầm source/model artifact được phép phân phối.

## Collaboration
Mỗi task có owner/phạm vi; tránh nhiều người sửa cùng file lớn; đồng bộ trước khi làm; commit nhỏ; ghi quyết định kiến trúc vào ADR.
