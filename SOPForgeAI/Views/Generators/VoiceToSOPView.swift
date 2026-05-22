import SwiftData
import SwiftUI

struct VoiceToSOPView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext

    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var viewModel = VoiceToSOPViewModel()
    @State private var sharePayload: SharePayload?
    @State private var previewPayload: SharePayload?

    var body: some View {
        @Bindable var model = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                UpgradeBanner(title: "Voice-to-SOP is a Pro workflow", message: "Record a rough explanation, clean it into an SOP, then export a professional PDF.") {}

                VStack(alignment: .leading, spacing: 14) {
                    Text("Capture process notes")
                        .font(.headline)

                    TextField("Business type", text: $model.businessType)
                        .textFieldStyle(.roundedBorder)

                    HStack(spacing: 12) {
                        Button {
                            Task { await toggleRecording() }
                        } label: {
                            Label(speechRecognizer.isRecording ? "Stop recording" : "Record", systemImage: speechRecognizer.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button {
                            model.voiceNotes = ""
                            speechRecognizer.transcript = ""
                        } label: {
                            Image(systemName: "xmark.circle")
                                .frame(width: 48, height: 48)
                        }
                        .buttonStyle(.bordered)
                        .accessibilityLabel("Clear voice notes")
                    }

                    TextEditor(text: $model.voiceNotes)
                        .frame(minHeight: 190)
                        .padding(8)
                        .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                    Picker("Tone", selection: $model.tone) {
                        ForEach(DocumentTone.allCases) { tone in
                            Text(tone.rawValue).tag(tone)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .premiumCard()

                Button {
                    Task { await model.convert(using: aiService) }
                } label: {
                    if model.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Label("Convert to SOP", systemImage: "sparkles")
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
        .navigationTitle("Voice-to-SOP")
        .task {
            if model.businessType.isEmpty {
                model.businessType = appState.businessType
            }
        }
        .onChange(of: speechRecognizer.transcript) { _, newValue in
            model.voiceNotes = newValue
        }
        .sheet(item: $sharePayload) { payload in
            ShareSheet(items: [payload.url])
        }
        .sheet(item: $previewPayload) { payload in
            PDFPreviewView(url: payload.url)
        }
    }

    private func outputSection(viewModel model: VoiceToSOPViewModel) -> some View {
        @Bindable var viewModel = model

        return VStack(alignment: .leading, spacing: 14) {
            Text("Clean SOP")
                .font(.headline)

            TextField("SOP title", text: $viewModel.generatedTitle)
                .font(.title3.weight(.semibold))
                .textFieldStyle(.roundedBorder)

            TextEditor(text: $viewModel.generatedContent)
                .frame(minHeight: 340)
                .padding(8)
                .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

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
        if let error = speechRecognizer.errorMessage ?? viewModel.errorMessage {
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

    private func toggleRecording() async {
        if speechRecognizer.isRecording {
            speechRecognizer.stopTranscribing()
        } else {
            do {
                try await speechRecognizer.startTranscribing()
            } catch {
                speechRecognizer.errorMessage = error.localizedDescription
            }
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
                safetyNotes: "Review dictated instructions for task-specific safety requirements before use."
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
