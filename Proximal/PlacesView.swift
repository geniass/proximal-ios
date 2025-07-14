//
//  PlacesView.swift
//  Proximal
//
//  Created by Ari Croock on 2025/07/13.
//

import SwiftUI

struct PlacesView: View {
    let trip: Trip
    
    @State private var viewMode: ViewMode = .list
    @State private var isShowingPlaceForm = false
    
    enum ViewMode {
        case list
        case map
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Picker("View Mode", selection: $viewMode) {
                    Text("List").tag(ViewMode.list)
                    Text("Map").tag(ViewMode.map)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                switch viewMode {
                case .list:
                    PlacesListView(trip: trip)
                case .map:
                    PlacesMapView(trip: trip)
                }
            }
            
            TrackingStatusBarView()
        }
        .navigationTitle(trip.name)
        .toolbar {
            ToolbarItem {
                Button(action: { isShowingPlaceForm = true }) {
                    Label("Add Place", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingPlaceForm) {
            PlaceFormView(trip: trip)
        }
    }
}
