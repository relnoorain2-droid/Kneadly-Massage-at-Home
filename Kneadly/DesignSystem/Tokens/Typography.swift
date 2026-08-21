import SwiftUI

/// Display face is New York — Apple's system serif. It is on every device,
/// costs 0 KB, supports every language we will localise into, and scales with
/// Dynamic Type natively. Bundling Fraunces is a v1.2 branding decision.
extension Font {

    static func kDisplay(_ size: CGFloat = 34, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    static var kTitle1: Font { .system(size: 28, weight: .semibold, design: .serif) }
    static var kTitle2: Font { .system(size: 22, weight: .semibold) }
    static var kStepTitle: Font { .system(size: 26, weight: .semibold, design: .serif) }
    static var kHeadline: Font { .system(size: 17, weight: .semibold) }
    static var kBody: Font { .system(size: 17) }
    static var kCallout: Font { .system(size: 16) }
    static var kSubhead: Font { .system(size: 15) }
    static var kFootnote: Font { .system(size: 13) }
    static var kCaption: Font { .system(size: 12) }
    static var kOverline: Font { .system(size: 11, weight: .semibold) }
    static var kNumeral: Font { .system(size: 15, weight: .semibold, design: .rounded).monospacedDigit() }
    static var kTimer: Font { .system(size: 17, weight: .bold, design: .rounded).monospacedDigit() }
}

struct OverlineStyle: ViewModifier {
    var color: Color = K.ink300
    func body(content: Content) -> some View {
        content
            .font(.kOverline)
            .tracking(1.1)
            .textCase(.uppercase)
            .foregroundStyle(color)
    }
}

extension View {
    func kOverline(_ color: Color = K.ink300) -> some View {
        modifier(OverlineStyle(color: color))
    }
}
