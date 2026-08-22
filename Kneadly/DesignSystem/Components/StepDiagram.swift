import SwiftUI

/// The hero visual for a step: the body, with the exact target zone lit and the
/// stroke direction drawn on it. This replaces the photograph — 225 steps
/// sharing 16 stock images meant "hold the sore outer elbow spot" showed a hand
/// massage. The diagram is precise for every single step.
struct StepDiagram: View {
    let zones: [BodyZone]
    var strokePath: StrokePath?
    var handPosition: HandPosition = .none
    var caption: String?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dashPhase: CGFloat = 0
    @State private var glow = false

    private var active: Set<BodyZone> { Set(zones) }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: KRadius.lg, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#241E1A"), Color(hex: "#171310")],
                        startPoint: .top, endPoint: .bottom
                    )
                )

            RadialGradient(
                colors: [K.terracotta500.opacity(reduceMotion ? 0.18 : (glow ? 0.26 : 0.14)), .clear],
                center: .center, startRadius: 2, endRadius: 190
            )
            .allowsHitTesting(false)

            GeometryReader { geo in
                figure(in: geo.size)
            }
            .aspectRatio(BodyGeometry.designSize.width / BodyGeometry.designSize.height,
                         contentMode: .fit)
            .padding(.vertical, 16)

            if let caption {
                Text(caption)
                    .font(.system(size: 10.5, weight: .semibold))
                    .tracking(1.1)
                    .textCase(.uppercase)
                    .foregroundStyle(K.clay400)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial, in: Capsule())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 10)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: KRadius.lg, style: .continuous))
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) { glow = true }
            withAnimation(.linear(duration: 1.3).repeatForever(autoreverses: false)) { dashPhase = -24 }
        }
        .accessibilityElement()
        .accessibilityLabel(accessibilityText)
    }

    @ViewBuilder
    private func figure(in size: CGSize) -> some View {
        ZStack {
            BodyGeometry.scaled(BodyGeometry.torso(), to: size)
                .fill(K.bone.opacity(0.10))

            ForEach(BodyZone.allCases) { zone in
                let spec = BodyGeometry.path(for: zone)
                let scaled = BodyGeometry.scaled(spec.path, to: size)
                let isActive = active.contains(zone)

                scaled
                    .fill(isActive ? K.terracotta500 : K.bone.opacity(0.10))
                    .overlay(scaled.stroke(K.ink900.opacity(0.45), lineWidth: 1))
                    .shadow(color: isActive ? K.terracotta500.opacity(0.65) : .clear, radius: 12)
            }

            if let strokePath, strokePath.isDrawable {
                strokeOverlay(strokePath, in: size)
            }
        }
    }

    @ViewBuilder
    private func strokeOverlay(_ stroke: StrokePath, in size: CGSize) -> some View {
        let pts = stroke.cgPoints.map { BodyGeometry.point($0, in: size) }

        ZStack {
            linePath(pts)
                .stroke(K.ink900.opacity(0.35),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))

            linePath(pts)
                .stroke(K.bone,
                        style: StrokeStyle(lineWidth: 2.6,
                                           lineCap: .round,
                                           lineJoin: .round,
                                           dash: (stroke.motion.isAnimated && !reduceMotion) ? [7, 5] : [],
                                           dashPhase: dashPhase))

            if let tip = pts.last {
                Circle()
                    .fill(K.bone)
                    .frame(width: 7, height: 7)
                    .position(tip)
                    .shadow(color: K.ink900.opacity(0.5), radius: 2)
            }
        }
    }

    private func linePath(_ pts: [CGPoint]) -> Path {
        Path { p in
            guard let first = pts.first else { return }
            p.move(to: first)
            for pt in pts.dropFirst() { p.addLine(to: pt) }
        }
    }

    private var accessibilityText: String {
        let names = zones.map { $0.title(front: true) }.joined(separator: " and ")
        var text = "Diagram showing \(names) highlighted."
        if let motion = strokePath?.motion { text += " \(motion.staticDescription)." }
        if handPosition != .none { text += " Using \(handPosition.title)." }
        return text
    }
}