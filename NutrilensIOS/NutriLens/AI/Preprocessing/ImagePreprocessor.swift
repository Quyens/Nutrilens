//
//  ImagePreprocessor.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import CoreGraphics
import CoreImage
#if canImport(UIKit)
import UIKit
#endif

public protocol ImagePreprocessorProtocol: Sendable {
    func preparePixelBuffer(from imageData: Data, targetSize: CGSize) throws -> CVPixelBuffer
}

public final class ImagePreprocessor: ImagePreprocessorProtocol {
    public init() {}

    public func preparePixelBuffer(from imageData: Data, targetSize: CGSize) throws -> CVPixelBuffer {
        guard let ciImage = CIImage(data: imageData) else {
            throw AppError.imageProcessingFailed("Invalid image data binary representation.")
        }

        let context = CIContext()
        // Aspect-fill and center crop to preserve food geometry parity with PyTorch T.Resize(224) + T.CenterCrop(224)
        let scale = max(targetSize.width / ciImage.extent.width, targetSize.height / ciImage.extent.height)
        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        let cropOriginX = (scaledImage.extent.width - targetSize.width) / 2.0
        let cropOriginY = (scaledImage.extent.height - targetSize.height) / 2.0
        let cropped = scaledImage.cropped(to: CGRect(x: cropOriginX, y: cropOriginY, width: targetSize.width, height: targetSize.height))
            .transformed(by: CGAffineTransform(translationX: -cropOriginX, y: -cropOriginY))

        var pixelBuffer: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(targetSize.width),
            Int(targetSize.height),
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            throw AppError.imageProcessingFailed("Could not allocate CVPixelBuffer.")
        }

        context.render(cropped, to: buffer)
        return buffer
    }
}
