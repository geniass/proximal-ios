//
//  PlacesListView.swift
//  Proximal
//
//  Created by Ari Croock on 2025/07/13.
//

import SwiftUI
import SwiftData
import MapKit

struct PlacesListView: View {
    let trip: Trip
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var now = Date()
    
    var body: some View {
        List {
            ForEach(trip.places ?? []) { place in
                HStack {
                    VStack(alignment: .leading) {
                        Text(place.name)
                        if let cooldownText = cooldownText(for: place) {
                            Text(cooldownText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        openInMaps(place: place)
                    }) {
                        Image(systemName: "map.fill")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Toggle("Active", isOn: Binding(
                        get: { place.isActive },
                        set: { place.isActive = $0 }
                    ))
                    .labelsHidden()
                }
            }
        }
        .onReceive(timer) { input in
            now = input
        }
    }
    
    private func cooldownText(for place: Place) -> String? {
        guard let lastNotified = place.lastNotified else { return nil }
        
        let cooldown: TimeInterval = AppConstants.notificationCooldown // 1 hour
        let remaining = (lastNotified.addingTimeInterval(cooldown)).timeIntervalSince(now)
        
        if remaining > 0 {
            let minutes = Int(remaining) / 60
            let seconds = Int(remaining) % 60
            return "Cooldown: \(String(format: "%02d:%02d", minutes, seconds))"
        }
        
        return nil
    }
    
    private func openInMaps(place: Place) {
        let placemark = MKPlacemark(coordinate: place.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = place.name
        mapItem.openInMaps()
    }
}