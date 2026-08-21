import Foundation

/// The only place the brand name lives. Changing the app's name is a one-file edit
/// here plus the `PRODUCT_NAME` / `CFBundleDisplayName` in project.yml.
enum AppBrand {
    static let name = "Kneadly"
    static let tagline = "Good hands, guided."
    static let bundleID = "com.kneadly-Massage.app"
    static let supportEmail = "support@kneadly.app"
    static let privacyURL = URL(string: "https://kneadly.app/privacy")!
    static let termsURL = URL(string: "https://kneadly.app/terms")!

    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
    static var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    /// Shown on first launch and whenever the version increases. Must be scrolled and accepted.
    static let disclaimer = """
    Kneadly is a wellness and education app. It does not provide medical advice, diagnosis or \
    treatment, and it is not a substitute for care from a qualified healthcare professional.

    Always talk to a doctor before starting massage if you have a medical condition, are \
    pregnant, or are recovering from injury or surgery.

    Stop immediately if you feel sharp, burning or radiating pain.

    If you have swelling, warmth, redness or pain in one leg, do not massage it — seek medical \
    attention. Massage can dislodge a blood clot.

    Never press on the spine itself, the front of the throat, the back of the knee, or the armpit.

    By continuing you confirm that you understand this, and that you take responsibility for \
    your own safety and the safety of anyone you massage.
    """
}
