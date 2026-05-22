import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class TrainingGuideViewModel {
    var businessType = ""
    var role = ""
    var taskName = ""
    var notes = ""
    var tone = DocumentTone.professional

    var generatedTitle = ""
    var generatedContent = ""
    var quizQuestions: [String] = []
    var generatedSummary = ""

    var isLoading = false
    var errorMessage: String?
    var successMessage: String?

    var hasOutput: Bool { !generatedTitle.isEmpty && !generatedContent.isEmpty }

    func generate(using aiService: any AIService) async {
        errorMessage = nil
        successMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await aiService.generateTrainingGuide(TrainingGuideRequest(
                businessType: businessType,
                role: role,
                taskName: taskName,
                notes: notes,
                tone: tone.rawValue
            ))
            generatedTitle = result.title
            generatedContent = result.content
            quizQuestions = result.checklist
            generatedSummary = result.summary
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save(in context: ModelContext) {
        guard hasOutput else { return }
        let document = TrainingGuide(
            title: generatedTitle,
            role: role,
            content: generatedContent,
            quizQuestions: quizQuestions
        )
        context.insert(document)
        do {
            try context.save()
            successMessage = "Saved to Document Library."
        } catch {
            errorMessage = "The training guide could not be saved."
        }
    }
}
