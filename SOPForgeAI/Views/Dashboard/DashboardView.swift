import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState

    @Query(sort: \SOPDocument.updatedAt, order: .reverse) private var sops: [SOPDocument]
    @Query(sort: \ChecklistDocument.createdAt, order: .reverse) private var checklists: [ChecklistDocument]
    @Query(sort: \TrainingGuide.createdAt, order: .reverse) private var guides: [TrainingGuide]

    private let columns = [GridItem(.adaptive(minimum: 155), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                summaryHeader

                UpgradeBanner {
                    // NavigationLink cannot be embedded here cleanly without changing the card layout.
                }
                .overlay {
                    NavigationLink(value: AppRoute.paywall) {
                        Color.clear
                    }
                    .buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick actions")
                        .font(.title3.bold())

                    LazyVGrid(columns: columns, spacing: 12) {
                        quickAction("Generate SOP", "Standardise any process", "doc.badge.plus", SOPTheme.accent, .sopGenerator)
                        quickAction("Create Checklist", "Open, close, inspect, maintain", "checklist", SOPTheme.success, .checklistBuilder)
                        quickAction("Voice-to-SOP", "Dictate a rough process", "waveform", SOPTheme.purple, .voiceToSOP)
                        quickAction("Training Guide", "Teach a role or task", "person.text.rectangle", .orange, .trainingGuide)
                        quickAction("Safety Procedure", "Capture risks and sign-off", "exclamationmark.shield", SOPTheme.warning, .safetyProcedure)
                        quickAction("Saved Documents", "Search, edit, export", "books.vertical", .teal, .savedDocuments)
                    }
                }

                recentSection
            }
            .padding(20)
        }
        .background(SOPTheme.groupedBackground)
        .navigationTitle("Dashboard")
    }

    private var summaryHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(appState.businessName.isEmpty ? "Operations workspace" : appState.businessName)
                        .font(.title.bold())
                    Text("\(appState.businessType) | \(appState.primaryGoal)")
                        .font(.subheadline)
                        .foregroundStyle(SOPTheme.subtleText)
                }

                Spacer()

                Image(systemName: "bolt.horizontal.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(SOPTheme.accent)
            }

            HStack(spacing: 10) {
                metric("\(sops.count)", "SOPs")
                metric("\(checklists.count)", "Checklists")
                metric("\(guides.count)", "Guides")
            }
        }
        .premiumCard()
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent documents")
                    .font(.title3.bold())
                Spacer()
                NavigationLink("View all", value: AppRoute.savedDocuments)
                    .font(.subheadline.weight(.semibold))
            }

            if recentDocuments.isEmpty {
                EmptyStateView(
                    title: "No documents yet",
                    message: "Generate your first SOP, checklist, or training guide to start building the library.",
                    systemImage: "tray"
                )
                .premiumCard()
            } else {
                ForEach(recentDocuments) { item in
                    DocumentCard(
                        title: item.title,
                        subtitle: item.subtitle,
                        category: item.category,
                        systemImage: item.icon,
                        tint: item.tint,
                        footer: item.date.shortDocumentDate
                    )
                }
            }
        }
    }

    private var recentDocuments: [DashboardDocument] {
        let sopItems = sops.map {
            DashboardDocument(title: $0.title, subtitle: "Version \($0.version) | \($0.businessType)", category: $0.category, icon: "doc.text.fill", tint: SOPTheme.accent, date: $0.updatedAt)
        }
        let checklistItems = checklists.map {
            DashboardDocument(title: $0.title, subtitle: "\($0.items.count) checklist items", category: $0.category, icon: "checklist", tint: SOPTheme.success, date: $0.createdAt)
        }
        let guideItems = guides.map {
            DashboardDocument(title: $0.title, subtitle: "Role: \($0.role)", category: "Training", icon: "person.text.rectangle", tint: SOPTheme.purple, date: $0.createdAt)
        }
        return (sopItems + checklistItems + guideItems)
            .sorted { $0.date > $1.date }
            .prefix(3)
            .map { $0 }
    }

    private func metric(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(SOPTheme.subtleText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func quickAction(_ title: String, _ subtitle: String, _ icon: String, _ tint: Color, _ route: AppRoute) -> some View {
        NavigationLink(value: route) {
            TemplateCard(title: title, subtitle: subtitle, systemImage: icon, tint: tint)
        }
        .buttonStyle(.plain)
    }
}

private struct DashboardDocument: Identifiable {
    let id = UUID()
    var title: String
    var subtitle: String
    var category: String
    var icon: String
    var tint: Color
    var date: Date
}
