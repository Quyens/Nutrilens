# Architecture – NutriLens

## Principles
MVVM + Clean Architecture, feature-oriented. Domain không phụ thuộc UI, persistence hay AI framework. Dependency direction hướng vào Domain; tránh dependency vòng.

## Flow
```text
SwiftUI View
  -> ViewModel (@MainActor)
  -> Use Case (Domain)
  -> Repository Protocol (Domain)
  -> Repository Implementation (Data)
       -> SwiftData / File Storage
       -> AI Recognition Service (Core ML)
```

## Layers
- **App:** entry point, navigation/coordinator, composition root, DI.
- **Features/Presentation:** Views, ViewModels, UI models, feature components.
- **Domain:** entities, value objects, use cases, repository protocols, business rules.
- **Data:** repository implementations, SwiftData models, mappers, local sources.
- **AI:** model loading, preprocessing, prediction, class mapping, OOD, AI errors.
- **Core:** Design System, persistence infrastructure, security, logging, utilities, optional networking.

## Dependency rules
- Domain không import SwiftUI, SwiftData, CoreML hoặc UIKit.
- View không gọi Data implementation hoặc Core ML trực tiếp.
- ViewModel không truy cập ModelContext trực tiếp.
- Core ML types không rò rỉ vào Domain entities.
- Mapper chuyển đổi persistence model ↔ domain entity.
- Dependency được tạo ở composition root và inject.
- Tránh global mutable state/service locator tùy tiện.

## Concurrency
UI state cập nhật trên MainActor. Inference và xử lý ảnh không block main thread. Xác định rõ actor isolation, cancellation và ownership. Không dùng Task.detached chỉ để né compiler.

## Persistence
SwiftData là local persistence mặc định. Có migration strategy trước khi đổi schema đã phát hành. Không lưu secrets trong SwiftData/UserDefaults. Có vòng đời rõ ràng cho ảnh gốc.

## Scope control
Cloud sync, account, HealthKit, analytics và backend không mặc định thuộc v1. Cần use case, privacy review và phê duyệt trước khi thêm.

## ADR
Quyết định kiến trúc lớn ghi trong Documentation/ADR theo template.
