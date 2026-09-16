import UIKit
import UserNotifications

/// Centralized thread-safe badge count manager for the SAT iOS application.
/// Provides synchronized badge updates across iOS 15, 16, 17, and 18,
/// handling notification taps, delivered notification count tracking, and resets.
final class BadgeManager {

    static let shared = BadgeManager()

    private init() {}

    /// Explicitly updates the application icon badge count across iOS versions.
    func setBadgeCount(_ count: Int) {
        let sanitized = max(0, count)
        DispatchQueue.main.async {
            if #available(iOS 16.0, *) {
                UNUserNotificationCenter.current().setBadgeCount(sanitized) { error in
                    if let error = error {
                        print("[BadgeManager] Error setting badge via UNUserNotificationCenter: \(error.localizedDescription)")
                    } else {
                        print("[BadgeManager] Successfully updated badge count to \(sanitized)")
                    }
                }
            }
            UIApplication.shared.applicationIconBadgeNumber = sanitized
        }
    }

    /// Decreases the badge count by a specified amount (default: 1), floored at 0.
    func decrementBadgeCount(by amount: Int = 1) {
        let current = UIApplication.shared.applicationIconBadgeNumber
        let newCount = max(0, current - amount)
        setBadgeCount(newCount)
    }

    /// Increments the badge count by a specified amount (default: 1).
    func incrementBadgeCount(by amount: Int = 1) {
        let current = UIApplication.shared.applicationIconBadgeNumber
        setBadgeCount(current + amount)
    }

    /// Clears the badge count back to 0.
    func clearBadge() {
        setBadgeCount(0)
    }

    /// Synchronizes the app badge with the actual count of delivered notifications
    /// currently waiting in the iOS Notification Center tray.
    func syncWithDeliveredNotifications() {
        UNUserNotificationCenter.current().getDeliveredNotifications { [weak self] notifications in
            let count = notifications.count
            print("[BadgeManager] Found \(count) delivered notification(s) in system tray.")
            self?.setBadgeCount(count)
        }
    }

    /// Handles a notification when read/tapped by the user:
    /// 1. Removes the tapped notification from the Notification Center tray
    /// 2. Automatically updates the badge to reflect the remaining unread count
    func handleNotificationTapped(identifier: String) {
        print("[BadgeManager] Notification read/tapped with ID: \(identifier)")
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
        
        // Query remaining notifications and update badge
        UNUserNotificationCenter.current().getDeliveredNotifications { [weak self] notifications in
            let remaining = notifications.filter { $0.request.identifier != identifier }.count
            print("[BadgeManager] Remaining unread notifications after tap: \(remaining)")
            self?.setBadgeCount(remaining)
        }
    }

    /// Clears both all delivered notifications from the tray and the app badge.
    func clearAllDeliveredAndBadge() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        clearBadge()
        print("[BadgeManager] Cleared all delivered notifications and reset badge to 0.")
    }
}
