import SwiftUI
import StoreKit

struct PaywallView: View {
    let trigger: PaywallTrigger

    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: SubscriptionService.PlanID = .annual
    @State private var isPurchasing = false

    var body: some View {
        ZStack {
            KPhoto(id: heroImage, placeholderHex: "#B98F76").ignoresSafeArea()
            LinearGradient(
                stops: [
                    .init(color: K.ink900.opacity(0.55), location: 0),
                    .init(color: K.ink900.opacity(0.82), location: 0.34),
                    .init(color: Color(hex: "#0E0B09").opacity(0.97), location: 0.62)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                Text(headline)
                    .font(.kDisplay(30))
                    .foregroundStyle(K.bone)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 20)

                VStack(alignment: .leading, spacing: 15) {
                    benefit("square.grid.2x2", "Every routine, head to toe", "\(env.content.routines.count) routines across 19 body areas")
                    benefit("hands.sparkles", "Partner, friends & together modes", "Giver and receiver views, consent flow, draping guides")
                    benefit("moon.stars", "Multi-day programs", "Sleep, neck reset, couples connection, recovery")
                    benefit("speaker.wave.2", "Offline + voice guidance", "Hands busy? Lock the screen and just listen")
                }
                .padding(.bottom, 18)

                ForEach(SubscriptionService.PlanID.allCases, id: \.self) { plan in
                    planRow(plan)
                }

                PrimaryButton(title: ctaTitle, isEnabled: !isPurchasing) { purchase() }
                    .padding(.top, 6)

                HStack(spacing: 14) {
                    Button("Restore") { Task { await env.subscriptions.restore() } }
                    Link("Terms", destination: AppBrand.termsURL)
                    Link("Privacy", destination: AppBrand.privacyURL)
                }
                .font(.system(size: 11.5))
                .foregroundStyle(K.bone.opacity(0.5))
                .frame(maxWidth: .infinity)
                .padding(.top, 11)

                Text(fineprint)
                    .font(.system(size: 11))
                    .foregroundStyle(K.bone.opacity(0.42))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)
            }
            .padding(.horizontal, KSpace.xl)
            .padding(.bottom, KSpace.xl)

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(K.bone)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(.leading, KSpace.md)
            .padding(.top, KSpace.md)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .accessibilityLabel("Close")
        }
        .preferredColorScheme(.dark)
        .task {
            Analytics.log(.paywallShown(trigger: trigger.id))
            if env.subscriptions.products.isEmpty { await env.subscriptions.loadProducts() }
        }
        .onChange(of: env.subscriptions.isPlus) { _, isPlus in
            if isPlus { dismiss() }
        }
    }

    private func benefit(_ symbol: String, _ title: String, _ subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 15))
                .foregroundStyle(K.bone)
                .frame(width: 34, height: 34)
                .background(K.bone.opacity(0.13), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 14.5, weight: .semibold)).foregroundStyle(K.bone)
                Text(subtitle).font(.system(size: 12.5)).foregroundStyle(K.bone.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    private func planRow(_ plan: SubscriptionService.PlanID) -> some View {
        Button {
            Haptics.selection()
            selectedPlan = plan
        } label: {
            HStack(spacing: 11) {
                Circle()
                    .strokeBorder(selectedPlan == plan ? K.terracotta500 : K.bone.opacity(0.35), lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .overlay {
                        if selectedPlan == plan {
                            Circle().fill(K.terracotta500).frame(width: 10, height: 10)
                        }
                    }
                VStack(alignment: .leading, spacing: 2) {
                    Text(plan.displayName).font(.system(size: 14.5, weight: .semibold)).foregroundStyle(K.bone)
                    Text(priceLine(plan)).font(.system(size: 12)).foregroundStyle(K.bone.opacity(0.6))
                }
                Spacer(minLength: 0)
                if plan == .annual {
                    Text(savingsBadge)
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.4)
                        .foregroundStyle(K.bone)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(K.terracotta500, in: Capsule())
                }
            }
            .padding(14)
            .background(selectedPlan == plan ? K.terracotta500.opacity(0.16) : .clear,
                        in: RoundedRectangle(cornerRadius: KRadius.md, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: KRadius.md, style: .continuous)
                .strokeBorder(selectedPlan == plan ? K.terracotta500 : K.bone.opacity(0.18), lineWidth: 1.5))
            .padding(.bottom, 8)
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityAddTraits(selectedPlan == plan ? [.isSelected] : [])
    }

    private func priceLine(_ plan: SubscriptionService.PlanID) -> String {
        let price = env.subscriptions.priceString(plan)
        switch plan {
        case .weekly:
            return "\(price)/week · 3 days free"
        case .monthly:
            return "\(price)/month"
        case .annual:
            if let monthly = env.subscriptions.monthlyEquivalent(.annual) {
                return "\(price)/year · \(monthly) per month"
            }
            return "\(price) per year"
        case .lifetime:
            return "\(price) once · yours forever"
        }
    }

    private var ctaTitle: String {
        if isPurchasing { return "One moment…" }
        guard selectedPlan != .lifetime, env.subscriptions.hasIntroOffer(selectedPlan) else {
            return "Continue"
        }
        switch selectedPlan {
        case .weekly: return "Start 3-day free trial"
        case .annual: return "Start 7-day free trial"
        default: return "Continue"
        }
    }

    private var fineprint: String {
        switch selectedPlan {
        case .lifetime:
            return "One payment. Yours forever, on every device you sign in to."
        case .weekly:
            return "Cancel anytime. We'll remind you before the trial ends."
        case .monthly:
            return "Cancel anytime from your Apple account settings."
        case .annual:
            return "Cancel anytime. We'll remind you 2 days before the trial ends."
        }
    }

    private var headline: String {
        switch trigger {
        case .firstSessionComplete:
            return "That's one.\nHere are \(max(0, env.content.routines.count - 1)) more."
        case .lockedRoutine:
            return "This one's in\nKneadly Plus."
        case .lockedProgram:
            return "Programs are\nin Kneadly Plus."
        case .settings:
            return "Every routine.\nBoth of your hands."
        }
    }

    private var savingsBadge: String {
        let percent = env.subscriptions.annualSavingsPercent()
        return percent > 0 ? "SAVE \(percent)%" : "BEST VALUE"
    }

    private var heroImage: String {
        if case let .lockedRoutine(id) = trigger, let routine = env.content.routine(id) {
            return routine.coverImage
        }
        return "img.onb.01"
    }

    private func purchase() {
        guard let product = env.subscriptions.product(selectedPlan) else { return }
        isPurchasing = true
        Task {
            let success = await env.subscriptions.purchase(product)
            isPurchasing = false
            if success {
                Analytics.log(.purchaseCompleted(plan: selectedPlan.rawValue))
                dismiss()
            }
        }
    }
}
