import Foundation
import UserNotifications

/// Local notifications only — nothing is sent through a server, so there is no
/// account, no push token and nothing to declare beyond "notifications".
///
/// Two kinds, both opt-in:
/// - a daily ritual at a time the user picks ("Your evening wind-down")
/// - desk breaks on weekdays at 11:00 and 15:30 — the gap in this category:
///   people who sit all day need the nudge *during* the day, not a
///   meditation reminder at night.
enum ReminderScheduler {

    private static let dailyID = "kneadly.daily"
    private static let deskIDs = (2...6).flatMap { ["kneadly.desk.am.\($0)", "kneadly.desk.pm.\($0)"] }

    static var deskBreaksEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "reminders.deskBreaks") }
        set { UserDefaults.standard.set(newValue, forKey: "reminders.deskBreaks") }
    }

    /// Ask once, at the moment the user turns a reminder on — never at launch.
    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral: return true
        case .denied: return false
        default:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        }
    }

    static func scheduleDaily(enabled: Bool, hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyID])
        guard enabled else { return }

        let content = UNMutableNotificationContent()
        let evening = hour >= 17 || hour < 4
        content.title = evening ? "Time to wind down" : "A few minutes for yourself"
        content.body = evening
            ? "Eight minutes of scalp and neck work, then sleep. Your hands are all you need."
            : "Pick one sore spot. Kneadly will talk you through it."
        content.sound = .default

        var when = DateComponents()
        when.hour = hour
        when.minute = minute
        center.add(UNNotificationRequest(identifier: dailyID, content: content,
                                         trigger: UNCalendarNotificationTrigger(dateMatching: when, repeats: true)))
    }

    static func scheduleDeskBreaks(enabled: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: deskIDs)
        deskBreaksEnabled = enabled
        guard enabled else { return }

        let slots: [(String, Int, Int, String, String)] = [
            ("am", 11, 0, "Shoulders up by your ears?", "Three minutes: neck, shoulders, forearms. You can do it in your chair."),
            ("pm", 15, 30, "Afternoon desk reset", "Your wrists and neck have been working all day. Give them three minutes.")
        ]
        for weekday in 2...6 {            // Monday–Friday
            for (tag, hour, minute, title, body) in slots {
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = .default
                var when = DateComponents()
                when.weekday = weekday
                when.hour = hour
                when.minute = minute
                center.add(UNNotificationRequest(identifier: "kneadly.desk.\(tag).\(weekday)", content: content,
                                                 trigger: UNCalendarNotificationTrigger(dateMatching: when, repeats: true)))
            }
        }
    }
}
