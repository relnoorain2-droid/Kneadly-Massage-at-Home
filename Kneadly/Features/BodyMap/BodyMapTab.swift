import SwiftUI

struct BodyMapTab: View {
    @Environment(AppEnvironment.self) private var env
    @State private var front = true
    @State private var selected: BodyZone?
    @State private var modeFilter: SessionMode?
    @State private var searchText = ""
    @State private var showSearch = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                ZStack(alignment: .bottomTrailing) {
                    BodyMapView(selection: selected.map { [$0] } ?? [],
                                blocked: blockedZones,
                                front: front) { zone in
                        selected = zone
                    }
                    .padding(.horizontal, 44)

                    FrontBackToggle(front: $front)
                        .padding(.trailing, KSpace.md)
                        .padding(.bottom, KSpace.sm)
                }
                .frame(maxHeight: .infinity)
            }
            .background(K.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selected) { zone in
                ZoneSheet(zone: zone, front: front, modeFilter: $modeFilter)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showSearch) {
                SearchSheet(searchText: $searchText)
                    .presentationDetents([.large])
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Where shall\nwe work?").font(.kDisplay(28))
                Text("Tap any area of the body.")
                    .font(.kSubhead).foregroundStyle(K.textSecondary)
            }
            Spacer()
            Button {
                showSearch = true
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(K.textPrimary)
                    .frame(width: 38, height: 38)
                    .background(K.surface, in: Circle())
                    .overlay(Circle().strokeBorder(K.separator, lineWidth: 1))
            }
            .accessibilityLabel("Search routines by symptom")
            .padding(.top, 6)
        }
        .padding(.horizontal, KSpace.screenMargin)
        .padding(.top, 56)
    }

    private var blockedZones: Set<BodyZone> {
        env.engine.blockedZones(answers: env.user.healthAnswers)
    }
}

struct ZoneSheet: View {
    let zone: BodyZone
    let front: Bool
    @Binding var modeFilter: SessionMode?
    @Environment(AppEnvironment.self) private var env

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(zone.title(front: front)).font(.kDisplay(23)).padding(.top, KSpace.md)
                Text(zone.note(front: front))
                    .font(.kFootnote).foregroundStyle(K.textSecondary)
                    .padding(.top, 4).padding(.bottom, KSpace.sm)
                    .fixedSize(horizontal: false, vertical: true)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ModePill(mode: nil, isOn: modeFilter == nil) { modeFilter = nil }
                        ForEach(SessionMode.allCases) { mode in
                            ModePill(mode: mode, isOn: modeFilter == mode) {
                                modeFilter = modeFilter == mode ? nil : mode
                            }
                        }
                    }
                }
                .padding(.bottom, KSpace.sm)

                if routines.isEmpty {
                    ContentUnavailableView(
                        "Nothing here yet",
                        systemImage: "hand.raised",
                        description: Text("We haven't added routines for this area in \(modeFilter?.title ?? "any") mode yet. More arrive every month.")
                    )
                    .padding(.top, KSpace.xl)
                } else {
                    ForEach(routines) { routine in
                        Button { env.open(routine) } label: {
                            RoutineRow(routine: routine,
                                       locked: env.isLocked(routine),
                                       verdict: env.verdict(for: routine))
                        }
                        .buttonStyle(PressScaleStyle())
                        .padding(.bottom, 8)
                    }
                }

                if let blocked = blockedNote {
                    SafetyBanner(title: "Heads up", message: blocked).padding(.top, KSpace.xs)
                }
                Spacer(minLength: KSpace.lg)
            }
            .padding(.horizontal, KSpace.screenMargin)
        }
        .background(K.background.ignoresSafeArea())
    }

    private var routines: [Routine] {
        env.content.routines(zone: zone, mode: modeFilter)
    }

    private var blockedNote: String? {
        let blocked = env.engine.blockedZones(answers: env.user.healthAnswers)
        guard blocked.contains(zone) else { return nil }
        return env.user.healthAnswers
            .compactMap(Contraindication.find)
            .first { $0.blockedZones.contains(zone) }?
            .explanation
    }
}

struct SearchSheet: View {
    @Binding var searchText: String
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss

    private let suggestions = ["headache", "can't sleep", "desk", "sore after gym", "feet hurt", "stressed", "jaw"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if searchText.isEmpty {
                        SectionHeader(title: "Try searching for")
                        FlowChips(items: suggestions) { searchText = $0 }
                    } else if results.isEmpty {
                        ContentUnavailableView.search(text: searchText).padding(.top, KSpace.xxl)
                    } else {
                        ForEach(results) { routine in
                            Button {
                                dismiss()
                                env.open(routine)
                            } label: {
                                RoutineRow(routine: routine, locked: env.isLocked(routine))
                            }
                            .buttonStyle(PressScaleStyle())
                            .padding(.bottom, 8)
                        }
                        .padding(.top, KSpace.md)
                    }
                    Spacer(minLength: KSpace.lg)
                }
                .padding(.horizontal, KSpace.screenMargin)
            }
            .background(K.background.ignoresSafeArea())
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Try “headache” or “can't sleep”")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var results: [Routine] { env.content.search(searchText) }
}

struct FlowChips: View {
    let items: [String]
    let onTap: (String) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                Button { onTap(item) } label: {
                    Text(item)
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 13).padding(.vertical, 9)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(K.textPrimary)
                        .background(K.surface, in: Capsule())
                        .overlay(Capsule().strokeBorder(K.separator, lineWidth: 1))
                }
            }
        }
    }
}
