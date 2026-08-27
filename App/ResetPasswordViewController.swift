import UIKit

class ResetPasswordViewController: UIViewController {

    // MARK: - State
    private enum Step {
        case enterEmail
        case verifyOTP
        case setNewPassword
    }

    private var currentStep: Step = .enterEmail
    private var userEmail: String = ""
    private var verifiedOTP: String = ""

    private let baseURL = "https://test.enin.io"
    private let apiAccessToken = "piggyC@ins2019"

    // MARK: - UI Components
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let errorLabel = UILabel()

    // Step 1: Email
    private let emailField = UITextField()

    // Step 2: OTP
    private let otpField = UITextField()

    // Step 3: Password
    private let newPasswordField = UITextField()
    private let confirmPasswordField = UITextField()

    private let actionButton = UIButton(type: .custom)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let closeButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStepUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 30/255, green: 36/255, blue: 43/255, alpha: 0.95)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor(red: 46/255, green: 54/255, blue: 63/255, alpha: 1.0)
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        view.addSubview(cardView)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = UIColor.white.withAlphaComponent(0.6)
        closeButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        cardView.addSubview(closeButton)

        let keyIcon = UIImageView()
        keyIcon.translatesAutoresizingMaskIntoConstraints = false
        keyIcon.image = UIImage(systemName: "key.fill")
        keyIcon.tintColor = UIColor(red: 233/255, green: 50/255, blue: 45/255, alpha: 1.0)
        keyIcon.contentMode = .scaleAspectFit
        cardView.addSubview(keyIcon)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Reset Password"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        cardView.addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        cardView.addSubview(subtitleLabel)

        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.backgroundColor = UIColor(red: 185/255, green: 74/255, blue: 72/255, alpha: 1.0)
        errorLabel.textColor = .white
        errorLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.layer.cornerRadius = 4
        errorLabel.layer.masksToBounds = true
        errorLabel.isHidden = true
        cardView.addSubview(errorLabel)

        // Setup text fields
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        let toolbar = createKeyboardToolbar()

        styleTextField(emailField, placeholder: "Enter registered email", iconName: "envelope.fill")
        emailField.keyboardType = .emailAddress
        emailField.inputAccessoryView = toolbar
        cardView.addSubview(emailField)

        styleTextField(otpField, placeholder: "Enter 6-digit OTP", iconName: "number")
        otpField.keyboardType = .numberPad
        otpField.inputAccessoryView = toolbar
        cardView.addSubview(otpField)

        styleTextField(newPasswordField, placeholder: "New Password", iconName: "lock.fill")
        newPasswordField.isSecureTextEntry = true
        newPasswordField.inputAccessoryView = toolbar
        cardView.addSubview(newPasswordField)

        styleTextField(confirmPasswordField, placeholder: "Confirm New Password", iconName: "lock.shield.fill")
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.inputAccessoryView = toolbar
        cardView.addSubview(confirmPasswordField)

        // Action Button
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.backgroundColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        actionButton.layer.cornerRadius = 8
        actionButton.addTarget(self, action: #selector(handleActionTap), for: .touchUpInside)
        cardView.addSubview(actionButton)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        actionButton.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            closeButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            keyIcon.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 28),
            keyIcon.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            keyIcon.widthAnchor.constraint(equalToConstant: 36),
            keyIcon.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.topAnchor.constraint(equalTo: keyIcon.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            errorLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 14),
            errorLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            emailField.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            emailField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            emailField.heightAnchor.constraint(equalToConstant: 48),

            otpField.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            otpField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            otpField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            otpField.heightAnchor.constraint(equalToConstant: 48),

            newPasswordField.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            newPasswordField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            newPasswordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            newPasswordField.heightAnchor.constraint(equalToConstant: 48),

            confirmPasswordField.topAnchor.constraint(equalTo: newPasswordField.bottomAnchor, constant: 12),
            confirmPasswordField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            confirmPasswordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: 48),

            actionButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            actionButton.heightAnchor.constraint(equalToConstant: 48),
            actionButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),

            activityIndicator.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: actionButton.trailingAnchor, constant: -16)
        ])
    }

    private func styleTextField(_ tf: UITextField, placeholder: String, iconName: String) {
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor(red: 35/255, green: 42/255, blue: 50/255, alpha: 1.0)
        tf.layer.cornerRadius = 8
        tf.textColor = .white
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.4)]
        )

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 48))
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
        iconView.contentMode = .center
        iconView.frame = paddingView.bounds
        paddingView.addSubview(iconView)
        tf.leftView = paddingView
        tf.leftViewMode = .always
    }

    private func updateStepUI() {
        errorLabel.isHidden = true
        view.endEditing(true)

        switch currentStep {
        case .enterEmail:
            subtitleLabel.text = "Enter your registered email to receive a 6-digit OTP verification code."
            emailField.isHidden = false
            otpField.isHidden = true
            newPasswordField.isHidden = true
            confirmPasswordField.isHidden = true
            actionButton.setTitle("Send OTP", for: .normal)
            actionButton.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20).isActive = true

        case .verifyOTP:
            subtitleLabel.text = "Enter the 6-digit verification code sent to:\n\(userEmail)"
            emailField.isHidden = true
            otpField.isHidden = false
            newPasswordField.isHidden = true
            confirmPasswordField.isHidden = true
            actionButton.setTitle("Verify OTP", for: .normal)
            actionButton.topAnchor.constraint(equalTo: otpField.bottomAnchor, constant: 20).isActive = true

        case .setNewPassword:
            subtitleLabel.text = "Create a strong new password for your account."
            emailField.isHidden = true
            otpField.isHidden = true
            newPasswordField.isHidden = false
            confirmPasswordField.isHidden = false
            actionButton.setTitle("Update Password", for: .normal)
            actionButton.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 20).isActive = true
        }
    }

    @objc private func handleActionTap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        errorLabel.isHidden = true

        switch currentStep {
        case .enterEmail:
            let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !email.isEmpty, email.contains("@") else {
                showError("Please enter a valid email address.")
                return
            }
            userEmail = email
            sendForgotPasswordOTP(email: email)

        case .verifyOTP:
            let otp = otpField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !otp.isEmpty, otp.count >= 4 else {
                showError("Please enter the verification OTP code.")
                return
            }
            verifiedOTP = otp
            verifyResetOTP(email: userEmail, otp: otp)

        case .setNewPassword:
            let newPass = newPasswordField.text ?? ""
            let confirmPass = confirmPasswordField.text ?? ""
            guard !newPass.isEmpty else {
                showError("Please enter your new password.")
                return
            }
            guard newPass.count >= 6 else {
                showError("Password must be at least 6 characters long.")
                return
            }
            guard newPass == confirmPass else {
                showError("Passwords do not match.")
                return
            }
            submitNewPassword(email: userEmail, otp: verifiedOTP, password: newPass)
        }
    }

    // Step 1: POST /api/forgot-password
    private func sendForgotPasswordOTP(email: String) {
        startLoading()
        guard let url = URL(string: "\(baseURL)/api/forgot-password") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "email=\(email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.stopLoading()
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
                    self?.currentStep = .verifyOTP
                    self?.updateStepUI()
                } else {
                    self?.showError(message.isEmpty ? "Email not registered." : message)
                }
            }
        }.resume()
    }

    // Step 2: POST /api/otp-verification
    private func verifyResetOTP(email: String, otp: String) {
        startLoading()
        guard let url = URL(string: "\(baseURL)/api/otp-verification") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "email=\(email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&forgot_otp=\(otp)"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.stopLoading()
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
                    self?.currentStep = .setNewPassword
                    self?.updateStepUI()
                } else {
                    self?.showError(message.isEmpty ? "Invalid OTP code." : message)
                }
            }
        }.resume()
    }

    // Step 3: POST /api/resent-password
    private func submitNewPassword(email: String, otp: String, password: String) {
        startLoading()
        guard let url = URL(string: "\(baseURL)/api/resent-password") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "email=\(email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&forgot_otp=\(otp)&password=\(password.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.stopLoading()
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
                        title: "Password Updated",
                        message: "Your password has been reset successfully. Please log in with your new password.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self?.dismiss(animated: true)
                    }))
                    self?.present(alert, animated: true)
                } else {
                    self?.showError(message.isEmpty ? "Failed to update password." : message)
                }
            }
        }.resume()
    }

    private func startLoading() {
        actionButton.isEnabled = false
        actionButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
    }

    private func stopLoading() {
        actionButton.isEnabled = true
        activityIndicator.stopAnimating()
        switch currentStep {
        case .enterEmail: actionButton.setTitle("Send OTP", for: .normal)
        case .verifyOTP: actionButton.setTitle("Verify OTP", for: .normal)
        case .setNewPassword: actionButton.setTitle("Update Password", for: .normal)
        }
    }

    private func showError(_ message: String) {
        errorLabel.text = "  \(message)  "
        errorLabel.isHidden = false
    }

    @objc private func dismissModal() {
        dismiss(animated: true)
    }

    private func createKeyboardToolbar() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        toolbar.barStyle = .black
        toolbar.isTranslucent = true
        toolbar.tintColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        toolbar.sizeToFit()
        return toolbar
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
