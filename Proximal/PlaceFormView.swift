//
//  PlaceFormView.swift
//  Proximal
//
//  Created by Ari Croock on 2025/07/13.
//

import SwiftUI
import MapKit

struct PlaceFormView: View {
    @Environment(\.dismiss) private var dismiss
    let trip: Trip
    
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Search for a place", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: search) {
                        Image(systemName: "magnifyingglass")
                    }
                }
                .padding()
                
                List(searchResults, id: \.self) { mapItem in
                    Button(action: { selectPlace(mapItem) }) {
                        VStack(alignment: .leading) {
                            Text(mapItem.name ?? "Unknown")
                                .font(.headline)
                            Text(mapItem.placemark.title ?? "")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Add Place")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func search() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            searchResults = response.mapItems
        }
    }
    
    private func selectPlace(_ mapItem: MKMapItem) {
        let newPlace = Place(
            name: mapItem.name ?? "Unknown",
            latitude: mapItem.placemark.coordinate.latitude,
            longitude: mapItem.placemark.coordinate.longitude,
            placeID: mapItem.placemark.description, // Using description as a stand-in for a real ID
            isActive: true
        )
        trip.places?.append(newPlace)
        dismiss()
    }
}
