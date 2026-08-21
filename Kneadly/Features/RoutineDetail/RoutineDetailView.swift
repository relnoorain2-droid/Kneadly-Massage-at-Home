import SwiftUI

struct RoutineDetailView: View {
    let routine: Routine
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss
    @State private var showPrepare = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    hero
                    VStack(alignment: .leading, spacing: 0) {
                        Text(routine.subtitle)
                            .font(.kCallout)
                            .foregroundStyle(K.textSecondary)
                            .padding(.top, KSpace.md)
                            .padding(.bottom, KSpace.sm)
                            .fixedSize(horizontal: false, vertical: true)

                        needsRow
                        verdictBanner
                        skipIfBanner
                        reviewedRow
                        positionRow

                        SectionHeader(title: "The \(routine.stepCount) steps")
                        ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                            StepPreviewRow(index: index + 1, step: step)
                        }
                        Spacer(minLength: 110)
                    }
                    .padding(.horizontal, KSpace.screenMargin)
                }
            }
            .ignoresSafeArea(edges: .top)

            startBar
        }
        .background(K.background.ignoresSafeArea())
        .fullScreenCover(isPresented: $showPrepare) {
            PrepareFlow(routine: routine) {
                showPrepare = false
                dismiss()
                env.startSession(routine)
            }
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            KPhoto(id: routine.coverImage, placeholderHex: routine.coverPlaceholderHex)
            PhotoScrim()
            VStack(alignment: .leading, spacing: 9) {
                Text(primaryRegionName).kOverline(K.bone.opacity(0.8))
                Text(routine.title)
                    .font(.kDisplay(29))
                    .foregroundStyle(K.bone)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 6) {
                    KChip(text: routine.mode.title, systemImage: routine.mode.symbol, style: .translucent)
                    KChip(text: routine.durationLabel, style: .translucent)
                    KChip(text: "\(routine.stepCount) steps", style: .translucent)
                    KChip(text: routine.level.title, style: .translucent)
                }
            }
            .padding(KSpace.lg)

            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(K.bone)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(.leading, KSpace.md)
            .padding(.top, 58)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .accessibilityLabel("Close")
        }
        .frame(height: 300)
    }

    private var needsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(routine.needs, id: \.self) { need in KChip(text: need) }
                if routine.mode.isAlwaysClothed { KChip(text: "Works fully clothed", systemImage: "tshirt") }
            }
        }
        .padding(.bottom, KSpace.md)
    }

    @ViewBuilder
    private var verdictBanner: some View {
        let verdict = env.verdict(for: routine)
        switch verdict {
        case .allowed:
            EmptyView()
        case let .allowedWithCap(cap, note):
            SafetyBanner(title: "Pressure capped at \(cap) of 5", message: note)
                .padding(.bottom, KSpace.md)
        case let .blocked(reason, alternativeID, seeDoctor):
            VStack(alignment: .leading, spacing: 10) {
                SafetyBanner(title: seeDoctor ? "Please see a doctor first" : "Not this one",
                             message: reason, tone: .stop)
                if let alternativeID, let alternative = env.content.routine(alternativeID) {
                    Button { env.open(alternative) } label: {
                        RoutineRow(routine: alternative, locked: env.isLocked(alternative))
                    }
                    .buttonStyle(PressScaleStyle())
                }
            }
            .padding(.bottom, KSpace.md)
        }
    }

    @ViewBuilder
    private var skipIfBanner: some View {
        if !routine.skipIf.isEmpty {
            SafetyBanner(
                title: "Skip this if",
                message: routine.skipIf.compactMap { Contraindication.find($0)?.plainQuestion.lowercased() }
                    .joined(separator: " · ")
            )
            .padding(.bottom, KSpace.md)
        }
    }

    @ViewBuilder
    private var reviewedRow: some View {
        if let reviewedBy = routine.reviewedBy {
            HStack(spacing: 9) {
                Image(systemName: "checkmark.seal")
                    .font(.system(size: 13))
                    .foregroundStyle(K.sage600)
                    .frame(width: 26, height: 26)
                    .background(K.sage300.opacity(0.22), in: Circle())
                Text(reviewedBy).font(.kCaption).foregroundStyle(K.textSecondary)
            }
            .padding(.bottom, KSpace.md)
        }
    }

    private var positionRow: some View {
        HStack(spacing: 9) {
            Image(systemName: routine.position.symbol)
                .font(.system(size: 13))
                .foregroundStyle(K.terracotta600)
                .frame(width: 26, height: 26)
                .background(K.terracotta500.opacity(0.12), in: Circle())
            Text(routine.position.title).font(.kCaption).foregroundStyle(K.textSecondary)
        }
    }

    private var startBar: some View {
        VStack(spacing: 0) {
            Divider().overlay(K.separator)
            PrimaryButton(title: startTitle, isEnabled: !env.verdict(for: routine).isBlocked) {
                if env.isLocked(routine) {
                    env.showPaywall = .lockedRoutine(routine.id)
                } else {
                    showPrepare = true
                }
            }
            .padding(.horizontal, KSpace.screenMargin)
            .padding(.top, KSpace.sm)
            .padding(.bottom, KSpace.md)
        }
        .background(.regularMaterial)
    }

    private var startTitle: String {
        if env.isLocked(routine) { return "Unlock with Kneadly Plus" }
        if env.verdict(for: routine).isBlocked { return "Not right for you today" }
        return "Start this session"
    }

    private var steps: [Step] { env.content.steps(for: routine) }

    private var primaryRegionName: String {
        ContentStore.regionTitle(routine.regionIDs.first ?? "")
    }
}

struct StepPreviewRow: View {
    let index: Int
    let step: Step

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            Text("\(index)")
                .font(.system(size: 11.5, weight: .bold))
                .foregroundStyle(K.ink500)
                .frame(width: 26, height: 26)
                .background(K.sand100, in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(step.title)
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundStyle(K.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(ContentStore.techniqueTitle(step.techniqueID)) · \(step.handPosition.title)")
                    .font(.system(size: 11.5))
                    .foregroundStyle(K.textSecondary)
            }
            Spacer(minLength: 0)
            Text("\(step.durationSeconds)s")
                .font(.system(size: 11.5))
                .foregroundStyle(K.textSecondary)
        }
        .padding(.vertical, 11)
        .overlay(alignment: .bottom) { Divider().overlay(K.separator) }
        .accessibilityElement(children: .combine)
    }
}
