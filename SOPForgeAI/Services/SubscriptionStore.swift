import Foundation
import Observation
import StoreKit

@MainActor
@Observable
final class SubscriptionStore {
    let productIDs = [
        "com.sopforgeai.pro.monthly",
        "com.sopforgeai.pro.yearly",
        "com.sopforgeai.business.monthly"
    ]

    var products: [Product] = []
    var currentPlan: SubscriptionPlan = .free
    var isActive = false
    var renewsAt: Date?
    var isLoading = false
    var errorMessage: String?
    var statusMessage: String?

    @ObservationIgnored private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handle(result)
            }
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        statusMessage = nil
        defer { isLoading = false }

        do {
            products = try await Product.products(for: productIDs).sorted { $0.price < $1.price }
            if products.isEmpty {
                statusMessage = "The free plan is active. Paid plans will appear here when App Store subscriptions finish setup."
            }
        } catch {
            products = []
            statusMessage = "The free plan is active. Paid plans are temporarily unavailable."
        }
    }

    func refreshEntitlements() async {
        var activePlan: SubscriptionPlan = .free
        var activeRenewal: Date?

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               let plan = SubscriptionPlan.allCases.first(where: { $0.productID == transaction.productID }) {
                activePlan = plan
                activeRenewal = transaction.expirationDate
            }
        }

        currentPlan = activePlan
        isActive = activePlan != .free
        renewsAt = activeRenewal
    }

    func product(for plan: SubscriptionPlan) -> Product? {
        guard let productID = plan.productID else { return nil }
        return products.first { $0.id == productID }
    }

    func displayPrice(for plan: SubscriptionPlan) -> String {
        product(for: plan)?.displayPrice ?? plan.pricePlaceholder
    }

    func purchase(_ product: Product) async {
        isLoading = true
        errorMessage = nil
        statusMessage = nil
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                await handle(verification)
            case .userCancelled, .pending:
                statusMessage = "No purchase was completed. You can continue using the free plan."
                break
            @unknown default:
                statusMessage = "No purchase was completed. You can continue using the free plan."
                break
            }
        } catch {
            statusMessage = "No purchase was completed. You can continue using the free plan."
        }
    }

    private func handle(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else {
            statusMessage = "No purchase was completed. You can continue using the free plan."
            return
        }

        if let plan = SubscriptionPlan.allCases.first(where: { $0.productID == transaction.productID }) {
            currentPlan = plan
            isActive = plan != .free
            renewsAt = transaction.expirationDate
        }

        await transaction.finish()
    }
}
