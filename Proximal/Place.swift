import Foundation
import SwiftData
import CoreLocation

@Model
final class Place {
    var name: String
    var latitude: Double
    var longitude: Double
    var placeID: String?
    var lastNotified: Date?
    var isActive: Bool
    var trip: Trip?

    init(name: String, latitude: Double, longitude: Double, placeID: String? = nil, isActive: Bool = true) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.placeID = placeID
        self.isActive = isActive
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
