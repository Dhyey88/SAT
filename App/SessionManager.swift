import Foundation
import UIKit
import WebKit

/// Central Session & Lifecycle Manager for SAT iOS Application.
/// Enforces a 5-minute (300 seconds) background session timeout.
/// 
/// Rules:
/// 1. As long as the app is open / running in background for less than 5 minutes, the session stays active.
/// 2. If the app remains in the background for more than 5 minutes, the session expires automatically.
/// 3. If the app is totally closed / killed from the App Switcher, the session terminates immediately.
final class SessionManager {

    static let shared = SessionManager()

    // MARK: - Configuration
    /// Session timeout interval: 5 minutes (300 seconds)
    static let sessionTimeoutSeconds: TimeInterval = 300.0

    enum LogoutReason {
        case userLogout
        case timeout
        case appClosed
    }

    private enum Keys {
        static let savedUserId = "sat_saved_user_id_int"
        static let savedUserEmail = "sat_saved_user_email"
    }

    // MARK: - In-Memory State (Process-Bound)
    /// Tracks if an active session exists in the current application process.
    /// When the app is totally closed / killed, this in-memory flag is destroyed.
    private(set) var isSessionActiveInMemory: Bool = false

    /// Timestamp when the app entered background
    private(set) var lastBackgroundTimestamp: Date?

    /// Timestamp of last user activity
    private(set) var lastActiveTimestamp: Date?

    private init() {}

    // MARK: - Session Queries
    var currentUserId: Int? {
        guard isSessionActiveInMemory else { return nil }
        let id = UserDefaults.standard.integer(forKey: Keys.savedUserId)
        return id > 0 ? id : nil
    }

    var currentUserEmail: String? {
        return UserDefaults.standard.string(forKey: Keys.savedUserEmail)
    }

    var isLoggedIn: Bool {
        return currentUserId != nil && isSessionActiveInMemory
    }

    // MARK: - Session Lifecycle Operations

    /// Saves session state upon successful login
    func saveSession(userId: Int, email: String) {
        UserDefaults.standard.set(userId, forKey: Keys.savedUserId)
        UserDefaults.standard.set(email, forKey: Keys.savedUserEmail)
        
        isSessionActiveInMemory = true
        lastActiveTimestamp = Date()
        lastBackgroundTimestamp = nil

        print("[SessionManager] Active session established for User ID: \(userId) (\(email)). Timeout: \(SessionManager.sessionTimeoutSeconds)s.")
    }

    /// Records when app transitions to background
    func recordBackgroundTransition() {
        guard isSessionActiveInMemory else { return }
        lastBackgroundTimestamp = Date()
        print("[SessionManager] App entered background at \(lastBackgroundTimestamp!). Starting 5-minute timeout window.")
    }

    /// Records user interaction or page navigation to reset activity timer
    func recordUserActivity() {
        lastActiveTimestamp = Date()
    }

    /// Validates session when app returns to foreground from background
    func checkSessionOnForeground() -> (isValid: Bool, reason: String?) {
        guard isSessionActiveInMemory, let userId = currentUserId, userId > 0 else {
            return (false, nil)
        }

        guard let bgTime = lastBackgroundTimestamp else {
            // No background transition recorded, session is active
            lastActiveTimestamp = Date()
            return (true, nil)
        }

        let elapsed = Date().timeIntervalSince(bgTime)
        print("[SessionManager] App returned to foreground after \(String(format: "%.1f", elapsed))s in background.")

        if elapsed > SessionManager.sessionTimeoutSeconds {
            print("[SessionManager] Session expired after 5 minutes of inactivity.")
            clearSession(reason: .timeout)
            return (false, nil)
        } else {
            print("[SessionManager] Session still valid (\(String(format: "%.1f", SessionManager.sessionTimeoutSeconds - elapsed))s remaining).")
            lastBackgroundTimestamp = nil
            lastActiveTimestamp = Date()
            return (true, nil)
        }
    }

    /// Centralized verification and UI transition on foreground
    func checkAndHandleSessionOnForeground(in window: UIWindow?) {
        // Only enforce timeout if the user is currently on the Web Dashboard
        guard isSessionActiveInMemory else { return }

        let result = checkSessionOnForeground()
        if !result.isValid {
            // Session expired: smoothly transition root view to LoginViewController without any error message
            DispatchQueue.main.async {
                guard let window = window else { return }
                let loginVC = LoginViewController()

                if let presented = window.rootViewController?.presentedViewController {
                    presented.dismiss(animated: false) {
                        UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve, animations: {
                            window.rootViewController = loginVC
                        }, completion: nil)
                    }
                } else {
                    UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve, animations: {
                        window.rootViewController = loginVC
                    }, completion: nil)
                }
            }
        }
    }

    /// Clears session, resets in-memory state, and wipes web cookies
    func clearSession(reason: LogoutReason = .userLogout) {
        let previousId = UserDefaults.standard.integer(forKey: Keys.savedUserId)
        isSessionActiveInMemory = false
        lastBackgroundTimestamp = nil
        lastActiveTimestamp = nil

        // Clear user ID from UserDefaults
        UserDefaults.standard.removeObject(forKey: Keys.savedUserId)
        UserDefaults.standard.removeObject(forKey: "saved_user_id_int")

        // Clear web session cookies
        DispatchQueue.main.async {
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                }
            }
        }

        print("[SessionManager] Cleared session for User ID: \(previousId). Reason: \(reason).")
    }
}
