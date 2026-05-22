import SwiftData
import SwiftUI

struct TrainingGuideGeneratorView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = TrainingGuideViewModel()
    @State private var sharePayload: SharePayload?
    @State private var previewPayload: SharePayload?

    var body: some View {
        @Bindable var model = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Training details")
                        .font(.headline)

                    TextField("Business type", text: $model.businessType)
                        .textFieldStyle(.roundedBorder)

                    TextField("Role", text: $model.role)
                        .textFieldStyle(.roundedBorder)

                    TextField("Task/process", text: $model.taskName)
                        .textFieldStyle(.roundedBorder)

                    TextField("Training notes", text: $model.notes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...7)

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
                        Label("Generate Training Guide", systemImage: "sparkles")
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
        .navigationTitle("Training Guide")
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

    private func outputSection(viewModel model: TrainingGuideViewModel) -> some View {
        @Bindable var viewModel = model

        return VStack(alignment: .leading, spacing: 14) {
            Text("Generated guide")
                .font(.headline)

            TextField("Guide title", text: $viewModel.generatedTitle)
                .font(.title3.weight(.semibold))
                .textFieldStyle(.roundedBorder)

            TextEditor(text: $viewModel.generatedContent)
                .frame(minHeight: 320)
                .padding(8)
                .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text("Quiz questions")
                    .font(.subheadline.weight(.semibold))

                ForEach(Array(viewModel.quizQuestions.indices), id: \.self) { index in
                    ChecklistRow(
                        text: Binding(
                            get: { viewModel.quizQuestions[index] },
                            set: { viewModel.quizQuestions[index] = $0 }
                        ),
                        index: index,
                        onDelete: { viewModel.quizQuestions.remove(at: index) }
                    )
                }

                Button {
                    viewModel.quizQuestions.append("")
                } label: {
                    Label("Add question", systemImage: "plus")
                }
                .buttonStyle(.bordered)
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
                checklist: viewModel.quizQuestions,
                safetyNotes: "Training materials must be reviewed by supervisors and qualified professionals where required."
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
