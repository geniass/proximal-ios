//
//  TripFormView.swift
//  Proximal
//
//  Created by Ari Croock on 2025/07/13.
//

import SwiftUI
import SwiftData

struct TripFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State var name: String = ""
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
            }
            .navigationTitle("New Trip")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newTrip = Trip(name: name, startDate: startDate, endDate: endDate)
                        modelContext.insert(newTrip)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    TripFormView()
        .modelContainer(for: Trip.self, inMemory: true)
}
