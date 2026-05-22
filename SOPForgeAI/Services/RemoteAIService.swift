import Foundation

struct RemoteAIService: AIService {
    var endpoint: URL? = AppConfiguration.backendEndpoint
    var apiKey: String?

    func generateSOP(_ request: SOPGenerationRequest) async throws -> AIGeneratedDocument {
        let notes = """
        Team role: \(request.teamRole)
        Tools/equipment: \(request.tools)
        Safety notes: \(request.safetyNotes)
        Quality standards: \(request.qualityStandards)
        Notes: \(request.notes)
        """
        let response = try await perform(module: "sop", businessType: request.businessType, taskName: request.taskName, notes: notes, tone: request.tone)
        return response.generatedDocument
    }

    func generateChecklist(_ request: ChecklistGenerationRequest) async throws -> AIGeneratedDocument {
        let response = try await perform(module: "checklist", businessType: request.businessType, taskName: request.taskName, notes: "\(request.checklistType)\n\(request.notes)", tone: request.tone)
        return response.generatedDocument
    }

    func generateTrainingGuide(_ request: TrainingGuideRequest) async throws -> AIGeneratedDocument {
        let notes = "Role: \(request.role)\n\(request.notes)"
        let response = try await perform(module: "training_guide", businessType: request.businessType, taskName: request.taskName, notes: notes, tone: request.tone)
        return response.generatedDocument
    }

    func improveDocument(title: String, content: String, instruction: String) async throws -> AIGeneratedDocument {
        let response = try await perform(module: "improve_document", businessType: "", taskName: title, notes: "\(instruction)\n\n\(content)", tone: DocumentTone.professional.rawValue)
        return response.generatedDocument
    }

    func convertVoiceNotesToSOP(_ request: VoiceToSOPRequest) async throws -> AIGeneratedDocument {
        let response = try await perform(module: "voice_to_sop", businessType: request.businessType, taskName: "Voice-to-SOP", notes: request.voiceNotes, tone: request.tone)
        return response.generatedDocument
    }

    private func perform(module: String, businessType: String, taskName: String, notes: String, tone: String) async throws -> BackendAIResponse {
        guard let endpoint else { throw AIServiceError.invalidEndpoint }

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let apiKey, !apiKey.isEmpty {
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        let payload = BackendAIRequest(
            module: module,
            businessType: businessType,
            taskName: taskName,
            notes: "\(AppConfiguration.internalAIPrompt)\n\nUser notes:\n\(notes)",
            tone: tone
        )
        urlRequest.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw AIServiceError.remoteFailure("The AI backend returned an unexpected response.")
        }

        return try JSONDecoder().decode(BackendAIResponse.self, from: data)
    }
}

struct BackendAIRequest: Codable {
    var module: String
    var businessType: String
    var taskName: String
    var notes: String
    var tone: String
}

struct BackendAIResponse: Codable {
    var title: String
    var content: String
    var checklist: [String]
    var summary: String

    var generatedDocument: AIGeneratedDocument {
        AIGeneratedDocument(title: title, content: content, checklist: checklist, summary: summary)
    }
}
