import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(AppEnvironment.self) private var env
    @Query(sort: \SessionLog.startedAt, order: .reverse) private var logs: [SessionLog]
    @State private var modeFilter: SessionMode?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    greeting
                    filters
                    if let program = activeProgram { programCard(program) }
                    suggestionSection
                    becauseSection
                    programsSection
                    weekSection
                    Spacer(minLength: KSpace.lg)
                }
            }
            .background(K.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Pieces

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(timeOfDayGreeting).kOverline()
            Text(env.user.name.isEmpty ? "Welcome back" : env.user.name)
                .font(.kDisplay(28))
            Text(streakLine)
                .font(.kFootnote)
                .foregroundStyle(K.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, KSpace.screenMargin)
        .padding(.top, 60)
        .padding(.bottom, KSpace.md)
        .background(
            LinearGradient(colors: [Color(hex: "#F0E4D8"), K.background], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(edges: .top)
        )
    }

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ModePill(mode: nil, isOn: modeFilter == nil) { modeFilter = nil }
                ForEach(SessionMode.allCases) { mode in
                    ModePill(mode: mode, isOn: modeFilter == mode) {
                        modeFilter = modeFilter == mode ? nil : mode
                    }
                }
            }
            .padding(.horizontal, KSpace.screenMargin)
        }
        .padding(.vertical, KSpace.sm)
    }

    @ViewBuilder
    private var suggestionSection: some View {
        if let routine = suggestion {
            VStack(alignment: .leading, spacing: 0) {
                SectionHeader(title: timeOfDayGreeting == "GOOD EVENING" ? "Tonight for you" : "For you")
                Button { env.open(routine) } label: {
                    RoutineHeroCard(routine: routine, locked: env.isLocked(routine))
                }
                .buttonStyle(PressScaleStyle())
            }
            .padding(.horizontal, KSpace.screenMargin)
        }
    }

    @ViewBuilder
    private var becauseSection: some View {
        let related = relatedRoutines
        if !related.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                SectionHeader(title: becauseTitle)
                    .padding(.horizontal, KSpace.screenMargin)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 11) {
                        ForEach(related) { routine in
                            Button { env.open(routine) } label: {
                                RoutineMiniCard(routine: routine, locked: env.isLocked(routine))
                            }
                            .buttonStyle(PressScaleStyle())
                        }
                    }
                    .padding(.horizontal, KSpace.screenMargin)
                }
            }
        }
    }

    private var programsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Programs").padding(.horizontal, KSpace.screenMargin)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 11) {
                    ForEach(env.content.programs) { program in
                        Button {
                            if program.isPremium && !env.subscriptions.isPlus {
                                env.showPaywall = .lockedProgram(program.id)
                            } else if let first = program.days.first,
                                      let routine = env.content.routine(first.routineID) {
                                env.open(routine)
                            }
                        } label: {
                            ProgramCard(program: program,
                                        locked: program.isPremium && !env.subscriptions.isPlus)
                        }
                        .buttonStyle(PressScaleStyle())
                    }
                }
                .padding(.horizontal, KSpace.screenMargin)
            }
        }
    }

    private var weekSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Your week")
            StreakRing(days: weekDays, todayIndex: todayIndex)
        }
        .padding(.horizontal, KSpace.screenMargin)
    }

    private func programCard(_ program: Program) -> some View {
        Button {
            if let day = program.days.first(where: { $0.day == 1 }),
               let routine = env.content.routine(day.routineID) { env.open(routine) }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "moon.stars")
                    .font(.system(size: 19))
                    .foregroundStyle(K.terracotta600)
                    .frame(width: 44, height: 44)
                    .background(K.terracotta500.opacity(0.1), in: Circle())
                VStack(alignment: .leading, spacing: 5) {
                    Text(program.title).font(.system(size: 14, weight: .semibold)).foregroundStyle(K.textPrimary)
                    ProgressBar(value: 0.28).frame(height: 5)
                    Text("Day 1 of \(program.dayCount)").font(.kCaption).foregroundStyle(K.textSecondary)
                }
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(K.ink300)
            }
            .kCard(padding: 13)
        }
        .buttonStyle(PressScaleStyle())
        .padding(.horizontal, KSpace.screenMargin)
    }

    // MARK: - Data

    private var suggestion: Routine? {
        env.content.suggestion(modes: modeFilter.map { [$0] } ?? env.user.selectedModes,
                               zones: env.user.soreZones,
                               maxMinutes: env.user.maxMinutes,
                               isPlus: env.subscriptions.isPlus)
    }

    private var relatedRoutines: [Routine] {
        let zone = env.user.soreZones.first
        let pool = env.content.routines(mode: modeFilter)
        let filtered: [Routine]
        if let zone {
            filtered = pool.filter { routine in
                Set(env.content.steps(for: routine).flatMap(\.bodyMapZones)).contains(zone)
            }
        } else {
            filtered = pool
        }
        return Array(filtered.filter { $0.id != suggestion?.id }.prefix(8))
    }

    private var becauseTitle: String {
        if let zone = env.user.soreZones.first {
            return "Because you said your \(zone.title(front: true).lowercased()) hurt"
        }
        return "Popular right now"
    }

    private var activeProgram: Program? {
        env.content.programs.first
    }

    private var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "GOOD MORNING"
        case 12..<17: return "GOOD AFTERNOON"
        default: return "GOOD EVENING"
        }
    }

    private var completedLogs: [SessionLog] { logs.filter(\.isComplete) }

    private var streakLine: String {
        let minutes = weekMinutes
        let streak = currentStreak
        if completedLogs.isEmpty { return "Your first session is waiting." }
        return "\(streak)-day streak · \(minutes) minutes this week"
    }

    private var weekMinutes: Int {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else { return 0 }
        return completedLogs.filter { $0.startedAt >= weekStart }.reduce(0) { $0 + $1.durationSeconds } / 60
    }

    private var weekDays: [Bool] {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else {
            return Array(repeating: false, count: 7)
        }
        return (0..<7).map { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: weekStart) else { return false }
            return completedLogs.contains { calendar.isDate($0.startedAt, inSameDayAs: day) }
        }
    }

    private var todayIndex: Int {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return (weekday + 5) % 7
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
