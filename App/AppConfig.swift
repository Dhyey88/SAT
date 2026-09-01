import Foundation
import UIKit

/// Central Application Configuration
/// Contains all base URLs, API tokens, endpoints, Google OAuth settings, push tokens, and global constants used throughout the SAT iOS App.
struct AppConfig {

    // MARK: - Server Base URLs & Security
    static let baseURL = "https://test.enin.io"
    static let apiAccessToken = "piggyC@ins2019"

    // MARK: - Device Identifiers & Defaults
    static let deviceType = "1" // Mobile Client
    static let defaultLoginRole = "ho_user"

    // MARK: - Push Notifications & Device Tokens (FCM & APNs)
    static var fcmDeviceToken: String {
        get {
            return UserDefaults.standard.string(forKey: "sat_fcm_token") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "sat_fcm_token")
        }
    }

    static var apnsDeviceToken: String {
        get {
            return UserDefaults.standard.string(forKey: "sat_apns_token") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "sat_apns_token")
        }
    }

    static var deviceId: String {
        if !fcmDeviceToken.isEmpty {
            return fcmDeviceToken
        }
        if !apnsDeviceToken.isEmpty {
            return apnsDeviceToken
        }
        return mobileDeviceId
    }

    static var mobileDeviceId: String {
        let savedUUID = UserDefaults.standard.string(forKey: "sat_mobile_uuid")
        if let uuid = savedUUID, !uuid.isEmpty {
            return uuid
        }
        let newUUID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        UserDefaults.standard.set(newUUID, forKey: "sat_mobile_uuid")
        return newUUID
    }

    static var deviceName: String {
        return UIDevice.current.name
    }

    static var osVersion: String {
        return "iOS \(UIDevice.current.systemVersion)"
    }

    // MARK: - Google OAuth Configuration (Discovered from /api/get-settings)
    static var googleClientId = "713566498405-1gscd9htrfe1ac3e0o4vnfgok5cqml13.apps.googleusercontent.com"
    static var googleClientLoginId = "1091487569389-aathe6r7hkqq3p98n59eh85ljta13jdk.apps.googleusercontent.com"

    // MARK: - Contact & Support Information (Dynamic with Live Defaults)
    static var supportEmail = "info@enin.io"
    static var helplineNumber = "9977833922"

    // MARK: - Dynamic App Version (Derived from iOS Application Bundle)
    static var appVersion: String {
        let ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        return "v \(ver)"
    }

    // MARK: - REST API Endpoints
    struct API {
        static let login = "\(baseURL)/api/login"
        static let socialLogin = "\(baseURL)/api/social-login"
        static let forgotPassword = "\(baseURL)/api/forgot-password"
        static let otpVerification = "\(baseURL)/api/otp-verification"
        static let checkTrustCode = "\(baseURL)/api/check-trust-code"
        static let checkEmail = "\(baseURL)/api/check-email"
        static let registerOtpSend = "\(baseURL)/api/register-otp-send"
        static let checkRegisterOtp = "\(baseURL)/api/check-register-otp"
        static let registerOtpResend = "\(baseURL)/api/register-otp-resend"
        static let resetPassword = "\(baseURL)/api/resent-password"
        static let register = "\(baseURL)/api/register"
        static let otpVerify = "\(baseURL)/api/otp-verify"
        static let deviceHelp = "\(baseURL)/api/get-device-help"
        static let branchHelp = "\(baseURL)/api/get-branch-help"
        static let getHelpReg = "\(baseURL)/api/get-help-reg"
        static let getSettings = "\(baseURL)/api/get-settings"

        /// Web Dashboard target URL for authenticated supplier agent sessions
        static func supplierAgentURL(userId: Int) -> String {
            return "\(baseURL)/app-supplier-agent?user_id=\(userId)"
        }
    }

    // MARK: - Remote Settings Synchronizer (Fetches Google Auth, Helplines & Configurations)
    static func fetchRemoteSettings(completion: (() -> Void)? = nil) {
        guard let url = URL(string: API.getSettings) else {
            completion?()
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, error in
            defer {
                DispatchQueue.main.async { completion?() }
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let list = json["data"] as? [[String: Any]] else {
                return
            }

            for item in list {
                guard let slug = item["slug"] as? String, let val = item["data"] as? String else { continue }
                switch slug {
                case "google_client_id":
                    if !val.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        googleClientId = val.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                case "google_client_login_id":
                    if !val.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        googleClientLoginId = val.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                case "default_help_contact":
                    if !val.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        helplineNumber = val.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                case "from_email":
                    if !val.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        supportEmail = val.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                default:
                    break
                }
            }
        }.resume()
    }
}
