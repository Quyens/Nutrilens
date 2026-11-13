#!/usr/bin/env bash
#
# publish_github_management.sh
# Script chuẩn bị quy trình đồng bộ hóa GitHub Management (Issues, PR, Project Board)
# CHỈ ĐƯỢC CHẠY KHI NGƯỜI DÙNG CHO PHÉP CHÍNH THỨC
#

set -e

echo "================================================================="
echo "  NUTRILENS V1.0 — GITHUB MANAGEMENT PUBLISHING UTILITY         "
echo "================================================================="
echo ""
echo "CẢNH BÁO: Script này sẽ thực hiện các thao tác ghi (Write Operations)"
echo "lên kho lưu trữ GitHub từ xa: git@github.com:Quyens/Nutrilens.git"
echo ""
read -p "Bạn có chắc chắn muốn tiếp tục thực hiện không? (nhập 'yes' để xác nhận): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Hủy bỏ thao tác. Không có thay đổi nào được gửi lên GitHub."
    exit 0
fi

echo ""
echo ">> 1. Kiểm tra trạng thái Git cục bộ..."
git status -s

echo ""
echo ">> 2. Đẩy các nhánh tính năng lịch sử lên GitHub Remote..."
git push origin checkpoint/phase00-baseline || true
git push origin feature/phase01-authentication || true
git push origin feature/phase02-meal-logging || true

echo ""
echo ">> 3. Kiểm tra GitHub CLI (gh)..."
if command -v gh &> /dev/null; then
    echo "GitHub CLI đã sẵn sàng. Xuất bản 7 User Stories chính..."
    
    # Issue 1
    gh issue create --title "[FEAT] [Phase 00] On-Device AI Food Recognition Viewfinder" \
      --body-file "reports/qlda/04_github_projects_backlog.md" --label "enhancement,phase00" || true
      
    echo "Đã tạo Issues thành công."
else
    echo "GitHub CLI (gh) chưa được cài đặt trên máy. Bạn có thể cài đặt bằng: 'brew install gh'"
    echo "Hoặc sao chép nội dung các Issue từ 'reports/qlda/04_github_projects_backlog.md' lên giao diện web."
fi

echo ""
echo ">> Hoàn tất quy trình kiểm tra và chuẩn bị GitHub Management."

