import Foundation
import SwiftData

@Model
final class SubscriptionState {
    @Attribute(.unique) var id: UUID
    var plan: String
    var isActive: Bool
    var renewsAt: Date?

    init(
        id: UUID = UUID(),
        plan: SubscriptionPlan = .free,
        isActive: Bool = false,
        renewsAt: Date? = nil
    ) {
        self.id = id
        self.plan = plan.rawValue
        self.isActive = isActive
        self.renewsAt = renewsAt
    }
}
