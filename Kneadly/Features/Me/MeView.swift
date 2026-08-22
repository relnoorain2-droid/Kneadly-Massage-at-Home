import SwiftUI
import SwiftData

struct MeView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.modelContext) private var context
    @Query(sort: \SessionLog.startedAt, order: .reverse) private var logs: [SessionLog]
    @Query(sort: \PartnerProfile.createdAt) private var partners: [PartnerProfile]
    @State private var showAddPartner = false
    @State private var newPartnerName = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Your practice").font(.kDisplay(28)).padding(.top, 56)

                    HStack(spacing: 8) {
                        StatTile(value: "\(completed.count)", label: "Sessions")
                        StatTile(value: "\(currentStreak)", label: "Day streak")
                        StatTile(value: totalTimeLabel, label: "Total")
                    }
                    .padding(.top, 14)

                    SectionHeader(title: "Partners")
                    ForEach(partners) { partner in
                        partnerRow(partner)
                    }
                    Button {
                        showAddPartner = true
                    } label: {
                        Text("+ Add a partner")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(K.textSecondary)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(K.surface, in: RoundedRectangle(cornerRadius: KRadius.md, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: KRadius.md, style: .continuous)
                                .strokeBorder(K.separator, lineWidth: 1))
                    }
                    .buttonStyle(PressScaleStyle())
                    Text("Partner details and health answers stay on this phone. They are never uploaded.")
                        .font(.system(size: 11.5))
                        .foregroundStyle(K.ink300)
                        .padding(.top, 8)
                        .fixedSize(horizontal: false, vertical: true)

                    SectionHeader(title: "Recent")
                    if completed.isEmpty {
                        ContentUnavailableView("No sessions yet",
                                               systemImage: "clock",
                                               description: Text("Your first session will show up here."))
                            .padding(.vertical, KSpace.lg)
                    } else {
                        ForEach(completed.prefix(12)) { log in
                            historyRow(log)
                        }
                    }

                    if let nudge = neglectedNudge {
                        SafetyBanner(title: "A nudge", message: nudge).padding(.top, 12)
                    }

                    SectionHeader(title: "Settings")
                    settings

                    Spacer(minLength: KSpace.lg)
                }
                .padding(.horizontal, KSpace.screenMargin)
            }
            .background(K.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .alert("Add a partner", isPresented: $showAddPartner) {
                TextField("Name", text: $newPartnerName)
                Button("Add") { addPartner() }
                Button("Cancel", role: .cancel) { newPartnerName = "" }
            } message: {
                Text("Stored on this phone only, so partner sessions can remember their pressure preference.")
            }
        }
    }

    // MARK: - Rows

    private func partnerRow(_ partner: PartnerProfile) -> some View {
        HStack(spacing: 12) {
            Text(partner.initial)
                .font(.kDisplay(19))
                .foregroundStyle(K.terracotta700)
                .frame(width: 56, height: 56)
                .background(K.terracotta500.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(partner.name).font(.system(size: 14.5, weight: .semibold)).foregroundStyle(K.textPrimary)
                Text("Prefers pressure \(partner.preferredPressure) of 5")
                    .font(.system(size: 11.5)).foregroundStyle(K.textSecondary)
            }
            Spacer(minLength: 0)
            Stepper("", value: Binding(
                get: { partner.preferredPressure },
                set: { partner.preferredPressure = min(5, max(1, $0)); try? context.save() }
            ), in: 1...5)
            .labelsHidden()
        }
        .padding(11)
        .background(K.surface, in: RoundedRectangle(cornerRadius: KRadius.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: KRadius.md, style: .continuous).strokeBorder(K.separator, lineWidth: 1))
        .padding(.bottom, 8)
        .accessibilityElement(children: .combine)
    }

    private func historyRow(_ log: SessionLog) -> some View {
        HStack(spacing: 12) {
            KPhoto(id: env.content.routine(log.routineID)?.coverImage ?? "img.reg.rest",
                   placeholderHex: env.content.routine(log.routineID)?.coverPlaceholderHex,
                   showsGrade: false)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(log.routineTitle).font(.system(size: 14.5, weight: .semibold)).foregroundStyle(K.textPrimary)
                Text("\(log.startedAt.formatted(.relative(presentation: .named))) · \(log.mode.title) · \(log.minutes) min\(feelSuffix(log))")
                    .font(.system(size: 11.5)).foregroundStyle(K.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(11)
        .background(K.surface, in: RoundedRectangle(cornerRadius: KRadius.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: KRadius.md, style: .continuous).strokeBorder(K.separator, lineWidth: 1))
        .padding(.bottom, 8)
        .accessibilityElement(children: .combine)
    }

    private var settings: some View {
        VStack(spacing: 0) {
            settingToggle("Voice guidance", systemImage: "speaker.wave.2", isOn: Binding(
                get: { env.user.voiceEnabled },
                set: { env.user.voiceEnabled = $0; env.narration.enabled = $0; env.user.save() }
            ))
            settingToggle("Haptics", systemImage: "iphone.radiowaves.left.and.right", isOn: Binding(
                get: { env.user.hapticsEnabled },
                set: { env.user.hapticsEnabled = $0; Haptics.enabled = $0; env.user.save() }
            ))
            settingToggle("Auto-advance steps", systemImage: "forward", isOn: Binding(
                get: { env.user.autoAdvance },
                set: { env.user.autoAdvance = $0; env.user.save() }
            ))

            NavigationLink { HealthAnswersView() } label: {
                settingRow("Health answers", systemImage: "heart.text.square", value: "\(env.user.healthAnswers.count)")
            }
            NavigationLink { AboutView() } label: {
                settingRow("About & legal", systemImage: "info.circle", value: "v\(AppBrand.version)")
            }
            if !env.subscriptions.isPlus {
                Button { env.showPaywall = .settings } label: {
                    settingRow("Kneadly Plus", systemImage: "sparkles", value: "Upgrade")
                }
            }
        }
        .background(K.surface, in: RoundedRectangle(cornerRadius: KRadius.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: KRadius.lg, style: .continuous).strokeBorder(K.separator, lineWidth: 1))
    }

    private func settingToggle(_ title: String, systemImage: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage).font(.system(size: 14)).foregroundStyle(K.terracotta600).frame(width: 24)
            Toggle(title, isOn: isOn).font(.kCallout).tint(K.terracotta500)
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
        .overlay(alignment: .bottom) { Divider().overlay(K.separator).padding(.leading, 50) }
    }

    private func settingRow(_ title: String, systemImage: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage).font(.system(size: 14)).foregroundStyle(K.terracotta600).frame(width: 24)
            Text(title).font(.kCallout).foregroundStyle(K.textPrimary)
            Spacer()
            Text(value).font(.kFootnote).foregroundStyle(K.textSecondary)
            Image(systemName: "chevron.right").font(.system(size: 11, weight: .semibold)).foregroundStyle(K.ink300)
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) { Divider().overlay(K.separator).padding(.leading, 50) }
    }

    // MARK: - Data

    private var completed: [SessionLog] { logs.filter(\.isComplete) }

    private func feelSuffix(_ log: SessionLog) -> String {
        guard let feel = log.feelAfter else { return "" }
        return " · \(feel.title)"
    }

    private var totalTimeLabel: String {
        let seconds = completed.reduce(0) { $0 + $1.durationSeconds }
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    private var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var day = Date()
        while completed.contains(where: { calendar.isDate($0.startedAt, inSameDayAs: day) }) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }

    private var neglectedNudge: String? {
        guard completed.count >= 3 else { return nil }
        let worked = Set(completed.prefix(20).compactMap { env.content.routine($0.routineID) }
            .flatMap { env.content.steps(for: $0).flatMap(\.bodyMapZones) })
        if !worked.contains(.feet) { return "You haven't touched your feet in a while. Foot Relief takes ten minutes." }
        if !worked.contains(.hands) { return "Your hands do everything and get nothing. Hand & Wrist Reset is five minutes." }
        return nil
    }

    private func addPartner() {
        let trimmed = newPartnerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        context.insert(PartnerProfile(name: trimmed, preferredPressure: 3))
        try? context.save()
        newPartnerName = ""
    }
}

struct HealthAnswersView: View {
    @Environment(AppEnvironment.self) private var env

    var body: some View {
        ArticleScaffold(title: "Health answers",
                        intro: "These stay on this phone. They are never uploaded, never synced and never shared.") {
            ForEach(Contraindication.all) { item in
                CheckRow(title: item.plainQuestion,
                         isOn: env.user.healthAnswers.contains(item.id)) {
                    Haptics.selection()
                    var answers = env.user.healthAnswers
                    if let index = answers.firstIndex(of: item.id) { answers.remove(at: index) } else { answers.append(item.id) }
                    env.user.healthAnswers = answers
                    env.user.save()
                }
            }
        }
    }
}

struct AboutView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var legalDocument: LegalDocument?

    var body: some View {
        ArticleScaffold(title: "About \(AppBrand.name)",
                        intro: AppBrand.tagline) {
            InfoBlock(title: "Version", body: "\(AppBrand.version) (\(AppBrand.build))")
            InfoBlock(title: "Important", body: AppBrand.disclaimer)
            InfoBlock(title: "Photography",
                      body: "Photographs are used under the Unsplash and Pexels licences. Thank you to every photographer whose work appears in this app.")
            Button("Privacy policy") { legalDocument = .privacy }
                .font(.kCallout).padding(.vertical, 6)
            Button("Terms of use") { legalDocument = .terms }
                .font(.kCallout).padding(.vertical, 6)
            Button("Restore purchases") { Task { await env.subscriptions.restore() } }
                .font(.kCallout).padding(.vertical, 6)
        }
        .sheet(item: $legalDocument) { LegalView(document: $0) }
    }
}
