//
//  TrackingStatusBarView.swift
//  Proximal
//
//  Created by Ari Croock on 2025/07/13.
//

import SwiftUI

struct TrackingStatusBarView: View {
    @ObservedObject var locationManager = LocationManager.shared
    
    var body: some View {
        VStack {
            if locationManager.isTracking {
                HStack {
                    Image(systemName: "location.fill")
                    Text("Tracking Active")
                }
                .foregroundColor(.green)
            } else {
                HStack {
                    Image(systemName: "location.slash.fill")
                    Text("Tracking Inactive")
                }
                .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview {
    TrackingStatusBarView()
}
