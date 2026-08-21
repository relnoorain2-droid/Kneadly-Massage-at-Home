import SwiftUI
import SwiftData

struct SessionCompleteView: View {
    let completed: CompletedSession

    @Environment(AppEnvironment.self) private var env
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \SessionLog.startedAt, order: .reverse) private var logs: [SessionLog]

    @State private var feel: FeelAfter?
    @State private var pressure: PressureFeedback?
    @State private var bloom = false

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: [Color(hex: "#F6EDE4"), K.background],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            if !reduceMotion {
                Circle()
                    .fill(RadialGradient(colors: [K.terracotta500.opacity(0.3), .clear],
                                         center: .center, startRadius: 0, endRadius: 140))
                    .frame(width: 280, height: 280)
                    .scaleEffect(bloom ? 1.09 : 1)
                    .opacity(bloom ? 1 : 0.75)
                    .offset(y: -220)
                    .animation(.easeInOut(duration: 3.4).repeatForever(autoreverses: true), value: bloom)
                    .allowsHitTesting(false)
            }

            ScrollView {
                VStack(spacing: 0) {
                    Image(systemName: "hands.sparkles")
                        .font(.system(size: 38))
                        .foregroundStyle(K.terracotta600)
                        .padding(.top, 96)
                        .padding(.bottom, 12)

                    Text("Done.").font(.kDisplay(32))
                    Text(summaryLine)
                        .font(.kSubhead)
                        .foregroundStyle(K.textSecondary)
                        .padding(.top, 6)
                        .padding(.bottom, 26)

                    HStack(spacing: 8) {
                        StatTile(value: "\(completedCount)", label: "Sessions")
                        StatTile(value: "\(currentStreak)", label: "Day streak")
                        StatTile(value: totalTimeLabel, label: "Total")
                    }
                    .padding(.bottom, 8)

                    SectionHeader(title: "How does it feel now?")
                    HStack(spacing: 8) {
                        ForEach(FeelAfter.allCases, id: \.self) { option in
                            choiceButton(option.title, isOn: feel == option) { select(feel: option) }
                        }
                    }
                    .padding(.bottom, 4)

                    if feel == .worse {
                        SafetyBanner(
                            title: "Sorry to hear that",
                            message: "Give it a few hours — some soreness after deeper work is normal. If the pain is sharp, spreading, or still there tomorrow, please have someone qualified look at it.",
                            tone: .stop
                        )
                        .padding(.top, 10)
                    }

                    SectionHeader(title: "Pressure was…")
                    HStack(spacing: 8) {
                        ForEach(PressureFeedback.allCases, id: \.self) { option in
                            choiceButton(option.title, isOn: pressure == option) { select(pressure: option) }
                        }
                    }
                    .padding(.bottom, 18)

                    if let aftercare = completed.routine.aftercare {
                        SafetyBanner(title: "Aftercare", message: aftercare)
                    }

                    Spacer(minLength: 130)
                }
                .padding(.horizontal, KSpace.screenMargin)
            }

            footer
        }
        .onAppear { bloom = true }
    }

    private func choiceButton(_ title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            Text(title)
                .font(.system(size: 13.5, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 46)
                .foregroundStyle(isOn ? K.terracotta700 : K.textPrimary)
                .background(isOn ? K.terracotta500.opacity(0.08) : K.surface,
                            in: RoundedRectangle(cornerRadius: KRadius.md, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: KRadius.md, style: .continuous)
                    .strokeBorder(isOn ? K.terracotta500 : K.separator, lineWidth: 1.5))
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityAddTraits(isOn ? [.isSelected] : [])
    }

    private var footer: some View {
        VStack(spacing: 10) {
            PrimaryButton(title: primaryTitle) {
                let shouldShowPaywall = !env.subscriptions.isPlus
                env.completedSession = nil
                dismiss()
                if shouldShowPaywall {
                    env.showPaywall = .firstSessionComplete
                    Analytics.log(.paywallShown(trigger: "first_session_complete"))
                }
            }
            Button("Back to Today") {
                env.completedSession = nil
                dismiss()
            }
            .font(.kFootnote)
            .foregroundStyle(K.textSecondary)
        }
        .padding(.horizontal, KSpace.screenMargin)
        .padding(.bottom, KSpace.md)
        .padding(.top, KSpace.sm)
        .background(.regularMaterial)
    }

    private var primaryTitle: String {
        env.subscriptions.isPlus ? "Done" : "See what's next"
    }

    // MARK: - Feedback

    private func select(feel option: FeelAfter) {
        feel = option
        currentLog?.feelAfterRaw = option.rawValue
        try? context.save()
    }

    private func select(pressure option: PressureFeedback) {
        pressure = option
        currentLog?.pressureFeedbackRaw = option.rawValue
        env.user.recordPressureFeedback(option)
        Analytics.log(.pressureFeedback(option.rawValue))
        try? context.save()
    }

    private var currentLog: SessionLog? {
        guard let id = completed.logID else { return logs.first }
        return logs.first { $0.id == id }
    }

    // MARK: - Stats

    private var summaryLine: String {
        let minutes = max(1, completed.seconds / 60)
        return "\(minutes) min · \(completed.stepsCompleted) steps · \(completed.routine.mode.title)"
    }

    private var completedLogs: [SessionLog] { logs.filter(\.isComplete) }
    private var completedCount: Int { completedLogs.count }

    private var totalTimeLabel: String {
        let seconds = completedLogs.reduce(0) { $0 + $1.durationSeconds }
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    private var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var day = Date()
        while completedLogs.contains(where: { calendar.isDate($0.startedAt, inSameDayAs: day) }) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }
}
