//
//  CreateEditCustomFoodView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Phase 03 Create & Edit Custom Food Screen.
//

import SwiftUI

public struct CreateEditCustomFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var environment: AppEnvironment

    public let existingFood: CustomFood?
    public let onSaved: (CustomFood) -> Void

    // Form Fields
    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var category: String = "Món Mặn"
    @State private var servingUnit: String = "phần"
    @State private var servingGramsText: String = "150"

    // Macros (per serving)
    @State private var caloriesText: String = ""
    @State private var proteinText: String = ""
    @State private var carbsText: String = ""
    @State private var fatText: String = ""
    @State private var fiberText: String = ""

    // Optional Micronutrients
    @State private var showMicronutrients: Bool = false
    @State private var sodiumText: String = ""
    @State private var potassiumText: String = ""
    @State private var calciumText: String = ""
    @State private var ironText: String = ""
    @State private var vitaminAText: String = ""
    @State private var vitaminCText: String = ""
    @State private var sugarText: String = ""
    @State private var cholesterolText: String = ""

    // Notes
    @State private var notes: String = ""
    @State private var isFavorite: Bool = false

    // State
    @State private var errorMessage: String? = nil
    @State private var isSaving: Bool = false

    private let categories = [
        "Món Mặn",
        "Món Nước",
        "Cơm & Xôi",
        "Rau Củ",
        "Canh",
        "Bánh Mì & Ăn Sáng",
        "Tráng Miệng",
        "Đồ Uống",
        "Gia Vị & Nước Chấm",
        "Khác"
    ]

    public init(
        existingFood: CustomFood? = nil,
        onSaved: @escaping (CustomFood) -> Void = { _ in }
    ) {
        self.existingFood = existingFood
        self.onSaved = onSaved
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.canvasBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Error message
                        if let error = errorMessage {
                            errorBanner(error)
                        }

                        // Basic Information Card
                        basicInfoCard

                        // Portion Card
                        portionCard

                        // Macronutrients Card
                        macronutrientsCard

                        // Optional Micronutrients Section
                        micronutrientsCard

                        // Notes Card
                        notesCard

                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 16)
                }
            }
            .navigationTitle(existingFood == nil ? "Tạo món ăn riêng" : "Sửa món ăn")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveFood()
                    } label: {
                        if isSaving {
                            ProgressView()
                                .tint(AppColors.primaryGreen)
                        } else {
                            Text("Lưu")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppColors.primaryGreen)
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .onAppear {
                populateExistingData()
            }
        }
    }

    // MARK: - Subviews
    private var basicInfoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Thông tin cơ bản")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: 6) {
                Text("Tên món ăn *")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                TextField("VD: Ức gà áp chảo sốt tiêu", text: $name)
                    .textFieldStyle(BotanicalFormTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Thương hiệu / Nguồn (Tùy chọn)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                TextField("VD: Tự làm, Healthy Meal...", text: $brand)
                    .textFieldStyle(BotanicalFormTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Danh mục")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)

                Picker("Danh mục", selection: $category) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat).tag(cat)
                    }
                }
                .pickerStyle(.menu)
                .tint(AppColors.primaryGreen)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppColors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(16)
        .background(formCardBackground)
    }

    private var portionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Khẩu phần chuẩn")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Đơn vị (chén, cái, phần...)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                    TextField("phần", text: $servingUnit)
                        .textFieldStyle(BotanicalFormTextFieldStyle())
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Trọng lượng (gram) *")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                    TextField("150", text: $servingGramsText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(BotanicalFormTextFieldStyle())
                }
            }
        }
        .padding(16)
        .background(formCardBackground)
    }

    private var macronutrientsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Dinh dưỡng cho 1 khẩu phần *")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                Text("Nhập năng lượng và các chất đa lượng của khẩu phần trên.")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Năng lượng (kcal) *")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                TextField("0", text: $caloriesText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(BotanicalFormTextFieldStyle())
            }

            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Đạm (g)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "2B6CB0"))
                    TextField("0", text: $proteinText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(BotanicalFormTextFieldStyle())
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Carbs (g)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "C05621"))
                    TextField("0", text: $carbsText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(BotanicalFormTextFieldStyle())
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Béo (g)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "C53030"))
                    TextField("0", text: $fatText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(BotanicalFormTextFieldStyle())
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Xơ (g)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "27AE60"))
                    TextField("0", text: $fiberText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(BotanicalFormTextFieldStyle())
                }
            }
        }
        .padding(16)
        .background(formCardBackground)
    }

    private var micronutrientsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showMicronutrients.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Vi chất & Dinh dưỡng chi tiết")
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.textPrimary)
                        Text("Natri, Canxi, Sắt, Vitamin, Đường, Cholesterol (tùy chọn)")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: showMicronutrients ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .buttonStyle(PlainButtonStyle())

            if showMicronutrients {
                Divider()

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        microField(label: "Natri (mg)", text: $sodiumText)
                        microField(label: "Kali (mg)", text: $potassiumText)
                    }

                    HStack(spacing: 12) {
                        microField(label: "Canxi (mg)", text: $calciumText)
                        microField(label: "Sắt (mg)", text: $ironText)
                    }

                    HStack(spacing: 12) {
                        microField(label: "Vitamin A (mcg)", text: $vitaminAText)
                        microField(label: "Vitamin C (mg)", text: $vitaminCText)
                    }

                    HStack(spacing: 12) {
                        microField(label: "Đường (g)", text: $sugarText)
                        microField(label: "Cholesterol (mg)", text: $cholesterolText)
                    }
                }
            }
        }
        .padding(16)
        .background(formCardBackground)
    }

    private func microField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppColors.textSecondary)
            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .textFieldStyle(BotanicalFormTextFieldStyle())
        }
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Ghi chú thêm (Tùy chọn)")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            TextField("Cách chế biến, lưu ý nguyên liệu...", text: $notes, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(BotanicalFormTextFieldStyle())
        }
        .padding(16)
        .background(formCardBackground)
    }

    private func errorBanner(_ msg: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(AppColors.error)
            Text(msg)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.error)
            Spacer()
        }
        .padding(12)
        .background(Color(hex: "FFF4F2"))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color(hex: "FAD4CF"), lineWidth: 1))
    }

    private var formCardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
    }

    // MARK: - Populate Existing
    private func populateExistingData() {
        guard let food = existingFood else { return }
        name = food.name
        brand = food.brand ?? ""
        category = food.category
        servingUnit = food.servingUnit
        servingGramsText = String(format: "%.0f", food.servingGrams)
        caloriesText = String(format: "%.0f", food.caloriesPerServing)
        proteinText = String(format: "%.1f", food.proteinGrams)
        carbsText = String(format: "%.1f", food.carbGrams)
        fatText = String(format: "%.1f", food.fatGrams)
        fiberText = String(format: "%.1f", food.fiberGrams)
        notes = food.notes ?? ""
        isFavorite = food.isFavorite

        if let micro = food.micronutrients {
            showMicronutrients = true
            sodiumText = micro.sodiumMg.map { String(format: "%.0f", $0) } ?? ""
            potassiumText = micro.potassiumMg.map { String(format: "%.0f", $0) } ?? ""
            calciumText = micro.calciumMg.map { String(format: "%.0f", $0) } ?? ""
            ironText = micro.ironMg.map { String(format: "%.1f", $0) } ?? ""
            vitaminAText = micro.vitaminAMcg.map { String(format: "%.0f", $0) } ?? ""
            vitaminCText = micro.vitaminCMg.map { String(format: "%.1f", $0) } ?? ""
            sugarText = micro.sugarGrams.map { String(format: "%.1f", $0) } ?? ""
            cholesterolText = micro.cholesterolMg.map { String(format: "%.0f", $0) } ?? ""
        }
    }

    // MARK: - Save
    private func saveFood() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Vui lòng nhập tên món ăn."
            return
        }

        let servingGrams = Double(servingGramsText.replacingOccurrences(of: ",", with: ".")) ?? 0
        guard servingGrams > 0 else {
            errorMessage = "Trọng lượng khẩu phần phải lớn hơn 0g."
            return
        }

        let calories = Double(caloriesText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let protein = Double(proteinText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let carbs = Double(carbsText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let fat = Double(fatText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let fiber = Double(fiberText.replacingOccurrences(of: ",", with: ".")) ?? 0

        guard calories >= 0, protein >= 0, carbs >= 0, fat >= 0, fiber >= 0 else {
            errorMessage = "Các chỉ số dinh dưỡng không được âm."
            return
        }

        // Build Micronutrients if entered
        func parseOptional(_ text: String) -> Double? {
            let clean = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
            return clean.isEmpty ? nil : Double(clean)
        }

        let sodium = parseOptional(sodiumText)
        let potassium = parseOptional(potassiumText)
        let calcium = parseOptional(calciumText)
        let iron = parseOptional(ironText)
        let vitA = parseOptional(vitaminAText)
        let vitC = parseOptional(vitaminCText)
        let sugar = parseOptional(sugarText)
        let chol = parseOptional(cholesterolText)

        let micronutrients: MicronutrientProfile?
        if sodium != nil || potassium != nil || calcium != nil || iron != nil || vitA != nil || vitC != nil || sugar != nil || chol != nil {
            micronutrients = MicronutrientProfile(
                sodiumMg: sodium,
                potassiumMg: potassium,
                calciumMg: calcium,
                ironMg: iron,
                vitaminAMcg: vitA,
                vitaminCMg: vitC,
                sugarGrams: sugar,
                cholesterolMg: chol
            )
        } else {
            micronutrients = nil
        }

        let food = CustomFood(
            id: existingFood?.id ?? UUID(),
            name: trimmedName,
            category: category,
            brand: brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : brand,
            servingUnit: servingUnit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "phần" : servingUnit,
            servingGrams: servingGrams,
            caloriesPerServing: calories,
            proteinGrams: protein,
            carbGrams: carbs,
            fatGrams: fat,
            fiberGrams: fiber,
            micronutrients: micronutrients,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes,
            isFavorite: isFavorite,
            createdAt: existingFood?.createdAt ?? Date(),
            updatedAt: Date()
        )

        isSaving = true
        errorMessage = nil

        Task {
            do {
                try await environment.saveCustomFoodUseCase.execute(food)
                isSaving = false
                onSaved(food)
                dismiss()
            } catch {
                isSaving = false
                errorMessage = "Không thể lưu món: \(error.localizedDescription)"
            }
        }
    }
}

// Custom TextField Style for consistent botanical forms
public struct BotanicalFormTextFieldStyle: TextFieldStyle {
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 14))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(AppColors.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
    }
}
