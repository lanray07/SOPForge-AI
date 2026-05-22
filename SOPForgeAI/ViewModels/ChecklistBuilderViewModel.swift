import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class ChecklistBuilderViewModel {
    var businessType = ""
    var checklistType = ChecklistTemplate.opening
    var taskName = ""
    var notes = ""
    var tone = DocumentTone.professional

    var generatedTitle = ""
    var generatedContent = ""
    var items: [String] = []
    var generatedSummary = ""

    var isLoading = false
    var errorMessage: String?
    var successMessage: String?

    var hasOutput: Bool { !generatedTitle.isEmpty && !items.isEmpty }

    func generate(using aiService: any AIService) async {
        errorMessage = nil
        successMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await aiService.generateChecklist(ChecklistGenerationRequest(
                businessType: businessType,
                checklistType: checklistType.rawValue,
                taskName: taskName,
                notes: notes,
                tone: tone.rawValue
            ))
            generatedTitle = result.title
            generatedContent = result.content
            items = result.checklist
            generatedSummary = result.summary
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save(in context: ModelContext) {
        guard hasOutput else { return }
        let document = ChecklistDocument(
            title: generatedTitle,
            category: checklistType.rawValue,
            items: items
        )
        context.insert(document)
        do {
            try context.save()
            successMessage = "Saved to Document Library."
        } catch {
            errorMessage = "The checklist could not be saved."
        }
    }
}
