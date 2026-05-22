import Foundation
import SwiftData

@Model
final class TrainingGuide {
    @Attribute(.unique) var id: UUID
    var title: String
    var role: String
    var content: String
    var quizQuestions: [String]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        role: String,
        content: String,
        quizQuestions: [String],
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.role = role
        self.content = content
        self.quizQuestions = quizQuestions
        self.createdAt = createdAt
    }
}
