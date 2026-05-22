import SwiftData
import SwiftUI

struct ChecklistDocumentEditorView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var document: ChecklistDocument
    @State private var sharePayload: SharePayload?
    @State private var previewPayload: SharePayload?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Checklist title", text: $document.title)
                        .font(.title3.weight(.semibold))
                        .textFieldStyle(.roundedBorder)

                    TextField("Category", text: $document.category)
                        .textFieldStyle(.roundedBorder)
                }
                .premiumCard()

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Items")
                            .font(.headline)
                        Spacer()
                        Button {
                            document.items.append("")
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                        .buttonStyle(.bordered)
                    }

                    ForEach(Array(document.items.indices), id: \.self) { index in
                        ChecklistRow(
                            text: Binding(
                                get: { document.items[index] },
                                set: { document.items[index] = $0 }
                            ),
                            index: index,
                            onDelete: { document.items.remove(at: index) }
                        )
                    }
                }
                .premiumCard()

                DisclaimerView()
            }
            .padding(20)
        }
        .background(SOPTheme.groupedBackground)
        .navigationTitle("Edit Checklist")
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
                content: "Checklist category: \(document.category)",
                checklist: document.items,
                safetyNotes: "Review all checklist items for safety and compliance relevance before use."
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
