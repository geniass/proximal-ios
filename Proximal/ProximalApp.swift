//
//  ProximalApp.swift
//  Proximal
//
//  Created by Ari Croock on 2025/07/13.
//

import SwiftUI
import SwiftData

@main
struct ProximalApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Trip.self,
            Place.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        NotificationManager.shared.requestAuthorization()
        NotificationManager.shared.registerNotificationCategories()
    }

    var body: some Scene {
        WindowGroup {
            TripsListView()
        }
        .modelContainer(sharedModelContainer)
    }
}
