//
//  LocationManager.swift
//  Proximal
//
//  Created by Ari Croock on 2025/07/13.
//

import Foundation
import CoreLocation
import UserNotifications
import SwiftData
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    var modelContext: ModelContext?
    @Published var isTracking = false
    
    override private init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestPermissions() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startMonitoring() {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            print("Geofencing is not supported on this device.")
            return
        }
        
        if locationManager.authorizationStatus != .authorizedAlways {
            print("Location permission not granted.")
            return
        }
        
        locationManager.startUpdatingLocation()
        isTracking = true
    }
    
    func stopMonitoring() {
        locationManager.stopUpdatingLocation()
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        isTracking = false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Stop updating location to save battery
        locationManager.stopUpdatingLocation()
        
        // Create a new geofence
        let region = CLCircularRegion(center: location.coordinate, radius: 200, identifier: "user_geofence")
        region.notifyOnExit = true
        locationManager.startMonitoring(for: region)
        
        print("Started monitoring region at: \(location.coordinate)")
        
        checkProximity(to: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region: \(region.identifier)")
        
        // Get new location and check for nearby places
        locationManager.startUpdatingLocation()
    }
    
    private func checkProximity(to location: CLLocation) {
        guard let modelContext = modelContext else {
            print("Model context not available.")
            return
        }
        
        do {
            let fetchDescriptor = FetchDescriptor<Place>(predicate: #Predicate { $0.isActive })
            let places = try modelContext.fetch(fetchDescriptor)
            
            for place in places {
                let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
                let distance = location.distance(from: placeLocation)
                
                if distance <= 500 {
                    if let lastNotified = place.lastNotified, Date().timeIntervalSince(lastNotified) < 3600 {
                        // Less than an hour has passed, so don't notify
                        continue
                    }
                    
                    place.lastNotified = Date()
                    NotificationManager.shared.sendProximityNotification(for: place, from: location)
                }
            }
        } catch {
            print("Failed to fetch places: \(error)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region?.identifier ?? "unknown") error: \(error.localizedDescription)")
    }
}
