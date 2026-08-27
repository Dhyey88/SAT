import UIKit

class SignUpViewController: UIViewController {

    private let baseURL = "https://test.enin.io"
    private let apiAccessToken = "piggyC@ins2019"

    var onSignUpSuccess: ((String) -> Void)?

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let cardView = UIView()

    private let closeButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let errorLabel = UILabel()

    private let firstNameField = UITextField()
    private let lastNameField = UITextField()
    private let mobileField = UITextField()
    private let emailField = UITextField()
    private let passwordField = UITextField()

    private let submitButton = UIButton(type: .custom)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 30/255, green: 36/255, blue: 43/255, alpha: 0.95)

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

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor(red: 46/255, green: 54/255, blue: 63/255, alpha: 1.0)
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        contentView.addSubview(cardView)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = UIColor.white.withAlphaComponent(0.6)
        closeButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        cardView.addSubview(closeButton)

        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = UIImage(systemName: "person.badge.plus.fill")
        icon.tintColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
        icon.contentMode = .scaleAspectFit
        cardView.addSubview(icon)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "New User Registration"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        cardView.addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Create your account to access SAT services."
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textAlignment = .center
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

        styleField(firstNameField, placeholder: "First Name", icon: "person.fill")
        cardView.addSubview(firstNameField)

        styleField(lastNameField, placeholder: "Last Name", icon: "person.fill")
        cardView.addSubview(lastNameField)

        styleField(mobileField, placeholder: "Mobile Number", icon: "phone.fill")
        mobileField.keyboardType = .phonePad
        cardView.addSubview(mobileField)

        styleField(emailField, placeholder: "Email Address", icon: "envelope.fill")
        emailField.keyboardType = .emailAddress
        cardView.addSubview(emailField)

        styleField(passwordField, placeholder: "Password (Min 6 characters)", icon: "lock.fill")
        passwordField.isSecureTextEntry = true
        cardView.addSubview(passwordField)

        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.backgroundColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        submitButton.setTitle("Create Account", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        submitButton.layer.cornerRadius = 8
        submitButton.addTarget(self, action: #selector(handleRegisterTap), for: .touchUpInside)
        cardView.addSubview(submitButton)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        submitButton.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),

            closeButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            icon.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            icon.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 36),
            icon.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            errorLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            errorLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            firstNameField.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 14),
            firstNameField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            firstNameField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            firstNameField.heightAnchor.constraint(equalToConstant: 46),

            lastNameField.topAnchor.constraint(equalTo: firstNameField.bottomAnchor, constant: 10),
            lastNameField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            lastNameField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            lastNameField.heightAnchor.constraint(equalToConstant: 46),

            mobileField.topAnchor.constraint(equalTo: lastNameField.bottomAnchor, constant: 10),
            mobileField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            mobileField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            mobileField.heightAnchor.constraint(equalToConstant: 46),

            emailField.topAnchor.constraint(equalTo: mobileField.bottomAnchor, constant: 10),
            emailField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            emailField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            emailField.heightAnchor.constraint(equalToConstant: 46),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 10),
            passwordField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            passwordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            passwordField.heightAnchor.constraint(equalToConstant: 46),

            submitButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20),
            submitButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            submitButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            submitButton.heightAnchor.constraint(equalToConstant: 48),
            submitButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),

            activityIndicator.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: submitButton.trailingAnchor, constant: -16)
        ])
    }

    private func styleField(_ tf: UITextField, placeholder: String, icon: String) {
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor(red: 35/255, green: 42/255, blue: 50/255, alpha: 1.0)
        tf.layer.cornerRadius = 8
        tf.textColor = .white
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.4)]
        )

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 46))
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
        iconView.contentMode = .center
        iconView.frame = paddingView.bounds
        paddingView.addSubview(iconView)
        tf.leftView = paddingView
        tf.leftViewMode = .always
    }

    @objc private func handleRegisterTap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        errorLabel.isHidden = true

        let fname = firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lname = lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let mobile = mobileField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField.text ?? ""

        guard !fname.isEmpty else { showError("Please enter your First Name."); return }
        guard !lname.isEmpty else { showError("Please enter your Last Name."); return }
        guard !mobile.isEmpty else { showError("Please enter your Mobile Number."); return }
        guard !email.isEmpty, email.contains("@") else { showError("Please enter a valid Email."); return }
        guard password.count >= 6 else { showError("Password must be at least 6 characters."); return }

        startLoading()

        guard let url = URL(string: "\(baseURL)/api/register") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let params: [String: String] = [
            "fname": fname,
            "lname": lname,
            "mobile": mobile,
            "email": email,
            "password": password,
            "device_type": "1", // iOS
            "device_id": "SAT_IOS_DEVICE",
            "mobile_device_id": "SAT_IOS_DEVICE"
        ]

        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
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
                        title: "Registration Successful",
                        message: "Your account has been registered successfully. You can now log in.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Log In Now", style: .default, handler: { _ in
                        self?.dismiss(animated: true) {
                            self?.onSignUpSuccess?(email)
                        }
                    }))
                    self?.present(alert, animated: true)
                } else {
                    self?.showError(message.isEmpty ? "Registration failed. Please check inputs." : message)
                }
            }
        }.resume()
    }

    private func startLoading() {
        submitButton.isEnabled = false
        submitButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
    }

    private func stopLoading() {
        submitButton.isEnabled = true
        submitButton.setTitle("Create Account", for: .normal)
        activityIndicator.stopAnimating()
    }

    private func showError(_ msg: String) {
        errorLabel.text = "  \(msg)  "
        errorLabel.isHidden = false
    }

    @objc private func dismissModal() {
        dismiss(animated: true)
    }

    // MARK: - Keyboard Handling
    private func setupKeyboardHandling() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        let toolbar = createKeyboardToolbar()
        firstNameField.inputAccessoryView = toolbar
        lastNameField.inputAccessoryView = toolbar
        mobileField.inputAccessoryView = toolbar
        emailField.inputAccessoryView = toolbar
        passwordField.inputAccessoryView = toolbar
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

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight + 20
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight + 20
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
}
