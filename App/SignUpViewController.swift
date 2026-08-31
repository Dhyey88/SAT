import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var onSignUpSuccess: ((String) -> Void)?

    // MARK: - State Management
    private enum Phase {
        case step1Validation // Trust code, Logo, Email, Mobile, Parent Branch Code
        case step2UserDetails // Title, First Name, Last Name, Password, Gender
    }

    private var currentPhase: Phase = .step1Validation

    private var verifiedMerchantId: Int = 0
    private var verifiedMerchantName: String = ""
    private var verifiedRoleId: Int = 0
    private var isTrustCodeVerified = false
    private var isEmailVerified = false
    private var isMobileVerified = false
    private var isParentCodeVerified = false

    private var availableTitles: [String] = ["Mr", "Mrs", "Ms", "Mh", "Bai", "Bh"]
    private var selectedTitle: String = "Mr"
    private var selectedGender: Int = 1 // 1 = Male, 2 = Female

    // OTP Timer
    private var otpTimer: Timer?
    private var otpRemainingSeconds = 30

    // MARK: - UI Containers
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let headerTitleLabel = UILabel()
    private let headerSubtitleLabel = UILabel()
    private let errorBanner = UIView()
    private let errorBannerLabel = UILabel()

    private let cardContainer = UIView()
    private let cardBody = UIView()
    private let formStackView = UIStackView()
    private let cardBottomBar = UIView()

    // MARK: - Phase 1 Views
    // 1. Trust Code Row
    private let trustCodeRowView = UIView()
    private let trustBadgeIcon = UIView()
    private let trustBadgeSubIcon = UIImageView()
    private let trustTitleLabel = UILabel()
    private let trustCodeField = UITextField()
    private let trustUnderline = UIView()
    private let trustErrorLabel = UILabel()
    private let trustCheckmark = UIImageView()
    private let trustArrowButton = UIButton(type: .system)
    private let trustInfoButton = UIButton(type: .system)
    private let trustSpinner = UIActivityIndicatorView(style: .medium)

    // 2. Trust Emblem Logo
    private let trustLogoContainer = UIView()
    private let trustLogoImageView = UIImageView()
    private let trustNameLabel = UILabel()

    // 3. Email Row
    private let emailRowView = UIView()
    private let emailIcon = UIImageView()
    private let emailTitleLabel = UILabel()
    private let emailField = UITextField()
    private let emailUnderline = UIView()
    private let emailErrorLabel = UILabel()
    private let emailCheckmark = UIImageView()
    private let emailArrowButton = UIButton(type: .system)
    private let emailSpinner = UIActivityIndicatorView(style: .medium)

    // 4. Mobile Row
    private let mobileRowView = UIView()
    private let mobileIcon = UIImageView()
    private let mobileTitleLabel = UILabel()
    private let mobileField = UITextField()
    private let mobileUnderline = UIView()
    private let mobileErrorLabel = UILabel()
    private let mobileCheckmark = UIImageView()
    private let mobileArrowButton = UIButton(type: .system)
    private let mobileInfoButton = UIButton(type: .system)
    private let mobileSpinner = UIActivityIndicatorView(style: .medium)

    // 5. Parent Branch Code Row
    private let parentRowView = UIView()
    private let parentIcon = UIImageView()
    private let parentTitleLabel = UILabel()
    private let parentCodeField = UITextField()
    private let parentUnderline = UIView()
    private let parentErrorLabel = UILabel()
    private let parentCheckmark = UIImageView()
    private let parentArrowButton = UIButton(type: .system)
    private let parentInfoButton = UIButton(type: .system)
    private let parentSpinner = UIActivityIndicatorView(style: .medium)

    // MARK: - Phase 2 Views (User Details Form)
    private let userDetailsSectionView = UIView()
    private let verifiedTrustHeaderBadge = UIView()
    private let verifiedTrustHeaderLabel = UILabel()

    private let titlePickerField = UITextField()
    private let titlePickerView = UIPickerView()
    private let titleUnderline = UIView()

    private let fnameField = UITextField()
    private let fnameUnderline = UIView()
    private let fnameErrorLabel = UILabel()

    private let lnameField = UITextField()
    private let lnameUnderline = UIView()
    private let lnameErrorLabel = UILabel()

    private let passwordField = UITextField()
    private let passwordUnderline = UIView()
    private let passwordErrorLabel = UILabel()
    private let showPasswordButton = UIButton(type: .system)

    private let genderContainer = UIView()
    private let maleRadioButton = UIButton(type: .system)
    private let femaleRadioButton = UIButton(type: .system)

    // Bottom Bar
    private let cancelButton = UIButton(type: .system)
    private let actionButton = UIButton(type: .system)
    private let actionSpinner = UIActivityIndicatorView(style: .medium)
    private let versionLabel = UILabel()

    // MARK: - OTP Modal Overlay Views
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
        setupOTPOverlayUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    deinit {
        otpTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI Construction
    private func setupUI() {
        // Background: Deep Royal Blue (#133B7C)
        view.backgroundColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)

        // 1. Scroll & Content
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // 2. Header
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.text = "Sign Up"
        headerTitleLabel.textColor = .white
        headerTitleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        headerTitleLabel.textAlignment = .center
        contentView.addSubview(headerTitleLabel)

        headerSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerSubtitleLabel.text = "Create your trust or branch account"
        headerSubtitleLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        headerSubtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        headerSubtitleLabel.textAlignment = .center
        contentView.addSubview(headerSubtitleLabel)

        // 3. Error Banner
        errorBanner.translatesAutoresizingMaskIntoConstraints = false
        errorBanner.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 0.95)
        errorBanner.layer.cornerRadius = 6
        errorBanner.layer.masksToBounds = true
        errorBanner.isHidden = true
        contentView.addSubview(errorBanner)

        errorBannerLabel.translatesAutoresizingMaskIntoConstraints = false
        errorBannerLabel.textColor = .white
        errorBannerLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        errorBannerLabel.textAlignment = .center
        errorBannerLabel.numberOfLines = 0
        errorBanner.addSubview(errorBannerLabel)

        // 4. Main Card Container
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.layer.cornerRadius = 18
        cardContainer.layer.masksToBounds = true
        cardContainer.backgroundColor = .white
        contentView.addSubview(cardContainer)

        cardBody.translatesAutoresizingMaskIntoConstraints = false
        cardBody.backgroundColor = .white
        cardContainer.addSubview(cardBody)

        // UIStackView inside Card Body (Prevents all constraint conflicts!)
        formStackView.translatesAutoresizingMaskIntoConstraints = false
        formStackView.axis = .vertical
        formStackView.spacing = 14
        formStackView.alignment = .fill
        formStackView.distribution = .fill
        cardBody.addSubview(formStackView)

        // Build Rows
        buildTrustCodeRow()
        buildLogoRow()
        buildEmailRow()
        buildMobileRow()
        buildParentCodeRow()
        buildUserDetailsSection()

        // Build Bottom Action Bar
        buildBottomActionBar()

        // 5. Version Label
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

            headerSubtitleLabel.topAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 4),
            headerSubtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            errorBanner.topAnchor.constraint(equalTo: headerSubtitleLabel.bottomAnchor, constant: 10),
            errorBanner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            errorBanner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            errorBannerLabel.topAnchor.constraint(equalTo: errorBanner.topAnchor, constant: 8),
            errorBannerLabel.leadingAnchor.constraint(equalTo: errorBanner.leadingAnchor, constant: 12),
            errorBannerLabel.trailingAnchor.constraint(equalTo: errorBanner.trailingAnchor, constant: -12),
            errorBannerLabel.bottomAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: -8),

            cardContainer.topAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: 12),
            cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50),

            cardBody.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            cardBody.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            cardBody.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),

            formStackView.topAnchor.constraint(equalTo: cardBody.topAnchor, constant: 16),
            formStackView.leadingAnchor.constraint(equalTo: cardBody.leadingAnchor, constant: 16),
            formStackView.trailingAnchor.constraint(equalTo: cardBody.trailingAnchor, constant: -16),
            formStackView.bottomAnchor.constraint(equalTo: cardBody.bottomAnchor, constant: -16),

            cardBottomBar.topAnchor.constraint(equalTo: cardBody.bottomAnchor),
            cardBottomBar.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            cardBottomBar.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            cardBottomBar.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor),
            cardBottomBar.heightAnchor.constraint(equalToConstant: 54),

            versionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    // MARK: - Row 1: Trust Code
    private func buildTrustCodeRow() {
        trustCodeRowView.translatesAutoresizingMaskIntoConstraints = false

        trustBadgeIcon.translatesAutoresizingMaskIntoConstraints = false
        trustBadgeIcon.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 0.85)
        trustBadgeIcon.layer.cornerRadius = 6
        trustBadgeIcon.layer.masksToBounds = true
        trustCodeRowView.addSubview(trustBadgeIcon)

        trustBadgeSubIcon.translatesAutoresizingMaskIntoConstraints = false
        trustBadgeSubIcon.image = UIImage(systemName: "person.crop.rectangle.fill") ?? UIImage(systemName: "person.fill")
        trustBadgeSubIcon.tintColor = .white
        trustBadgeSubIcon.contentMode = .scaleAspectFit
        trustBadgeIcon.addSubview(trustBadgeSubIcon)

        trustTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        trustTitleLabel.attributedText = createRequiredLabel("Trust/Institution code")
        trustCodeRowView.addSubview(trustTitleLabel)

        trustCodeField.translatesAutoresizingMaskIntoConstraints = false
        trustCodeField.placeholder = "Type your trust code"
        trustCodeField.text = "SAT6677"
        trustCodeField.textColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        trustCodeField.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        trustCodeField.autocapitalizationType = .allCharacters
        trustCodeField.autocorrectionType = .no
        trustCodeField.returnKeyType = .next
        trustCodeField.delegate = self
        trustCodeField.addTarget(self, action: #selector(trustCodeChanged), for: .editingChanged)
        trustCodeRowView.addSubview(trustCodeField)

        trustUnderline.translatesAutoresizingMaskIntoConstraints = false
        trustUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        trustCodeRowView.addSubview(trustUnderline)

        trustErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        trustErrorLabel.textColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
        trustErrorLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        trustErrorLabel.numberOfLines = 0
        trustErrorLabel.isHidden = true
        trustCodeRowView.addSubview(trustErrorLabel)

        trustCheckmark.translatesAutoresizingMaskIntoConstraints = false
        trustCheckmark.image = UIImage(systemName: "checkmark")
        trustCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        trustCheckmark.isHidden = true
        trustCodeRowView.addSubview(trustCheckmark)

        trustArrowButton.translatesAutoresizingMaskIntoConstraints = false
        trustArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        trustArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        trustArrowButton.addTarget(self, action: #selector(handleTrustCodeSubmit), for: .touchUpInside)
        trustCodeRowView.addSubview(trustArrowButton)

        trustInfoButton.translatesAutoresizingMaskIntoConstraints = false
        trustInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        trustInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        trustInfoButton.addTarget(self, action: #selector(showTrustInfo), for: .touchUpInside)
        trustCodeRowView.addSubview(trustInfoButton)

        trustSpinner.translatesAutoresizingMaskIntoConstraints = false
        trustSpinner.hidesWhenStopped = true
        trustSpinner.color = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        trustCodeRowView.addSubview(trustSpinner)

        NSLayoutConstraint.activate([
            trustBadgeIcon.leadingAnchor.constraint(equalTo: trustCodeRowView.leadingAnchor),
            trustBadgeIcon.topAnchor.constraint(equalTo: trustCodeRowView.topAnchor, constant: 4),
            trustBadgeIcon.widthAnchor.constraint(equalToConstant: 34),
            trustBadgeIcon.heightAnchor.constraint(equalToConstant: 24),

            trustBadgeSubIcon.centerXAnchor.constraint(equalTo: trustBadgeIcon.centerXAnchor),
            trustBadgeSubIcon.centerYAnchor.constraint(equalTo: trustBadgeIcon.centerYAnchor),
            trustBadgeSubIcon.widthAnchor.constraint(equalToConstant: 20),
            trustBadgeSubIcon.heightAnchor.constraint(equalToConstant: 16),

            trustTitleLabel.leadingAnchor.constraint(equalTo: trustBadgeIcon.trailingAnchor, constant: 12),
            trustTitleLabel.topAnchor.constraint(equalTo: trustCodeRowView.topAnchor),
            trustTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trustCheckmark.leadingAnchor, constant: -6),

            trustCodeField.leadingAnchor.constraint(equalTo: trustBadgeIcon.trailingAnchor, constant: 12),
            trustCodeField.topAnchor.constraint(equalTo: trustTitleLabel.bottomAnchor, constant: 4),
            trustCodeField.trailingAnchor.constraint(equalTo: trustCheckmark.leadingAnchor, constant: -8),
            trustCodeField.heightAnchor.constraint(equalToConstant: 28),

            trustUnderline.leadingAnchor.constraint(equalTo: trustCodeField.leadingAnchor),
            trustUnderline.trailingAnchor.constraint(equalTo: trustCodeField.trailingAnchor),
            trustUnderline.topAnchor.constraint(equalTo: trustCodeField.bottomAnchor, constant: 2),
            trustUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            trustErrorLabel.leadingAnchor.constraint(equalTo: trustCodeField.leadingAnchor),
            trustErrorLabel.trailingAnchor.constraint(equalTo: trustCodeRowView.trailingAnchor),
            trustErrorLabel.topAnchor.constraint(equalTo: trustUnderline.bottomAnchor, constant: 3),
            trustErrorLabel.bottomAnchor.constraint(equalTo: trustCodeRowView.bottomAnchor, constant: -2),

            trustInfoButton.trailingAnchor.constraint(equalTo: trustCodeRowView.trailingAnchor),
            trustInfoButton.centerYAnchor.constraint(equalTo: trustBadgeIcon.centerYAnchor),
            trustInfoButton.widthAnchor.constraint(equalToConstant: 26),
            trustInfoButton.heightAnchor.constraint(equalToConstant: 26),

            trustArrowButton.trailingAnchor.constraint(equalTo: trustInfoButton.leadingAnchor, constant: -8),
            trustArrowButton.centerYAnchor.constraint(equalTo: trustBadgeIcon.centerYAnchor),
            trustArrowButton.widthAnchor.constraint(equalToConstant: 26),
            trustArrowButton.heightAnchor.constraint(equalToConstant: 26),

            trustCheckmark.trailingAnchor.constraint(equalTo: trustArrowButton.leadingAnchor, constant: -8),
            trustCheckmark.centerYAnchor.constraint(equalTo: trustBadgeIcon.centerYAnchor),
            trustCheckmark.widthAnchor.constraint(equalToConstant: 20),
            trustCheckmark.heightAnchor.constraint(equalToConstant: 20),

            trustSpinner.centerXAnchor.constraint(equalTo: trustArrowButton.centerXAnchor),
            trustSpinner.centerYAnchor.constraint(equalTo: trustArrowButton.centerYAnchor)
        ])

        formStackView.addArrangedSubview(trustCodeRowView)
    }

    // MARK: - Row 2: Trust Emblem Logo
    private func buildLogoRow() {
        trustLogoContainer.translatesAutoresizingMaskIntoConstraints = false

        trustLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        if let img = UIImage(named: "AppIcon-1024") ?? UIImage(named: "AppIcon") {
            trustLogoImageView.image = img
        } else {
            trustLogoImageView.image = UIImage(systemName: "seal.fill")
        }
        trustLogoImageView.contentMode = .scaleAspectFit
        trustLogoImageView.layer.cornerRadius = 14
        trustLogoImageView.layer.masksToBounds = true
        trustLogoContainer.addSubview(trustLogoImageView)

        trustNameLabel.translatesAutoresizingMaskIntoConstraints = false
        trustNameLabel.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        trustNameLabel.font = UIFont.systemFont(ofSize: 13.5, weight: .bold)
        trustNameLabel.textAlignment = .center
        trustNameLabel.numberOfLines = 2
        trustNameLabel.isHidden = true
        trustLogoContainer.addSubview(trustNameLabel)

        NSLayoutConstraint.activate([
            trustLogoImageView.topAnchor.constraint(equalTo: trustLogoContainer.topAnchor, constant: 4),
            trustLogoImageView.centerXAnchor.constraint(equalTo: trustLogoContainer.centerXAnchor),
            trustLogoImageView.widthAnchor.constraint(equalToConstant: 105),
            trustLogoImageView.heightAnchor.constraint(equalToConstant: 105),

            trustNameLabel.topAnchor.constraint(equalTo: trustLogoImageView.bottomAnchor, constant: 6),
            trustNameLabel.leadingAnchor.constraint(equalTo: trustLogoContainer.leadingAnchor),
            trustNameLabel.trailingAnchor.constraint(equalTo: trustLogoContainer.trailingAnchor),
            trustNameLabel.bottomAnchor.constraint(equalTo: trustLogoContainer.bottomAnchor, constant: -2)
        ])

        formStackView.addArrangedSubview(trustLogoContainer)
    }

    // MARK: - Row 3: Email
    private func buildEmailRow() {
        emailRowView.translatesAutoresizingMaskIntoConstraints = false

        emailIcon.translatesAutoresizingMaskIntoConstraints = false
        emailIcon.image = UIImage(systemName: "envelope.fill")
        emailIcon.tintColor = UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0)
        emailRowView.addSubview(emailIcon)

        emailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTitleLabel.attributedText = createRequiredLabel("Email")
        emailRowView.addSubview(emailTitleLabel)

        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.placeholder = "Type your email address"
        emailField.textColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        emailField.font = UIFont.systemFont(ofSize: 14.5, weight: .regular)
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.keyboardType = .emailAddress
        emailField.returnKeyType = .next
        emailField.delegate = self
        emailField.addTarget(self, action: #selector(emailFieldChanged), for: .editingChanged)
        emailRowView.addSubview(emailField)

        emailUnderline.translatesAutoresizingMaskIntoConstraints = false
        emailUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        emailRowView.addSubview(emailUnderline)

        emailErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        emailErrorLabel.textColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
        emailErrorLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emailErrorLabel.numberOfLines = 0
        emailErrorLabel.isHidden = true
        emailRowView.addSubview(emailErrorLabel)

        emailCheckmark.translatesAutoresizingMaskIntoConstraints = false
        emailCheckmark.image = UIImage(systemName: "checkmark")
        emailCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        emailCheckmark.isHidden = true
        emailRowView.addSubview(emailCheckmark)

        emailArrowButton.translatesAutoresizingMaskIntoConstraints = false
        emailArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        emailArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        emailArrowButton.addTarget(self, action: #selector(handleEmailSubmit), for: .touchUpInside)
        emailRowView.addSubview(emailArrowButton)

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
            emailUnderline.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            emailUnderline.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 2),
            emailUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            emailErrorLabel.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            emailErrorLabel.trailingAnchor.constraint(equalTo: emailRowView.trailingAnchor),
            emailErrorLabel.topAnchor.constraint(equalTo: emailUnderline.bottomAnchor, constant: 3),
            emailErrorLabel.bottomAnchor.constraint(equalTo: emailRowView.bottomAnchor, constant: -2),

            emailArrowButton.trailingAnchor.constraint(equalTo: emailRowView.trailingAnchor),
            emailArrowButton.centerYAnchor.constraint(equalTo: emailIcon.centerYAnchor),
            emailArrowButton.widthAnchor.constraint(equalToConstant: 26),
            emailArrowButton.heightAnchor.constraint(equalToConstant: 26),

            emailCheckmark.trailingAnchor.constraint(equalTo: emailArrowButton.leadingAnchor, constant: -8),
            emailCheckmark.centerYAnchor.constraint(equalTo: emailIcon.centerYAnchor),
            emailCheckmark.widthAnchor.constraint(equalToConstant: 20),
            emailCheckmark.heightAnchor.constraint(equalToConstant: 20),

            emailSpinner.centerXAnchor.constraint(equalTo: emailArrowButton.centerXAnchor),
            emailSpinner.centerYAnchor.constraint(equalTo: emailArrowButton.centerYAnchor)
        ])

        formStackView.addArrangedSubview(emailRowView)
    }

    // MARK: - Row 4: Mobile Phone
    private func buildMobileRow() {
        mobileRowView.translatesAutoresizingMaskIntoConstraints = false

        mobileIcon.translatesAutoresizingMaskIntoConstraints = false
        mobileIcon.image = UIImage(systemName: "hand.tap.fill") ?? UIImage(systemName: "phone.fill")
        mobileIcon.tintColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1.0)
        mobileRowView.addSubview(mobileIcon)

        mobileTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        mobileTitleLabel.attributedText = createRequiredLabel("Mobile phone")
        mobileRowView.addSubview(mobileTitleLabel)

        mobileField.translatesAutoresizingMaskIntoConstraints = false
        mobileField.placeholder = "Type your 10-digit mobile"
        mobileField.textColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        mobileField.font = UIFont.systemFont(ofSize: 14.5, weight: .regular)
        mobileField.keyboardType = .phonePad
        mobileField.delegate = self
        mobileField.addTarget(self, action: #selector(mobileFieldChanged), for: .editingChanged)
        mobileRowView.addSubview(mobileField)

        mobileUnderline.translatesAutoresizingMaskIntoConstraints = false
        mobileUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        mobileRowView.addSubview(mobileUnderline)

        mobileErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        mobileErrorLabel.textColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
        mobileErrorLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        mobileErrorLabel.numberOfLines = 0
        mobileErrorLabel.isHidden = true
        mobileRowView.addSubview(mobileErrorLabel)

        mobileCheckmark.translatesAutoresizingMaskIntoConstraints = false
        mobileCheckmark.image = UIImage(systemName: "checkmark")
        mobileCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        mobileCheckmark.isHidden = true
        mobileRowView.addSubview(mobileCheckmark)

        mobileArrowButton.translatesAutoresizingMaskIntoConstraints = false
        mobileArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        mobileArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        mobileArrowButton.addTarget(self, action: #selector(handleMobileSubmitAndSendOTP), for: .touchUpInside)
        mobileRowView.addSubview(mobileArrowButton)

        mobileInfoButton.translatesAutoresizingMaskIntoConstraints = false
        mobileInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        mobileInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        mobileInfoButton.addTarget(self, action: #selector(showMobileInfo), for: .touchUpInside)
        mobileRowView.addSubview(mobileInfoButton)

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

            mobileErrorLabel.leadingAnchor.constraint(equalTo: mobileField.leadingAnchor),
            mobileErrorLabel.trailingAnchor.constraint(equalTo: mobileRowView.trailingAnchor),
            mobileErrorLabel.topAnchor.constraint(equalTo: mobileUnderline.bottomAnchor, constant: 3),
            mobileErrorLabel.bottomAnchor.constraint(equalTo: mobileRowView.bottomAnchor, constant: -2),

            mobileInfoButton.trailingAnchor.constraint(equalTo: mobileRowView.trailingAnchor),
            mobileInfoButton.centerYAnchor.constraint(equalTo: mobileIcon.centerYAnchor),
            mobileInfoButton.widthAnchor.constraint(equalToConstant: 26),
            mobileInfoButton.heightAnchor.constraint(equalToConstant: 26),

            mobileArrowButton.trailingAnchor.constraint(equalTo: mobileInfoButton.leadingAnchor, constant: -8),
            mobileArrowButton.centerYAnchor.constraint(equalTo: mobileIcon.centerYAnchor),
            mobileArrowButton.widthAnchor.constraint(equalToConstant: 26),
            mobileArrowButton.heightAnchor.constraint(equalToConstant: 26),

            mobileCheckmark.trailingAnchor.constraint(equalTo: mobileArrowButton.leadingAnchor, constant: -8),
            mobileCheckmark.centerYAnchor.constraint(equalTo: mobileIcon.centerYAnchor),
            mobileCheckmark.widthAnchor.constraint(equalToConstant: 20),
            mobileCheckmark.heightAnchor.constraint(equalToConstant: 20),

            mobileSpinner.centerXAnchor.constraint(equalTo: mobileArrowButton.centerXAnchor),
            mobileSpinner.centerYAnchor.constraint(equalTo: mobileArrowButton.centerYAnchor)
        ])

        formStackView.addArrangedSubview(mobileRowView)
    }

    // MARK: - Row 5: Parent Code
    private func buildParentCodeRow() {
        parentRowView.translatesAutoresizingMaskIntoConstraints = false

        parentIcon.translatesAutoresizingMaskIntoConstraints = false
        parentIcon.image = UIImage(systemName: "person.crop.circle.badge.checkmark") ?? UIImage(systemName: "person.fill")
        parentIcon.tintColor = UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0)
        parentRowView.addSubview(parentIcon)

        parentTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        parentTitleLabel.attributedText = createRequiredLabel("Enter Main/Parent Branch Code#")
        parentRowView.addSubview(parentTitleLabel)

        parentCodeField.translatesAutoresizingMaskIntoConstraints = false
        parentCodeField.placeholder = "Enter parent code (e.g. 6 or SAT6677)"
        parentCodeField.textColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        parentCodeField.font = UIFont.systemFont(ofSize: 14.5, weight: .regular)
        parentCodeField.autocapitalizationType = .allCharacters
        parentCodeField.delegate = self
        parentCodeField.addTarget(self, action: #selector(parentCodeChanged), for: .editingChanged)
        parentRowView.addSubview(parentCodeField)

        parentUnderline.translatesAutoresizingMaskIntoConstraints = false
        parentUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        parentRowView.addSubview(parentUnderline)

        parentErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        parentErrorLabel.textColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
        parentErrorLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        parentErrorLabel.numberOfLines = 0
        parentErrorLabel.isHidden = true
        parentRowView.addSubview(parentErrorLabel)

        parentCheckmark.translatesAutoresizingMaskIntoConstraints = false
        parentCheckmark.image = UIImage(systemName: "checkmark")
        parentCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        parentCheckmark.isHidden = true
        parentRowView.addSubview(parentCheckmark)

        parentArrowButton.translatesAutoresizingMaskIntoConstraints = false
        parentArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        parentArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        parentArrowButton.addTarget(self, action: #selector(handleParentCodeSubmit), for: .touchUpInside)
        parentRowView.addSubview(parentArrowButton)

        parentInfoButton.translatesAutoresizingMaskIntoConstraints = false
        parentInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        parentInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        parentInfoButton.addTarget(self, action: #selector(showParentInfo), for: .touchUpInside)
        parentRowView.addSubview(parentInfoButton)

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
            parentCodeField.trailingAnchor.constraint(equalTo: parentCheckmark.leadingAnchor, constant: -8),
            parentCodeField.heightAnchor.constraint(equalToConstant: 28),

            parentUnderline.leadingAnchor.constraint(equalTo: parentCodeField.leadingAnchor),
            parentUnderline.trailingAnchor.constraint(equalTo: parentCodeField.trailingAnchor),
            parentUnderline.topAnchor.constraint(equalTo: parentCodeField.bottomAnchor, constant: 2),
            parentUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            parentErrorLabel.leadingAnchor.constraint(equalTo: parentCodeField.leadingAnchor),
            parentErrorLabel.trailingAnchor.constraint(equalTo: parentRowView.trailingAnchor),
            parentErrorLabel.topAnchor.constraint(equalTo: parentUnderline.bottomAnchor, constant: 3),
            parentErrorLabel.bottomAnchor.constraint(equalTo: parentRowView.bottomAnchor, constant: -2),

            parentInfoButton.trailingAnchor.constraint(equalTo: parentRowView.trailingAnchor),
            parentInfoButton.centerYAnchor.constraint(equalTo: parentIcon.centerYAnchor),
            parentInfoButton.widthAnchor.constraint(equalToConstant: 26),
            parentInfoButton.heightAnchor.constraint(equalToConstant: 26),

            parentArrowButton.trailingAnchor.constraint(equalTo: parentInfoButton.leadingAnchor, constant: -8),
            parentArrowButton.centerYAnchor.constraint(equalTo: parentIcon.centerYAnchor),
            parentArrowButton.widthAnchor.constraint(equalToConstant: 26),
            parentArrowButton.heightAnchor.constraint(equalToConstant: 26),

            parentCheckmark.trailingAnchor.constraint(equalTo: parentArrowButton.leadingAnchor, constant: -8),
            parentCheckmark.centerYAnchor.constraint(equalTo: parentIcon.centerYAnchor),
            parentCheckmark.widthAnchor.constraint(equalToConstant: 20),
            parentCheckmark.heightAnchor.constraint(equalToConstant: 20),

            parentSpinner.centerXAnchor.constraint(equalTo: parentArrowButton.centerXAnchor),
            parentSpinner.centerYAnchor.constraint(equalTo: parentArrowButton.centerYAnchor)
        ])

        formStackView.addArrangedSubview(parentRowView)
    }

    // MARK: - Phase 2: User Details Form
    private func buildUserDetailsSection() {
        userDetailsSectionView.translatesAutoresizingMaskIntoConstraints = false
        userDetailsSectionView.isHidden = true

        // Verified Trust Header Badge
        verifiedTrustHeaderBadge.translatesAutoresizingMaskIntoConstraints = false
        verifiedTrustHeaderBadge.backgroundColor = UIColor(red: 232/255, green: 240/255, blue: 254/255, alpha: 1.0)
        verifiedTrustHeaderBadge.layer.cornerRadius = 8
        verifiedTrustHeaderBadge.layer.masksToBounds = true
        userDetailsSectionView.addSubview(verifiedTrustHeaderBadge)

        verifiedTrustHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        verifiedTrustHeaderLabel.text = "🏛️ SHRI ANANDPUR TRUST"
        verifiedTrustHeaderLabel.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        verifiedTrustHeaderLabel.font = UIFont.systemFont(ofSize: 13.5, weight: .bold)
        verifiedTrustHeaderLabel.textAlignment = .center
        verifiedTrustHeaderBadge.addSubview(verifiedTrustHeaderLabel)

        // Salutation / Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.attributedText = createRequiredLabel("Salutation / Title")
        userDetailsSectionView.addSubview(titleLabel)

        titlePickerField.translatesAutoresizingMaskIntoConstraints = false
        titlePickerField.text = "Mr"
        titlePickerField.textColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        titlePickerField.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titlePickerView.delegate = self
        titlePickerView.dataSource = self
        titlePickerField.inputView = titlePickerView
        userDetailsSectionView.addSubview(titlePickerField)

        titleUnderline.translatesAutoresizingMaskIntoConstraints = false
        titleUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        userDetailsSectionView.addSubview(titleUnderline)

        // First Name
        let fnameLabel = UILabel()
        fnameLabel.translatesAutoresizingMaskIntoConstraints = false
        fnameLabel.attributedText = createRequiredLabel("First Name")
        userDetailsSectionView.addSubview(fnameLabel)

        fnameField.translatesAutoresizingMaskIntoConstraints = false
        fnameField.placeholder = "Enter first name"
        fnameField.textColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        fnameField.font = UIFont.systemFont(ofSize: 14.5, weight: .regular)
        fnameField.returnKeyType = .next
        fnameField.delegate = self
        fnameField.addTarget(self, action: #selector(fnameChanged), for: .editingChanged)
        userDetailsSectionView.addSubview(fnameField)

        fnameUnderline.translatesAutoresizingMaskIntoConstraints = false
        fnameUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        userDetailsSectionView.addSubview(fnameUnderline)

        fnameErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        fnameErrorLabel.textColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
        fnameErrorLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        fnameErrorLabel.isHidden = true
        userDetailsSectionView.addSubview(fnameErrorLabel)

        // Last Name
        let lnameLabel = UILabel()
        lnameLabel.translatesAutoresizingMaskIntoConstraints = false
        lnameLabel.attributedText = createRequiredLabel("Last Name")
        userDetailsSectionView.addSubview(lnameLabel)

        lnameField.translatesAutoresizingMaskIntoConstraints = false
        lnameField.placeholder = "Enter last name"
        lnameField.textColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        lnameField.font = UIFont.systemFont(ofSize: 14.5, weight: .regular)
        lnameField.returnKeyType = .next
        lnameField.delegate = self
        lnameField.addTarget(self, action: #selector(lnameChanged), for: .editingChanged)
        userDetailsSectionView.addSubview(lnameField)

        lnameUnderline.translatesAutoresizingMaskIntoConstraints = false
        lnameUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        userDetailsSectionView.addSubview(lnameUnderline)

        lnameErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        lnameErrorLabel.textColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
        lnameErrorLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lnameErrorLabel.isHidden = true
        userDetailsSectionView.addSubview(lnameErrorLabel)

        // Password
        let passwordLabel = UILabel()
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.attributedText = createRequiredLabel("Password")
        userDetailsSectionView.addSubview(passwordLabel)

        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.placeholder = "Minimum 6 characters"
        passwordField.textColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        passwordField.font = UIFont.systemFont(ofSize: 14.5, weight: .regular)
        passwordField.isSecureTextEntry = true
        passwordField.returnKeyType = .done
        passwordField.delegate = self
        passwordField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        userDetailsSectionView.addSubview(passwordField)

        showPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        showPasswordButton.setTitle("Show", for: .normal)
        showPasswordButton.setTitleColor(UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0), for: .normal)
        showPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        showPasswordButton.addTarget(self, action: #selector(toggleShowPassword), for: .touchUpInside)
        userDetailsSectionView.addSubview(showPasswordButton)

        passwordUnderline.translatesAutoresizingMaskIntoConstraints = false
        passwordUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        userDetailsSectionView.addSubview(passwordUnderline)

        passwordErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordErrorLabel.textColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
        passwordErrorLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        passwordErrorLabel.isHidden = true
        userDetailsSectionView.addSubview(passwordErrorLabel)

        // Gender Selection
        genderContainer.translatesAutoresizingMaskIntoConstraints = false
        userDetailsSectionView.addSubview(genderContainer)

        let genderTitle = UILabel()
        genderTitle.translatesAutoresizingMaskIntoConstraints = false
        genderTitle.text = "Gender"
        genderTitle.textColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        genderTitle.font = UIFont.systemFont(ofSize: 14.5, weight: .bold)
        genderContainer.addSubview(genderTitle)

        maleRadioButton.translatesAutoresizingMaskIntoConstraints = false
        maleRadioButton.setTitle(" 🔘 Male", for: .normal)
        maleRadioButton.setTitleColor(UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0), for: .normal)
        maleRadioButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.5, weight: .semibold)
        maleRadioButton.addTarget(self, action: #selector(selectMale), for: .touchUpInside)
        genderContainer.addSubview(maleRadioButton)

        femaleRadioButton.translatesAutoresizingMaskIntoConstraints = false
        femaleRadioButton.setTitle(" ⚪ Female", for: .normal)
        femaleRadioButton.setTitleColor(UIColor(red: 100/255, green: 110/255, blue: 120/255, alpha: 1.0), for: .normal)
        femaleRadioButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.5, weight: .semibold)
        femaleRadioButton.addTarget(self, action: #selector(selectFemale), for: .touchUpInside)
        genderContainer.addSubview(femaleRadioButton)

        NSLayoutConstraint.activate([
            verifiedTrustHeaderBadge.topAnchor.constraint(equalTo: userDetailsSectionView.topAnchor),
            verifiedTrustHeaderBadge.leadingAnchor.constraint(equalTo: userDetailsSectionView.leadingAnchor),
            verifiedTrustHeaderBadge.trailingAnchor.constraint(equalTo: userDetailsSectionView.trailingAnchor),
            verifiedTrustHeaderBadge.heightAnchor.constraint(equalToConstant: 38),

            verifiedTrustHeaderLabel.centerXAnchor.constraint(equalTo: verifiedTrustHeaderBadge.centerXAnchor),
            verifiedTrustHeaderLabel.centerYAnchor.constraint(equalTo: verifiedTrustHeaderBadge.centerYAnchor),

            // Salutation / Title
            titleLabel.topAnchor.constraint(equalTo: verifiedTrustHeaderBadge.bottomAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: userDetailsSectionView.leadingAnchor),

            titlePickerField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            titlePickerField.leadingAnchor.constraint(equalTo: userDetailsSectionView.leadingAnchor),
            titlePickerField.trailingAnchor.constraint(equalTo: userDetailsSectionView.trailingAnchor),
            titlePickerField.heightAnchor.constraint(equalToConstant: 28),

            titleUnderline.topAnchor.constraint(equalTo: titlePickerField.bottomAnchor, constant: 2),
            titleUnderline.leadingAnchor.constraint(equalTo: userDetailsSectionView.leadingAnchor),
            titleUnderline.trailingAnchor.constraint(equalTo: userDetailsSectionView.trailingAnchor),
            titleUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            // First Name
            fnameLabel.topAnchor.constraint(equalTo: titleUnderline.bottomAnchor, constant: 14),
            fnameLabel.leadingAnchor.constraint(equalTo: userDetailsSectionView.leadingAnchor),

            fnameField.topAnchor.constraint(equalTo: fnameLabel.bottomAnchor, constant: 4),
            fnameField.leadingAnchor.constraint(equalTo: userDetailsSectionView.leadingAnchor),
            fnameField.trailingAnchor.constraint(equalTo: userDetailsSectionView.trailingAnchor),
            fnameField.heightAnchor.constraint(equalToConstant: 28),

            fnameUnderline.topAnchor.constraint(equalTo: fnameField.bottomAnchor, constant: 2),
            fnameUnderline.leadingAnchor.constraint(equalTo: userDetailsSectionView.leadingAnchor),
            fnameUnderline.trailingAnchor.constraint(equalTo: userDetailsSectionView.trailingAnchor),
            fnameUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            fnameErrorLabel.topAnchor.constraint(equalTo: fnameUnderline.bottomAnchor, constant: 3),
            fnameErrorLabel.leadingAnchor.constraint(equalTo: userDetailsSectionView.leadingAnchor),
            fnameErrorLabel.trailingAnchor.constraint(equalTo: userDetailsSectionView.trailingAnchor),

            // Last Name
            lnameLabel.topAnchor.constraint(equalTo: fnameUnderline.bottomAnchor, constant: 18),
            lnameLabel.leadingAnchor.constraint(equalTo: userDetailsSectionView.leadingAnchor),

            lnameField.topAnchor.constraint(equalTo: lnameLabel.bottomAnchor, constant: 4),
            lnameField.leadingAnchor.constraint(equalTo: userDetailsSectionView.leadingAnchor),
            lnameField.trailingAnchor.constraint(equalTo: userDetailsSectionView.trailingAnchor),
            lnameField.heightAnchor.constraint(equalToConstant: 28),

            lnameUnderline.topAnchor.constraint(equalTo: lnameField.bottomAnchor, constant: 2),
            lnameUnderline.leadingAnchor.constraint(equalTo: userDetailsSectionView.leadingAnchor),
            lnameUnderline.trailingAnchor.constraint(equalTo: userDetailsSectionView.trailingAnchor),
            lnameUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            lnameErrorLabel.topAnchor.constraint(equalTo: lnameUnderline.bottomAnchor, constant: 3),
            lnameErrorLabel.leadingAnchor.constraint(equalTo: userDetailsSectionView.leadingAnchor),
            lnameErrorLabel.trailingAnchor.constraint(equalTo: userDetailsSectionView.trailingAnchor),

            // Password
            passwordLabel.topAnchor.constraint(equalTo: lnameUnderline.bottomAnchor, constant: 18),
            passwordLabel.leadingAnchor.constraint(equalTo: userDetailsSectionView.leadingAnchor),

            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 4),
            passwordField.leadingAnchor.constraint(equalTo: userDetailsSectionView.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: showPasswordButton.leadingAnchor, constant: -8),
            passwordField.heightAnchor.constraint(equalToConstant: 28),

            showPasswordButton.trailingAnchor.constraint(equalTo: userDetailsSectionView.trailingAnchor),
            showPasswordButton.centerYAnchor.constraint(equalTo: passwordField.centerYAnchor),
            showPasswordButton.widthAnchor.constraint(equalToConstant: 50),

            passwordUnderline.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 2),
            passwordUnderline.leadingAnchor.constraint(equalTo: userDetailsSectionView.leadingAnchor),
            passwordUnderline.trailingAnchor.constraint(equalTo: userDetailsSectionView.trailingAnchor),
            passwordUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            passwordErrorLabel.topAnchor.constraint(equalTo: passwordUnderline.bottomAnchor, constant: 3),
            passwordErrorLabel.leadingAnchor.constraint(equalTo: userDetailsSectionView.leadingAnchor),
            passwordErrorLabel.trailingAnchor.constraint(equalTo: userDetailsSectionView.trailingAnchor),

            // Gender
            genderContainer.topAnchor.constraint(equalTo: passwordUnderline.bottomAnchor, constant: 18),
            genderContainer.leadingAnchor.constraint(equalTo: userDetailsSectionView.leadingAnchor),
            genderContainer.trailingAnchor.constraint(equalTo: userDetailsSectionView.trailingAnchor),
            genderContainer.bottomAnchor.constraint(equalTo: userDetailsSectionView.bottomAnchor, constant: -4),

            genderTitle.leadingAnchor.constraint(equalTo: genderContainer.leadingAnchor),
            genderTitle.centerYAnchor.constraint(equalTo: genderContainer.centerYAnchor),

            maleRadioButton.leadingAnchor.constraint(equalTo: genderTitle.trailingAnchor, constant: 20),
            maleRadioButton.centerYAnchor.constraint(equalTo: genderContainer.centerYAnchor),

            femaleRadioButton.leadingAnchor.constraint(equalTo: maleRadioButton.trailingAnchor, constant: 20),
            femaleRadioButton.centerYAnchor.constraint(equalTo: genderContainer.centerYAnchor)
        ])

        formStackView.addArrangedSubview(userDetailsSectionView)
    }

    // MARK: - Bottom Action Bar
    private func buildBottomActionBar() {
        cardBottomBar.translatesAutoresizingMaskIntoConstraints = false
        cardBottomBar.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cancelButton.addTarget(self, action: #selector(handleCancelTap), for: .touchUpInside)
        cardBottomBar.addSubview(cancelButton)

        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setTitle("Register Branch  ➔", for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        actionButton.addTarget(self, action: #selector(handleActionTap), for: .touchUpInside)
        cardBottomBar.addSubview(actionButton)

        actionSpinner.translatesAutoresizingMaskIntoConstraints = false
        actionSpinner.hidesWhenStopped = true
        actionSpinner.color = .white
        cardBottomBar.addSubview(actionSpinner)

        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: cardBottomBar.leadingAnchor, constant: 20),
            cancelButton.centerYAnchor.constraint(equalTo: cardBottomBar.centerYAnchor),

            actionButton.trailingAnchor.constraint(equalTo: cardBottomBar.trailingAnchor, constant: -20),
            actionButton.centerYAnchor.constraint(equalTo: cardBottomBar.centerYAnchor),

            actionSpinner.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            actionSpinner.centerXAnchor.constraint(equalTo: actionButton.centerXAnchor)
        ])
    }

    // MARK: - OTP Modal Overlay
    private func setupOTPOverlayUI() {
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
        otpInputField.addTarget(self, action: #selector(otpFieldChanged), for: .editingChanged)
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

    // MARK: - Error Handlers & Real-time Clearing
    private func showBannerError(_ msg: String) {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        errorBannerLabel.text = msg
        errorBanner.isHidden = false
    }

    private func clearBannerError() {
        errorBanner.isHidden = true
    }

    @objc private func trustCodeChanged() {
        trustUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        trustErrorLabel.isHidden = true
        trustCheckmark.isHidden = true
        clearBannerError()
    }

    @objc private func emailFieldChanged() {
        emailUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        emailErrorLabel.isHidden = true
        emailCheckmark.isHidden = true
        clearBannerError()
    }

    @objc private func mobileFieldChanged() {
        mobileUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        mobileErrorLabel.isHidden = true
        mobileCheckmark.isHidden = true
        clearBannerError()
    }

    @objc private func parentCodeChanged() {
        parentUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        parentErrorLabel.isHidden = true
        parentCheckmark.isHidden = true
        clearBannerError()
    }

    @objc private func otpFieldChanged() {
        otpUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        otpErrorLabel.isHidden = true
    }

    @objc private func fnameChanged() {
        fnameUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        fnameErrorLabel.isHidden = true
        clearBannerError()
    }

    @objc private func lnameChanged() {
        lnameUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        lnameErrorLabel.isHidden = true
        clearBannerError()
    }

    @objc private func passwordChanged() {
        passwordUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        passwordErrorLabel.isHidden = true
        clearBannerError()
    }

    // MARK: - Step 1: Trust Code Verification (POST /api/check-trust-code)
    @objc private func handleTrustCodeSubmit() {
        view.endEditing(true)
        let code = trustCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !code.isEmpty else {
            trustUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            trustErrorLabel.text = "Please enter valid trust code. Contact helpline."
            trustErrorLabel.isHidden = false
            showBannerError("Please enter your Trust/Institution code.")
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
                self?.trustArrowButton.isHidden = false
                self?.trustSpinner.stopAnimating()

                if let error = error {
                    self?.showBannerError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self?.showBannerError("Invalid response from server.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let message = json["message"] as? String ?? ""

                if status, let dataObj = json["data"] as? [String: Any], let merchantId = dataObj["id"] as? Int, merchantId > 0 {
                    self?.verifiedMerchantId = merchantId
                    self?.verifiedMerchantName = (dataObj["name"] as? String) ?? "SHRI ANANDPUR TRUST"
                    self?.verifiedRoleId = (dataObj["role_id"] as? Int) ?? 0
                    self?.isTrustCodeVerified = true
                    self?.trustCheckmark.isHidden = false
                    self?.trustErrorLabel.isHidden = true
                    self?.trustNameLabel.text = self?.verifiedMerchantName
                    self?.trustNameLabel.isHidden = false

                    if let titles = dataObj["MerchantTitle"] as? [[String: Any]], !titles.isEmpty {
                        let parsedTitles = titles.compactMap { $0["title"] as? String }.filter { !$0.isEmpty }
                        if !parsedTitles.isEmpty {
                            self?.availableTitles = parsedTitles
                            self?.selectedTitle = parsedTitles[0]
                            self?.titlePickerField.text = parsedTitles[0]
                            self?.titlePickerView.reloadAllComponents()
                        }
                    }

                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } else {
                    self?.trustUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
                    let err = message.isEmpty ? "Please enter valid trust code. Contact helpline." : message
                    self?.trustErrorLabel.text = err
                    self?.trustErrorLabel.isHidden = false
                    self?.showBannerError(err)
                }
            }
        }.resume()
    }

    // MARK: - Step 2: Email Validation (POST /api/check-email)
    @objc private func handleEmailSubmit() {
        view.endEditing(true)
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !email.isEmpty, email.contains("@"), email.contains(".") else {
            emailUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            emailErrorLabel.text = "Please enter a valid Email address."
            emailErrorLabel.isHidden = false
            showBannerError("Please enter a valid Email address.")
            return
        }

        emailArrowButton.isHidden = true
        emailSpinner.startAnimating()
        clearBannerError()

        guard let url = URL(string: AppConfig.API.checkEmail) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(AppConfig.apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let params = ["email": email, "device_type": AppConfig.deviceType]
        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.emailArrowButton.isHidden = false
                self?.emailSpinner.stopAnimating()

                if let error = error {
                    self?.showBannerError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self?.showBannerError("Invalid response from server.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let message = json["message"] as? String ?? ""

                if status {
                    self?.isEmailVerified = true
                    self?.emailCheckmark.isHidden = false
                    self?.emailErrorLabel.isHidden = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } else {
                    self?.emailUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
                    let err = message.isEmpty ? "This Email id is already registered." : message
                    self?.emailErrorLabel.text = err
                    self?.emailErrorLabel.isHidden = false
                    self?.showBannerError(err)
                }
            }
        }.resume()
    }

    // MARK: - Step 3: Mobile & OTP Dispatch (POST /api/register-otp-send)
    @objc private func handleMobileSubmitAndSendOTP() {
        view.endEditing(true)
        let mobile = mobileField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !mobile.isEmpty, mobile.count == 10 else {
            mobileUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            mobileErrorLabel.text = "Please enter a valid 10-digit mobile number."
            mobileErrorLabel.isHidden = false
            showBannerError("Please enter a valid 10-digit mobile number.")
            return
        }

        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trustCode = trustCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

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
            "merchant_id": "\(verifiedMerchantId > 0 ? verifiedMerchantId : 6)",
            "mobile_device_id": AppConfig.mobileDeviceId,
            "device_id": AppConfig.deviceId
        ]
        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.mobileArrowButton.isHidden = false
                self?.mobileSpinner.stopAnimating()

                if let error = error {
                    self?.showBannerError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self?.showBannerError("Invalid response from server.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let message = json["message"] as? String ?? ""

                if status {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    self?.presentOTPModal()
                } else {
                    self?.mobileUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
                    let err = message.isEmpty ? "Failed to send OTP. Please check mobile number." : message
                    self?.mobileErrorLabel.text = err
                    self?.mobileErrorLabel.isHidden = false
                    self?.showBannerError(err)
                }
            }
        }.resume()
    }

    // MARK: - Step 4: OTP Modal Verification (POST /api/check-register-otp)
    private func presentOTPModal() {
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
                let formatted = String(format: "00 : %02d", self.otpRemainingSeconds)
                self.otpTimerLabel.text = formatted
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
                self?.otpSpinner.stopAnimating()
                self?.otpVerifyButton.setTitle("Verify OTP", for: .normal)

                if let error = error {
                    self?.otpErrorLabel.text = "Network error: \(error.localizedDescription)"
                    self?.otpErrorLabel.isHidden = false
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self?.otpErrorLabel.text = "Invalid response from server."
                    self?.otpErrorLabel.isHidden = false
                    return
                }

                let status = json["status"] as? Bool ?? false
                let message = json["message"] as? String ?? ""

                if status {
                    self?.otpTimer?.invalidate()
                    self?.isMobileVerified = true
                    self?.mobileCheckmark.isHidden = false
                    self?.mobileErrorLabel.isHidden = true
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

                    UIView.animate(withDuration: 0.2, animations: {
                        self?.otpOverlayBackdrop.alpha = 0
                    }) { _ in
                        self?.otpOverlayBackdrop.isHidden = true
                    }
                    self?.parentCodeField.becomeFirstResponder()
                } else {
                    self?.otpUnderline.backgroundColor = UIColor(red: 255/255, green: 107/255, blue: 107/255, alpha: 1.0)
                    self?.otpErrorLabel.text = message.isEmpty ? "Invalid OTP code entered." : message
                    self?.otpErrorLabel.isHidden = false
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }.resume()
    }

    // MARK: - Step 5: Parent Code Validation (POST /api/check-trust-code)
    @objc private func handleParentCodeSubmit() {
        view.endEditing(true)
        let parentCode = parentCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !parentCode.isEmpty else {
            parentUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            parentErrorLabel.text = "Please enter Main/Parent Branch Code."
            parentErrorLabel.isHidden = false
            showBannerError("Please enter Main/Parent Branch Code.")
            return
        }

        parentArrowButton.isHidden = true
        parentSpinner.startAnimating()
        clearBannerError()

        guard let url = URL(string: AppConfig.API.checkTrustCode) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(AppConfig.apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let params = ["code": parentCode, "device_type": AppConfig.deviceType, "mobile_device_id": AppConfig.mobileDeviceId]
        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.parentArrowButton.isHidden = false
                self?.parentSpinner.stopAnimating()

                if let error = error {
                    self?.showBannerError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self?.showBannerError("Invalid response from server.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let message = json["message"] as? String ?? ""

                if status {
                    self?.isParentCodeVerified = true
                    self?.parentCheckmark.isHidden = false
                    self?.parentErrorLabel.isHidden = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } else {
                    self?.parentUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
                    let err = message.isEmpty ? "Invalid parent branch code." : message
                    self?.parentErrorLabel.text = err
                    self?.parentErrorLabel.isHidden = false
                    self?.showBannerError(err)
                }
            }
        }.resume()
    }

    // MARK: - Action Tap: Step 1 -> Step 2 -> Submit Final Registration
    @objc private func handleActionTap() {
        view.endEditing(true)
        if currentPhase == .step1Validation {
            guard isTrustCodeVerified else {
                handleTrustCodeSubmit()
                return
            }
            guard isEmailVerified else {
                handleEmailSubmit()
                return
            }
            guard isMobileVerified else {
                handleMobileSubmitAndSendOTP()
                return
            }

            let parentCode = parentCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !parentCode.isEmpty else {
                parentUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
                parentErrorLabel.text = "Please enter Main/Parent Branch Code."
                parentErrorLabel.isHidden = false
                showBannerError("Please enter Main/Parent Branch Code.")
                return
            }

            // Smooth transition to Phase 2
            currentPhase = .step2UserDetails
            UIView.animate(withDuration: 0.3) {
                self.trustCodeRowView.isHidden = true
                self.trustLogoContainer.isHidden = true
                self.emailRowView.isHidden = true
                self.mobileRowView.isHidden = true
                self.parentRowView.isHidden = true
                self.userDetailsSectionView.isHidden = false
                self.actionButton.setTitle("Create Account  ➔", for: .normal)
                self.verifiedTrustHeaderLabel.text = "🏛️ \(self.verifiedMerchantName.uppercased())"
            }
            fnameField.becomeFirstResponder()

        } else {
            // Validate Phase 2 details
            let fname = fnameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let lname = lnameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            var hasError = false
            if fname.isEmpty {
                fnameUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
                fnameErrorLabel.text = "First Name is required."
                fnameErrorLabel.isHidden = false
                hasError = true
            }

            if lname.isEmpty {
                lnameUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
                lnameErrorLabel.text = "Last Name is required."
                lnameErrorLabel.isHidden = false
                hasError = true
            }

            if password.count < 6 {
                passwordUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
                passwordErrorLabel.text = "Password must be at least 6 characters."
                passwordErrorLabel.isHidden = false
                hasError = true
            }

            if hasError {
                showBannerError("Please complete all required fields.")
                return
            }

            performFinalRegistration(fname: fname, lname: lname, password: password)
        }
    }

    // MARK: - Final Registration Network Call (POST /api/register)
    private func performFinalRegistration(fname: String, lname: String, password: String) {
        actionButton.setTitle("", for: .normal)
        actionSpinner.startAnimating()
        clearBannerError()

        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let mobile = mobileField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trustCode = trustCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard let url = URL(string: AppConfig.API.register) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(AppConfig.apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let params: [String: String] = [
            "fname": fname,
            "lname": lname,
            "mobile": mobile,
            "email": email,
            "password": password,
            "merchant_id": "\(verifiedMerchantId > 0 ? verifiedMerchantId : 6)",
            "trust_code": trustCode,
            "title": selectedTitle,
            "gender": "\(selectedGender)",
            "device_type": AppConfig.deviceType,
            "device_id": AppConfig.deviceId,
            "mobile_device_id": AppConfig.mobileDeviceId
        ]

        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.actionSpinner.stopAnimating()
                self?.actionButton.setTitle("Create Account  ➔", for: .normal)

                if let error = error {
                    self?.showBannerError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self?.showBannerError("Invalid server response.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let message = json["message"] as? String ?? ""

                if status {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    let alert = UIAlertController(
                        title: "Registration Successful!",
                        message: "Your account under \(self?.verifiedMerchantName ?? "Trust") has been created.\nYou can now log in.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Log In Now", style: .default) { [weak self] _ in
                        self?.dismiss(animated: true) {
                            self?.onSignUpSuccess?(email)
                        }
                    })
                    self?.present(alert, animated: true)
                } else {
                    self?.showBannerError(message.isEmpty ? "Registration failed. Please try again." : message)
                }
            }
        }.resume()
    }

    @objc private func handleCancelTap() {
        if currentPhase == .step2UserDetails {
            currentPhase = .step1Validation
            UIView.animate(withDuration: 0.25) {
                self.trustCodeRowView.isHidden = false
                self.trustLogoContainer.isHidden = false
                self.emailRowView.isHidden = false
                self.mobileRowView.isHidden = false
                self.parentRowView.isHidden = false
                self.userDetailsSectionView.isHidden = true
                self.actionButton.setTitle("Register Branch  ➔", for: .normal)
            }
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func toggleShowPassword() {
        passwordField.isSecureTextEntry.toggle()
        let title = passwordField.isSecureTextEntry ? "Show" : "Hide"
        showPasswordButton.setTitle(title, for: .normal)
    }

    @objc private func selectMale() {
        selectedGender = 1
        maleRadioButton.setTitle(" 🔘 Male", for: .normal)
        maleRadioButton.setTitleColor(UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0), for: .normal)
        femaleRadioButton.setTitle(" ⚪ Female", for: .normal)
        femaleRadioButton.setTitleColor(UIColor(red: 100/255, green: 110/255, blue: 120/255, alpha: 1.0), for: .normal)
    }

    @objc private func selectFemale() {
        selectedGender = 2
        femaleRadioButton.setTitle(" 🔘 Female", for: .normal)
        femaleRadioButton.setTitleColor(UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0), for: .normal)
        maleRadioButton.setTitle(" ⚪ Male", for: .normal)
        maleRadioButton.setTitleColor(UIColor(red: 100/255, green: 110/255, blue: 120/255, alpha: 1.0), for: .normal)
    }

    // MARK: - UIPickerViewDelegate & DataSource (Salutation / Title)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableTitles.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableTitles[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTitle = availableTitles[row]
        titlePickerField.text = selectedTitle
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
            handleEmailSubmit()
        } else if textField == mobileField {
            handleMobileSubmitAndSendOTP()
        } else if textField == parentCodeField {
            handleParentCodeSubmit()
        } else if textField == fnameField {
            lnameField.becomeFirstResponder()
        } else if textField == lnameField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            textField.resignFirstResponder()
            handleActionTap()
        }
        return true
    }
}
