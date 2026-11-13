//
//  CreateEditPackagedFoodView.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//  Form to create a new packaged food record or edit an existing one.
//

import SwiftUI

public struct CreateEditPackagedFoodView: View {
    @ObservedObject var viewModel: BarcodeScannerViewModel
    @Environment(\.dismiss) private var dismiss

    private let existingFood: PackagedFood?

    // Form fields
    @State private var barcode: String
    @State private var barcodeType: BarcodeType
    @State private var productName: String
    @State private var brand: String
    @State private var category: String
    @State private var servingSizeText: String
    @State private var servingUnit: String
    @State private var servingsPerPackageText: String
    @State private var servingGramsText: String

    @State private var basis: NutritionBasis
    @State private var caloriesText: String
    @State private var proteinText: String
    @State private var carbsText: String
    @State private var fatText: String
    @State private var fiberText: String
    @State private var sodiumText: String
    @State private var sugarText: String

    @State private var ingredientText: String
    @State private var selectedAllergens: Set<AllergenType>
    @State private var notes: String
    @State private var validationError: String?

    public init(viewModel: BarcodeScannerViewModel, existingFood: PackagedFood? = nil, initialBarcode: String? = nil) {
        self.viewModel = viewModel
        self.existingFood = existingFood

        let initBarcode = existingFood?.barcode ?? initialBarcode ?? ""
        _barcode = State(initialValue: initBarcode)
        _barcodeType = State(initialValue: existingFood?.barcodeType ?? .ean13)
        _productName = State(initialValue: existingFood?.productName ?? "")
        _brand = State(initialValue: existingFood?.brand ?? "")
        _category = State(initialValue: existingFood?.category ?? "Thực phẩm đóng gói")
        _servingSizeText = State(initialValue: String(format: "%.0f", existingFood?.serving.servingSize ?? 100))
        _servingUnit = State(initialValue: existingFood?.serving.servingUnit ?? "g")
        _servingsPerPackageText = State(initialValue: existingFood?.serving.servingsPerPackage.map { String(format: "%.1f", $0) } ?? "1.0")
        _servingGramsText = State(initialValue: String(format: "%.0f", existingFood?.serving.servingGramsEquivalent ?? 100))

        _basis = State(initialValue: existingFood?.nutrition.basis ?? .perServing)
        _caloriesText = State(initialValue: String(format: "%.0f", existingFood?.nutrition.calories ?? 0))
        _proteinText = State(initialValue: String(format: "%.1f", existingFood?.nutrition.proteinGrams ?? 0))
        _carbsText = State(initialValue: String(format: "%.1f", existingFood?.nutrition.carbGrams ?? 0))
        _fatText = State(initialValue: String(format: "%.1f", existingFood?.nutrition.fatGrams ?? 0))
        _fiberText = State(initialValue: existingFood?.nutrition.fiberGrams.map { String(format: "%.1f", $0) } ?? "")
        _sodiumText = State(initialValue: existingFood?.nutrition.sodiumMg.map { String(format: "%.0f", $0) } ?? "")
        _sugarText = State(initialValue: existingFood?.nutrition.sugarGrams.map { String(format: "%.1f", $0) } ?? "")

        _ingredientText = State(initialValue: existingFood?.ingredientText ?? existingFood?.ingredients.joined(separator: ", ") ?? "")
        _selectedAllergens = State(initialValue: Set(existingFood?.allergens ?? []))
        _notes = State(initialValue: existingFood?.notes ?? "")
    }

    public var body: some View {
        NavigationStack {
            Form {
                // Section 1: Basic Barcode & Identification
                Section("Thông tin mã vạch & Tên món") {
                    HStack {
                        Text("Mã vạch")
                            .foregroundStyle(AppColors.textSecondary)
                        Spacer()
                        Text(barcode)
                            .font(.system(.body, design: .monospaced, weight: .bold))
                            .foregroundStyle(AppColors.primary)
                    }

                    TextField("Tên sản phẩm (Bắt buộc)", text: $productName)
                        .font(AppTypography.body)

                    TextField("Thương hiệu / Nhà sản xuất (Tùy chọn)", text: $brand)
                        .font(AppTypography.body)

                    Picker("Phân loại", selection: $category) {
                        Text("Thực phẩm đóng gói").tag("Thực phẩm đóng gói")
                        Text("Sữa & Chế phẩm sữa").tag("Sữa & Chế phẩm từ sữa")
                        Text("Mì & Thực phẩm ăn liền").tag("Mì & Thực phẩm ăn liền")
                        Text("Đồ uống & Giải khát").tag("Đồ uống & Giải khát")
                        Text("Bánh kẹo & Snack").tag("Bánh kẹo & Đồ ăn vặt")
                        Text("Gia vị & Nước chấm").tag("Gia vị & Nước chấm")
                        Text("Hạt & Đồ sấy khô").tag("Hạt & Đồ ăn vặt dinh dưỡng")
                    }
                }

                // Section 2: Serving info
                Section("Quy cách khẩu phần") {
                    HStack {
                        Text("Kích thước:")
                        TextField("100", text: $servingSizeText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        TextField("Đơn vị (g, ml)", text: $servingUnit)
                            .frame(width: 60)
                    }

                    HStack {
                        Text("Số khẩu phần / gói:")
                        Spacer()
                        TextField("1.0", text: $servingsPerPackageText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Trọng lượng quy đổi (g):")
                        Spacer()
                        TextField("100", text: $servingGramsText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                // Section 3: Nutrition
                Section("Dinh dưỡng khai báo") {
                    Picker("Cơ sở tính toán", selection: $basis) {
                        ForEach(NutritionBasis.allCases, id: \.self) { b in
                            Text(b.rawValue).tag(b)
                        }
                    }

                    HStack {
                        Text("Năng lượng (Calo):")
                        Spacer()
                        TextField("0", text: $caloriesText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("kcal").font(.caption).foregroundColor(.gray)
                    }

                    HStack {
                        Text("Chất đạm (Protein):")
                        Spacer()
                        TextField("0", text: $proteinText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g").font(.caption).foregroundColor(.gray)
                    }

                    HStack {
                        Text("Tinh bột (Carb):")
                        Spacer()
                        TextField("0", text: $carbsText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g").font(.caption).foregroundColor(.gray)
                    }

                    HStack {
                        Text("Chất béo (Fat):")
                        Spacer()
                        TextField("0", text: $fatText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g").font(.caption).foregroundColor(.gray)
                    }

                    HStack {
                        Text("Chất xơ:")
                        Spacer()
                        TextField("Không bắt buộc", text: $fiberText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g").font(.caption).foregroundColor(.gray)
                    }

                    HStack {
                        Text("Natri (Sodium):")
                        Spacer()
                        TextField("Không bắt buộc", text: $sodiumText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("mg").font(.caption).foregroundColor(.gray)
                    }

                    HStack {
                        Text("Đường (Sugar):")
                        Spacer()
                        TextField("Không bắt buộc", text: $sugarText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g").font(.caption).foregroundColor(.gray)
                    }
                }

                // Section 4: Ingredients & Allergens
                Section("Thành phần & Dị ứng") {
                    TextField("Danh sách thành phần (cách nhau bởi dấu phẩy)", text: $ingredientText, axis: .vertical)
                        .lineLimit(3...6)

                    Text("Chọn các nhóm dị ứng có trong sản phẩm:")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)

                    ForEach(AllergenType.allCases) { allergen in
                        HStack {
                            Label(allergen.vietnameseName, systemImage: allergen.systemIcon)
                            Spacer()
                            if selectedAllergens.contains(allergen) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primary)
                                    .fontWeight(.bold)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedAllergens.contains(allergen) {
                                selectedAllergens.remove(allergen)
                            } else {
                                selectedAllergens.insert(allergen)
                            }
                        }
                    }
                }

                // Section 5: Notes
                Section("Ghi chú bổ sung") {
                    TextField("Ghi chú cá nhân", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }

                if let error = validationError {
                    Section {
                        Text(error)
                            .font(AppTypography.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(existingFood == nil ? "Thêm sản phẩm mới" : "Chỉnh sửa sản phẩm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        saveProduct()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)
                }
            }
        }
    }

    private func saveProduct() {
        let cleanName = productName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else {
            validationError = "Vui lòng nhập tên sản phẩm"
            return
        }

        let barcodeVal = BarcodeValue(rawValue: barcode)
        guard barcodeVal.isValid else {
            validationError = barcodeVal.validationError ?? "Mã vạch không hợp lệ"
            return
        }

        let sSize = Double(servingSizeText.replacingOccurrences(of: ",", with: ".")) ?? 100
        let sServings = Double(servingsPerPackageText.replacingOccurrences(of: ",", with: ".")) ?? 1.0
        let sGrams = Double(servingGramsText.replacingOccurrences(of: ",", with: ".")) ?? sSize

        let cal = Double(caloriesText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let prot = Double(proteinText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let carb = Double(carbsText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let fat = Double(fatText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let fiber = Double(fiberText.replacingOccurrences(of: ",", with: "."))
        let sodium = Double(sodiumText.replacingOccurrences(of: ",", with: "."))
        let sugar = Double(sugarText.replacingOccurrences(of: ",", with: "."))

        let parsedIngredients = ingredientText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let serving = PackagedFoodServing(
            servingSize: sSize,
            servingUnit: servingUnit,
            servingsPerPackage: sServings,
            servingGramsEquivalent: sGrams
        )

        let nutrition = PackagedFoodNutrition(
            calories: cal,
            proteinGrams: prot,
            carbGrams: carb,
            fatGrams: fat,
            fiberGrams: fiber,
            sodiumMg: sodium,
            sugarGrams: sugar,
            basis: basis
        )

        let food = PackagedFood(
            id: existingFood?.id ?? UUID(),
            barcode: barcodeVal.normalizedValue,
            rawBarcode: barcode,
            barcodeType: barcodeVal.type,
            productName: cleanName,
            brand: brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : brand.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            serving: serving,
            nutrition: nutrition,
            ingredients: parsedIngredients,
            ingredientText: ingredientText.isEmpty ? nil : ingredientText,
            allergens: Array(selectedAllergens),
            verificationStatus: .verified,
            isFavorite: existingFood?.isFavorite ?? false,
            lastScannedAt: Date(),
            createdAt: existingFood?.createdAt ?? Date(),
            updatedAt: Date(),
            notes: notes.isEmpty ? nil : notes
        )

        Task {
            let success = await viewModel.saveProductToLibrary(food)
            if success {
                viewModel.activeProduct = food
                viewModel.activeLookupSource = .userLibrary
                viewModel.evaluateSafety(for: food)
                viewModel.showResultSheet = true
                dismiss()
            } else {
                validationError = viewModel.errorMessage
            }
        }
    }
}

