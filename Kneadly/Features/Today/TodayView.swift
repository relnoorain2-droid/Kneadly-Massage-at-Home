import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(AppEnvironment.self) private var env
    @Query(sort: \SessionLog.startedAt, order: .reverse) private var logs: [SessionLog]
    @Query(sort: \ProgramProgress.startedAt, order: .reverse) private var programProgress: [ProgramProgress]
    @Environment(\.modelContext) private var context
    @State private var modeFilter: SessionMode?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    greeting
                    filters
                    if let active = activeProgram { programCard(active.program, progress: active.progress) }
                    QuickFixRow()
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
                        Button { launch(program) } label: {
                            ProgramCard(program: program,
                                        progress: progress(for: program)?.progress(of: program.dayCount) ?? 0,
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

    private func programCard(_ program: Program, progress: ProgramProgress) -> some View {
        let day = program.days.first(where: { $0.day == progress.currentDay }) ?? program.days[0]
        let routine = env.content.routine(day.routineID)
        return Button { launch(program) } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle().stroke(K.sand200, lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: progress.progress(of: program.dayCount))
                        .stroke(K.terracotta500, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(day.day)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(K.terracotta700)
                }
                .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(program.title) · Day \(day.day) of \(program.dayCount)")
                        .kOverline(K.terracotta600)
                    Text(routine?.title ?? "Today's session")
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(K.textPrimary)
                    if let note = day.note {
                        Text(note).font(.kCaption).foregroundStyle(K.textSecondary).lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(K.ink300)
            }
            .kCard(padding: 13)
        }
        .buttonStyle(PressScaleStyle())
        .padding(.horizontal, KSpace.screenMargin)
        .padding(.bottom, KSpace.sm)
        .accessibilityLabel("Continue \(program.title), day \(day.day) of \(program.dayCount): \(routine?.title ?? "")")
    }

    // MARK: - Programs

    private func progress(for program: Program) -> ProgramProgress? {
        programProgress.first { $0.programID == program.id }
    }

    /// Start or continue a program at its current day. Completing that day's
    /// routine advances it (see StepPlayerView.advanceProgramIfNeeded).
    private func launch(_ program: Program) {
        if program.isPremium && !env.subscriptions.isPlus {
            env.showPaywall = .lockedProgram(program.id)
            return
        }
        let current: ProgramProgress
        if let existing = progress(for: program) {
            if existing.completedDays.count >= program.dayCount {   // finished: go again
                existing.completedDays = []
                existing.currentDay = 1
                existing.startedAt = Date()
            }
            current = existing
        } else {
            current = ProgramProgress(programID: program.id)
            context.insert(current)
        }
        try? context.save()
        guard
              let day = program.days.first(where: { $0.day == current.currentDay }) ?? program.days.first,
              let routine = env.content.routine(day.routineID) else { return }
        env.activeProgramID = program.id
        env.open(routine)
    }

    // MARK: - Data

    private var suggestion: Routine? {
        if let id = ReliefStats.bestRoutineID(logs),
           let proven = env.content.routine(id),
           !env.isLocked(proven),
           modeFilter == nil || proven.mode == modeFilter {
            return proven
        }
        return env.content.suggestion(modes: modeFilter.map { [$0] } ?? env.user.selectedModes,
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

    /// The most recently started program that isn't finished — real progress,
    /// not a placeholder.
    private var activeProgram: (program: Program, progress: ProgramProgress)? {
        for record in programProgress {
            guard let program = env.content.programs.first(where: { $0.id == record.programID }),
                  record.completedDays.count < program.dayCount else { continue }
            if program.isPremium && !env.subscriptions.isPlus { continue }
            return (program, record)
        }
        return nil
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
