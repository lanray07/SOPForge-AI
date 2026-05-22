import Foundation

protocol AIService: Sendable {
    func generateSOP(_ request: SOPGenerationRequest) async throws -> AIGeneratedDocument
    func generateChecklist(_ request: ChecklistGenerationRequest) async throws -> AIGeneratedDocument
    func generateTrainingGuide(_ request: TrainingGuideRequest) async throws -> AIGeneratedDocument
    func improveDocument(title: String, content: String, instruction: String) async throws -> AIGeneratedDocument
    func convertVoiceNotesToSOP(_ request: VoiceToSOPRequest) async throws -> AIGeneratedDocument
}

struct SOPGenerationRequest: Codable, Sendable {
    var businessType: String
    var taskName: String
    var teamRole: String
    var tools: String
    var safetyNotes: String
    var qualityStandards: String
    var tone: String
    var notes: String
}

struct ChecklistGenerationRequest: Codable, Sendable {
    var businessType: String
    var checklistType: String
    var taskName: String
    var notes: String
    var tone: String
}

struct TrainingGuideRequest: Codable, Sendable {
    var businessType: String
    var role: String
    var taskName: String
    var notes: String
    var tone: String
}

struct VoiceToSOPRequest: Codable, Sendable {
    var businessType: String
    var voiceNotes: String
    var tone: String
}

struct AIGeneratedDocument: Codable, Identifiable, Sendable {
    var id = UUID()
    var title: String
    var content: String
    var checklist: [String]
    var summary: String
}

enum AIServiceError: LocalizedError {
    case missingInput(String)
    case invalidEndpoint
    case remoteFailure(String)

    var errorDescription: String? {
        switch self {
        case .missingInput(let field):
            "Please add \(field) before generating."
        case .invalidEndpoint:
            "The backend endpoint placeholder has not been configured."
        case .remoteFailure(let message):
            message
        }
    }
}
