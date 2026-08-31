import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    var onSignUpSuccess: ((String) -> Void)?

    // MARK: - State
    private enum Step {
        case enterTrustCode
        case enterUserDetails
    }

    private var currentStep: Step = .enterTrustCode
    private var verifiedMerchantId: Int = 0
    private var verifiedMerchantName: String = ""
    private var enteredTrustCode: String = ""

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header
    private let headerTitleLabel = UILabel()

    // Error Banner
    private let errorLabel = UILabel()

    // MARK: - Step 1 UI (Trust Code Card)
    private let trustCardContainer = UIView()
    private let trustCardTopView = UIView()
    private let trustCardBottomView = UIView()

    private let idBadgeIconView = UIView()
    private let idBadgeSubIcon = UIImageView()
    private let trustCodeTitleLabel = UILabel()
    private let trustCodeField = UITextField()
    private let trustCodeUnderline = UIView()

    private let submitArrowButton = UIButton(type: .system)
    private let trustInfoButton = UIButton(type: .system)
    private let trustActivityIndicator = UIActivityIndicatorView(style: .medium)
    private let cancelButton = UIButton(type: .system)

    // MARK: - Step 2 UI (User Details Form)
    private let detailsCardView = UIView()
    private let verifiedTrustBadgeView = UIView()
    private let verifiedTrustIcon = UIImageView()
    private let verifiedTrustTitleLabel = UILabel()
    private let verifiedTrustCodeLabel = UILabel()

    private let firstNameField = UITextField()
    private let lastNameField = UITextField()
    private let mobileField = UITextField()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let confirmPasswordField = UITextField()

    private let showPasswordButton = UIButton(type: .custom)
    private let showConfirmPasswordButton = UIButton(type: .custom)

    private let registerButton = UIButton(type: .custom)
    private let registerActivityIndicator = UIActivityIndicatorView(style: .medium)
    private let backToTrustCodeButton = UIButton(type: .system)

    // Footer Version
    private let versionLabel = UILabel()

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
        NotificationCenter.default.removeObserver(self)
    }

    private func setupUI() {
        // Deep Royal Blue Background matching Android/Web reference
        view.backgroundColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0) // #133B7C

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

        // 2. Header Title "Sign Up"
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.text = "Sign Up"
        headerTitleLabel.textColor = .white
        headerTitleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        headerTitleLabel.textAlignment = .center
        contentView.addSubview(headerTitleLabel)

        // 3. Error Banner
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 0.95)
        errorLabel.textColor = .white
        errorLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.layer.cornerRadius = 6
        errorLabel.layer.masksToBounds = true
        errorLabel.isHidden = true
        contentView.addSubview(errorLabel)

        // 4. Setup Step 1: Trust Card (Exact Match to Screenshot)
        setupTrustCardUI()

        // 5. Setup Step 2: User Details Form
        setupUserDetailsUI()

        // 6. Version Label at Bottom
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.text = "v t 2.0.10"
        versionLabel.textColor = UIColor.white.withAlphaComponent(0.65)
        versionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        versionLabel.textAlignment = .right
        view.addSubview(versionLabel)

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

            headerTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            errorLabel.topAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 14),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Step 1: Trust Card
            trustCardContainer.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            trustCardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            trustCardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            trustCardContainer.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -60),

            // Step 2: Details Card
            detailsCardView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            detailsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            detailsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            detailsCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60),

            versionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Step 1: Trust Code Card (Exact Match to Screenshot)
    private func setupTrustCardUI() {
        trustCardContainer.translatesAutoresizingMaskIntoConstraints = false
        trustCardContainer.layer.cornerRadius = 16
        trustCardContainer.layer.masksToBounds = true
        trustCardContainer.layer.shadowColor = UIColor.black.cgColor
        trustCardContainer.layer.shadowOpacity = 0.25
        trustCardContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        trustCardContainer.layer.shadowRadius = 10
        contentView.addSubview(trustCardContainer)

        // White Top Section
        trustCardTopView.translatesAutoresizingMaskIntoConstraints = false
        trustCardTopView.backgroundColor = .white
        trustCardContainer.addSubview(trustCardTopView)

        // Pink ID Badge Icon
        idBadgeIconView.translatesAutoresizingMaskIntoConstraints = false
        idBadgeIconView.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 0.85) // Pink #E91E63
        idBadgeIconView.layer.cornerRadius = 6
        idBadgeIconView.layer.masksToBounds = true
        trustCardTopView.addSubview(idBadgeIconView)

        idBadgeSubIcon.translatesAutoresizingMaskIntoConstraints = false
        idBadgeSubIcon.image = UIImage(systemName: "person.crop.rectangle.fill") ?? UIImage(systemName: "person.text.rectangle")
        idBadgeSubIcon.tintColor = .white
        idBadgeSubIcon.contentMode = .scaleAspectFit
        idBadgeIconView.addSubview(idBadgeSubIcon)

        // Label: "Trust/Institution code*" (with red asterisk)
        trustCodeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        let titleAttr = NSMutableAttributedString(
            string: "Trust/Institution code",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14.5, weight: .bold),
                .foregroundColor: UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
            ]
        )
        let starAttr = NSAttributedString(
            string: "*",
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .bold),
                .foregroundColor: UIColor(red: 220/255, green: 53/255, blue: 69/255, alpha: 1.0)
            ]
        )
        titleAttr.append(starAttr)
        trustCodeTitleLabel.attributedText = titleAttr
        trustCardTopView.addSubview(trustCodeTitleLabel)

        // TextField: "Type your trust code"
        trustCodeField.translatesAutoresizingMaskIntoConstraints = false
        trustCodeField.placeholder = "Type your trust code"
        trustCodeField.textColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        trustCodeField.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        trustCodeField.autocapitalizationType = .allCharacters
        trustCodeField.autocorrectionType = .no
        trustCodeField.returnKeyType = .go
        trustCodeField.delegate = self
        trustCodeField.addTarget(self, action: #selector(trustCodeChanged), for: .editingChanged)
        trustCardTopView.addSubview(trustCodeField)

        // Bottom underline
        trustCodeUnderline.translatesAutoresizingMaskIntoConstraints = false
        trustCodeUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        trustCardTopView.addSubview(trustCodeUnderline)

        // Right Action: Submit Arrow Button "➔"
        submitArrowButton.translatesAutoresizingMaskIntoConstraints = false
        submitArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        submitArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        submitArrowButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        submitArrowButton.addTarget(self, action: #selector(handleTrustCodeSubmit), for: .touchUpInside)
        trustCardTopView.addSubview(submitArrowButton)

        // Right Action: Info Button "ⓘ"
        trustInfoButton.translatesAutoresizingMaskIntoConstraints = false
        trustInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        trustInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        trustInfoButton.addTarget(self, action: #selector(showTrustCodeInfo), for: .touchUpInside)
        trustCardTopView.addSubview(trustInfoButton)

        // Activity Indicator for Trust Code Verification
        trustActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        trustActivityIndicator.hidesWhenStopped = true
        trustActivityIndicator.color = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        trustCardTopView.addSubview(trustActivityIndicator)

        // Blue Bottom Section: "Cancel" Button
        trustCardBottomView.translatesAutoresizingMaskIntoConstraints = false
        trustCardBottomView.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0) // Light Blue #4184D6
        trustCardContainer.addSubview(trustCardBottomView)

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cancelButton.contentHorizontalAlignment = .left
        cancelButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        trustCardBottomView.addSubview(cancelButton)

        // Constraints for Trust Card
        NSLayoutConstraint.activate([
            trustCardTopView.topAnchor.constraint(equalTo: trustCardContainer.topAnchor),
            trustCardTopView.leadingAnchor.constraint(equalTo: trustCardContainer.leadingAnchor),
            trustCardTopView.trailingAnchor.constraint(equalTo: trustCardContainer.trailingAnchor),
            trustCardTopView.heightAnchor.constraint(equalToConstant: 100),

            idBadgeIconView.leadingAnchor.constraint(equalTo: trustCardTopView.leadingAnchor, constant: 16),
            idBadgeIconView.topAnchor.constraint(equalTo: trustCardTopView.topAnchor, constant: 28),
            idBadgeIconView.widthAnchor.constraint(equalToConstant: 38),
            idBadgeIconView.heightAnchor.constraint(equalToConstant: 28),

            idBadgeSubIcon.centerXAnchor.constraint(equalTo: idBadgeIconView.centerXAnchor),
            idBadgeSubIcon.centerYAnchor.constraint(equalTo: idBadgeIconView.centerYAnchor),
            idBadgeSubIcon.widthAnchor.constraint(equalToConstant: 24),
            idBadgeSubIcon.heightAnchor.constraint(equalToConstant: 18),

            trustCodeTitleLabel.leadingAnchor.constraint(equalTo: idBadgeIconView.trailingAnchor, constant: 12),
            trustCodeTitleLabel.topAnchor.constraint(equalTo: trustCardTopView.topAnchor, constant: 18),
            trustCodeTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: submitArrowButton.leadingAnchor, constant: -8),

            trustCodeField.leadingAnchor.constraint(equalTo: idBadgeIconView.trailingAnchor, constant: 12),
            trustCodeField.topAnchor.constraint(equalTo: trustCodeTitleLabel.bottomAnchor, constant: 6),
            trustCodeField.trailingAnchor.constraint(equalTo: submitArrowButton.leadingAnchor, constant: -10),
            trustCodeField.heightAnchor.constraint(equalToConstant: 30),

            trustCodeUnderline.leadingAnchor.constraint(equalTo: trustCodeField.leadingAnchor),
            trustCodeUnderline.trailingAnchor.constraint(equalTo: trustCodeField.trailingAnchor),
            trustCodeUnderline.topAnchor.constraint(equalTo: trustCodeField.bottomAnchor, constant: 2),
            trustCodeUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            trustInfoButton.trailingAnchor.constraint(equalTo: trustCardTopView.trailingAnchor, constant: -16),
            trustInfoButton.centerYAnchor.constraint(equalTo: trustCardTopView.centerYAnchor),
            trustInfoButton.widthAnchor.constraint(equalToConstant: 28),
            trustInfoButton.heightAnchor.constraint(equalToConstant: 28),

            submitArrowButton.trailingAnchor.constraint(equalTo: trustInfoButton.leadingAnchor, constant: -12),
            submitArrowButton.centerYAnchor.constraint(equalTo: trustCardTopView.centerYAnchor),
            submitArrowButton.widthAnchor.constraint(equalToConstant: 28),
            submitArrowButton.heightAnchor.constraint(equalToConstant: 28),

            trustActivityIndicator.centerXAnchor.constraint(equalTo: submitArrowButton.centerXAnchor),
            trustActivityIndicator.centerYAnchor.constraint(equalTo: submitArrowButton.centerYAnchor),

            trustCardBottomView.topAnchor.constraint(equalTo: trustCardTopView.bottomAnchor),
            trustCardBottomView.leadingAnchor.constraint(equalTo: trustCardContainer.leadingAnchor),
            trustCardBottomView.trailingAnchor.constraint(equalTo: trustCardContainer.trailingAnchor),
            trustCardBottomView.bottomAnchor.constraint(equalTo: trustCardContainer.bottomAnchor),
            trustCardBottomView.heightAnchor.constraint(equalToConstant: 48),

            cancelButton.leadingAnchor.constraint(equalTo: trustCardBottomView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: trustCardBottomView.trailingAnchor, constant: -20),
            cancelButton.centerYAnchor.constraint(equalTo: trustCardBottomView.centerYAnchor)
        ])
    }

    // MARK: - Step 2: User Details UI (After Trust Code Verified)
    private func setupUserDetailsUI() {
        detailsCardView.translatesAutoresizingMaskIntoConstraints = false
        detailsCardView.backgroundColor = .white
        detailsCardView.layer.cornerRadius = 16
        detailsCardView.layer.masksToBounds = true
        detailsCardView.layer.shadowColor = UIColor.black.cgColor
        detailsCardView.layer.shadowOpacity = 0.25
        detailsCardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        detailsCardView.layer.shadowRadius = 10
        contentView.addSubview(detailsCardView)

        // Verified Trust Header Badge
        verifiedTrustBadgeView.translatesAutoresizingMaskIntoConstraints = false
        verifiedTrustBadgeView.backgroundColor = UIColor(red: 232/255, green: 245/255, blue: 233/255, alpha: 1.0) // Light green
        verifiedTrustBadgeView.layer.cornerRadius = 8
        verifiedTrustBadgeView.layer.borderWidth = 1
        verifiedTrustBadgeView.layer.borderColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 0.4).cgColor
        detailsCardView.addSubview(verifiedTrustBadgeView)

        verifiedTrustIcon.translatesAutoresizingMaskIntoConstraints = false
        verifiedTrustIcon.image = UIImage(systemName: "checkmark.seal.fill")
        verifiedTrustIcon.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        verifiedTrustBadgeView.addSubview(verifiedTrustIcon)

        verifiedTrustTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        verifiedTrustTitleLabel.textColor = UIColor(red: 27/255, green: 94/255, blue: 32/255, alpha: 1.0)
        verifiedTrustTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        verifiedTrustBadgeView.addSubview(verifiedTrustTitleLabel)

        verifiedTrustCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        verifiedTrustCodeLabel.textColor = UIColor(red: 56/255, green: 142/255, blue: 60/255, alpha: 1.0)
        verifiedTrustCodeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        verifiedTrustBadgeView.addSubview(verifiedTrustCodeLabel)

        // Input Fields (White background with crisp borders)
        styleTextField(firstNameField, placeholder: "First Name *", icon: "person.fill")
        styleTextField(lastNameField, placeholder: "Last Name *", icon: "person.fill")
        styleTextField(mobileField, placeholder: "Mobile Number (10 digits) *", icon: "phone.fill")
        mobileField.keyboardType = .phonePad

        styleTextField(emailField, placeholder: "Email Address *", icon: "envelope.fill")
        emailField.keyboardType = .emailAddress

        styleTextField(passwordField, placeholder: "Create Password (min 6 chars) *", icon: "lock.fill")
        passwordField.isSecureTextEntry = true

        styleTextField(confirmPasswordField, placeholder: "Confirm Password *", icon: "lock.shield.fill")
        confirmPasswordField.isSecureTextEntry = true

        // Password Show/Hide Buttons
        setupPasswordToggle(showPasswordButton, targetField: passwordField)
        setupPasswordToggle(showConfirmPasswordButton, targetField: confirmPasswordField)

        detailsCardView.addSubview(firstNameField)
        detailsCardView.addSubview(lastNameField)
        detailsCardView.addSubview(mobileField)
        detailsCardView.addSubview(emailField)
        detailsCardView.addSubview(passwordField)
        detailsCardView.addSubview(confirmPasswordField)

        // Register Action Button (Emerald Green #28B779)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.backgroundColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        registerButton.setTitle("Create Account  ➔", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        registerButton.layer.cornerRadius = 6
        registerButton.addTarget(self, action: #selector(handleRegisterSubmit), for: .touchUpInside)
        detailsCardView.addSubview(registerButton)

        registerActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        registerActivityIndicator.hidesWhenStopped = true
        registerActivityIndicator.color = .white
        detailsCardView.addSubview(registerActivityIndicator)

        // Back / Change Trust Code Button
        backToTrustCodeButton.translatesAutoresizingMaskIntoConstraints = false
        backToTrustCodeButton.setTitle("← Change Trust Code", for: .normal)
        backToTrustCodeButton.setTitleColor(UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0), for: .normal)
        backToTrustCodeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        backToTrustCodeButton.addTarget(self, action: #selector(handleBackToTrustCode), for: .touchUpInside)
        detailsCardView.addSubview(backToTrustCodeButton)

        // Details Card Constraints
        NSLayoutConstraint.activate([
            verifiedTrustBadgeView.topAnchor.constraint(equalTo: detailsCardView.topAnchor, constant: 16),
            verifiedTrustBadgeView.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            verifiedTrustBadgeView.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),

            verifiedTrustIcon.leadingAnchor.constraint(equalTo: verifiedTrustBadgeView.leadingAnchor, constant: 10),
            verifiedTrustIcon.centerYAnchor.constraint(equalTo: verifiedTrustBadgeView.centerYAnchor),
            verifiedTrustIcon.widthAnchor.constraint(equalToConstant: 22),
            verifiedTrustIcon.heightAnchor.constraint(equalToConstant: 22),

            verifiedTrustTitleLabel.topAnchor.constraint(equalTo: verifiedTrustBadgeView.topAnchor, constant: 8),
            verifiedTrustTitleLabel.leadingAnchor.constraint(equalTo: verifiedTrustIcon.trailingAnchor, constant: 10),
            verifiedTrustTitleLabel.trailingAnchor.constraint(equalTo: verifiedTrustBadgeView.trailingAnchor, constant: -10),

            verifiedTrustCodeLabel.topAnchor.constraint(equalTo: verifiedTrustTitleLabel.bottomAnchor, constant: 2),
            verifiedTrustCodeLabel.leadingAnchor.constraint(equalTo: verifiedTrustIcon.trailingAnchor, constant: 10),
            verifiedTrustCodeLabel.trailingAnchor.constraint(equalTo: verifiedTrustBadgeView.trailingAnchor, constant: -10),
            verifiedTrustCodeLabel.bottomAnchor.constraint(equalTo: verifiedTrustBadgeView.bottomAnchor, constant: -8),

            firstNameField.topAnchor.constraint(equalTo: verifiedTrustBadgeView.bottomAnchor, constant: 16),
            firstNameField.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            firstNameField.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),
            firstNameField.heightAnchor.constraint(equalToConstant: 44),

            lastNameField.topAnchor.constraint(equalTo: firstNameField.bottomAnchor, constant: 12),
            lastNameField.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            lastNameField.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),
            lastNameField.heightAnchor.constraint(equalToConstant: 44),

            mobileField.topAnchor.constraint(equalTo: lastNameField.bottomAnchor, constant: 12),
            mobileField.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            mobileField.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),
            mobileField.heightAnchor.constraint(equalToConstant: 44),

            emailField.topAnchor.constraint(equalTo: mobileField.bottomAnchor, constant: 12),
            emailField.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            emailField.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),
            emailField.heightAnchor.constraint(equalToConstant: 44),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 12),
            passwordField.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            passwordField.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),
            passwordField.heightAnchor.constraint(equalToConstant: 44),

            confirmPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 12),
            confirmPasswordField.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            confirmPasswordField.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: 44),

            registerButton.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 18),
            registerButton.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            registerButton.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),
            registerButton.heightAnchor.constraint(equalToConstant: 46),

            registerActivityIndicator.centerYAnchor.constraint(equalTo: registerButton.centerYAnchor),
            registerActivityIndicator.trailingAnchor.constraint(equalTo: registerButton.trailingAnchor, constant: -16),

            backToTrustCodeButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 12),
            backToTrustCodeButton.centerXAnchor.constraint(equalTo: detailsCardView.centerXAnchor),
            backToTrustCodeButton.bottomAnchor.constraint(equalTo: detailsCardView.bottomAnchor, constant: -16)
        ])
    }

    private func styleTextField(_ tf: UITextField, placeholder: String, icon: String) {
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 6
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(red: 218/255, green: 224/255, blue: 233/255, alpha: 1.0).cgColor
        tf.textColor = UIColor(red: 46/255, green: 54/255, blue: 63/255, alpha: 1.0)
        tf.font = UIFont.systemFont(ofSize: 14.5, weight: .medium)
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(red: 140/255, green: 150/255, blue: 160/255, alpha: 1.0)]
        )

        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 44))
        let iconView = UIImageView(frame: CGRect(x: 10, y: 13, width: 18, height: 18))
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = UIColor(red: 100/255, green: 110/255, blue: 120/255, alpha: 1.0)
        iconView.contentMode = .scaleAspectFit
        leftView.addSubview(iconView)
        tf.leftView = leftView
        tf.leftViewMode = .always
    }

    private func setupPasswordToggle(_ button: UIButton, targetField: UITextField) {
        button.setTitle("Show", for: .normal)
        button.setTitleColor(UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        button.frame = CGRect(x: 0, y: 0, width: 55, height: 44)
        button.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)

        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
        rightView.addSubview(button)
        targetField.rightView = rightView
        targetField.rightViewMode = .always
    }

    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        if sender == showPasswordButton {
            passwordField.isSecureTextEntry.toggle()
            sender.setTitle(passwordField.isSecureTextEntry ? "Show" : "Hide", for: .normal)
        } else {
            confirmPasswordField.isSecureTextEntry.toggle()
            sender.setTitle(confirmPasswordField.isSecureTextEntry ? "Show" : "Hide", for: .normal)
        }
    }

    private func updateStepUI() {
        errorLabel.isHidden = true
        switch currentStep {
        case .enterTrustCode:
            trustCardContainer.isHidden = false
            detailsCardView.isHidden = true
        case .enterUserDetails:
            trustCardContainer.isHidden = true
            detailsCardView.isHidden = false
            verifiedTrustTitleLabel.text = verifiedMerchantName
            verifiedTrustCodeLabel.text = "Trust Code: \(enteredTrustCode)"
        }
    }

    // MARK: - Step 1: Trust Code Verification (POST /api/check-trust-code)
    @objc private func trustCodeChanged() {
        errorLabel.isHidden = true
    }

    @objc private func handleTrustCodeSubmit() {
        view.endEditing(true)
        let code = trustCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !code.isEmpty else {
            showError("Please enter your Trust/Institution code.")
            return
        }

        submitArrowButton.isHidden = true
        trustActivityIndicator.startAnimating()
        errorLabel.isHidden = true

        guard let url = URL(string: AppConfig.API.checkTrustCode) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(AppConfig.apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let params: [String: String] = [
            "code": code,
            "device_type": AppConfig.deviceType,
            "mobile_device_id": AppConfig.mobileDeviceId
        ]
        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.submitArrowButton.isHidden = false
                self?.trustActivityIndicator.stopAnimating()

                if let error = error {
                    self?.showError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self?.showError("Invalid response from server.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let message = json["message"] as? String ?? ""

                if status, let dataObj = json["data"] as? [String: Any], let merchantId = dataObj["id"] as? Int, merchantId > 0 {
                    self?.verifiedMerchantId = merchantId
                    self?.verifiedMerchantName = (dataObj["name"] as? String) ?? "Registered Trust"
                    self?.enteredTrustCode = code
                    self?.currentStep = .enterUserDetails
                    self?.updateStepUI()
                } else {
                    self?.showError(message.isEmpty ? "Please enter valid trust code. Contact helpline." : message)
                }
            }
        }.resume()
    }

    @objc private func showTrustCodeInfo() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let alert = UIAlertController(
            title: "Trust/Institution Code",
            message: "A unique code assigned to your trust or branch institution. If you do not have a Trust Code, please contact your Trust Administrator or Helpline.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func handleBackToTrustCode() {
        currentStep = .enterTrustCode
        updateStepUI()
    }

    // MARK: - Step 2: User Registration (POST /api/register)
    @objc private func handleRegisterSubmit() {
        view.endEditing(true)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        let fname = firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lname = lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let mobile = mobileField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField.text ?? ""
        let confirmPass = confirmPasswordField.text ?? ""

        guard !fname.isEmpty else { showError("Please enter your First Name."); return }
        guard !lname.isEmpty else { showError("Please enter your Last Name."); return }
        guard !mobile.isEmpty, mobile.count >= 10 else { showError("Please enter a valid 10-digit Mobile Number."); return }
        guard !email.isEmpty, email.contains("@") else { showError("Please enter a valid Email Address."); return }
        guard password.count >= 6 else { showError("Password must be at least 6 characters long."); return }
        guard password == confirmPass else { showError("Passwords do not match."); return }

        registerButton.isEnabled = false
        registerButton.setTitle("", for: .normal)
        registerActivityIndicator.startAnimating()
        errorLabel.isHidden = true

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
            "trust_code": enteredTrustCode,
            "device_type": AppConfig.deviceType,
            "device_id": AppConfig.deviceId,
            "mobile_device_id": AppConfig.mobileDeviceId
        ]

        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.registerButton.isEnabled = true
                self?.registerButton.setTitle("Create Account  ➔", for: .normal)
                self?.registerActivityIndicator.stopAnimating()

                if let error = error {
                    self?.showError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self?.showError("Invalid response from server.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let message = json["message"] as? String ?? ""

                if status {
                    let alert = UIAlertController(
                        title: "Registration Successful",
                        message: "Your account has been registered successfully under \(self?.verifiedMerchantName ?? "the Trust"). You can now log in.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Log In Now", style: .default, handler: { _ in
                        self?.dismiss(animated: true) {
                            self?.onSignUpSuccess?(email)
                        }
                    }))
                    self?.present(alert, animated: true)
                } else {
                    self?.showError(message.isEmpty ? "Registration failed. Please check your details." : message)
                }
            }
        }.resume()
    }

    private func showError(_ msg: String) {
        errorLabel.text = "  \(msg)  "
        errorLabel.isHidden = false
    }

    @objc private func dismissModal() {
        dismiss(animated: true)
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
        }
        return true
    }
}
