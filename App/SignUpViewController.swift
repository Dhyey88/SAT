import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    var onSignUpSuccess: ((String) -> Void)?

    // MARK: - Progressive Steps
    private enum Step {
        case step1TrustCode // Enter and verify Trust/Institution Code
        case step2EmailMobileOTP // Enter Email, Mobile, and verify OTP
        case step3UserDetails // Enter Parent Code, Title, Name, Password, Gender
    }

    private var currentStep: Step = .step1TrustCode

    // Data State
    private var verifiedMerchantId: Int = 6
    private var verifiedMerchantName: String = "SHRI ANANDPUR TRUST"
    private var verifiedRoleId: Int = 0
    private var isOTPRequested = false

    private var availableTitles: [String] = ["Mr", "Mrs", "Ms", "Mh", "Bai", "Bh"]
    private var selectedTitle: String = "Mr"
    private var selectedGender: Int = 1 // 1 = Male, 2 = Female

    // OTP Countdown Timer
    private var otpTimer: Timer?
    private var otpRemainingSeconds = 30

    // MARK: - UI Containers
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let cardView = UIView()
    private let closeButton = UIButton(type: .system)

    // Header
    private let headerIconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stepIndicatorLabel = UILabel()
    private let errorBanner = UIView()
    private let errorLabel = UILabel()

    // MARK: - Step 1 Controls (Trust Code)
    private let step1Container = UIView()
    private let trustCodeField = UITextField()

    // MARK: - Step 2 Controls (Email, Mobile, OTP)
    private let step2Container = UIView()
    private let trustBadgeLabel = UILabel()
    private let emailField = UITextField()
    private let mobileField = UITextField()
    private let otpContainer = UIView()
    private let otpField = UITextField()
    private let otpTimerLabel = UILabel()
    private let resendOTPButton = UIButton(type: .system)

    // MARK: - Step 3 Controls (Parent Code, User Details)
    private let step3Container = UIView()
    private let parentCodeField = UITextField()
    private let titleSegmentControl = UISegmentedControl(items: ["Mr", "Mrs", "Ms", "Mh", "Bai", "Bh"])
    private let firstNameField = UITextField()
    private let lastNameField = UITextField()
    private let passwordField = UITextField()
    private let showPasswordButton = UIButton(type: .system)
    private let genderSegmentControl = UISegmentedControl(items: ["Male 👨", "Female 👩"])

    // Action Button & Loading Spinner
    private let actionButton = UIButton(type: .custom)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let backStepButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
        updateStepUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    deinit {
        otpTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Main UI Setup
    private func setupUI() {
        // Deep Royal Blue Translucent Overlay
        view.backgroundColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 0.96)

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

        // 2. Card View
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 18
        cardView.layer.masksToBounds = true
        contentView.addSubview(cardView)

        // Close Button (Top Right)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = UIColor(red: 120/255, green: 130/255, blue: 145/255, alpha: 1.0)
        closeButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        cardView.addSubview(closeButton)

        // Header Icon
        headerIconView.translatesAutoresizingMaskIntoConstraints = false
        headerIconView.image = UIImage(systemName: "person.badge.plus.fill")
        headerIconView.tintColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        headerIconView.contentMode = .scaleAspectFit
        cardView.addSubview(headerIconView)

        // Title & Subtitle
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Sign Up"
        titleLabel.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        titleLabel.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        titleLabel.textAlignment = .center
        cardView.addSubview(titleLabel)

        stepIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        stepIndicatorLabel.text = "Step 1 of 3: Trust Verification"
        stepIndicatorLabel.textColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
        stepIndicatorLabel.font = UIFont.systemFont(ofSize: 12.5, weight: .bold)
        stepIndicatorLabel.textAlignment = .center
        cardView.addSubview(stepIndicatorLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Enter your trust or branch code to begin"
        subtitleLabel.textColor = UIColor(red: 100/255, green: 110/255, blue: 120/255, alpha: 1.0)
        subtitleLabel.font = UIFont.systemFont(ofSize: 13.5, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        cardView.addSubview(subtitleLabel)

        // Error Banner
        errorBanner.translatesAutoresizingMaskIntoConstraints = false
        errorBanner.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 0.95)
        errorBanner.layer.cornerRadius = 6
        errorBanner.layer.masksToBounds = true
        errorBanner.isHidden = true
        cardView.addSubview(errorBanner)

        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textColor = .white
        errorLabel.font = UIFont.systemFont(ofSize: 12.5, weight: .medium)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorBanner.addSubview(errorLabel)

        // Setup Step Containers
        setupStep1UI()
        setupStep2UI()
        setupStep3UI()

        // Action Button
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.backgroundColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0) // Emerald Green #28B779
        actionButton.setTitle("Verify Trust Code  ➔", for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        actionButton.layer.cornerRadius = 8
        actionButton.addTarget(self, action: #selector(handleActionButtonTap), for: .touchUpInside)
        cardView.addSubview(actionButton)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        actionButton.addSubview(activityIndicator)

        // Back Step Button
        backStepButton.translatesAutoresizingMaskIntoConstraints = false
        backStepButton.setTitle("← Previous Step", for: .normal)
        backStepButton.setTitleColor(UIColor(red: 100/255, green: 110/255, blue: 120/255, alpha: 1.0), for: .normal)
        backStepButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        backStepButton.isHidden = true
        backStepButton.addTarget(self, action: #selector(handleBackStepTap), for: .touchUpInside)
        cardView.addSubview(backStepButton)

        // Layout Constraints
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

            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),

            closeButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            closeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalToConstant: 28),

            headerIconView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            headerIconView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            headerIconView.widthAnchor.constraint(equalToConstant: 36),
            headerIconView.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.topAnchor.constraint(equalTo: headerIconView.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            stepIndicatorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            stepIndicatorLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: stepIndicatorLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            errorBanner.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            errorBanner.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            errorBanner.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            errorLabel.topAnchor.constraint(equalTo: errorBanner.topAnchor, constant: 6),
            errorLabel.leadingAnchor.constraint(equalTo: errorBanner.leadingAnchor, constant: 10),
            errorLabel.trailingAnchor.constraint(equalTo: errorBanner.trailingAnchor, constant: -10),
            errorLabel.bottomAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: -6),

            // Step 1 Layout
            step1Container.topAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: 12),
            step1Container.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            step1Container.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            // Step 2 Layout
            step2Container.topAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: 12),
            step2Container.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            step2Container.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            // Step 3 Layout
            step3Container.topAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: 12),
            step3Container.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            step3Container.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            actionButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            actionButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            actionButton.heightAnchor.constraint(equalToConstant: 48),

            activityIndicator.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: actionButton.trailingAnchor, constant: -16),

            backStepButton.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 10),
            backStepButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            backStepButton.heightAnchor.constraint(equalToConstant: 32),
            backStepButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Step 1 UI Setup (Trust Code)
    private func setupStep1UI() {
        step1Container.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(step1Container)

        let trustTitle = createFieldHeaderLabel("Trust / Institution Code*")
        step1Container.addSubview(trustTitle)

        styleTextField(trustCodeField, placeholder: "e.g. SAT6677", icon: "building.2.crop.circle.fill")
        trustCodeField.text = "SAT6677"
        trustCodeField.autocapitalizationType = .allCharacters
        trustCodeField.delegate = self
        step1Container.addSubview(trustCodeField)

        let trustHintLabel = UILabel()
        trustHintLabel.translatesAutoresizingMaskIntoConstraints = false
        trustHintLabel.text = "💡 Enter the unique code provided by your Head Office."
        trustHintLabel.textColor = UIColor(red: 120/255, green: 130/255, blue: 145/255, alpha: 1.0)
        trustHintLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        trustHintLabel.numberOfLines = 0
        step1Container.addSubview(trustHintLabel)

        NSLayoutConstraint.activate([
            trustTitle.topAnchor.constraint(equalTo: step1Container.topAnchor),
            trustTitle.leadingAnchor.constraint(equalTo: step1Container.leadingAnchor),

            trustCodeField.topAnchor.constraint(equalTo: trustTitle.bottomAnchor, constant: 6),
            trustCodeField.leadingAnchor.constraint(equalTo: step1Container.leadingAnchor),
            trustCodeField.trailingAnchor.constraint(equalTo: step1Container.trailingAnchor),
            trustCodeField.heightAnchor.constraint(equalToConstant: 44),

            trustHintLabel.topAnchor.constraint(equalTo: trustCodeField.bottomAnchor, constant: 8),
            trustHintLabel.leadingAnchor.constraint(equalTo: step1Container.leadingAnchor),
            trustHintLabel.trailingAnchor.constraint(equalTo: step1Container.trailingAnchor),
            trustHintLabel.bottomAnchor.constraint(equalTo: step1Container.bottomAnchor, constant: -10)
        ])
    }

    // MARK: - Step 2 UI Setup (Email, Mobile, OTP)
    private func setupStep2UI() {
        step2Container.translatesAutoresizingMaskIntoConstraints = false
        step2Container.isHidden = true
        cardView.addSubview(step2Container)

        // Verified Trust Header Badge
        trustBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        trustBadgeLabel.backgroundColor = UIColor(red: 232/255, green: 240/255, blue: 254/255, alpha: 1.0)
        trustBadgeLabel.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        trustBadgeLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        trustBadgeLabel.textAlignment = .center
        trustBadgeLabel.layer.cornerRadius = 6
        trustBadgeLabel.layer.masksToBounds = true
        trustBadgeLabel.text = "🏛️ SHRI ANANDPUR TRUST (SAT6677)"
        step2Container.addSubview(trustBadgeLabel)

        // Email
        let emailTitle = createFieldHeaderLabel("Email Address*")
        step2Container.addSubview(emailTitle)

        styleTextField(emailField, placeholder: "name@example.com", icon: "envelope.fill")
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        emailField.delegate = self
        step2Container.addSubview(emailField)

        // Mobile
        let mobileTitle = createFieldHeaderLabel("10-Digit Mobile Number*")
        step2Container.addSubview(mobileTitle)

        styleTextField(mobileField, placeholder: "Enter mobile number", icon: "phone.fill")
        mobileField.keyboardType = .phonePad
        mobileField.delegate = self
        step2Container.addSubview(mobileField)

        // OTP Section (Appears after sending OTP)
        otpContainer.translatesAutoresizingMaskIntoConstraints = false
        otpContainer.isHidden = true
        step2Container.addSubview(otpContainer)

        let otpTitle = createFieldHeaderLabel("Enter 4-Digit OTP*")
        otpContainer.addSubview(otpTitle)

        styleTextField(otpField, placeholder: "4-digit OTP", icon: "lock.shield.fill")
        otpField.keyboardType = .numberPad
        otpContainer.addSubview(otpField)

        otpTimerLabel.translatesAutoresizingMaskIntoConstraints = false
        otpTimerLabel.text = "Expires in 00:30"
        otpTimerLabel.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        otpTimerLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        otpContainer.addSubview(otpTimerLabel)

        resendOTPButton.translatesAutoresizingMaskIntoConstraints = false
        resendOTPButton.setTitle("Resend OTP", for: .normal)
        resendOTPButton.setTitleColor(UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0), for: .normal)
        resendOTPButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        resendOTPButton.isHidden = true
        resendOTPButton.addTarget(self, action: #selector(handleResendOTPTap), for: .touchUpInside)
        otpContainer.addSubview(resendOTPButton)

        NSLayoutConstraint.activate([
            trustBadgeLabel.topAnchor.constraint(equalTo: step2Container.topAnchor),
            trustBadgeLabel.leadingAnchor.constraint(equalTo: step2Container.leadingAnchor),
            trustBadgeLabel.trailingAnchor.constraint(equalTo: step2Container.trailingAnchor),
            trustBadgeLabel.heightAnchor.constraint(equalToConstant: 34),

            emailTitle.topAnchor.constraint(equalTo: trustBadgeLabel.bottomAnchor, constant: 10),
            emailTitle.leadingAnchor.constraint(equalTo: step2Container.leadingAnchor),

            emailField.topAnchor.constraint(equalTo: emailTitle.bottomAnchor, constant: 4),
            emailField.leadingAnchor.constraint(equalTo: step2Container.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: step2Container.trailingAnchor),
            emailField.heightAnchor.constraint(equalToConstant: 44),

            mobileTitle.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 10),
            mobileTitle.leadingAnchor.constraint(equalTo: step2Container.leadingAnchor),

            mobileField.topAnchor.constraint(equalTo: mobileTitle.bottomAnchor, constant: 4),
            mobileField.leadingAnchor.constraint(equalTo: step2Container.leadingAnchor),
            mobileField.trailingAnchor.constraint(equalTo: step2Container.trailingAnchor),
            mobileField.heightAnchor.constraint(equalToConstant: 44),

            otpContainer.topAnchor.constraint(equalTo: mobileField.bottomAnchor, constant: 10),
            otpContainer.leadingAnchor.constraint(equalTo: step2Container.leadingAnchor),
            otpContainer.trailingAnchor.constraint(equalTo: step2Container.trailingAnchor),
            otpContainer.bottomAnchor.constraint(equalTo: step2Container.bottomAnchor, constant: -10),

            otpTitle.topAnchor.constraint(equalTo: otpContainer.topAnchor),
            otpTitle.leadingAnchor.constraint(equalTo: otpContainer.leadingAnchor),

            otpField.topAnchor.constraint(equalTo: otpTitle.bottomAnchor, constant: 4),
            otpField.leadingAnchor.constraint(equalTo: otpContainer.leadingAnchor),
            otpField.trailingAnchor.constraint(equalTo: otpContainer.trailingAnchor),
            otpField.heightAnchor.constraint(equalToConstant: 44),

            otpTimerLabel.topAnchor.constraint(equalTo: otpField.bottomAnchor, constant: 6),
            otpTimerLabel.leadingAnchor.constraint(equalTo: otpContainer.leadingAnchor),
            otpTimerLabel.bottomAnchor.constraint(equalTo: otpContainer.bottomAnchor),

            resendOTPButton.centerYAnchor.constraint(equalTo: otpTimerLabel.centerYAnchor),
            resendOTPButton.trailingAnchor.constraint(equalTo: otpContainer.trailingAnchor)
        ])
    }

    // MARK: - Step 3 UI Setup (Parent Code, User Details)
    private func setupStep3UI() {
        step3Container.translatesAutoresizingMaskIntoConstraints = false
        step3Container.isHidden = true
        cardView.addSubview(step3Container)

        // Parent Code
        let parentTitle = createFieldHeaderLabel("Main/Parent Branch Code#*")
        step3Container.addSubview(parentTitle)

        styleTextField(parentCodeField, placeholder: "e.g. 6 or SAT6677", icon: "person.crop.circle.badge.checkmark")
        parentCodeField.text = "6"
        parentCodeField.delegate = self
        step3Container.addSubview(parentCodeField)

        // Salutation / Title
        let salutationTitle = createFieldHeaderLabel("Salutation / Title*")
        step3Container.addSubview(salutationTitle)

        titleSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        titleSegmentControl.selectedSegmentIndex = 0
        titleSegmentControl.selectedSegmentTintColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        titleSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        titleSegmentControl.addTarget(self, action: #selector(titleSegmentChanged), for: .valueChanged)
        step3Container.addSubview(titleSegmentControl)

        // First Name
        let fnameTitle = createFieldHeaderLabel("First Name*")
        step3Container.addSubview(fnameTitle)

        styleTextField(firstNameField, placeholder: "First Name", icon: "person.fill")
        firstNameField.delegate = self
        step3Container.addSubview(firstNameField)

        // Last Name
        let lnameTitle = createFieldHeaderLabel("Last Name*")
        step3Container.addSubview(lnameTitle)

        styleTextField(lastNameField, placeholder: "Last Name", icon: "person.fill")
        lastNameField.delegate = self
        step3Container.addSubview(lastNameField)

        // Password
        let passwordTitle = createFieldHeaderLabel("Password (Min 6 Characters)*")
        step3Container.addSubview(passwordTitle)

        styleTextField(passwordField, placeholder: "Enter password", icon: "lock.fill")
        passwordField.isSecureTextEntry = true
        passwordField.delegate = self
        step3Container.addSubview(passwordField)

        showPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        showPasswordButton.setTitle("Show", for: .normal)
        showPasswordButton.setTitleColor(UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0), for: .normal)
        showPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        showPasswordButton.addTarget(self, action: #selector(toggleShowPassword), for: .touchUpInside)
        passwordField.rightView = showPasswordButton
        passwordField.rightViewMode = .always

        // Gender
        let genderTitle = createFieldHeaderLabel("Gender")
        step3Container.addSubview(genderTitle)

        genderSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        genderSegmentControl.selectedSegmentIndex = 0
        genderSegmentControl.selectedSegmentTintColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        genderSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        genderSegmentControl.addTarget(self, action: #selector(genderSegmentChanged), for: .valueChanged)
        step3Container.addSubview(genderSegmentControl)

        NSLayoutConstraint.activate([
            parentTitle.topAnchor.constraint(equalTo: step3Container.topAnchor),
            parentTitle.leadingAnchor.constraint(equalTo: step3Container.leadingAnchor),

            parentCodeField.topAnchor.constraint(equalTo: parentTitle.bottomAnchor, constant: 4),
            parentCodeField.leadingAnchor.constraint(equalTo: step3Container.leadingAnchor),
            parentCodeField.trailingAnchor.constraint(equalTo: step3Container.trailingAnchor),
            parentCodeField.heightAnchor.constraint(equalToConstant: 44),

            salutationTitle.topAnchor.constraint(equalTo: parentCodeField.bottomAnchor, constant: 10),
            salutationTitle.leadingAnchor.constraint(equalTo: step3Container.leadingAnchor),

            titleSegmentControl.topAnchor.constraint(equalTo: salutationTitle.bottomAnchor, constant: 4),
            titleSegmentControl.leadingAnchor.constraint(equalTo: step3Container.leadingAnchor),
            titleSegmentControl.trailingAnchor.constraint(equalTo: step3Container.trailingAnchor),
            titleSegmentControl.heightAnchor.constraint(equalToConstant: 32),

            fnameTitle.topAnchor.constraint(equalTo: titleSegmentControl.bottomAnchor, constant: 10),
            fnameTitle.leadingAnchor.constraint(equalTo: step3Container.leadingAnchor),

            firstNameField.topAnchor.constraint(equalTo: fnameTitle.bottomAnchor, constant: 4),
            firstNameField.leadingAnchor.constraint(equalTo: step3Container.leadingAnchor),
            firstNameField.trailingAnchor.constraint(equalTo: step3Container.trailingAnchor),
            firstNameField.heightAnchor.constraint(equalToConstant: 44),

            lnameTitle.topAnchor.constraint(equalTo: firstNameField.bottomAnchor, constant: 10),
            lnameTitle.leadingAnchor.constraint(equalTo: step3Container.leadingAnchor),

            lastNameField.topAnchor.constraint(equalTo: lnameTitle.bottomAnchor, constant: 4),
            lastNameField.leadingAnchor.constraint(equalTo: step3Container.leadingAnchor),
            lastNameField.trailingAnchor.constraint(equalTo: step3Container.trailingAnchor),
            lastNameField.heightAnchor.constraint(equalToConstant: 44),

            passwordTitle.topAnchor.constraint(equalTo: lastNameField.bottomAnchor, constant: 10),
            passwordTitle.leadingAnchor.constraint(equalTo: step3Container.leadingAnchor),

            passwordField.topAnchor.constraint(equalTo: passwordTitle.bottomAnchor, constant: 4),
            passwordField.leadingAnchor.constraint(equalTo: step3Container.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: step3Container.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 44),

            genderTitle.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 10),
            genderTitle.leadingAnchor.constraint(equalTo: step3Container.leadingAnchor),

            genderSegmentControl.topAnchor.constraint(equalTo: genderTitle.bottomAnchor, constant: 4),
            genderSegmentControl.leadingAnchor.constraint(equalTo: step3Container.leadingAnchor),
            genderSegmentControl.trailingAnchor.constraint(equalTo: step3Container.trailingAnchor),
            genderSegmentControl.heightAnchor.constraint(equalToConstant: 32),
            genderSegmentControl.bottomAnchor.constraint(equalTo: step3Container.bottomAnchor, constant: -10)
        ])
    }

    // MARK: - Step UI Transition Manager
    private func updateStepUI() {
        clearError()

        switch currentStep {
        case .step1TrustCode:
            stepIndicatorLabel.text = "Step 1 of 3: Trust Verification"
            subtitleLabel.text = "Enter your trust or branch code to begin"
            step1Container.isHidden = false
            step2Container.isHidden = true
            step3Container.isHidden = true
            backStepButton.isHidden = true
            actionButton.setTitle("Verify Trust Code  ➔", for: .normal)
            actionButton.topAnchor.constraint(equalTo: step1Container.bottomAnchor, constant: 12).isActive = true

        case .step2EmailMobileOTP:
            stepIndicatorLabel.text = "Step 2 of 3: Contact & OTP Verification"
            subtitleLabel.text = "Verify your email address and mobile number"
            trustBadgeLabel.text = "🏛️ \(verifiedMerchantName.uppercased()) (\(trustCodeField.text ?? ""))"
            step1Container.isHidden = true
            step2Container.isHidden = false
            step3Container.isHidden = true
            backStepButton.isHidden = false

            if isOTPRequested {
                actionButton.setTitle("Verify OTP  ➔", for: .normal)
            } else {
                actionButton.setTitle("Send OTP  ➔", for: .normal)
            }
            actionButton.topAnchor.constraint(equalTo: step2Container.bottomAnchor, constant: 12).isActive = true

        case .step3UserDetails:
            stepIndicatorLabel.text = "Step 3 of 3: Account Details"
            subtitleLabel.text = "Complete your personal details to register"
            step1Container.isHidden = true
            step2Container.isHidden = true
            step3Container.isHidden = false
            backStepButton.isHidden = false
            actionButton.setTitle("Create Account  ➔", for: .normal)
            actionButton.topAnchor.constraint(equalTo: step3Container.bottomAnchor, constant: 12).isActive = true
        }
    }

    // MARK: - Action Button Router
    @objc private func handleActionButtonTap() {
        view.endEditing(true)
        switch currentStep {
        case .step1TrustCode:
            executeTrustCodeVerification()
        case .step2EmailMobileOTP:
            if isOTPRequested {
                executeOTPVerification()
            } else {
                executeSendOTP()
            }
        case .step3UserDetails:
            executeFinalRegistration()
        }
    }

    // MARK: - Step 1: Trust Code Verification (POST /api/check-trust-code)
    private func executeTrustCodeVerification() {
        let code = trustCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !code.isEmpty else {
            showError("Please enter your Trust/Institution code.")
            return
        }

        startLoading()

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
                self.stopLoading()

                if let error = error {
                    self.showError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.showError("Invalid response from server.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let apiMessage = self.extractMessage(from: json, fallback: "Please enter valid trust code. Contact helpline.")

                if status {
                    let dataObj = (json["data"] as? [String: Any]) ?? (json["response"] as? [String: Any]) ?? [:]
                    self.verifiedMerchantId = (dataObj["id"] as? Int) ?? (dataObj["merchant_id"] as? Int) ?? 6
                    self.verifiedMerchantName = (dataObj["name"] as? String) ?? "SHRI ANANDPUR TRUST"
                    self.verifiedRoleId = (dataObj["role_id"] as? Int) ?? 0

                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    self.currentStep = .step2EmailMobileOTP
                    UIView.transition(with: self.cardView, duration: 0.3, options: .transitionCrossDissolve) {
                        self.updateStepUI()
                    }
                    self.emailField.becomeFirstResponder()
                } else {
                    self.showError(apiMessage)
                }
            }
        }.resume()
    }

    // MARK: - Step 2: Send OTP (POST /api/register-otp-send)
    private func executeSendOTP() {
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let mobile = mobileField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trustCode = trustCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !email.isEmpty, email.contains("@"), email.contains(".") else {
            showError("Please enter a valid Email address.")
            return
        }

        guard !mobile.isEmpty, mobile.count == 10 else {
            showError("Please enter a valid 10-digit mobile number.")
            return
        }

        startLoading()

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
                self.stopLoading()

                if let error = error {
                    self.showError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.showError("Invalid response from server.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let apiMessage = self.extractMessage(from: json, fallback: "Failed to send OTP. Please check your inputs.")

                if status {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    self.isOTPRequested = true
                    self.otpContainer.isHidden = false
                    self.actionButton.setTitle("Verify OTP  ➔", for: .normal)
                    self.startOTPTimer()
                    self.otpField.becomeFirstResponder()
                } else {
                    self.showError(apiMessage)
                }
            }
        }.resume()
    }

    // MARK: - Step 2: Verify OTP (POST /api/check-register-otp)
    private func executeOTPVerification() {
        let otp = otpField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let mobile = mobileField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !otp.isEmpty, otp.count == 4 else {
            showError("Please enter the 4-digit OTP.")
            return
        }

        startLoading()

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
                self.stopLoading()

                if let error = error {
                    self.showError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.showError("Invalid response from server.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let apiMessage = self.extractMessage(from: json, fallback: "Invalid OTP code entered.")

                if status {
                    self.otpTimer?.invalidate()
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    self.currentStep = .step3UserDetails
                    UIView.transition(with: self.cardView, duration: 0.3, options: .transitionCrossDissolve) {
                        self.updateStepUI()
                    }
                    self.firstNameField.becomeFirstResponder()
                } else {
                    self.showError(apiMessage)
                }
            }
        }.resume()
    }

    // MARK: - Step 3: Final Registration (POST /api/register)
    private func executeFinalRegistration() {
        let parentCode = parentCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let fname = firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lname = lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let mobile = mobileField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trustCode = trustCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !parentCode.isEmpty else { showError("Please enter Main/Parent Branch Code."); return }
        guard !fname.isEmpty else { showError("First Name is required."); return }
        guard !lname.isEmpty else { showError("Last Name is required."); return }
        guard password.count >= 6 else { showError("Password must be at least 6 characters."); return }

        startLoading()

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
            "merchant_id": "\(verifiedMerchantId)",
            "trust_code": trustCode,
            "asharm_id": parentCode,
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
                guard let self = self else { return }
                self.stopLoading()

                if let error = error {
                    self.showError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.showError("Invalid server response.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let apiMessage = self.extractMessage(from: json, fallback: "Registration failed. Please try again.")

                if status {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    let alert = UIAlertController(
                        title: "Registration Successful!",
                        message: "Your account under \(self.verifiedMerchantName) has been created.\nYou can now log in.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Log In Now", style: .default) { [weak self] _ in
                        self?.dismiss(animated: true) {
                            self?.onSignUpSuccess?(email)
                        }
                    })
                    self.present(alert, animated: true)
                } else {
                    self.showError(apiMessage)
                }
            }
        }.resume()
    }

    // MARK: - OTP Timer Helpers
    private func startOTPTimer() {
        otpRemainingSeconds = 30
        otpTimerLabel.text = "Expires in 00:30"
        resendOTPButton.isHidden = true
        otpTimer?.invalidate()
        otpTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.otpRemainingSeconds > 0 {
                self.otpRemainingSeconds -= 1
                self.otpTimerLabel.text = String(format: "Expires in 00:%02d", self.otpRemainingSeconds)
            } else {
                timer.invalidate()
                self.resendOTPButton.isHidden = false
            }
        }
    }

    @objc private func handleResendOTPTap() {
        resendOTPButton.isHidden = true
        executeSendOTP()
    }

    @objc private func handleBackStepTap() {
        if currentStep == .step3UserDetails {
            currentStep = .step2EmailMobileOTP
        } else if currentStep == .step2EmailMobileOTP {
            currentStep = .step1TrustCode
        }
        UIView.transition(with: cardView, duration: 0.25, options: .transitionCrossDissolve) {
            self.updateStepUI()
        }
    }

    // MARK: - Field Stylers & Helpers
    private func styleTextField(_ tf: UITextField, placeholder: String, icon: String) {
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor(red: 245/255, green: 247/255, blue: 250/255, alpha: 1.0)
        tf.layer.cornerRadius = 8
        tf.layer.borderWidth = 1.2
        tf.layer.borderColor = UIColor(red: 218/255, green: 224/255, blue: 233/255, alpha: 1.0).cgColor
        tf.textColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        tf.font = UIFont.systemFont(ofSize: 14.5, weight: .medium)
        tf.autocorrectionType = .no
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(red: 140/255, green: 150/255, blue: 160/255, alpha: 1.0)]
        )

        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 38, height: 44))
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        iconView.contentMode = .center
        iconView.frame = iconContainer.bounds
        iconContainer.addSubview(iconView)
        tf.leftView = iconContainer
        tf.leftViewMode = .always
    }

    private func createFieldHeaderLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = UIColor(red: 46/255, green: 54/255, blue: 63/255, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        return label
    }

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

    private func showError(_ msg: String) {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        errorLabel.text = msg
        errorBanner.isHidden = false
    }

    private func clearError() {
        errorBanner.isHidden = true
    }

    private func startLoading() {
        actionButton.isEnabled = false
        actionButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        clearError()
    }

    private func stopLoading() {
        actionButton.isEnabled = true
        activityIndicator.stopAnimating()
        updateStepUI()
    }

    @objc private func toggleShowPassword() {
        passwordField.isSecureTextEntry.toggle()
        let title = passwordField.isSecureTextEntry ? "Show" : "Hide"
        showPasswordButton.setTitle(title, for: .normal)
    }

    @objc private func titleSegmentChanged() {
        selectedTitle = availableTitles[titleSegmentControl.selectedSegmentIndex]
    }

    @objc private func genderSegmentChanged() {
        selectedGender = genderSegmentControl.selectedSegmentIndex + 1
    }

    @objc private func dismissModal() {
        dismiss(animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Keyboard Avoidance
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
        handleActionButtonTap()
        return true
    }
}
