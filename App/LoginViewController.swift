import UIKit
import Network
import SafariServices

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header Elements
    private let welcomeLabel = UILabel()
    private let avatarContainer = UIView()
    private let avatarImageView = UIImageView()

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

    // MARK: - Offline View (App Store Guideline 4.2 Compliant)
    private let offlineOverlayView = UIView()
    private let networkMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitorQueue")
    private var isNetworkAvailable = true

    // MARK: - API Constants
    private let baseURL = "https://test.enin.io"
    private let apiAccessToken = "piggyC@ins2019"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
        setupNetworkMonitoring()
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

        // 2. Avatar Placeholder
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false
        avatarContainer.backgroundColor = UIColor(red: 38/255, green: 45/255, blue: 53/255, alpha: 1.0)
        avatarContainer.layer.cornerRadius = 35
        avatarContainer.layer.masksToBounds = true
        avatarContainer.layer.borderWidth = 2
        avatarContainer.layer.borderColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 0.8).cgColor
        contentView.addSubview(avatarContainer)

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.image = UIImage(systemName: "person.fill")
        avatarImageView.tintColor = UIColor.white.withAlphaComponent(0.85)
        avatarImageView.contentMode = .scaleAspectFit
        avatarContainer.addSubview(avatarImageView)

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

            avatarContainer.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 14),
            avatarContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 70),
            avatarContainer.heightAnchor.constraint(equalToConstant: 70),

            avatarImageView.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),

            googleLoginButton.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 18),
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

        // Action Links: Tutorial & Reset Password
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
        actionLinksStack.distribution = .equalSpacing
        actionLinksStack.alignment = .center

        // Tutorial Button (Web Sky Blue #27A9E3)
        tutorialButton.translatesAutoresizingMaskIntoConstraints = false
        tutorialButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        tutorialButton.tintColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
        tutorialButton.setTitle(" Tutorial", for: .normal)
        tutorialButton.setTitleColor(UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0), for: .normal)
        tutorialButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        tutorialButton.addTarget(self, action: #selector(openTutorial), for: .touchUpInside)
        actionLinksStack.addArrangedSubview(tutorialButton)

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
        privacyPolicyButton.addTarget(self, action: #selector(openPrivacyPolicy), for: .touchUpInside)
        leftLinks.addArrangedSubview(privacyPolicyButton)

        footerDividerLabel.text = "|"
        footerDividerLabel.textColor = UIColor.white.withAlphaComponent(0.4)
        footerDividerLabel.font = UIFont.systemFont(ofSize: 13)
        leftLinks.addArrangedSubview(footerDividerLabel)

        contactButton.setTitle("Contact", for: .normal)
        contactButton.setTitleColor(UIColor.white.withAlphaComponent(0.65), for: .normal)
        contactButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        contactButton.addTarget(self, action: #selector(showOfflineHelp), for: .touchUpInside)
        leftLinks.addArrangedSubview(contactButton)

        footerStack.addArrangedSubview(leftLinks)

        // Version Label
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        versionLabel.text = "v \(version)"
        versionLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        versionLabel.font = UIFont.systemFont(ofSize: 13)
        footerStack.addArrangedSubview(versionLabel)
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
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard let url = URL(string: "https://test.enin.io/tutorial") else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }

    @objc private func openResetPasswordModal() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let resetVC = ResetPasswordViewController()
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
        signUpVC.modalPresentationStyle = .formSheet
        present(signUpVC, animated: true)
    }

    @objc private func openInfoModal() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let alert = UIAlertController(
            title: "About SAT",
            message: "SAT Application provides comprehensive trust accounting, branch billing, and donation management services.\n\nVersion: 1.0.0\nSupport: support@enin.io\nHelpline: +91 98765 43210",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func openPrivacyPolicy() {
        guard let url = URL(string: "https://test.enin.io/privacy-policy") else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }

    // MARK: - Google Account Chooser & Social Login
    @objc private func handleGoogleLogin() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        let chooserVC = GoogleAccountChooserViewController()
        chooserVC.modalPresentationStyle = .overFullScreen
        chooserVC.modalTransitionStyle = .crossDissolve
        chooserVC.onAccountSelected = { [weak self] selectedEmail in
            self?.performSocialLoginRequest(email: selectedEmail)
        }
        present(chooserVC, animated: true)
    }

    private func performSocialLoginRequest(email: String) {
        guard isNetworkAvailable else {
            offlineOverlayView.isHidden = false
            return
        }

        guard let url = URL(string: "\(baseURL)/api/social-login") else { return }

        loginButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        loginButton.isEnabled = false

        let params: [String: String] = [
            "provider": "google",
            "provider_id": "google_\(email)",
            "email": email,
            "device_type": "1", // iOS
            "mobile_device_id": "SAT_IOS_DEVICE"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiAccessToken, forHTTPHeaderField: "access-token")
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
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

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

        errorLabel.isHidden = true
        loginButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        loginButton.isEnabled = false

        let bodyParams: [String: String] = [
            "email": email,
            "password": password,
            "device_type": "1", // 1 for iOS
            "device_id": "SAT_IOS_DEVICE",
            "mobile_device_id": "SAT_IOS_DEVICE",
            "login_by": "ho_user"
        ]

        performLoginRequest(params: bodyParams, userEmail: email)
    }

    private func performLoginRequest(params: [String: String], userEmail: String) {
        guard let url = URL(string: "\(baseURL)/api/login") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiAccessToken, forHTTPHeaderField: "access-token")

        let bodyString = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.loginButton.setTitle("Login  ➔", for: .normal)
                self?.loginButton.isEnabled = true

                if let error = error {
                    self?.showError(message: "Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    self?.showError(message: "Invalid response from server.")
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let status = json["status"] as? Bool ?? false
                        let message = json["message"] as? String ?? ""

                        if status, let dataObj = json["data"] as? [String: Any] {
                            let userId = (dataObj["userId"] as? Int) ?? Int("\(dataObj["userId"] ?? 0)") ?? 0
                            let requiredOtp = dataObj["required_otp"] as? Int ?? 0

                            if requiredOtp == 1 || message.lowercased().contains("otp") {
                                self?.promptForOTP(userId: userId, email: userEmail)
                            } else {
                                self?.openWebDashboard(userId: userId)
                            }
                        } else {
                            self?.showError(message: message.isEmpty ? "Invalid credentials." : message)
                        }
                    }
                } catch {
                    self?.showError(message: "Error processing response.")
                }
            }
        }.resume()
    }

    private func promptForOTP(userId: Int, email: String) {
        let alert = UIAlertController(title: "Enter Verification Code",
                                      message: "An OTP has been sent to your registered mobile/email.",
                                      preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "4-digit OTP"
            tf.keyboardType = .numberPad
        }

        let verifyAction = UIAlertAction(title: "Verify", style: .default) { [weak self, weak alert] _ in
            guard let otp = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !otp.isEmpty else { return }
            self?.verifyOTP(userId: userId, email: email, otp: otp)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(verifyAction)
        present(alert, animated: true)
    }

    private func verifyOTP(userId: Int, email: String, otp: String) {
        guard let url = URL(string: "\(baseURL)/api/otp-verify") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiAccessToken, forHTTPHeaderField: "access-token")

        let params = ["otp": otp, "email": email, "device_type": "1", "device_id": "SAT_IOS_DEVICE"]
        let bodyString = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let status = json["status"] as? Bool, status {
                    self?.openWebDashboard(userId: userId)
                } else {
                    self?.showError(message: "Invalid OTP code.")
                }
            }
        }.resume()
    }

    private func openWebDashboard(userId: Int) {
        let targetURL = "\(baseURL)/app-supplier-agent?user_id=\(userId)"
        let webVC = WebViewController(initialURLString: targetURL)
        webVC.modalPresentationStyle = .fullScreen
        present(webVC, animated: true)
    }

    private func showError(message: String) {
        errorLabel.text = "  \(message)  "
        errorLabel.isHidden = false
    }

    // MARK: - Native Offline Screen (App Store Guideline 4.2 Compliant)
    private func setupOfflineView() {
        offlineOverlayView.translatesAutoresizingMaskIntoConstraints = false
        offlineOverlayView.backgroundColor = UIColor(red: 30/255, green: 36/255, blue: 43/255, alpha: 1.0)
        offlineOverlayView.isHidden = true
        view.addSubview(offlineOverlayView)

        NSLayoutConstraint.activate([
            offlineOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            offlineOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            offlineOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            offlineOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = UIColor(red: 46/255, green: 54/255, blue: 63/255, alpha: 1.0)
        iconContainer.layer.cornerRadius = 45
        offlineOverlayView.addSubview(iconContainer)

        let wifiIcon = UIImageView()
        wifiIcon.translatesAutoresizingMaskIntoConstraints = false
        wifiIcon.image = UIImage(systemName: "wifi.slash")
        wifiIcon.tintColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
        wifiIcon.contentMode = .scaleAspectFit
        iconContainer.addSubview(wifiIcon)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "No Internet Connection"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .center
        offlineOverlayView.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Please connect to Wi-Fi or Mobile Data to use SAT."
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        subtitleLabel.font = UIFont.systemFont(ofSize: 15)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        offlineOverlayView.addSubview(subtitleLabel)

        let retryButton = UIButton(type: .system)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle("Try Again", for: .normal)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        retryButton.tintColor = .white
        retryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        retryButton.backgroundColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        retryButton.layer.cornerRadius = 6
        retryButton.addTarget(self, action: #selector(retryConnection), for: .touchUpInside)
        offlineOverlayView.addSubview(retryButton)

        let helpButton = UIButton(type: .system)
        helpButton.translatesAutoresizingMaskIntoConstraints = false
        helpButton.setTitle("Need Help? View Offline Support", for: .normal)
        helpButton.setTitleColor(UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0), for: .normal)
        helpButton.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        helpButton.tintColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
        helpButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        helpButton.addTarget(self, action: #selector(showOfflineHelp), for: .touchUpInside)
        offlineOverlayView.addSubview(helpButton)

        NSLayoutConstraint.activate([
            iconContainer.centerXAnchor.constraint(equalTo: offlineOverlayView.centerXAnchor),
            iconContainer.centerYAnchor.constraint(equalTo: offlineOverlayView.centerYAnchor, constant: -90),
            iconContainer.widthAnchor.constraint(equalToConstant: 90),
            iconContainer.heightAnchor.constraint(equalToConstant: 90),

            wifiIcon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            wifiIcon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            wifiIcon.widthAnchor.constraint(equalToConstant: 48),
            wifiIcon.heightAnchor.constraint(equalToConstant: 48),

            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: offlineOverlayView.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: offlineOverlayView.trailingAnchor, constant: -32),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: offlineOverlayView.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: offlineOverlayView.trailingAnchor, constant: -32),

            retryButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            retryButton.centerXAnchor.constraint(equalTo: offlineOverlayView.centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 160),
            retryButton.heightAnchor.constraint(equalToConstant: 48),

            helpButton.topAnchor.constraint(equalTo: retryButton.bottomAnchor, constant: 20),
            helpButton.centerXAnchor.constraint(equalTo: offlineOverlayView.centerXAnchor)
        ])
    }

    @objc private func showOfflineHelp() {
        let alert = UIAlertController(
            title: "SAT Support & Assistance",
            message: "You can contact support directly via telephone or email.\n\n• Helpline: +91 98765 43210\n• Email: support@enin.io\n• Head Office: Ahmedabad, Gujarat",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Call Helpline", style: .default, handler: { _ in
            if let url = URL(string: "tel:+919876543210"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "Send Support Email", style: .default, handler: { _ in
            if let url = URL(string: "mailto:support@enin.io"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }

    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let isConnected = path.status == .satisfied
                self?.isNetworkAvailable = isConnected
                self?.offlineOverlayView.isHidden = isConnected
            }
        }
        networkMonitor.start(queue: monitorQueue)
    }

    @objc private func retryConnection() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        if networkMonitor.currentPath.status == .satisfied {
            offlineOverlayView.isHidden = true
        } else {
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.duration = 0.4
            animation.values = [-10.0, 10.0, -8.0, 8.0, -5.0, 5.0, 0.0]
            offlineOverlayView.layer.add(animation, forKey: "shake")
        }
    }
}
