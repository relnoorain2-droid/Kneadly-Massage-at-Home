import SwiftUI

struct PrepareFlow: View {
    let routine: Routine
    let onStart: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var page = 0
    @State private var checked: Set<String> = []
    @State private var giverAgreed = false
    @State private var receiverReady = false

    private var pageCount: Int { routine.mode.needsConsentRitual ? 3 : 2 }

    var body: some View {
        VStack(spacing: 0) {
            header
            TabView(selection: $page) {
                setupPage.tag(0)
                positionPage.tag(1)
                if routine.mode.needsConsentRitual { consentPage.tag(2) }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            footer
        }
        .background {
            Rectangle().fill(backgroundStyle).ignoresSafeArea()
        }
    }

    private var backgroundStyle: AnyShapeStyle {
        if page == pageCount - 1 && routine.mode.needsConsentRitual {
            return AnyShapeStyle(LinearGradient(colors: [Color(hex: "#F2F5F1"), K.background],
                                                startPoint: .top, endPoint: .bottom))
        }
        return AnyShapeStyle(K.background)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button {
                if page == 0 { dismiss() } else { page -= 1 }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(K.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(K.surface, in: Circle())
                    .overlay(Circle().strokeBorder(K.separator, lineWidth: 1))
            }
            .accessibilityLabel("Back")
            Text("Prepare · \(page + 1) of \(pageCount)").kOverline()
            Spacer()
            Button("Close") { dismiss() }
                .font(.kFootnote)
                .foregroundStyle(K.textSecondary)
        }
        .padding(.horizontal, KSpace.screenMargin)
        .padding(.top, 56)
        .padding(.bottom, KSpace.sm)
    }

    // MARK: - 1. Setup

    private var setupItems: [String] {
        var items = ["Towel or sheet within reach", "Room warm — 22–24°C"]
        if !routine.mode.isAlwaysClothed { items.append("Oil or lotion (optional)") }
        items.append("Phone propped where you can see it")
        items.append("Nails short, rings off, hands warm")
        items.append(contentsOf: routine.needs)
        return items
    }

    private var setupPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Get set up").font(.kDisplay(28))
                Text("Two minutes here makes the next \(routine.minutes) much better.")
                    .font(.kSubhead).foregroundStyle(K.textSecondary)
                    .padding(.top, 8).padding(.bottom, 18)

                ForEach(setupItems, id: \.self) { item in
                    Button {
                        Haptics.selection()
                        if checked.contains(item) { checked.remove(item) } else { checked.insert(item) }
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(checked.contains(item) ? K.sage600 : .clear)
                                .frame(width: 24, height: 24)
                                .overlay(Circle().strokeBorder(checked.contains(item) ? K.sage600 : K.sand200, lineWidth: 2))
                                .overlay {
                                    if checked.contains(item) {
                                        Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundStyle(K.bone)
                                    }
                                }
                            Text(item).font(.kCallout).foregroundStyle(K.textPrimary)
                            Spacer(minLength: 0)
                        }
                        .padding(13)
                        .background(checked.contains(item) ? K.sage300.opacity(0.14) : K.surface,
                                    in: RoundedRectangle(cornerRadius: KRadius.md, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: KRadius.md, style: .continuous)
                            .strokeBorder(checked.contains(item) ? K.sage300 : K.separator, lineWidth: 1))
                        .padding(.bottom, 8)
                    }
                    .buttonStyle(PressScaleStyle())
                }

                SafetyBanner(title: "Tip", message: "Warm the oil in your palms first, never straight onto their skin. Cold oil undoes the whole first minute.")
                    .padding(.top, 6)
                Spacer(minLength: KSpace.lg)
            }
            .padding(.horizontal, KSpace.screenMargin)
        }
    }

    // MARK: - 2. Position

    private var positionPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Position").font(.kDisplay(28))
                Text(routine.position.title)
                    .font(.kSubhead).foregroundStyle(K.textSecondary)
                    .padding(.top, 8).padding(.bottom, 14)

                KPhoto(id: routine.coverImage, placeholderHex: routine.coverPlaceholderHex)
                    .frame(height: 190)
                    .clipShape(RoundedRectangle(cornerRadius: KRadius.xl, style: .continuous))
                    .padding(.bottom, 14)

                infoCard(title: routine.mode == .solo ? "You" : "Receiver", body: routine.position.receiverNote)
                if routine.mode != .solo {
                    infoCard(title: "Giver", body: routine.position.giverNote)
                }
                SafetyBanner(title: "Draping", message: drapingNote)
                Spacer(minLength: KSpace.lg)
            }
            .padding(.horizontal, KSpace.screenMargin)
        }
    }

    private func infoCard(title: String, body text: String) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title).font(.system(size: 14.5, weight: .semibold)).foregroundStyle(K.textPrimary)
            Text(text).font(.kSubhead).foregroundStyle(K.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .kCard(padding: 15)
        .padding(.bottom, KSpace.sm)
    }

    private var drapingNote: String {
        if routine.mode.isAlwaysClothed {
            return "Stay fully clothed for this one. Every technique here works over a t-shirt."
        }
        return "Cover everything with a towel and uncover only the area you're working on. Re-cover it before you move on. This is what a professional does, and it is what lets the receiver relax."
    }

    // MARK: - 3. Consent ritual

    private var consentPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Agree the rules").font(.kDisplay(28))
                Text("Thirty seconds now. It's what separates a good massage from an awkward one.")
                    .font(.kSubhead).foregroundStyle(K.textSecondary)
                    .padding(.top, 8).padding(.bottom, 16)
                    .fixedSize(horizontal: false, vertical: true)

                consentCard("Agree a number scale") {
                    VStack(alignment: .leading, spacing: 11) {
                        Text("1 is barely there. 10 is too much. Aim for 6 or 7 — firm enough to feel, never enough to flinch.")
                            .font(.kSubhead).foregroundStyle(K.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { level in
                                Capsule()
                                    .fill(K.pressure(level))
                                    .frame(height: 8)
                                    .frame(maxWidth: .infinity)
                                    .overlay(Capsule().strokeBorder(level == 4 ? K.terracotta500.opacity(0.4) : .clear, lineWidth: 2.5))
                            }
                        }
                    }
                }

                consentCard("Agree a stop word") {
                    Text("“Stop” works fine. The receiver can use it at any moment, for any reason, and doesn't owe anyone an explanation.")
                        .font(.kSubhead).foregroundStyle(K.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                consentCard("Receiver, you're in charge") {
                    VStack(alignment: .leading, spacing: 7) {
                        bullet("Speak up early, not after it hurts.")
                        bullet("Breathe out into the pressure.")
                        bullet("Sharp, burning or electric pain — say stop straight away.")
                    }
                }

                HStack(spacing: 9) {
                    consentButton("Giver: we're agreed", isOn: $giverAgreed)
                    consentButton("Receiver: I'm ready", isOn: $receiverReady)
                }
                Spacer(minLength: KSpace.lg)
            }
            .padding(.horizontal, KSpace.screenMargin)
        }
    }

    private func consentCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title).font(.kDisplay(19))
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .kCard(padding: 17)
        .padding(.bottom, KSpace.sm)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle().fill(K.terracotta500).frame(width: 5, height: 5).padding(.top, 7)
            Text(text).font(.kSubhead).foregroundStyle(K.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func consentButton(_ title: String, isOn: Binding<Bool>) -> some View {
        Button {
            Haptics.medium()
            isOn.wrappedValue.toggle()
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 48)
                .foregroundStyle(isOn.wrappedValue ? K.bone : K.textPrimary)
                .background(isOn.wrappedValue ? K.sage600 : K.surface,
                            in: RoundedRectangle(cornerRadius: KRadius.md, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: KRadius.md, style: .continuous)
                    .strokeBorder(isOn.wrappedValue ? .clear : K.separator, lineWidth: 1.5))
        }
        .buttonStyle(PressScaleStyle())
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 0) {
            PrimaryButton(title: footerTitle, isEnabled: footerEnabled) {
                if page < pageCount - 1 { page += 1 } else { onStart() }
            }
            .padding(.horizontal, KSpace.screenMargin)
            .padding(.bottom, KSpace.md)
        }
    }

    private var footerTitle: String {
        switch page {
        case 0: return "Next — position"
        case 1: return routine.mode.needsConsentRitual ? "Next — agree the rules" : "Begin — \(routine.minutes) minutes"
        default: return footerEnabled ? "Begin — \(routine.minutes) minutes" : "Both of you tap to begin"
        }
    }

    private var footerEnabled: Bool {
        guard page == pageCount - 1, routine.mode.needsConsentRitual else { return true }
        return giverAgreed && receiverReady
    }
}
