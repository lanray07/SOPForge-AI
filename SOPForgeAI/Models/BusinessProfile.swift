import Foundation
import SwiftData

@Model
final class BusinessProfile {
    @Attribute(.unique) var id: UUID
    var businessName: String
    var industry: String
    var teamSize: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        businessName: String,
        industry: String,
        teamSize: Int,
        createdAt: Date = .now
    ) {
        self.id = id
        self.businessName = businessName
        self.industry = industry
        self.teamSize = teamSize
        self.createdAt = createdAt
    }
}
