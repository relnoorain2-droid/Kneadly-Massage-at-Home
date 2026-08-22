import Foundation
import StoreKit
import Observation

@MainActor
@Observable
final class SubscriptionService {

    enum PlanID: String, CaseIterable {
        case weekly   = "com.kneadlymassage.app.plus.weekly"
        case monthly  = "com.kneadlymassage.app.plus.monthly"
        case annual   = "com.kneadlymassage.app.plus.annual"
        case lifetime = "com.kneadlymassage.app.plus.lifetime"

        var displayName: String {
            switch self {
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            case .annual: return "Annual"
            case .lifetime: return "Lifetime"
            }
        }

        var isSubscription: Bool { self != .lifetime }

        var sortOrder: Int {
            switch self {
            case .weekly: return 0
            case .monthly: return 1
            case .annual: return 2
            case .lifetime: return 3
            }
        }
    }

    private(set) var products: [Product] = []
    private(set) var isPlus = false
    private(set) var isLoading = false
    private(set) var lastError: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        // Must run for the whole app lifetime so Ask-to-Buy and renewals are caught.
        updatesTask = observeTransactions()
    }

    func product(_ plan: PlanID) -> Product? {
        products.first { $0.id == plan.rawValue }
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let ids = PlanID.allCases.map(\.rawValue)
            let fetched = try await Product.products(for: ids)
            products = fetched.sorted { lhs, rhs in
                let lhsOrder = PlanID(rawValue: lhs.id)?.sortOrder ?? 9
                let rhsOrder = PlanID(rawValue: rhs.id)?.sortOrder ?? 9
                return lhsOrder < rhsOrder
            }
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
        await refreshEntitlements()
    }

    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case let .success(verification):
                guard case let .verified(transaction) = verification else {
                    lastError = "That purchase could not be verified."
                    return false
                }
                await transaction.finish()
                await refreshEntitlements()
                return true
            case .userCancelled:
                return false
            case .pending:
                lastError = "Waiting for approval."
                return false
            @unknown default:
                return false
            }
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func refreshEntitlements() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            guard case let .verified(transaction) = result else { continue }
            guard PlanID(rawValue: transaction.productID) != nil else { continue }
            if let revoked = transaction.revocationDate, revoked <= Date() { continue }
            if let expiry = transaction.expirationDate, expiry <= Date() { continue }
            entitled = true
        }
        isPlus = entitled
    }

    private func observeTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard case let .verified(transaction) = result else { continue }
                await transaction.finish()
                await self?.refreshEntitlements()
            }
        }
    }

    // MARK: - Display helpers

    func priceString(_ plan: PlanID) -> String {
        product(plan)?.displayPrice ?? placeholderPrice(plan)
    }

    func monthlyEquivalent(_ plan: PlanID) -> String? {
        guard plan == .annual, let product = product(.annual) else { return nil }
        let perMonth = product.price / 12
        return perMonth.formatted(.currency(code: product.priceFormatStyle.currencyCode))
    }

    func hasIntroOffer(_ plan: PlanID) -> Bool {
        product(plan)?.subscription?.introductoryOffer != nil
    }

    private func placeholderPrice(_ plan: PlanID) -> String {
        switch plan {
        case .weekly: return "$6.99"
        case .monthly: return "$12.99"
        case .annual: return "$39.99"
        case .lifetime: return "$69.99"
        }
    }

    func annualSavingsPercent() -> Int {
        let weeklyPrice = product(.weekly)?.price ?? 6.99
        let annualPrice = product(.annual)?.price ?? 39.99
        let yearOfWeekly = weeklyPrice * 52
        guard yearOfWeekly > 0, annualPrice < yearOfWeekly else { return 0 }
        let saving = (yearOfWeekly - annualPrice) / yearOfWeekly * 100
        return Int(NSDecimalNumber(decimal: saving).doubleValue.rounded())
    }
}
