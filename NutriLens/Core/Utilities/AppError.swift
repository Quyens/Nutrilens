//
//  AppError.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation

public enum AppError: LocalizedError, Equatable {
    case networkUnavailable
    case cameraUnavailable
    case imageProcessingFailed(String)
    case inferenceFailed(String)
    case outOfDistribution
    case dataPersistenceFailed(String)
    case itemNotFound
    case invalidInput(String)
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "No internet connection detected."
        case .cameraUnavailable:
            return "Camera is not available on this device or permission was denied."
        case .imageProcessingFailed(let msg):
            return "Unable to process food image: \(msg)"
        case .inferenceFailed(let msg):
            return "Nutrition recognition failed: \(msg)"
        case .outOfDistribution:
            return "The captured image does not appear to be food or recognizable dish."
        case .dataPersistenceFailed(let msg):
            return "Failed to save or load meal data: \(msg)"
        case .itemNotFound:
            return "Requested food or meal was not found."
        case .invalidInput(let msg):
            return "Invalid input provided: \(msg)"
        case .unknown(let msg):
            return "An unexpected error occurred: \(msg)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .outOfDistribution:
            return "Please re-frame your camera directly over the dish with good lighting."
        case .cameraUnavailable:
            return "Enable camera access in iOS Settings > NutriLens."
        case .imageProcessingFailed, .inferenceFailed:
            return "Try capturing the food item from another angle or adjust lighting."
        default:
            return "Please try again."
        }
    }
}
