# Project Summary: Proximity Native iOS App

## Overview
Proximity is a native iOS application designed to help users discover and be reminded of places of interest nearby, especially while traveling. The app allows users to manage trips and places of interest, and leverages intelligent background location tracking to notify users when they are close to saved locations. The architecture is optimized for battery efficiency and reliable background operation, following modern iOS best practices.

## Core Functionality
- **Trip Management:** Users can create, edit, and manage multiple trips, each with its own set of places of interest.
- **Places of Interest:** For each trip, users can add, view, and remove places they want to visit. Each place includes details such as name, coordinates, and Apple Maps Place ID (or equivalent).
- **Proximity Notifications:** The app tracks the user's location in the background and notifies them when they are near a saved place of interest (e.g., within 500 meters).
- **Distance Calculation:** The app calculates and displays the distance from the user's current location to each place of interest.
- **Intelligent Activity Recognition:** Uses the Core Motion framework to detect activity (walking, running, automotive, stationary) and pauses/resumes GPS tracking to save battery.
- **Significant Movement Detection:** Only triggers notifications for movements of 500+ meters, reducing unnecessary alerts and battery usage.

## How It Works

### Geofencing Strategy
The app uses a single dynamic geofence (a `CLCircularRegion`) centered on the user's current location rather than creating individual geofences for each POI. This approach is designed to handle the reality that users may have hundreds or thousands of POIs, while Apple limits apps to a maximum of 20 monitored regions.

**Key aspects of the geofencing method:**
- **Single 200m radius geofence** - Created at the user's current location when the app starts or location changes significantly.
- **EXIT-only trigger** - The app only wakes up when the user exits the geofence (`didExitRegion`), meaning they have moved more than 200m from their last known position.
- **Dynamic repositioning** - When triggered, the app gets the new location, checks all POIs for proximity (within 500m), sends notifications if any are found, then creates a new geofence at the new location.
- **Avoids Apple's 20 region limit** - By using only one geofence instead of one per POI, the app can handle unlimited POIs without hitting platform restrictions.
- **Reduces complexity** - No need for geofence clustering algorithms, POI prioritization, or complex region management logic.

This method ensures the app only performs location checks when the user has moved a significant distance, optimizing battery life while maintaining reliable proximity detection for any number of saved places.

### Background Processing
- On app start, the app requests "Always" location permissions and registers for region monitoring events using `CLLocationManager`.
- When the user exits the region, the `CLLocationManagerDelegate`'s `locationManager(_:didExitRegion:)` method is called, waking the app in the background to handle the event and process proximity checks.
- iOS automatically re-launches the app to handle location events if it was terminated, ensuring tracking resumes after a device reboot.
- All notifications are managed through the `UserNotifications` framework for consistency.
- The app gets a fresh location from the system rather than storing stale location data.

## User Interface
- **Trips List Screen:** A SwiftUI `List` displaying all trips with progress indicators and options to add or edit.
- **Trip Form Sheet:** A modal `.sheet` allowing users to create or edit a trip's name and dates.
- **Places of Interest Screen:** Shows all places for a selected trip, with a toggle (e.g., a `Picker`) to switch between a `List` and a `MapKit` view. Includes a search/add button and a tracking status bar.
- **Map View:** Integrates `MapKit` to display all places as `MKAnnotation` markers. Users can tap markers for details and actions.
                User can open places in Apple Maps for navigation using `MKMapItem`.
- **Tracking Status Bar:** A view indicating whether background location tracking is active.
- **Debug Features:** Includes debug toggles and info for development and troubleshooting.

## Features
- Add, edit, and delete trips and places of interest.
- View places in both list and interactive map formats.
- Real-time distance updates based on user location.
- Open places directly in Apple Maps for navigation.
- Responsive UI for various device sizes using SwiftUI.
- Background location tracking for proximity notifications.
- Smart pause/resume of tracking based on activity recognition.
- Asks for permissions when needed, and guides users to the Settings app for background location permissions.
- Persistent state across app restarts and device reboots using Core Data or SwiftData.
- Offline-first design: The app can function without an internet connection, relying on locally stored data.

## TODO Features
- Allow distance from POI to be configurable per trip.
- Allow importing or syncing trips with Apple Maps Guides.
- Trip-aware filtering - Only activate geofences for current/active trips.
- Cooldown periods - Prevent repeated notifications for the same POI within a time window.
- Context-aware filtering - Don't notify about restaurants during non-meal hours.
- Distance and direction info - Show "350m northeast" in notifications.
- Notification action buttons - Add "Navigate" and "Snooze" buttons to notifications.
- Notification grouping - Bundle multiple nearby places into one expandable notification.

## Future Battery Optimization Ideas
If further battery optimization is needed, these strategies could be implemented:

### Smart Region Management
- **Activity-based activation** - Only monitor regions when the user is moving; disable during stationary periods using `CMMotionActivityManager`.
- **Time-based scheduling** - Pause monitoring during user-defined quiet hours.
- **Battery level adaptation** - Increase region radius or reduce check frequency when in Low Power Mode.

### Location Strategy Optimization
- **Adaptive radius** - Increase region radius in rural areas, decrease in urban areas.
- **Distance-based POI filtering** - Only check POIs within a reasonable range (e.g., 10km).
- **Significant location change** - Use the significant-change location service (`startMonitoringSignificantLocationChanges`) as a fallback or primary mechanism.

### Notification Intelligence
- **Batch processing** - Group multiple nearby POI checks into a single location request.
- **Smart wake patterns** - Align processing with other app activities to reduce independent wake-ups.

### System Integration
- **Background App Refresh** - Ensure compliance with iOS background execution policies.
- **Network usage optimization** - Cache POI data locally to minimize network calls.
- **Sensor fusion** - Use the accelerometer/gyroscope to detect movement before engaging GPS.

## Stretch Goals
- **Landmark-based directions** - Instead of cardinal directions, use nearby landmarks as references (e.g., "350m toward Central Station"). This would require querying nearby places from Apple Maps and calculating which landmark is in the same direction as the target POI.

## Architecture Overview
- **Standard Background Location:** All background work is handled via the `CoreLocation` framework, not a persistent foreground process.
- **NotificationManager:** Centralized notification logic using `UserNotifications`.
- **LocationDelegate:** A class conforming to `CLLocationManagerDelegate` to handle all location and region updates.
- **Modern iOS Practices:** Uses SwiftUI for the UI, Combine or async/await for concurrency, and modern permission handling.

## Technologies Used
- **Swift** for native iOS development.
- **SwiftUI** for building the user interface.
- **MapKit** for map integration and displaying annotations.
- **Core Location** for efficient location tracking and region monitoring.
- **Core Motion** for detecting user activity.
- **UserNotifications** for delivering local notifications.
- **Core Data** or **SwiftData** for persistent storage of trips and places of interest.

This architecture provides reliable, battery-efficient background tracking and notification delivery, following current iOS best practices, while offering a rich trip and place management experience.