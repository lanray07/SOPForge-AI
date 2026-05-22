import SwiftUI

enum AppRoute: Hashable {
    case sopGenerator
    case checklistBuilder
    case voiceToSOP
    case trainingGuide
    case safetyProcedure
    case savedDocuments
    case paywall
}

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case create = "Create"
    case library = "Library"
    case subscription = "Plans"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .dashboard: "rectangle.grid.2x2"
        case .create: "plus.square.on.square"
        case .library: "books.vertical"
        case .subscription: "creditcard"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = AppTab.dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
                    .navigationDestination(for: AppRoute.self, destination: destination)
            }
            .tabItem { Label(AppTab.dashboard.rawValue, systemImage: AppTab.dashboard.systemImage) }
            .tag(AppTab.dashboard)

            NavigationStack {
                CreateHubView()
                    .navigationDestination(for: AppRoute.self, destination: destination)
            }
            .tabItem { Label(AppTab.create.rawValue, systemImage: AppTab.create.systemImage) }
            .tag(AppTab.create)

            NavigationStack {
                DocumentLibraryView()
                    .navigationDestination(for: AppRoute.self, destination: destination)
            }
            .tabItem { Label(AppTab.library.rawValue, systemImage: AppTab.library.systemImage) }
            .tag(AppTab.library)

            NavigationStack {
                PaywallView()
            }
            .tabItem { Label(AppTab.subscription.rawValue, systemImage: AppTab.subscription.systemImage) }
            .tag(AppTab.subscription)
        }
        .tint(SOPTheme.accent)
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .sopGenerator:
            SOPGeneratorView(mode: .standard)
        case .checklistBuilder:
            ChecklistBuilderView()
        case .voiceToSOP:
            VoiceToSOPView()
        case .trainingGuide:
            TrainingGuideGeneratorView()
        case .safetyProcedure:
            SOPGeneratorView(mode: .safety)
        case .savedDocuments:
            DocumentLibraryView()
        case .paywall:
            PaywallView()
        }
    }
}
