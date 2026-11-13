//
//  BarcodeCaptureService.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  AVFoundation-based hardware barcode scanner service.
//

import Foundation
import AVFoundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public protocol BarcodeCaptureServiceProtocol: AnyObject {
    var permissionState: CameraPermissionState { get }
    var isScanning: Bool { get }
    var isTorchOn: Bool { get }
    var hasTorch: Bool { get }

    func checkPermission()
    func requestPermission() async -> Bool
    func startScanning()
    func stopScanning()
    func toggleTorch()
    func setBarcodeHandler(_ handler: @escaping (String, BarcodeType) -> Void)
}

@MainActor
public final class BarcodeCaptureService: NSObject, ObservableObject, BarcodeCaptureServiceProtocol, AVCaptureMetadataOutputObjectsDelegate {
    @Published public private(set) var permissionState: CameraPermissionState = .notDetermined
    @Published public private(set) var isScanning: Bool = false
    @Published public private(set) var isTorchOn: Bool = false
    @Published public private(set) var errorMessage: String?

    public let session = AVCaptureSession()
    private let metadataOutput = AVCaptureMetadataOutput()
    private let sessionQueue = DispatchQueue(label: "com.nutrilens.barcode.sessionQueue")

    private var onBarcodeDetected: ((String, BarcodeType) -> Void)?
    private var lastScannedBarcode: String?
    private var lastScannedTimestamp: Date?
    private let throttleInterval: TimeInterval = 2.0

    public var isCameraAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil
        #endif
    }

    public var hasTorch: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return false }
        return device.hasTorch
        #endif
    }

    public override init() {
        super.init()
        checkPermission()
    }

    public func setBarcodeHandler(_ handler: @escaping (String, BarcodeType) -> Void) {
        self.onBarcodeDetected = handler
    }

    public func checkPermission() {
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
            startScanning()
        } else {
            permissionState = .denied
        }
        return granted
    }

    public func configureSessionIfNeeded() {
        guard isCameraAvailable, permissionState == .authorized else { return }
        guard session.inputs.isEmpty else { return }

        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
                  self.session.canAddInput(videoInput) else {
                Task { @MainActor in
                    self.errorMessage = "Không thể khởi tạo camera thiết bị"
                }
                self.session.commitConfiguration()
                return
            }

            self.session.addInput(videoInput)

            if self.session.canAddOutput(self.metadataOutput) {
                self.session.addOutput(self.metadataOutput)
                self.metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)

                // Supported retail 1D barcodes
                let supportedTypes: [AVMetadataObject.ObjectType] = [
                    .ean13,
                    .ean8,
                    .upce,
                    .code128
                ]
                let available = self.metadataOutput.availableMetadataObjectTypes
                let validTypes = supportedTypes.filter { available.contains($0) }
                self.metadataOutput.metadataObjectTypes = validTypes
            }

            self.session.commitConfiguration()
        }
    }

    public func startScanning() {
        guard isCameraAvailable, permissionState == .authorized else { return }
        sessionQueue.async { [weak self] in
            guard let self = self, !self.session.isRunning else { return }
            self.session.startRunning()
            Task { @MainActor in
                self.isScanning = true
            }
        }
    }

    public func stopScanning() {
        if isTorchOn {
            setTorch(enabled: false)
        }
        sessionQueue.async { [weak self] in
            guard let self = self, self.session.isRunning else { return }
            self.session.stopRunning()
            Task { @MainActor in
                self.isScanning = false
            }
        }
    }

    public func toggleTorch() {
        setTorch(enabled: !isTorchOn)
    }

    private func setTorch(enabled: Bool) {
        #if !targetEnvironment(simulator)
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = enabled ? .on : .off
            device.unlockForConfiguration()
            isTorchOn = enabled
        } catch {
            AppLogger.hardware.error("Failed to toggle torch: \(error.localizedDescription)")
        }
        #endif
    }

    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    public nonisolated func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue,
              !stringValue.isEmpty else {
            return
        }

        let barcodeType: BarcodeType
        switch readableObject.type {
        case .ean13: barcodeType = .ean13
        case .ean8: barcodeType = .ean8
        case .upce: barcodeType = .upcE
        case .code128: barcodeType = .code128
        default: barcodeType = .other
        }

        Task { @MainActor in
            // Duplicate suppression / Throttling
            let now = Date()
            if let lastCode = self.lastScannedBarcode,
               let lastTime = self.lastScannedTimestamp,
               lastCode == stringValue,
               now.timeIntervalSince(lastTime) < self.throttleInterval {
                return
            }

            self.lastScannedBarcode = stringValue
            self.lastScannedTimestamp = now

            AppLogger.hardware.info("Barcode detected: \(stringValue) (\(barcodeType.rawValue))")
            self.onBarcodeDetected?(stringValue, barcodeType)
        }
    }

    deinit {
        if session.isRunning {
            session.stopRunning()
        }
    }
}

// MARK: - Mock Barcode Capture Service for Tests & Previews
@MainActor
public final class MockBarcodeCaptureService: ObservableObject, BarcodeCaptureServiceProtocol {
    @Published public var permissionState: CameraPermissionState = .authorized
    @Published public var isScanning: Bool = true
    @Published public var isTorchOn: Bool = false
    public var hasTorch: Bool = true

    private var onBarcodeDetected: ((String, BarcodeType) -> Void)?

    public init(permissionState: CameraPermissionState = .authorized) {
        self.permissionState = permissionState
    }

    public func checkPermission() {}
    public func requestPermission() async -> Bool {
        permissionState = .authorized
        return true
    }

    public func startScanning() {
        isScanning = true
    }

    public func stopScanning() {
        isScanning = false
    }

    public func toggleTorch() {
        isTorchOn.toggle()
    }

    public func setBarcodeHandler(_ handler: @escaping (String, BarcodeType) -> Void) {
        self.onBarcodeDetected = handler
    }

    public func simulateScan(barcode: String, type: BarcodeType = .ean13) {
        onBarcodeDetected?(barcode, type)
    }
}

