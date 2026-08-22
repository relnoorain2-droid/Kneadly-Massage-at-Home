import SwiftUI
import UIKit

/// Photography loader with a graceful, intentional fallback.
///
/// Photos live in `Resources/Photos/<assetID>.jpg` and are fetched by
/// `Scripts/fetch_assets.sh` (run locally or as a CI step). If a photo is not
/// present the view renders a warm gradient derived from the content pack's
/// `placeholderHex`, so the UI never shows a grey box and the app is always
/// shippable — with or without the photo set.
enum PhotoCache {
    private static let lock = NSLock()
    private static var images: [String: UIImage] = [:]
    private static var misses: Set<String> = []

    /// Tries each id in turn and returns the first that resolves. Lets a step
    /// ask for its precise technique photo and quietly fall back to the region
    /// photo until that technique's image has been shot.
    static func firstImage(_ ids: [String]) -> UIImage? {
        for id in ids where !id.isEmpty {
            if let image = image(id) { return image }
        }
        return nil
    }

    static func image(_ id: String) -> UIImage? {
        lock.lock(); defer { lock.unlock() }
        if let cached = images[id] { return cached }
        if misses.contains(id) { return nil }
        for ext in ["jpg", "jpeg", "png", "heic"] {
            if let url = Bundle.main.url(forResource: id, withExtension: ext, subdirectory: "Photos")
                ?? Bundle.main.url(forResource: id, withExtension: ext),
               let image = UIImage(contentsOfFile: url.path) {
                images[id] = image
                return image
            }
        }
        if let asset = UIImage(named: id) {
            images[id] = asset
            return asset
        }
        misses.insert(id)
        return nil
    }
}

struct KPhoto: View {
    let id: String
    /// Used when `id` has no image on disk yet.
    var fallbackID: String?
    var placeholderHex: String?
    var showsGrade: Bool = true

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let image = PhotoCache.firstImage([id, fallbackID ?? ""]) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    fallback
                }
                if showsGrade {
                    LinearGradient(
                        colors: [K.terracotta500.opacity(0.10), K.ink900.opacity(0.12)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .blendMode(.multiply)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .clipped()
        .accessibilityHidden(true)
    }

    private var base: Color { Color(hex: placeholderHex ?? "#C9A188") }

    private var fallback: some View {
        ZStack {
            LinearGradient(
                colors: [base.opacity(0.95), base.opacity(0.6), K.ink900.opacity(0.35)],
                startPoint: .top, endPoint: .bottom
            )
            RadialGradient(
                colors: [K.bone.opacity(0.16), .clear],
                center: .init(x: 0.3, y: 0.22), startRadius: 4, endRadius: 260
            )
        }
    }
}

/// The dark bottom scrim that lets text sit over photography.
struct PhotoScrim: View {
    var strength: Double = 1
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: K.ink900.opacity(0.10 * strength), location: 0),
                .init(color: K.ink900.opacity(0.0), location: 0.26),
                .init(color: K.ink900.opacity(0.30 * strength), location: 0.55),
                .init(color: K.ink900.opacity(0.88 * strength), location: 1)
            ],
            startPoint: .top, endPoint: .bottom
        )
        .allowsHitTesting(false)
    }
}
