import SwiftData
import SwiftUI

struct DocumentLibraryView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \SOPDocument.updatedAt, order: .reverse) private var sops: [SOPDocument]
    @Query(sort: \ChecklistDocument.createdAt, order: .reverse) private var checklists: [ChecklistDocument]
    @Query(sort: \TrainingGuide.createdAt, order: .reverse) private var guides: [TrainingGuide]

    @State private var viewModel = DocumentLibraryViewModel()
    @State private var sharePayload: SharePayload?
    @State private var previewPayload: SharePayload?

    var body: some View {
        @Bindable var model = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Search documents", text: $model.searchText)
                        .textFieldStyle(.roundedBorder)

                    Picker("Filter", selection: $model.filter) {
                        ForEach(LibraryFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .premiumCard()

                if visibleDocumentCount == 0 {
                    EmptyStateView(
                        title: "No matching documents",
                        message: "Saved SOPs, checklists, and training guides appear here for editing, duplicating, and PDF export.",
                        systemImage: "doc.text.magnifyingglass"
                    )
                    .premiumCard()
                } else {
                    documentSections
                }
            }
            .padding(20)
        }
        .background(SOPTheme.groupedBackground)
        .navigationTitle("Saved Documents")
        .sheet(item: $sharePayload) { payload in
            ShareSheet(items: [payload.url])
        }
        .sheet(item: $previewPayload) { payload in
            PDFPreviewView(url: payload.url)
        }
    }

    @ViewBuilder
    private var documentSections: some View {
        if viewModel.includesSOPs() {
            let filtered = sops.filter { viewModel.matches(title: $0.title, category: $0.category, content: $0.content) }
            if !filtered.isEmpty {
                sectionTitle("SOPs")
                ForEach(filtered) { document in
                    NavigationLink {
                        SOPDocumentEditorView(document: document)
                    } label: {
                        DocumentCard(
                            title: document.title,
                            subtitle: "Version \(document.version) | Updated \(document.updatedAt.shortDocumentDate)",
                            category: document.category,
                            systemImage: "doc.text.fill",
                            tint: SOPTheme.accent,
                            footer: document.businessType
                        )
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Duplicate", systemImage: "doc.on.doc") { duplicate(document) }
                        Button("Share PDF", systemImage: "square.and.arrow.up") { export(document, share: true) }
                        Button("Preview PDF", systemImage: "doc.richtext") { export(document, share: false) }
                        Button("Delete", systemImage: "trash", role: .destructive) { delete(document) }
                    }
                }
            }
        }

        if viewModel.includesChecklists() {
            let filtered = checklists.filter { viewModel.matches(title: $0.title, category: $0.category, content: $0.items.joined(separator: " ")) }
            if !filtered.isEmpty {
                sectionTitle("Checklists")
                ForEach(filtered) { document in
                    NavigationLink {
                        ChecklistDocumentEditorView(document: document)
                    } label: {
                        DocumentCard(
                            title: document.title,
                            subtitle: "\(document.items.count) items | Created \(document.createdAt.shortDocumentDate)",
                            category: document.category,
                            systemImage: "checklist",
                            tint: SOPTheme.success
                        )
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Duplicate", systemImage: "doc.on.doc") { duplicate(document) }
                        Button("Share PDF", systemImage: "square.and.arrow.up") { export(document, share: true) }
                        Button("Preview PDF", systemImage: "doc.richtext") { export(document, share: false) }
                        Button("Delete", systemImage: "trash", role: .destructive) { delete(document) }
                    }
                }
            }
        }

        if viewModel.includesTraining() {
            let filtered = guides.filter { viewModel.matches(title: $0.title, category: "Training", content: $0.content) }
            if !filtered.isEmpty {
                sectionTitle("Training Guides")
                ForEach(filtered) { document in
                    NavigationLink {
                        TrainingGuideEditorView(document: document)
                    } label: {
                        DocumentCard(
                            title: document.title,
                            subtitle: "Role: \(document.role) | Created \(document.createdAt.shortDocumentDate)",
                            category: "Training",
                            systemImage: "person.text.rectangle",
                            tint: SOPTheme.purple
                        )
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Duplicate", systemImage: "doc.on.doc") { duplicate(document) }
                        Button("Share PDF", systemImage: "square.and.arrow.up") { export(document, share: true) }
                        Button("Preview PDF", systemImage: "doc.richtext") { export(document, share: false) }
                        Button("Delete", systemImage: "trash", role: .destructive) { delete(document) }
                    }
                }
            }
        }
    }

    private var visibleDocumentCount: Int {
        var count = 0
        if viewModel.includesSOPs() {
            count += sops.filter { viewModel.matches(title: $0.title, category: $0.category, content: $0.content) }.count
        }
        if viewModel.includesChecklists() {
            count += checklists.filter { viewModel.matches(title: $0.title, category: $0.category, content: $0.items.joined(separator: " ")) }.count
        }
        if viewModel.includesTraining() {
            count += guides.filter { viewModel.matches(title: $0.title, category: "Training", content: $0.content) }.count
        }
        return count
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3.bold())
            .padding(.top, 4)
    }

    private func duplicate(_ document: SOPDocument) {
        let copy = SOPDocument(
            title: "\(document.title) Copy",
            category: document.category,
            businessType: document.businessType,
            content: document.content,
            version: document.version
        )
        modelContext.insert(copy)
        try? modelContext.save()
    }

    private func duplicate(_ document: ChecklistDocument) {
        let copy = ChecklistDocument(title: "\(document.title) Copy", category: document.category, items: document.items)
        modelContext.insert(copy)
        try? modelContext.save()
    }

    private func duplicate(_ document: TrainingGuide) {
        let copy = TrainingGuide(title: "\(document.title) Copy", role: document.role, content: document.content, quizQuestions: document.quizQuestions)
        modelContext.insert(copy)
        try? modelContext.save()
    }

    private func delete(_ document: SOPDocument) {
        modelContext.delete(document)
        try? modelContext.save()
    }

    private func delete(_ document: ChecklistDocument) {
        modelContext.delete(document)
        try? modelContext.save()
    }

    private func delete(_ document: TrainingGuide) {
        modelContext.delete(document)
        try? modelContext.save()
    }

    private func export(_ document: SOPDocument, share: Bool) {
        createPDF(
            title: document.title,
            version: document.version,
            date: document.createdAt,
            content: document.content,
            checklist: [],
            safety: "Review the SOP safety notes and any local operating requirements before use.",
            share: share
        )
    }

    private func export(_ document: ChecklistDocument, share: Bool) {
        createPDF(
            title: document.title,
            version: 1,
            date: document.createdAt,
            content: "Checklist category: \(document.category)",
            checklist: document.items,
            safety: "Review all checklist items for safety and compliance relevance before use.",
            share: share
        )
    }

    private func export(_ document: TrainingGuide, share: Bool) {
        createPDF(
            title: document.title,
            version: 1,
            date: document.createdAt,
            content: document.content,
            checklist: document.quizQuestions,
            safety: "Supervisor review is required before using this as staff training material.",
            share: share
        )
    }

    private func createPDF(title: String, version: Int, date: Date, content: String, checklist: [String], safety: String, share: Bool) {
        do {
            let url = try PDFExporter.export(payload: PDFExportPayload(
                businessName: appState.businessName,
                title: title,
                version: version,
                dateCreated: date,
                content: content,
                checklist: checklist,
                safetyNotes: safety
            ))
            let payload = SharePayload(url: url)
            if share {
                sharePayload = payload
            } else {
                previewPayload = payload
            }
        } catch {
            viewModel.errorMessage = "The PDF could not be created."
        }
    }
}
