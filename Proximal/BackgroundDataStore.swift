//
//  BackgroundDataStore.swift
//  Proximal
//
//  Created by Ari Croock on 2025/07/27.
//

import Foundation
import SwiftData

@ModelActor
public actor BackgroundDataStore {
    /// Safely updates the lastNotified date for a place from any thread.
    func updateLastNotified(for placeID: PersistentIdentifier) {
        guard let place = self[placeID, as: Place.self] else {
            print("Could not find place with ID \(placeID) in the background store.")
            return
        }
        place.lastNotified = Date()
        do {
            try modelContext.save()
            print("Successfully updated and saved lastNotified for place \(place.name).")
        } catch {
            print("Failed to save context after updating lastNotified: \(error)")
        }
    }
    
    /// Safely resets all notification cooldowns from any thread.
    func resetAllCooldowns() {
        do {
            var allPlaces = try modelContext.fetch(FetchDescriptor<Place>())
            for place in allPlaces {
                place.lastNotified = nil
            }
            try modelContext.save()
            print("Successfully reset all cooldowns in the background store.")
            
            // Re-fetch to get the updated state
            allPlaces = try modelContext.fetch(FetchDescriptor<Place>())
            print("Current cooldown statuses:")
            for place in allPlaces {
                let status = place.lastNotified == nil ? "Ready" : "On cooldown"
                print("- \(place.name): \(status)")
            }
            
        } catch {
            print("Failed to fetch and reset places in background store: \(error)")
        }
    }
}
