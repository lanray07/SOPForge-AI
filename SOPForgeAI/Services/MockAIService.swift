import Foundation

struct MockAIService: AIService {
    func generateSOP(_ request: SOPGenerationRequest) async throws -> AIGeneratedDocument {
        guard !request.taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AIServiceError.missingInput("a task or process name")
        }

        await simulateLatency()
        let title = "\(request.taskName) SOP"
        let checklist = [
            "Confirm the assigned role understands the task.",
            "Verify tools and materials are ready before work starts.",
            "Follow every procedure step in sequence.",
            "Check quality standards before handoff.",
            "Record supervisor sign-off when complete."
        ]

        return AIGeneratedDocument(
            title: title,
            content: sopContent(for: request),
            checklist: checklist,
            summary: "A practical SOP for \(request.businessType.lowercased()) teams covering preparation, execution, quality control, and sign-off."
        )
    }

    func generateChecklist(_ request: ChecklistGenerationRequest) async throws -> AIGeneratedDocument {
        guard !request.taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AIServiceError.missingInput("the checklist focus")
        }

        await simulateLatency()
        let items = [
            "Review the shift/task objective.",
            "Confirm required tools, equipment, and materials are available.",
            "Check the workspace for safety risks.",
            "Complete the task-specific preparation steps.",
            "Document issues, exceptions, or incomplete work.",
            "Confirm quality standards before closing the checklist.",
            "Escalate blockers to the supervisor."
        ]

        return AIGeneratedDocument(
            title: "\(request.taskName) \(request.checklistType)",
            content: """
            Checklist type: \(request.checklistType)
            Business type: \(request.businessType)
            Tone: \(request.tone)

            Use this checklist at the start or end of the workflow. Add site-specific requirements before publishing it to staff.
            """,
            checklist: items,
            summary: "A \(request.checklistType.lowercased()) for \(request.taskName.lowercased())."
        )
    }

    func generateTrainingGuide(_ request: TrainingGuideRequest) async throws -> AIGeneratedDocument {
        guard !request.role.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AIServiceError.missingInput("a staff role")
        }

        await simulateLatency()
        let quiz = [
            "What should you check before starting this process?",
            "Which safety note is most important for this role?",
            "What does good quality look like before supervisor review?",
            "When should you escalate an issue?"
        ]

        return AIGeneratedDocument(
            title: "\(request.role) Training Guide: \(request.taskName)",
            content: trainingContent(for: request),
            checklist: quiz,
            summary: "A beginner-friendly training plan with role-specific instructions, practice steps, and supervisor review notes."
        )
    }

    func improveDocument(title: String, content: String, instruction: String) async throws -> AIGeneratedDocument {
        await simulateLatency()
        return AIGeneratedDocument(
            title: "\(title) - Improved",
            content: """
            Improved version

            \(content)

            Revision note:
            \(instruction)

            Review note:
            Confirm the final version with a supervisor or qualified professional before publishing.
            """,
            checklist: [
                "Read the improved version end to end.",
                "Confirm the instructions match real operations.",
                "Check safety and compliance notes with the right person.",
                "Publish as a new version after approval."
            ],
            summary: "The document was rewritten for clarity, consistency, and operational review."
        )
    }

    func convertVoiceNotesToSOP(_ request: VoiceToSOPRequest) async throws -> AIGeneratedDocument {
        guard !request.voiceNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AIServiceError.missingInput("voice notes or typed process notes")
        }

        await simulateLatency()
        let sopRequest = SOPGenerationRequest(
            businessType: request.businessType,
            taskName: "Voice Captured Process",
            teamRole: "Assigned staff member",
            tools: "As described in the notes",
            safetyNotes: "Review the captured notes for hazards before publishing.",
            qualityStandards: "Supervisor confirms the process is complete and consistent.",
            tone: request.tone,
            notes: request.voiceNotes
        )
        return try await generateSOP(sopRequest)
    }

    private func simulateLatency() async {
        try? await Task.sleep(nanoseconds: 550_000_000)
    }

    private func sopContent(for request: SOPGenerationRequest) -> String {
        """
        Purpose
        Provide a clear, repeatable process for \(request.taskName) so team members can complete the work consistently with less repeated explanation.

        Scope
        Applies to \(request.businessType) team members working in the role of \(request.teamRole.isEmpty ? "assigned operator" : request.teamRole).

        Required Tools
        \(request.tools.isEmpty ? "List required tools, equipment, materials, apps, or forms before publishing." : request.tools)

        Step-by-Step Procedure
        1. Confirm the job, site, client, or internal request details.
        2. Prepare the work area and check that tools or equipment are safe to use.
        3. Follow the standard process notes below:
        \(request.notes.isEmpty ? "   - Add local process notes before publishing." : request.notes.split(separator: "\n").map { "   - \($0)" }.joined(separator: "\n"))
        4. Complete the work in the agreed sequence and avoid skipping quality checks.
        5. Record any exceptions, delays, damaged equipment, or client-specific requirements.
        6. Notify the supervisor when the process is complete.

        Safety Notes
        \(request.safetyNotes.isEmpty ? "Review the task for site-specific risks. Add PPE, equipment, chemical, ladder, driving, or manual-handling requirements where relevant." : request.safetyNotes)

        Quality Checklist
        \(request.qualityStandards.isEmpty ? "Work should be complete, clean, documented, and ready for supervisor or client review." : request.qualityStandards)

        Common Mistakes
        - Starting before tools, materials, or instructions are confirmed.
        - Rushing the final quality check.
        - Failing to report hazards, delays, or exceptions.
        - Leaving unclear notes for the next team member.

        Supervisor Sign-Off
        Supervisor name: ______________________
        Signature: ____________________________
        Date: ________________________________
        """
    }

    private func trainingContent(for request: TrainingGuideRequest) -> String {
        """
        Beginner-Friendly Overview
        This guide trains a \(request.role) to complete \(request.taskName) in a consistent, professional way.

        Role-Specific Instructions
        - Understand the expected outcome before starting.
        - Ask a supervisor to confirm anything unclear.
        - Follow the steps exactly until signed off to work independently.

        Step-by-Step Training Plan
        1. Watch a supervisor demonstrate the process.
        2. Review the SOP and checklist for the task.
        3. Practice the task with supervision.
        4. Complete the task independently while being observed.
        5. Review mistakes, questions, and quality expectations.
        6. Receive supervisor sign-off before unsupervised work.

        Process Notes
        \(request.notes.isEmpty ? "Add business-specific training examples before publishing." : request.notes)

        Supervisor Review Notes
        Confirm the trainee understands safety requirements, quality standards, escalation steps, and documentation expectations.
        """
    }
}
