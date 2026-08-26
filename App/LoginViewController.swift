import UIKit
import Network

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let logoImageView = UIImageView()
    private let roleSegmentedControl = UISegmentedControl(items: ["HO User", "Branch Incharge", "Rahbar"])
    
    private let emailContainer = UIView()
    private let emailBadge = UIImageView()
    private let emailTextField = UITextField()

    private let passwordContainer = UIView()
    private let passwordBadge = UIImageView()
    private let passwordTextField = UITextField()
    private let showPasswordButton = UIButton(type: .system)

    private let errorLabel = UILabel()
    private let loginButton = UIButton(type: .custom)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Offline View
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
        setupNetworkMonitoring()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 46/255, green: 54/255, blue: 63/255, alpha: 1.0)

        // ScrollView setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
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

        // Logo
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        if let logoImage = UIImage(named: "logo") {
            logoImageView.image = logoImage
        } else {
            logoImageView.image = UIImage(systemName: "building.columns.fill")
            logoImageView.tintColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
        }
        contentView.addSubview(logoImageView)

        // Error Banner
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.backgroundColor = UIColor(red: 185/255, green: 74/255, blue: 72/255, alpha: 1.0)
        errorLabel.textColor = .white
        errorLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.layer.cornerRadius = 4
        errorLabel.layer.masksToBounds = true
        errorLabel.isHidden = true
        contentView.addSubview(errorLabel)

        // Role Selector
        roleSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        roleSegmentedControl.selectedSegmentIndex = 0
        roleSegmentedControl.backgroundColor = UIColor(red: 55/255, green: 64/255, blue: 74/255, alpha: 1.0)
        roleSegmentedControl.selectedSegmentTintColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
        roleSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        roleSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.7)], for: .normal)
        roleSegmentedControl.addTarget(self, action: #selector(roleChanged), for: .valueChanged)
        contentView.addSubview(roleSegmentedControl)

        // Email / Branch Code Input Container
        setupInputContainer(container: emailContainer, badge: emailBadge, textField: emailTextField,
                            badgeColor: UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0),
                            iconName: "envelope.fill", placeholder: "Email address")
        contentView.addSubview(emailContainer)

        // Password / Mobile Input Container
        setupInputContainer(container: passwordContainer, badge: passwordBadge, textField: passwordTextField,
                            badgeColor: UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0),
                            iconName: "lock.fill", placeholder: "Password")
        passwordTextField.isSecureTextEntry = true
        contentView.addSubview(passwordContainer)

        // Show Password Button
        showPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        showPasswordButton.setTitle("Show password", for: .normal)
        showPasswordButton.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .normal)
        showPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        showPasswordButton.setImage(UIImage(systemName: "square"), for: .normal)
        showPasswordButton.tintColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
        showPasswordButton.addTarget(self, action: #selector(toggleShowPassword), for: .touchUpInside)
        contentView.addSubview(showPasswordButton)

        // Login Button
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        loginButton.backgroundColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        loginButton.layer.cornerRadius = 4
        loginButton.addTarget(self, action: #selector(handleLoginTap), for: .touchUpInside)
        contentView.addSubview(loginButton)

        // Spinner
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        loginButton.addSubview(activityIndicator)

        // Layout Constraints
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            logoImageView.widthAnchor.constraint(equalToConstant: 220),

            errorLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            roleSegmentedControl.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            roleSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            roleSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            roleSegmentedControl.heightAnchor.constraint(equalToConstant: 38),

            emailContainer.topAnchor.constraint(equalTo: roleSegmentedControl.bottomAnchor, constant: 16),
            emailContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emailContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            emailContainer.heightAnchor.constraint(equalToConstant: 48),

            passwordContainer.topAnchor.constraint(equalTo: emailContainer.bottomAnchor, constant: 14),
            passwordContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            passwordContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            passwordContainer.heightAnchor.constraint(equalToConstant: 48),

            showPasswordButton.topAnchor.constraint(equalTo: passwordContainer.bottomAnchor, constant: 8),
            showPasswordButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            loginButton.topAnchor.constraint(equalTo: showPasswordButton.bottomAnchor, constant: 16),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),

            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor, constant: -16)
        ])

        setupOfflineView()
    }

    private func setupInputContainer(container: UIView, badge: UIImageView, textField: UITextField,
                                     badgeColor: UIColor, iconName: String, placeholder: String) {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 35/255, green: 42/255, blue: 50/255, alpha: 1.0)
        container.layer.cornerRadius = 4
        container.layer.masksToBounds = true

        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.backgroundColor = badgeColor
        badge.image = UIImage(systemName: iconName)
        badge.tintColor = .white
        badge.contentMode = .center
        container.addSubview(badge)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = .white
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.4)]
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

    // MARK: - Native Offline Screen (App Store Guideline 4.2 Compliant)
    private func setupOfflineView() {
        offlineOverlayView.translatesAutoresizingMaskIntoConstraints = false
        offlineOverlayView.backgroundColor = UIColor(red: 46/255, green: 54/255, blue: 63/255, alpha: 1.0)
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
        iconContainer.backgroundColor = UIColor(red: 55/255, green: 64/255, blue: 74/255, alpha: 1.0)
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
        subtitleLabel.text = "Please connect to Wi-Fi or Mobile Data to use SAT App."
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

        NSLayoutConstraint.activate([
            iconContainer.centerXAnchor.constraint(equalTo: offlineOverlayView.centerXAnchor),
            iconContainer.centerYAnchor.constraint(equalTo: offlineOverlayView.centerYAnchor, constant: -80),
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
            retryButton.heightAnchor.constraint(equalToConstant: 48)
        ])
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
        if networkMonitor.currentPath.status == .satisfied {
            offlineOverlayView.isHidden = true
        } else {
            // Jiggle animation to show still offline
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.duration = 0.4
            animation.values = [-10.0, 10.0, -8.0, 8.0, -5.0, 5.0, 0.0]
            offlineOverlayView.layer.add(animation, forKey: "shake")
        }
    }

    // MARK: - Actions
    @objc private func roleChanged() {
        let isHO = roleSegmentedControl.selectedSegmentIndex == 0
        emailTextField.text = ""
        passwordTextField.text = ""
        errorLabel.isHidden = true

        if isHO {
            emailTextField.placeholder = "Email address"
            passwordTextField.placeholder = "Password"
            passwordTextField.isSecureTextEntry = showPasswordButton.isSelected ? false : true
            showPasswordButton.isHidden = false
        } else {
            emailTextField.placeholder = "Branch Code"
            passwordTextField.placeholder = "Mobile Number"
            passwordTextField.isSecureTextEntry = false
            showPasswordButton.isHidden = true
        }
    }

    @objc private func toggleShowPassword() {
        showPasswordButton.isSelected.toggle()
        passwordTextField.isSecureTextEntry = !showPasswordButton.isSelected
        let icon = showPasswordButton.isSelected ? "checkmark.square.fill" : "square"
        showPasswordButton.setImage(UIImage(systemName: icon), for: .normal)
    }

    @objc private func handleLoginTap() {
        view.endEditing(true)
        guard isNetworkAvailable else {
            offlineOverlayView.isHidden = false
            return
        }

        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""

        guard !email.isEmpty else {
            showError(message: roleSegmentedControl.selectedSegmentIndex == 0 ? "Please enter your email" : "Branch Code is required")
            return
        }

        guard !password.isEmpty else {
            showError(message: roleSegmentedControl.selectedSegmentIndex == 0 ? "Please enter your password" : "Mobile number is required")
            return
        }

        errorLabel.isHidden = true
        loginButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        loginButton.isEnabled = false

        let loginByValue = roleSegmentedControl.selectedSegmentIndex == 0 ? "ho_user" :
                          (roleSegmentedControl.selectedSegmentIndex == 1 ? "branch-incharge" : "rahbar")

        var bodyParams: [String: String] = [
            "email": email,
            "password": password,
            "device_type": "1", // 1 for iOS
            "device_id": "SAT_IOS_DEVICE",
            "mobile_device_id": "SAT_IOS_DEVICE",
            "login_by": loginByValue
        ]

        if loginByValue != "ho_user" {
            bodyParams["asharm_id"] = email
        }

        performLoginRequest(params: bodyParams, userEmail: email)
    }

    private func performLoginRequest(params: [String: String], userEmail: String) {
        guard let url = URL(string: "\(baseURL)/api/login") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiAccessToken, forHTTPHeaderField: "access-token")

        // Build URL encoded form body
        let bodyString = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.loginButton.setTitle("Login", for: .normal)
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
}
