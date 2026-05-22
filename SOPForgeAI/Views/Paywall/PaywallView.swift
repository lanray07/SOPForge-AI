import StoreKit
import SwiftData
import SwiftUI

struct PaywallView: View {
    @Environment(SubscriptionStore.self) private var subscriptionStore
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                if subscriptionStore.isLoading {
                    ProgressView("Loading plans...")
                        .frame(maxWidth: .infinity)
                        .premiumCard()
                }

                if let error = subscriptionStore.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                        .premiumCard()
                }

                planCard(.free)
                planCard(.proMonthly)
                planCard(.proYearly)
                planCard(.businessMonthly)

                DisclaimerView()
            }
            .padding(20)
        }
        .background(SOPTheme.groupedBackground)
        .navigationTitle("Plans")
        .task {
            await subscriptionStore.loadProducts()
            await subscriptionStore.refreshEntitlements()
            persistSubscriptionState()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(SOPTheme.purple)
                .frame(width: 54, height: 54)
                .background(SOPTheme.purple.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text("Scale your operations documents")
                .font(.largeTitle.bold())
                .fixedSize(horizontal: false, vertical: true)

            Text("Pick the document volume and export control that match your team.")
                .foregroundStyle(SOPTheme.subtleText)
        }
        .premiumCard()
    }

    private func planCard(_ plan: SubscriptionPlan) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.title)
                        .font(.title3.bold())
                    Text(plan.summary)
                        .font(.subheadline)
                        .foregroundStyle(SOPTheme.subtleText)
                }

                Spacer()

                Text(subscriptionStore.displayPrice(for: plan))
                    .font(.title3.bold())
                    .foregroundStyle(plan == .businessMonthly ? SOPTheme.purple : SOPTheme.accent)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(plan.features, id: \.self) { feature in
                    Label(feature, systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(SOPTheme.subtleText)
                }
            }

            if subscriptionStore.currentPlan == plan {
                Label("Current plan", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(SOPTheme.success)
            } else if plan != .free {
                Button {
                    Task { await buy(plan) }
                } label: {
                    Text("Choose \(plan.title)")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(subscriptionStore.isLoading)
            }
        }
        .premiumCard()
    }

    private func buy(_ plan: SubscriptionPlan) async {
        guard let product = subscriptionStore.product(for: plan) else {
            subscriptionStore.errorMessage = "This StoreKit product is not available in the current configuration."
            return
        }

        await subscriptionStore.purchase(product)
        persistSubscriptionState()
    }

    private func persistSubscriptionState() {
        let descriptor = FetchDescriptor<SubscriptionState>()
        if let existing = try? modelContext.fetch(descriptor).first {
            existing.plan = subscriptionStore.currentPlan.rawValue
            existing.isActive = subscriptionStore.isActive
            existing.renewsAt = subscriptionStore.renewsAt
        } else {
            let state = SubscriptionState(
                plan: subscriptionStore.currentPlan,
                isActive: subscriptionStore.isActive,
                renewsAt: subscriptionStore.renewsAt
            )
            modelContext.insert(state)
        }
        try? modelContext.save()
    }
}
