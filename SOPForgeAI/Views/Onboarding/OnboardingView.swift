import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var businessName = ""
    @State private var selectedIndustry = BusinessIndustry.smallBusiness
    @State private var selectedGoal = OnboardingGoal.createSOPs
    @State private var teamSize = 5

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 10)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Business profile")
                            .font(.headline)

                        TextField("Business name", text: $businessName)
                            .textFieldStyle(.roundedBorder)

                        Stepper("Team size: \(teamSize)", value: $teamSize, in: 1...500)
                    }
                    .premiumCard()

                    selectionSection(
                        title: "Business type",
                        items: BusinessIndustry.allCases,
                        selected: selectedIndustry
                    ) { industry in
                        selectedIndustry = industry
                    }

                    selectionSection(
                        title: "Primary goal",
                        items: OnboardingGoal.allCases,
                        selected: selectedGoal
                    ) { goal in
                        selectedGoal = goal
                    }

                    Button(action: completeOnboarding) {
                        Text("Start building documents")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(businessName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(20)
            }
            .background(SOPTheme.groupedBackground)
            .navigationTitle("SOPForge AI")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(SOPTheme.accent)
                .frame(width: 58, height: 58)
                .background(SOPTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text("Turn messy processes into clear SOPs, checklists, and training documents.")
                .font(.largeTitle.bold())
                .fixedSize(horizontal: false, vertical: true)

            Text("Set the working context once and SOPForge AI will use it throughout the app.")
                .font(.body)
                .foregroundStyle(SOPTheme.subtleText)
        }
    }

    private func selectionSection<Item: RawRepresentable & CaseIterable & Identifiable & Equatable>(
        title: String,
        items: [Item],
        selected: Item,
        onSelect: @escaping (Item) -> Void
    ) -> some View where Item.RawValue == String {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(items) { item in
                    Button {
                        onSelect(item)
                    } label: {
                        Text(item.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selected == item ? .white : .primary)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .padding(.horizontal, 10)
                            .background(selected == item ? SOPTheme.accent : Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .premiumCard()
    }

    private func completeOnboarding() {
        let trimmedName = businessName.trimmingCharacters(in: .whitespacesAndNewlines)
        let profile = BusinessProfile(
            businessName: trimmedName,
            industry: selectedIndustry.rawValue,
            teamSize: teamSize
        )
        modelContext.insert(profile)
        try? modelContext.save()
        appState.completeOnboarding(businessName: trimmedName, businessType: selectedIndustry.rawValue, goal: selectedGoal.rawValue)
    }
}
