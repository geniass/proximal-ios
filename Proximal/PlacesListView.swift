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
    
    var body: some View {
        List {
            ForEach(trip.places ?? []) { place in
                HStack {
                    Text(place.name)
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
    }
    
    private func openInMaps(place: Place) {
        let placemark = MKPlacemark(coordinate: place.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = place.name
        mapItem.openInMaps()
    }
}
