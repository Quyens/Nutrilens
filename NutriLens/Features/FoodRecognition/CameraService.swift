//
//  CameraService.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Manages native AVCaptureSession, hardware camera lifecycle, photo capture,
//  and permission state handling.
//

import Foundation
import AVFoundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public enum CameraPermissionState: Equatable, Sendable {
    case notDetermined
    case authorized
    case denied
    case restricted
    case unavailable // Running on Simulator or hardware absent
}

@MainActor
public final class CameraService: NSObject, ObservableObject {
    @Published public private(set) var permissionState: CameraPermissionState = .notDetermined
    @Published public private(set) var isSessionRunning: Bool = false
    @Published public var isFlashOn: Bool = false
    @Published public private(set) var capturedPhoto: UIImage?
    @Published public private(set) var capturedImageData: Data?
    @Published public private(set) var errorMessage: String?

    public let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var photoContinuation: CheckedContinuation<(UIImage, Data), Error>?

    public var isCameraAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil
        #endif
    }

    public override init() {
        super.init()
        checkInitialPermission()
    }

    public func checkInitialPermission() {
        if !isCameraAvailable {
            permissionState = .unavailable
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionState = .authorized
            configureSessionIfNeeded()
        case .notDetermined:
            permissionState = .notDetermined
        case .denied:
            permissionState = .denied
        case .restricted:
            permissionState = .restricted
        @unknown default:
            permissionState = .unavailable
        }
    }

    public func requestPermission() async -> Bool {
        if !isCameraAvailable {
            permissionState = .unavailable
            return false
        }

        let granted = await AVCaptureDevice.requestAccess(for: .video)
        if granted {
            permissionState = .authorized
            configureSessionIfNeeded()
            startSession()
        } else {
            permissionState = .denied
        }
        return granted
    }

    public func openSettings() {
        #if canImport(UIKit)
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
        #endif
    }

    public func configureSessionIfNeeded() {
        guard isCameraAvailable, permissionState == .authorized else { return }
        guard session.inputs.isEmpty else { return }

        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            errorMessage = "Không thể khởi tạo đầu vào Camera."
            return
        }

        session.addInput(input)

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.maxPhotoQualityPrioritization = .balanced
        }

        session.commitConfiguration()
    }

    public func startSession() {
        guard isCameraAvailable, permissionState == .authorized else { return }
        guard !session.isRunning else {
            isSessionRunning = true
            return
        }

        Task.detached(priority: .userInitiated) { [session] in
            session.startRunning()
            await MainActor.run {
                self.isSessionRunning = session.isRunning
            }
        }
    }

    public func stopSession() {
        guard session.isRunning else {
            isSessionRunning = false
            return
        }

        Task.detached(priority: .background) { [session] in
            session.stopRunning()
            await MainActor.run {
                self.isSessionRunning = false
            }
        }
    }

    public func capturePhoto() async throws -> (UIImage, Data) {
        guard isCameraAvailable else {
            throw AppError.cameraUnavailable
        }
        guard isSessionRunning else {
            throw AppError.cameraUnavailable
        }

        let settings = AVCapturePhotoSettings()
        if photoOutput.supportedFlashModes.contains(.on) {
            settings.flashMode = isFlashOn ? .on : .off
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.photoContinuation = continuation
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    public func toggleFlash() {
        isFlashOn.toggle()
    }

    public func resetCapture() {
        capturedPhoto = nil
        capturedImageData = nil
        errorMessage = nil
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraService: AVCapturePhotoCaptureDelegate {
    public nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            Task { @MainActor in
                self.photoContinuation?.resume(throwing: AppError.imageProcessingFailed("Chụp ảnh thất bại: \(error.localizedDescription)"))
                self.photoContinuation = nil
            }
            return
        }

        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            Task { @MainActor in
                self.photoContinuation?.resume(throwing: AppError.imageProcessingFailed("Không thể phân tích dữ liệu ảnh đã chụp."))
                self.photoContinuation = nil
            }
            return
        }

        // Fix EXIF orientation so portrait photos stay upright
        let normalizedImage = image.normalizedOrientation()
        let normalizedData = normalizedImage.jpegData(compressionQuality: 0.90) ?? data

        Task { @MainActor in
            self.capturedPhoto = normalizedImage
            self.capturedImageData = normalizedData
            self.photoContinuation?.resume(returning: (normalizedImage, normalizedData))
            self.photoContinuation = nil
        }
    }
}

// MARK: - UIImage Orientation Normalizer
extension UIImage {
    public func normalizedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return normalized
    }
}
