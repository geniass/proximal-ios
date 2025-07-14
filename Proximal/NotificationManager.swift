//
//  NotificationManager.swift
//  Proximal
//
//  Created by Ari Croock on 2025/07/13.
//

import Foundation
import UserNotifications
import CoreLocation

class NotificationManager {
    static let shared = NotificationManager()
    
    let categoryIdentifier = "PROXIMITY_ALERT"
    
    private init() {}
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
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
        
        let content = UNMutableNotificationContent()
        content.title = "Nearby Place: \(place.name)"
        content.body = "You are approximately \(Int(distance)) meters away."
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: place.name, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
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
}
