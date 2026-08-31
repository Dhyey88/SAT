import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    var onSignUpSuccess: ((String) -> Void)?

    // MARK: - Verified State
    private var verifiedMerchantId: Int = 6
    private var verifiedMerchantName: String = "SHRI ANANDPUR TRUST"
    private var verifiedRoleId: Int = 0

    // Countdown Timer for OTP Dialog
    private var otpTimer: Timer?
    private var otpRemainingSeconds = 30

    // MARK: - Main UI Containers
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let headerTitleLabel = UILabel()
    private let errorBanner = UIView()
    private let errorLabel = UILabel()
    private let versionLabel = UILabel()

    // MARK: - Card 1: Initial Card (Screenshot 1: Trust Code only)
    private let initialCardView = UIView()
    private let initTrustBadge = UIView()
    private let initTrustBadgeIcon = UIImageView()
    private let initTrustTitleLabel = UILabel()
    private let initTrustCodeField = UITextField()
    private let initTrustUnderline = UIView()
    private let initTrustArrowButton = UIButton(type: .system)
    private let initTrustInfoButton = UIButton(type: .system)
    private let initTrustSpinner = UIActivityIndicatorView(style: .medium)
    private let initBottomBar = UIView()
    private let initCancelButton = UIButton(type: .system)

    // MARK: - Card 2: Expanded Card (Screenshot 2: All Rows + Emblem Logo)
    private let expandedCardView = UIView()

    // 1. Trust Code Row (Verified with Checkmark)
    private let expTrustRowView = UIView()
    private let expTrustBadge = UIView()
    private let expTrustBadgeIcon = UIImageView()
    private let expTrustTitleLabel = UILabel()
    private let expTrustCodeField = UITextField()
    private let expTrustUnderline = UIView()
    private let expTrustCheckmark = UIImageView()
    private let expTrustArrowButton = UIButton(type: .system)
    private let expTrustInfoButton = UIButton(type: .system)

    // 2. Emblem Logo
    private let emblemImageView = UIImageView()

    // 3. Email Row
    private let expEmailRowView = UIView()
    private let expEmailIcon = UIImageView()
    private let expEmailTitleLabel = UILabel()
    private let expEmailField = UITextField()
    private let expEmailUnderline = UIView()
    private let expEmailCheckmark = UIImageView()

    // 4. Mobile Phone Row
    private let expMobileRowView = UIView()
    private let expMobileIcon = UIImageView()
    private let expMobileTitleLabel = UILabel()
    private let expMobileField = UITextField()
    private let expMobileUnderline = UIView()
    private let expMobileCheckmark = UIImageView()
    private let expMobileArrowButton = UIButton(type: .system)
    private let expMobileInfoButton = UIButton(type: .system)
    private let expMobileSpinner = UIActivityIndicatorView(style: .medium)

    // 5. Parent Branch Code Row
    private let expParentRowView = UIView()
    private let expParentIcon = UIImageView()
    private let expParentTitleLabel = UILabel()
    private let expParentCodeField = UITextField()
    private let expParentUnderline = UIView()
    private let expParentArrowButton = UIButton(type: .system)
    private let expParentInfoButton = UIButton(type: .system)

    // Expanded Bottom Bar
    private let expBottomBar = UIView()
    private let expCancelButton = UIButton(type: .system)
    private let expRegisterButton = UIButton(type: .system)
    private let expRegisterSpinner = UIActivityIndicatorView(style: .medium)

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

    // MARK: - Main UI Construction
    private func setupUI() {
        // Deep Royal Blue (#133B7C)
        view.backgroundColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)

        // 1. ScrollView & ContentView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // 2. Header Title ("Sign Up")
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.text = "Sign Up"
        headerTitleLabel.textColor = .white
        headerTitleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        headerTitleLabel.textAlignment = .center
        contentView.addSubview(headerTitleLabel)

        // 3. Error Banner
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

        // 4. Build Initial Card (Screenshot 1)
        buildInitialCard()

        // 5. Build Expanded Card (Screenshot 2)
        buildExpandedCard()

        // 6. Version Label ("v t 2.0.10")
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.text = "v t 2.0.10"
        versionLabel.textColor = UIColor.white.withAlphaComponent(0.65)
        versionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        versionLabel.textAlignment = .right
        view.addSubview(versionLabel)

        // Base Layout Constraints
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

            versionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    // MARK: - Card 1: Initial Card (Screenshot 1)
    private func buildInitialCard() {
        initialCardView.translatesAutoresizingMaskIntoConstraints = false
        initialCardView.backgroundColor = .white
        initialCardView.layer.cornerRadius = 18
        initialCardView.layer.masksToBounds = true
        contentView.addSubview(initialCardView)

        // Pink ID Badge Icon
        initTrustBadge.translatesAutoresizingMaskIntoConstraints = false
        initTrustBadge.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 0.85)
        initTrustBadge.layer.cornerRadius = 6
        initTrustBadge.layer.masksToBounds = true
        initialCardView.addSubview(initTrustBadge)

        initTrustBadgeIcon.translatesAutoresizingMaskIntoConstraints = false
        initTrustBadgeIcon.image = UIImage(systemName: "person.crop.rectangle.fill") ?? UIImage(systemName: "person.fill")
        initTrustBadgeIcon.tintColor = .white
        initTrustBadgeIcon.contentMode = .scaleAspectFit
        initTrustBadge.addSubview(initTrustBadgeIcon)

        // Label: "Trust/Institution code*"
        initTrustTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        initTrustTitleLabel.attributedText = createRequiredLabel("Trust/Institution code")
        initialCardView.addSubview(initTrustTitleLabel)

        // Text Input
        initTrustCodeField.translatesAutoresizingMaskIntoConstraints = false
        initTrustCodeField.placeholder = "Type your trust code"
        initTrustCodeField.text = "SAT6677"
        initTrustCodeField.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        initTrustCodeField.font = UIFont.systemFont(ofSize: 15.5, weight: .semibold)
        initTrustCodeField.autocapitalizationType = .allCharacters
        initTrustCodeField.autocorrectionType = .no
        initTrustCodeField.returnKeyType = .done
        initTrustCodeField.delegate = self
        initTrustCodeField.addTarget(self, action: #selector(clearBannerError), for: .editingChanged)
        initialCardView.addSubview(initTrustCodeField)

        // Blue Underline
        initTrustUnderline.translatesAutoresizingMaskIntoConstraints = false
        initTrustUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        initialCardView.addSubview(initTrustUnderline)

        // Arrow Button
        initTrustArrowButton.translatesAutoresizingMaskIntoConstraints = false
        initTrustArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        initTrustArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        initTrustArrowButton.addTarget(self, action: #selector(handleTrustCodeSubmit), for: .touchUpInside)
        initialCardView.addSubview(initTrustArrowButton)

        // Info Button
        initTrustInfoButton.translatesAutoresizingMaskIntoConstraints = false
        initTrustInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        initTrustInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        initTrustInfoButton.addTarget(self, action: #selector(showTrustInfo), for: .touchUpInside)
        initialCardView.addSubview(initTrustInfoButton)

        // Spinner
        initTrustSpinner.translatesAutoresizingMaskIntoConstraints = false
        initTrustSpinner.hidesWhenStopped = true
        initTrustSpinner.color = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        initialCardView.addSubview(initTrustSpinner)

        // Bottom Bar
        initBottomBar.translatesAutoresizingMaskIntoConstraints = false
        initBottomBar.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        initialCardView.addSubview(initBottomBar)

        initCancelButton.translatesAutoresizingMaskIntoConstraints = false
        initCancelButton.setTitle("Cancel", for: .normal)
        initCancelButton.setTitleColor(.white, for: .normal)
        initCancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        initCancelButton.addTarget(self, action: #selector(handleCancelTap), for: .touchUpInside)
        initBottomBar.addSubview(initCancelButton)

        NSLayoutConstraint.activate([
            initialCardView.topAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: 12),
            initialCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            initialCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            initialCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50),

            initTrustBadge.leadingAnchor.constraint(equalTo: initialCardView.leadingAnchor, constant: 18),
            initTrustBadge.topAnchor.constraint(equalTo: initialCardView.topAnchor, constant: 24),
            initTrustBadge.widthAnchor.constraint(equalToConstant: 34),
            initTrustBadge.heightAnchor.constraint(equalToConstant: 24),

            initTrustBadgeIcon.centerXAnchor.constraint(equalTo: initTrustBadge.centerXAnchor),
            initTrustBadgeIcon.centerYAnchor.constraint(equalTo: initTrustBadge.centerYAnchor),
            initTrustBadgeIcon.widthAnchor.constraint(equalToConstant: 20),
            initTrustBadgeIcon.heightAnchor.constraint(equalToConstant: 16),

            initTrustTitleLabel.leadingAnchor.constraint(equalTo: initTrustBadge.trailingAnchor, constant: 12),
            initTrustTitleLabel.topAnchor.constraint(equalTo: initialCardView.topAnchor, constant: 20),

            initTrustCodeField.leadingAnchor.constraint(equalTo: initTrustBadge.trailingAnchor, constant: 12),
            initTrustCodeField.topAnchor.constraint(equalTo: initTrustTitleLabel.bottomAnchor, constant: 4),
            initTrustCodeField.trailingAnchor.constraint(equalTo: initTrustArrowButton.leadingAnchor, constant: -8),
            initTrustCodeField.heightAnchor.constraint(equalToConstant: 28),

            initTrustUnderline.leadingAnchor.constraint(equalTo: initTrustCodeField.leadingAnchor),
            initTrustUnderline.trailingAnchor.constraint(equalTo: initTrustCodeField.trailingAnchor),
            initTrustUnderline.topAnchor.constraint(equalTo: initTrustCodeField.bottomAnchor, constant: 2),
            initTrustUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            initTrustInfoButton.trailingAnchor.constraint(equalTo: initialCardView.trailingAnchor, constant: -18),
            initTrustInfoButton.centerYAnchor.constraint(equalTo: initTrustBadge.centerYAnchor),
            initTrustInfoButton.widthAnchor.constraint(equalToConstant: 26),
            initTrustInfoButton.heightAnchor.constraint(equalToConstant: 26),

            initTrustArrowButton.trailingAnchor.constraint(equalTo: initTrustInfoButton.leadingAnchor, constant: -8),
            initTrustArrowButton.centerYAnchor.constraint(equalTo: initTrustBadge.centerYAnchor),
            initTrustArrowButton.widthAnchor.constraint(equalToConstant: 26),
            initTrustArrowButton.heightAnchor.constraint(equalToConstant: 26),

            initTrustSpinner.centerXAnchor.constraint(equalTo: initTrustArrowButton.centerXAnchor),
            initTrustSpinner.centerYAnchor.constraint(equalTo: initTrustArrowButton.centerYAnchor),

            initBottomBar.topAnchor.constraint(equalTo: initTrustUnderline.bottomAnchor, constant: 36),
            initBottomBar.leadingAnchor.constraint(equalTo: initialCardView.leadingAnchor),
            initBottomBar.trailingAnchor.constraint(equalTo: initialCardView.trailingAnchor),
            initBottomBar.bottomAnchor.constraint(equalTo: initialCardView.bottomAnchor),
            initBottomBar.heightAnchor.constraint(equalToConstant: 54),

            initCancelButton.leadingAnchor.constraint(equalTo: initBottomBar.leadingAnchor, constant: 20),
            initCancelButton.centerYAnchor.constraint(equalTo: initBottomBar.centerYAnchor)
        ])
    }

    // MARK: - Card 2: Expanded Card (Screenshot 2)
    private func buildExpandedCard() {
        expandedCardView.translatesAutoresizingMaskIntoConstraints = false
        expandedCardView.backgroundColor = .white
        expandedCardView.layer.cornerRadius = 18
        expandedCardView.layer.masksToBounds = true
        expandedCardView.isHidden = true // Revealed after Trust code is verified
        contentView.addSubview(expandedCardView)

        // 1. Trust Row
        expTrustRowView.translatesAutoresizingMaskIntoConstraints = false
        expandedCardView.addSubview(expTrustRowView)

        expTrustBadge.translatesAutoresizingMaskIntoConstraints = false
        expTrustBadge.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 0.85)
        expTrustBadge.layer.cornerRadius = 6
        expTrustBadge.layer.masksToBounds = true
        expTrustRowView.addSubview(expTrustBadge)

        expTrustBadgeIcon.translatesAutoresizingMaskIntoConstraints = false
        expTrustBadgeIcon.image = UIImage(systemName: "person.crop.rectangle.fill") ?? UIImage(systemName: "person.fill")
        expTrustBadgeIcon.tintColor = .white
        expTrustBadgeIcon.contentMode = .scaleAspectFit
        expTrustBadge.addSubview(expTrustBadgeIcon)

        expTrustTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        expTrustTitleLabel.attributedText = createRequiredLabel("Trust/Institution code")
        expTrustRowView.addSubview(expTrustTitleLabel)

        expTrustCodeField.translatesAutoresizingMaskIntoConstraints = false
        expTrustCodeField.text = "SAT6677"
        expTrustCodeField.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        expTrustCodeField.font = UIFont.systemFont(ofSize: 15.5, weight: .semibold)
        expTrustCodeField.isEnabled = false
        expTrustRowView.addSubview(expTrustCodeField)

        expTrustUnderline.translatesAutoresizingMaskIntoConstraints = false
        expTrustUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        expTrustRowView.addSubview(expTrustUnderline)

        expTrustCheckmark.translatesAutoresizingMaskIntoConstraints = false
        expTrustCheckmark.image = UIImage(systemName: "checkmark")
        expTrustCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        expTrustRowView.addSubview(expTrustCheckmark)

        expTrustArrowButton.translatesAutoresizingMaskIntoConstraints = false
        expTrustArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        expTrustArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        expTrustRowView.addSubview(expTrustArrowButton)

        expTrustInfoButton.translatesAutoresizingMaskIntoConstraints = false
        expTrustInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        expTrustInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        expTrustInfoButton.addTarget(self, action: #selector(showTrustInfo), for: .touchUpInside)
        expTrustRowView.addSubview(expTrustInfoButton)

        // 2. Emblem Logo
        emblemImageView.translatesAutoresizingMaskIntoConstraints = false
        if let emblem = UIImage(named: "trust_emblem") ?? UIImage(named: "AppIcon-1024") ?? UIImage(named: "AppIcon") {
            emblemImageView.image = emblem
        } else {
            emblemImageView.image = UIImage(systemName: "seal.fill")
        }
        emblemImageView.contentMode = .scaleAspectFit
        expandedCardView.addSubview(emblemImageView)

        // 3. Email Row
        expEmailRowView.translatesAutoresizingMaskIntoConstraints = false
        expandedCardView.addSubview(expEmailRowView)

        expEmailIcon.translatesAutoresizingMaskIntoConstraints = false
        expEmailIcon.image = UIImage(systemName: "envelope.fill")
        expEmailIcon.tintColor = UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0)
        expEmailRowView.addSubview(expEmailIcon)

        expEmailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        expEmailTitleLabel.attributedText = createRequiredLabel("Email")
        expEmailRowView.addSubview(expEmailTitleLabel)

        expEmailField.translatesAutoresizingMaskIntoConstraints = false
        expEmailField.placeholder = "Type your email address"
        expEmailField.text = "dhyey.k@latitudetechnolabs.org"
        expEmailField.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        expEmailField.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        expEmailField.keyboardType = .emailAddress
        expEmailField.autocapitalizationType = .none
        expEmailField.autocorrectionType = .no
        expEmailField.delegate = self
        expEmailRowView.addSubview(expEmailField)

        expEmailUnderline.translatesAutoresizingMaskIntoConstraints = false
        expEmailUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        expEmailRowView.addSubview(expEmailUnderline)

        expEmailCheckmark.translatesAutoresizingMaskIntoConstraints = false
        expEmailCheckmark.image = UIImage(systemName: "checkmark")
        expEmailCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        expEmailCheckmark.isHidden = true
        expEmailRowView.addSubview(expEmailCheckmark)

        // 4. Mobile Phone Row
        expMobileRowView.translatesAutoresizingMaskIntoConstraints = false
        expandedCardView.addSubview(expMobileRowView)

        expMobileIcon.translatesAutoresizingMaskIntoConstraints = false
        expMobileIcon.image = UIImage(systemName: "hand.tap.fill") ?? UIImage(systemName: "phone.fill")
        expMobileIcon.tintColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1.0)
        expMobileRowView.addSubview(expMobileIcon)

        expMobileTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        expMobileTitleLabel.attributedText = createRequiredLabel("Mobile phone")
        expMobileRowView.addSubview(expMobileTitleLabel)

        expMobileField.translatesAutoresizingMaskIntoConstraints = false
        expMobileField.placeholder = "Type your 10-digit mobile"
        expMobileField.text = "7990657479"
        expMobileField.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        expMobileField.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        expMobileField.keyboardType = .phonePad
        expMobileField.delegate = self
        expMobileRowView.addSubview(expMobileField)

        expMobileUnderline.translatesAutoresizingMaskIntoConstraints = false
        expMobileUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        expMobileRowView.addSubview(expMobileUnderline)

        expMobileCheckmark.translatesAutoresizingMaskIntoConstraints = false
        expMobileCheckmark.image = UIImage(systemName: "checkmark")
        expMobileCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        expMobileCheckmark.isHidden = true
        expMobileRowView.addSubview(expMobileCheckmark)

        expMobileArrowButton.translatesAutoresizingMaskIntoConstraints = false
        expMobileArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        expMobileArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        expMobileArrowButton.addTarget(self, action: #selector(handleMobileSubmitAndSendOTP), for: .touchUpInside)
        expMobileRowView.addSubview(expMobileArrowButton)

        expMobileInfoButton.translatesAutoresizingMaskIntoConstraints = false
        expMobileInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        expMobileInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        expMobileInfoButton.addTarget(self, action: #selector(showMobileInfo), for: .touchUpInside)
        expMobileRowView.addSubview(expMobileInfoButton)

        expMobileSpinner.translatesAutoresizingMaskIntoConstraints = false
        expMobileSpinner.hidesWhenStopped = true
        expMobileSpinner.color = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        expMobileRowView.addSubview(expMobileSpinner)

        // 5. Parent Branch Code Row
        expParentRowView.translatesAutoresizingMaskIntoConstraints = false
        expParentRowView.isHidden = true // Revealed after OTP verification
        expandedCardView.addSubview(expParentRowView)

        expParentIcon.translatesAutoresizingMaskIntoConstraints = false
        expParentIcon.image = UIImage(systemName: "person.crop.circle.badge.checkmark") ?? UIImage(systemName: "person.fill")
        expParentIcon.tintColor = UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0)
        expParentRowView.addSubview(expParentIcon)

        expParentTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        expParentTitleLabel.attributedText = createRequiredLabel("Enter Main/Parent Branch Code#")
        expParentRowView.addSubview(expParentTitleLabel)

        expParentCodeField.translatesAutoresizingMaskIntoConstraints = false
        expParentCodeField.placeholder = "0000"
        expParentCodeField.text = "6"
        expParentCodeField.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        expParentCodeField.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        expParentCodeField.keyboardType = .asciiCapable
        expParentCodeField.delegate = self
        expParentRowView.addSubview(expParentCodeField)

        expParentUnderline.translatesAutoresizingMaskIntoConstraints = false
        expParentUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        expParentRowView.addSubview(expParentUnderline)

        expParentArrowButton.translatesAutoresizingMaskIntoConstraints = false
        expParentArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        expParentArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        expParentArrowButton.addTarget(self, action: #selector(handleRegisterBranch), for: .touchUpInside)
        expParentRowView.addSubview(expParentArrowButton)

        expParentInfoButton.translatesAutoresizingMaskIntoConstraints = false
        expParentInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        expParentInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        expParentInfoButton.addTarget(self, action: #selector(showParentInfo), for: .touchUpInside)
        expParentRowView.addSubview(expParentInfoButton)

        // Expanded Bottom Bar
        expBottomBar.translatesAutoresizingMaskIntoConstraints = false
        expBottomBar.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        expandedCardView.addSubview(expBottomBar)

        expCancelButton.translatesAutoresizingMaskIntoConstraints = false
        expCancelButton.setTitle("Cancel", for: .normal)
        expCancelButton.setTitleColor(.white, for: .normal)
        expCancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        expCancelButton.addTarget(self, action: #selector(handleCancelTap), for: .touchUpInside)
        expBottomBar.addSubview(expCancelButton)

        expRegisterButton.translatesAutoresizingMaskIntoConstraints = false
        expRegisterButton.setTitle("Register Branch  ➔", for: .normal)
        expRegisterButton.setTitleColor(.white, for: .normal)
        expRegisterButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        expRegisterButton.isHidden = true // Revealed after OTP verification
        expRegisterButton.addTarget(self, action: #selector(handleRegisterBranch), for: .touchUpInside)
        expBottomBar.addSubview(expRegisterButton)

        expRegisterSpinner.translatesAutoresizingMaskIntoConstraints = false
        expRegisterSpinner.hidesWhenStopped = true
        expRegisterSpinner.color = .white
        expBottomBar.addSubview(expRegisterSpinner)

        NSLayoutConstraint.activate([
            expandedCardView.topAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: 12),
            expandedCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            expandedCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            expandedCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50),

            // 1. Trust Row
            expTrustRowView.topAnchor.constraint(equalTo: expandedCardView.topAnchor, constant: 20),
            expTrustRowView.leadingAnchor.constraint(equalTo: expandedCardView.leadingAnchor, constant: 18),
            expTrustRowView.trailingAnchor.constraint(equalTo: expandedCardView.trailingAnchor, constant: -18),

            expTrustBadge.leadingAnchor.constraint(equalTo: expTrustRowView.leadingAnchor),
            expTrustBadge.topAnchor.constraint(equalTo: expTrustRowView.topAnchor, constant: 4),
            expTrustBadge.widthAnchor.constraint(equalToConstant: 34),
            expTrustBadge.heightAnchor.constraint(equalToConstant: 24),

            expTrustBadgeIcon.centerXAnchor.constraint(equalTo: expTrustBadge.centerXAnchor),
            expTrustBadgeIcon.centerYAnchor.constraint(equalTo: expTrustBadge.centerYAnchor),
            expTrustBadgeIcon.widthAnchor.constraint(equalToConstant: 20),
            expTrustBadgeIcon.heightAnchor.constraint(equalToConstant: 16),

            expTrustTitleLabel.leadingAnchor.constraint(equalTo: expTrustBadge.trailingAnchor, constant: 12),
            expTrustTitleLabel.topAnchor.constraint(equalTo: expTrustRowView.topAnchor),

            expTrustCodeField.leadingAnchor.constraint(equalTo: expTrustBadge.trailingAnchor, constant: 12),
            expTrustCodeField.topAnchor.constraint(equalTo: expTrustTitleLabel.bottomAnchor, constant: 4),
            expTrustCodeField.trailingAnchor.constraint(equalTo: expTrustCheckmark.leadingAnchor, constant: -8),
            expTrustCodeField.heightAnchor.constraint(equalToConstant: 28),

            expTrustUnderline.leadingAnchor.constraint(equalTo: expTrustCodeField.leadingAnchor),
            expTrustUnderline.trailingAnchor.constraint(equalTo: expTrustCodeField.trailingAnchor),
            expTrustUnderline.topAnchor.constraint(equalTo: expTrustCodeField.bottomAnchor, constant: 2),
            expTrustUnderline.heightAnchor.constraint(equalToConstant: 1.5),
            expTrustUnderline.bottomAnchor.constraint(equalTo: expTrustRowView.bottomAnchor),

            expTrustInfoButton.trailingAnchor.constraint(equalTo: expTrustRowView.trailingAnchor),
            expTrustInfoButton.centerYAnchor.constraint(equalTo: expTrustBadge.centerYAnchor),
            expTrustInfoButton.widthAnchor.constraint(equalToConstant: 26),
            expTrustInfoButton.heightAnchor.constraint(equalToConstant: 26),

            expTrustArrowButton.trailingAnchor.constraint(equalTo: expTrustInfoButton.leadingAnchor, constant: -6),
            expTrustArrowButton.centerYAnchor.constraint(equalTo: expTrustBadge.centerYAnchor),
            expTrustArrowButton.widthAnchor.constraint(equalToConstant: 26),
            expTrustArrowButton.heightAnchor.constraint(equalToConstant: 26),

            expTrustCheckmark.trailingAnchor.constraint(equalTo: expTrustArrowButton.leadingAnchor, constant: -6),
            expTrustCheckmark.centerYAnchor.constraint(equalTo: expTrustBadge.centerYAnchor),
            expTrustCheckmark.widthAnchor.constraint(equalToConstant: 20),
            expTrustCheckmark.heightAnchor.constraint(equalToConstant: 20),

            // 2. Emblem Logo
            emblemImageView.topAnchor.constraint(equalTo: expTrustRowView.bottomAnchor, constant: 14),
            emblemImageView.centerXAnchor.constraint(equalTo: expandedCardView.centerXAnchor),
            emblemImageView.widthAnchor.constraint(equalToConstant: 135),
            emblemImageView.heightAnchor.constraint(equalToConstant: 135),

            // 3. Email Row
            expEmailRowView.topAnchor.constraint(equalTo: emblemImageView.bottomAnchor, constant: 14),
            expEmailRowView.leadingAnchor.constraint(equalTo: expandedCardView.leadingAnchor, constant: 18),
            expEmailRowView.trailingAnchor.constraint(equalTo: expandedCardView.trailingAnchor, constant: -18),

            expEmailIcon.leadingAnchor.constraint(equalTo: expEmailRowView.leadingAnchor),
            expEmailIcon.topAnchor.constraint(equalTo: expEmailRowView.topAnchor, constant: 4),
            expEmailIcon.widthAnchor.constraint(equalToConstant: 26),
            expEmailIcon.heightAnchor.constraint(equalToConstant: 20),

            expEmailTitleLabel.leadingAnchor.constraint(equalTo: expEmailIcon.trailingAnchor, constant: 12),
            expEmailTitleLabel.topAnchor.constraint(equalTo: expEmailRowView.topAnchor),

            expEmailField.leadingAnchor.constraint(equalTo: expEmailIcon.trailingAnchor, constant: 12),
            expEmailField.topAnchor.constraint(equalTo: expEmailTitleLabel.bottomAnchor, constant: 4),
            expEmailField.trailingAnchor.constraint(equalTo: expEmailCheckmark.leadingAnchor, constant: -8),
            expEmailField.heightAnchor.constraint(equalToConstant: 28),

            expEmailUnderline.leadingAnchor.constraint(equalTo: expEmailField.leadingAnchor),
            expEmailUnderline.trailingAnchor.constraint(equalTo: expEmailRowView.trailingAnchor),
            expEmailUnderline.topAnchor.constraint(equalTo: expEmailField.bottomAnchor, constant: 2),
            expEmailUnderline.heightAnchor.constraint(equalToConstant: 1.5),
            expEmailUnderline.bottomAnchor.constraint(equalTo: expEmailRowView.bottomAnchor),

            expEmailCheckmark.trailingAnchor.constraint(equalTo: expEmailRowView.trailingAnchor),
            expEmailCheckmark.centerYAnchor.constraint(equalTo: expEmailIcon.centerYAnchor),
            expEmailCheckmark.widthAnchor.constraint(equalToConstant: 20),
            expEmailCheckmark.heightAnchor.constraint(equalToConstant: 20),

            // 4. Mobile Row
            expMobileRowView.topAnchor.constraint(equalTo: expEmailRowView.bottomAnchor, constant: 14),
            expMobileRowView.leadingAnchor.constraint(equalTo: expandedCardView.leadingAnchor, constant: 18),
            expMobileRowView.trailingAnchor.constraint(equalTo: expandedCardView.trailingAnchor, constant: -18),

            expMobileIcon.leadingAnchor.constraint(equalTo: expMobileRowView.leadingAnchor),
            expMobileIcon.topAnchor.constraint(equalTo: expMobileRowView.topAnchor, constant: 4),
            expMobileIcon.widthAnchor.constraint(equalToConstant: 26),
            expMobileIcon.heightAnchor.constraint(equalToConstant: 20),

            expMobileTitleLabel.leadingAnchor.constraint(equalTo: expMobileIcon.trailingAnchor, constant: 12),
            expMobileTitleLabel.topAnchor.constraint(equalTo: expMobileRowView.topAnchor),

            expMobileField.leadingAnchor.constraint(equalTo: expMobileIcon.trailingAnchor, constant: 12),
            expMobileField.topAnchor.constraint(equalTo: expMobileTitleLabel.bottomAnchor, constant: 4),
            expMobileField.trailingAnchor.constraint(equalTo: expMobileCheckmark.leadingAnchor, constant: -8),
            expMobileField.heightAnchor.constraint(equalToConstant: 28),

            expMobileUnderline.leadingAnchor.constraint(equalTo: expMobileField.leadingAnchor),
            expMobileUnderline.trailingAnchor.constraint(equalTo: expMobileField.trailingAnchor),
            expMobileUnderline.topAnchor.constraint(equalTo: expMobileField.bottomAnchor, constant: 2),
            expMobileUnderline.heightAnchor.constraint(equalToConstant: 1.5),
            expMobileUnderline.bottomAnchor.constraint(equalTo: expMobileRowView.bottomAnchor),

            expMobileInfoButton.trailingAnchor.constraint(equalTo: expMobileRowView.trailingAnchor),
            expMobileInfoButton.centerYAnchor.constraint(equalTo: expMobileIcon.centerYAnchor),
            expMobileInfoButton.widthAnchor.constraint(equalToConstant: 26),
            expMobileInfoButton.heightAnchor.constraint(equalToConstant: 26),

            expMobileArrowButton.trailingAnchor.constraint(equalTo: expMobileInfoButton.leadingAnchor, constant: -6),
            expMobileArrowButton.centerYAnchor.constraint(equalTo: expMobileIcon.centerYAnchor),
            expMobileArrowButton.widthAnchor.constraint(equalToConstant: 26),
            expMobileArrowButton.heightAnchor.constraint(equalToConstant: 26),

            expMobileCheckmark.trailingAnchor.constraint(equalTo: expMobileArrowButton.leadingAnchor, constant: -6),
            expMobileCheckmark.centerYAnchor.constraint(equalTo: expMobileIcon.centerYAnchor),
            expMobileCheckmark.widthAnchor.constraint(equalToConstant: 20),
            expMobileCheckmark.heightAnchor.constraint(equalToConstant: 20),

            expMobileSpinner.centerXAnchor.constraint(equalTo: expMobileArrowButton.centerXAnchor),
            expMobileSpinner.centerYAnchor.constraint(equalTo: expMobileArrowButton.centerYAnchor),

            // 5. Parent Code Row
            expParentRowView.topAnchor.constraint(equalTo: expMobileRowView.bottomAnchor, constant: 14),
            expParentRowView.leadingAnchor.constraint(equalTo: expandedCardView.leadingAnchor, constant: 18),
            expParentRowView.trailingAnchor.constraint(equalTo: expandedCardView.trailingAnchor, constant: -18),

            expParentIcon.leadingAnchor.constraint(equalTo: expParentRowView.leadingAnchor),
            expParentIcon.topAnchor.constraint(equalTo: expParentRowView.topAnchor, constant: 4),
            expParentIcon.widthAnchor.constraint(equalToConstant: 26),
            expParentIcon.heightAnchor.constraint(equalToConstant: 20),

            expParentTitleLabel.leadingAnchor.constraint(equalTo: expParentIcon.trailingAnchor, constant: 12),
            expParentTitleLabel.topAnchor.constraint(equalTo: expParentRowView.topAnchor),

            expParentCodeField.leadingAnchor.constraint(equalTo: expParentIcon.trailingAnchor, constant: 12),
            expParentCodeField.topAnchor.constraint(equalTo: expParentTitleLabel.bottomAnchor, constant: 4),
            expParentCodeField.trailingAnchor.constraint(equalTo: expParentArrowButton.leadingAnchor, constant: -8),
            expParentCodeField.heightAnchor.constraint(equalToConstant: 28),

            expParentUnderline.leadingAnchor.constraint(equalTo: expParentCodeField.leadingAnchor),
            expParentUnderline.trailingAnchor.constraint(equalTo: expParentCodeField.trailingAnchor),
            expParentUnderline.topAnchor.constraint(equalTo: expParentCodeField.bottomAnchor, constant: 2),
            expParentUnderline.heightAnchor.constraint(equalToConstant: 1.5),
            expParentUnderline.bottomAnchor.constraint(equalTo: expParentRowView.bottomAnchor),

            expParentInfoButton.trailingAnchor.constraint(equalTo: expParentRowView.trailingAnchor),
            expParentInfoButton.centerYAnchor.constraint(equalTo: expParentIcon.centerYAnchor),
            expParentInfoButton.widthAnchor.constraint(equalToConstant: 26),
            expParentInfoButton.heightAnchor.constraint(equalToConstant: 26),

            expParentArrowButton.trailingAnchor.constraint(equalTo: expParentInfoButton.leadingAnchor, constant: -6),
            expParentArrowButton.centerYAnchor.constraint(equalTo: expParentIcon.centerYAnchor),
            expParentArrowButton.widthAnchor.constraint(equalToConstant: 26),
            expParentArrowButton.heightAnchor.constraint(equalToConstant: 26),

            // Bottom Bar
            expBottomBar.topAnchor.constraint(equalTo: expParentRowView.bottomAnchor, constant: 20),
            expBottomBar.leadingAnchor.constraint(equalTo: expandedCardView.leadingAnchor),
            expBottomBar.trailingAnchor.constraint(equalTo: expandedCardView.trailingAnchor),
            expBottomBar.bottomAnchor.constraint(equalTo: expandedCardView.bottomAnchor),
            expBottomBar.heightAnchor.constraint(equalToConstant: 54),

            expCancelButton.leadingAnchor.constraint(equalTo: expBottomBar.leadingAnchor, constant: 20),
            expCancelButton.centerYAnchor.constraint(equalTo: expBottomBar.centerYAnchor),

            expRegisterButton.trailingAnchor.constraint(equalTo: expBottomBar.trailingAnchor, constant: -20),
            expRegisterButton.centerYAnchor.constraint(equalTo: expBottomBar.centerYAnchor),

            expRegisterSpinner.centerYAnchor.constraint(equalTo: expRegisterButton.centerYAnchor),
            expRegisterSpinner.centerXAnchor.constraint(equalTo: expRegisterButton.centerXAnchor)
        ])
    }

    // MARK: - Floating OTP Modal Dialog (Screenshot 3)
    private func setupOTPDialogUI() {
        otpOverlayBackdrop.translatesAutoresizingMaskIntoConstraints = false
        otpOverlayBackdrop.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        otpOverlayBackdrop.isHidden = true
        view.addSubview(otpOverlayBackdrop)

        otpCardContainer.translatesAutoresizingMaskIntoConstraints = false
        otpCardContainer.backgroundColor = UIColor(red: 21/255, green: 64/255, blue: 141/255, alpha: 1.0)
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
        otpCancelButton.backgroundColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 0.75)
        otpCancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        otpCancelButton.layer.cornerRadius = 4
        otpCancelButton.addTarget(self, action: #selector(handleCancelOTP), for: .touchUpInside)
        otpCardContainer.addSubview(otpCancelButton)

        otpVerifyButton.translatesAutoresizingMaskIntoConstraints = false
        otpVerifyButton.setTitle("Verify OTP", for: .normal)
        otpVerifyButton.setTitleColor(.white, for: .normal)
        otpVerifyButton.backgroundColor = UIColor(red: 2/255, green: 136/255, blue: 209/255, alpha: 1.0)
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
                .foregroundColor: UIColor(red: 220/255, green: 53/255, blue: 69/255, alpha: 1.0)
            ]
        ))
        return attr
    }

    // MARK: - Dynamic Error Extraction & Banner Helpers
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

    @objc private func clearBannerError() {
        errorBanner.isHidden = true
    }

    // MARK: - Step 1: Trust Code Verification (POST /api/check-trust-code)
    @objc private func handleTrustCodeSubmit() {
        view.endEditing(true)
        let code = initTrustCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !code.isEmpty else {
            initTrustUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            showBannerError("Please enter valid trust code. Contact helpline.")
            return
        }

        initTrustArrowButton.isHidden = true
        initTrustSpinner.startAnimating()
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
                self.initTrustArrowButton.isHidden = false
                self.initTrustSpinner.stopAnimating()

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

                    self.expTrustCodeField.text = code
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                    // Switch cleanly from Initial Card to Expanded Card (Screenshot 2)
                    UIView.transition(with: self.contentView, duration: 0.35, options: .transitionCrossDissolve) {
                        self.initialCardView.isHidden = true
                        self.expandedCardView.isHidden = false
                    }
                    self.expEmailField.becomeFirstResponder()
                } else {
                    self.initTrustUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
                    self.showBannerError(apiMessage)
                }
            }
        }.resume()
    }

    // MARK: - Step 2: Mobile Submit & Send OTP (POST /api/register-otp-send)
    @objc private func handleMobileSubmitAndSendOTP() {
        view.endEditing(true)
        let email = expEmailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let mobile = expMobileField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trustCode = expTrustCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !email.isEmpty, email.contains("@"), email.contains(".") else {
            expEmailUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            showBannerError("Please enter a valid Email address.")
            return
        }

        guard !mobile.isEmpty, mobile.count == 10 else {
            expMobileUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            showBannerError("Please enter a valid 10-digit mobile number.")
            return
        }

        expMobileArrowButton.isHidden = true
        expMobileSpinner.startAnimating()
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
                self.expMobileArrowButton.isHidden = false
                self.expMobileSpinner.stopAnimating()

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
                    self.expMobileUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
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

        let mobile = expMobileField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

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

                    self.expEmailCheckmark.isHidden = false
                    self.expMobileCheckmark.isHidden = false

                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

                    // Dismiss Floating OTP Dialog
                    UIView.animate(withDuration: 0.2, animations: {
                        self.otpOverlayBackdrop.alpha = 0
                    }) { _ in
                        self.otpOverlayBackdrop.isHidden = true
                    }

                    // Reveal Parent Code Row and Register Branch Button (Screenshot 2)
                    UIView.animate(withDuration: 0.3) {
                        self.expParentRowView.isHidden = false
                        self.expRegisterButton.isHidden = false
                    }
                    self.expParentCodeField.becomeFirstResponder()
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
        let parentCode = expParentCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = expEmailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let mobile = expMobileField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trustCode = expTrustCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !parentCode.isEmpty else {
            expParentUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            showBannerError("Please enter Main/Parent Branch Code.")
            return
        }

        expRegisterButton.setTitle("", for: .normal)
        expRegisterSpinner.startAnimating()
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
                self.expRegisterSpinner.stopAnimating()
                self.expRegisterButton.setTitle("Register Branch  ➔", for: .normal)

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
        if textField == initTrustCodeField {
            handleTrustCodeSubmit()
        } else if textField == expEmailField {
            expMobileField.becomeFirstResponder()
        } else if textField == expMobileField {
            handleMobileSubmitAndSendOTP()
        } else if textField == expParentCodeField {
            handleRegisterBranch()
        }
        return true
    }
}
