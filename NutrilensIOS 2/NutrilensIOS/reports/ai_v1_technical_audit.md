# NutriLens AI Food Recognition V1 — Technical Audit & Release-Blocker Report

**Auditors:** Principal Core ML Engineer, Senior iOS Architect, AI Quality Assurance Engineer  
**Date:** 2026-11-03  
**Scope:** NutriLens iOS Architecture, Core ML Model Pipeline, On-Device Fallback, OOD Calibration, Nutrition Database Integrity, and Automated Test Coverage.  
**Classification:** RELEASE BLOCKER AUDIT (Milestone Acceptance Gate)

---

## 1. Executive Summary & Verdict

| Audit Dimension | Status | Severity | Summary |
|---|---|---|---|
| **Core ML Model Execution** | **FAILED** | **CRITICAL BLOCKER** | The NutriLens EfficientNet-B0 (Experiment B) model is NOT bundled in Xcode. 100% of runtime image inferences fall back to Apple's private Vision framework. |
| **Model Provenance** | **BLOCKED** | **CRITICAL BLOCKER** | The source PyTorch checkpoint `best_checkpoint.pt` exists and its SHA-256 (`7a7d01ae...`) is verified. However, **no Core ML conversion has been executed** (`.mlmodelc` / `.mlpackage` absent). |
| **OOD Detection Calibration** | **AMENDED / FLAGGED** | **HIGH** | The research threshold was $\tau=0.70$ (Temperature $T=1.5$). The code used an uncalibrated heuristic $\tau=0.45$ to accommodate Apple Vision. Now formally separated into validated vs. unvalidated detectors. |
| **Nutrition Data Provenance** | **CORRECTED** | **MODERATE** | Prior to audit, only 15 dishes existed (causing 15/30 model classes to map incorrectly to Phở). The database has been expanded to all 30 classes with NIN citations and explicit limitations. |
| **Simulator Test Coverage** | **AUDITED** | **HIGH** | 0% of automated unit or UI tests execute real Core ML inference. Tests rely on mock repositories and sample button clicks. Core ML inference is unverified in automation. |
| **Overall Release Verdict** | **REJECTED FOR RELEASE** | **BLOCKER** | **The app is NOT production-ready for AI-driven food recognition until Core ML conversion, bundled weights, and parity validation are completed.** |

---

## 2. Task 1 — Actual Model Execution Audit

### Detailed Findings

1. **Is the NutriLens EfficientNet-B0 Experiment B model bundled?**
   - **NO**. A full filesystem search of `NutriLens.xcodeproj` and application bundles reveals zero compiled Core ML artifacts (`.mlmodelc`, `.mlmodel`, or `.mlpackage`).
2. **Does a valid `.mlmodelc` or `.mlpackage` exist anywhere in the project or workspace?**
   - **NO**. In `/Users/vanquyen/Documents/NutrilensIOS` and research directory `/Users/vanquyen/Documents/dataset`, only PyTorch checkpoints (`.pt`) exist. No Core ML model artifact has ever been generated or compiled with `xcrun coremlc`.
3. **Is it included in the application target build phases?**
   - **NO**. `NutriLens.xcodeproj/project.pbxproj` contains zero file references, build files, or resource copy phases (`PBXResourcesBuildPhase`) referencing a machine learning model.
4. **Does inference actually execute through this model?**
   - **NO**. In [CoreMLFoodInferenceEngine.swift](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/AI/Prediction/CoreMLFoodInferenceEngine.swift):
     ```swift
     if let customModelURL = Bundle.main.url(forResource: "FoodClassifier", withExtension: "mlmodelc"),
        let customMLModel = try? MLModel(contentsOf: customModelURL),
        let vnCoreMLModel = try? VNCoreMLModel(for: customMLModel) { ... }
     ```
     `Bundle.main.url(forResource:withExtension:)` returns `nil`. The Core ML code path is completely unexecuted.
5. **Under what conditions is `VNClassifyImageRequest` used?**
   - In the initial implementation, **100% of runtime image inferences** executed through Apple Vision's built-in `VNClassifyImageRequest`.
   - `VNClassifyImageRequest` is Apple's generic multi-label scene/object classifier containing thousands of broad classes (e.g., "soup", "noodle", "dish", "sandwich").
   - The engine filtered these labels using string matching (`["food", "noodle", "soup", ...]`) and mapped the first matched keyword to an entry in `VietnameseNutritionDatabase`.
6. **Can the UI distinguish custom-model results from fallback results?**
   - **Previously: NO**. The UI hardcoded `AI VISION · ON-DEVICE` and presented high match percentages, masking the fallback.
   - **Remediated**: The UI and ViewModel now inspect `isUsingFallbackEngine` and explicitly display `APPLE VISION • FALLBACK` with an amber warning badge when fallback is active, reserving `NUTRILENS AI • ON-DEVICE` only for true Core ML execution.

---

## 3. Task 2 — Model Provenance & Conversion Gap

### Checkpoint Provenance (Verified)
- **Source Artifact:** `/Users/vanquyen/Documents/dataset/models/production_candidate/best_checkpoint.pt`
- **Source Experiment:** Phase 4 Experiment B (`models/phase4/experiment_b`)
- **Computed SHA-256 Checksum:** `7a7d01ae33f76426c0025e377e26fb1bd2bc5d04baf8cea6af0c94d42b4a3ff0` (Verified via `shasum -a 256`)
- **Base Architecture:** `torchvision.models.efficientnet_b0` (Dropout $p=0.2$, Linear head $1280 \to 30$)
- **Parameters:** 4,045,978 (FP32, 49,026,969 bytes)
- **Class Count:** Exactly 30 canonical Vietnamese culinary classes (`banh_beo` $\to$ `xoi`)
- **Validation Accuracy (Internal):** 83.48% (Macro F1: 83.31%)
- **Validation Accuracy (External 11-Class Benchmark):** 91.57%

### The Missing Conversion Step (Release Blocker)
The model was trained in PyTorch, but the bridge to Apple Core ML was **never implemented**:
1. `coremltools` is not installed in `/Users/vanquyen/Documents/dataset/.venv`.
2. No conversion script exists to trace or export the model to `.mlpackage`.
3. Preprocessing parameters in Python (`T.Resize(224, bicubic)`, `T.CenterCrop(224)`, normalization: mean `[0.485, 0.456, 0.406]`, std `[0.229, 0.224, 0.225]`) have not been embedded into Core ML model metadata.
4. **Parity Gap**: Top-1/Top-5 agreement, logit error, and drift between PyTorch and Core ML have **never been measured**.

---

## 4. Task 3 — Out-of-Distribution (OOD) Audit

### Threshold Divergence
- **Research Calibration (Phase 4):**
  - Architecture: EfficientNet-B0 (30 classes closed set).
  - Method: Temperature-Scaled Softmax ($T=1.5$).
  - Calibrated Operational Threshold: $\mathbf{\tau = 0.70}$.
  - Empirical Performance: **89.71% unknown rejection rate**, **10.29% false acceptance rate**, **AUROC 0.872**.
- **Implementation State (Prior to Audit):**
  - Threshold was arbitrarily changed to $\mathbf{\tau = 0.45}$ in `DefaultOODDetector`.
  - **Reason for Change:** Under Apple's broad Vision taxonomy, confidence scores for specific food categories rarely exceed $0.50$. Using $0.70$ on Apple Vision resulted in nearly 100% false rejections of actual food photos.
  - **Violation:** Scores from a 30-class Softmax distribution with temperature scaling are **mathematically incomparable** to Apple Vision's hierarchical multi-label probabilities. Applying a single threshold across different score distributions without calibration violates Section 5 of `GEMINI.md`.

### Remediation Implemented
1. Created [ValidatedEfficientNetB0OODDetector](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/AI/OOD/OODDetectorProtocol.swift) locked at $\tau=0.70$, $T=1.5$, with explicit provenance.
2. Created [UnvalidatedVisionFallbackOODDetector](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/AI/OOD/OODDetectorProtocol.swift) with $\tau=0.45$, explicitly flagging `isValidated = false` and logging audit warnings.
3. Updated [FoodRecognitionView.swift](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Features/FoodRecognition/FoodRecognitionView.swift) to warn the user whenever prediction confidence is $< 0.70$.

---

## 5. Task 4 — Nutrition Database Audit

### Initial Defect: Taxonomy Mismatch
The AI model outputs 30 classes:
```
banh_beo, banh_bot_loc, banh_can, banh_canh, banh_chung, banh_cuon, banh_duc, banh_gio,
banh_khot, banh_mi, banh_pia, banh_tet, banh_trang_nuong, banh_xeo, bun_bo_hue,
bun_dau_mam_tom, bun_mam, bun_rieu, bun_thit_nuong, ca_kho_to, canh_chua, cao_lau,
chao_long, com_tam, goi_cuon, hu_tieu, mi_quang, nem_chua, pho, xoi
```
However, [VietnameseNutritionDatabase.swift](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Data/Repositories/VietnameseNutritionDatabase.swift) initially contained only 15 dishes. If the model predicted `bun_dau_mam_tom`, `ca_kho_to`, or `banh_chung`, `findBestMatch` fell back to `dishes.first` (**Phở Bò Tái Nạm**), logging completely incorrect calories and macros!

### Remediation & Database Expansion
The database has been expanded to **all 30 canonical classes** plus signature regional dishes (35 total profiles):
- Every dish now includes:
  - Canonical slug matching `class_mapping.json`.
  - Reference Code (e.g., `NIN-2007-M014`, `NIN-2007-B004`).
  - Formal Provenance: *Bảng Thành Phần Thực Phẩm Việt Nam – Viện Dinh Dưỡng Quốc Gia (Bộ Y Tế)* & USDA FoodData Central.
  - Verification Method: Distinguishes laboratory chemical analysis from standardized recipe summation.
  - Explicit Nutritional Limitations: Discloses liquid vs. solid variance (e.g., broth consumption accounting for $\pm 20\%$ calories and sodium).

### Portion Scaling Arithmetic Audit
In [FoodItem.swift](file:///Users/vanquyen/Documents/NutrilensIOS/NutriLens/Domain/Entities/FoodItem.swift):
$$\text{Factor} = \frac{\text{Target Grams}}{\text{Serving Size Grams}}$$
$$\text{Nutrient}' = \text{Nutrient} \times \text{Factor}$$
- **Correctness:** Arithmetic scaling is verified.
- **Scientific Limitation:** Linear scaling assumes uniform nutrient distribution. For soup dishes (Phở, Bún Bò), users rarely consume 100% of the broth, creating an estimated 15–25% variance in actual consumed calories and sodium.

---

## 6. Task 5 — Automated Test Coverage Audit

| Test Target | Test Name | Model Tested | Camera Tested | Inference Reality |
|---|---|---|---|---|
| `NutriLensTests` | `testVietnameseNutritionDatabaseDataIntegrity` | None | None | Unit check on static database structs |
| `NutriLensTests` | `testThirtyCanonicalClassesIntegrity` | None | None | Verifies 30-class mapping coverage |
| `NutriLensTests` | `testOODDetectorModelSpecificThresholds` | None | None | Verifies threshold constants (0.70 vs 0.45) |
| `NutriLensTests` | `testFoodRecognitionFlowStepTransitions` | **Mock** | None | `MockFoodRecognitionRepository` with preset sample |
| `NutriLensTests` | `testOODHandlingInViewModel` | **Mock** | None | `MockFoodRecognitionRepository(shouldSimulateOOD: true)` |
| `NutriLensTests` | `testCameraServiceOnSimulator` | None | Hardware check | Asserts simulator camera is unavailable |
| `NutriLensUITests` | `testCompleteFoodRecognitionFlow` | **Bypassed** | Simulated | **Taps sample UI button ("Phở Bò Tái Nạm"); skips AI inference** |

### Key Finding
**There is currently ZERO automated test coverage running actual image inference through `CoreMLFoodInferenceEngine.infer(pixelBuffer:)` with a test image bundle.** The passing tests only prove UI state transitions and SwiftData persistence.

---

## 7. Dataset & Model Distribution Rights

In accordance with Section 5 of `GEMINI.md`:
1. **Source Dataset Provenance:** The 30-class training corpus was aggregated from `30VNFoods` (Quan Dang et al., IEEE 2021) and filtered web crawls (`VinaFood21`).
2. **License Status:** The academic paper and GitHub release permit research and academic evaluation. However, the raw crawled images lack explicit commercial redistribution waivers.
3. **App Store Legal Risk:** Distributing the weights in a public, commercial App Store app requires either:
   - Written confirmation of open commercial data licensing, or
   - Completing Phase 4.4 protocol (in-house proprietary dataset expansion and re-licensing).

---

## 8. Release Blockers & Corrective Action Plan

```
[BLOCKER 1: Missing Core ML Model]
├── Action: Convert best_checkpoint.pt (SHA-256: 7a7d01ae...) to Core ML (.mlpackage).
├── Tooling: Install coremltools in Python venv; trace PyTorch model; set RGB inputs, scale 1/255, and class labels.
└── Action: Compile to FoodClassifier.mlmodelc and embed in NutriLens.xcodeproj resources.

[BLOCKER 2: Preprocessing & Parity Validation]
├── Action: Verify Top-1 / Top-5 parity between PyTorch and Core ML on the 1,495 validation images.
└── Action: Validate that ImagePreprocessor aspect-fill/center-crop matches PyTorch transforms.

[BLOCKER 3: Automated Real-Inference Testing]
├── Action: Add integration test feeding a real test food image (e.g., pho_test.jpg) into CoreMLFoodInferenceEngine.
└── Action: Assert output matches canonical class with expected confidence.

[BLOCKER 4: Distribution Licensing]
└── Action: Complete licensing audit of training imagery before commercial App Store submission.
```

---

## 9. Conclusion

The NutriLens UI/UX and SwiftData architecture are exceptionally well-engineered, robust, and beautiful. However, **from a Core ML and AI engineering perspective, the V1 milestone is not production-ready**. 

The code changes made in this audit establish strict transparency: Apple Vision fallback is now explicitly disclosed in logs and UI, the full 30-class taxonomy is supported with traceable NIN citations, and OOD detectors are properly segregated. Converting and embedding the actual EfficientNet-B0 Core ML model is the final mandatory step before release.
