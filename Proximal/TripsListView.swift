//
//  TripsListView.swift
//  Proximal
//
//  Created by Ari Croock on 2025/07/13.
//

import SwiftUI
import SwiftData

struct TripsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trips: [Trip]
    @State private var isShowingTripForm = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(trips) { trip in
                    NavigationLink {
                        PlacesView(trip: trip)
                    } label: {
                        Text(trip.name)
                    }
                }
                .onDelete(perform: deleteTrips)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { isShowingTripForm = true }) {
                        Label("Add Trip", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: {
                            LocationManager.shared.resetAllCooldowns()
                        }) {
                            Label("Reset Notification Cooldowns", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Label("Debug Menu", systemImage: "ladybug")
                    }
                }
            }
            .navigationTitle("Trips")
            .sheet(isPresented: $isShowingTripForm) {
                TripFormView()
            }
            .onAppear {
                LocationManager.shared.validateAndStartMonitoring()
            }
        } detail: {
            Text("Select a trip")
        }
    }

    private func deleteTrips(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(trips[index])
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Trip.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    return TripsListView()
        .modelContainer(container)
}