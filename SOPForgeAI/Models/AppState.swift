import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }

    var businessName: String {
        didSet { defaults.set(businessName, forKey: Keys.businessName) }
    }

    var businessType: String {
        didSet { defaults.set(businessType, forKey: Keys.businessType) }
    }

    var primaryGoal: String {
        didSet { defaults.set(primaryGoal, forKey: Keys.primaryGoal) }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.hasCompletedOnboarding = defaults.bool(forKey: Keys.hasCompletedOnboarding)
        self.businessName = defaults.string(forKey: Keys.businessName) ?? ""
        self.businessType = defaults.string(forKey: Keys.businessType) ?? BusinessIndustry.smallBusiness.rawValue
        self.primaryGoal = defaults.string(forKey: Keys.primaryGoal) ?? OnboardingGoal.createSOPs.rawValue
    }

    func completeOnboarding(businessName: String, businessType: String, goal: String) {
        self.businessName = businessName
        self.businessType = businessType
        self.primaryGoal = goal
        self.hasCompletedOnboarding = true
    }

    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let businessName = "businessName"
        static let businessType = "businessType"
        static let primaryGoal = "primaryGoal"
    }
}
