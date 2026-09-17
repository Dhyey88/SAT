import UIKit

/// Central design system tokens and cached theme colors for the SAT iOS application.
/// Replaces repetitive UIColor allocations throughout the codebase.
struct AppTheme {

    // MARK: - Core Palette
    /// Dark Slate / Charcoal Canvas background (#2E363F)
    static let canvasBackground = UIColor(red: 46/255, green: 54/255, blue: 63/255, alpha: 1.0)

    /// Deep SAT Navy / Android-matched Blue (#163060)
    static let satDeepBlue = UIColor(red: 22/255, green: 48/255, blue: 96/255, alpha: 1.0)

    /// Floating Card background (#39424E)
    static let cardBackground = UIColor(red: 57/255, green: 66/255, blue: 78/255, alpha: 1.0)

    /// Lighter card row or section background (#353D47)
    static let cardRowBackground = UIColor(red: 53/255, green: 61/255, blue: 71/255, alpha: 1.0)

    /// Gold / Warm Amber action button color (#FFB848)
    static let actionGold = UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0)

    /// Pink / Magenta Trust Code badge accent (#E91E63)
    static let pinkBadgeAccent = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 0.85)

    /// Success checkmark green (#27AE60)
    static let successGreen = UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 1.0)

    /// Alert / Error banner red (#E74C3C)
    static let errorRed = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0)

    /// Text Muted Gray
    static let textMuted = UIColor(white: 0.75, alpha: 1.0)

    /// Underline / Divider Gray
    static let dividerLine = UIColor(white: 1.0, alpha: 0.15)
}
