//
//  CopyDayPlanSheet.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Sheet allowing users to duplicate an entire day's meal schedule to another day.
//

import SwiftUI

public struct CopyDayPlanSheet: View {
    @Environment(\.dismiss) private var dismiss
    let sourceDate: Date
    let mealsCount: Int
    let onConfirmCopy: (Date, Date, CopyDayPlanMode) -> Void

    @State private var targetDate: Date
    @State private var mode: CopyDayPlanMode = .append
    @State private var isShowingReplaceAlert: Bool = false

    public init(
        sourceDate: Date,
        mealsCount: Int,
        onConfirmCopy: @escaping (Date, Date, CopyDayPlanMode) -> Void
    ) {
        self.sourceDate = sourceDate
        self.mealsCount = mealsCount
        self.onConfirmCopy = onConfirmCopy

        // Default targetDate to tomorrow
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: sourceDate) ?? sourceDate
        _targetDate = State(initialValue: tomorrow)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.canvasBackground.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    // Source Day Card
                    sourceDayCard

                    // Target Date Selector
                    targetDayCard

                    // Copy Mode Selector
                    copyModeSection

                    Spacer()

                    // Confirmation Action
                    confirmButton
                }
                .padding(AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.xl)
            }
            .navigationTitle("Sao chép thực đơn ngày")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Hủy") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .alert("Xác nhận ghi đè thực đơn", isPresented: $isShowingReplaceAlert) {
                Button("Ghi đè", role: .destructive) {
                    executeCopy()
                }
                Button("Hủy", role: .cancel) {}
            } message: {
                Text("Toàn bộ món ăn đã lập trong ngày đích sẽ bị thay thế bởi thực đơn ngày nguồn. Bạn có chắc chắn muốn tiếp tục?")
            }
        }
    }

    // MARK: - Source Day Card
    private var sourceDayCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Ngày nguồn")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textSecondary)

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(AppColors.primaryGreen)

                let formatter = DateFormatter()
                let _ = formatter.locale = Locale(identifier: "vi_VN")
                let _ = formatter.dateFormat = "EEEE, dd/MM/yyyy"
                Text(formatter.string(from: sourceDate).capitalized)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text("\(mealsCount) bữa ăn")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppColors.primaryGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.mintSurface)
                    .clipShape(Capsule())
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .stroke(Color(red: 0.90, green: 0.93, blue: 0.91), lineWidth: 1)
            )
        }
    }

    // MARK: - Target Day Card
    private var targetDayCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Sao chép sang ngày đích")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textSecondary)

            DatePicker(
                "Chọn ngày nhận thực đơn",
                selection: $targetDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .tint(AppColors.primaryGreen)
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .stroke(Color(red: 0.90, green: 0.93, blue: 0.91), lineWidth: 1)
            )
        }
    }

    // MARK: - Copy Mode Section
    private var copyModeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Chế độ sao chép")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textSecondary)

            VStack(spacing: 8) {
                ModeOptionRow(
                    title: "Thêm tiếp vào ngày đích",
                    subtitle: "Giữ nguyên các món đã lên kế hoạch sẵn tại ngày đích.",
                    isSelected: mode == .append
                ) {
                    mode = .append
                }

                ModeOptionRow(
                    title: "Ghi đè ngày đích",
                    subtitle: "Xóa toàn bộ món cũ tại ngày đích và sao chép mới.",
                    isSelected: mode == .replace
                ) {
                    mode = .replace
                }
            }
        }
    }

    private var confirmButton: some View {
        Button(action: {
            if mode == .replace {
                isShowingReplaceAlert = true
            } else {
                executeCopy()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: "doc.on.doc.fill")
                Text("Sao chép \(mealsCount) bữa ăn")
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.forestGreen],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        }
    }

    private func executeCopy() {
        onConfirmCopy(sourceDate, targetDate, mode)
        dismiss()
    }
}

private struct ModeOptionRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? AppColors.primaryGreen : AppColors.textSecondary)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .stroke(isSelected ? AppColors.primaryGreen : Color(red: 0.90, green: 0.93, blue: 0.91), lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

