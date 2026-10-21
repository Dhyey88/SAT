import UIKit

/// Central design system tokens and styling helpers for the SAT iOS application.
/// Provides consistent colors, typography, elevations, corner radii, and haptic feedback.
struct AppTheme {

    // MARK: - Core Palette
    /// Dark Slate / Charcoal Canvas background (#2E363F)
    static let canvasBackground = UIColor(red: 46/255, green: 54/255, blue: 63/255, alpha: 1.0)

    /// Deep SAT Navy / Android-matched Blue (#163060)
    static let satDeepBlue = UIColor(red: 22/255, green: 48/255, blue: 96/255, alpha: 1.0)

    /// Card Bottom Action Bar Background (#262D35)
    static let cardBottomBar = UIColor(red: 38/255, green: 45/255, blue: 53/255, alpha: 1.0)
    static let cardBackgroundDark = cardBottomBar

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
    static let textPlaceholder = UIColor(red: 140/255, green: 150/255, blue: 160/255, alpha: 1.0)

    /// Underline / Divider Gray
    static let dividerLine = UIColor(white: 1.0, alpha: 0.15)
    static let inputBorderNormal = UIColor(red: 218/255, green: 224/255, blue: 233/255, alpha: 1.0)
    static let inputBorderActive = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)

    // MARK: - Corner Radii Tokens
    struct CornerRadius {
        static let small: CGFloat = 6.0    // Badges, small tags
        static let medium: CGFloat = 10.0  // Text fields, OTP cells, small buttons
        static let large: CGFloat = 14.0   // Modal sheets, dialog containers
        static let xlarge: CGFloat = 16.0  // Floating cards
    }

    // MARK: - Typography Scale (Accessible Dynamic Type Scaling)
    struct Typography {
        static var titleHero: UIFont {
            return UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: UIFont.systemFont(ofSize: 26, weight: .bold))
        }
        static var titleHeader: UIFont {
            return UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 20, weight: .bold))
        }
        static var titleCard: UIFont {
            return UIFontMetrics(forTextStyle: .headline).scaledFont(for: UIFont.systemFont(ofSize: 16, weight: .semibold))
        }
        static var bodyBold: UIFont {
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 15, weight: .bold))
        }
        static var bodyMedium: UIFont {
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 15, weight: .medium))
        }
        static var captionBold: UIFont {
            return UIFontMetrics(forTextStyle: .caption1).scaledFont(for: UIFont.systemFont(ofSize: 13, weight: .bold))
        }
        static var captionMedium: UIFont {
            return UIFontMetrics(forTextStyle: .caption1).scaledFont(for: UIFont.systemFont(ofSize: 13, weight: .medium))
        }
        static var captionRegular: UIFont {
            return UIFontMetrics(forTextStyle: .caption2).scaledFont(for: UIFont.systemFont(ofSize: 13, weight: .regular))
        }
        static var otpDigits: UIFont {
            return UIFontMetrics(forTextStyle: .title1).scaledFont(for: UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .bold))
        }
    }

    // MARK: - Popup & Modal Tokens
    struct PopupTheme {
        static let backdropBlurStyle: UIBlurEffect.Style = .systemUltraThinMaterialDark
        static let cardCornerRadius: CGFloat = 20.0
        static let cardBorderColor: UIColor = UIColor.white.withAlphaComponent(0.12)
        static let cardBorderWidth: CGFloat = 1.0
        static let cardBackgroundDark: UIColor = UIColor(red: 32/255, green: 38/255, blue: 46/255, alpha: 0.97)
        static let shadowRadius: CGFloat = 22.0
        static let shadowOpacity: Float = 0.35
    }

    /// Applies premium elevated shadow and rounded corners for floating popups and dialog cards
    static func applyPopupCardElevation(to view: UIView, cornerRadius: CGFloat = PopupTheme.cardCornerRadius) {
        view.layer.cornerRadius = cornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = PopupTheme.shadowOpacity
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = PopupTheme.shadowRadius
        view.layer.masksToBounds = false
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }

    /// Creates a modern frosted glass blur backdrop view for popups and dialogs
    static func createBlurBackdrop(style: UIBlurEffect.Style = .dark) -> UIVisualEffectView {
        let blur = UIBlurEffect(style: style)
        let effectView = UIVisualEffectView(effect: blur)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        let dimmingOverlay = UIView()
        dimmingOverlay.translatesAutoresizingMaskIntoConstraints = false
        dimmingOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        effectView.contentView.addSubview(dimmingOverlay)
        NSLayoutConstraint.activate([
            dimmingOverlay.topAnchor.constraint(equalTo: effectView.topAnchor),
            dimmingOverlay.leadingAnchor.constraint(equalTo: effectView.leadingAnchor),
            dimmingOverlay.trailingAnchor.constraint(equalTo: effectView.trailingAnchor),
            dimmingOverlay.bottomAnchor.constraint(equalTo: effectView.bottomAnchor)
        ])
        return effectView
    }

    /// Fluid Apple-standard spring presentation for modal popups and dialogs
    static func presentSpringPopup(backdrop: UIView, card: UIView, completion: (() -> Void)? = nil) {
        backdrop.alpha = 0
        backdrop.isHidden = false
        card.alpha = 0
        card.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        triggerHapticFeedback(.light)

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.6,
            options: [.curveEaseOut],
            animations: {
                backdrop.alpha = 1.0
                card.alpha = 1.0
                card.transform = .identity
            },
            completion: { _ in completion?() }
        )
    }

    /// Smooth spring scale-down dismissal for modal popups and dialogs
    static func dismissSpringPopup(backdrop: UIView, card: UIView, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                backdrop.alpha = 0
                card.alpha = 0
                card.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            },
            completion: { _ in
                backdrop.isHidden = true
                card.transform = .identity
                completion?()
            }
        )
    }

    // MARK: - Elevation & Shadow Helpers
    /// Applies a smooth, modern drop shadow to floating cards without clipping
    /// Optimizes GPU rendering by enabling layer rasterization to eliminate dynamic off-screen render passes during scrolling.
    static func applyCardElevation(to view: UIView, cornerRadius: CGFloat = CornerRadius.xlarge) {
        view.layer.cornerRadius = cornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.18
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 14
        view.layer.masksToBounds = false
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }

    /// Applies subtle button elevation with GPU rasterization optimization
    static func applyButtonElevation(to button: UIButton) {
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.20
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 4
        button.layer.masksToBounds = false
        button.layer.shouldRasterize = true
        button.layer.rasterizationScale = UIScreen.main.scale
    }

    /// Updates shadowPath dynamically for explicit bounds to achieve zero-overhead GPU shadow rendering
    static func updateShadowPath(for layer: CALayer, bounds: CGRect, cornerRadius: CGFloat) {
        guard !bounds.isEmpty else { return }
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }

    static func updateShadowPath(for view: UIView, cornerRadius: CGFloat) {
        updateShadowPath(for: view.layer, bounds: view.bounds, cornerRadius: cornerRadius)
    }

    // MARK: - Pre-warmed Static Haptic Feedback Generators (Zero Allocation Churn)
    private static let lightImpactFeedback: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        return generator
    }()

    private static let mediumImpactFeedback: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        return generator
    }()

    private static let heavyImpactFeedback: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        return generator
    }()

    private static let notificationFeedback: UINotificationFeedbackGenerator = {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        return generator
    }()

    /// Triggers native tactile haptic feedback for user interactions
    static func triggerHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let applyBlock = {
            let generator: UIImpactFeedbackGenerator
            switch style {
            case .light:
                generator = lightImpactFeedback
            case .medium:
                generator = mediumImpactFeedback
            case .heavy:
                generator = heavyImpactFeedback
            case .soft:
                generator = lightImpactFeedback
            case .rigid:
                generator = heavyImpactFeedback
            @unknown default:
                generator = lightImpactFeedback
            }
            generator.prepare()
            generator.impactOccurred()
        }

        if Thread.isMainThread {
            applyBlock()
        } else {
            DispatchQueue.main.async(execute: applyBlock)
        }
    }

    static func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        triggerHapticFeedback(style)
    }

    static func triggerHapticFeedback(notificationType: UINotificationFeedbackGenerator.FeedbackType) {
        triggerNotificationFeedback(notificationType)
    }

    static func triggerNotificationFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let applyBlock = {
            notificationFeedback.prepare()
            notificationFeedback.notificationOccurred(type)
        }

        if Thread.isMainThread {
            applyBlock()
        } else {
            DispatchQueue.main.async(execute: applyBlock)
        }
    }
}

// MARK: - SATCardView (Zero-Overhead GPU Shadow Path Management)
open class SATCardView: UIView {
    public var cardCornerRadius: CGFloat = AppTheme.CornerRadius.xlarge {
        didSet {
            layer.cornerRadius = cardCornerRadius
            setNeedsLayout()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        AppTheme.applyCardElevation(to: self, cornerRadius: cardCornerRadius)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        AppTheme.updateShadowPath(for: self, cornerRadius: cardCornerRadius)
    }
}

// MARK: - SATButton (Spring Press Micro-Interactions & GPU Shadow Path)
open class SATButton: UIButton {
    public var enableMicroInteraction: Bool = true

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupInteractions()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupInteractions()
    }

    private func setupInteractions() {
        addTarget(self, action: #selector(handleTouchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
    }

    @objc private func handleTouchDown() {
        guard enableMicroInteraction else { return }
        AppTheme.triggerHapticFeedback(.light)
        UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }

    @objc private func handleTouchUp() {
        guard enableMicroInteraction else { return }
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.allowUserInteraction]) {
            self.transform = .identity
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        if layer.shadowOpacity > 0 {
            AppTheme.updateShadowPath(for: self, cornerRadius: layer.cornerRadius)
        }
    }
}

