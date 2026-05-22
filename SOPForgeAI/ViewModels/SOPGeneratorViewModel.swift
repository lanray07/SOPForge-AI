import Foundation
import Observation
import SwiftData

enum SOPGeneratorMode: String {
    case standard
    case safety

    var category: String {
        switch self {
        case .standard: "SOP"
        case .safety: "Safety Procedure"
        }
    }

    var navigationTitle: String {
        switch self {
        case .standard: "Generate SOP"
        case .safety: "Safety Procedure"
        }
    }
}

@MainActor
@Observable
final class SOPGeneratorViewModel {
    var businessType = ""
    var taskName = ""
    var teamRole = ""
    var tools = ""
    var safetyNotes = ""
    var qualityStandards = ""
    var processNotes = ""
    var tone = DocumentTone.professional
    var category: String

    var generatedTitle = ""
    var generatedContent = ""
    var generatedChecklist: [String] = []
    var generatedSummary = ""

    var isLoading = false
    var errorMessage: String?
    var successMessage: String?

    init(category: String = "SOP") {
        self.category = category
        if category == "Safety Procedure" {
            safetyNotes = "List hazards, PPE, equipment checks, escalation steps, and supervisor review requirements."
        }
    }

    var hasOutput: Bool {
        !generatedTitle.isEmpty && !generatedContent.isEmpty
    }

    func generate(using aiService: any AIService) async {
        errorMessage = nil
        successMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let request = SOPGenerationRequest(
                businessType: businessType,
                taskName: taskName,
                teamRole: teamRole,
                tools: tools,
                safetyNotes: safetyNotes,
                qualityStandards: qualityStandards,
                tone: tone.rawValue,
                notes: processNotes
            )
            let result = try await aiService.generateSOP(request)
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
            category: category,
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
