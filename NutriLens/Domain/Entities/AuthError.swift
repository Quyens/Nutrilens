//
//  AuthError.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Typed authentication and security errors with localized Vietnamese descriptions.
//

import Foundation

public enum AuthError: LocalizedError, Equatable {
    case invalidEmail
    case weakPassword(reason: String)
    case passwordsDoNotMatch
    case userNotFound
    case wrongPassword
    case emailAlreadyInUse
    case networkUnavailable
    case backendUnavailable(message: String)
    case unauthorized
    case sessionExpired
    case keychainError(details: String)
    case operationCancelled
    case mockModeNotice(message: String)

    public var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Địa chỉ email không đúng định dạng. Vui lòng kiểm tra lại."
        case .weakPassword(let reason):
            return "Mật khẩu chưa đủ an toàn: \(reason)"
        case .passwordsDoNotMatch:
            return "Mật khẩu xác nhận không khớp. Vui lòng nhập lại."
        case .userNotFound:
            return "Không tìm thấy tài khoản với email đã cung cấp."
        case .wrongPassword:
            return "Mật khẩu không chính xác. Vui lòng thử lại."
        case .emailAlreadyInUse:
            return "Email này đã được sử dụng cho một tài khoản khác."
        case .networkUnavailable:
            return "Không thể kết nối mạng. Vui lòng kiểm tra lại đường truyền."
        case .backendUnavailable(let message):
            return message
        case .unauthorized:
            return "Phiên xác thực không hợp lệ. Vui lòng đăng nhập lại."
        case .sessionExpired:
            return "Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại."
        case .keychainError(let details):
            return "Lỗi bảo mật Keychain: \(details)"
        case .operationCancelled:
            return "Thao tác đã bị hủy."
        case .mockModeNotice(let message):
            return message
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .invalidEmail:
            return "Ví dụ: ban@example.com"
        case .weakPassword:
            return "Mật khẩu cần có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường và chữ số."
        case .passwordsDoNotMatch:
            return "Hãy đảm bảo mật khẩu mới và mật khẩu xác nhận hoàn toàn giống nhau."
        case .backendUnavailable:
            return "Hệ thống đang hoạt động ở chế độ ngoại tuyến. Bạn có thể sử dụng Chế độ Khách để tiếp tục."
        case .mockModeNotice:
            return "Chức năng trực tuyến sẽ khả dụng khi kết nối backend chính thức."
        default:
            return nil
        }
    }
}
