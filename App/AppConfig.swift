import Foundation

/// Central Application Configuration
/// Contains all base URLs, API tokens, endpoints, and global constants used throughout the SAT iOS App.
struct AppConfig {

    // MARK: - Server Base URLs & Security
    static let baseURL = "https://test.enin.io"
    static let apiAccessToken = "piggyC@ins2019"

    // MARK: - Device Identifiers & Defaults
    static let deviceType = "1" // 1 = iOS
    static let deviceId = "SAT_IOS_DEVICE"
    static let mobileDeviceId = "SAT_IOS_DEVICE"
    static let defaultLoginRole = "ho_user"

    // MARK: - Web & Policy URLs
    static let privacyPolicyURL = "\(baseURL)/privacy-policy"
    static let tutorialURL = "\(baseURL)/tutorial"

    // MARK: - Contact & Support Information
    static let supportEmail = "support@enin.io"
    static let helplineNumber = "+91 98765 43210"
    static let appVersion = "1.0.0"

    // MARK: - REST API Endpoints
    struct API {
        static let login = "\(baseURL)/api/login"
        static let socialLogin = "\(baseURL)/api/social-login"
        static let forgotPassword = "\(baseURL)/api/forgot-password"
        static let otpVerification = "\(baseURL)/api/otp-verification"
        static let resetPassword = "\(baseURL)/api/resent-password"
        static let register = "\(baseURL)/api/register"
        static let otpVerify = "\(baseURL)/api/otp-verify"
        static let deviceHelp = "\(baseURL)/api/get-device-help"

        /// Web Dashboard target URL for authenticated supplier agent sessions
        static func supplierAgentURL(userId: Int) -> String {
            return "\(baseURL)/app-supplier-agent?user_id=\(userId)"
        }
    }
}
