import Foundation
import SwiftData

@Model
final class SOPDocument {
    @Attribute(.unique) var id: UUID
    var title: String
    var category: String
    var businessType: String
    var content: String
    var version: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        category: String,
        businessType: String,
        content: String,
        version: Int = 1,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.businessType = businessType
        self.content = content
        self.version = version
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
