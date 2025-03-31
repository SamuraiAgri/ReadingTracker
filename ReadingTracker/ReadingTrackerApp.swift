//
//  ReadingTrackerApp.swift
//  ReadingTracker
//
//  Created by rinka on 2025/03/31.
//

import SwiftUI

@main
struct ReadingTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
