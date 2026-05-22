import SwiftData
import SwiftUI

struct SOPDocumentEditorView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var document: SOPDocument
    @State private var sharePayload: SharePayload?
    @State private var previewPayload: SharePayload?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Document title", text: $document.title)
                        .font(.title3.weight(.semibold))
                        .textFieldStyle(.roundedBorder)

                    TextField("Category", text: $document.category)
                        .textFieldStyle(.roundedBorder)

                    TextField("Business type", text: $document.businessType)
                        .textFieldStyle(.roundedBorder)

                    Stepper("Version \(document.version)", value: $document.version, in: 1...999)
                }
                .premiumCard()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Content")
                        .font(.headline)
                    TextEditor(text: $document.content)
                        .frame(minHeight: 460)
                        .padding(8)
                        .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .premiumCard()

                DisclaimerView()
            }
            .padding(20)
        }
        .background(SOPTheme.groupedBackground)
        .navigationTitle("Edit SOP")
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
        document.updatedAt = .now
        try? modelContext.save()
    }

    private func exportPDF(share: Bool) {
        save()
        do {
            let url = try PDFExporter.export(payload: PDFExportPayload(
                businessName: appState.businessName,
                title: document.title,
                version: document.version,
                dateCreated: document.createdAt,
                content: document.content,
                checklist: [],
                safetyNotes: "Review the SOP safety notes and any local operating requirements before use."
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
