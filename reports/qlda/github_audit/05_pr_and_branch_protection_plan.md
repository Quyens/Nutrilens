# KẾ HOẠCH BẢO VỆ NHÁNH & QUY TRÌNH KIỂM DUYỆT PULL REQUEST (BRANCH PROTECTION & PR PLAN)
## DỰ ÁN: NUTRILENS V1.0 — MÔN HỌC QUẢN TRỊ DỰ ÁN PHẦN MỀM (VKU)
### GIẢNG VIÊN HƯỚNG DẪN: TS. NGUYỄN THANH TUẤN

**Mã tài liệu:** `reports/qlda/github_audit/05_pr_and_branch_protection_plan.md`  
**Ngày lập kế hoạch:** 13 tháng 11 năm 2026  
**Trạng thái kích hoạt:** `PENDING USER AUTHORIZATION` (Đã chuẩn bị quy chuẩn, chờ người dùng thiết lập trên GitHub Settings)

---

## 1. Hiện Trạng & Bài Học Kinh Nghiệm Từ Lịch Sử (Audit Findings)

- **Thực tế đã diễn ra:**
  - Nhóm đã khởi tạo nhánh `feature/phase01-authentication` và tạo `PR #1 (authentication)` trên GitHub vào ngày 06/11/2026.
  - Tuy nhiên, do thói quen làm việc cục bộ, PR này bị đóng (`Closed`) và việc hợp nhất được thực hiện qua lệnh merge trên máy cá nhân rồi đẩy commit `30c2758` lên remote.
  - Tương tự, giai đoạn Phase 02 được merge cục bộ qua commit `7fb01c3`.
- **Đánh giá theo chuẩn quản trị PMBOK / Agile:**
  - Merge cục bộ tuy bảo đảm tính đúng đắn của mã nguồn nhưng làm mất đi bằng chứng thảo luận, nhận xét code (code review comments) và trạng thái phê duyệt chính thức trên giao diện web của GitHub.
- **Biện pháp khắc phục chuẩn học thuật:** Thiết lập chính sách **Branch Protection Rules** để ngăn chặn hoàn toàn việc push/merge trực tiếp vào nhánh `main`.

---

## 2. Thẩm Định Tính Khả Thi Trên Gói Dịch Vụ GitHub (Plan Compatibility Assessment)

> [!TIP]
> **Kết Quả Thẩm Định Bản Quyền GitHub:**
> - Kho lưu trữ `Quyens/Nutrilens` được thiết lập ở chế độ **Công khai (Public Repository)**.
> - Theo chính sách của GitHub, các kho lưu trữ Public **được hỗ trợ 100% miễn phí** toàn bộ các tính năng bảo vệ nhánh cao cấp bao gồm:
>   - Bắt buộc Pull Request trước khi Merge (`Require a pull request before merging`).
>   - Bắt buộc tối thiểu 01 Thẩm định viên phê duyệt (`Require approvals: 1`).
>   - Bắt buộc kiểm thử CI tự động vượt qua (`Require status checks to pass`).
>   - Chặn Force Push và Chặn xóa nhánh.
> - Do đó, nhóm hoàn toàn đủ điều kiện kích hoạt mà không cần nâng cấp tài khoản trả phí.

---

## 3. Đặc Tả Cấu Hình Bảo Vệ Nhánh `main` (Branch Protection Specification)

Khi nhận được sự cho phép của người dùng, các quy tắc sau sẽ được áp dụng trong `Settings -> Branches -> Add branch protection rule`:

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                 QUY TẮC BẢO VỆ NHÁNH CHÍNH (BRANCH: main)                   │
├────────────────────────────────────────┬─────────────┬──────────────────────┤
│ TÊN QUY TẮC (SETTING)                  │ TRẠNG THÁI  │ MỤC ĐÍCH QUẢN TRỊ    │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ Branch name pattern                    │ `main`      │ Áp dụng nhánh chính  │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ Require a pull request before merging  │ ENABLED [x] │ Không cho push thẳng │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ Required approvals                     │ `1`         │ Cần ít nhất 1 bạn ký │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ Dismiss stale PR approvals on new push │ ENABLED [x] │ Đẩy code mới phải ký │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ Require status checks to pass          │ ENABLED [x] │ Chờ CI pipeline xanh │
│ -> Status check name                   │ `build-and-test` (iOS CI)          │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ Require conversation resolution        │ ENABLED [x] │ Phải giải quyết xong │
│                                        │             │ mọi ý kiến đóng góp  │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ Do not allow bypassing the settings    │ ENABLED [x] │ Kể cả Admin/Lead     │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ Restrict force pushes                  │ ENABLED [x] │ Cấm git push --force │
├────────────────────────────────────────┼─────────────┼──────────────────────┤
│ Restrict deletions                     │ ENABLED [x] │ Cấm xóa nhánh main   │
└────────────────────────────────────────┴─────────────┴──────────────────────┘
```

---

## 4. Quy Trình Thẩm Định Chéo Độc Lập (Peer Review Workflow)

Mỗi tính năng mới bắt buộc phải tuân thủ chu trình 4 bước khép kín:

```text
  [Lập trình viên]                [CI Runner]              [Reviewer độc lập]
         │                             │                            │
   Tạo PR mới                          │                            │
   (Gắn Issue & WBS)                   │                            │
         │                             │                            │
         ├────────────────────────────>│                            │
         │                        Chạy CI Build                     │
         │                        & 149 Tests                       │
         │                             │                            │
         │                             ├──── CI Báo Xanh (Pass) ───>│
         │                             │                     Đọc mã nguồn &
         │                             │                     Checklist chuẩn
         │                             │                            │
         │<──────── Sửa đổi nếu cần ───┼──────────────────── Có ý kiến phản hồi
         │                             │                            │
         │<────── Thông báo Merge ─────┼──────────────────── Phê duyệt (Approve)
```

1. **Bước 1 (Mở PR):** Lập trình viên hoàn thành tính năng trên nhánh `feature/*`, điền đầy đủ mẫu `.github/PULL_REQUEST_TEMPLATE.md` với mã Issue WBS và ảnh giao diện.
2. **Bước 2 (Kiểm tra CI):** GitHub Actions tự động dựng bản build và chạy 149 ca kiểm thử Unit & UI test. Nếu có lỗi, PR bị khóa không cho merge.
3. **Bước 3 (Kiểm duyệt ngang hàng):** Thẩm định viên (người không viết đoạn code đó) kiểm tra:
   - Kiến trúc Clean Architecture (Domain có bị dính SwiftUI/SwiftData không).
   - Bảo mật (có lộ thông tin nhạy cảm hay API keys không).
   - Chất lượng mã nguồn (không force unwrap `!`, không nuốt lỗi).
4. **Bước 4 (Hợp nhất):** Sau khi có đủ **01 Approve** và **CI Green**, PR được merge vào `main` theo phương thức *Squash and Merge* hoặc *Rebase and Merge*.

