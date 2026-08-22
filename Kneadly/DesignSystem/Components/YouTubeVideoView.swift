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
        web.loadHTMLString(Self.html(for: videoID),
                           baseURL: URL(string: "https://www.youtube.com"))
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
