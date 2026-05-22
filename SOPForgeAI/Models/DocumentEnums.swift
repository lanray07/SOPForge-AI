import Foundation

enum BusinessIndustry: String, CaseIterable, Identifiable {
    case contractor = "Contractor"
    case cleaning = "Cleaning Company"
    case landscaping = "Landscaping Team"
    case logistics = "Logistics Team"
    case agency = "Agency"
    case propertyManagement = "Property Manager"
    case hospitality = "Hospitality Business"
    case smallBusiness = "Small Business"

    var id: String { rawValue }
}

enum OnboardingGoal: String, CaseIterable, Identifiable {
    case createSOPs = "Create SOPs"
    case trainStaff = "Train staff"
    case buildChecklists = "Build checklists"
    case documentWorkflows = "Document workflows"
    case improveQuality = "Improve quality control"

    var id: String { rawValue }
}

enum DocumentTone: String, CaseIterable, Identifiable {
    case professional = "Professional"
    case friendly = "Friendly"
    case direct = "Direct"
    case detailed = "Detailed"
    case simple = "Simple"

    var id: String { rawValue }
}

enum ChecklistTemplate: String, CaseIterable, Identifiable {
    case opening = "Opening Checklist"
    case closing = "Closing Checklist"
    case inspection = "Inspection Checklist"
    case cleaning = "Cleaning Checklist"
    case maintenance = "Maintenance Checklist"
    case safety = "Safety Checklist"
    case onboarding = "Onboarding Checklist"

    var id: String { rawValue }
}

enum SubscriptionPlan: String, CaseIterable, Identifiable, Codable {
    case free
    case proMonthly
    case proYearly
    case businessMonthly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .free: "Free"
        case .proMonthly: "Pro Monthly"
        case .proYearly: "Pro Yearly"
        case .businessMonthly: "Business Monthly"
        }
    }

    var productID: String? {
        switch self {
        case .free: nil
        case .proMonthly: "com.sopforgeai.pro.monthly"
        case .proYearly: "com.sopforgeai.pro.yearly"
        case .businessMonthly: "com.sopforgeai.business.monthly"
        }
    }

    var pricePlaceholder: String {
        switch self {
        case .free: "£0"
        case .proMonthly: "£14.99"
        case .proYearly: "£119.99"
        case .businessMonthly: "£59.99"
        }
    }

    var summary: String {
        switch self {
        case .free: "3 documents/month, basic SOPs, SOPForge AI branding"
        case .proMonthly, .proYearly: "Unlimited documents, PDF export, Voice-to-SOP, advanced templates"
        case .businessMonthly: "Custom branding, version history, team workflow placeholders"
        }
    }

    var features: [String] {
        switch self {
        case .free:
            ["3 documents/month", "Basic SOPs", "SOPForge AI branding"]
        case .proMonthly, .proYearly:
            ["Unlimited documents", "PDF exports", "Voice-to-SOP", "Advanced templates", "Training guides"]
        case .businessMonthly:
            ["Custom branding", "Team workflow placeholder", "Document version history", "Multi-location placeholder", "White-label exports"]
        }
    }
}
