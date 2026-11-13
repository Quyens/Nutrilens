//
//  ManualBarcodeEntrySheet.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Sheet allowing manual input of 8-13 digit barcodes with live validation.
//

import SwiftUI

public struct ManualBarcodeEntrySheet: View {
    @ObservedObject var viewModel: BarcodeScannerViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var barcodeInput: String = ""
    @State private var validationMessage: String?
    @State private var isValid: Bool = false

    public init(viewModel: BarcodeScannerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                // Instruction card
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.title2)
                            .foregroundStyle(AppColors.primary)
                        Text("Nhập mã vạch sản phẩm")
                            .font(AppTypography.headline)
                            .foregroundStyle(AppColors.textPrimary)
                    }

                    Text("Nhập dãy 8 đến 13 chữ số in dưới vạch kẻ trên bao bì thực phẩm (EAN-13, EAN-8 hoặc UPC-A).")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.cardBackground)
                .cornerRadius(AppRadius.large)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.large)
                        .stroke(AppColors.leafGreen.opacity(0.2), lineWidth: 1)
                )

                // Input Field
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack {
                        TextField("Ví dụ: 8934673105051", text: $barcodeInput)
                            .keyboardType(.numberPad)
                            .font(.system(.title3, design: .monospaced, weight: .semibold))
                            .padding(AppSpacing.md)
                            .background(AppColors.surfaceBackground)
                            .cornerRadius(AppRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.medium)
                                    .stroke(isValid ? AppColors.primary : (barcodeInput.isEmpty ? Color.gray.opacity(0.3) : Color.orange), lineWidth: 1.5)
                            )
                            .onChange(of: barcodeInput) { _, newValue in
                                validateInput(newValue)
                            }

                        if !barcodeInput.isEmpty {
                            Button {
                                barcodeInput = ""
                                validateInput("")
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }

                    // Validation status
                    if let message = validationMessage {
                        HStack(spacing: 4) {
                            Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .font(.caption)
                            Text(message)
                                .font(AppTypography.caption)
                        }
                        .foregroundColor(isValid ? AppColors.primary : .orange)
                        .padding(.horizontal, 4)
                    }
                }

                // Sample Barcodes for Quick Testing
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Mẫu mã vạch Việt Nam thực tế:")
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppColors.textSecondary)

                    VStack(spacing: AppSpacing.xs) {
                        sampleRow(title: "Sữa Vinamilk 100% (180ml)", code: "8934673105057")
                        sampleRow(title: "Mì Hảo Hảo Tôm Chua Cay (75g)", code: "8934563138165")
                        sampleRow(title: "Bánh ChocoPie Orion (33g)", code: "8936036010015")
                        sampleRow(title: "Nước tương Nam Dương (500ml)", code: "8934758010047")
                        sampleRow(title: "Mã chưa có trong hệ thống", code: "8938888999999")
                    }
                }
                .padding(AppSpacing.md)
                .background(AppColors.surfaceBackground)
                .cornerRadius(AppRadius.medium)

                Spacer()

                // Action button
                Button {
                    let codeToSearch = barcodeInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    dismiss()
                    Task {
                        await viewModel.lookupBarcode(code: codeToSearch)
                    }
                } label: {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "magnifyingglass")
                            .font(.headline)
                        Text("Tìm kiếm sản phẩm")
                            .font(AppTypography.buttonText)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(isValid ? AppColors.primary : Color.gray)
                    .cornerRadius(AppRadius.large)
                }
                .disabled(!isValid)
            }
            .padding(AppSpacing.md)
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Nhập mã vạch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }
    }

    private func sampleRow(title: String, code: String) -> some View {
        Button {
            barcodeInput = code
            validateInput(code)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(code)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                Text("Chọn")
                    .font(AppTypography.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.primary.opacity(0.1))
                    .foregroundStyle(AppColors.primary)
                    .cornerRadius(12)
            }
            .padding(.vertical, 4)
        }
    }

    private func validateInput(_ text: String) {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else {
            validationMessage = nil
            isValid = false
            return
        }

        let val = BarcodeValue(rawValue: clean)
        isValid = val.isValid
        if val.isValid {
            validationMessage = "Mã chuẩn \(val.type.rawValue) hợp lệ"
        } else {
            validationMessage = val.validationError ?? "Mã không hợp lệ"
        }
    }
}

