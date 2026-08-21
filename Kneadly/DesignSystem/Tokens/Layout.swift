import SwiftUI

/// 4pt base grid.
enum KSpace {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
    static let huge: CGFloat = 56

    static let screenMargin: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let sectionGap: CGFloat = 32
}

enum KRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 999
}

/// Soft and warm, never grey.
struct KShadow: ViewModifier {
    enum Level { case e1, e2, e3 }
    let level: Level

    func body(content: Content) -> some View {
        switch level {
        case .e1: content.shadow(color: Color(hex: "#3C281E").opacity(0.06), radius: 8, x: 0, y: 2)
        case .e2: content.shadow(color: Color(hex: "#3C281E").opacity(0.10), radius: 20, x: 0, y: 6)
        case .e3: content.shadow(color: Color(hex: "#3C281E").opacity(0.14), radius: 36, x: 0, y: 12)
        }
    }
}

extension View {
    func kShadow(_ level: KShadow.Level = .e1) -> some View { modifier(KShadow(level: level)) }
    func kCard(padding: CGFloat = KSpace.cardPadding) -> some View {
        self.padding(padding)
            .background(K.surface, in: RoundedRectangle(cornerRadius: KRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: KRadius.lg, style: .continuous)
                    .strokeBorder(K.separator, lineWidth: 1)
            )
    }
}

/// Nothing snaps. This is a relaxation app — every transition should feel like a slow exhale.
enum KMotion {
    static let screen = Animation.spring(response: 0.45, dampingFraction: 0.86)
    static let sheet = Animation.spring(response: 0.5, dampingFraction: 0.85)
    static let step = Animation.easeInOut(duration: 0.4)
    static let select = Animation.easeInOut(duration: 0.25)
    static let press = Animation.spring(response: 0.25, dampingFraction: 0.7)
    static let bloom = Animation.easeInOut(duration: 0.9)

    static func respectingReduceMotion(_ animation: Animation, reduced: Bool) -> Animation {
        reduced ? .easeInOut(duration: 0.2) : animation
    }
}
