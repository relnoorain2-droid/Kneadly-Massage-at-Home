import SwiftUI
import Charts

/// "Is this working?" answered with the user's own numbers.
struct ReliefCard: View {
    let logs: [SessionLog]

    private var entries: [ReliefEntry] { ReliefStats.entries(logs) }
    private var recent: [ReliefEntry] { Array(entries.suffix(10)) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if entries.isEmpty {
                empty
            } else {
                summary
                chart
                if let best = ReliefStats.byRoutine(entries).first(where: { $0.sessions >= 2 && $0.averageDrop > 0 }) {
                    HStack(spacing: 10) {
                        Image(systemName: "star.fill").foregroundStyle(K.terracotta500)
                        Text("Works best for you: **\(best.title)** — \(fmt(best.averageBefore)) → \(fmt(best.averageAfter)) on average over \(best.sessions) sessions.")
                            .font(.system(size: 12.5))
                            .foregroundStyle(K.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(16)
        .background(K.surface, in: RoundedRectangle(cornerRadius: KRadius.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: KRadius.lg, style: .continuous).strokeBorder(K.separator, lineWidth: 1))
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your relief score").font(.system(size: 15, weight: .semibold)).foregroundStyle(K.textPrimary)
            Text("Rate how tight you feel before and after each session. After a few, you'll see exactly which routines work for your body.")
                .font(.system(size: 12.5)).foregroundStyle(K.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var summary: some View {
        let drop = ReliefStats.averageDrop(entries)
        return HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(drop > 0 ? "−\(fmt(drop))" : fmt(drop))
                .font(.kDisplay(34))
                .foregroundStyle(drop > 0 ? K.sage600 : K.textPrimary)
            VStack(alignment: .leading, spacing: 1) {
                Text("points of tension, on average").font(.system(size: 13, weight: .semibold)).foregroundStyle(K.textPrimary)
                Text("across \(entries.count) rated session\(entries.count == 1 ? "" : "s")").font(.system(size: 11.5)).foregroundStyle(K.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var chart: some View {
        Chart {
            ForEach(Array(recent.enumerated()), id: \.element.id) { index, entry in
                RuleMark(x: .value("Session", index),
                         yStart: .value("Before", entry.before),
                         yEnd: .value("After", entry.after))
                    .foregroundStyle(K.ink300.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                PointMark(x: .value("Session", index), y: .value("Tension", entry.before))
                    .foregroundStyle(K.terracotta500)
                    .symbolSize(46)
                PointMark(x: .value("Session", index), y: .value("Tension", entry.after))
                    .foregroundStyle(K.sage600)
                    .symbolSize(46)
            }
        }
        .chartYScale(domain: 0...10)
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(values: [0, 5, 10]) { _ in
                AxisGridLine().foregroundStyle(K.separator)
                AxisValueLabel().font(.system(size: 10))
            }
        }
        .frame(height: 140)
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 10) {
                legend(K.terracotta500, "Before")
                legend(K.sage600, "After")
            }
            .font(.system(size: 10.5))
        }
        .accessibilityLabel("Tension before and after your last \(recent.count) sessions.")
    }

    private func legend(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label).foregroundStyle(K.textSecondary)
        }
    }

    private func fmt(_ v: Double) -> String { String(format: "%.1f", v) }
}
