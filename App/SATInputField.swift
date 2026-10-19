import UIKit

/// High-performance, standardized custom input field component for the SAT iOS application.
/// Consolidates container borders, icon badges, secure password toggles, animated focus states,
/// inline validation feedback, and keyboard toolbars into a single reusable component.
open class SATInputField: UIView, UITextFieldDelegate {

    // MARK: - Callbacks & Handlers
    public var onTextChanged: ((String) -> Void)?
    public var onReturnTapped: (() -> Void)?
    public var onFocusChanged: ((Bool) -> Void)?

    // MARK: - UI Subviews
    public let titleLabel = UILabel()
    public let containerView = UIView()
    public let iconContainer = UIView()
    public let iconImageView = UIImageView()
    public let textField = UITextField()
    public let trailingActionButton = UIButton(type: .system)
    public let underlineIndicator = UIView()
    public let errorLabel = UILabel()

    // MARK: - Configuration Properties
    public var isSecure: Bool = false {
        didSet {
            textField.isSecureTextEntry = isSecure
            trailingActionButton.isHidden = !isSecure
            updateTrailingEyeIcon()
        }
    }

    public var text: String {
        get { return textField.text ?? "" }
        set { textField.text = newValue }
    }

    public var placeholder: String? {
        get { return textField.placeholder }
        set {
            guard let val = newValue else {
                textField.placeholder = nil
                return
            }
            textField.attributedPlaceholder = NSAttributedString(
                string: val,
                attributes: [.foregroundColor: AppTheme.textPlaceholder]
            )
        }
    }

    // MARK: - Initializers
    public init(
        title: String? = nil,
        placeholder: String? = nil,
        systemIcon: String? = nil,
        isSecure: Bool = false
    ) {
        super.init(frame: .zero)
        setupUI()
        
        if let title = title {
            titleLabel.text = title
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
        }
        
        self.placeholder = placeholder
        self.isSecure = isSecure
        
        if let iconName = systemIcon {
            iconImageView.image = UIImage(systemName: iconName)
        }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Layout Setup
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        // 1. Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        titleLabel.font = AppTheme.Typography.captionBold
        addSubview(titleLabel)

        // 2. Container View
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(red: 22/255, green: 28/255, blue: 35/255, alpha: 0.95)
        containerView.layer.cornerRadius = AppTheme.CornerRadius.medium
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = AppTheme.dividerLine.cgColor
        containerView.layer.masksToBounds = true
        addSubview(containerView)

        // 3. Icon Container & Image
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        containerView.addSubview(iconContainer)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = AppTheme.accentSkyBlue
        iconImageView.contentMode = .scaleAspectFit
        iconContainer.addSubview(iconImageView)

        // 4. Text Field
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = .white
        textField.font = AppTheme.Typography.bodyMedium
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        containerView.addSubview(textField)

        // 5. Trailing Action Button (Show/Hide Password)
        trailingActionButton.translatesAutoresizingMaskIntoConstraints = false
        trailingActionButton.tintColor = UIColor.white.withAlphaComponent(0.60)
        trailingActionButton.isHidden = true
        trailingActionButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        containerView.addSubview(trailingActionButton)

        // 6. Active Underline Indicator
        underlineIndicator.translatesAutoresizingMaskIntoConstraints = false
        underlineIndicator.backgroundColor = AppTheme.accentSkyBlue
        underlineIndicator.alpha = 0.0
        containerView.addSubview(underlineIndicator)

        // 7. Error Label
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textColor = AppTheme.errorRed
        errorLabel.font = AppTheme.Typography.captionRegular
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        addSubview(errorLabel)

        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),

            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 48),

            iconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconContainer.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 44),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            trailingActionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            trailingActionButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            trailingActionButton.widthAnchor.constraint(equalToConstant: 36),
            trailingActionButton.heightAnchor.constraint(equalToConstant: 36),

            textField.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: trailingActionButton.leadingAnchor, constant: -4),
            textField.topAnchor.constraint(equalTo: containerView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            underlineIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            underlineIndicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            underlineIndicator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            underlineIndicator.heightAnchor.constraint(equalToConstant: 2.0),

            errorLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Actions
    @objc private func togglePasswordVisibility() {
        AppTheme.triggerHapticFeedback(.light)
        textField.isSecureTextEntry.toggle()
        updateTrailingEyeIcon()
    }

    private func updateTrailingEyeIcon() {
        let iconName = textField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        trailingActionButton.setImage(UIImage(systemName: iconName), for: .normal)
    }

    @objc private func textFieldDidChange() {
        clearError()
        onTextChanged?(textField.text ?? "")
    }

    // MARK: - State & Validation Styling
    public func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false

        UIView.animate(withDuration: 0.2) {
            self.containerView.layer.borderColor = AppTheme.errorRed.cgColor
            self.underlineIndicator.backgroundColor = AppTheme.errorRed
            self.underlineIndicator.alpha = 1.0
        }

        // Tactile warning and subtle shake
        AppTheme.triggerNotificationFeedback(.warning)
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.35
        animation.values = [-8.0, 8.0, -6.0, 6.0, -3.0, 3.0, 0.0]
        containerView.layer.add(animation, forKey: "shake")
    }

    public func clearError() {
        guard !errorLabel.isHidden else { return }
        errorLabel.isHidden = true
        errorLabel.text = nil

        UIView.animate(withDuration: 0.2) {
            self.containerView.layer.borderColor = self.textField.isFirstResponder ? AppTheme.accentSkyBlue.cgColor : AppTheme.dividerLine.cgColor
            self.underlineIndicator.backgroundColor = AppTheme.accentSkyBlue
            self.underlineIndicator.alpha = self.textField.isFirstResponder ? 1.0 : 0.0
        }
    }

    // MARK: - UITextFieldDelegate
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        clearError()
        UIView.animate(withDuration: 0.2) {
            self.containerView.layer.borderColor = AppTheme.accentSkyBlue.cgColor
            self.underlineIndicator.alpha = 1.0
            self.iconImageView.tintColor = AppTheme.accentSkyBlue
        }
        onFocusChanged?(true)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.containerView.layer.borderColor = AppTheme.dividerLine.cgColor
            self.underlineIndicator.alpha = 0.0
            self.iconImageView.tintColor = UIColor.white.withAlphaComponent(0.70)
        }
        onFocusChanged?(false)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturnTapped?()
        return true
    }
}
