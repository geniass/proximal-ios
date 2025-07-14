import Foundation
import SwiftData

@Model
final class Trip {
    var name: String
    var startDate: Date
    var endDate: Date
    @Relationship(deleteRule: .cascade) var places: [Place]?

    init(name: String, startDate: Date, endDate: Date) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
    }
}
