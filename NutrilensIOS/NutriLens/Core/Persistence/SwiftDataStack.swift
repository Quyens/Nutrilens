//
//  SwiftDataStack.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import SwiftData

public final class SwiftDataStack: @unchecked Sendable {
    public static let shared = SwiftDataStack()

    public let container: ModelContainer

    public init(inMemory: Bool = false) {
        let schema = Schema([
            MealSDModel.self,
            FoodItemSDModel.self
        ])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        do {
            self.container = try ModelContainer(for: schema, configurations: [config])
            AppLogger.data.info("SwiftData initialized successfully. In-memory: \(inMemory)")
        } catch {
            fatalError("Could not initialize SwiftData ModelContainer: \(error.localizedDescription)")
        }
    }

    @MainActor
    public var mainContext: ModelContext {
        container.mainContext
    }
}
