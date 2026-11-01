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
        let scaleX = targetSize.width / ciImage.extent.width
        let scaleY = targetSize.height / ciImage.extent.height
        let transformed = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

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

        context.render(transformed, to: buffer)
        return buffer
    }
}
