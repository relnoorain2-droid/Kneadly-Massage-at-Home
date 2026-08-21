import SwiftUI

struct LearnView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Learn").font(.kDisplay(28)).padding(.top, 56)
                    Text("The five strokes, ten hand positions, and everything about doing this safely.")
                        .font(.kSubhead).foregroundStyle(K.textSecondary)
                        .padding(.top, 6)
                        .fixedSize(horizontal: false, vertical: true)

                    SectionHeader(title: "The basics")
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                        NavigationLink { StrokesView() } label: {
                            LearnTile(title: "The five strokes", imageID: "img.reg.back")
                        }
                        NavigationLink { HandPositionsView() } label: {
                            LearnTile(title: "Ten hand positions", imageID: "img.reg.hand")
                        }
                        NavigationLink { OilsView() } label: {
                            LearnTile(title: "Oils & preparation", imageID: "img.prep.oil")
                        }
                        NavigationLink { PressureView() } label: {
                            LearnTile(title: "Pressure & talking", imageID: "img.reg.prone")
                        }
                    }

                    SectionHeader(title: "Safety — never locked")
                    NavigationLink { SafetyLibraryView() } label: {
                        SafetyBanner(title: "When to stop immediately",
                                     message: "Sharp, burning, electric or radiating pain. Dizziness. Numbness. A dull ache is fine — anything sharp is not. Tap to read the full safety library.")
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 8)

                    SafetyBanner(
                        title: "Never massage a leg that is",
                        message: "Swollen, warm, red, or painful on one side only. This can be a blood clot, and massage can dislodge it. See a doctor instead.",
                        tone: .stop
                    )

                    Spacer(minLength: KSpace.lg)
                }
                .padding(.horizontal, KSpace.screenMargin)
            }
            .background(K.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct LearnTile: View {
    let title: String
    let imageID: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            KPhoto(id: imageID, placeholderHex: "#C2A58E")
            PhotoScrim(strength: 0.85)
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(K.bone)
                .multilineTextAlignment(.leading)
                .padding(11)
        }
        .frame(height: 112)
        .clipShape(RoundedRectangle(cornerRadius: KRadius.lg, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Articles

struct ArticleScaffold<Content: View>: View {
    let title: String
    let intro: String
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(title).font(.kDisplay(28)).padding(.bottom, 8)
                Text(intro).font(.kSubhead).foregroundStyle(K.textSecondary)
                    .padding(.bottom, KSpace.md)
                    .fixedSize(horizontal: false, vertical: true)
                content
                Spacer(minLength: KSpace.xl)
            }
            .padding(.horizontal, KSpace.screenMargin)
            .padding(.top, KSpace.sm)
        }
        .background(K.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoBlock: View {
    let title: String
    let text: String
    var footnote: String?

    init(title: String, body text: String, footnote: String? = nil) {
        self.title = title
        self.text = text
        self.footnote = footnote
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(size: 15.5, weight: .semibold)).foregroundStyle(K.textPrimary)
            Text(text).font(.kSubhead).foregroundStyle(K.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if let footnote {
                Text(footnote).font(.kCaption).foregroundStyle(K.ink300)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .kCard(padding: 15)
        .padding(.bottom, 9)
        .accessibilityElement(children: .combine)
    }
}

struct StrokesView: View {
    private let strokes: [(String, String, String, String)] = [
        ("Effleurage", "Gliding", "Long flowing strokes with flat palms, always working toward the heart.", "Opens and closes every routine. Pressure 1–3."),
        ("Petrissage", "Kneading", "Squeeze, lift and roll the muscle between thumb and fingers, like kneading dough.", "Main work on fleshy areas. Pressure 2–4."),
        ("Friction", "Small circles", "Small deep circular or cross-fibre movement on one spot.", "Knots and tendon attachments. Pressure 3–5."),
        ("Tapotement", "Tapping", "Rhythmic cupped tapping.", "Energising finish. Never on the kidneys or spine. Pressure 2–3."),
        ("Vibration", "Shaking", "Fine trembling or rocking of a limb or muscle.", "Between deep sections, to reset. Pressure 1–2.")
    ]

    var body: some View {
        ArticleScaffold(title: "The five strokes",
                        intro: "Learn these and you can give a real massage. Everything else is a variation.") {
            ForEach(strokes, id: \.0) { name, plain, description, note in
                InfoBlock(title: "\(name) — \(plain.lowercased())", body: description, footnote: note)
            }
            SafetyBanner(title: "The one that matters most",
                         message: "Learn to use your forearm early. Beginners exhaust their thumbs in four minutes and give up. A forearm gives broad, deep pressure and costs you nothing.")
        }
    }
}

struct HandPositionsView: View {
    var body: some View {
        ArticleScaffold(title: "Ten hand positions",
                        intro: "Which part of your hand you use changes everything about how the pressure lands.") {
            ForEach(HandPosition.allCases.filter { $0 != .none }, id: \.self) { position in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: position.symbol)
                        .font(.system(size: 17))
                        .foregroundStyle(K.terracotta600)
                        .frame(width: 34, height: 34)
                        .background(K.terracotta500.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(position.title).font(.system(size: 15, weight: .semibold)).foregroundStyle(K.textPrimary)
                        Text(position.howTo).font(.kSubhead).foregroundStyle(K.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
                .kCard(padding: 14)
                .padding(.bottom, 9)
                .accessibilityElement(children: .combine)
            }
        }
    }
}

struct PressureView: View {
    var body: some View {
        ArticleScaffold(title: "Pressure & talking",
                        intro: "Agree the scale out loud before you start. It is the single biggest difference between a good massage and an awkward one.") {
            ForEach(PressureLevel.allCases) { level in
                HStack(spacing: 12) {
                    PressureMeter(level: level.rawValue, showLabel: false)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(level.title).font(.system(size: 15, weight: .semibold)).foregroundStyle(K.textPrimary)
                        Text(level.anchor).font(.kSubhead).foregroundStyle(K.textSecondary)
                    }
                    Spacer(minLength: 0)
                }
                .kCard(padding: 14)
                .padding(.bottom, 9)
            }

            InfoBlock(title: "Six rules for the giver",
                      body: "Start lighter than you think. Pressure comes from leaning your body weight in, not from your arms. Slow is deeper than hard. Sharp, burning or electric pain means stop. Never press on bone, the spine, the throat, the back of the knee or the armpit. Ask how it is at the start of each new area — then stop asking and let them relax.")
            InfoBlock(title: "Three rules for the receiver",
                      body: "Speak up early, not after it hurts. Breathe out into the pressure — holding your breath makes everything tighter. You can stop at any moment, for any reason, and you don't need one.")
        }
    }
}

struct OilsView: View {
    private let oils: [(String, String, String)] = [
        ("Fractionated coconut", "Light, slippery, long glide. Doesn't go rancid.", "Best default choice."),
        ("Sweet almond", "Medium weight, nourishing, good for dry skin.", "Avoid with nut allergies."),
        ("Jojoba", "Absorbs fast, closest to skin's own oil.", "Best for face and scalp. Most expensive."),
        ("Grapeseed", "Very light and non-greasy.", "Short shelf life."),
        ("Unscented lotion", "Grippy, less glide.", "Best when you want friction rather than slide.")
    ]

    var body: some View {
        ArticleScaffold(title: "Oils & preparation",
                        intro: "You don't need oil for every routine. When you do use it, warm it in your palms first.") {
            ForEach(oils, id: \.0) { name, description, note in
                InfoBlock(title: name, body: description, footnote: note)
            }
            SafetyBanner(title: "Essential oils — never neat",
                         message: "Adults: 2% dilution, which is 12 drops in 30ml of carrier oil. Face or sensitive skin: 1%. Pregnancy: 1%, and avoid clary sage, rosemary, jasmine and juniper. Always patch test on the inner forearm 24 hours before first use.")
                .padding(.bottom, 9)
            SafetyBanner(title: "Never",
                         message: "Undiluted essential oils on skin. Citrus oils before sun exposure. Any oil on broken skin. Petroleum jelly — no glide and it blocks pores.",
                         tone: .stop)
        }
    }
}

struct SafetyLibraryView: View {
    var body: some View {
        ArticleScaffold(title: "Safety",
                        intro: "Massage is safe for almost everyone. These are the times it isn't, in plain language.") {
            SafetyBanner(title: "Stop immediately if",
                         message: "The pain is sharp, burning, electric, or radiating anywhere. Dizziness. Numbness or tingling. Nausea. A dull ache is fine — anything sharp is not.",
                         tone: .stop)
                .padding(.bottom, 9)

            SafetyBanner(title: "Never press on",
                         message: "The spine itself — work beside it. The front or centre of the throat. The back of the knee. The armpit. The eyeball. Breast tissue. Anywhere with an open wound, rash, or infection.",
                         tone: .stop)
                .padding(.bottom, 14)

            Text("The full list").kOverline().padding(.bottom, 8)

            ForEach(Contraindication.all) { item in
                InfoBlock(title: item.plainQuestion,
                          body: item.explanation,
                          footnote: item.seeDoctor ? "Talk to a doctor before starting." : severityNote(item.severity))
            }

            InfoBlock(title: "Working with older bodies",
                      body: "Thin skin bruises easily. Keep pressure gentle, warm up for longer, look at the skin before you start, and never traction the neck. Hands and feet are usually the most welcome and the safest places to work.")
            InfoBlock(title: "Pregnancy",
                      body: "Side-lying only after the first trimester, with a pillow between the knees. No deep abdominal work. No strong pressure at the inner ankle or in the web between thumb and index finger. Talk to your midwife or doctor first.")
        }
    }

    private func severityNote(_ severity: ContraindicationSeverity) -> String {
        switch severity {
        case .absolute: return "No massage until this has cleared."
        case .relative: return "Massage can continue with lower pressure and modified positions."
        case .local: return "Work everywhere else, skip the affected area."
        }
    }
}
