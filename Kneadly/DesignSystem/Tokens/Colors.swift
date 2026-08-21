import SwiftUI

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r, g, b, a: Double
        switch cleaned.count {
        case 8:
            r = Double((value >> 24) & 0xFF) / 255
            g = Double((value >> 16) & 0xFF) / 255
            b = Double((value >> 8) & 0xFF) / 255
            a = Double(value & 0xFF) / 255
        default:
            r = Double((value >> 16) & 0xFF) / 255
            g = Double((value >> 8) & 0xFF) / 255
            b = Double(value & 0xFF) / 255
            a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

/// Warm, low-saturation, skin-adjacent. It has to sit behind photographs of skin
/// without fighting them. Dark mode is a re-lighting, not an inversion — most
/// sessions happen at night in a dim room.
enum K {

    // Sand
    static let sand50  = Color(hex: "#FBF8F4")
    static let sand100 = Color(hex: "#F5EFE7")
    static let sand200 = Color(hex: "#EBE1D5")

    // Clay
    static let clay200 = Color(hex: "#E3C8B7")
    static let clay400 = Color(hex: "#D09A7C")

    // Terracotta — primary
    static let terracotta500 = Color(hex: "#C0664A")
    static let terracotta600 = Color(hex: "#A85539")
    static let terracotta700 = Color(hex: "#8C4429")
    static let terracottaDark = Color(hex: "#D4785C")

    // Sage — safety, success, sensation cues
    static let sage300 = Color(hex: "#A9BFB0")
    static let sage600 = Color(hex: "#5E8570")
    static let sage800 = Color(hex: "#33503F")

    // Ink
    static let ink900 = Color(hex: "#14110F")
    static let ink800 = Color(hex: "#1E1A17")
    static let ink700 = Color(hex: "#2C2723")
    static let ink500 = Color(hex: "#5C534C")
    static let ink300 = Color(hex: "#8F847A")
    static let bone   = Color(hex: "#FFFDFA")

    // Semantic
    static let caution = Color(hex: "#C87F5E")
    static let stop    = Color(hex: "#B34A3F")
    static let info    = Color(hex: "#5F7D91")

    // Adaptive
    static var background: Color { Color("Background") }
    static var surface: Color { Color("Surface") }
    static var surfaceElevated: Color { Color("SurfaceElevated") }
    static var textPrimary: Color { Color("TextPrimary") }
    static var textSecondary: Color { Color("TextSecondary") }
    static var separator: Color { Color("Separator") }
    static var accent: Color { Color("AccentColor") }

    /// Pressure is semantic, never decorative.
    static func pressure(_ level: Int) -> Color {
        switch min(5, max(1, level)) {
        case 1: return Color(hex: "#8FB8A4")
        case 2: return Color(hex: "#B9C48D")
        case 3: return Color(hex: "#E0B15F")
        case 4: return Color(hex: "#D08A4E")
        default: return Color(hex: "#C0664A")
        }
    }
}

extension ShapeStyle where Self == Color {
    static var kBackground: Color { K.background }
    static var kSurface: Color { K.surface }
    static var kAccent: Color { K.accent }
}
