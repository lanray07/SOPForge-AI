import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class VoiceToSOPViewModel {
    var businessType = ""
    var voiceNotes = ""
    var tone = DocumentTone.professional

    var generatedTitle = ""
    var generatedContent = ""
    var generatedChecklist: [String] = []
    var generatedSummary = ""

    var isLoading = false
    var errorMessage: String?
    var successMessage: String?

    var hasOutput: Bool {
        !generatedTitle.isEmpty && !generatedContent.isEmpty
    }

    func convert(using aiService: any AIService) async {
        errorMessage = nil
        successMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await aiService.convertVoiceNotesToSOP(VoiceToSOPRequest(
                businessType: businessType,
                voiceNotes: voiceNotes,
                tone: tone.rawValue
            ))
            generatedTitle = result.title
            generatedContent = result.content
            generatedChecklist = result.checklist
            generatedSummary = result.summary
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save(in context: ModelContext) {
        guard hasOutput else { return }
        let document = SOPDocument(
            title: generatedTitle,
            category: "Voice-to-SOP",
            businessType: businessType,
            content: generatedContent
        )
        context.insert(document)
        do {
            try context.save()
            successMessage = "Saved to Document Library."
        } catch {
            errorMessage = "The SOP could not be saved."
        }
    }
}
