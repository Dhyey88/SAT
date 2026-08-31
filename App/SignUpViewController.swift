import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    var onSignUpSuccess: ((String) -> Void)?

    // MARK: - Validation & Progressive Data State
    private var verifiedMerchantId: Int = 6
    private var verifiedMerchantName: String = "SHRI ANANDPUR TRUST"
    private var verifiedRoleId: Int = 0

    private var isTrustCodeVerified = false
    private var isEmailVerified = false
    private var isMobileVerified = false

    // Countdown Timer for OTP Dialog
    private var otpTimer: Timer?
    private var otpRemainingSeconds = 30

    // MARK: - Main UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let headerTitleLabel = UILabel()
    private let errorBanner = UIView()
    private let errorLabel = UILabel()

    // White Main Card & Bottom Bar
    private let cardContainer = UIView()
    private let cardContentStack = UIStackView()
    private let bottomActionBar = UIView()
    private let cancelButton = UIButton(type: .system)
    private let registerBranchButton = UIButton(type: .system)
    private let actionSpinner = UIActivityIndicatorView(style: .medium)
    private let versionLabel = UILabel()

    // MARK: - Row 1: Trust/Institution Code
    private let trustRowView = UIView()
    private let trustBadgeIcon = UIView()
    private let trustBadgeSubIcon = UIImageView()
    private let trustTitleLabel = UILabel()
    private let trustCodeField = UITextField()
    private let trustUnderline = UIView()
    private let trustCheckmark = UIImageView()
    private let trustArrowButton = UIButton(type: .system)
    private let trustInfoButton = UIButton(type: .system)
    private let trustSpinner = UIActivityIndicatorView(style: .medium)

    // MARK: - Row 2: Center Circular Emblem Logo
    private let emblemContainer = UIView()
    private let emblemImageView = UIImageView()

    // MARK: - Row 3: Email
    private let emailRowView = UIView()
    private let emailIcon = UIImageView()
    private let emailTitleLabel = UILabel()
    private let emailField = UITextField()
    private let emailUnderline = UIView()
    private let emailCheckmark = UIImageView()
    private let emailSpinner = UIActivityIndicatorView(style: .medium)

    // MARK: - Row 4: Mobile Phone
    private let mobileRowView = UIView()
    private let mobileIcon = UIImageView()
    private let mobileTitleLabel = UILabel()
    private let mobileField = UITextField()
    private let mobileUnderline = UIView()
    private let mobileCheckmark = UIImageView()
    private let mobileArrowButton = UIButton(type: .system)
    private let mobileInfoButton = UIButton(type: .system)
    private let mobileSpinner = UIActivityIndicatorView(style: .medium)

    // MARK: - Row 5: Enter Main/Parent Branch Code#
    private let parentRowView = UIView()
    private let parentIcon = UIImageView()
    private let parentTitleLabel = UILabel()
    private let parentCodeField = UITextField()
    private let parentUnderline = UIView()
    private let parentArrowButton = UIButton(type: .system)
    private let parentInfoButton = UIButton(type: .system)
    private let parentSpinner = UIActivityIndicatorView(style: .medium)

    // MARK: - Floating OTP Verification Modal Dialog (Screenshot 3)
    private let otpOverlayBackdrop = UIView()
    private let otpCardContainer = UIView()
    private let otpTitleLabel = UILabel()
    private let otpInputField = UITextField()
    private let otpUnderline = UIView()
    private let otpErrorLabel = UILabel()
    private let otpTimerLabel = UILabel()
    private let otpResendButton = UIButton(type: .system)
    private let otpCancelButton = UIButton(type: .system)
    private let otpVerifyButton = UIButton(type: .system)
    private let otpSpinner = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
        setupOTPDialogUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    deinit {
        otpTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Main Layout
    private func setupUI() {
        // Deep Royal Blue Canvas (#133B7C)
        view.backgroundColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)

        // 1. Scroll & Content View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // 2. Top "Sign Up" Header
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.text = "Sign Up"
        headerTitleLabel.textColor = .white
        headerTitleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        headerTitleLabel.textAlignment = .center
        contentView.addSubview(headerTitleLabel)

        // 3. Error Banner (Appears dynamically upon validation failure)
        errorBanner.translatesAutoresizingMaskIntoConstraints = false
        errorBanner.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 0.95)
        errorBanner.layer.cornerRadius = 6
        errorBanner.layer.masksToBounds = true
        errorBanner.isHidden = true
        contentView.addSubview(errorBanner)

        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textColor = .white
        errorLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorBanner.addSubview(errorLabel)

        // 4. White Card Container
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.backgroundColor = .white
        cardContainer.layer.cornerRadius = 18
        cardContainer.layer.masksToBounds = true
        contentView.addSubview(cardContainer)

        // Card Content Stack (Vertical UIStackView for flawless dynamic expansion)
        cardContentStack.translatesAutoresizingMaskIntoConstraints = false
        cardContentStack.axis = .vertical
        cardContentStack.spacing = 16
        cardContentStack.alignment = .fill
        cardContentStack.distribution = .fill
        cardContainer.addSubview(cardContentStack)

        // Build All Progressive Rows
        buildTrustRow()
        buildEmblemRow()
        buildEmailRow()
        buildMobileRow()
        buildParentRow()

        // Build Card Bottom Action Bar
        buildBottomActionBar()

        // 5. Version Label (Bottom Right: "v t 2.0.10")
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.text = "v t 2.0.10"
        versionLabel.textColor = UIColor.white.withAlphaComponent(0.65)
        versionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        versionLabel.textAlignment = .right
        view.addSubview(versionLabel)

        // Main Layout Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            headerTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            headerTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            errorBanner.topAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 10),
            errorBanner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            errorBanner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            errorLabel.topAnchor.constraint(equalTo: errorBanner.topAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: errorBanner.leadingAnchor, constant: 12),
            errorLabel.trailingAnchor.constraint(equalTo: errorBanner.trailingAnchor, constant: -12),
            errorLabel.bottomAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: -8),

            cardContainer.topAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: 12),
            cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50),

            cardContentStack.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 20),
            cardContentStack.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 18),
            cardContentStack.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -18),

            bottomActionBar.topAnchor.constraint(equalTo: cardContentStack.bottomAnchor, constant: 20),
            bottomActionBar.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            bottomActionBar.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            bottomActionBar.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor),
            bottomActionBar.heightAnchor.constraint(equalToConstant: 54),

            versionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    // MARK: - Row 1: Trust/Institution Code
    private func buildTrustRow() {
        trustRowView.translatesAutoresizingMaskIntoConstraints = false

        // Pink ID Badge Icon
        trustBadgeIcon.translatesAutoresizingMaskIntoConstraints = false
        trustBadgeIcon.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 0.85) // Pink
        trustBadgeIcon.layer.cornerRadius = 6
        trustBadgeIcon.layer.masksToBounds = true
        trustRowView.addSubview(trustBadgeIcon)

        trustBadgeSubIcon.translatesAutoresizingMaskIntoConstraints = false
        trustBadgeSubIcon.image = UIImage(systemName: "person.crop.rectangle.fill") ?? UIImage(systemName: "person.fill")
        trustBadgeSubIcon.tintColor = .white
        trustBadgeSubIcon.contentMode = .scaleAspectFit
        trustBadgeIcon.addSubview(trustBadgeSubIcon)

        // Label: "Trust/Institution code*"
        trustTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        trustTitleLabel.attributedText = createRequiredLabel("Trust/Institution code")
        trustRowView.addSubview(trustTitleLabel)

        // Text Input
        trustCodeField.translatesAutoresizingMaskIntoConstraints = false
        trustCodeField.placeholder = "Type your trust code"
        trustCodeField.text = "SAT6677"
        trustCodeField.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        trustCodeField.font = UIFont.systemFont(ofSize: 15.5, weight: .semibold)
        trustCodeField.autocapitalizationType = .allCharacters
        trustCodeField.autocorrectionType = .no
        trustCodeField.returnKeyType = .done
        trustCodeField.delegate = self
        trustCodeField.addTarget(self, action: #selector(trustCodeEditingChanged), for: .editingChanged)
        trustRowView.addSubview(trustCodeField)

        // Blue Underline
        trustUnderline.translatesAutoresizingMaskIntoConstraints = false
        trustUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        trustRowView.addSubview(trustUnderline)

        // Green Checkmark
        trustCheckmark.translatesAutoresizingMaskIntoConstraints = false
        trustCheckmark.image = UIImage(systemName: "checkmark")
        trustCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        trustCheckmark.isHidden = true
        trustRowView.addSubview(trustCheckmark)

        // Arrow Button
        trustArrowButton.translatesAutoresizingMaskIntoConstraints = false
        trustArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        trustArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        trustArrowButton.addTarget(self, action: #selector(handleTrustCodeSubmit), for: .touchUpInside)
        trustRowView.addSubview(trustArrowButton)

        // Info Button
        trustInfoButton.translatesAutoresizingMaskIntoConstraints = false
        trustInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        trustInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        trustInfoButton.addTarget(self, action: #selector(showTrustInfo), for: .touchUpInside)
        trustRowView.addSubview(trustInfoButton)

        // Spinner
        trustSpinner.translatesAutoresizingMaskIntoConstraints = false
        trustSpinner.hidesWhenStopped = true
        trustSpinner.color = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        trustRowView.addSubview(trustSpinner)

        NSLayoutConstraint.activate([
            trustBadgeIcon.leadingAnchor.constraint(equalTo: trustRowView.leadingAnchor),
            trustBadgeIcon.topAnchor.constraint(equalTo: trustRowView.topAnchor, constant: 4),
            trustBadgeIcon.widthAnchor.constraint(equalToConstant: 34),
            trustBadgeIcon.heightAnchor.constraint(equalToConstant: 24),

            trustBadgeSubIcon.centerXAnchor.constraint(equalTo: trustBadgeIcon.centerXAnchor),
            trustBadgeSubIcon.centerYAnchor.constraint(equalTo: trustBadgeIcon.centerYAnchor),
            trustBadgeSubIcon.widthAnchor.constraint(equalToConstant: 20),
            trustBadgeSubIcon.heightAnchor.constraint(equalToConstant: 16),

            trustTitleLabel.leadingAnchor.constraint(equalTo: trustBadgeIcon.trailingAnchor, constant: 12),
            trustTitleLabel.topAnchor.constraint(equalTo: trustRowView.topAnchor),

            trustCodeField.leadingAnchor.constraint(equalTo: trustBadgeIcon.trailingAnchor, constant: 12),
            trustCodeField.topAnchor.constraint(equalTo: trustTitleLabel.bottomAnchor, constant: 4),
            trustCodeField.trailingAnchor.constraint(equalTo: trustCheckmark.leadingAnchor, constant: -8),
            trustCodeField.heightAnchor.constraint(equalToConstant: 28),

            trustUnderline.leadingAnchor.constraint(equalTo: trustCodeField.leadingAnchor),
            trustUnderline.trailingAnchor.constraint(equalTo: trustCodeField.trailingAnchor),
            trustUnderline.topAnchor.constraint(equalTo: trustCodeField.bottomAnchor, constant: 2),
            trustUnderline.heightAnchor.constraint(equalToConstant: 1.5),
            trustUnderline.bottomAnchor.constraint(equalTo: trustRowView.bottomAnchor, constant: -2),

            trustInfoButton.trailingAnchor.constraint(equalTo: trustRowView.trailingAnchor),
            trustInfoButton.centerYAnchor.constraint(equalTo: trustBadgeIcon.centerYAnchor),
            trustInfoButton.widthAnchor.constraint(equalToConstant: 26),
            trustInfoButton.heightAnchor.constraint(equalToConstant: 26),

            trustArrowButton.trailingAnchor.constraint(equalTo: trustInfoButton.leadingAnchor, constant: -6),
            trustArrowButton.centerYAnchor.constraint(equalTo: trustBadgeIcon.centerYAnchor),
            trustArrowButton.widthAnchor.constraint(equalToConstant: 26),
            trustArrowButton.heightAnchor.constraint(equalToConstant: 26),

            trustCheckmark.trailingAnchor.constraint(equalTo: trustArrowButton.leadingAnchor, constant: -6),
            trustCheckmark.centerYAnchor.constraint(equalTo: trustBadgeIcon.centerYAnchor),
            trustCheckmark.widthAnchor.constraint(equalToConstant: 20),
            trustCheckmark.heightAnchor.constraint(equalToConstant: 20),

            trustSpinner.centerXAnchor.constraint(equalTo: trustArrowButton.centerXAnchor),
            trustSpinner.centerYAnchor.constraint(equalTo: trustArrowButton.centerYAnchor)
        ])

        cardContentStack.addArrangedSubview(trustRowView)
    }

    // MARK: - Row 2: Center Circular Emblem Logo (Revealed on Trust Verify)
    private func buildEmblemRow() {
        emblemContainer.translatesAutoresizingMaskIntoConstraints = false
        emblemContainer.isHidden = true // Hidden initially, reveals after Trust verification

        emblemImageView.translatesAutoresizingMaskIntoConstraints = false
        if let emblem = UIImage(named: "trust_emblem") ?? UIImage(named: "AppIcon-1024") ?? UIImage(named: "AppIcon") {
            emblemImageView.image = emblem
        } else {
            emblemImageView.image = UIImage(systemName: "seal.fill")
        }
        emblemImageView.contentMode = .scaleAspectFit
        emblemContainer.addSubview(emblemImageView)

        NSLayoutConstraint.activate([
            emblemImageView.topAnchor.constraint(equalTo: emblemContainer.topAnchor, constant: 4),
            emblemImageView.centerXAnchor.constraint(equalTo: emblemContainer.centerXAnchor),
            emblemImageView.widthAnchor.constraint(equalToConstant: 140),
            emblemImageView.heightAnchor.constraint(equalToConstant: 140),
            emblemImageView.bottomAnchor.constraint(equalTo: emblemContainer.bottomAnchor, constant: -4)
        ])

        cardContentStack.addArrangedSubview(emblemContainer)
    }

    // MARK: - Row 3: Email (Revealed on Trust Verify)
    private func buildEmailRow() {
        emailRowView.translatesAutoresizingMaskIntoConstraints = false
        emailRowView.isHidden = true // Hidden initially

        // Envelope Icon
        emailIcon.translatesAutoresizingMaskIntoConstraints = false
        emailIcon.image = UIImage(systemName: "envelope.fill")
        emailIcon.tintColor = UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0) // Gold
        emailRowView.addSubview(emailIcon)

        // Label: "Email*"
        emailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTitleLabel.attributedText = createRequiredLabel("Email")
        emailRowView.addSubview(emailTitleLabel)

        // Text Input
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.placeholder = "Type your email address"
        emailField.text = "dhyey.k@latitudetechnolabs.org"
        emailField.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        emailField.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.returnKeyType = .next
        emailField.delegate = self
        emailField.addTarget(self, action: #selector(emailEditingChanged), for: .editingChanged)
        emailRowView.addSubview(emailField)

        // Blue Underline
        emailUnderline.translatesAutoresizingMaskIntoConstraints = false
        emailUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        emailRowView.addSubview(emailUnderline)

        // Green Checkmark
        emailCheckmark.translatesAutoresizingMaskIntoConstraints = false
        emailCheckmark.image = UIImage(systemName: "checkmark")
        emailCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        emailCheckmark.isHidden = true
        emailRowView.addSubview(emailCheckmark)

        // Spinner
        emailSpinner.translatesAutoresizingMaskIntoConstraints = false
        emailSpinner.hidesWhenStopped = true
        emailSpinner.color = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        emailRowView.addSubview(emailSpinner)

        NSLayoutConstraint.activate([
            emailIcon.leadingAnchor.constraint(equalTo: emailRowView.leadingAnchor),
            emailIcon.topAnchor.constraint(equalTo: emailRowView.topAnchor, constant: 4),
            emailIcon.widthAnchor.constraint(equalToConstant: 26),
            emailIcon.heightAnchor.constraint(equalToConstant: 20),

            emailTitleLabel.leadingAnchor.constraint(equalTo: emailIcon.trailingAnchor, constant: 12),
            emailTitleLabel.topAnchor.constraint(equalTo: emailRowView.topAnchor),

            emailField.leadingAnchor.constraint(equalTo: emailIcon.trailingAnchor, constant: 12),
            emailField.topAnchor.constraint(equalTo: emailTitleLabel.bottomAnchor, constant: 4),
            emailField.trailingAnchor.constraint(equalTo: emailCheckmark.leadingAnchor, constant: -8),
            emailField.heightAnchor.constraint(equalToConstant: 28),

            emailUnderline.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            emailUnderline.trailingAnchor.constraint(equalTo: emailRowView.trailingAnchor),
            emailUnderline.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 2),
            emailUnderline.heightAnchor.constraint(equalToConstant: 1.5),
            emailUnderline.bottomAnchor.constraint(equalTo: emailRowView.bottomAnchor, constant: -2),

            emailCheckmark.trailingAnchor.constraint(equalTo: emailRowView.trailingAnchor),
            emailCheckmark.centerYAnchor.constraint(equalTo: emailIcon.centerYAnchor),
            emailCheckmark.widthAnchor.constraint(equalToConstant: 20),
            emailCheckmark.heightAnchor.constraint(equalToConstant: 20),

            emailSpinner.centerXAnchor.constraint(equalTo: emailCheckmark.centerXAnchor),
            emailSpinner.centerYAnchor.constraint(equalTo: emailCheckmark.centerYAnchor)
        ])

        cardContentStack.addArrangedSubview(emailRowView)
    }

    // MARK: - Row 4: Mobile Phone (Revealed on Trust Verify)
    private func buildMobileRow() {
        mobileRowView.translatesAutoresizingMaskIntoConstraints = false
        mobileRowView.isHidden = true // Hidden initially

        // Hand Tap Phone Icon
        mobileIcon.translatesAutoresizingMaskIntoConstraints = false
        mobileIcon.image = UIImage(systemName: "hand.tap.fill") ?? UIImage(systemName: "phone.fill")
        mobileIcon.tintColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1.0) // Pink
        mobileRowView.addSubview(mobileIcon)

        // Label: "Mobile phone*"
        mobileTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        mobileTitleLabel.attributedText = createRequiredLabel("Mobile phone")
        mobileRowView.addSubview(mobileTitleLabel)

        // Text Input
        mobileField.translatesAutoresizingMaskIntoConstraints = false
        mobileField.placeholder = "Type your 10-digit mobile"
        mobileField.text = "7990657479"
        mobileField.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        mobileField.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        mobileField.keyboardType = .phonePad
        mobileField.delegate = self
        mobileField.addTarget(self, action: #selector(mobileEditingChanged), for: .editingChanged)
        mobileRowView.addSubview(mobileField)

        // Blue Underline
        mobileUnderline.translatesAutoresizingMaskIntoConstraints = false
        mobileUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        mobileRowView.addSubview(mobileUnderline)

        // Green Checkmark
        mobileCheckmark.translatesAutoresizingMaskIntoConstraints = false
        mobileCheckmark.image = UIImage(systemName: "checkmark")
        mobileCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        mobileCheckmark.isHidden = true
        mobileRowView.addSubview(mobileCheckmark)

        // Arrow Button (Dispatches OTP)
        mobileArrowButton.translatesAutoresizingMaskIntoConstraints = false
        mobileArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        mobileArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        mobileArrowButton.addTarget(self, action: #selector(handleMobileSubmitAndSendOTP), for: .touchUpInside)
        mobileRowView.addSubview(mobileArrowButton)

        // Info Button
        mobileInfoButton.translatesAutoresizingMaskIntoConstraints = false
        mobileInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        mobileInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        mobileInfoButton.addTarget(self, action: #selector(showMobileInfo), for: .touchUpInside)
        mobileRowView.addSubview(mobileInfoButton)

        // Spinner
        mobileSpinner.translatesAutoresizingMaskIntoConstraints = false
        mobileSpinner.hidesWhenStopped = true
        mobileSpinner.color = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        mobileRowView.addSubview(mobileSpinner)

        NSLayoutConstraint.activate([
            mobileIcon.leadingAnchor.constraint(equalTo: mobileRowView.leadingAnchor),
            mobileIcon.topAnchor.constraint(equalTo: mobileRowView.topAnchor, constant: 4),
            mobileIcon.widthAnchor.constraint(equalToConstant: 26),
            mobileIcon.heightAnchor.constraint(equalToConstant: 20),

            mobileTitleLabel.leadingAnchor.constraint(equalTo: mobileIcon.trailingAnchor, constant: 12),
            mobileTitleLabel.topAnchor.constraint(equalTo: mobileRowView.topAnchor),

            mobileField.leadingAnchor.constraint(equalTo: mobileIcon.trailingAnchor, constant: 12),
            mobileField.topAnchor.constraint(equalTo: mobileTitleLabel.bottomAnchor, constant: 4),
            mobileField.trailingAnchor.constraint(equalTo: mobileCheckmark.leadingAnchor, constant: -8),
            mobileField.heightAnchor.constraint(equalToConstant: 28),

            mobileUnderline.leadingAnchor.constraint(equalTo: mobileField.leadingAnchor),
            mobileUnderline.trailingAnchor.constraint(equalTo: mobileField.trailingAnchor),
            mobileUnderline.topAnchor.constraint(equalTo: mobileField.bottomAnchor, constant: 2),
            mobileUnderline.heightAnchor.constraint(equalToConstant: 1.5),
            mobileUnderline.bottomAnchor.constraint(equalTo: mobileRowView.bottomAnchor, constant: -2),

            mobileInfoButton.trailingAnchor.constraint(equalTo: mobileRowView.trailingAnchor),
            mobileInfoButton.centerYAnchor.constraint(equalTo: mobileIcon.centerYAnchor),
            mobileInfoButton.widthAnchor.constraint(equalToConstant: 26),
            mobileInfoButton.heightAnchor.constraint(equalToConstant: 26),

            mobileArrowButton.trailingAnchor.constraint(equalTo: mobileInfoButton.leadingAnchor, constant: -6),
            mobileArrowButton.centerYAnchor.constraint(equalTo: mobileIcon.centerYAnchor),
            mobileArrowButton.widthAnchor.constraint(equalToConstant: 26),
            mobileArrowButton.heightAnchor.constraint(equalToConstant: 26),

            mobileCheckmark.trailingAnchor.constraint(equalTo: mobileArrowButton.leadingAnchor, constant: -6),
            mobileCheckmark.centerYAnchor.constraint(equalTo: mobileIcon.centerYAnchor),
            mobileCheckmark.widthAnchor.constraint(equalToConstant: 20),
            mobileCheckmark.heightAnchor.constraint(equalToConstant: 20),

            mobileSpinner.centerXAnchor.constraint(equalTo: mobileArrowButton.centerXAnchor),
            mobileSpinner.centerYAnchor.constraint(equalTo: mobileArrowButton.centerYAnchor)
        ])

        cardContentStack.addArrangedSubview(mobileRowView)
    }

    // MARK: - Row 5: Enter Main/Parent Branch Code# (Revealed on OTP Verify)
    private func buildParentRow() {
        parentRowView.translatesAutoresizingMaskIntoConstraints = false
        parentRowView.isHidden = true // Hidden initially

        // Businessman Avatar Icon
        parentIcon.translatesAutoresizingMaskIntoConstraints = false
        parentIcon.image = UIImage(systemName: "person.crop.circle.badge.checkmark") ?? UIImage(systemName: "person.fill")
        parentIcon.tintColor = UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0)
        parentRowView.addSubview(parentIcon)

        // Label: "Enter Main/Parent Branch Code#"
        parentTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        parentTitleLabel.attributedText = createRequiredLabel("Enter Main/Parent Branch Code#")
        parentRowView.addSubview(parentTitleLabel)

        // Text Input
        parentCodeField.translatesAutoresizingMaskIntoConstraints = false
        parentCodeField.placeholder = "0000"
        parentCodeField.text = "6"
        parentCodeField.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        parentCodeField.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        parentCodeField.keyboardType = .asciiCapable
        parentCodeField.delegate = self
        parentCodeField.addTarget(self, action: #selector(parentEditingChanged), for: .editingChanged)
        parentRowView.addSubview(parentCodeField)

        // Blue Underline
        parentUnderline.translatesAutoresizingMaskIntoConstraints = false
        parentUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        parentRowView.addSubview(parentUnderline)

        // Arrow Button
        parentArrowButton.translatesAutoresizingMaskIntoConstraints = false
        parentArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        parentArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        parentArrowButton.addTarget(self, action: #selector(handleRegisterBranch), for: .touchUpInside)
        parentRowView.addSubview(parentArrowButton)

        // Info Button
        parentInfoButton.translatesAutoresizingMaskIntoConstraints = false
        parentInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        parentInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        parentInfoButton.addTarget(self, action: #selector(showParentInfo), for: .touchUpInside)
        parentRowView.addSubview(parentInfoButton)

        // Spinner
        parentSpinner.translatesAutoresizingMaskIntoConstraints = false
        parentSpinner.hidesWhenStopped = true
        parentSpinner.color = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        parentRowView.addSubview(parentSpinner)

        NSLayoutConstraint.activate([
            parentIcon.leadingAnchor.constraint(equalTo: parentRowView.leadingAnchor),
            parentIcon.topAnchor.constraint(equalTo: parentRowView.topAnchor, constant: 4),
            parentIcon.widthAnchor.constraint(equalToConstant: 26),
            parentIcon.heightAnchor.constraint(equalToConstant: 20),

            parentTitleLabel.leadingAnchor.constraint(equalTo: parentIcon.trailingAnchor, constant: 12),
            parentTitleLabel.topAnchor.constraint(equalTo: parentRowView.topAnchor),

            parentCodeField.leadingAnchor.constraint(equalTo: parentIcon.trailingAnchor, constant: 12),
            parentCodeField.topAnchor.constraint(equalTo: parentTitleLabel.bottomAnchor, constant: 4),
            parentCodeField.trailingAnchor.constraint(equalTo: parentArrowButton.leadingAnchor, constant: -8),
            parentCodeField.heightAnchor.constraint(equalToConstant: 28),

            parentUnderline.leadingAnchor.constraint(equalTo: parentCodeField.leadingAnchor),
            parentUnderline.trailingAnchor.constraint(equalTo: parentCodeField.trailingAnchor),
            parentUnderline.topAnchor.constraint(equalTo: parentCodeField.bottomAnchor, constant: 2),
            parentUnderline.heightAnchor.constraint(equalToConstant: 1.5),
            parentUnderline.bottomAnchor.constraint(equalTo: parentRowView.bottomAnchor, constant: -2),

            parentInfoButton.trailingAnchor.constraint(equalTo: parentRowView.trailingAnchor),
            parentInfoButton.centerYAnchor.constraint(equalTo: parentIcon.centerYAnchor),
            parentInfoButton.widthAnchor.constraint(equalToConstant: 26),
            parentInfoButton.heightAnchor.constraint(equalToConstant: 26),

            parentArrowButton.trailingAnchor.constraint(equalTo: parentInfoButton.leadingAnchor, constant: -6),
            parentArrowButton.centerYAnchor.constraint(equalTo: parentIcon.centerYAnchor),
            parentArrowButton.widthAnchor.constraint(equalToConstant: 26),
            parentArrowButton.heightAnchor.constraint(equalToConstant: 26),

            parentSpinner.centerXAnchor.constraint(equalTo: parentArrowButton.centerXAnchor),
            parentSpinner.centerYAnchor.constraint(equalTo: parentArrowButton.centerYAnchor)
        ])

        cardContentStack.addArrangedSubview(parentRowView)
    }

    // MARK: - Card Bottom Action Bar (Cancel & Register Branch ➔)
    private func buildBottomActionBar() {
        bottomActionBar.translatesAutoresizingMaskIntoConstraints = false
        bottomActionBar.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0) // #4184D6

        // Cancel Button (Left)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cancelButton.addTarget(self, action: #selector(handleCancelTap), for: .touchUpInside)
        bottomActionBar.addSubview(cancelButton)

        // Register Branch Button (Right - Visible after OTP verify)
        registerBranchButton.translatesAutoresizingMaskIntoConstraints = false
        registerBranchButton.setTitle("Register Branch  ➔", for: .normal)
        registerBranchButton.setTitleColor(.white, for: .normal)
        registerBranchButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        registerBranchButton.isHidden = true // Revealed after OTP verification
        registerBranchButton.addTarget(self, action: #selector(handleRegisterBranch), for: .touchUpInside)
        bottomActionBar.addSubview(registerBranchButton)

        actionSpinner.translatesAutoresizingMaskIntoConstraints = false
        actionSpinner.hidesWhenStopped = true
        actionSpinner.color = .white
        bottomActionBar.addSubview(actionSpinner)

        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: bottomActionBar.leadingAnchor, constant: 20),
            cancelButton.centerYAnchor.constraint(equalTo: bottomActionBar.centerYAnchor),

            registerBranchButton.trailingAnchor.constraint(equalTo: bottomActionBar.trailingAnchor, constant: -20),
            registerBranchButton.centerYAnchor.constraint(equalTo: bottomActionBar.centerYAnchor),

            actionSpinner.centerYAnchor.constraint(equalTo: registerBranchButton.centerYAnchor),
            actionSpinner.centerXAnchor.constraint(equalTo: registerBranchButton.centerXAnchor)
        ])
    }

    // MARK: - Floating OTP Modal Dialog (Screenshot 3)
    private func setupOTPDialogUI() {
        otpOverlayBackdrop.translatesAutoresizingMaskIntoConstraints = false
        otpOverlayBackdrop.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        otpOverlayBackdrop.isHidden = true
        view.addSubview(otpOverlayBackdrop)

        otpCardContainer.translatesAutoresizingMaskIntoConstraints = false
        otpCardContainer.backgroundColor = UIColor(red: 21/255, green: 64/255, blue: 141/255, alpha: 1.0) // #15408D
        otpCardContainer.layer.cornerRadius = 14
        otpCardContainer.layer.masksToBounds = true
        otpOverlayBackdrop.addSubview(otpCardContainer)

        otpTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        otpTitleLabel.text = "OTP Verification"
        otpTitleLabel.textColor = .white
        otpTitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        otpTitleLabel.textAlignment = .center
        otpCardContainer.addSubview(otpTitleLabel)

        otpInputField.translatesAutoresizingMaskIntoConstraints = false
        otpInputField.attributedPlaceholder = NSAttributedString(
            string: "Enter OTP",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
        )
        otpInputField.textColor = .white
        otpInputField.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        otpInputField.keyboardType = .numberPad
        otpInputField.textAlignment = .left
        otpCardContainer.addSubview(otpInputField)

        otpUnderline.translatesAutoresizingMaskIntoConstraints = false
        otpUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        otpCardContainer.addSubview(otpUnderline)

        otpErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        otpErrorLabel.textColor = UIColor(red: 255/255, green: 107/255, blue: 107/255, alpha: 1.0)
        otpErrorLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        otpErrorLabel.textAlignment = .center
        otpErrorLabel.isHidden = true
        otpCardContainer.addSubview(otpErrorLabel)

        otpTimerLabel.translatesAutoresizingMaskIntoConstraints = false
        otpTimerLabel.text = "00 : 30"
        otpTimerLabel.textColor = .white
        otpTimerLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        otpCardContainer.addSubview(otpTimerLabel)

        otpResendButton.translatesAutoresizingMaskIntoConstraints = false
        otpResendButton.setTitle("Resend OTP", for: .normal)
        otpResendButton.setTitleColor(UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0), for: .normal)
        otpResendButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        otpResendButton.isHidden = true
        otpResendButton.addTarget(self, action: #selector(handleResendOTP), for: .touchUpInside)
        otpCardContainer.addSubview(otpResendButton)

        otpCancelButton.translatesAutoresizingMaskIntoConstraints = false
        otpCancelButton.setTitle("Cancel", for: .normal)
        otpCancelButton.setTitleColor(.white, for: .normal)
        otpCancelButton.backgroundColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 0.75) // #27A9E3
        otpCancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        otpCancelButton.layer.cornerRadius = 4
        otpCancelButton.addTarget(self, action: #selector(handleCancelOTP), for: .touchUpInside)
        otpCardContainer.addSubview(otpCancelButton)

        otpVerifyButton.translatesAutoresizingMaskIntoConstraints = false
        otpVerifyButton.setTitle("Verify OTP", for: .normal)
        otpVerifyButton.setTitleColor(.white, for: .normal)
        otpVerifyButton.backgroundColor = UIColor(red: 2/255, green: 136/255, blue: 209/255, alpha: 1.0) // #0288D1
        otpVerifyButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        otpVerifyButton.layer.cornerRadius = 4
        otpVerifyButton.addTarget(self, action: #selector(handleVerifyOTP), for: .touchUpInside)
        otpCardContainer.addSubview(otpVerifyButton)

        otpSpinner.translatesAutoresizingMaskIntoConstraints = false
        otpSpinner.hidesWhenStopped = true
        otpSpinner.color = .white
        otpCardContainer.addSubview(otpSpinner)

        NSLayoutConstraint.activate([
            otpOverlayBackdrop.topAnchor.constraint(equalTo: view.topAnchor),
            otpOverlayBackdrop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            otpOverlayBackdrop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            otpOverlayBackdrop.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            otpCardContainer.centerYAnchor.constraint(equalTo: otpOverlayBackdrop.centerYAnchor, constant: -30),
            otpCardContainer.leadingAnchor.constraint(equalTo: otpOverlayBackdrop.leadingAnchor, constant: 24),
            otpCardContainer.trailingAnchor.constraint(equalTo: otpOverlayBackdrop.trailingAnchor, constant: -24),

            otpTitleLabel.topAnchor.constraint(equalTo: otpCardContainer.topAnchor, constant: 20),
            otpTitleLabel.centerXAnchor.constraint(equalTo: otpCardContainer.centerXAnchor),

            otpInputField.topAnchor.constraint(equalTo: otpTitleLabel.bottomAnchor, constant: 22),
            otpInputField.leadingAnchor.constraint(equalTo: otpCardContainer.leadingAnchor, constant: 20),
            otpInputField.trailingAnchor.constraint(equalTo: otpCardContainer.trailingAnchor, constant: -20),
            otpInputField.heightAnchor.constraint(equalToConstant: 32),

            otpUnderline.topAnchor.constraint(equalTo: otpInputField.bottomAnchor, constant: 4),
            otpUnderline.leadingAnchor.constraint(equalTo: otpInputField.leadingAnchor),
            otpUnderline.trailingAnchor.constraint(equalTo: otpInputField.trailingAnchor),
            otpUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            otpErrorLabel.topAnchor.constraint(equalTo: otpUnderline.bottomAnchor, constant: 4),
            otpErrorLabel.leadingAnchor.constraint(equalTo: otpCardContainer.leadingAnchor, constant: 16),
            otpErrorLabel.trailingAnchor.constraint(equalTo: otpCardContainer.trailingAnchor, constant: -16),

            otpTimerLabel.topAnchor.constraint(equalTo: otpErrorLabel.bottomAnchor, constant: 10),
            otpTimerLabel.leadingAnchor.constraint(equalTo: otpCardContainer.leadingAnchor, constant: 20),

            otpResendButton.centerYAnchor.constraint(equalTo: otpTimerLabel.centerYAnchor),
            otpResendButton.trailingAnchor.constraint(equalTo: otpCardContainer.trailingAnchor, constant: -20),

            otpCancelButton.topAnchor.constraint(equalTo: otpTimerLabel.bottomAnchor, constant: 20),
            otpCancelButton.leadingAnchor.constraint(equalTo: otpCardContainer.leadingAnchor, constant: 16),
            otpCancelButton.widthAnchor.constraint(equalToConstant: 90),
            otpCancelButton.heightAnchor.constraint(equalToConstant: 38),
            otpCancelButton.bottomAnchor.constraint(equalTo: otpCardContainer.bottomAnchor, constant: -18),

            otpVerifyButton.topAnchor.constraint(equalTo: otpTimerLabel.bottomAnchor, constant: 20),
            otpVerifyButton.trailingAnchor.constraint(equalTo: otpCardContainer.trailingAnchor, constant: -16),
            otpVerifyButton.widthAnchor.constraint(equalToConstant: 110),
            otpVerifyButton.heightAnchor.constraint(equalToConstant: 38),

            otpSpinner.centerYAnchor.constraint(equalTo: otpVerifyButton.centerYAnchor),
            otpSpinner.centerXAnchor.constraint(equalTo: otpVerifyButton.centerXAnchor)
        ])
    }

    private func createRequiredLabel(_ text: String) -> NSAttributedString {
        let attr = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14.5, weight: .bold),
                .foregroundColor: UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
            ]
        )
        attr.append(NSAttributedString(
            string: "*",
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .bold),
                .foregroundColor: UIColor(red: 220/255, green: 53/255, blue: 69/255, alpha: 1.0) // Red
            ]
        ))
        return attr
    }

    // MARK: - Error Helpers & Dynamic Extraction
    private func extractMessage(from json: [String: Any], fallback: String) -> String {
        if let msg = json["message"] as? String, !msg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return msg
        }
        if let err = json["error"] as? String, !err.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return err
        }
        if let dataObj = json["data"] as? [String: Any] {
            if let msg = dataObj["message"] as? String, !msg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return msg
            }
            if let err = dataObj["error"] as? String, !err.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return err
            }
        }
        if let respObj = json["response"] as? [String: Any] {
            if let msg = respObj["message"] as? String, !msg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return msg
            }
            if let err = respObj["error"] as? String, !err.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return err
            }
        }
        return fallback
    }

    private func showBannerError(_ msg: String) {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        errorLabel.text = msg
        errorBanner.isHidden = false
    }

    private func clearBannerError() {
        errorBanner.isHidden = true
    }

    @objc private func trustCodeEditingChanged() {
        trustUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        trustCheckmark.isHidden = true
        clearBannerError()
    }

    @objc private func emailEditingChanged() {
        emailUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        emailCheckmark.isHidden = true
        clearBannerError()
    }

    @objc private func mobileEditingChanged() {
        mobileUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        mobileCheckmark.isHidden = true
        clearBannerError()
    }

    @objc private func parentEditingChanged() {
        parentUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        clearBannerError()
    }

    // MARK: - Step 1: Trust Code Verification (POST /api/check-trust-code)
    @objc private func handleTrustCodeSubmit() {
        view.endEditing(true)
        let code = trustCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !code.isEmpty else {
            trustUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            showBannerError("Please enter valid trust code. Contact helpline.")
            return
        }

        trustArrowButton.isHidden = true
        trustSpinner.startAnimating()
        clearBannerError()

        guard let url = URL(string: AppConfig.API.checkTrustCode) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(AppConfig.apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let params = ["code": code, "device_type": AppConfig.deviceType, "mobile_device_id": AppConfig.mobileDeviceId]
        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.trustArrowButton.isHidden = false
                self.trustSpinner.stopAnimating()

                if let error = error {
                    self.showBannerError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.showBannerError("Invalid response from server.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let apiMessage = self.extractMessage(from: json, fallback: "Please enter valid trust code. Contact helpline.")

                if status {
                    let dataObj = (json["data"] as? [String: Any]) ?? (json["response"] as? [String: Any]) ?? [:]
                    self.verifiedMerchantId = (dataObj["id"] as? Int) ?? (dataObj["merchant_id"] as? Int) ?? 6
                    self.verifiedMerchantName = (dataObj["name"] as? String) ?? "SHRI ANANDPUR TRUST"
                    self.verifiedRoleId = (dataObj["role_id"] as? Int) ?? 0

                    self.isTrustCodeVerified = true
                    self.trustCheckmark.isHidden = false
                    self.trustUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                    // Expand card smoothly to reveal Logo, Email, and Mobile rows (Screenshot 2)
                    UIView.animate(withDuration: 0.3) {
                        self.emblemContainer.isHidden = false
                        self.emailRowView.isHidden = false
                        self.mobileRowView.isHidden = false
                    }
                    self.emailField.becomeFirstResponder()
                } else {
                    self.trustUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
                    self.showBannerError(apiMessage)
                }
            }
        }.resume()
    }

    // MARK: - Step 2: Mobile Submit & Send OTP (POST /api/register-otp-send)
    @objc private func handleMobileSubmitAndSendOTP() {
        view.endEditing(true)
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let mobile = mobileField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trustCode = trustCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !email.isEmpty, email.contains("@"), email.contains(".") else {
            emailUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            showBannerError("Please enter a valid Email address.")
            return
        }

        guard !mobile.isEmpty, mobile.count == 10 else {
            mobileUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            showBannerError("Please enter a valid 10-digit mobile number.")
            return
        }

        mobileArrowButton.isHidden = true
        mobileSpinner.startAnimating()
        clearBannerError()

        guard let url = URL(string: AppConfig.API.registerOtpSend) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(AppConfig.apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let params: [String: String] = [
            "mobile_no": mobile,
            "email": email,
            "trust_code": trustCode,
            "merchant_id": "\(verifiedMerchantId)",
            "mobile_device_id": AppConfig.mobileDeviceId,
            "device_id": AppConfig.deviceId
        ]
        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.mobileArrowButton.isHidden = false
                self.mobileSpinner.stopAnimating()

                if let error = error {
                    self.showBannerError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.showBannerError("Invalid response from server.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let apiMessage = self.extractMessage(from: json, fallback: "Failed to send OTP. Please check mobile number.")

                if status {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    self.presentOTPDialog()
                } else {
                    self.mobileUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
                    self.showBannerError(apiMessage)
                }
            }
        }.resume()
    }

    // MARK: - Step 3: Present Floating OTP Dialog (Screenshot 3)
    private func presentOTPDialog() {
        otpInputField.text = ""
        otpRemainingSeconds = 30
        otpTimerLabel.text = "00 : 30"
        otpResendButton.isHidden = true
        otpErrorLabel.isHidden = true
        otpOverlayBackdrop.alpha = 0
        otpOverlayBackdrop.isHidden = false

        UIView.animate(withDuration: 0.25) {
            self.otpOverlayBackdrop.alpha = 1.0
        }
        otpInputField.becomeFirstResponder()
        startOTPTimer()
    }

    private func startOTPTimer() {
        otpTimer?.invalidate()
        otpTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.otpRemainingSeconds > 0 {
                self.otpRemainingSeconds -= 1
                self.otpTimerLabel.text = String(format: "00 : %02d", self.otpRemainingSeconds)
            } else {
                timer.invalidate()
                self.otpResendButton.isHidden = false
            }
        }
    }

    @objc private func handleCancelOTP() {
        otpTimer?.invalidate()
        view.endEditing(true)
        UIView.animate(withDuration: 0.2, animations: {
            self.otpOverlayBackdrop.alpha = 0
        }) { _ in
            self.otpOverlayBackdrop.isHidden = true
        }
    }

    @objc private func handleResendOTP() {
        otpResendButton.isHidden = true
        handleMobileSubmitAndSendOTP()
    }

    // MARK: - Step 4: Verify OTP (POST /api/check-register-otp)
    @objc private func handleVerifyOTP() {
        view.endEditing(true)
        let otp = otpInputField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !otp.isEmpty, otp.count == 4 else {
            otpUnderline.backgroundColor = UIColor(red: 255/255, green: 107/255, blue: 107/255, alpha: 1.0)
            otpErrorLabel.text = "Please enter the 4-digit OTP."
            otpErrorLabel.isHidden = false
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }

        let mobile = mobileField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        otpVerifyButton.setTitle("", for: .normal)
        otpSpinner.startAnimating()

        guard let url = URL(string: AppConfig.API.checkRegisterOtp) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(AppConfig.apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let params: [String: String] = [
            "mobile_no": mobile,
            "register_otp": otp,
            "mobile_device_id": AppConfig.mobileDeviceId
        ]
        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.otpSpinner.stopAnimating()
                self.otpVerifyButton.setTitle("Verify OTP", for: .normal)

                if let error = error {
                    self.otpErrorLabel.text = "Network error: \(error.localizedDescription)"
                    self.otpErrorLabel.isHidden = false
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.otpErrorLabel.text = "Invalid response from server."
                    self.otpErrorLabel.isHidden = false
                    return
                }

                let status = json["status"] as? Bool ?? false
                let apiMessage = self.extractMessage(from: json, fallback: "Invalid OTP code entered.")

                if status {
                    self.otpTimer?.invalidate()
                    self.isEmailVerified = true
                    self.isMobileVerified = true

                    self.emailCheckmark.isHidden = false
                    self.mobileCheckmark.isHidden = false

                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

                    // Dismiss Floating OTP Dialog
                    UIView.animate(withDuration: 0.2, animations: {
                        self.otpOverlayBackdrop.alpha = 0
                    }) { _ in
                        self.otpOverlayBackdrop.isHidden = true
                    }

                    // Reveal Row 5 (Parent Branch Code) & Bottom "Register Branch ➔" Button (Screenshot 2)
                    UIView.animate(withDuration: 0.3) {
                        self.parentRowView.isHidden = false
                        self.registerBranchButton.isHidden = false
                    }
                    self.parentCodeField.becomeFirstResponder()
                } else {
                    self.otpUnderline.backgroundColor = UIColor(red: 255/255, green: 107/255, blue: 107/255, alpha: 1.0)
                    self.otpErrorLabel.text = apiMessage
                    self.otpErrorLabel.isHidden = false
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }.resume()
    }

    // MARK: - Step 5: Final Branch Registration (POST /api/register)
    @objc private func handleRegisterBranch() {
        view.endEditing(true)
        let parentCode = parentCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let mobile = mobileField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trustCode = trustCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !parentCode.isEmpty else {
            parentUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            showBannerError("Please enter Main/Parent Branch Code.")
            return
        }

        registerBranchButton.setTitle("", for: .normal)
        actionSpinner.startAnimating()
        clearBannerError()

        guard let url = URL(string: AppConfig.API.register) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(AppConfig.apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let params: [String: String] = [
            "fname": "Branch",
            "lname": "Admin",
            "mobile": mobile,
            "email": email,
            "password": "Password@123",
            "merchant_id": "\(verifiedMerchantId)",
            "trust_code": trustCode,
            "asharm_id": parentCode,
            "device_type": AppConfig.deviceType,
            "device_id": AppConfig.deviceId,
            "mobile_device_id": AppConfig.mobileDeviceId
        ]
        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.actionSpinner.stopAnimating()
                self.registerBranchButton.setTitle("Register Branch  ➔", for: .normal)

                if let error = error {
                    self.showBannerError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.showBannerError("Invalid server response.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let apiMessage = self.extractMessage(from: json, fallback: "Branch registration failed. Please try again.")

                if status {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    let alert = UIAlertController(
                        title: "Registration Successful!",
                        message: "Your branch under \(self.verifiedMerchantName) has been successfully registered.\nYou can now log in.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Log In Now", style: .default) { [weak self] _ in
                        self?.dismiss(animated: true) {
                            self?.onSignUpSuccess?(email)
                        }
                    })
                    self.present(alert, animated: true)
                } else {
                    self.showBannerError(apiMessage)
                }
            }
        }.resume()
    }

    @objc private func handleCancelTap() {
        dismiss(animated: true)
    }

    // MARK: - Info Modals
    @objc private func showTrustInfo() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        showHelpAlert(
            title: "Trust/Institution Code",
            message: "A unique identification code assigned to your trust or branch (e.g. SAT6677). Contact your Trust Head Office if you do not have one."
        )
    }

    @objc private func showMobileInfo() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        showHelpAlert(
            title: "Mobile Phone Verification",
            message: "Enter your 10-digit mobile number to receive a secure One-Time Password (OTP) for account verification."
        )
    }

    @objc private func showParentInfo() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        showHelpAlert(
            title: "Main/Parent Branch Code",
            message: "Enter the code or ID of your parent Head Office branch (e.g. 6 or SAT6677)."
        )
    }

    private func showHelpAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Keyboard Handling
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let kbFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = kbFrame.height + 20
        scrollView.verticalScrollIndicatorInsets.bottom = kbFrame.height
    }

    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == trustCodeField {
            handleTrustCodeSubmit()
        } else if textField == emailField {
            mobileField.becomeFirstResponder()
        } else if textField == mobileField {
            handleMobileSubmitAndSendOTP()
        } else if textField == parentCodeField {
            handleRegisterBranch()
        }
        return true
    }
}
