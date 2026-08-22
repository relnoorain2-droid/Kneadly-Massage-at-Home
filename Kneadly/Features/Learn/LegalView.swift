import SwiftUI

/// Privacy Policy and Terms of Use, served from inside the app.
///
/// Apple requires a subscription paywall to link to both. Hosting them in-app
/// guarantees the links always resolve — a dead privacy URL is one of the more
/// common causes of a rejected subscription app.
///
/// NOTE: you still need a publicly reachable privacy policy URL for the App
/// Store Connect metadata field. Point it at a page with this same text.

struct LegalDocument: Identifiable {
    let id: String
    let title: String
    let updated: String
    let sections: [(String, String)]
}

extension LegalDocument {

    static let privacy = LegalDocument(
        id: "privacy",
        title: "Privacy Policy",
        updated: "Last updated August 2026",
        sections: [
            ("The short version",
             "Kneadly is built to know as little about you as possible. There is no account. Your health answers never leave your phone. We cannot see what routines you do, who you massage, or anything you enter."),

            ("What stays on your device only",
             "Your health screening answers. Any partner profiles you create, including their names and any sensitive areas you note. Your session history, streaks and preferences. All of this is stored in your phone's own storage. It is never uploaded to us, never synced to our servers, and we have no way to read it."),

            ("What we do collect",
             "Anonymous usage events — for example that a session was started or a paywall was shown. These carry no name, no email, no device identifier and no advertising ID. They cannot be linked back to you or to any individual. We use them only to understand which routines people find useful."),

            ("What we never collect",
             "We do not collect your name, email address, phone number, contacts, location, photos, or health data. Kneadly itself does not track you across apps or websites, and does not use the advertising identifier. We do not sell, rent or share data with advertisers or data brokers, because we do not hold data that could be sold."),

            ("Demonstration videos",
             "Some routines include a free demonstration video hosted on YouTube, shown in YouTube's own player. We load these from youtube-nocookie.com, YouTube's privacy-enhanced address, which does not store viewing data unless you actually press play. Once you press play, YouTube receives that request directly and its own privacy policy applies to it — we never see who watched what. If you do not press play, nothing is sent. The videos belong to the teachers credited beneath them, not to us."),

            ("Purchases",
             "Subscriptions are handled entirely by Apple. We never see your payment details. Apple tells our app only whether an active subscription exists — nothing more."),

            ("Apple Health",
             "If you choose to allow it, Kneadly can write completed sessions to the Health app as mindful minutes. This is optional and off unless you turn it on. We only write; we never read anything from Health."),

            ("Children",
             "Kneadly is not intended for children under 12 and we do not knowingly collect information from them."),

            ("Deleting your data",
             "Because everything personal lives on your device, deleting the app deletes it all. You can also use Reset All Data in Settings to clear it while keeping the app installed."),

            ("Changes",
             "If this policy changes materially we will show you the new version in the app before you continue using it."),

            ("Contact",
             "Questions about privacy can be sent to \(AppBrand.supportEmail).")
        ]
    )

    static let terms = LegalDocument(
        id: "terms",
        title: "Terms of Use",
        updated: "Last updated August 2026",
        sections: [
            ("Not medical advice",
             "Kneadly is a wellness and education app. It does not provide medical advice, diagnosis or treatment, and it is not a substitute for care from a qualified healthcare professional. Always talk to a doctor before starting massage if you have a medical condition, are pregnant, or are recovering from injury or surgery."),

            ("Your responsibility",
             "You are responsible for your own safety and for the safety of anyone you massage. Stop immediately if you or they feel sharp, burning or radiating pain, dizziness or numbness. Never massage a leg that is swollen, warm, red, or painful on one side only — this can indicate a blood clot and requires medical attention, not massage."),

            ("Consent",
             "Never massage another person without their clear, freely given permission. They may withdraw that permission at any moment, for any reason, and are not required to explain why. Kneadly is intended for consensual, non-sexual, therapeutic touch only."),

            ("Subscriptions",
             "Kneadly Plus is offered as an auto-renewing subscription. Payment is charged to your Apple Account at confirmation of purchase. Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period, and your account is charged for renewal within 24 hours of the end of that period. Any unused portion of a free trial is forfeited when you purchase a subscription. You can manage and cancel subscriptions in your Apple Account settings."),

            ("Lifetime purchase",
             "The lifetime option is a one-time purchase that unlocks all current features for as long as the app remains available. It is not a subscription and does not renew."),

            ("Licence",
             "We grant you a personal, non-transferable licence to use Kneadly on devices you own. You may not copy, resell, redistribute or reverse-engineer the app or its content."),

            ("Content",
             "Routines, instructions, illustrations and audio in Kneadly are our property or used with permission. They are for your personal use and may not be republished or used commercially."),

            ("Limitation of liability",
             "To the fullest extent permitted by law, Kneadly and its makers are not liable for any injury, loss or damage arising from your use of the app. You use the techniques shown at your own risk."),

            ("Changes",
             "We may update these terms. Continued use after an update means you accept the revised terms."),

            ("Demonstration videos",
             "Some routines link to a demonstration video hosted on YouTube and shown in YouTube's own player. Those videos are made by the teachers credited beneath them and are not ours. They are free to watch and are never part of what a Kneadly Plus subscription pays for. We cannot control whether a video stays available, and your use of the YouTube player is also governed by YouTube's own terms."),

            ("Contact",
             "Questions can be sent to \(AppBrand.supportEmail).")
        ]
    )
}

struct LegalView: View {
    let document: LegalDocument
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(document.title)
                        .font(.kDisplay(28))
                        .padding(.top, KSpace.sm)
                    Text(document.updated)
                        .font(.kCaption)
                        .foregroundStyle(K.ink300)
                        .padding(.top, 4)
                        .padding(.bottom, KSpace.lg)

                    ForEach(Array(document.sections.enumerated()), id: \.offset) { _, section in
                        VStack(alignment: .leading, spacing: 7) {
                            Text(section.0)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(K.textPrimary)
                            Text(section.1)
                                .font(.kSubhead)
                                .foregroundStyle(K.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, KSpace.lg)
                    }

                    Text("\(AppBrand.name) \(AppBrand.version) (\(AppBrand.build))")
                        .font(.kCaption)
                        .foregroundStyle(K.ink300)
                        .padding(.bottom, KSpace.xxl)
                }
                .padding(.horizontal, KSpace.screenMargin)
            }
            .background(K.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
