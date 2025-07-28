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
    
    init() {
        NotificationManager.shared.requestAuthorization()
        NotificationManager.shared.registerNotificationCategories()
    }

    var body: some Scene {
        WindowGroup {
            TripsListView()
                .onAppear {
                    let container = try! ModelContainer(for: Trip.self, Place.self)
                    LocationManager.shared.configure(modelContainer: container)
                }
        }
        .modelContainer(for: [Trip.self, Place.self])
    }
}
