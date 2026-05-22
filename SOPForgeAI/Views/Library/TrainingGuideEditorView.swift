import SwiftData
import SwiftUI

struct TrainingGuideEditorView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var document: TrainingGuide
    @State private var sharePayload: SharePayload?
    @State private var previewPayload: SharePayload?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Guide title", text: $document.title)
                        .font(.title3.weight(.semibold))
                        .textFieldStyle(.roundedBorder)

                    TextField("Role", text: $document.role)
                        .textFieldStyle(.roundedBorder)
                }
                .premiumCard()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Content")
                        .font(.headline)
                    TextEditor(text: $document.content)
                        .frame(minHeight: 360)
                        .padding(8)
                        .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .premiumCard()

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Quiz questions")
                            .font(.headline)
                        Spacer()
                        Button {
                            document.quizQuestions.append("")
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                        .buttonStyle(.bordered)
                    }

                    ForEach(Array(document.quizQuestions.indices), id: \.self) { index in
                        ChecklistRow(
                            text: Binding(
                                get: { document.quizQuestions[index] },
                                set: { document.quizQuestions[index] = $0 }
                            ),
                            index: index,
                            onDelete: { document.quizQuestions.remove(at: index) }
                        )
                    }
                }
                .premiumCard()

                DisclaimerView()
            }
            .padding(20)
        }
        .background(SOPTheme.groupedBackground)
        .navigationTitle("Edit Training")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Button("Share PDF", systemImage: "square.and.arrow.up") { exportPDF(share: true) }
                    Button("Preview PDF", systemImage: "doc.richtext") { exportPDF(share: false) }
                } label: {
                    Image(systemName: "doc.text")
                }

                Button("Done") {
                    save()
                    dismiss()
                }
            }
        }
        .onDisappear(perform: save)
        .sheet(item: $sharePayload) { payload in
            ShareSheet(items: [payload.url])
        }
        .sheet(item: $previewPayload) { payload in
            PDFPreviewView(url: payload.url)
        }
    }

    private func save() {
        try? modelContext.save()
    }

    private func exportPDF(share: Bool) {
        save()
        do {
            let url = try PDFExporter.export(payload: PDFExportPayload(
                businessName: appState.businessName,
                title: document.title,
                version: 1,
                dateCreated: document.createdAt,
                content: document.content,
                checklist: document.quizQuestions,
                safetyNotes: "Supervisor review is required before using this as staff training material."
            ))
            let payload = SharePayload(url: url)
            if share {
                sharePayload = payload
            } else {
                previewPayload = payload
            }
        } catch {
            // Keep editing uninterrupted if export fails.
        }
    }
}
