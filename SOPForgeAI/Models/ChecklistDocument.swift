import Foundation
import SwiftData

@Model
final class ChecklistDocument {
    @Attribute(.unique) var id: UUID
    var title: String
    var category: String
    var items: [String]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        category: String,
        items: [String],
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.items = items
        self.createdAt = createdAt
    }
}
