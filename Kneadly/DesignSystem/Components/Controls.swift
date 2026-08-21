import SwiftUI

struct PrimaryButton: View {
    let title: String
    var systemImage: String?
    var isEnabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.light()
            action()
        } label: {
            HStack(spacing: KSpace.xs) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title).font(.kHeadline)
            }
            .frame(maxWidth: .infinity, minHeight: 54)
            .foregroundStyle(K.bone)
            .background(K.terracotta500, in: RoundedRectangle(cornerRadius: KRadius.md, style: .continuous))
        }
        .buttonStyle(PressScaleStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
    }
}

struct SecondaryButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.light()
            action()
        } label: {
            Text(title)
                .font(.kHeadline)
                .frame(maxWidth: .infinity, minHeight: 54)
                .foregroundStyle(K.terracotta700)
                .overlay(
                    RoundedRectangle(cornerRadius: KRadius.md, style: .continuous)
                        .strokeBorder(K.terracotta500, lineWidth: 1.5)
                )
        }
        .buttonStyle(PressScaleStyle())
    }
}

struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(KMotion.press, value: configuration.isPressed)
    }
}

struct KChip: View {
    let text: String
    var systemImage: String?
    var style: Style = .solid

    enum Style { case solid, translucent, accent }

    var body: some View {
        HStack(spacing: 5) {
            if let systemImage { Image(systemName: systemImage).font(.system(size: 11, weight: .semibold)) }
            Text(text).font(.system(size: 12, weight: .semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .foregroundStyle(foreground)
        .background(background, in: Capsule())
        .overlay(Capsule().strokeBorder(border, lineWidth: style == .translucent ? 1 : 0))
    }

    private var foreground: Color {
        switch style {
        case .solid: return K.ink500
        case .translucent: return K.bone
        case .accent: return K.bone
        }
    }
    private var background: Color {
        switch style {
        case .solid: return K.sand100
        case .translucent: return K.bone.opacity(0.22)
        case .accent: return K.terracotta500
        }
    }
    private var border: Color {
        style == .translucent ? K.bone.opacity(0.24) : .clear
    }
}

struct ModePill: View {
    let mode: SessionMode?
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            Text(mode?.title ?? "All")
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .foregroundStyle(isOn ? K.bone : K.ink500)
                .background(isOn ? K.terracotta500 : K.surface, in: Capsule())
                .overlay(Capsule().strokeBorder(isOn ? .clear : K.separator, lineWidth: 1.5))
        }
        .buttonStyle(PressScaleStyle())
    }
}

/// Five dots. Colour is never the only carrier of meaning — the label is always there.
struct PressureMeter: View {
    let level: Int
    var showLabel: Bool = true
    var onDark: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            HStack(spacing: 3.5) {
                ForEach(1...5, id: \.self) { index in
                    Circle()
                        .fill(index <= level ? K.pressure(level) : (onDark ? K.bone.opacity(0.18) : K.sand200))
                        .frame(width: 9, height: 9)
                }
            }
            if showLabel {
                Text(PressureLevel.clamped(level).title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(onDark ? K.bone : K.ink500)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Pressure \(level) of 5, \(PressureLevel.clamped(level).title). \(PressureLevel.clamped(level).anchor).")
    }
}

struct TimerRing: View {
    let progress: Double
    var lineWidth: CGFloat = 4
    var track: Color = K.bone.opacity(0.16)
    var tint: Color = K.clay200

    var body: some View {
        ZStack {
            Circle().stroke(track, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .accessibilityHidden(true)
    }
}

/// What the receiver should feel. This is how a beginner self-corrects.
struct SensationCue: View {
    let text: String
    var onDark: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Circle()
                .fill(K.sage300)
                .frame(width: 7, height: 7)
                .padding(.top, 6)
            (Text("You should feel: ").font(.system(size: 13.5, weight: .semibold))
                + Text(text).font(.system(size: 13.5)))
                .foregroundStyle(onDark ? Color(hex: "#CFE0D5") : K.sage800)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(K.sage300.opacity(onDark ? 0.16 : 0.20), in: RoundedRectangle(cornerRadius: KRadius.md, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

/// Safety copy is always paired with an alternative. A dead end is a bad outcome.
struct SafetyBanner: View {
    let title: String
    let message: String
    var tone: Tone = .calm

    enum Tone { case calm, stop }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).kOverline(tone == .stop ? K.stop : K.sage800)
            Text(message)
                .font(.kFootnote)
                .foregroundStyle(tone == .stop ? Color(hex: "#7D322A") : K.sage800)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            (tone == .stop ? K.stop.opacity(0.10) : K.sage300.opacity(0.22)),
            in: RoundedRectangle(cornerRadius: KRadius.md, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .kOverline()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, KSpace.lg)
            .padding(.bottom, KSpace.xs)
    }
}
