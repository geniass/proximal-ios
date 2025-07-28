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
    // The location manager will hold a reference to the data store.
    private var dataStore: BackgroundDataStore!
    @Published var isTracking = false
    @Published var currentLocation: CLLocation?
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func configure(modelContainer: ModelContainer) {
        self.dataStore = BackgroundDataStore(modelContainer: modelContainer)
    }
    
    func validateAndStartMonitoring() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            isTracking = true
        default:
            isTracking = false
            print("Location permission is not 'Always'. Tracking cannot start.")
        }
    }
    
    func stopMonitoring() {
        locationManager.stopUpdatingLocation()
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        isTracking = false
    }
    
    func resetAllCooldowns() {
        Task {
            await dataStore.resetAllCooldowns()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        validateAndStartMonitoring()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.currentLocation = location
        
        locationManager.stopUpdatingLocation()
        
        let region = CLCircularRegion(center: location.coordinate, radius: 200, identifier: "user_geofence")
        region.notifyOnExit = true
        locationManager.startMonitoring(for: region)
        
        print("Started monitoring region at: \(location.coordinate)")
        
        checkProximity(to: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region: \(region.identifier)")
        locationManager.startUpdatingLocation()
    }
    
    private func checkProximity(to location: CLLocation) {
        // Ensure the data store has been configured.
        guard dataStore != nil else {
            print("LocationManager: Data store not configured.")
            return
        }
        
        Task.detached(priority: .background) {
            // Fetch fresh data using the actor's context to ensure consistency.
            let context = ModelContext(self.dataStore.modelContainer)
            let descriptor = FetchDescriptor<Place>()
            guard let places = try? context.fetch(descriptor) else { return }
            
            for place in places where place.isActive {
                let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
                let distance = location.distance(from: placeLocation)
                
                if distance <= 500 {
                    if let lastNotified = place.lastNotified, Date().timeIntervalSince(lastNotified) < 300 {
                        continue
                    }
                    
                    // Tell the data store actor to update the official record.
                    await self.dataStore.updateLastNotified(for: place.persistentModelID)
                    NotificationManager.shared.sendProximityNotification(for: place, from: location)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region?.identifier ?? "unknown") error: \(error.localizedDescription)")
    }
}
