//
//  NotificationManager.swift
//  Proximal
//
//  Created by Ari Croock on 2025/07/13.
//

import Foundation
import UserNotifications
import CoreLocation

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    let categoryIdentifier = "PROXIMITY_ALERT"
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            }
            if success {
                print("Notification authorization granted.")
            } else {
                print("Notification authorization denied.")
            }
        }
    }
    
    func registerNotificationCategories() {
        let navigateAction = UNNotificationAction(identifier: "NAVIGATE", title: "Navigate", options: .foreground)
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE", title: "Snooze", options: [])
        
        let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [navigateAction, snoozeAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    func sendProximityNotification(for place: Place, from location: CLLocation) {
        let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        let distance = location.distance(from: placeLocation)
        let direction = self.direction(from: location.coordinate, to: place.coordinate)
        
        let content = UNMutableNotificationContent()
        content.title = "Nearby Place: \(place.name)"
        content.body = "You are approximately \(Int(distance)) meters away, to the \(direction)."
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: place.name, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification for \(place.name): \(error.localizedDescription)")
            } else {
                print("Successfully scheduled notification for \(place.name).")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification banner/alert even if the app is in the foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func sendTestNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Proximity Alert"
        content.body = message
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func direction(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> String {
        let lat1 = source.latitude.toRadians()
        let lon1 = source.longitude.toRadians()

        let lat2 = destination.latitude.toRadians()
        let lon2 = destination.longitude.toRadians()

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        let degreesBearing = radiansBearing.toDegrees()

        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"]
        let index = Int((degreesBearing + 22.5) / 45.0) & 7
        return directions[index]
    }
}

fileprivate extension Double {
    func toRadians() -> Double {
        return self * .pi / 180.0
    }

    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}
