import UIKit

/// Central design system tokens and styling helpers for the SAT iOS application.
/// Provides consistent colors, typography, elevations, corner radii, and haptic feedback.
struct AppTheme {

    // MARK: - Core Palette
    /// Dark Slate / Charcoal Canvas background (#2E363F)
    static let canvasBackground = UIColor(red: 46/255, green: 54/255, blue: 63/255, alpha: 1.0)

    /// Deep SAT Navy / Android-matched Blue (#163060)
    static let satDeepBlue = UIColor(red: 22/255, green: 48/255, blue: 96/255, alpha: 1.0)

    /// Floating Card background - Dark slate variant (#39424E)
    static let cardBackground = UIColor(red: 57/255, green: 66/255, blue: 78/255, alpha: 1.0)

    /// Floating Card White (#FFFFFF)
    static let cardWhite = UIColor.white

    /// Card Bottom Action Bar Background (#262D35)
    static let cardBottomBar = UIColor(red: 38/255, green: 45/255, blue: 53/255, alpha: 1.0)
    static let cardBackgroundDark = cardBottomBar

    /// Lighter card row or section background (#353D47)
    static let cardRowBackground = UIColor(red: 53/255, green: 61/255, blue: 71/255, alpha: 1.0)

    /// Gold / Warm Amber action & badge accent (#FFB848)
    static let actionGold = UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0)
    static let amberGold = actionGold

    /// Pink / Magenta Trust Code badge accent (#E91E63)
    static let pinkBadgeAccent = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 0.85)

    /// Success checkmark & primary action emerald green (#28B779 / #27AE60)
    static let successGreen = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
    static let emeraldGreen = successGreen

    /// Sky Blue accent (#27A9E3) - active underlines, links, focus indicators
    static let accentSkyBlue = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
    static let skyBlueAccent = accentSkyBlue

    /// Alert / Error banner red (#E74C3C / #DA542E)
    static let errorRed = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0)
    static let alertRed = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)

    /// Google Red (#EA4335)
    static let googleRed = UIColor(red: 234/255, green: 67/255, blue: 53/255, alpha: 1.0)

    /// Text Colors
    static let textPrimaryLight = UIColor.white
    static let textPrimaryDark = UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 1.0)
    static let textMuted = UIColor(white: 0.75, alpha: 1.0)
    static let textPlaceholder = UIColor(red: 140/255, green: 150/255, blue: 160/255, alpha: 1.0)

    /// Underline / Divider Gray
    static let dividerLine = UIColor(white: 1.0, alpha: 0.15)
    static let inputBorderNormal = UIColor(red: 218/255, green: 224/255, blue: 233/255, alpha: 1.0)
    static let inputBorderActive = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
    static let inputBorderInactive = UIColor(red: 218/255, green: 224/255, blue: 233/255, alpha: 1.0)

    // MARK: - Corner Radii Tokens
    struct CornerRadius {
        static let small: CGFloat = 6.0    // Badges, small tags
        static let medium: CGFloat = 10.0  // Text fields, OTP cells, small buttons
        static let large: CGFloat = 14.0   // Modal sheets, dialog containers
        static let xlarge: CGFloat = 16.0  // Floating cards
        static let pill: CGFloat = 22.0    // Capsule action buttons
    }

    // MARK: - Typography Scale
    struct Typography {
        static let titleHero = UIFont.systemFont(ofSize: 26, weight: .bold)
        static let titleHeader = UIFont.systemFont(ofSize: 20, weight: .bold)
        static let titleCard = UIFont.systemFont(ofSize: 16, weight: .semibold)
        static let bodyBold = UIFont.systemFont(ofSize: 15, weight: .bold)
        static let bodyMedium = UIFont.systemFont(ofSize: 15, weight: .medium)
        static let bodyRegular = UIFont.systemFont(ofSize: 14, weight: .regular)
        static let captionBold = UIFont.systemFont(ofSize: 13, weight: .bold)
        static let captionMedium = UIFont.systemFont(ofSize: 13, weight: .medium)
        static let captionRegular = UIFont.systemFont(ofSize: 13, weight: .regular)
        static let subtext = UIFont.systemFont(ofSize: 11, weight: .medium)
        static let otpDigits = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .bold)
    }

    // MARK: - Elevation & Shadow Helpers
    /// Applies a smooth, modern drop shadow to floating cards without clipping
    static func applyCardElevation(to view: UIView, cornerRadius: CGFloat = CornerRadius.xlarge) {
        view.layer.cornerRadius = cornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.18
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 14
        view.layer.masksToBounds = false
    }

    /// Applies subtle button elevation
    static func applyButtonElevation(to button: UIButton) {
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.20
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 4
        button.layer.masksToBounds = false
    }

    // MARK: - Haptic Feedback
    /// Triggers native tactile haptic feedback for user interactions
    static func triggerHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    static func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        triggerHapticFeedback(style)
    }

    static func triggerHapticFeedback(notificationType: UINotificationFeedbackGenerator.FeedbackType) {
        triggerNotificationFeedback(notificationType)
    }

    static func triggerNotificationFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
