//
//  BarcodeScannerView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Main real-time Barcode Scanner interface with botanical overlay, viewfinder reticle,
//  AVFoundation camera preview, and development simulator fallback.
//

import SwiftUI
import AVFoundation

public struct BarcodeScannerView: View {
    @ObservedObject var viewModel: BarcodeScannerViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var scanLineOffset: CGFloat = -100
    @State private var isAnimatingLaser: Bool = false

    public init(viewModel: BarcodeScannerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            // MARK: - Layer 1: Camera or Simulator Background
            if viewModel.permissionState == .authorized {
                BarcodeCameraPreviewView(session: (viewModel.captureService as? BarcodeCaptureService)?.session ?? AVCaptureSession())
                    .ignoresSafeArea()
            } else {
                simulatorFallbackBackground
            }

            // MARK: - Layer 2: Viewfinder Overlay
            VStack {
                topNavigationBar

                Spacer()

                viewfinderReticle

                Spacer()

                bottomControlsDock
            }

            // MARK: - Layer 3: Toast Notification
            if let toast = viewModel.toastMessage {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text(toast)
                            .font(AppTypography.caption)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppColors.deepForest.opacity(0.95))
                    .cornerRadius(20)
                    .padding(.bottom, 100)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut, value: viewModel.toastMessage)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation { viewModel.toastMessage = nil }
                    }
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
            startLaserAnimation()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
        // MARK: - Sheets
        .sheet(isPresented: $viewModel.showResultSheet) {
            ScannedProductResultSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showManualEntrySheet) {
            ManualBarcodeEntrySheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showCreateEditSheet) {
            CreateEditPackagedFoodView(
                viewModel: viewModel,
                initialBarcode: viewModel.unknownBarcodeNumber.isEmpty ? nil : viewModel.unknownBarcodeNumber
            )
        }
        .sheet(isPresented: $viewModel.showLibrarySheet) {
            PackagedFoodLibraryView(viewModel: viewModel)
        }
        // MARK: - Unknown Barcode Alert / Sheet
        .alert("Chưa tìm thấy thông tin sản phẩm", isPresented: $viewModel.showUnknownSheet) {
            Button("Thêm sản phẩm mới") {
                viewModel.showCreateEditSheet = true
            }
            Button("Quét lại", role: .cancel) {
                viewModel.resumeScanning()
            }
        } message: {
            Text("Mã vạch '\(viewModel.unknownBarcodeNumber)' chưa có trong hệ thống chuẩn hoặc kho cá nhân của bạn. Bạn có muốn thêm mới ngay?")
        }
    }

    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }

            Spacer()

            Text("Quét mã vạch")
                .font(AppTypography.headline)
                .foregroundColor(.white)
                .shadow(radius: 4)

            Spacer()

            HStack(spacing: AppSpacing.sm) {
                // Torch toggle (if available)
                if viewModel.hasTorch {
                    Button {
                        viewModel.toggleTorch()
                    } label: {
                        Image(systemName: viewModel.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.body.weight(.semibold))
                            .foregroundColor(viewModel.isTorchOn ? .yellow : .white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }

                // Manual entry button
                Button {
                    viewModel.showManualEntrySheet = true
                } label: {
                    Image(systemName: "keyboard")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.sm)
    }

    // MARK: - Viewfinder Reticle
    private var viewfinderReticle: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                // Reticle boundary
                RoundedRectangle(cornerRadius: AppRadius.large)
                    .stroke(AppColors.leafGreen, lineWidth: 3)
                    .frame(width: 280, height: 200)
                    .background(Color.black.opacity(0.1))

                // Botanical Corner Accents
                reticleCorners

                // Animated Green Laser Scanner Line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, AppColors.leafGreen, Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 260, height: 3)
                    .shadow(color: AppColors.leafGreen, radius: 5)
                    .offset(y: scanLineOffset)
            }

            Text("Căn chỉnh mã vạch vào giữa khung quét")
                .font(AppTypography.subheadline)
                .foregroundColor(.white)
                .shadow(radius: 4)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.45))
                .cornerRadius(16)
        }
    }

    private var reticleCorners: some View {
        ZStack {
            // Top-left
            cornerMarker.position(x: 10, y: 10)
            // Top-right
            cornerMarker.rotationEffect(.degrees(90)).position(x: 270, y: 10)
            // Bottom-right
            cornerMarker.rotationEffect(.degrees(180)).position(x: 270, y: 190)
            // Bottom-left
            cornerMarker.rotationEffect(.degrees(270)).position(x: 10, y: 190)
        }
        .frame(width: 280, height: 200)
    }

    private var cornerMarker: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 24))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 24, y: 0))
        }
        .stroke(AppColors.softSage, lineWidth: 4)
        .frame(width: 24, height: 24)
    }

    // MARK: - Bottom Controls Dock
    private var bottomControlsDock: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.lg) {
                // Button 1: Manual Keypad
                Button {
                    viewModel.showManualEntrySheet = true
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "number.square.fill")
                            .font(.title2)
                        Text("Nhập mã")
                            .font(AppTypography.caption)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.55))
                    .cornerRadius(AppRadius.medium)
                }

                // Button 2: Packaged Food Library
                Button {
                    viewModel.showLibrarySheet = true
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "archivebox.fill")
                            .font(.title2)
                        Text("Kho hàng")
                            .font(AppTypography.caption)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.55))
                    .cornerRadius(AppRadius.medium)
                }
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.bottom, AppSpacing.lg)
        }
    }

    // MARK: - Simulator Fallback UI
    private var simulatorFallbackBackground: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.deepForest, Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: AppSpacing.sm) {
                HStack(spacing: 6) {
                    Image(systemName: "laptopcomputer")
                    Text("Chế độ mô phỏng (Simulator)")
                        .fontWeight(.bold)
                }
                .font(.caption)
                .foregroundColor(.yellow)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.6))
                .cornerRadius(12)
                .padding(.top, 70)

                Text("Simulator không hỗ trợ Camera thực tế.\nBấm vào một trong các sản phẩm mẫu để kiểm tra:")
                    .font(AppTypography.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // Quick test chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        simulatorChip("Vinamilk 180ml", code: "8934673105057")
                        simulatorChip("Mì Hảo Hảo 75g", code: "8934563138165")
                        simulatorChip("ChocoPie 33g", code: "8936036010015")
                        simulatorChip("Nước dừa Cocoxim", code: "8936079280147")
                        simulatorChip("Nước tương Nam Dương", code: "8934758010047")
                        simulatorChip("Hạt điều Bazan", code: "8938501234018")
                        simulatorChip("Mã vạch lạ", code: "8930000000019")
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 4)

                Spacer()
            }
        }
    }

    private func simulatorChip(_ title: String, code: String) -> some View {
        Button {
            Task {
                await viewModel.lookupBarcode(code: code)
            }
        } label: {
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(code)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppColors.primary.opacity(0.75))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppColors.leafGreen, lineWidth: 1)
            )
        }
    }

    private func startLaserAnimation() {
        withAnimation(Animation.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
            scanLineOffset = 90
        }
    }
}

// MARK: - UIViewRepresentable for AVCaptureVideoPreviewLayer
struct BarcodeCameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> BarcodePreviewUIView {
        let view = BarcodePreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: BarcodePreviewUIView, context: Context) {}

    class BarcodePreviewUIView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        var previewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
    }
}
