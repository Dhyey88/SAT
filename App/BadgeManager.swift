import UIKit
import UserNotifications

/// Centralized, high-performance badge count manager for the SAT iOS application.
/// Ensures strict main-thread execution for UIKit compliance, debounces rapid lifecycle calls,
/// and synchronizes badge counts across iOS 15, 16, 17, and 18.
final class BadgeManager {

    static let shared = BadgeManager()

    /// Cached state to avoid redundant SpringBoard / UNUserNotificationCenter IPC overhead.
    private var lastKnownBadgeCount: Int = -1

    /// Dispatch work item for coalescing rapid lifecycle sync calls.
    private var pendingSyncWorkItem: DispatchWorkItem?

    private init() {}

    /// Explicitly updates the application icon badge count across iOS versions on the main thread.
    func setBadgeCount(_ count: Int, force: Bool = false) {
        let sanitized = max(0, count)

        let applyBlock = { [weak self] in
            guard let self = self else { return }
            guard force || self.lastKnownBadgeCount != sanitized else {
                return
            }
            self.lastKnownBadgeCount = sanitized

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

        if Thread.isMainThread {
            applyBlock()
        } else {
            DispatchQueue.main.async(execute: applyBlock)
        }
    }

    /// Decreases the badge count by a specified amount (default: 1), floored at 0.
    func decrementBadgeCount(by amount: Int = 1) {
        let block = { [weak self] in
            guard let self = self else { return }
            let current = UIApplication.shared.applicationIconBadgeNumber
            let newCount = max(0, current - amount)
            self.setBadgeCount(newCount)
        }

        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }

    /// Increments the badge count by a specified amount (default: 1).
    func incrementBadgeCount(by amount: Int = 1) {
        let block = { [weak self] in
            guard let self = self else { return }
            let current = UIApplication.shared.applicationIconBadgeNumber
            self.setBadgeCount(current + amount)
        }

        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }

    /// Clears the badge count back to 0.
    func clearBadge() {
        setBadgeCount(0, force: true)
    }

    /// Synchronizes the app badge with the actual count of delivered notifications
    /// currently waiting in the iOS Notification Center tray.
    /// Debounces multiple rapid calls within 200ms into a single query.
    func syncWithDeliveredNotifications(debounce: Bool = true) {
        pendingSyncWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
                let count = notifications.count
                print("[BadgeManager] Found \(count) delivered notification(s) in system tray.")
                self?.setBadgeCount(count)
            }
        }
        pendingSyncWorkItem = workItem

        if debounce {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: workItem)
        } else {
            DispatchQueue.main.async(execute: workItem)
        }
    }

    /// Handles a notification when read/tapped by the user:
    /// 1. Removes the tapped notification from the Notification Center tray
    /// 2. Immediately calculates remaining notifications and reduces badge count
    func handleNotificationTapped(identifier: String) {
        print("[BadgeManager] Notification read/tapped with ID: \(identifier)")
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])

        UNUserNotificationCenter.current().getDeliveredNotifications { [weak self] notifications in
            let remaining = notifications.filter { $0.request.identifier != identifier }.count
            print("[BadgeManager] Remaining unread notifications after tap: \(remaining)")
            self?.setBadgeCount(remaining)
        }
    }

    /// Clears both all delivered notifications from the tray and resets badge to 0.
    func clearAllDeliveredAndBadge() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        clearBadge()
        print("[BadgeManager] Cleared all delivered notifications and reset badge to 0.")
    }
}
