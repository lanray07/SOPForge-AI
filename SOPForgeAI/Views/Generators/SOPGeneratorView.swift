import SwiftData
import SwiftUI

struct SOPGeneratorView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel: SOPGeneratorViewModel
    @State private var sharePayload: SharePayload?
    @State private var previewPayload: SharePayload?

    private let mode: SOPGeneratorMode

    init(mode: SOPGeneratorMode = .standard) {
        self.mode = mode
        _viewModel = State(initialValue: SOPGeneratorViewModel(category: mode.category))
    }

    var body: some View {
        @Bindable var model = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                inputSection(viewModel: model)

                Button {
                    Task { await model.generate(using: aiService) }
                } label: {
                    if model.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Label("Generate \(mode.category)", systemImage: "sparkles")
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
        .navigationTitle(mode.navigationTitle)
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

    private func inputSection(viewModel model: SOPGeneratorViewModel) -> some View {
        @Bindable var viewModel = model

        return VStack(alignment: .leading, spacing: 14) {
            Text("Process details")
                .font(.headline)

            TextField("Business type", text: $viewModel.businessType)
                .textFieldStyle(.roundedBorder)

            TextField("Task/process name", text: $viewModel.taskName)
                .textFieldStyle(.roundedBorder)

            TextField("Team role", text: $viewModel.teamRole)
                .textFieldStyle(.roundedBorder)

            TextField("Tools/equipment used", text: $viewModel.tools, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)

            TextField("Safety notes", text: $viewModel.safetyNotes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...5)

            TextField("Quality standards", text: $viewModel.qualityStandards, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...5)

            VStack(alignment: .leading, spacing: 8) {
                Text("Process notes")
                    .font(.subheadline.weight(.semibold))
                TextEditor(text: $viewModel.processNotes)
                    .frame(minHeight: 130)
                    .padding(8)
                    .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }

            Picker("Tone", selection: $viewModel.tone) {
                ForEach(DocumentTone.allCases) { tone in
                    Text(tone.rawValue).tag(tone)
                }
            }
            .pickerStyle(.menu)
        }
        .premiumCard()
    }

    private func outputSection(viewModel model: SOPGeneratorViewModel) -> some View {
        @Bindable var viewModel = model

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("AI output")
                    .font(.headline)
                Spacer()
                Text(viewModel.category)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SOPTheme.accent)
            }

            TextField("SOP title", text: $viewModel.generatedTitle)
                .font(.title3.weight(.semibold))
                .textFieldStyle(.roundedBorder)

            TextEditor(text: $viewModel.generatedContent)
                .frame(minHeight: 360)
                .padding(8)
                .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            if !viewModel.generatedChecklist.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quality checklist")
                        .font(.subheadline.weight(.semibold))
                    ForEach(viewModel.generatedChecklist.indices, id: \.self) { index in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(SOPTheme.success)
                            Text(viewModel.generatedChecklist[index])
                                .font(.subheadline)
                        }
                    }
                }
            }

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
                checklist: viewModel.generatedChecklist,
                safetyNotes: viewModel.safetyNotes
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
