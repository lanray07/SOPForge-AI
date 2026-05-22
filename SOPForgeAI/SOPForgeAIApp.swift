import SwiftData
import SwiftUI

@main
@MainActor
struct SOPForgeAIApp: App {
    @State private var appState = AppState()
    @State private var subscriptionStore = SubscriptionStore()

    private let modelContainer: ModelContainer = {
        let schema = Schema([
            BusinessProfile.self,
            SOPDocument.self,
            ChecklistDocument.self,
            TrainingGuide.self,
            SubscriptionState.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create SwiftData model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(subscriptionStore)
                .environment(\.aiService, aiService)
        }
        .modelContainer(modelContainer)
    }

    private var aiService: any AIService {
        if AppConfiguration.useMockAIByDefault {
            MockAIService()
        } else {
            RemoteAIService()
        }
    }
}
