import SwiftUI

struct CreateHubView: View {
    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose a document workflow")
                        .font(.title.bold())
                    Text("Start from a focused generator, edit the output, then save it to the offline library.")
                        .font(.subheadline)
                        .foregroundStyle(SOPTheme.subtleText)
                }

                LazyVGrid(columns: columns, spacing: 12) {
                    card("SOP Generator", "Purpose, scope, steps, safety, quality", "doc.badge.plus", SOPTheme.accent, .sopGenerator)
                    card("Checklist Builder", "Opening, closing, inspection, safety", "checklist", SOPTheme.success, .checklistBuilder)
                    card("Voice-to-SOP", "Record or dictate rough process notes", "waveform", SOPTheme.purple, .voiceToSOP)
                    card("Training Guide", "Training plan, quiz, supervisor review", "person.text.rectangle", .orange, .trainingGuide)
                    card("Safety Procedure", "Hazards, controls, sign-off", "exclamationmark.shield", SOPTheme.warning, .safetyProcedure)
                }

                DisclaimerView()
            }
            .padding(20)
        }
        .background(SOPTheme.groupedBackground)
        .navigationTitle("Create")
    }

    private func card(_ title: String, _ subtitle: String, _ icon: String, _ tint: Color, _ route: AppRoute) -> some View {
        NavigationLink(value: route) {
            TemplateCard(title: title, subtitle: subtitle, systemImage: icon, tint: tint)
        }
        .buttonStyle(.plain)
    }
}
