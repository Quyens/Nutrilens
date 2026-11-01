//
//  AppLogger.swift
//  NutriLens
//
//  Created for NutriLens Clean Architecture iOS App.
//

import Foundation
import os

public enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.nutrilens.app"

    public static let general = Logger(subsystem: subsystem, category: "General")
    public static let ai = Logger(subsystem: subsystem, category: "AIInference")
    public static let data = Logger(subsystem: subsystem, category: "Persistence")
    public static let nutrition = Logger(subsystem: subsystem, category: "Nutrition")
    public static let ui = Logger(subsystem: subsystem, category: "UI")
    public static let security = Logger(subsystem: subsystem, category: "Security")
}
