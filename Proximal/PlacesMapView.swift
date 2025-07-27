//
//  PlacesMapView.swift
//  Proximal
//
//  Created by Ari Croock on 2025/07/13.
//

import SwiftUI
import MapKit

struct PlacesMapView: View {
    let trip: Trip
    @StateObject private var locationManager = LocationManager.shared
    
    var body: some View {
        Map {
            // Show the user's location on the map
            UserAnnotation()
            
            // Draw a circle around the user's location
            if let location = locationManager.currentLocation {
                MapCircle(center: location.coordinate, radius: 500)
                    .foregroundStyle(.blue.opacity(0.2))
                    .stroke(.blue, lineWidth: 1)
            }
            
            // Show annotations for all the places in the trip
            ForEach(trip.places ?? []) { place in
                Annotation(place.name, coordinate: place.coordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        .foregroundColor(place.isActive ? .red : .gray)
                }
            }
        }
        .mapControls {
            // Add map controls for user tracking and zoom
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
    }
}
