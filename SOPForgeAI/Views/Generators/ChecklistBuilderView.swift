import SwiftData
import SwiftUI

struct ChecklistBuilderView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = ChecklistBuilderViewModel()
    @State private var sharePayload: SharePayload?
    @State private var previewPayload: SharePayload?

    var body: some View {
        @Bindable var model = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Checklist details")
                        .font(.headline)

                    TextField("Business type", text: $model.businessType)
                        .textFieldStyle(.roundedBorder)

                    Picker("Checklist type", selection: $model.checklistType) {
                        ForEach(ChecklistTemplate.allCases) { template in
                            Text(template.rawValue).tag(template)
                        }
                    }
                    .pickerStyle(.menu)

                    TextField("Checklist focus", text: $model.taskName)
                        .textFieldStyle(.roundedBorder)

                    TextField("Notes", text: $model.notes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)

                    Picker("Tone", selection: $model.tone) {
                        ForEach(DocumentTone.allCases) { tone in
                            Text(tone.rawValue).tag(tone)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .premiumCard()

                Button {
                    Task { await model.generate(using: aiService) }
                } label: {
                    if model.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Label("Generate Checklist", systemImage: "sparkles")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(model.isLoading)

                statusMessages

                if model.hasOutput {
                    outputSection(viewModel: model)
                    DisclaimerView()
                }
            }
            .padding(20)
        }
        .background(SOPTheme.groupedBackground)
        .navigationTitle("Checklist Builder")
        .task {
            if model.businessType.isEmpty {
                model.businessType = appState.businessType
            }
        }
        .sheet(item: $sharePayload) { payload in
            ShareSheet(items: [payload.url])
        }
        .sheet(item: $previewPayload) { payload in
            PDFPreviewView(url: payload.url)
        }
    }

    private func outputSection(viewModel model: ChecklistBuilderViewModel) -> some View {
        @Bindable var viewModel = model

        return VStack(alignment: .leading, spacing: 14) {
            Text("Generated checklist")
                .font(.headline)

            TextField("Checklist title", text: $viewModel.generatedTitle)
                .font(.title3.weight(.semibold))
                .textFieldStyle(.roundedBorder)

            ForEach(Array(viewModel.items.indices), id: \.self) { index in
                ChecklistRow(
                    text: Binding(
                        get: { viewModel.items[index] },
                        set: { viewModel.items[index] = $0 }
                    ),
                    index: index,
                    onDelete: { viewModel.items.remove(at: index) }
                )
            }

            Button {
                viewModel.items.append("")
            } label: {
                Label("Add item", systemImage: "plus")
            }
            .buttonStyle(.bordered)

            HStack(spacing: 10) {
                Button {
                    viewModel.save(in: modelContext)
                } label: {
                    Label("Save", systemImage: "tray.and.arrow.down")
                }
                .buttonStyle(SecondaryButtonStyle())

                Menu {
                    Button {
                        exportPDF(share: true)
                    } label: {
                        Label("Share PDF", systemImage: "square.and.arrow.up")
                    }
                    Button {
                        exportPDF(share: false)
                    } label: {
                        Label("Preview PDF", systemImage: "doc.richtext")
                    }
                } label: {
                    Label("PDF", systemImage: "doc.text")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .premiumCard()
    }

    @ViewBuilder
    private var statusMessages: some View {
        if let error = viewModel.errorMessage {
            Label(error, systemImage: "exclamationmark.triangle")
                .font(.subheadline)
                .foregroundStyle(.red)
                .premiumCard()
        }

        if let success = viewModel.successMessage {
            Label(success, systemImage: "checkmark.circle")
                .font(.subheadline)
                .foregroundStyle(SOPTheme.success)
                .premiumCard()
        }
    }

    private func exportPDF(share: Bool) {
        do {
            let url = try PDFExporter.export(payload: PDFExportPayload(
                businessName: appState.businessName,
                title: viewModel.generatedTitle,
                version: 1,
                dateCreated: .now,
                content: viewModel.generatedContent,
                checklist: viewModel.items,
                safetyNotes: "Review all checklist items for task-specific safety requirements."
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
