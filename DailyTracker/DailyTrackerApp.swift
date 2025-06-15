//
//  DailyTrackerApp.swift
//  DailyTracker
//
//  Created by Osman Ali Deol on 2025-05-06.
//

import SwiftUI

@main
struct DailyTrackerApp: App {
    @AppStorage("hasSetupGoals") var hasSetupGoals: Bool = false

    var body: some Scene {
        WindowGroup {
            if hasSetupGoals {
                MainTabView()  // ✅ This shows both Today + Weekly tabs
            } else {
                SetupView()    // First-time goal setup
            }
        }
    }
}
