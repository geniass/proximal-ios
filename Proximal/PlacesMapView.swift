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
    
    var body: some View {
        Map {
            ForEach(trip.places ?? []) { place in
                Annotation(place.name, coordinate: place.coordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
            }
        }
    }
}
