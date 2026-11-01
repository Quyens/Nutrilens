//
//  AsyncState.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public enum AsyncState<T: Equatable>: Equatable {
    case idle
    case loading
    case success(T)
    case failure(AppError)

    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    public var value: T? {
        if case .success(let val) = self { return val }
        return nil
    }

    public var error: AppError? {
        if case .failure(let err) = self { return err }
        return nil
    }
}
