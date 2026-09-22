import UIKit

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {

    var onResetPasswordSuccess: ((String) -> Void)?

    // MARK: - State Tracking
    private var userEmail: String = ""
    private var verifiedOTP: String = ""

    // MARK: - Main UI Containers
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let headerTitleLabel = UILabel()
    private let errorBanner = UIView()
    private let errorLabel = UILabel()

    // Dynamic Content View Bottom Constraint
    private var contentBottomConstraint: NSLayoutConstraint?

    // MARK: - Step 1 Card: Email Entry (Screenshot 1)
    private let step1Card = UIView()
    private let s1AvatarIcon = UIImageView()
    private let s1TitleLabel = UILabel()
    private let s1EmailField = UITextField()
    private let s1Underline = UIView()
    private let s1BottomBar = UIView()
    private let s1CancelButton = UIButton(type: .system)
    private let s1NextButton = UIButton(type: .system)
    private let s1Spinner = UIActivityIndicatorView(style: .medium)

    // MARK: - Step 2 Card: 6-Box OTP (Screenshot 2)
    private let step2Card = UIView()
    private let s2LockIcon = UIImageView()
    private var s2OtpBoxes: [UITextField] = []
    private let s2OtpStack = UIStackView()
    private let s2BottomBar = UIView()
    private let s2CancelButton = UIButton(type: .system)
    private let s2NextButton = UIButton(type: .system)
    private let s2Spinner = UIActivityIndicatorView(style: .medium)

    // MARK: - Step 3 Card: Password Entry (Screenshot 3)
    private let step3Card = UIView()

    // Password Row
    private let s3LockIcon1 = UIImageView()
    private let s3PasswordField = UITextField()
    private let s3PasswordUnderline = UIView()
    private let s3ShowPasswordButton1 = UIButton(type: .system)

    // Confirm Password Row
    private let s3LockIcon2 = UIImageView()
    private let s3ConfirmPasswordField = UITextField()
    private let s3ConfirmPasswordUnderline = UIView()
    private let s3ShowPasswordButton2 = UIButton(type: .system)

    // Step 3 Bottom Bar
    private let s3BottomBar = UIView()
    private let s3CancelButton = UIButton(type: .system)
    private let s3NextButton = UIButton(type: .system)
    private let s3Spinner = UIActivityIndicatorView(style: .medium)

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

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = AppTheme.canvasBackground

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // Header Title Label (Changes per step: "Forgot Password?", "Enter OTP", "Enter Password")
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.text = "Forgot Password?"
        headerTitleLabel.textColor = AppTheme.textPrimaryLight
        headerTitleLabel.font = AppTheme.Typography.titleHeader
        headerTitleLabel.textAlignment = .center
        contentView.addSubview(headerTitleLabel)

        // Error Banner
        errorBanner.translatesAutoresizingMaskIntoConstraints = false
        errorBanner.backgroundColor = AppTheme.errorRed
        errorBanner.layer.cornerRadius = AppTheme.CornerRadius.small
        errorBanner.layer.masksToBounds = true
        errorBanner.isHidden = true
        contentView.addSubview(errorBanner)

        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textColor = .white
        errorLabel.font = AppTheme.Typography.captionMedium
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorBanner.addSubview(errorLabel)

        // Build 3 Steps Cards
        buildStep1Card()
        buildStep2Card()
        buildStep3Card()

        // Dynamic Bottom Constraint to active card
        contentBottomConstraint = contentView.bottomAnchor.constraint(equalTo: step1Card.bottomAnchor, constant: 40)
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

            headerTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 28),
            headerTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            errorBanner.topAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 12),
            errorBanner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            errorBanner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            errorLabel.topAnchor.constraint(equalTo: errorBanner.topAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: errorBanner.leadingAnchor, constant: 12),
            errorLabel.trailingAnchor.constraint(equalTo: errorBanner.trailingAnchor, constant: -12),
            errorLabel.bottomAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: -8)
        ])
    }

    // MARK: - Step 1 Card: Email Entry (Screenshot 1)
    private func buildStep1Card() {
        step1Card.translatesAutoresizingMaskIntoConstraints = false
        step1Card.backgroundColor = .white
        step1Card.layer.cornerRadius = AppTheme.CornerRadius.large
        step1Card.layer.masksToBounds = true
        AppTheme.applyCardElevation(to: step1Card, cornerRadius: AppTheme.CornerRadius.large)
        contentView.addSubview(step1Card)

        // Person / Avatar Icon
        s1AvatarIcon.translatesAutoresizingMaskIntoConstraints = false
        s1AvatarIcon.image = UIImage(systemName: "person.crop.circle.fill") ?? UIImage(systemName: "person.fill")
        s1AvatarIcon.tintColor = AppTheme.actionGold
        s1AvatarIcon.contentMode = .scaleAspectFit
        step1Card.addSubview(s1AvatarIcon)

        // User Email Title Label
        s1TitleLabel.translatesAutoresizingMaskIntoConstraints = false
        s1TitleLabel.text = "User Email"
        s1TitleLabel.textColor = AppTheme.textPrimaryDark
        s1TitleLabel.font = AppTheme.Typography.titleCard
        step1Card.addSubview(s1TitleLabel)

        // Email Text Field
        s1EmailField.translatesAutoresizingMaskIntoConstraints = false
        s1EmailField.placeholder = "Your Email"
        s1EmailField.textColor = AppTheme.textPrimaryDark
        s1EmailField.font = AppTheme.Typography.bodyMedium
        s1EmailField.keyboardType = .emailAddress
        s1EmailField.autocapitalizationType = .none
        s1EmailField.autocorrectionType = .no
        s1EmailField.returnKeyType = .next
        s1EmailField.delegate = self
        s1EmailField.addTarget(self, action: #selector(clearErrorBanner), for: .editingChanged)
        step1Card.addSubview(s1EmailField)

        // Sky Blue Underline
        s1Underline.translatesAutoresizingMaskIntoConstraints = false
        s1Underline.backgroundColor = AppTheme.accentSkyBlue
        step1Card.addSubview(s1Underline)

        // Bottom Bar (Matching Theme #262D35)
        s1BottomBar.translatesAutoresizingMaskIntoConstraints = false
        s1BottomBar.backgroundColor = AppTheme.cardBottomBar
        s1BottomBar.layer.cornerRadius = AppTheme.CornerRadius.large
        s1BottomBar.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        s1BottomBar.layer.masksToBounds = true
        step1Card.addSubview(s1BottomBar)

        s1CancelButton.translatesAutoresizingMaskIntoConstraints = false
        s1CancelButton.setTitle("Cancel", for: .normal)
        s1CancelButton.setTitleColor(AppTheme.accentSkyBlue, for: .normal)
        s1CancelButton.titleLabel?.font = AppTheme.Typography.bodyBold
        s1CancelButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        s1BottomBar.addSubview(s1CancelButton)

        s1NextButton.translatesAutoresizingMaskIntoConstraints = false
        s1NextButton.setTitle("Next  ➔", for: .normal)
        s1NextButton.setTitleColor(.white, for: .normal)
        s1NextButton.titleLabel?.font = AppTheme.Typography.titleCard
        s1NextButton.backgroundColor = AppTheme.emeraldGreen
        s1NextButton.layer.cornerRadius = AppTheme.CornerRadius.medium
        AppTheme.applyButtonElevation(to: s1NextButton)
        s1NextButton.addTarget(self, action: #selector(handleStep1Submit), for: .touchUpInside)
        s1BottomBar.addSubview(s1NextButton)

        s1Spinner.translatesAutoresizingMaskIntoConstraints = false
        s1Spinner.hidesWhenStopped = true
        s1Spinner.color = .white
        s1BottomBar.addSubview(s1Spinner)

        NSLayoutConstraint.activate([
            step1Card.topAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: 16),
            step1Card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            step1Card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            s1AvatarIcon.leadingAnchor.constraint(equalTo: step1Card.leadingAnchor, constant: 18),
            s1AvatarIcon.topAnchor.constraint(equalTo: step1Card.topAnchor, constant: 22),
            s1AvatarIcon.widthAnchor.constraint(equalToConstant: 32),
            s1AvatarIcon.heightAnchor.constraint(equalToConstant: 32),

            s1TitleLabel.leadingAnchor.constraint(equalTo: s1AvatarIcon.trailingAnchor, constant: 12),
            s1TitleLabel.topAnchor.constraint(equalTo: step1Card.topAnchor, constant: 18),

            s1EmailField.leadingAnchor.constraint(equalTo: s1AvatarIcon.trailingAnchor, constant: 12),
            s1EmailField.trailingAnchor.constraint(equalTo: step1Card.trailingAnchor, constant: -18),
            s1EmailField.topAnchor.constraint(equalTo: s1TitleLabel.bottomAnchor, constant: 4),
            s1EmailField.heightAnchor.constraint(equalToConstant: 30),

            s1Underline.leadingAnchor.constraint(equalTo: s1EmailField.leadingAnchor),
            s1Underline.trailingAnchor.constraint(equalTo: s1EmailField.trailingAnchor),
            s1Underline.topAnchor.constraint(equalTo: s1EmailField.bottomAnchor, constant: 2),
            s1Underline.heightAnchor.constraint(equalToConstant: 1.5),

            s1BottomBar.topAnchor.constraint(equalTo: s1Underline.bottomAnchor, constant: 24),
            s1BottomBar.leadingAnchor.constraint(equalTo: step1Card.leadingAnchor),
            s1BottomBar.trailingAnchor.constraint(equalTo: step1Card.trailingAnchor),
            s1BottomBar.bottomAnchor.constraint(equalTo: step1Card.bottomAnchor),
            s1BottomBar.heightAnchor.constraint(equalToConstant: 54),

            s1CancelButton.leadingAnchor.constraint(equalTo: s1BottomBar.leadingAnchor, constant: 20),
            s1CancelButton.centerYAnchor.constraint(equalTo: s1BottomBar.centerYAnchor),

            s1NextButton.trailingAnchor.constraint(equalTo: s1BottomBar.trailingAnchor, constant: -16),
            s1NextButton.centerYAnchor.constraint(equalTo: s1BottomBar.centerYAnchor),
            s1NextButton.widthAnchor.constraint(equalToConstant: 104),
            s1NextButton.heightAnchor.constraint(equalToConstant: 38),

            s1Spinner.centerXAnchor.constraint(equalTo: s1NextButton.centerXAnchor),
            s1Spinner.centerYAnchor.constraint(equalTo: s1NextButton.centerYAnchor)
        ])
    }

    // MARK: - Step 2 Card: 6-Box OTP (Screenshot 2)
    private func buildStep2Card() {
        step2Card.translatesAutoresizingMaskIntoConstraints = false
        step2Card.backgroundColor = .white
        step2Card.layer.cornerRadius = AppTheme.CornerRadius.large
        step2Card.layer.masksToBounds = true
        step2Card.isHidden = true
        AppTheme.applyCardElevation(to: step2Card, cornerRadius: AppTheme.CornerRadius.large)
        contentView.addSubview(step2Card)

        // Lock Icon
        s2LockIcon.translatesAutoresizingMaskIntoConstraints = false
        s2LockIcon.image = UIImage(systemName: "lock.fill")
        s2LockIcon.tintColor = AppTheme.actionGold
        s2LockIcon.contentMode = .scaleAspectFit
        step2Card.addSubview(s2LockIcon)

        // 6 Individual OTP Boxes
        s2OtpStack.translatesAutoresizingMaskIntoConstraints = false
        s2OtpStack.axis = .horizontal
        s2OtpStack.distribution = .fillEqually
        s2OtpStack.spacing = 8
        step2Card.addSubview(s2OtpStack)

        for i in 0..<6 {
            let tf = UITextField()
            tf.translatesAutoresizingMaskIntoConstraints = false
            tf.textAlignment = .center
            tf.font = AppTheme.Typography.otpDigits
            tf.textColor = AppTheme.textPrimaryDark
            tf.backgroundColor = UIColor(red: 245/255, green: 247/255, blue: 250/255, alpha: 1.0)
            tf.layer.cornerRadius = AppTheme.CornerRadius.medium
            tf.layer.borderWidth = 1.5
            tf.layer.borderColor = AppTheme.inputBorderNormal.cgColor
            tf.keyboardType = .numberPad
            tf.tag = i
            tf.delegate = self
            tf.addTarget(self, action: #selector(otpTextChanged(_:)), for: .editingChanged)
            s2OtpBoxes.append(tf)
            s2OtpStack.addArrangedSubview(tf)
        }

        // Bottom Bar
        s2BottomBar.translatesAutoresizingMaskIntoConstraints = false
        s2BottomBar.backgroundColor = AppTheme.cardBottomBar
        s2BottomBar.layer.cornerRadius = AppTheme.CornerRadius.large
        s2BottomBar.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        s2BottomBar.layer.masksToBounds = true
        step2Card.addSubview(s2BottomBar)

        s2CancelButton.translatesAutoresizingMaskIntoConstraints = false
        s2CancelButton.setTitle("Cancel", for: .normal)
        s2CancelButton.setTitleColor(AppTheme.accentSkyBlue, for: .normal)
        s2CancelButton.titleLabel?.font = AppTheme.Typography.bodyBold
        s2CancelButton.addTarget(self, action: #selector(handleStep2Cancel), for: .touchUpInside)
        s2BottomBar.addSubview(s2CancelButton)

        s2NextButton.translatesAutoresizingMaskIntoConstraints = false
        s2NextButton.setTitle("Next  ➔", for: .normal)
        s2NextButton.setTitleColor(.white, for: .normal)
        s2NextButton.titleLabel?.font = AppTheme.Typography.titleCard
        s2NextButton.backgroundColor = AppTheme.emeraldGreen
        s2NextButton.layer.cornerRadius = AppTheme.CornerRadius.medium
        AppTheme.applyButtonElevation(to: s2NextButton)
        s2NextButton.addTarget(self, action: #selector(handleStep2Submit), for: .touchUpInside)
        s2BottomBar.addSubview(s2NextButton)

        s2Spinner.translatesAutoresizingMaskIntoConstraints = false
        s2Spinner.hidesWhenStopped = true
        s2Spinner.color = .white
        s2BottomBar.addSubview(s2Spinner)

        NSLayoutConstraint.activate([
            step2Card.topAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: 16),
            step2Card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            step2Card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            s2LockIcon.leadingAnchor.constraint(equalTo: step2Card.leadingAnchor, constant: 16),
            s2LockIcon.centerYAnchor.constraint(equalTo: s2OtpStack.centerYAnchor),
            s2LockIcon.widthAnchor.constraint(equalToConstant: 26),
            s2LockIcon.heightAnchor.constraint(equalToConstant: 26),

            s2OtpStack.leadingAnchor.constraint(equalTo: s2LockIcon.trailingAnchor, constant: 12),
            s2OtpStack.trailingAnchor.constraint(equalTo: step2Card.trailingAnchor, constant: -16),
            s2OtpStack.topAnchor.constraint(equalTo: step2Card.topAnchor, constant: 24),
            s2OtpStack.heightAnchor.constraint(equalToConstant: 48),

            s2BottomBar.topAnchor.constraint(equalTo: s2OtpStack.bottomAnchor, constant: 24),
            s2BottomBar.leadingAnchor.constraint(equalTo: step2Card.leadingAnchor),
            s2BottomBar.trailingAnchor.constraint(equalTo: step2Card.trailingAnchor),
            s2BottomBar.bottomAnchor.constraint(equalTo: step2Card.bottomAnchor),
            s2BottomBar.heightAnchor.constraint(equalToConstant: 54),

            s2CancelButton.leadingAnchor.constraint(equalTo: s2BottomBar.leadingAnchor, constant: 20),
            s2CancelButton.centerYAnchor.constraint(equalTo: s2BottomBar.centerYAnchor),

            s2NextButton.trailingAnchor.constraint(equalTo: s2BottomBar.trailingAnchor, constant: -16),
            s2NextButton.centerYAnchor.constraint(equalTo: s2BottomBar.centerYAnchor),
            s2NextButton.widthAnchor.constraint(equalToConstant: 104),
            s2NextButton.heightAnchor.constraint(equalToConstant: 38),

            s2Spinner.centerXAnchor.constraint(equalTo: s2NextButton.centerXAnchor),
            s2Spinner.centerYAnchor.constraint(equalTo: s2NextButton.centerYAnchor)
        ])
    }

    // MARK: - Step 3 Card: Password Entry (Screenshot 3)
    private func buildStep3Card() {
        step3Card.translatesAutoresizingMaskIntoConstraints = false
        step3Card.backgroundColor = .white
        step3Card.layer.cornerRadius = AppTheme.CornerRadius.large
        step3Card.layer.masksToBounds = true
        step3Card.isHidden = true
        AppTheme.applyCardElevation(to: step3Card, cornerRadius: AppTheme.CornerRadius.large)
        contentView.addSubview(step3Card)

        // 1. Password Row
        s3LockIcon1.translatesAutoresizingMaskIntoConstraints = false
        s3LockIcon1.image = UIImage(systemName: "lock.fill")
        s3LockIcon1.tintColor = AppTheme.actionGold
        s3LockIcon1.contentMode = .scaleAspectFit
        step3Card.addSubview(s3LockIcon1)

        s3ShowPasswordButton1.translatesAutoresizingMaskIntoConstraints = false
        s3ShowPasswordButton1.setTitle("", for: .normal)
        s3ShowPasswordButton1.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        s3ShowPasswordButton1.tintColor = AppTheme.textPlaceholder
        s3ShowPasswordButton1.addTarget(self, action: #selector(toggleShowPassword1), for: .touchUpInside)
        step3Card.addSubview(s3ShowPasswordButton1)

        s3PasswordField.translatesAutoresizingMaskIntoConstraints = false
        s3PasswordField.placeholder = "Type Your Password"
        s3PasswordField.textColor = AppTheme.textPrimaryDark
        s3PasswordField.font = AppTheme.Typography.bodyMedium
        s3PasswordField.isSecureTextEntry = true
        s3PasswordField.returnKeyType = .next
        s3PasswordField.delegate = self
        s3PasswordField.addTarget(self, action: #selector(clearErrorBanner), for: .editingChanged)
        step3Card.addSubview(s3PasswordField)

        s3PasswordUnderline.translatesAutoresizingMaskIntoConstraints = false
        s3PasswordUnderline.backgroundColor = AppTheme.accentSkyBlue
        step3Card.addSubview(s3PasswordUnderline)

        // 2. Confirm Password Row
        s3LockIcon2.translatesAutoresizingMaskIntoConstraints = false
        s3LockIcon2.image = UIImage(systemName: "lock.fill")
        s3LockIcon2.tintColor = AppTheme.actionGold
        s3LockIcon2.contentMode = .scaleAspectFit
        step3Card.addSubview(s3LockIcon2)

        s3ShowPasswordButton2.translatesAutoresizingMaskIntoConstraints = false
        s3ShowPasswordButton2.setTitle("", for: .normal)
        s3ShowPasswordButton2.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        s3ShowPasswordButton2.tintColor = AppTheme.textPlaceholder
        s3ShowPasswordButton2.addTarget(self, action: #selector(toggleShowPassword2), for: .touchUpInside)
        step3Card.addSubview(s3ShowPasswordButton2)

        s3ConfirmPasswordField.translatesAutoresizingMaskIntoConstraints = false
        s3ConfirmPasswordField.placeholder = "Type Your Password Again"
        s3ConfirmPasswordField.textColor = AppTheme.textPrimaryDark
        s3ConfirmPasswordField.font = AppTheme.Typography.bodyMedium
        s3ConfirmPasswordField.isSecureTextEntry = true
        s3ConfirmPasswordField.returnKeyType = .go
        s3ConfirmPasswordField.delegate = self
        s3ConfirmPasswordField.addTarget(self, action: #selector(clearErrorBanner), for: .editingChanged)
        step3Card.addSubview(s3ConfirmPasswordField)

        s3ConfirmPasswordUnderline.translatesAutoresizingMaskIntoConstraints = false
        s3ConfirmPasswordUnderline.backgroundColor = AppTheme.accentSkyBlue
        step3Card.addSubview(s3ConfirmPasswordUnderline)

        // Step 3 Bottom Bar
        s3BottomBar.translatesAutoresizingMaskIntoConstraints = false
        s3BottomBar.backgroundColor = AppTheme.cardBottomBar
        s3BottomBar.layer.cornerRadius = AppTheme.CornerRadius.large
        s3BottomBar.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        s3BottomBar.layer.masksToBounds = true
        step3Card.addSubview(s3BottomBar)

        s3CancelButton.translatesAutoresizingMaskIntoConstraints = false
        s3CancelButton.setTitle("Cancel", for: .normal)
        s3CancelButton.setTitleColor(AppTheme.accentSkyBlue, for: .normal)
        s3CancelButton.titleLabel?.font = AppTheme.Typography.bodyBold
        s3CancelButton.addTarget(self, action: #selector(handleStep3Cancel), for: .touchUpInside)
        s3BottomBar.addSubview(s3CancelButton)

        s3NextButton.translatesAutoresizingMaskIntoConstraints = false
        s3NextButton.setTitle("Reset Password ➔", for: .normal)
        s3NextButton.setTitleColor(.white, for: .normal)
        s3NextButton.titleLabel?.font = AppTheme.Typography.titleCard
        s3NextButton.backgroundColor = AppTheme.emeraldGreen
        s3NextButton.layer.cornerRadius = AppTheme.CornerRadius.medium
        AppTheme.applyButtonElevation(to: s3NextButton)
        s3NextButton.addTarget(self, action: #selector(handleStep3Submit), for: .touchUpInside)
        s3BottomBar.addSubview(s3NextButton)

        s3Spinner.translatesAutoresizingMaskIntoConstraints = false
        s3Spinner.hidesWhenStopped = true
        s3Spinner.color = .white
        s3BottomBar.addSubview(s3Spinner)

        NSLayoutConstraint.activate([
            step3Card.topAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: 16),
            step3Card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            step3Card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Password Row
            s3LockIcon1.leadingAnchor.constraint(equalTo: step3Card.leadingAnchor, constant: 18),
            s3LockIcon1.centerYAnchor.constraint(equalTo: s3PasswordField.centerYAnchor),
            s3LockIcon1.widthAnchor.constraint(equalToConstant: 22),
            s3LockIcon1.heightAnchor.constraint(equalToConstant: 22),

            s3ShowPasswordButton1.trailingAnchor.constraint(equalTo: step3Card.trailingAnchor, constant: -16),
            s3ShowPasswordButton1.centerYAnchor.constraint(equalTo: s3PasswordField.centerYAnchor),
            s3ShowPasswordButton1.widthAnchor.constraint(equalToConstant: 44),
            s3ShowPasswordButton1.heightAnchor.constraint(equalToConstant: 44),

            s3PasswordField.leadingAnchor.constraint(equalTo: s3LockIcon1.trailingAnchor, constant: 12),
            s3PasswordField.trailingAnchor.constraint(equalTo: s3ShowPasswordButton1.leadingAnchor, constant: -8),
            s3PasswordField.topAnchor.constraint(equalTo: step3Card.topAnchor, constant: 22),
            s3PasswordField.heightAnchor.constraint(equalToConstant: 30),

            s3PasswordUnderline.leadingAnchor.constraint(equalTo: s3PasswordField.leadingAnchor),
            s3PasswordUnderline.trailingAnchor.constraint(equalTo: s3PasswordField.trailingAnchor),
            s3PasswordUnderline.topAnchor.constraint(equalTo: s3PasswordField.bottomAnchor, constant: 2),
            s3PasswordUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            // Confirm Password Row
            s3LockIcon2.leadingAnchor.constraint(equalTo: step3Card.leadingAnchor, constant: 18),
            s3LockIcon2.centerYAnchor.constraint(equalTo: s3ConfirmPasswordField.centerYAnchor),
            s3LockIcon2.widthAnchor.constraint(equalToConstant: 22),
            s3LockIcon2.heightAnchor.constraint(equalToConstant: 22),

            s3ShowPasswordButton2.trailingAnchor.constraint(equalTo: step3Card.trailingAnchor, constant: -16),
            s3ShowPasswordButton2.centerYAnchor.constraint(equalTo: s3ConfirmPasswordField.centerYAnchor),
            s3ShowPasswordButton2.widthAnchor.constraint(equalToConstant: 44),
            s3ShowPasswordButton2.heightAnchor.constraint(equalToConstant: 44),

            s3ConfirmPasswordField.leadingAnchor.constraint(equalTo: s3LockIcon2.trailingAnchor, constant: 12),
            s3ConfirmPasswordField.trailingAnchor.constraint(equalTo: s3ShowPasswordButton2.leadingAnchor, constant: -8),
            s3ConfirmPasswordField.topAnchor.constraint(equalTo: s3PasswordUnderline.bottomAnchor, constant: 18),
            s3ConfirmPasswordField.heightAnchor.constraint(equalToConstant: 30),

            s3ConfirmPasswordUnderline.leadingAnchor.constraint(equalTo: s3ConfirmPasswordField.leadingAnchor),
            s3ConfirmPasswordUnderline.trailingAnchor.constraint(equalTo: s3ConfirmPasswordField.trailingAnchor),
            s3ConfirmPasswordUnderline.topAnchor.constraint(equalTo: s3ConfirmPasswordField.bottomAnchor, constant: 2),
            s3ConfirmPasswordUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            // Bottom Bar
            s3BottomBar.topAnchor.constraint(equalTo: s3ConfirmPasswordUnderline.bottomAnchor, constant: 24),
            s3BottomBar.leadingAnchor.constraint(equalTo: step3Card.leadingAnchor),
            s3BottomBar.trailingAnchor.constraint(equalTo: step3Card.trailingAnchor),
            s3BottomBar.bottomAnchor.constraint(equalTo: step3Card.bottomAnchor),
            s3BottomBar.heightAnchor.constraint(equalToConstant: 54),

            s3CancelButton.leadingAnchor.constraint(equalTo: s3BottomBar.leadingAnchor, constant: 20),
            s3CancelButton.centerYAnchor.constraint(equalTo: s3BottomBar.centerYAnchor),

            s3NextButton.trailingAnchor.constraint(equalTo: s3BottomBar.trailingAnchor, constant: -16),
            s3NextButton.centerYAnchor.constraint(equalTo: s3BottomBar.centerYAnchor),
            s3NextButton.widthAnchor.constraint(equalToConstant: 154),
            s3NextButton.heightAnchor.constraint(equalToConstant: 38),

            s3Spinner.centerXAnchor.constraint(equalTo: s3NextButton.centerXAnchor),
            s3Spinner.centerYAnchor.constraint(equalTo: s3NextButton.centerYAnchor)
        ])
    }

    // MARK: - Actions & API Calls

    // Step 1: Submit Email -> POST /api/forgot-password
    @objc private func handleStep1Submit() {
        view.endEditing(true)
        let email = s1EmailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard ValidationHelper.isValidEmail(email) else {
            s1Underline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            showError("Please enter a valid email address.")
            return
        }

        s1NextButton.setTitle("", for: .normal)
        s1Spinner.startAnimating()
        clearErrorBanner()

        guard let url = URL(string: AppConfig.API.forgotPassword) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(AppConfig.apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let params: [String: String] = [
            "email": email,
            "device_type": AppConfig.deviceType,
            "mobile_device_id": AppConfig.mobileDeviceId
        ]
        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        APIClient.post(endpoint: AppConfig.API.forgotPassword, parameters: params) { [weak self] result in
            guard let self = self else { return }
            self.s1Spinner.stopAnimating()
            self.s1NextButton.setTitle("Next  ➔", for: .normal)

            switch result {
            case .failure(let error):
                self.s1Underline.backgroundColor = AppTheme.errorRed
                self.showError("Network error: \(error.localizedDescription)")
            case .success(let json):
                let status = json["status"] as? Bool ?? false
                let apiMessage = self.extractMessage(from: json, fallback: "Email does not exist in our records.")

                if status {
                    self.userEmail = email
                    self.s1Underline.backgroundColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                    // Update bottom constraint to step2Card
                    self.contentBottomConstraint?.isActive = false
                    self.contentBottomConstraint = self.contentView.bottomAnchor.constraint(equalTo: self.step2Card.bottomAnchor, constant: 40)
                    self.contentBottomConstraint?.isActive = true

                    // Transition to Step 2 Card (Enter OTP)
                    self.headerTitleLabel.text = "Enter OTP"
                    UIView.transition(with: self.contentView, duration: 0.35, options: .transitionCrossDissolve) {
                        self.step1Card.isHidden = true
                        self.step2Card.isHidden = false
                    }
                    self.scrollView.setContentOffset(.zero, animated: true)
                    self.s2OtpBoxes.first?.becomeFirstResponder()
                } else {
                    self.s1Underline.backgroundColor = AppTheme.errorRed
                    self.showError(apiMessage)
                }
            }
        }
    }

    // Step 2: Submit OTP -> POST /api/otp-verification
    @objc private func handleStep2Submit() {
        view.endEditing(true)
        let otp = s2OtpBoxes.map { $0.text ?? "" }.joined().trimmingCharacters(in: .whitespacesAndNewlines)
        guard ValidationHelper.isNonEmpty(otp) else {
            showError("Please enter the OTP.")
            return
        }

        s2NextButton.setTitle("", for: .normal)
        s2Spinner.startAnimating()
        clearErrorBanner()

        guard let url = URL(string: AppConfig.API.otpVerification) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(AppConfig.apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let params: [String: String] = [
            "email": userEmail,
            "forgot_otp": otp,
            "device_type": AppConfig.deviceType,
            "mobile_device_id": AppConfig.mobileDeviceId
        ]
        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        APIClient.post(endpoint: AppConfig.API.otpVerification, parameters: params) { [weak self] result in
            guard let self = self else { return }
            self.s2Spinner.stopAnimating()
            self.s2NextButton.setTitle("Next  ➔", for: .normal)

            switch result {
            case .failure(let error):
                self.showError("Network error: \(error.localizedDescription)")
            case .success(let json):
                let status = json["status"] as? Bool ?? false
                let apiMessage = self.extractMessage(from: json, fallback: "Invalid OTP entered.")

                if status {
                    self.verifiedOTP = otp
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                    // Update bottom constraint to step3Card
                    self.contentBottomConstraint?.isActive = false
                    self.contentBottomConstraint = self.contentView.bottomAnchor.constraint(equalTo: self.step3Card.bottomAnchor, constant: 40)
                    self.contentBottomConstraint?.isActive = true

                    // Transition to Step 3 Card (Enter Password)
                    self.headerTitleLabel.text = "Enter Password"
                    UIView.transition(with: self.contentView, duration: 0.35, options: .transitionCrossDissolve) {
                        self.step2Card.isHidden = true
                        self.step3Card.isHidden = false
                    }
                    self.scrollView.setContentOffset(.zero, animated: true)
                    self.s3PasswordField.becomeFirstResponder()
                } else {
                    self.showError(apiMessage)
                }
            }
        }
    }

    // Step 3: Submit New Password -> POST /api/resent-password
    @objc private func handleStep3Submit() {
        view.endEditing(true)
        let pass = s3PasswordField.text ?? ""
        let confirmPass = s3ConfirmPasswordField.text ?? ""

        let passValidation = ValidationHelper.isValidPassword(pass, minLength: 6)
        guard passValidation.isValid else {
            s3PasswordUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            showError(passValidation.message ?? "Password must be at least 6 characters.")
            return
        }

        guard pass == confirmPass else {
            s3ConfirmPasswordUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            showError("Passwords do not match. Please re-type.")
            return
        }

        s3NextButton.setTitle("", for: .normal)
        s3Spinner.startAnimating()
        clearErrorBanner()

        guard let url = URL(string: AppConfig.API.resetPassword) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(AppConfig.apiAccessToken, forHTTPHeaderField: "access-token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let params: [String: String] = [
            "email": userEmail,
            "forgot_otp": verifiedOTP,
            "password": pass,
            "device_type": AppConfig.deviceType,
            "mobile_device_id": AppConfig.mobileDeviceId
        ]
        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        APIClient.post(endpoint: AppConfig.API.resetPassword, parameters: params) { [weak self] result in
            guard let self = self else { return }
            self.s3Spinner.stopAnimating()
            self.s3NextButton.setTitle("Next  ➔", for: .normal)

            switch result {
            case .failure(let error):
                self.showError("Network error: \(error.localizedDescription)")
            case .success(let json):
                let status = json["status"] as? Bool ?? false
                let apiMessage = self.extractMessage(from: json, fallback: "Failed to reset password.")

                if status {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    let alert = UIAlertController(
                        title: "Password Changed!",
                        message: "Your password has been successfully updated.\nYou can now log in with your new credentials.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Log In Now", style: .default) { [weak self] _ in
                        guard let self = self else { return }
                        self.dismiss(animated: true) {
                            self.onResetPasswordSuccess?(self.userEmail)
                        }
                    })
                    self.present(alert, animated: true)
                } else {
                    self.showError(apiMessage)
                }
            }
        }
    }

    // MARK: - Navigation / Back Buttons
    @objc private func handleCancel() {
        dismiss(animated: true)
    }

    @objc private func handleStep2Cancel() {
        clearErrorBanner()
        headerTitleLabel.text = "Forgot Password?"

        contentBottomConstraint?.isActive = false
        contentBottomConstraint = contentView.bottomAnchor.constraint(equalTo: step1Card.bottomAnchor, constant: 40)
        contentBottomConstraint?.isActive = true

        UIView.transition(with: contentView, duration: 0.3, options: .transitionCrossDissolve) {
            self.step2Card.isHidden = true
            self.step1Card.isHidden = false
        }
        scrollView.setContentOffset(.zero, animated: true)
        s1EmailField.becomeFirstResponder()
    }

    @objc private func handleStep3Cancel() {
        clearErrorBanner()
        headerTitleLabel.text = "Enter OTP"

        contentBottomConstraint?.isActive = false
        contentBottomConstraint = contentView.bottomAnchor.constraint(equalTo: step2Card.bottomAnchor, constant: 40)
        contentBottomConstraint?.isActive = true

        UIView.transition(with: contentView, duration: 0.3, options: .transitionCrossDissolve) {
            self.step3Card.isHidden = true
            self.step2Card.isHidden = false
        }
        scrollView.setContentOffset(.zero, animated: true)
        s2OtpBoxes.first?.becomeFirstResponder()
    }

    // MARK: - Password Show/Hide
    @objc private func toggleShowPassword1() {
        AppTheme.triggerHapticFeedback(.light)
        s3PasswordField.isSecureTextEntry.toggle()
        let icon = s3PasswordField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        s3ShowPasswordButton1.setImage(UIImage(systemName: icon), for: .normal)
    }

    @objc private func toggleShowPassword2() {
        AppTheme.triggerHapticFeedback(.light)
        s3ConfirmPasswordField.isSecureTextEntry.toggle()
        let icon = s3ConfirmPasswordField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        s3ShowPasswordButton2.setImage(UIImage(systemName: icon), for: .normal)
    }

    // MARK: - OTP 6-Box Logic (Auto-Advance & Backspace)
    @objc private func otpTextChanged(_ textField: UITextField) {
        let text = textField.text ?? ""
        if text.count > 1 {
            // If user pasted multi-character code
            let chars = Array(text)
            for (idx, ch) in chars.enumerated() {
                if idx < s2OtpBoxes.count {
                    s2OtpBoxes[idx].text = String(ch)
                }
            }
            s2OtpBoxes.last?.becomeFirstResponder()
        } else if text.count == 1 {
            // Auto advance
            let nextIndex = textField.tag + 1
            if nextIndex < s2OtpBoxes.count {
                s2OtpBoxes[nextIndex].becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if s2OtpBoxes.contains(textField) {
            UIView.animate(withDuration: 0.15) {
                textField.layer.borderColor = AppTheme.inputBorderActive.cgColor
                textField.layer.borderWidth = 2.0
            }
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if s2OtpBoxes.contains(textField) {
            UIView.animate(withDuration: 0.15) {
                textField.layer.borderColor = AppTheme.inputBorderNormal.cgColor
                textField.layer.borderWidth = 1.5
            }
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag >= 0 && textField.tag < 6 && s2OtpBoxes.contains(textField) {
            // Handle Backspace
            if string.isEmpty {
                textField.text = ""
                let prevIndex = textField.tag - 1
                if prevIndex >= 0 {
                    s2OtpBoxes[prevIndex].becomeFirstResponder()
                }
                return false
            }
            // Only allow digits
            guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) else {
                return false
            }
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == s1EmailField {
            handleStep1Submit()
        } else if textField == s3PasswordField {
            s3ConfirmPasswordField.becomeFirstResponder()
        } else if textField == s3ConfirmPasswordField {
            handleStep3Submit()
        }
        return true
    }

    // MARK: - Helpers
    private func showError(_ msg: String) {
        AppTheme.triggerNotificationFeedback(.error)
        errorLabel.text = "  ⚠️  \(msg)  "
        errorBanner.alpha = 0
        errorBanner.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.errorBanner.alpha = 1.0
        }
    }

    @objc private func clearErrorBanner() {
        if !errorBanner.isHidden {
            UIView.animate(withDuration: 0.2, animations: {
                self.errorBanner.alpha = 0
            }) { _ in
                self.errorBanner.isHidden = true
            }
        }
        s1Underline.backgroundColor = AppTheme.accentSkyBlue
        s3PasswordUnderline.backgroundColor = AppTheme.accentSkyBlue
        s3ConfirmPasswordUnderline.backgroundColor = AppTheme.accentSkyBlue
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
