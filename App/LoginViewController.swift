import UIKit
import Network
import SafariServices

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header Elements
    private let welcomeLabel = UILabel()
    private let appLogoImageView = UIImageView()

    // Social Login
    private let googleLoginButton = UIButton(type: .custom)
    private let topOrLabel = UILabel()

    // Central Card
    private let cardView = UIView()
    
    // User ID & Password
    private let userIdTitleLabel = UILabel()
    private let emailContainer = UIView()
    private let emailBadge = UIImageView()
    private let emailTextField = UITextField()

    private let passwordTitleLabel = UILabel()
    private let passwordContainer = UIView()
    private let passwordBadge = UIImageView()
    private let passwordTextField = UITextField()
    private let showPasswordTrailingButton = UIButton(type: .system)

    // Tutorial & Reset Password Row
    private let actionLinksStack = UIStackView()
    private let tutorialButton = UIButton(type: .system)
    private let resetPasswordButton = UIButton(type: .system)

    // Card Bottom Action Bar
    private let cardBottomBar = UIView()
    private let infoButton = UIButton(type: .system)
    private let loginButton = UIButton(type: .custom)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // Bottom Links
    private let bottomOrLabel = UILabel()
    private let signUpButton = UIButton(type: .system)

    // Footer
    private let footerStack = UIStackView()
    private let privacyPolicyButton = UIButton(type: .system)
    private let footerDividerLabel = UILabel()
    private let contactButton = UIButton(type: .system)
    private let versionLabel = UILabel()

    // Error Alert
    private let errorLabel = UILabel()

    // MARK: - Help Modal Dialog
    private let helpOverlayBackdrop = UIView()
    private let helpCardContainer = UIView()
    private let helpHeaderView = UIView()
    private let helpTitleLabel = UILabel()
    private let helpCloseButton = UIButton(type: .system)
    private let helpHeaderDivider = UIView()
    private let helpTextView = UITextView()
    private let helpSpinner = UIActivityIndicatorView(style: .medium)

    // MARK: - Android-Style Message Popup (247 / Available on sign up only)
    private let androidPopupBackdrop = UIView()
    private let androidPopupCard = UIView()
    private let androidPopupEmblem = UIImageView()
    private let androidPopupCodeLabel = UILabel()
    private let androidPopupMsgLabel = UILabel()
    private let androidPopupVersionLabel = UILabel()
    private let androidPopupOkButton = UIButton(type: .system)

    // MARK: - Offline View (App Store Guideline 4.2 Compliant)
    private let offlineOverlayView = UIView()
    private let networkMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitorQueue")
    private var isNetworkAvailable = true

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
        setupNetworkMonitoring()
        setupHelpDialogUI()
        setupAndroidPopupUI()
        AppConfig.fetchRemoteSettings()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 46/255, green: 54/255, blue: 63/255, alpha: 1.0)

        // ScrollView Setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // 1. Welcome Title
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.text = "Welcome"
        welcomeLabel.textColor = .white
        welcomeLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        welcomeLabel.textAlignment = .center
        contentView.addSubview(welcomeLabel)

        // 2. App Logo
        appLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        if let emblem = UIImage(named: "trust_emblem") ?? UIImage(named: "AppIcon-1024") ?? UIImage(named: "AppIcon") {
            appLogoImageView.image = emblem
        } else {
            appLogoImageView.image = UIImage(systemName: "seal.fill")
        }
        appLogoImageView.contentMode = .scaleAspectFit
        contentView.addSubview(appLogoImageView)

        // 3. Login Via Gmail Button
        googleLoginButton.translatesAutoresizingMaskIntoConstraints = false
        googleLoginButton.setTitle("  Login Via Gmail", for: .normal)
        googleLoginButton.setImage(UIImage(systemName: "g.circle.fill"), for: .normal)
        googleLoginButton.tintColor = .white
        googleLoginButton.setTitleColor(.white, for: .normal)
        googleLoginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        googleLoginButton.backgroundColor = UIColor(red: 234/255, green: 67/255, blue: 53/255, alpha: 1.0)
        googleLoginButton.layer.cornerRadius = 8
        googleLoginButton.layer.shadowColor = UIColor.black.cgColor
        googleLoginButton.layer.shadowOpacity = 0.2
        googleLoginButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        googleLoginButton.layer.shadowRadius = 4
        googleLoginButton.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
        contentView.addSubview(googleLoginButton)

        // 4. Top "OR"
        topOrLabel.translatesAutoresizingMaskIntoConstraints = false
        topOrLabel.text = "— OR —"
        topOrLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        topOrLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        topOrLabel.textAlignment = .center
        contentView.addSubview(topOrLabel)

        // 5. Error Banner
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.backgroundColor = UIColor(red: 185/255, green: 74/255, blue: 72/255, alpha: 1.0)
        errorLabel.textColor = .white
        errorLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.layer.cornerRadius = 6
        errorLabel.layer.masksToBounds = true
        errorLabel.isHidden = true
        contentView.addSubview(errorLabel)

        // 6. Central Card
        setupCentralCard()

        // 7. Bottom "OR"
        bottomOrLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomOrLabel.text = "— OR —"
        bottomOrLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        bottomOrLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        bottomOrLabel.textAlignment = .center
        contentView.addSubview(bottomOrLabel)

        // 8. New User? SignUp Button
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.setTitle("New User? SignUp", for: .normal)
        signUpButton.setTitleColor(UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0), for: .normal)
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        signUpButton.addTarget(self, action: #selector(openSignUpModal), for: .touchUpInside)
        contentView.addSubview(signUpButton)

        // 9. Footer
        setupFooter()

        // Constraints
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            welcomeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            appLogoImageView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 14),
            appLogoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            appLogoImageView.widthAnchor.constraint(equalToConstant: 80),
            appLogoImageView.heightAnchor.constraint(equalToConstant: 80),

            googleLoginButton.topAnchor.constraint(equalTo: appLogoImageView.bottomAnchor, constant: 18),
            googleLoginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 36),
            googleLoginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -36),
            googleLoginButton.heightAnchor.constraint(equalToConstant: 46),

            topOrLabel.topAnchor.constraint(equalTo: googleLoginButton.bottomAnchor, constant: 14),
            topOrLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            errorLabel.topAnchor.constraint(equalTo: topOrLabel.bottomAnchor, constant: 10),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            cardView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            bottomOrLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            bottomOrLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            signUpButton.topAnchor.constraint(equalTo: bottomOrLabel.bottomAnchor, constant: 8),
            signUpButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 36),

            footerStack.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 24),
            footerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            footerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            footerStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])

        setupOfflineView()
    }

    private func setupCentralCard() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor(red: 46/255, green: 54/255, blue: 63/255, alpha: 1.0)
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        contentView.addSubview(cardView)

        // User ID Label & Field
        userIdTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        userIdTitleLabel.text = "Enter User ID"
        userIdTitleLabel.textColor = .white
        userIdTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        cardView.addSubview(userIdTitleLabel)

        setupInputContainer(container: emailContainer, badge: emailBadge, textField: emailTextField,
                            badgeColor: UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0),
                            iconName: "person.fill", placeholder: "Enter your Userid")
        cardView.addSubview(emailContainer)

        // Password Label & Field
        passwordTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordTitleLabel.text = "Password"
        passwordTitleLabel.textColor = .white
        passwordTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        cardView.addSubview(passwordTitleLabel)

        setupPasswordContainer()
        cardView.addSubview(passwordContainer)

        // Action Links: Reset Password (Tutorial hidden)
        setupActionLinksRow()
        cardView.addSubview(actionLinksStack)

        // Card Bottom Bar (Info + Login)
        setupCardBottomBar()
        cardView.addSubview(cardBottomBar)

        NSLayoutConstraint.activate([
            userIdTitleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            userIdTitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),

            emailContainer.topAnchor.constraint(equalTo: userIdTitleLabel.bottomAnchor, constant: 6),
            emailContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            emailContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            emailContainer.heightAnchor.constraint(equalToConstant: 46),

            passwordTitleLabel.topAnchor.constraint(equalTo: emailContainer.bottomAnchor, constant: 14),
            passwordTitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),

            passwordContainer.topAnchor.constraint(equalTo: passwordTitleLabel.bottomAnchor, constant: 6),
            passwordContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            passwordContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            passwordContainer.heightAnchor.constraint(equalToConstant: 46),

            actionLinksStack.topAnchor.constraint(equalTo: passwordContainer.bottomAnchor, constant: 14),
            actionLinksStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            actionLinksStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            cardBottomBar.topAnchor.constraint(equalTo: actionLinksStack.bottomAnchor, constant: 16),
            cardBottomBar.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            cardBottomBar.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            cardBottomBar.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            cardBottomBar.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    private func setupInputContainer(container: UIView, badge: UIImageView, textField: UITextField,
                                     badgeColor: UIColor, iconName: String, placeholder: String) {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 6
        container.layer.masksToBounds = true
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor(red: 218/255, green: 224/255, blue: 233/255, alpha: 1.0).cgColor

        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.backgroundColor = badgeColor
        badge.image = UIImage(systemName: iconName)
        badge.tintColor = .white
        badge.contentMode = .center
        container.addSubview(badge)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = UIColor(red: 46/255, green: 54/255, blue: 63/255, alpha: 1.0)
        textField.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.delegate = self
        textField.returnKeyType = .next
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(red: 140/255, green: 150/255, blue: 160/255, alpha: 1.0)]
        )
        container.addSubview(textField)

        NSLayoutConstraint.activate([
            badge.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            badge.topAnchor.constraint(equalTo: container.topAnchor),
            badge.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            badge.widthAnchor.constraint(equalToConstant: 44),

            textField.leadingAnchor.constraint(equalTo: badge.trailingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            textField.topAnchor.constraint(equalTo: container.topAnchor),
            textField.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }

    private func setupPasswordContainer() {
        passwordContainer.translatesAutoresizingMaskIntoConstraints = false
        passwordContainer.backgroundColor = .white
        passwordContainer.layer.cornerRadius = 6
        passwordContainer.layer.masksToBounds = true
        passwordContainer.layer.borderWidth = 1
        passwordContainer.layer.borderColor = UIColor(red: 218/255, green: 224/255, blue: 233/255, alpha: 1.0).cgColor

        passwordBadge.translatesAutoresizingMaskIntoConstraints = false
        passwordBadge.backgroundColor = UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0) // Web Amber Gold #FFB848
        passwordBadge.image = UIImage(systemName: "lock.fill")
        passwordBadge.tintColor = .white
        passwordBadge.contentMode = .center
        passwordContainer.addSubview(passwordBadge)

        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.textColor = UIColor(red: 46/255, green: 54/255, blue: 63/255, alpha: 1.0)
        passwordTextField.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        passwordTextField.returnKeyType = .go
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Type Your Password",
            attributes: [.foregroundColor: UIColor(red: 140/255, green: 150/255, blue: 160/255, alpha: 1.0)]
        )
        passwordContainer.addSubview(passwordTextField)

        showPasswordTrailingButton.translatesAutoresizingMaskIntoConstraints = false
        showPasswordTrailingButton.setTitle("Show", for: .normal)
        showPasswordTrailingButton.setTitleColor(UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0), for: .normal)
        showPasswordTrailingButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        showPasswordTrailingButton.addTarget(self, action: #selector(toggleShowPassword), for: .touchUpInside)
        passwordContainer.addSubview(showPasswordTrailingButton)

        NSLayoutConstraint.activate([
            passwordBadge.leadingAnchor.constraint(equalTo: passwordContainer.leadingAnchor),
            passwordBadge.topAnchor.constraint(equalTo: passwordContainer.topAnchor),
            passwordBadge.bottomAnchor.constraint(equalTo: passwordContainer.bottomAnchor),
            passwordBadge.widthAnchor.constraint(equalToConstant: 44),

            passwordTextField.leadingAnchor.constraint(equalTo: passwordBadge.trailingAnchor, constant: 12),
            passwordTextField.trailingAnchor.constraint(equalTo: showPasswordTrailingButton.leadingAnchor, constant: -8),
            passwordTextField.topAnchor.constraint(equalTo: passwordContainer.topAnchor),
            passwordTextField.bottomAnchor.constraint(equalTo: passwordContainer.bottomAnchor),

            showPasswordTrailingButton.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor, constant: -12),
            showPasswordTrailingButton.centerYAnchor.constraint(equalTo: passwordContainer.centerYAnchor),
            showPasswordTrailingButton.widthAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupActionLinksRow() {
        actionLinksStack.translatesAutoresizingMaskIntoConstraints = false
        actionLinksStack.axis = .horizontal
        actionLinksStack.distribution = .fill
        actionLinksStack.alignment = .trailing

        // Tutorial Button (Hidden per user request)
        tutorialButton.isHidden = true

        // Reset Password Button (Web Terracotta Orange #DA542E)
        resetPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        resetPasswordButton.setImage(UIImage(systemName: "key.fill"), for: .normal)
        resetPasswordButton.tintColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
        resetPasswordButton.setTitle(" Reset Password", for: .normal)
        resetPasswordButton.setTitleColor(UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0), for: .normal)
        resetPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        resetPasswordButton.addTarget(self, action: #selector(openResetPasswordModal), for: .touchUpInside)
        actionLinksStack.addArrangedSubview(resetPasswordButton)
    }

    private func setupCardBottomBar() {
        cardBottomBar.translatesAutoresizingMaskIntoConstraints = false
        cardBottomBar.backgroundColor = UIColor(red: 38/255, green: 45/255, blue: 53/255, alpha: 1.0)

        // Info Button (i)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
        infoButton.tintColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
        infoButton.addTarget(self, action: #selector(openInfoModal), for: .touchUpInside)
        cardBottomBar.addSubview(infoButton)

        // Login Button
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setTitle("Login  ➔", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        loginButton.backgroundColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        loginButton.layer.cornerRadius = 6
        loginButton.addTarget(self, action: #selector(handleLoginTap), for: .touchUpInside)
        cardBottomBar.addSubview(loginButton)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        loginButton.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            infoButton.leadingAnchor.constraint(equalTo: cardBottomBar.leadingAnchor, constant: 16),
            infoButton.centerYAnchor.constraint(equalTo: cardBottomBar.centerYAnchor),
            infoButton.widthAnchor.constraint(equalToConstant: 32),
            infoButton.heightAnchor.constraint(equalToConstant: 32),

            loginButton.trailingAnchor.constraint(equalTo: cardBottomBar.trailingAnchor, constant: -16),
            loginButton.centerYAnchor.constraint(equalTo: cardBottomBar.centerYAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 120),
            loginButton.heightAnchor.constraint(equalToConstant: 38),

            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor, constant: -12)
        ])
    }

    private func setupFooter() {
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        footerStack.axis = .horizontal
        footerStack.distribution = .equalSpacing
        footerStack.alignment = .center
        contentView.addSubview(footerStack)

        let leftLinks = UIStackView()
        leftLinks.axis = .horizontal
        leftLinks.spacing = 8

        privacyPolicyButton.setTitle("Privacy policy", for: .normal)
        privacyPolicyButton.setTitleColor(UIColor.white.withAlphaComponent(0.65), for: .normal)
        privacyPolicyButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        privacyPolicyButton.addTarget(self, action: #selector(openPrivacyPolicyModal), for: .touchUpInside)
        leftLinks.addArrangedSubview(privacyPolicyButton)

        footerDividerLabel.text = "|"
        footerDividerLabel.textColor = UIColor.white.withAlphaComponent(0.4)
        footerDividerLabel.font = UIFont.systemFont(ofSize: 13)
        leftLinks.addArrangedSubview(footerDividerLabel)

        contactButton.setTitle("Contact", for: .normal)
        contactButton.setTitleColor(UIColor.white.withAlphaComponent(0.65), for: .normal)
        contactButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        contactButton.addTarget(self, action: #selector(openContactSheet), for: .touchUpInside)
        leftLinks.addArrangedSubview(contactButton)

        footerStack.addArrangedSubview(leftLinks)

        // Version Label (Pure dynamic from bundle)
        versionLabel.text = AppConfig.appVersion
        versionLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        versionLabel.font = UIFont.systemFont(ofSize: 13)
        footerStack.addArrangedSubview(versionLabel)
    }

    // MARK: - Help Modal Dialog (API-driven)
    private func setupHelpDialogUI() {
        helpOverlayBackdrop.translatesAutoresizingMaskIntoConstraints = false
        helpOverlayBackdrop.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        helpOverlayBackdrop.isHidden = true
        view.addSubview(helpOverlayBackdrop)

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(handleCloseHelpDialog))
        helpOverlayBackdrop.addGestureRecognizer(dismissTap)

        helpCardContainer.translatesAutoresizingMaskIntoConstraints = false
        helpCardContainer.backgroundColor = .white
        helpCardContainer.layer.cornerRadius = 10
        helpCardContainer.layer.masksToBounds = true
        helpOverlayBackdrop.addSubview(helpCardContainer)

        let stopTap = UITapGestureRecognizer(target: nil, action: nil)
        helpCardContainer.addGestureRecognizer(stopTap)

        // Header
        helpHeaderView.translatesAutoresizingMaskIntoConstraints = false
        helpCardContainer.addSubview(helpHeaderView)

        helpTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        helpTitleLabel.text = "Help"
        helpTitleLabel.textColor = UIColor(red: 46/255, green: 54/255, blue: 63/255, alpha: 1.0)
        helpTitleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        helpHeaderView.addSubview(helpTitleLabel)

        helpCloseButton.translatesAutoresizingMaskIntoConstraints = false
        helpCloseButton.setTitle("✕", for: .normal)
        helpCloseButton.setTitleColor(UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0), for: .normal)
        helpCloseButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        helpCloseButton.addTarget(self, action: #selector(handleCloseHelpDialog), for: .touchUpInside)
        helpHeaderView.addSubview(helpCloseButton)

        helpHeaderDivider.translatesAutoresizingMaskIntoConstraints = false
        helpHeaderDivider.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
        helpCardContainer.addSubview(helpHeaderDivider)

        // Content Text View
        helpTextView.translatesAutoresizingMaskIntoConstraints = false
        helpTextView.isEditable = false
        helpTextView.isSelectable = false
        helpTextView.backgroundColor = .clear
        helpTextView.textColor = UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1.0)
        helpTextView.font = UIFont.systemFont(ofSize: 14.5, weight: .regular)
        helpTextView.showsVerticalScrollIndicator = true
        helpCardContainer.addSubview(helpTextView)

        helpSpinner.translatesAutoresizingMaskIntoConstraints = false
        helpSpinner.hidesWhenStopped = true
        helpSpinner.color = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
        helpCardContainer.addSubview(helpSpinner)

        NSLayoutConstraint.activate([
            helpOverlayBackdrop.topAnchor.constraint(equalTo: view.topAnchor),
            helpOverlayBackdrop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            helpOverlayBackdrop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            helpOverlayBackdrop.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            helpCardContainer.centerXAnchor.constraint(equalTo: helpOverlayBackdrop.centerXAnchor),
            helpCardContainer.centerYAnchor.constraint(equalTo: helpOverlayBackdrop.centerYAnchor),
            helpCardContainer.leadingAnchor.constraint(equalTo: helpOverlayBackdrop.leadingAnchor, constant: 20),
            helpCardContainer.trailingAnchor.constraint(equalTo: helpOverlayBackdrop.trailingAnchor, constant: -20),
            helpCardContainer.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.65),

            helpHeaderView.topAnchor.constraint(equalTo: helpCardContainer.topAnchor, constant: 14),
            helpHeaderView.leadingAnchor.constraint(equalTo: helpCardContainer.leadingAnchor, constant: 18),
            helpHeaderView.trailingAnchor.constraint(equalTo: helpCardContainer.trailingAnchor, constant: -18),
            helpHeaderView.heightAnchor.constraint(equalToConstant: 32),

            helpTitleLabel.leadingAnchor.constraint(equalTo: helpHeaderView.leadingAnchor),
            helpTitleLabel.centerYAnchor.constraint(equalTo: helpHeaderView.centerYAnchor),

            helpCloseButton.trailingAnchor.constraint(equalTo: helpHeaderView.trailingAnchor),
            helpCloseButton.centerYAnchor.constraint(equalTo: helpHeaderView.centerYAnchor),
            helpCloseButton.widthAnchor.constraint(equalToConstant: 30),
            helpCloseButton.heightAnchor.constraint(equalToConstant: 30),

            helpHeaderDivider.topAnchor.constraint(equalTo: helpHeaderView.bottomAnchor, constant: 10),
            helpHeaderDivider.leadingAnchor.constraint(equalTo: helpCardContainer.leadingAnchor),
            helpHeaderDivider.trailingAnchor.constraint(equalTo: helpCardContainer.trailingAnchor),
            helpHeaderDivider.heightAnchor.constraint(equalToConstant: 1),

            helpTextView.topAnchor.constraint(equalTo: helpHeaderDivider.bottomAnchor, constant: 10),
            helpTextView.leadingAnchor.constraint(equalTo: helpCardContainer.leadingAnchor, constant: 16),
            helpTextView.trailingAnchor.constraint(equalTo: helpCardContainer.trailingAnchor, constant: -16),
            helpTextView.bottomAnchor.constraint(equalTo: helpCardContainer.bottomAnchor, constant: -16),

            helpSpinner.centerXAnchor.constraint(equalTo: helpCardContainer.centerXAnchor),
            helpSpinner.centerYAnchor.constraint(equalTo: helpCardContainer.centerYAnchor)
        ])
    }

    private func presentHelpModal(title: String = "Help", defaultText: String, apiEndpoint: String? = nil, postParams: [String: String]? = nil) {
        view.endEditing(true)
        helpTitleLabel.text = title
        helpTextView.text = defaultText
        helpTextView.setContentOffset(.zero, animated: false)

        helpOverlayBackdrop.alpha = 0
        helpOverlayBackdrop.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.helpOverlayBackdrop.alpha = 1.0
        }

        guard let endpoint = apiEndpoint, let url = URL(string: endpoint) else { return }

        helpSpinner.startAnimating()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(AppConfig.apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let params = postParams ?? [:]
        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.helpSpinner.stopAnimating()
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let dataObj = json["data"] as? [String: Any],
                      let helpStr = dataObj["help"] as? String,
                      !helpStr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return
                }
                self.helpTextView.text = helpStr.replacingOccurrences(of: "\\r\\n", with: "\n").replacingOccurrences(of: "\r\n", with: "\n")
            }
        }.resume()
    }

    @objc private func handleCloseHelpDialog() {
        UIView.animate(withDuration: 0.2, animations: {
            self.helpOverlayBackdrop.alpha = 0
        }) { _ in
            self.helpOverlayBackdrop.isHidden = true
        }
    }

    // MARK: - Keyboard Handling
    private func setupKeyboardHandling() {
        // Tap anywhere on screen to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        // Observe keyboard will show and hide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        let bottomPadding: CGFloat = 20
        scrollView.contentInset.bottom = keyboardHeight + bottomPadding
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight + bottomPadding
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            handleLoginTap()
        }
        return true
    }

    // MARK: - Actions
    @objc private func toggleShowPassword() {
        passwordTextField.isSecureTextEntry.toggle()
        let title = passwordTextField.isSecureTextEntry ? "Show" : "Hide"
        showPasswordTrailingButton.setTitle(title, for: .normal)
    }

    @objc private func openTutorial() {
        // Tutorial hidden
    }

    @objc private func openResetPasswordModal() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let resetVC = ResetPasswordViewController()
        resetVC.onResetPasswordSuccess = { [weak self] resetEmail in
            self?.emailTextField.text = resetEmail
        }
        resetVC.modalPresentationStyle = .overFullScreen
        resetVC.modalTransitionStyle = .crossDissolve
        present(resetVC, animated: true)
    }

    @objc private func openSignUpModal() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let signUpVC = SignUpViewController()
        signUpVC.onSignUpSuccess = { [weak self] registeredEmail in
            self?.emailTextField.text = registeredEmail
        }
        signUpVC.modalPresentationStyle = .overFullScreen
        signUpVC.modalTransitionStyle = .crossDissolve
        present(signUpVC, animated: true)
    }

    // Login screen info (i) button - opens live dynamic Help modal
    @objc private func openInfoModal() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let fallbackText = """
        Welcome !

        To Use this app for purposes of Data entry & submission to your office press the button 'Login by Gmail' and:

        1. Enter the pre-approved Trust code of your organization and press ->

        2. Enter your Branchid or Office id.

        3. Enter User and Branch details.

        4. Click Register to proceed.

        5. App will be ready for use once the sign up request is approved by the authorised staff of the said Trust/Institution/Company.

        Notes :
        1. Register one userid on one mobile device.
         
        2. The privacy policy and the contact details of the Trust code organization, applicable on signup only, are as on its website.

        3. To use the app for Scan & Share without signup touch on the eScan.

        4. To Register Trust/Institution code write to : manojarora_2000@yahoo.com ; info@enin.io
        """
        presentHelpModal(title: "Help", defaultText: fallbackText, apiEndpoint: AppConfig.API.getHelpReg)
    }

    // MARK: - Privacy Policy & Contact Popups (Android-Matched 247 Dialog)
    @objc private func openPrivacyPolicyModal() {
        presentAndroidStylePopup(code: "247", message: "Available on sign up only.")
    }

    @objc private func openContactSheet() {
        presentAndroidStylePopup(code: "247", message: "Available on sign up only.")
    }

    // MARK: - Android Style Modal Dialog (247 / Available on sign up only.)
    private func setupAndroidPopupUI() {
        androidPopupBackdrop.translatesAutoresizingMaskIntoConstraints = false
        androidPopupBackdrop.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        androidPopupBackdrop.isHidden = true
        view.addSubview(androidPopupBackdrop)

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissAndroidPopup))
        androidPopupBackdrop.addGestureRecognizer(dismissTap)

        androidPopupCard.translatesAutoresizingMaskIntoConstraints = false
        androidPopupCard.backgroundColor = .white
        androidPopupCard.layer.cornerRadius = 12
        androidPopupCard.layer.masksToBounds = true
        androidPopupBackdrop.addSubview(androidPopupCard)

        let stopTap = UITapGestureRecognizer(target: nil, action: nil)
        androidPopupCard.addGestureRecognizer(stopTap)

        // Green Trust Emblem
        androidPopupEmblem.translatesAutoresizingMaskIntoConstraints = false
        androidPopupEmblem.image = UIImage(named: "trust_emblem") ?? UIImage(systemName: "checkmark.seal.fill")
        androidPopupEmblem.tintColor = UIColor(red: 40/255, green: 167/255, blue: 69/255, alpha: 1.0)
        androidPopupEmblem.contentMode = .scaleAspectFit
        androidPopupCard.addSubview(androidPopupEmblem)

        // Code Label (e.g. "247")
        androidPopupCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        androidPopupCodeLabel.text = "247"
        androidPopupCodeLabel.textColor = UIColor(red: 30/255, green: 36/255, blue: 43/255, alpha: 1.0)
        androidPopupCodeLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        androidPopupCard.addSubview(androidPopupCodeLabel)

        // Body Message: "Available on sign up only."
        androidPopupMsgLabel.translatesAutoresizingMaskIntoConstraints = false
        androidPopupMsgLabel.text = "Available on sign up only."
        androidPopupMsgLabel.textColor = UIColor(red: 30/255, green: 36/255, blue: 43/255, alpha: 1.0)
        androidPopupMsgLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        androidPopupMsgLabel.numberOfLines = 0
        androidPopupCard.addSubview(androidPopupMsgLabel)

        // Version Label ("v t 2.0.10") at bottom-left
        androidPopupVersionLabel.translatesAutoresizingMaskIntoConstraints = false
        androidPopupVersionLabel.text = AppConfig.appVersion
        androidPopupVersionLabel.textColor = UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1.0)
        androidPopupVersionLabel.font = UIFont.systemFont(ofSize: 12.5, weight: .regular)
        androidPopupCard.addSubview(androidPopupVersionLabel)

        // Ok Button at bottom-right
        androidPopupOkButton.translatesAutoresizingMaskIntoConstraints = false
        androidPopupOkButton.setTitle("Ok", for: .normal)
        androidPopupOkButton.setTitleColor(UIColor(red: 30/255, green: 36/255, blue: 43/255, alpha: 1.0), for: .normal)
        androidPopupOkButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        androidPopupOkButton.addTarget(self, action: #selector(dismissAndroidPopup), for: .touchUpInside)
        androidPopupCard.addSubview(androidPopupOkButton)

        NSLayoutConstraint.activate([
            androidPopupBackdrop.topAnchor.constraint(equalTo: view.topAnchor),
            androidPopupBackdrop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            androidPopupBackdrop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            androidPopupBackdrop.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            androidPopupCard.centerXAnchor.constraint(equalTo: androidPopupBackdrop.centerXAnchor),
            androidPopupCard.centerYAnchor.constraint(equalTo: androidPopupBackdrop.centerYAnchor),
            androidPopupCard.leadingAnchor.constraint(equalTo: androidPopupBackdrop.leadingAnchor, constant: 28),
            androidPopupCard.trailingAnchor.constraint(equalTo: androidPopupBackdrop.trailingAnchor, constant: -28),

            androidPopupEmblem.topAnchor.constraint(equalTo: androidPopupCard.topAnchor, constant: 22),
            androidPopupEmblem.leadingAnchor.constraint(equalTo: androidPopupCard.leadingAnchor, constant: 20),
            androidPopupEmblem.widthAnchor.constraint(equalToConstant: 32),
            androidPopupEmblem.heightAnchor.constraint(equalToConstant: 32),

            androidPopupCodeLabel.leadingAnchor.constraint(equalTo: androidPopupEmblem.trailingAnchor, constant: 10),
            androidPopupCodeLabel.centerYAnchor.constraint(equalTo: androidPopupEmblem.centerYAnchor),

            androidPopupMsgLabel.topAnchor.constraint(equalTo: androidPopupEmblem.bottomAnchor, constant: 18),
            androidPopupMsgLabel.leadingAnchor.constraint(equalTo: androidPopupCard.leadingAnchor, constant: 20),
            androidPopupMsgLabel.trailingAnchor.constraint(equalTo: androidPopupCard.trailingAnchor, constant: -20),

            androidPopupVersionLabel.leadingAnchor.constraint(equalTo: androidPopupCard.leadingAnchor, constant: 20),
            androidPopupVersionLabel.bottomAnchor.constraint(equalTo: androidPopupCard.bottomAnchor, constant: -18),

            androidPopupOkButton.trailingAnchor.constraint(equalTo: androidPopupCard.trailingAnchor, constant: -24),
            androidPopupOkButton.bottomAnchor.constraint(equalTo: androidPopupCard.bottomAnchor, constant: -14),
            androidPopupOkButton.topAnchor.constraint(equalTo: androidPopupMsgLabel.bottomAnchor, constant: 36)
        ])
    }

    private func presentAndroidStylePopup(code: String = "247", message: String = "Available on sign up only.") {
        view.endEditing(true)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        androidPopupCodeLabel.text = code
        androidPopupMsgLabel.text = message
        androidPopupVersionLabel.text = AppConfig.appVersion

        androidPopupBackdrop.alpha = 0
        androidPopupBackdrop.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.androidPopupBackdrop.alpha = 1.0
        }
    }

    @objc private func dismissAndroidPopup() {
        UIView.animate(withDuration: 0.2, animations: {
            self.androidPopupBackdrop.alpha = 0
        }) { _ in
            self.androidPopupBackdrop.isHidden = true
        }
    }

    // MARK: - Google Account Chooser & Social Login
    @objc private func handleGoogleLogin() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        var accounts = UserDefaults.standard.stringArray(forKey: "saved_google_accounts") ?? []
        let currentFieldEmail = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if currentFieldEmail.contains("@") && !accounts.contains(currentFieldEmail) {
            accounts.insert(currentFieldEmail, at: 0)
        }

        let actionSheet = UIAlertController(
            title: "Sign in with Google",
            message: "Choose a Gmail account to log in directly to SAT:",
            preferredStyle: .actionSheet
        )

        // List each available account for direct 1-tap sign in
        for email in accounts {
            let accountAction = UIAlertAction(title: "👤  \(email)", style: .default) { [weak self] _ in
                self?.performSocialLoginRequest(email: email)
            }
            actionSheet.addAction(accountAction)
        }

        // Option to add/use another Google account
        let addAccountAction = UIAlertAction(title: "➕  Use another account...", style: .default) { [weak self] _ in
            self?.promptForNewGoogleAccount()
        }
        actionSheet.addAction(addAccountAction)

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // Support iPad popovers
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = googleLoginButton
            popover.sourceRect = googleLoginButton.bounds
        }

        present(actionSheet, animated: true)
    }

    private func promptForNewGoogleAccount() {
        let alert = UIAlertController(
            title: "Add Google Account",
            message: "Enter your Gmail address to sign in:",
            preferredStyle: .alert
        )
        alert.addTextField { tf in
            tf.placeholder = "your.email@gmail.com"
            tf.keyboardType = .emailAddress
            tf.autocapitalizationType = .none
        }
        alert.addAction(UIAlertAction(title: "Sign In", style: .default, handler: { [weak self, weak alert] _ in
            guard let email = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else { return }
            self?.performSocialLoginRequest(email: email)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func performSocialLoginRequest(email: String) {
        guard isNetworkAvailable else {
            offlineOverlayView.isHidden = false
            return
        }

        guard let url = URL(string: AppConfig.API.socialLogin) else { return }

        loginButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        loginButton.isEnabled = false

        let params: [String: String] = [
            "provider": "google",
            "provider_id": "google_\(email)",
            "email": email,
            "device_type": AppConfig.deviceType,
            "mobile_device_id": AppConfig.mobileDeviceId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(AppConfig.apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.loginButton.setTitle("Login  ➔", for: .normal)
                self?.loginButton.isEnabled = true

                if let error = error {
                    self?.showError(message: "Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self?.showError(message: "Invalid response from server.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let message = json["message"] as? String ?? ""

                if status, let dataObj = json["data"] as? [String: Any] {
                    // Save email into saved_google_accounts list so it's always listed for 1-tap login
                    var savedAccounts = UserDefaults.standard.stringArray(forKey: "saved_google_accounts") ?? []
                    if !savedAccounts.contains(email) {
                        savedAccounts.append(email)
                        UserDefaults.standard.set(savedAccounts, forKey: "saved_google_accounts")
                    }

                    let userId = (dataObj["userId"] as? Int) ?? Int("\(dataObj["userId"] ?? 0)") ?? 0
                    self?.openWebDashboard(userId: userId)
                } else {
                    self?.showError(message: message.isEmpty ? "Social login failed." : message)
                }
            }
        }.resume()
    }

    // Standard User ID / Password Login (POST /api/login)
    @objc private func handleLoginTap() {
        view.endEditing(true)
        guard isNetworkAvailable else {
            offlineOverlayView.isHidden = false
            return
        }

        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""

        guard !email.isEmpty else {
            showError(message: "Please enter your User ID")
            return
        }

        guard !password.isEmpty else {
            showError(message: "Please enter your password")
            return
        }

        guard let url = URL(string: AppConfig.API.login) else { return }

        loginButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        loginButton.isEnabled = false
        clearError()

        let params: [String: String] = [
            "email": email,
            "password": password,
            "device_type": AppConfig.deviceType,
            "device_id": AppConfig.deviceId,
            "device_name": "iPhone",
            "mobile_device_id": AppConfig.mobileDeviceId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(AppConfig.apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.loginButton.setTitle("Login  ➔", for: .normal)
                self?.loginButton.isEnabled = true

                if let error = error {
                    self?.showError(message: "Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self?.showError(message: "Invalid response from server.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let message = json["message"] as? String ?? ""

                if status, let dataObj = json["data"] as? [String: Any] {
                    let userId = (dataObj["userId"] as? Int) ?? Int("\(dataObj["userId"] ?? 0)") ?? 0
                    self?.openWebDashboard(userId: userId)
                } else {
                    self?.showError(message: message.isEmpty ? "Invalid credentials. Please try again." : message)
                }
            }
        }.resume()
    }

    private func openWebDashboard(userId: Int) {
        let targetURL = AppConfig.API.supplierAgentURL(userId: userId)
        let webVC = WebViewController(initialURLString: targetURL)
        let nav = UINavigationController(rootViewController: webVC)
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true)
    }

    private func showError(message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func clearError() {
        errorLabel.isHidden = true
    }

    // MARK: - Offline Handling (App Store Guideline 4.2)
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = (path.status == .satisfied)
                if path.status == .satisfied {
                    self?.offlineOverlayView.isHidden = true
                }
            }
        }
        networkMonitor.start(queue: monitorQueue)
    }

    private func setupOfflineView() {
        offlineOverlayView.translatesAutoresizingMaskIntoConstraints = false
        offlineOverlayView.backgroundColor = UIColor(red: 46/255, green: 54/255, blue: 63/255, alpha: 0.96)
        offlineOverlayView.isHidden = true
        view.addSubview(offlineOverlayView)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        offlineOverlayView.addSubview(stack)

        let wifiIcon = UIImageView(image: UIImage(systemName: "wifi.slash"))
        wifiIcon.tintColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
        wifiIcon.contentMode = .scaleAspectFit
        wifiIcon.translatesAutoresizingMaskIntoConstraints = false
        wifiIcon.heightAnchor.constraint(equalToConstant: 60).isActive = true
        wifiIcon.widthAnchor.constraint(equalToConstant: 60).isActive = true
        stack.addArrangedSubview(wifiIcon)

        let offlineTitle = UILabel()
        offlineTitle.text = "You're Offline"
        offlineTitle.textColor = .white
        offlineTitle.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        stack.addArrangedSubview(offlineTitle)

        let offlineMsg = UILabel()
        offlineMsg.text = "Please check your internet connection to use SAT Application features."
        offlineMsg.textColor = UIColor.white.withAlphaComponent(0.8)
        offlineMsg.font = UIFont.systemFont(ofSize: 14)
        offlineMsg.textAlignment = .center
        offlineMsg.numberOfLines = 0
        stack.addArrangedSubview(offlineMsg)

        let helplineBtn = UIButton(type: .system)
        helplineBtn.setTitle("📞  Call Helpline: \(AppConfig.helplineNumber)", for: .normal)
        helplineBtn.setTitleColor(.white, for: .normal)
        helplineBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        helplineBtn.backgroundColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
        helplineBtn.layer.cornerRadius = 8
        helplineBtn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        helplineBtn.addTarget(self, action: #selector(callHelpline), for: .touchUpInside)
        stack.addArrangedSubview(helplineBtn)

        let retryBtn = UIButton(type: .system)
        retryBtn.setTitle("Retry Connection", for: .normal)
        retryBtn.setTitleColor(.white, for: .normal)
        retryBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        retryBtn.backgroundColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        retryBtn.layer.cornerRadius = 8
        retryBtn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24)
        retryBtn.addTarget(self, action: #selector(retryConnection), for: .touchUpInside)
        stack.addArrangedSubview(retryBtn)

        NSLayoutConstraint.activate([
            offlineOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            offlineOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            offlineOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            offlineOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.centerXAnchor.constraint(equalTo: offlineOverlayView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: offlineOverlayView.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: offlineOverlayView.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: offlineOverlayView.trailingAnchor, constant: -32)
        ])
    }

    @objc private func callHelpline() {
        guard let url = URL(string: "tel://\(AppConfig.helplineNumber)") else { return }
        UIApplication.shared.open(url)
    }

    @objc private func showOfflineHelp() {
        let alert = UIAlertController(
            title: "Helpline & Support",
            message: "Helpline: \(AppConfig.helplineNumber)\nSupport Email: \(AppConfig.supportEmail)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { [weak self] _ in
            self?.callHelpline()
        }))
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func retryConnection() {
        if networkMonitor.currentPath.status == .satisfied {
            offlineOverlayView.isHidden = true
        } else {
            showError(message: "Still offline. Please check your connection.")
        }
    }
}
