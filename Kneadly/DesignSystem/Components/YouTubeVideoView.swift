import SwiftUI
import WebKit

/// YouTube's official embedded player, wrapped for SwiftUI.
///
/// Deliberately plain. YouTube's Required Minimum Functionality rules forbid
/// putting overlays, frames or any visual element in front of the player, and
/// forbid altering its appearance — so no custom play button, no timer on top,
/// no branding over it. Anything Kneadly wants to say goes above or below.
///
/// Playback never starts on its own: `mediaTypesRequiringUserActionForPlayback`
/// is `.all`, so the viewer taps play themselves.
struct YouTubeVideoView: UIViewRepresentable {
    let videoID: String

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var loadedID: String?
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = .all

        let web = WKWebView(frame: .zero, configuration: config)
        web.scrollView.isScrollEnabled = false
        web.scrollView.bounces = false
        web.isOpaque = false
        web.backgroundColor = .clear
        web.scrollView.backgroundColor = .clear
        return web
    }

    func updateUIView(_ web: WKWebView, context: Context) {
        guard context.coordinator.loadedID != videoID else { return }
        context.coordinator.loadedID = videoID
        web.load(Self.request(for: videoID))
    }

    /// YouTube refuses embeds that arrive without an identifiable referrer
    /// ("This video is unavailable" / error 152-153). Its Required Minimum
    /// Functionality rules ask mobile apps to identify themselves with an
    /// HTTP Referer and `origin` built from the bundle ID, so the embed page
    /// is loaded directly with both rather than injected as HTML.
    static func request(for id: String) -> URLRequest {
        let bundle = (Bundle.main.bundleIdentifier ?? "com.kneadly-massage.app").lowercased()
        let origin = "https://\(bundle)"
        var components = URLComponents(string: "https://www.youtube-nocookie.com/embed/\(id)")!
        components.queryItems = [
            URLQueryItem(name: "playsinline", value: "1"),
            URLQueryItem(name: "rel", value: "0"),
            URLQueryItem(name: "origin", value: origin),
            URLQueryItem(name: "widget_referrer", value: origin)
        ]
        var request = URLRequest(url: components.url!)
        request.setValue(origin, forHTTPHeaderField: "Referer")
        return request
    }

    static func dismantleUIView(_ web: WKWebView, coordinator: Coordinator) {
        web.stopLoading()
        web.loadHTMLString("", baseURL: nil)
    }

    /// `youtube-nocookie.com` is YouTube's own privacy-enhanced host: it does not
    /// store viewing data unless the viewer actually plays something.
    private static func html(for id: String) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
        <style>
          * { margin: 0; padding: 0; }
          html, body { background: transparent; overflow: hidden; }
          .wrap { position: relative; width: 100%; padding-bottom: 56.25%; }
          iframe { position: absolute; inset: 0; width: 100%; height: 100%; border: 0; }
        </style>
        </head>
        <body>
        <div class="wrap">
          <iframe
            src="https://www.youtube-nocookie.com/embed/\(id)?playsinline=1&rel=0"
            allow="accelerometer; encrypted-media; gyroscope; picture-in-picture; fullscreen"
            allowfullscreen>
          </iframe>
        </div>
        </body>
        </html>
        """
    }
}

/// The "watch a therapist do it" block on a routine screen.
///
/// Free for everyone, subscriber or not — see the note in `RoutineVideos.swift`.
struct RoutineVideoSection: View {
    let video: RoutineVideo

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Text("Watch it done").kOverline()
                Text("FREE")
                    .font(.system(size: 9.5, weight: .bold))
                    .tracking(0.6)
                    .foregroundStyle(K.terracotta500)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2.5)
                    .background(K.terracotta500.opacity(0.13), in: Capsule())
                Spacer(minLength: 0)
            }
            .padding(.top, KSpace.lg)
            .padding(.bottom, KSpace.xs)

            YouTubeVideoView(videoID: video.videoID)
                .aspectRatio(16.0 / 9.0, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: KRadius.md, style: .continuous))

            Text(video.title)
                .font(.system(size: 13.5, weight: .semibold))
                .foregroundStyle(K.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 9)

            Text("\(video.channel) · on YouTube")
                .font(.kCaption)
                .foregroundStyle(K.textSecondary)
                .padding(.top, 2)

            Text("A demonstration from another teacher, so you can see the movement before you try it. Kneadly's own step-by-step guidance is below.")
                .font(.kCaption)
                .foregroundStyle(K.ink300)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 6)
        }
    }
}

// MARK: - Full screen

/// The video, filling the screen, opened from a Watch button on any step.
///
/// The close control sits in a bar *above* the player, never on top of it —
/// YouTube's Required Minimum Functionality rules forbid putting overlays,
/// frames or any visual element in front of an embedded player.
struct VideoFullScreen: View {
    let video: RoutineVideo
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(video.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(K.bone)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(video.channel) · on YouTube")
                        .font(.kCaption)
                        .foregroundStyle(K.bone.opacity(0.55))
                }
                Spacer(minLength: 0)
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(K.bone)
                        .frame(width: 38, height: 38)
                        .background(K.bone.opacity(0.13), in: Circle())
                }
                .accessibilityLabel("Close video")
            }
            .padding(.horizontal, KSpace.lg)
            .padding(.top, KSpace.lg)
            .padding(.bottom, KSpace.md)

            YouTubeVideoView(videoID: video.videoID)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Text("Free to watch, for everyone. This video belongs to \(video.channel), not to Kneadly, and is not part of what a subscription pays for.")
                .font(.system(size: 11))
                .foregroundStyle(K.bone.opacity(0.4))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, KSpace.xl)
                .padding(.vertical, KSpace.md)
        }
        .background(K.ink900.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

/// The small "Watch" pill shown on a step.
struct WatchButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 13, weight: .semibold))
                Text("Watch")
                    .font(.system(size: 12.5, weight: .semibold))
            }
            .foregroundStyle(K.bone)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(.ultraThinMaterial, in: Capsule())
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityLabel("Watch a video of this technique")
    }
}
