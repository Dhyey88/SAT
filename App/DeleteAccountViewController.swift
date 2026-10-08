import UIKit

/// Native Account Deletion UIViewController conforming to Apple App Store Review Guideline 5.1.1(v).
/// Provides a 100% native phone screen for users to request permanent account deletion without any web views.
class DeleteAccountViewController: UIViewController, UITextFieldDelegate {

    enum Mode {
        case authenticated
        case unauthenticated
    }

    var onAccountDeletionSuccess: ((String) -> Void)?

    private let mode: Mode
    private var prefilledEmail: String

    // MARK: - UI Containers
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header Elements
    private let headerIconView = UIImageView()
    private let headerTitleLabel = UILabel()
    private let headerSubtitleLabel = UILabel()

    // Status Banner (Error / Notice)
    private let statusBanner = UIView()
    private let statusLabel = UILabel()

    // Central Card
    private let cardView = UIView()

    // Warning / Disclosure Box
    private let warningContainer = UIView()
    private let warningIcon = UIImageView()
    private let warningLabel = UILabel()

    // Email / User ID Input Row
    private let emailIcon = UIImageView()
    private let emailTitleLabel = UILabel()
    private let emailTextField = UITextField()
    private let emailUnderline = UIView()

    // Password Verification Row
    private let passwordIcon = UIImageView()
    private let passwordTitleLabel = UILabel()
    private let passwordTextField = UITextField()
    private let passwordUnderline = UIView()
    private let showPasswordButton = UIButton(type: .system)

    // Optional Reason Row
    private let reasonIcon = UIImageView()
    private let reasonTitleLabel = UILabel()
    private let reasonTextField = UITextField()
    private let reasonUnderline = UIView()

    // Card Bottom Action Bar
    private let cardBottomBar = UIView()
    private let cancelButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .medium)

    // Dynamic Bottom Constraint
    private var contentBottomConstraint: NSLayoutConstraint?

    // MARK: - Initializers
    init(mode: Mode = .unauthenticated, prefilledEmail: String = "") {
        self.mode = mode
        self.prefilledEmail = prefilledEmail
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.mode = .unauthenticated
        self.prefilledEmail = ""
        super.init(coder: coder)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()

        if !prefilledEmail.isEmpty {
            emailTextField.text = prefilledEmail
        } else if let savedEmail = UserDefaults.standard.string(forKey: "sat_saved_user_email"), !savedEmail.isEmpty {
            emailTextField.text = savedEmail
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = AppTheme.canvasBackground

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        // 1. Header Icon (Trash Badge)
        headerIconView.translatesAutoresizingMaskIntoConstraints = false
        headerIconView.image = UIImage(systemName: "trash.circle.fill")
        headerIconView.tintColor = AppTheme.alertRed
        headerIconView.contentMode = .scaleAspectFit
        contentView.addSubview(headerIconView)

        // 2. Header Title Label
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.text = "Delete Account"
        headerTitleLabel.textColor = AppTheme.textPrimaryLight
        headerTitleLabel.font = AppTheme.Typography.titleHeader
        headerTitleLabel.textAlignment = .center
        contentView.addSubview(headerTitleLabel)

        // 3. Header Subtitle Label
        headerSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerSubtitleLabel.text = "Permanent Account Deletion Request"
        headerSubtitleLabel.textColor = UIColor.white.withAlphaComponent(0.65)
        headerSubtitleLabel.font = AppTheme.Typography.captionMedium
        headerSubtitleLabel.textAlignment = .center
        contentView.addSubview(headerSubtitleLabel)

        // 4. Status Banner
        statusBanner.translatesAutoresizingMaskIntoConstraints = false
        statusBanner.backgroundColor = AppTheme.errorRed
        statusBanner.layer.cornerRadius = AppTheme.CornerRadius.small
        statusBanner.layer.masksToBounds = true
        statusBanner.isHidden = true
        contentView.addSubview(statusBanner)

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textColor = .white
        statusLabel.font = AppTheme.Typography.captionMedium
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusBanner.addSubview(statusLabel)

        // 5. Build Central Form Card
        buildFormCard()

        // Dynamic Bottom Constraint
        contentBottomConstraint = contentView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 40)
        contentBottomConstraint?.isActive = true

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
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            headerIconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            headerIconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerIconView.widthAnchor.constraint(equalToConstant: 44),
            headerIconView.heightAnchor.constraint(equalToConstant: 44),

            headerTitleLabel.topAnchor.constraint(equalTo: headerIconView.bottomAnchor, constant: 8),
            headerTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            headerSubtitleLabel.topAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 4),
            headerSubtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            statusBanner.topAnchor.constraint(equalTo: headerSubtitleLabel.bottomAnchor, constant: 14),
            statusBanner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusBanner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            statusLabel.topAnchor.constraint(equalTo: statusBanner.topAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: statusBanner.leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: statusBanner.trailingAnchor, constant: -12),
            statusLabel.bottomAnchor.constraint(equalTo: statusBanner.bottomAnchor, constant: -8),

            cardView.topAnchor.constraint(equalTo: statusBanner.bottomAnchor, constant: 14),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Central Form Card
    private func buildFormCard() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = AppTheme.CornerRadius.large
        cardView.layer.masksToBounds = true
        AppTheme.applyCardElevation(to: cardView, cornerRadius: AppTheme.CornerRadius.large)
        contentView.addSubview(cardView)

        // Warning Box (Apple Guideline 5.1.1(v) Disclosure)
        warningContainer.translatesAutoresizingMaskIntoConstraints = false
        warningContainer.backgroundColor = UIColor(red: 254/255, green: 242/255, blue: 242/255, alpha: 1.0)
        warningContainer.layer.cornerRadius = AppTheme.CornerRadius.medium
        warningContainer.layer.borderWidth = 1.0
        warningContainer.layer.borderColor = UIColor(red: 254/255, green: 202/255, blue: 202/255, alpha: 1.0).cgColor
        cardView.addSubview(warningContainer)

        warningIcon.translatesAutoresizingMaskIntoConstraints = false
        warningIcon.image = UIImage(systemName: "exclamationmark.triangle.fill")
        warningIcon.tintColor = AppTheme.alertRed
        warningIcon.contentMode = .scaleAspectFit
        warningContainer.addSubview(warningIcon)

        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        warningLabel.text = "Submitting this request will flag your account for permanent deletion and deactivate your profile. All associated personal data will be erased."
        warningLabel.textColor = UIColor(red: 153/255, green: 27/255, blue: 27/255, alpha: 1.0)
        warningLabel.font = AppTheme.Typography.captionMedium
        warningLabel.numberOfLines = 0
        warningContainer.addSubview(warningLabel)

        // Email Row
        emailIcon.translatesAutoresizingMaskIntoConstraints = false
        emailIcon.image = UIImage(systemName: "person.crop.circle.fill")
        emailIcon.tintColor = AppTheme.actionGold
        emailIcon.contentMode = .scaleAspectFit
        cardView.addSubview(emailIcon)

        emailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTitleLabel.text = "Account Email / User ID"
        emailTitleLabel.textColor = AppTheme.textPrimaryDark
        emailTitleLabel.font = AppTheme.Typography.titleCard
        cardView.addSubview(emailTitleLabel)

        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.placeholder = "Enter registered email or user ID"
        emailTextField.textColor = AppTheme.textPrimaryDark
        emailTextField.font = AppTheme.Typography.bodyMedium
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.returnKeyType = .next
        emailTextField.delegate = self
        emailTextField.addTarget(self, action: #selector(clearStatusBanner), for: .editingChanged)
        cardView.addSubview(emailTextField)

        emailUnderline.translatesAutoresizingMaskIntoConstraints = false
        emailUnderline.backgroundColor = AppTheme.accentSkyBlue
        cardView.addSubview(emailUnderline)

        // Password Row
        passwordIcon.translatesAutoresizingMaskIntoConstraints = false
        passwordIcon.image = UIImage(systemName: "lock.fill")
        passwordIcon.tintColor = AppTheme.actionGold
        passwordIcon.contentMode = .scaleAspectFit
        cardView.addSubview(passwordIcon)

        passwordTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordTitleLabel.text = "Verify Password"
        passwordTitleLabel.textColor = AppTheme.textPrimaryDark
        passwordTitleLabel.font = AppTheme.Typography.titleCard
        cardView.addSubview(passwordTitleLabel)

        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.placeholder = "Enter password to verify identity"
        passwordTextField.textColor = AppTheme.textPrimaryDark
        passwordTextField.font = AppTheme.Typography.bodyMedium
        passwordTextField.isSecureTextEntry = true
        passwordTextField.returnKeyType = .next
        passwordTextField.delegate = self
        passwordTextField.addTarget(self, action: #selector(clearStatusBanner), for: .editingChanged)
        cardView.addSubview(passwordTextField)

        showPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        showPasswordButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        showPasswordButton.tintColor = AppTheme.textPlaceholder
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        cardView.addSubview(showPasswordButton)

        passwordUnderline.translatesAutoresizingMaskIntoConstraints = false
        passwordUnderline.backgroundColor = AppTheme.accentSkyBlue
        cardView.addSubview(passwordUnderline)

        // Reason Row (Optional)
        reasonIcon.translatesAutoresizingMaskIntoConstraints = false
        reasonIcon.image = UIImage(systemName: "bubble.left.and.bubble.right.fill")
        reasonIcon.tintColor = AppTheme.actionGold
        reasonIcon.contentMode = .scaleAspectFit
        cardView.addSubview(reasonIcon)

        reasonTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        reasonTitleLabel.text = "Reason for Deletion (Optional)"
        reasonTitleLabel.textColor = AppTheme.textPrimaryDark
        reasonTitleLabel.font = AppTheme.Typography.titleCard
        cardView.addSubview(reasonTitleLabel)

        reasonTextField.translatesAutoresizingMaskIntoConstraints = false
        reasonTextField.placeholder = "e.g. No longer needed, switching service..."
        reasonTextField.textColor = AppTheme.textPrimaryDark
        reasonTextField.font = AppTheme.Typography.bodyMedium
        reasonTextField.returnKeyType = .done
        reasonTextField.delegate = self
        reasonTextField.addTarget(self, action: #selector(clearStatusBanner), for: .editingChanged)
        cardView.addSubview(reasonTextField)

        reasonUnderline.translatesAutoresizingMaskIntoConstraints = false
        reasonUnderline.backgroundColor = AppTheme.accentSkyBlue
        cardView.addSubview(reasonUnderline)

        // Bottom Bar
        cardBottomBar.translatesAutoresizingMaskIntoConstraints = false
        cardBottomBar.backgroundColor = AppTheme.cardBottomBar
        cardBottomBar.layer.cornerRadius = AppTheme.CornerRadius.large
        cardBottomBar.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        cardBottomBar.layer.masksToBounds = true
        cardView.addSubview(cardBottomBar)

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(AppTheme.accentSkyBlue, for: .normal)
        cancelButton.titleLabel?.font = AppTheme.Typography.bodyBold
        cancelButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        cardBottomBar.addSubview(cancelButton)

        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle("Delete Account", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.titleLabel?.font = AppTheme.Typography.titleCard
        deleteButton.backgroundColor = AppTheme.alertRed
        deleteButton.layer.cornerRadius = AppTheme.CornerRadius.medium
        AppTheme.applyButtonElevation(to: deleteButton)
        deleteButton.addTarget(self, action: #selector(handleDeleteTapped), for: .touchUpInside)
        cardBottomBar.addSubview(deleteButton)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.color = .white
        cardBottomBar.addSubview(spinner)

        // Constraints within Card
        NSLayoutConstraint.activate([
            warningContainer.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            warningContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            warningContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            warningIcon.leadingAnchor.constraint(equalTo: warningContainer.leadingAnchor, constant: 10),
            warningIcon.topAnchor.constraint(equalTo: warningContainer.topAnchor, constant: 10),
            warningIcon.widthAnchor.constraint(equalToConstant: 20),
            warningIcon.heightAnchor.constraint(equalToConstant: 20),

            warningLabel.leadingAnchor.constraint(equalTo: warningIcon.trailingAnchor, constant: 8),
            warningLabel.trailingAnchor.constraint(equalTo: warningContainer.trailingAnchor, constant: -10),
            warningLabel.topAnchor.constraint(equalTo: warningContainer.topAnchor, constant: 8),
            warningLabel.bottomAnchor.constraint(equalTo: warningContainer.bottomAnchor, constant: -8),

            // Email Row
            emailIcon.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            emailIcon.topAnchor.constraint(equalTo: warningContainer.bottomAnchor, constant: 18),
            emailIcon.widthAnchor.constraint(equalToConstant: 28),
            emailIcon.heightAnchor.constraint(equalToConstant: 28),

            emailTitleLabel.leadingAnchor.constraint(equalTo: emailIcon.trailingAnchor, constant: 12),
            emailTitleLabel.topAnchor.constraint(equalTo: warningContainer.bottomAnchor, constant: 14),

            emailTextField.leadingAnchor.constraint(equalTo: emailIcon.trailingAnchor, constant: 12),
            emailTextField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            emailTextField.topAnchor.constraint(equalTo: emailTitleLabel.bottomAnchor, constant: 4),
            emailTextField.heightAnchor.constraint(equalToConstant: 30),

            emailUnderline.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 2),
            emailUnderline.leadingAnchor.constraint(equalTo: emailIcon.trailingAnchor, constant: 12),
            emailUnderline.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            emailUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            // Password Row
            passwordIcon.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            passwordIcon.topAnchor.constraint(equalTo: emailUnderline.bottomAnchor, constant: 18),
            passwordIcon.widthAnchor.constraint(equalToConstant: 28),
            passwordIcon.heightAnchor.constraint(equalToConstant: 28),

            passwordTitleLabel.leadingAnchor.constraint(equalTo: passwordIcon.trailingAnchor, constant: 12),
            passwordTitleLabel.topAnchor.constraint(equalTo: emailUnderline.bottomAnchor, constant: 14),

            passwordTextField.leadingAnchor.constraint(equalTo: passwordIcon.trailingAnchor, constant: 12),
            passwordTextField.trailingAnchor.constraint(equalTo: showPasswordButton.leadingAnchor, constant: -8),
            passwordTextField.topAnchor.constraint(equalTo: passwordTitleLabel.bottomAnchor, constant: 4),
            passwordTextField.heightAnchor.constraint(equalToConstant: 30),

            showPasswordButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            showPasswordButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor),
            showPasswordButton.widthAnchor.constraint(equalToConstant: 28),
            showPasswordButton.heightAnchor.constraint(equalToConstant: 28),

            passwordUnderline.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 2),
            passwordUnderline.leadingAnchor.constraint(equalTo: passwordIcon.trailingAnchor, constant: 12),
            passwordUnderline.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            passwordUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            // Reason Row
            reasonIcon.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            reasonIcon.topAnchor.constraint(equalTo: passwordUnderline.bottomAnchor, constant: 18),
            reasonIcon.widthAnchor.constraint(equalToConstant: 28),
            reasonIcon.heightAnchor.constraint(equalToConstant: 28),

            reasonTitleLabel.leadingAnchor.constraint(equalTo: reasonIcon.trailingAnchor, constant: 12),
            reasonTitleLabel.topAnchor.constraint(equalTo: passwordUnderline.bottomAnchor, constant: 14),

            reasonTextField.leadingAnchor.constraint(equalTo: reasonIcon.trailingAnchor, constant: 12),
            reasonTextField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            reasonTextField.topAnchor.constraint(equalTo: reasonTitleLabel.bottomAnchor, constant: 4),
            reasonTextField.heightAnchor.constraint(equalToConstant: 30),

            reasonUnderline.topAnchor.constraint(equalTo: reasonTextField.bottomAnchor, constant: 2),
            reasonUnderline.leadingAnchor.constraint(equalTo: reasonIcon.trailingAnchor, constant: 12),
            reasonUnderline.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            reasonUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            // Bottom Bar
            cardBottomBar.topAnchor.constraint(equalTo: reasonUnderline.bottomAnchor, constant: 24),
            cardBottomBar.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            cardBottomBar.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            cardBottomBar.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            cardBottomBar.heightAnchor.constraint(equalToConstant: 58),

            cancelButton.leadingAnchor.constraint(equalTo: cardBottomBar.leadingAnchor, constant: 18),
            cancelButton.centerYAnchor.constraint(equalTo: cardBottomBar.centerYAnchor),

            deleteButton.trailingAnchor.constraint(equalTo: cardBottomBar.trailingAnchor, constant: -18),
            deleteButton.centerYAnchor.constraint(equalTo: cardBottomBar.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 154),
            deleteButton.heightAnchor.constraint(equalToConstant: 40),

            spinner.centerYAnchor.constraint(equalTo: deleteButton.centerYAnchor),
            spinner.trailingAnchor.constraint(equalTo: deleteButton.trailingAnchor, constant: -12)
        ])
    }

    // MARK: - User Actions
    @objc private func handleCancel() {
        dismissKeyboard()
        dismiss(animated: true)
    }

    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.fill" : "eye.slash.fill"
        showPasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @objc private func clearStatusBanner() {
        if !statusBanner.isHidden {
            UIView.animate(withDuration: 0.2, animations: {
                self.statusBanner.alpha = 0
            }) { _ in
                self.statusBanner.isHidden = true
            }
        }
    }

    private func showStatusBanner(message: String, isError: Bool) {
        statusBanner.backgroundColor = isError ? AppTheme.errorRed : AppTheme.successGreen
        statusLabel.text = message
        statusBanner.alpha = 0
        statusBanner.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.statusBanner.alpha = 1.0
        }
    }

    private func setLoading(_ loading: Bool) {
        if loading {
            deleteButton.setTitle("", for: .normal)
            spinner.startAnimating()
            deleteButton.isEnabled = false
            cancelButton.isEnabled = false
            emailTextField.isEnabled = false
            passwordTextField.isEnabled = false
            reasonTextField.isEnabled = false
        } else {
            spinner.stopAnimating()
            deleteButton.setTitle("Delete Account", for: .normal)
            deleteButton.isEnabled = true
            cancelButton.isEnabled = true
            emailTextField.isEnabled = true
            passwordTextField.isEnabled = true
            reasonTextField.isEnabled = true
        }
    }

    // MARK: - Deletion Execution Flow
    @objc private func handleDeleteTapped() {
        dismissKeyboard()

        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""
        let reason = reasonTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Validate Email
        let userValidation = ValidationHelper.isValidUserId(email)
        if !userValidation.isValid {
            AppTheme.triggerNotificationFeedback(.error)
            showStatusBanner(message: userValidation.message ?? "Please enter a valid User ID / Email.", isError: true)
            emailTextField.becomeFirstResponder()
            return
        }

        // Validate Password
        if password.isEmpty {
            AppTheme.triggerNotificationFeedback(.error)
            showStatusBanner(message: "Please enter your password to confirm account ownership.", isError: true)
            passwordTextField.becomeFirstResponder()
            return
        }

        // Native Confirmation Safeguard
        let alert = UIAlertController(
            title: "Confirm Account Deletion",
            message: "Are you sure you want to permanently delete your account (\(email))?\n\nThis will deactivate your account and submit a permanent deletion request to the administrator. This action cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes, Delete Account", style: .destructive, handler: { [weak self] _ in
            self?.executeAccountDeletion(email: email, password: password, reason: reason)
        }))

        present(alert, animated: true)
    }

    private func executeAccountDeletion(email: String, password: String, reason: String) {
        setLoading(true)
        clearStatusBanner()

        // Step 1: Authenticate credentials with login API to verify identity and get access-token
        let loginParams: [String: String] = [
            "email": email,
            "password": password,
            "device_type": AppConfig.deviceType,
            "device_id": AppConfig.deviceId,
            "device_name": AppConfig.deviceName,
            "os_version": AppConfig.osVersion,
            "mobile_device_id": AppConfig.mobileDeviceId
        ]

        APIClient.post(endpoint: AppConfig.API.login, parameters: loginParams) { [weak self] loginResult in
            guard let self = self else { return }

            switch loginResult {
            case .failure(let error):
                self.setLoading(false)
                AppTheme.triggerNotificationFeedback(.error)
                self.showStatusBanner(message: "Connection error: \(error.localizedDescription)", isError: true)

            case .success(let loginJson):
                let loginStatus = loginJson["status"] as? Bool ?? false
                let loginMessage = loginJson["message"] as? String ?? "Invalid credentials. Please try again."

                guard loginStatus, let userToken = loginJson["access-token"] as? String, !userToken.isEmpty else {
                    self.setLoading(false)
                    AppTheme.triggerNotificationFeedback(.error)
                    self.showStatusBanner(message: loginMessage, isError: true)
                    return
                }

                // Step 2: Call edit-userprofile with request_type=delete and is_user_delete_request=1
                var deleteParams: [String: Any] = [
                    "request_type": "delete",
                    "is_user_delete_request": 1
                ]
                if !reason.isEmpty {
                    deleteParams["reason"] = reason
                }

                APIClient.post(
                    endpoint: AppConfig.API.editUserProfile,
                    parameters: deleteParams,
                    customHeaders: ["access-token": userToken]
                ) { [weak self] deleteResult in
                    guard let self = self else { return }
                    self.setLoading(false)

                    switch deleteResult {
                    case .failure(let error):
                        AppTheme.triggerNotificationFeedback(.error)
                        self.showStatusBanner(message: "Failed to submit request: \(error.localizedDescription)", isError: true)

                    case .success(let deleteJson):
                        let deleteStatus = deleteJson["status"] as? Bool ?? false
                        let deleteMessage = deleteJson["message"] as? String ?? "Account delete request sent successfully."

                        if deleteStatus {
                            AppTheme.triggerNotificationFeedback(.success)

                            // Clear active user session
                            SessionManager.shared.clearSession(reason: .userLogout)

                            let successAlert = UIAlertController(
                                title: "Request Submitted",
                                message: "Your account deletion request has been submitted successfully. Your profile has been deactivated and will be permanently removed.",
                                preferredStyle: .alert
                            )
                            successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                                self?.dismiss(animated: true) {
                                    self?.onAccountDeletionSuccess?(deleteMessage)
                                }
                            }))
                            self.present(successAlert, animated: true)
                        } else {
                            AppTheme.triggerNotificationFeedback(.error)
                            self.showStatusBanner(message: deleteMessage, isError: true)
                        }
                    }
                }
            }
        }
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            reasonTextField.becomeFirstResponder()
        } else if textField == reasonTextField {
            dismissKeyboard()
        }
        return true
    }

    // MARK: - Keyboard Handling
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

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
}
