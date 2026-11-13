//
//  IngredientVerificationStatus.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Expresses ingredient data completeness relative to documented reference databases (NIN / USDA).
//  NOTE: Does NOT represent laboratory certification.
//

import Foundation

public enum IngredientVerificationStatus: String, Codable, Sendable, CaseIterable {
    case verified = "verified"
    case partial = "partial"
    case unverified = "unverified"

    public var title: String {
        switch self {
        case .verified:
            return "Đã đối chiếu thành phần"
        case .partial:
            return "Chưa đủ thông tin thành phần"
        case .unverified:
            return "Chưa kiểm chứng thành phần"
        }
    }

    public var badgeLabel: String {
        switch self {
        case .verified:
            return "Thành phần chuẩn NIN/USDA"
        case .partial:
            return "Thành phần chưa đầy đủ"
        case .unverified:
            return "Chưa có dữ liệu thành phần"
        }
    }

    public var systemIcon: String {
        switch self {
        case .verified:
            return "checkmark.shield.fill"
        case .partial:
            return "exclamationmark.triangle.fill"
        case .unverified:
            return "questionmark.circle.fill"
        }
    }

    public var disclaimer: String {
        switch self {
        case .verified:
            return "Dữ liệu thành phần đối chiếu theo Bảng Thành phần Thực phẩm Việt Nam (NIN) và USDA FoodData Central. Không thay thế kiểm nghiệm thực tế tại cơ sở chế biến."
        case .partial:
            return "Món ăn chỉ có thông tin dinh dưỡng tổng hợp hoặc chưa liệt kê đầy đủ danh mục phụ gia, gia vị nêm nếm. Vui lòng hỏi cơ sở chế biến nếu bạn có tiền sử dị ứng."
        case .unverified:
            return "Món ăn chưa có tài liệu thành phần chi tiết. Tuyệt đối không dựa vào trạng thái này để xác định độ an toàn dị ứng."
        }
    }
}

