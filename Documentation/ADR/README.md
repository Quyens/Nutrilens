# Architecture Decision Records (ADR)

Ghi lại quyết định kỹ thuật ảnh hưởng đáng kể đến kiến trúc/sản phẩm.

## Khi cần ADR
Thay đổi stack/deployment target; thêm backend/cloud/account; đổi database; đổi model/preprocessing/OOD; thêm SDK/dependency có ảnh hưởng privacy/security; đổi cách lưu ảnh/dữ liệu; thay đổi kiến trúc/navigation lớn.

## Naming
`NNNN-short-title.md`, ví dụ `0001-on-device-coreml.md`.

## Template
```markdown
# ADR NNNN: Title
- Status: Proposed | Accepted | Rejected | Superseded
- Date: YYYY-MM-DD
- Owners:

## Context
Vấn đề và bối cảnh.

## Decision
Quyết định được chọn.

## Alternatives
Các lựa chọn đã cân nhắc.

## Consequences
Lợi ích, đánh đổi, rủi ro và tác động.

## Evidence
Link, benchmark, test hoặc tài liệu hỗ trợ.
```
