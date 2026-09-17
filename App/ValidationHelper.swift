import Foundation

/// Centralized, high-performance validation utility for SAT iOS Application Forms.
/// Pre-compiles regular expressions to avoid CPU overhead during real-time user typing.
struct ValidationHelper {

    // MARK: - Pre-compiled Regular Expressions
    private static let emailRegex: NSRegularExpression? = {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        return try? NSRegularExpression(pattern: pattern, options: [])
    }()

    private static let mobileRegex: NSRegularExpression? = {
        let pattern = "^[0-9]{10}$"
        return try? NSRegularExpression(pattern: pattern, options: [])
    }()

    // MARK: - 1. Email Format (Standard RFC 5322 Regex)
    static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let regex = emailRegex else { return false }
        let range = NSRange(location: 0, length: trimmed.utf16.count)
        return regex.firstMatch(in: trimmed, options: [], range: range) != nil
    }

    // MARK: - 2. Mobile Phone (Strictly 10 Numeric Digits, Any Starting Digit)
    static func isValid10DigitMobile(_ mobile: String) -> Bool {
        let trimmed = mobile.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let regex = mobileRegex else { return false }
        let range = NSRange(location: 0, length: trimmed.utf16.count)
        return regex.firstMatch(in: trimmed, options: [], range: range) != nil
    }

    // MARK: - 3. User ID (Accepts either a valid Email OR a 10-Digit Mobile Number)
    static func isValidUserId(_ input: String) -> (isValid: Bool, message: String?) {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return (false, "Please enter your User ID.")
        }
        if trimmed.contains("@") {
            if !isValidEmail(trimmed) {
                return (false, "Please enter a valid email address.")
            }
        } else {
            if !isValid10DigitMobile(trimmed) {
                return (false, "Please enter a valid 10-digit mobile number or email.")
            }
        }
        return (true, nil)
    }

    // MARK: - 4. Password Verification
    static func isValidPassword(_ pass: String, minLength: Int = 6) -> (isValid: Bool, message: String?) {
        let trimmed = pass.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return (false, "Please enter your password.")
        }
        if trimmed.count < minLength {
            return (false, "Password must be at least \(minLength) characters.")
        }
        return (true, nil)
    }

    // MARK: - 5. Required (Non-Empty) Check
    static func isNonEmpty(_ value: String?) -> Bool {
        guard let val = value else { return false }
        return !val.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
