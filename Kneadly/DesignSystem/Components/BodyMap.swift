import SwiftUI

/// The signature asset. Drawn as SwiftUI `Path`s in a 200 x 400 design space, so it
/// scales, tints, animates and works in dark mode with zero raster assets.
enum BodyGeometry {

    static let designSize = CGSize(width: 200, height: 400)

    /// Torso outline. Everything on the trunk is clipped to this so no region
    /// ever spills outside the silhouette.
    static func torso() -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 70, y: 74))
        p.addCurve(to: CGPoint(x: 100, y: 63),
                   control1: CGPoint(x: 70, y: 67), control2: CGPoint(x: 82, y: 63))
        p.addCurve(to: CGPoint(x: 130, y: 74),
                   control1: CGPoint(x: 118, y: 63), control2: CGPoint(x: 130, y: 67))
        p.addLine(to: CGPoint(x: 133, y: 118))
        p.addLine(to: CGPoint(x: 128, y: 160))
        p.addLine(to: CGPoint(x: 131, y: 197))
        p.addQuadCurve(to: CGPoint(x: 69, y: 197), control: CGPoint(x: 100, y: 207))
        p.addLine(to: CGPoint(x: 72, y: 160))
        p.addLine(to: CGPoint(x: 67, y: 118))
        p.closeSubpath()
        return p
    }

    /// A filled capsule between two points — used for every limb segment so the
    /// limbs are tappable and tintable rather than merely stroked.
    static func capsule(from a: CGPoint, to b: CGPoint, width: CGFloat) -> Path {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let length = sqrt(dx * dx + dy * dy)
        guard length > 0 else { return Path(ellipseIn: CGRect(x: a.x - width / 2, y: a.y - width / 2, width: width, height: width)) }
        let angle = atan2(dy, dx)
        var p = Path()
        p.addRoundedRect(in: CGRect(x: 0, y: -width / 2, width: length, height: width),
                         cornerSize: CGSize(width: width / 2, height: width / 2))
        let transform = CGAffineTransform(translationX: a.x, y: a.y).rotated(by: angle)
        return p.applying(transform)
    }

    static func ellipse(_ x: CGFloat, _ y: CGFloat, _ rx: CGFloat, _ ry: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: x - rx, y: y - ry, width: rx * 2, height: ry * 2))
    }

    /// Shapes that make up a zone. Trunk zones are clipped to the torso.
    static func path(for zone: BodyZone) -> (path: Path, clipToTorso: Bool) {
        switch zone {
        case .head:
            return (ellipse(100, 35, 23, 23), false)
        case .neck:
            return (capsule(from: CGPoint(x: 100, y: 58), to: CGPoint(x: 100, y: 69), width: 21), false)
        case .shoulders:
            var p = ellipse(76, 78, 17, 11)
            p.addPath(ellipse(124, 78, 17, 11))
            return (p, true)
        case .chest:
            return (ellipse(100, 106, 33, 19), true)
        case .abdomen:
            return (ellipse(100, 148, 31, 22), true)
        case .hips:
            return (ellipse(100, 190, 34, 18), true)
        case .arms:
            var p = capsule(from: CGPoint(x: 70, y: 80), to: CGPoint(x: 53, y: 139), width: 18)
            p.addPath(capsule(from: CGPoint(x: 130, y: 80), to: CGPoint(x: 147, y: 139), width: 18))
            return (p, false)
        case .forearms:
            var p = capsule(from: CGPoint(x: 53, y: 139), to: CGPoint(x: 47, y: 191), width: 15)
            p.addPath(capsule(from: CGPoint(x: 147, y: 139), to: CGPoint(x: 153, y: 191), width: 15))
            return (p, false)
        case .hands:
            var p = ellipse(46, 202, 9, 9)
            p.addPath(ellipse(154, 202, 9, 9))
            return (p, false)
        case .thighs:
            var p = capsule(from: CGPoint(x: 87, y: 201), to: CGPoint(x: 83, y: 271), width: 26)
            p.addPath(capsule(from: CGPoint(x: 113, y: 201), to: CGPoint(x: 117, y: 271), width: 26))
            return (p, false)
        case .knees:
            var p = ellipse(83, 279, 10.5, 10.5)
            p.addPath(ellipse(117, 279, 10.5, 10.5))
            return (p, false)
        case .calves:
            var p = capsule(from: CGPoint(x: 83, y: 289), to: CGPoint(x: 81, y: 350), width: 20)
            p.addPath(capsule(from: CGPoint(x: 117, y: 289), to: CGPoint(x: 119, y: 350), width: 20))
            return (p, false)
        case .feet:
            var p = ellipse(80, 363, 11, 8)
            p.addPath(ellipse(120, 363, 11, 8))
            return (p, false)
        }
    }

    static func scaled(_ path: Path, to size: CGSize) -> Path {
        let sx = size.width / designSize.width
        let sy = size.height / designSize.height
        let scale = min(sx, sy)
        let offsetX = (size.width - designSize.width * scale) / 2
        let offsetY = (size.height - designSize.height * scale) / 2
        return path.applying(CGAffineTransform(translationX: offsetX, y: offsetY).scaledBy(x: scale, y: scale))
    }

    static func point(_ normalised: CGPoint, in size: CGSize) -> CGPoint {
        let scale = min(size.width / designSize.width, size.height / designSize.height)
        let offsetX = (size.width - designSize.width * scale) / 2
        let offsetY = (size.height - designSize.height * scale) / 2
        return CGPoint(x: offsetX + normalised.x * designSize.width * scale,
                       y: offsetY + normalised.y * designSize.height * scale)
    }
}

// MARK: - Full body map

struct BodyMapView: View {
    var selection: Set<BodyZone> = []
    var blocked: Set<BodyZone> = []
    var front: Bool = true
    var onTap: ((BodyZone) -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The zone that was last tapped. Drives a single short press-in, press-out
    /// bounce so a tap feels answered. Nothing on this map animates on its own —
    /// a body map that breathes forever is impossible to aim at.
    @State private var tapped: BodyZone?

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                BodyGeometry.scaled(BodyGeometry.torso(), to: size)
                    .fill(K.clay200.opacity(0.55))

                ForEach(BodyZone.allCases) { zone in
                    zoneShape(zone, size: size)
                }
            }
            .frame(width: size.width, height: size.height)
        }
        .aspectRatio(BodyGeometry.designSize.width / BodyGeometry.designSize.height, contentMode: .fit)
    }

    @ViewBuilder
    private func zoneShape(_ zone: BodyZone, size: CGSize) -> some View {
        let spec = BodyGeometry.path(for: zone)
        let scaledPath = BodyGeometry.scaled(spec.path, to: size)
        let isSelected = selection.contains(zone)
        let isBlocked = blocked.contains(zone)

        ZStack {
            scaledPath
                .fill(fill(isSelected: isSelected, isBlocked: isBlocked))
            scaledPath
                .stroke(K.sand50.opacity(0.9), lineWidth: isSelected ? 2.6 : 1.4)
        }
        .opacity(isBlocked ? 0.42 : 1)
        .compositingGroup()
        .shadow(color: isSelected ? K.terracotta500.opacity(0.5) : .clear, radius: 9)
        .clipShape(zoneClip(spec.clipToTorso, size: size))
        .scaleEffect(tapped == zone && !reduceMotion ? 1.045 : 1.0)
        .animation(reduceMotion ? nil : .spring(response: 0.26, dampingFraction: 0.55), value: tapped)
        // Hit area must match what you can actually see. Clipped zones used to
        // stay tappable outside the torso, so neighbouring areas stole the tap.
        .contentShape(HitShape(path: hitPath(clipToTorso: spec.clipToTorso, scaledPath, size: size)))
        .onTapGesture {
            guard let onTap else { return }
            Haptics.light()
            tapped = zone
            onTap(zone)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                if tapped == zone { tapped = nil }
            }
        }
        .accessibilityElement()
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(zone.title(front: front))
        .accessibilityHint(isBlocked ? "Not available with your health answers" : "Shows routines for this area")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    /// The visible region of a zone: intersected with the torso when the zone is
    /// clipped to it, so taps land where the colour is.
    private func hitPath(clipToTorso: Bool, _ scaledPath: Path, size: CGSize) -> Path {
        guard clipToTorso else { return scaledPath }
        let torso = BodyGeometry.scaled(BodyGeometry.torso(), to: size)
        return Path(scaledPath.cgPath.intersection(torso.cgPath))
    }

    private func zoneClip(_ clip: Bool, size: CGSize) -> some Shape {
        ClipPathShape(path: clip ? BodyGeometry.scaled(BodyGeometry.torso(), to: size) : Path(CGRect(origin: .zero, size: size)))
    }

    private func fill(isSelected: Bool, isBlocked: Bool) -> Color {
        if isBlocked { return K.clay200.opacity(0.5) }
        return isSelected ? K.terracotta500 : K.clay200
    }
}

/// A ready-made path used as a hit area.
private struct HitShape: Shape {
    let path: Path
    func path(in rect: CGRect) -> Path { path }
}

private struct ClipPathShape: Shape {
    let path: Path
    func path(in rect: CGRect) -> Path { path }
}

// MARK: - Mini body map (Step Player inset)

struct BodyMapMini: View {
    let zones: [BodyZone]
    var strokePath: StrokePath?
    var tint: Color = K.terracotta500

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dashPhase: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let active = Set(zones)
            ZStack {
                BodyGeometry.scaled(BodyGeometry.torso(), to: size)
                    .fill(K.bone.opacity(0.16))

                ForEach(BodyZone.allCases) { zone in
                    let spec = BodyGeometry.path(for: zone)
                    BodyGeometry.scaled(spec.path, to: size)
                        .fill(active.contains(zone) ? tint : K.bone.opacity(0.16))
                }

                if let strokePath, strokePath.isDrawable {
                    strokeOverlay(strokePath, size: size)
                }
            }
        }
        .aspectRatio(BodyGeometry.designSize.width / BodyGeometry.designSize.height, contentMode: .fit)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func strokeOverlay(_ stroke: StrokePath, size: CGSize) -> some View {
        let points = stroke.cgPoints.map { BodyGeometry.point($0, in: size) }
        Path { p in
            guard let first = points.first else { return }
            p.move(to: first)
            for pt in points.dropFirst() { p.addLine(to: pt) }
        }
        .stroke(style: StrokeStyle(lineWidth: 2.4,
                                   lineCap: .round,
                                   dash: stroke.motion.isAnimated ? [6, 4] : [],
                                   dashPhase: dashPhase))
        .foregroundStyle(K.bone)
        .onAppear {
            guard stroke.motion.isAnimated, !reduceMotion else { return }
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                dashPhase = -20
            }
        }
    }
}
