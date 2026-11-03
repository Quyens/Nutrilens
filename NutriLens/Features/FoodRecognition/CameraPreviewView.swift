//
//  CameraPreviewView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  SwiftUI wrapper around AVCaptureVideoPreviewLayer.
//

import SwiftUI
import AVFoundation
#if canImport(UIKit)
import UIKit

public struct CameraPreviewView: UIViewRepresentable {
    public let session: AVCaptureSession

    public init(session: AVCaptureSession) {
        self.session = session
    }

    public func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    public func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        uiView.videoPreviewLayer.session = session
    }
}

public final class CameraPreviewUIView: UIView {
    public override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    public var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.frame = bounds
    }
}
#else
public struct CameraPreviewView: View {
    public init(session: AVCaptureSession) {}
    public var body: some View {
        Color.black
    }
}
#endif
