import UIKit
import PhotosUI

class SignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var onSignUpSuccess: ((String) -> Void)?

    // MARK: - State Tracking
    private var verifiedMerchantId: Int = 6
    private var verifiedMerchantName: String = "SHRI ANANDPUR TRUST"
    private var verifiedRoleId: Int = 0

    private var isEmailVerified = false
    private var isMobileVerified = false
    private var isParentCodeVerified = false

    private var availableTitles: [String] = ["Mr", "Mrs", "Ms", "Mh", "Bai", "Bh"]
    private var selectedTitle: String = "Mr"

    private let idDocumentOptions: [String] = ["Aadhar Card", "PAN Card", "Voter ID Card", "Driving License", "Passport"]
    private var selectedIdDocument: String = "Aadhar Card"

    private var selectedGender: Int = 1 // 1 = Male, 2 = Female
    private var uploadedDocumentImage: UIImage?

    // OTP Timer
    private var otpTimer: Timer?
    private var otpRemainingSeconds = 30

    // Dynamic Content View Bottom Constraint
    private var contentBottomConstraint: NSLayoutConstraint?

    // MARK: - Main UI Containers
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let headerTitleLabel = UILabel()
    private let headerSubtitleLabel = UILabel()
    private let errorBanner = UIView()
    private let errorLabel = UILabel()
    private let versionLabel = UILabel()

    // MARK: - Card 1: Initial State (Trust Code only)
    private let initialCardView = UIView()
    private let initTrustBadge = UIView()
    private let initTrustBadgeIcon = UIImageView()
    private let initTrustTitleLabel = UILabel()
    private let initTrustCodeField = UITextField()
    private let initTrustUnderline = UIView()
    private let initTrustArrowButton = UIButton(type: .system)
    private let initTrustInfoButton = UIButton(type: .system)
    private let initTrustSpinner = UIActivityIndicatorView(style: .medium)
    private let initBottomBar = UIView()
    private let initCancelButton = UIButton(type: .system)

    // MARK: - Card 2: Mid Progressive Card (Trust -> Email -> Mobile -> Parent Code)
    private let midCardView = UIView()

    // Trust Row
    private let midTrustRowView = UIView()
    private let midTrustBadge = UIView()
    private let midTrustBadgeIcon = UIImageView()
    private let midTrustTitleLabel = UILabel()
    private let midTrustCodeField = UITextField()
    private let midTrustUnderline = UIView()
    private let midTrustCheckmark = UIImageView()
    private let midTrustArrowButton = UIButton(type: .system)
    private let midTrustInfoButton = UIButton(type: .system)

    // Emblem Logo
    private let midEmblemImageView = UIImageView()

    // Email Row
    private let midEmailRowView = UIView()
    private let midEmailIcon = UIImageView()
    private let midEmailTitleLabel = UILabel()
    private let midEmailField = UITextField()
    private let midEmailUnderline = UIView()
    private let midEmailCheckmark = UIImageView()
    private let midEmailArrowButton = UIButton(type: .system)
    private let midEmailInfoButton = UIButton(type: .system)
    private let midEmailSpinner = UIActivityIndicatorView(style: .medium)

    // Mobile Row
    private let midMobileRowView = UIView()
    private let midMobileIcon = UIImageView()
    private let midMobileTitleLabel = UILabel()
    private let midMobileField = UITextField()
    private let midMobileUnderline = UIView()
    private let midMobileCheckmark = UIImageView()
    private let midMobileArrowButton = UIButton(type: .system)
    private let midMobileInfoButton = UIButton(type: .system)
    private let midMobileSpinner = UIActivityIndicatorView(style: .medium)

    // Parent Code Row
    private let midParentRowView = UIView()
    private let midParentIcon = UIImageView()
    private let midParentTitleLabel = UILabel()
    private let midParentCodeField = UITextField()
    private let midParentUnderline = UIView()
    private let midParentCheckmark = UIImageView()
    private let midParentArrowButton = UIButton(type: .system)
    private let midParentInfoButton = UIButton(type: .system)
    private let midParentSpinner = UIActivityIndicatorView(style: .medium)

    // Mid Bottom Bar
    private let midBottomBar = UIView()
    private let midCancelButton = UIButton(type: .system)

    // Dynamic constraints for midCardView progressive heights
    private var midEmailToBottomConstraint: NSLayoutConstraint?
    private var midMobileToBottomConstraint: NSLayoutConstraint?
    private var midParentToBottomConstraint: NSLayoutConstraint?

    // MARK: - Card 3: Full User Details Card (Screenshot 1 & 2)
    private let detailsCardView = UIView()

    // 1. Trust Code Row
    private let dtTrustRow = UIView()
    private let dtTrustBadge = UIView()
    private let dtTrustBadgeIcon = UIImageView()
    private let dtTrustTitleLabel = UILabel()
    private let dtTrustCodeField = UITextField()
    private let dtTrustUnderline = UIView()
    private let dtTrustCheckmark = UIImageView()
    private let dtTrustArrowButton = UIButton(type: .system)
    private let dtTrustInfoButton = UIButton(type: .system)

    // 2. Title*
    private let dtTitleRow = UIView()
    private let dtTitleIcon = UIImageView()
    private let dtTitleLabel = UILabel()
    private let dtTitleField = UITextField()
    private let dtTitleUnderline = UIView()

    // 3. First Name*
    private let dtFnameRow = UIView()
    private let dtFnameIcon = UIImageView()
    private let dtFnameLabel = UILabel()
    private let dtFnameField = UITextField()
    private let dtFnameUnderline = UIView()

    // 4. Last Name*
    private let dtLnameRow = UIView()
    private let dtLnameIcon = UIImageView()
    private let dtLnameLabel = UILabel()
    private let dtLnameField = UITextField()
    private let dtLnameUnderline = UIView()

    // 5. Password*
    private let dtPasswordRow = UIView()
    private let dtPasswordIcon = UIImageView()
    private let dtPasswordLabel = UILabel()
    private let dtPasswordField = UITextField()
    private let dtPasswordUnderline = UIView()
    private let dtShowPasswordButton = UIButton(type: .system)

    // 6. Center Emblem Logo
    private let dtEmblemImageView = UIImageView()

    // 7. Email*
    private let dtEmailRow = UIView()
    private let dtEmailIcon = UIImageView()
    private let dtEmailLabel = UILabel()
    private let dtEmailField = UITextField()
    private let dtEmailUnderline = UIView()
    private let dtEmailCheckmark = UIImageView()

    // 8. Mobile phone*
    private let dtMobileRow = UIView()
    private let dtMobileIcon = UIImageView()
    private let dtMobileLabel = UILabel()
    private let dtMobileField = UITextField()
    private let dtMobileUnderline = UIView()
    private let dtMobileCheckmark = UIImageView()
    private let dtMobileArrowButton = UIButton(type: .system)
    private let dtMobileInfoButton = UIButton(type: .system)

    // 9. Mobile phone # for OTP
    private let dtOtpMobileRow = UIView()
    private let dtOtpMobileIcon = UIImageView()
    private let dtOtpMobileLabel = UILabel()
    private let dtOtpMobileField = UITextField()
    private let dtOtpMobileUnderline = UIView()

    // 10. Gender
    private let dtGenderRow = UIView()
    private let dtGenderIcon = UIImageView()
    private let dtGenderLabel = UILabel()
    private let dtMaleRadioButton = UIButton(type: .system)
    private let dtFemaleRadioButton = UIButton(type: .system)

    // 11. Enter Main/Parent Branch Code#
    private let dtParentRow = UIView()
    private let dtParentIcon = UIImageView()
    private let dtParentLabel = UILabel()
    private let dtParentCodeField = UITextField()
    private let dtParentUnderline = UIView()
    private let dtParentCheckmark = UIImageView()
    private let dtParentArrowButton = UIButton(type: .system)
    private let dtParentInfoButton = UIButton(type: .system)

    // 12. Id Document
    private let dtIdDocRow = UIView()
    private let dtIdDocIcon = UIImageView()
    private let dtIdDocLabel = UILabel()
    private let dtIdDocField = UITextField()
    private let dtIdDocUnderline = UIView()

    // 13. Government Id Number
    private let dtGovtIdRow = UIView()
    private let dtGovtIdIcon = UIImageView()
    private let dtGovtIdLabel = UILabel()
    private let dtGovtIdField = UITextField()
    private let dtGovtIdUnderline = UIView()

    // 14. Upload Document Box
    private let dtUploadBox = UIView()
    private let dtUploadIcon = UIImageView()
    private let dtUploadLabel = UILabel()
    private let dtUploadPreview = UIImageView()

    // Details Bottom Bar
    private let dtBottomBar = UIView()
    private let dtCancelButton = UIButton(type: .system)
    private let dtRegisterButton = UIButton(type: .system)
    private let dtRegisterSpinner = UIActivityIndicatorView(style: .medium)

    // MARK: - Floating OTP Modal Dialog (Screenshot 3)
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
        setupOTPDialogUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    deinit {
        otpTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Main UI Construction
    private func setupUI() {
        // Deep Royal Blue Canvas (#133B7C)
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

        // 2. Header Labels
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.text = "Sign Up"
        headerTitleLabel.textColor = .white
        headerTitleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        headerTitleLabel.textAlignment = .center
        contentView.addSubview(headerTitleLabel)

        headerSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerSubtitleLabel.text = "Enter Detail Of User"
        headerSubtitleLabel.textColor = .white
        headerSubtitleLabel.font = UIFont.systemFont(ofSize: 16.5, weight: .medium)
        headerSubtitleLabel.textAlignment = .center
        headerSubtitleLabel.isHidden = true
        contentView.addSubview(headerSubtitleLabel)

        // 3. Error Banner
        errorBanner.translatesAutoresizingMaskIntoConstraints = false
        errorBanner.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 0.95)
        errorBanner.layer.cornerRadius = 6
        errorBanner.layer.masksToBounds = true
        errorBanner.isHidden = true
        contentView.addSubview(errorBanner)

        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textColor = .white
        errorLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorBanner.addSubview(errorLabel)

        // 4. Build 3 Self-Sizing Cards
        buildInitialCard()
        buildMidCard()
        buildDetailsCard()

        // 5. Version Label ("v t 2.0.10")
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.text = "v t 2.0.10"
        versionLabel.textColor = UIColor.white.withAlphaComponent(0.65)
        versionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        versionLabel.textAlignment = .right
        view.addSubview(versionLabel)

        // Dynamic bottom constraint to initialCardView
        contentBottomConstraint = contentView.bottomAnchor.constraint(equalTo: initialCardView.bottomAnchor, constant: 40)
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

            headerTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            headerTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            headerSubtitleLabel.topAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 6),
            headerSubtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            errorBanner.topAnchor.constraint(equalTo: headerSubtitleLabel.bottomAnchor, constant: 8),
            errorBanner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            errorBanner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            errorLabel.topAnchor.constraint(equalTo: errorBanner.topAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: errorBanner.leadingAnchor, constant: 12),
            errorLabel.trailingAnchor.constraint(equalTo: errorBanner.trailingAnchor, constant: -12),
            errorLabel.bottomAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: -8),

            versionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }

    // MARK: - Card 1: Compact Initial Card (Trust Code only)
    private func buildInitialCard() {
        initialCardView.translatesAutoresizingMaskIntoConstraints = false
        initialCardView.backgroundColor = .white
        initialCardView.layer.cornerRadius = 18
        initialCardView.layer.masksToBounds = true
        contentView.addSubview(initialCardView)

        initTrustBadge.translatesAutoresizingMaskIntoConstraints = false
        initTrustBadge.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 0.85)
        initTrustBadge.layer.cornerRadius = 6
        initTrustBadge.layer.masksToBounds = true
        initialCardView.addSubview(initTrustBadge)

        initTrustBadgeIcon.translatesAutoresizingMaskIntoConstraints = false
        initTrustBadgeIcon.image = UIImage(systemName: "person.crop.rectangle.fill") ?? UIImage(systemName: "person.fill")
        initTrustBadgeIcon.tintColor = .white
        initTrustBadgeIcon.contentMode = .scaleAspectFit
        initTrustBadge.addSubview(initTrustBadgeIcon)

        initTrustTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        initTrustTitleLabel.attributedText = createRequiredLabel("Trust/Institution code*")
        initialCardView.addSubview(initTrustTitleLabel)

        initTrustCodeField.translatesAutoresizingMaskIntoConstraints = false
        initTrustCodeField.placeholder = "Type your trust code"
        initTrustCodeField.text = "SAT6677"
        initTrustCodeField.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        initTrustCodeField.font = UIFont.systemFont(ofSize: 15.5, weight: .semibold)
        initTrustCodeField.autocapitalizationType = .allCharacters
        initTrustCodeField.autocorrectionType = .no
        initTrustCodeField.delegate = self
        initTrustCodeField.addTarget(self, action: #selector(clearBannerError), for: .editingChanged)
        initialCardView.addSubview(initTrustCodeField)

        initTrustUnderline.translatesAutoresizingMaskIntoConstraints = false
        initTrustUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        initialCardView.addSubview(initTrustUnderline)

        initTrustInfoButton.translatesAutoresizingMaskIntoConstraints = false
        initTrustInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        initTrustInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        initTrustInfoButton.addTarget(self, action: #selector(showTrustInfo), for: .touchUpInside)
        initialCardView.addSubview(initTrustInfoButton)

        initTrustArrowButton.translatesAutoresizingMaskIntoConstraints = false
        initTrustArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        initTrustArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        initTrustArrowButton.addTarget(self, action: #selector(handleTrustCodeSubmit), for: .touchUpInside)
        initialCardView.addSubview(initTrustArrowButton)

        initTrustSpinner.translatesAutoresizingMaskIntoConstraints = false
        initTrustSpinner.hidesWhenStopped = true
        initTrustSpinner.color = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        initialCardView.addSubview(initTrustSpinner)

        initBottomBar.translatesAutoresizingMaskIntoConstraints = false
        initBottomBar.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        initialCardView.addSubview(initBottomBar)

        initCancelButton.translatesAutoresizingMaskIntoConstraints = false
        initCancelButton.setTitle("Cancel", for: .normal)
        initCancelButton.setTitleColor(.white, for: .normal)
        initCancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        initCancelButton.addTarget(self, action: #selector(handleCancelTap), for: .touchUpInside)
        initBottomBar.addSubview(initCancelButton)

        NSLayoutConstraint.activate([
            initialCardView.topAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: 14),
            initialCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            initialCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            initTrustBadge.leadingAnchor.constraint(equalTo: initialCardView.leadingAnchor, constant: 16),
            initTrustBadge.topAnchor.constraint(equalTo: initialCardView.topAnchor, constant: 20),
            initTrustBadge.widthAnchor.constraint(equalToConstant: 34),
            initTrustBadge.heightAnchor.constraint(equalToConstant: 24),

            initTrustBadgeIcon.centerXAnchor.constraint(equalTo: initTrustBadge.centerXAnchor),
            initTrustBadgeIcon.centerYAnchor.constraint(equalTo: initTrustBadge.centerYAnchor),
            initTrustBadgeIcon.widthAnchor.constraint(equalToConstant: 20),
            initTrustBadgeIcon.heightAnchor.constraint(equalToConstant: 16),

            initTrustTitleLabel.leadingAnchor.constraint(equalTo: initTrustBadge.trailingAnchor, constant: 12),
            initTrustTitleLabel.topAnchor.constraint(equalTo: initialCardView.topAnchor, constant: 18),

            initTrustCodeField.leadingAnchor.constraint(equalTo: initTrustBadge.trailingAnchor, constant: 12),
            initTrustCodeField.topAnchor.constraint(equalTo: initTrustTitleLabel.bottomAnchor, constant: 4),
            initTrustCodeField.trailingAnchor.constraint(equalTo: initTrustArrowButton.leadingAnchor, constant: -8),
            initTrustCodeField.heightAnchor.constraint(equalToConstant: 28),

            initTrustUnderline.leadingAnchor.constraint(equalTo: initTrustCodeField.leadingAnchor),
            initTrustUnderline.trailingAnchor.constraint(equalTo: initTrustCodeField.trailingAnchor),
            initTrustUnderline.topAnchor.constraint(equalTo: initTrustCodeField.bottomAnchor, constant: 2),
            initTrustUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            initTrustInfoButton.trailingAnchor.constraint(equalTo: initialCardView.trailingAnchor, constant: -16),
            initTrustInfoButton.centerYAnchor.constraint(equalTo: initTrustCodeField.centerYAnchor),
            initTrustInfoButton.widthAnchor.constraint(equalToConstant: 26),
            initTrustInfoButton.heightAnchor.constraint(equalToConstant: 26),

            initTrustArrowButton.trailingAnchor.constraint(equalTo: initTrustInfoButton.leadingAnchor, constant: -8),
            initTrustArrowButton.centerYAnchor.constraint(equalTo: initTrustCodeField.centerYAnchor),
            initTrustArrowButton.widthAnchor.constraint(equalToConstant: 26),
            initTrustArrowButton.heightAnchor.constraint(equalToConstant: 26),

            initTrustSpinner.centerXAnchor.constraint(equalTo: initTrustArrowButton.centerXAnchor),
            initTrustSpinner.centerYAnchor.constraint(equalTo: initTrustArrowButton.centerYAnchor),

            initBottomBar.topAnchor.constraint(equalTo: initTrustUnderline.bottomAnchor, constant: 22),
            initBottomBar.leadingAnchor.constraint(equalTo: initialCardView.leadingAnchor),
            initBottomBar.trailingAnchor.constraint(equalTo: initialCardView.trailingAnchor),
            initBottomBar.bottomAnchor.constraint(equalTo: initialCardView.bottomAnchor),
            initBottomBar.heightAnchor.constraint(equalToConstant: 54),

            initCancelButton.leadingAnchor.constraint(equalTo: initBottomBar.leadingAnchor, constant: 20),
            initCancelButton.centerYAnchor.constraint(equalTo: initBottomBar.centerYAnchor)
        ])
    }

    // MARK: - Card 2: Mid Progressive Card (Trust -> Email -> Mobile -> Parent Code)
    private func buildMidCard() {
        midCardView.translatesAutoresizingMaskIntoConstraints = false
        midCardView.backgroundColor = .white
        midCardView.layer.cornerRadius = 18
        midCardView.layer.masksToBounds = true
        midCardView.isHidden = true
        contentView.addSubview(midCardView)

        // 1. Trust Row (Verified)
        midTrustRowView.translatesAutoresizingMaskIntoConstraints = false
        midCardView.addSubview(midTrustRowView)

        midTrustBadge.translatesAutoresizingMaskIntoConstraints = false
        midTrustBadge.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 0.85)
        midTrustBadge.layer.cornerRadius = 6
        midTrustBadge.layer.masksToBounds = true
        midTrustRowView.addSubview(midTrustBadge)

        midTrustBadgeIcon.translatesAutoresizingMaskIntoConstraints = false
        midTrustBadgeIcon.image = UIImage(systemName: "person.crop.rectangle.fill") ?? UIImage(systemName: "person.fill")
        midTrustBadgeIcon.tintColor = .white
        midTrustBadgeIcon.contentMode = .scaleAspectFit
        midTrustBadge.addSubview(midTrustBadgeIcon)

        midTrustTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        midTrustTitleLabel.attributedText = createRequiredLabel("Trust/Institution code*")
        midTrustRowView.addSubview(midTrustTitleLabel)

        midTrustCodeField.translatesAutoresizingMaskIntoConstraints = false
        midTrustCodeField.text = "SAT6677"
        midTrustCodeField.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        midTrustCodeField.font = UIFont.systemFont(ofSize: 15.5, weight: .semibold)
        midTrustCodeField.isEnabled = false
        midTrustRowView.addSubview(midTrustCodeField)

        midTrustUnderline.translatesAutoresizingMaskIntoConstraints = false
        midTrustUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        midTrustRowView.addSubview(midTrustUnderline)

        midTrustInfoButton.translatesAutoresizingMaskIntoConstraints = false
        midTrustInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        midTrustInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        midTrustInfoButton.addTarget(self, action: #selector(showTrustInfo), for: .touchUpInside)
        midTrustRowView.addSubview(midTrustInfoButton)

        midTrustArrowButton.translatesAutoresizingMaskIntoConstraints = false
        midTrustArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        midTrustArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        midTrustRowView.addSubview(midTrustArrowButton)

        midTrustCheckmark.translatesAutoresizingMaskIntoConstraints = false
        midTrustCheckmark.image = UIImage(systemName: "checkmark")
        midTrustCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        midTrustRowView.addSubview(midTrustCheckmark)

        // 2. Center Emblem Logo
        midEmblemImageView.translatesAutoresizingMaskIntoConstraints = false
        if let emblem = UIImage(named: "trust_emblem") ?? UIImage(named: "AppIcon-1024") ?? UIImage(named: "AppIcon") {
            midEmblemImageView.image = emblem
        } else {
            midEmblemImageView.image = UIImage(systemName: "seal.fill")
        }
        midEmblemImageView.contentMode = .scaleAspectFit
        midCardView.addSubview(midEmblemImageView)

        // 3. Email Row (Revealed first)
        midEmailRowView.translatesAutoresizingMaskIntoConstraints = false
        midCardView.addSubview(midEmailRowView)

        midEmailIcon.translatesAutoresizingMaskIntoConstraints = false
        midEmailIcon.image = UIImage(systemName: "envelope.fill")
        midEmailIcon.tintColor = UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0)
        midEmailIcon.contentMode = .scaleAspectFit
        midEmailRowView.addSubview(midEmailIcon)

        midEmailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        midEmailTitleLabel.attributedText = createRequiredLabel("Email*")
        midEmailRowView.addSubview(midEmailTitleLabel)

        midEmailField.translatesAutoresizingMaskIntoConstraints = false
        midEmailField.placeholder = "Type your email address"
        midEmailField.text = "dhyey.khanpara26087@gmail.com"
        midEmailField.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        midEmailField.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        midEmailField.keyboardType = .emailAddress
        midEmailField.autocapitalizationType = .none
        midEmailField.autocorrectionType = .no
        midEmailField.delegate = self
        midEmailField.addTarget(self, action: #selector(clearBannerError), for: .editingChanged)
        midEmailRowView.addSubview(midEmailField)

        midEmailUnderline.translatesAutoresizingMaskIntoConstraints = false
        midEmailUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        midEmailRowView.addSubview(midEmailUnderline)

        midEmailInfoButton.translatesAutoresizingMaskIntoConstraints = false
        midEmailInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        midEmailInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        midEmailInfoButton.addTarget(self, action: #selector(showEmailInfo), for: .touchUpInside)
        midEmailRowView.addSubview(midEmailInfoButton)

        midEmailArrowButton.translatesAutoresizingMaskIntoConstraints = false
        midEmailArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        midEmailArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        midEmailArrowButton.addTarget(self, action: #selector(handleEmailVerifyAndRevealMobile), for: .touchUpInside)
        midEmailRowView.addSubview(midEmailArrowButton)

        midEmailCheckmark.translatesAutoresizingMaskIntoConstraints = false
        midEmailCheckmark.image = UIImage(systemName: "checkmark")
        midEmailCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        midEmailCheckmark.isHidden = true
        midEmailRowView.addSubview(midEmailCheckmark)

        midEmailSpinner.translatesAutoresizingMaskIntoConstraints = false
        midEmailSpinner.hidesWhenStopped = true
        midEmailSpinner.color = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        midEmailRowView.addSubview(midEmailSpinner)

        // 4. Mobile Row (Revealed after Email verified)
        midMobileRowView.translatesAutoresizingMaskIntoConstraints = false
        midMobileRowView.isHidden = true
        midCardView.addSubview(midMobileRowView)

        midMobileIcon.translatesAutoresizingMaskIntoConstraints = false
        midMobileIcon.image = UIImage(systemName: "hand.tap.fill") ?? UIImage(systemName: "phone.fill")
        midMobileIcon.tintColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1.0)
        midMobileIcon.contentMode = .scaleAspectFit
        midMobileRowView.addSubview(midMobileIcon)

        midMobileTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        midMobileTitleLabel.attributedText = createRequiredLabel("Mobile phone*")
        midMobileRowView.addSubview(midMobileTitleLabel)

        midMobileField.translatesAutoresizingMaskIntoConstraints = false
        midMobileField.placeholder = "Type your 10-digit mobile"
        midMobileField.text = "7894562130"
        midMobileField.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        midMobileField.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        midMobileField.keyboardType = .phonePad
        midMobileField.delegate = self
        midMobileField.addTarget(self, action: #selector(clearBannerError), for: .editingChanged)
        midMobileRowView.addSubview(midMobileField)

        midMobileUnderline.translatesAutoresizingMaskIntoConstraints = false
        midMobileUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        midMobileRowView.addSubview(midMobileUnderline)

        midMobileInfoButton.translatesAutoresizingMaskIntoConstraints = false
        midMobileInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        midMobileInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        midMobileInfoButton.addTarget(self, action: #selector(showMobileInfo), for: .touchUpInside)
        midMobileRowView.addSubview(midMobileInfoButton)

        midMobileArrowButton.translatesAutoresizingMaskIntoConstraints = false
        midMobileArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        midMobileArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        midMobileArrowButton.addTarget(self, action: #selector(handleMobileSubmitAndSendOTP), for: .touchUpInside)
        midMobileRowView.addSubview(midMobileArrowButton)

        midMobileCheckmark.translatesAutoresizingMaskIntoConstraints = false
        midMobileCheckmark.image = UIImage(systemName: "checkmark")
        midMobileCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        midMobileCheckmark.isHidden = true
        midMobileRowView.addSubview(midMobileCheckmark)

        midMobileSpinner.translatesAutoresizingMaskIntoConstraints = false
        midMobileSpinner.hidesWhenStopped = true
        midMobileSpinner.color = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        midMobileRowView.addSubview(midMobileSpinner)

        // 5. Parent Code Row (Revealed after OTP verified)
        midParentRowView.translatesAutoresizingMaskIntoConstraints = false
        midParentRowView.isHidden = true
        midCardView.addSubview(midParentRowView)

        midParentIcon.translatesAutoresizingMaskIntoConstraints = false
        midParentIcon.image = UIImage(systemName: "person.crop.circle.badge.checkmark") ?? UIImage(systemName: "person.fill")
        midParentIcon.tintColor = UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0)
        midParentIcon.contentMode = .scaleAspectFit
        midParentRowView.addSubview(midParentIcon)

        midParentTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        midParentTitleLabel.attributedText = createRequiredLabel("Enter Main/Parent Branch Code#")
        midParentRowView.addSubview(midParentTitleLabel)

        midParentCodeField.translatesAutoresizingMaskIntoConstraints = false
        midParentCodeField.placeholder = "0001"
        midParentCodeField.text = "0001"
        midParentCodeField.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        midParentCodeField.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        midParentCodeField.keyboardType = .asciiCapable
        midParentCodeField.delegate = self
        midParentCodeField.addTarget(self, action: #selector(clearBannerError), for: .editingChanged)
        midParentRowView.addSubview(midParentCodeField)

        midParentUnderline.translatesAutoresizingMaskIntoConstraints = false
        midParentUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        midParentRowView.addSubview(midParentUnderline)

        midParentInfoButton.translatesAutoresizingMaskIntoConstraints = false
        midParentInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        midParentInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        midParentInfoButton.addTarget(self, action: #selector(showParentInfo), for: .touchUpInside)
        midParentRowView.addSubview(midParentInfoButton)

        midParentArrowButton.translatesAutoresizingMaskIntoConstraints = false
        midParentArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        midParentArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        midParentArrowButton.addTarget(self, action: #selector(handleParentCodeSubmitAndOpenDetails), for: .touchUpInside)
        midParentRowView.addSubview(midParentArrowButton)

        midParentCheckmark.translatesAutoresizingMaskIntoConstraints = false
        midParentCheckmark.image = UIImage(systemName: "checkmark")
        midParentCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        midParentCheckmark.isHidden = true
        midParentRowView.addSubview(midParentCheckmark)

        midParentSpinner.translatesAutoresizingMaskIntoConstraints = false
        midParentSpinner.hidesWhenStopped = true
        midParentSpinner.color = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        midParentRowView.addSubview(midParentSpinner)

        // Mid Bottom Bar
        midBottomBar.translatesAutoresizingMaskIntoConstraints = false
        midBottomBar.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        midCardView.addSubview(midBottomBar)

        midCancelButton.translatesAutoresizingMaskIntoConstraints = false
        midCancelButton.setTitle("Cancel", for: .normal)
        midCancelButton.setTitleColor(.white, for: .normal)
        midCancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        midCancelButton.addTarget(self, action: #selector(handleCancelTap), for: .touchUpInside)
        midBottomBar.addSubview(midCancelButton)

        // Setup dynamic bottom bar constraints
        midEmailToBottomConstraint = midBottomBar.topAnchor.constraint(equalTo: midEmailRowView.bottomAnchor, constant: 20)
        midMobileToBottomConstraint = midBottomBar.topAnchor.constraint(equalTo: midMobileRowView.bottomAnchor, constant: 20)
        midParentToBottomConstraint = midBottomBar.topAnchor.constraint(equalTo: midParentRowView.bottomAnchor, constant: 20)

        midEmailToBottomConstraint?.isActive = true // Default state in Card 2

        NSLayoutConstraint.activate([
            midCardView.topAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: 14),
            midCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            midCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // 1. Trust Row
            midTrustRowView.topAnchor.constraint(equalTo: midCardView.topAnchor, constant: 18),
            midTrustRowView.leadingAnchor.constraint(equalTo: midCardView.leadingAnchor, constant: 16),
            midTrustRowView.trailingAnchor.constraint(equalTo: midCardView.trailingAnchor, constant: -16),

            midTrustBadge.leadingAnchor.constraint(equalTo: midTrustRowView.leadingAnchor),
            midTrustBadge.topAnchor.constraint(equalTo: midTrustRowView.topAnchor, constant: 2),
            midTrustBadge.widthAnchor.constraint(equalToConstant: 34),
            midTrustBadge.heightAnchor.constraint(equalToConstant: 24),

            midTrustBadgeIcon.centerXAnchor.constraint(equalTo: midTrustBadge.centerXAnchor),
            midTrustBadgeIcon.centerYAnchor.constraint(equalTo: midTrustBadge.centerYAnchor),
            midTrustBadgeIcon.widthAnchor.constraint(equalToConstant: 20),
            midTrustBadgeIcon.heightAnchor.constraint(equalToConstant: 16),

            midTrustTitleLabel.leadingAnchor.constraint(equalTo: midTrustBadge.trailingAnchor, constant: 12),
            midTrustTitleLabel.topAnchor.constraint(equalTo: midTrustRowView.topAnchor),

            midTrustInfoButton.trailingAnchor.constraint(equalTo: midTrustRowView.trailingAnchor),
            midTrustInfoButton.centerYAnchor.constraint(equalTo: midTrustCodeField.centerYAnchor),
            midTrustInfoButton.widthAnchor.constraint(equalToConstant: 26),
            midTrustInfoButton.heightAnchor.constraint(equalToConstant: 26),

            midTrustArrowButton.trailingAnchor.constraint(equalTo: midTrustInfoButton.leadingAnchor, constant: -6),
            midTrustArrowButton.centerYAnchor.constraint(equalTo: midTrustCodeField.centerYAnchor),
            midTrustArrowButton.widthAnchor.constraint(equalToConstant: 26),
            midTrustArrowButton.heightAnchor.constraint(equalToConstant: 26),

            midTrustCheckmark.trailingAnchor.constraint(equalTo: midTrustArrowButton.leadingAnchor, constant: -6),
            midTrustCheckmark.centerYAnchor.constraint(equalTo: midTrustCodeField.centerYAnchor),
            midTrustCheckmark.widthAnchor.constraint(equalToConstant: 20),
            midTrustCheckmark.heightAnchor.constraint(equalToConstant: 20),

            midTrustCodeField.leadingAnchor.constraint(equalTo: midTrustBadge.trailingAnchor, constant: 12),
            midTrustCodeField.topAnchor.constraint(equalTo: midTrustTitleLabel.bottomAnchor, constant: 4),
            midTrustCodeField.trailingAnchor.constraint(equalTo: midTrustCheckmark.leadingAnchor, constant: -8),
            midTrustCodeField.heightAnchor.constraint(equalToConstant: 28),

            midTrustUnderline.leadingAnchor.constraint(equalTo: midTrustCodeField.leadingAnchor),
            midTrustUnderline.trailingAnchor.constraint(equalTo: midTrustCodeField.trailingAnchor),
            midTrustUnderline.topAnchor.constraint(equalTo: midTrustCodeField.bottomAnchor, constant: 2),
            midTrustUnderline.heightAnchor.constraint(equalToConstant: 1.5),
            midTrustUnderline.bottomAnchor.constraint(equalTo: midTrustRowView.bottomAnchor),

            // 2. Emblem Logo
            midEmblemImageView.topAnchor.constraint(equalTo: midTrustRowView.bottomAnchor, constant: 14),
            midEmblemImageView.centerXAnchor.constraint(equalTo: midCardView.centerXAnchor),
            midEmblemImageView.widthAnchor.constraint(equalToConstant: 125),
            midEmblemImageView.heightAnchor.constraint(equalToConstant: 125),

            // 3. Email Row
            midEmailRowView.topAnchor.constraint(equalTo: midEmblemImageView.bottomAnchor, constant: 14),
            midEmailRowView.leadingAnchor.constraint(equalTo: midCardView.leadingAnchor, constant: 16),
            midEmailRowView.trailingAnchor.constraint(equalTo: midCardView.trailingAnchor, constant: -16),

            midEmailIcon.leadingAnchor.constraint(equalTo: midEmailRowView.leadingAnchor),
            midEmailIcon.topAnchor.constraint(equalTo: midEmailRowView.topAnchor, constant: 4),
            midEmailIcon.widthAnchor.constraint(equalToConstant: 24),
            midEmailIcon.heightAnchor.constraint(equalToConstant: 22),

            midEmailTitleLabel.leadingAnchor.constraint(equalTo: midEmailIcon.trailingAnchor, constant: 12),
            midEmailTitleLabel.topAnchor.constraint(equalTo: midEmailRowView.topAnchor),

            midEmailInfoButton.trailingAnchor.constraint(equalTo: midEmailRowView.trailingAnchor),
            midEmailInfoButton.centerYAnchor.constraint(equalTo: midEmailField.centerYAnchor),
            midEmailInfoButton.widthAnchor.constraint(equalToConstant: 26),
            midEmailInfoButton.heightAnchor.constraint(equalToConstant: 26),

            midEmailArrowButton.trailingAnchor.constraint(equalTo: midEmailInfoButton.leadingAnchor, constant: -6),
            midEmailArrowButton.centerYAnchor.constraint(equalTo: midEmailField.centerYAnchor),
            midEmailArrowButton.widthAnchor.constraint(equalToConstant: 26),
            midEmailArrowButton.heightAnchor.constraint(equalToConstant: 26),

            midEmailCheckmark.trailingAnchor.constraint(equalTo: midEmailArrowButton.leadingAnchor, constant: -6),
            midEmailCheckmark.centerYAnchor.constraint(equalTo: midEmailField.centerYAnchor),
            midEmailCheckmark.widthAnchor.constraint(equalToConstant: 20),
            midEmailCheckmark.heightAnchor.constraint(equalToConstant: 20),

            midEmailField.leadingAnchor.constraint(equalTo: midEmailIcon.trailingAnchor, constant: 12),
            midEmailField.topAnchor.constraint(equalTo: midEmailTitleLabel.bottomAnchor, constant: 4),
            midEmailField.trailingAnchor.constraint(equalTo: midEmailCheckmark.leadingAnchor, constant: -8),
            midEmailField.heightAnchor.constraint(equalToConstant: 28),

            midEmailUnderline.leadingAnchor.constraint(equalTo: midEmailField.leadingAnchor),
            midEmailUnderline.trailingAnchor.constraint(equalTo: midEmailField.trailingAnchor),
            midEmailUnderline.topAnchor.constraint(equalTo: midEmailField.bottomAnchor, constant: 2),
            midEmailUnderline.heightAnchor.constraint(equalToConstant: 1.5),
            midEmailUnderline.bottomAnchor.constraint(equalTo: midEmailRowView.bottomAnchor),

            midEmailSpinner.centerXAnchor.constraint(equalTo: midEmailArrowButton.centerXAnchor),
            midEmailSpinner.centerYAnchor.constraint(equalTo: midEmailArrowButton.centerYAnchor),

            // 4. Mobile Row
            midMobileRowView.topAnchor.constraint(equalTo: midEmailRowView.bottomAnchor, constant: 14),
            midMobileRowView.leadingAnchor.constraint(equalTo: midCardView.leadingAnchor, constant: 16),
            midMobileRowView.trailingAnchor.constraint(equalTo: midCardView.trailingAnchor, constant: -16),

            midMobileIcon.leadingAnchor.constraint(equalTo: midMobileRowView.leadingAnchor),
            midMobileIcon.topAnchor.constraint(equalTo: midMobileRowView.topAnchor, constant: 4),
            midMobileIcon.widthAnchor.constraint(equalToConstant: 24),
            midMobileIcon.heightAnchor.constraint(equalToConstant: 22),

            midMobileTitleLabel.leadingAnchor.constraint(equalTo: midMobileIcon.trailingAnchor, constant: 12),
            midMobileTitleLabel.topAnchor.constraint(equalTo: midMobileRowView.topAnchor),

            midMobileInfoButton.trailingAnchor.constraint(equalTo: midMobileRowView.trailingAnchor),
            midMobileInfoButton.centerYAnchor.constraint(equalTo: midMobileField.centerYAnchor),
            midMobileInfoButton.widthAnchor.constraint(equalToConstant: 26),
            midMobileInfoButton.heightAnchor.constraint(equalToConstant: 26),

            midMobileArrowButton.trailingAnchor.constraint(equalTo: midMobileInfoButton.leadingAnchor, constant: -6),
            midMobileArrowButton.centerYAnchor.constraint(equalTo: midMobileField.centerYAnchor),
            midMobileArrowButton.widthAnchor.constraint(equalToConstant: 26),
            midMobileArrowButton.heightAnchor.constraint(equalToConstant: 26),

            midMobileCheckmark.trailingAnchor.constraint(equalTo: midMobileArrowButton.leadingAnchor, constant: -6),
            midMobileCheckmark.centerYAnchor.constraint(equalTo: midMobileField.centerYAnchor),
            midMobileCheckmark.widthAnchor.constraint(equalToConstant: 20),
            midMobileCheckmark.heightAnchor.constraint(equalToConstant: 20),

            midMobileField.leadingAnchor.constraint(equalTo: midMobileIcon.trailingAnchor, constant: 12),
            midMobileField.topAnchor.constraint(equalTo: midMobileTitleLabel.bottomAnchor, constant: 4),
            midMobileField.trailingAnchor.constraint(equalTo: midMobileCheckmark.leadingAnchor, constant: -8),
            midMobileField.heightAnchor.constraint(equalToConstant: 28),

            midMobileUnderline.leadingAnchor.constraint(equalTo: midMobileField.leadingAnchor),
            midMobileUnderline.trailingAnchor.constraint(equalTo: midMobileField.trailingAnchor),
            midMobileUnderline.topAnchor.constraint(equalTo: midMobileField.bottomAnchor, constant: 2),
            midMobileUnderline.heightAnchor.constraint(equalToConstant: 1.5),
            midMobileUnderline.bottomAnchor.constraint(equalTo: midMobileRowView.bottomAnchor),

            midMobileSpinner.centerXAnchor.constraint(equalTo: midMobileArrowButton.centerXAnchor),
            midMobileSpinner.centerYAnchor.constraint(equalTo: midMobileArrowButton.centerYAnchor),

            // 5. Parent Code Row
            midParentRowView.topAnchor.constraint(equalTo: midMobileRowView.bottomAnchor, constant: 14),
            midParentRowView.leadingAnchor.constraint(equalTo: midCardView.leadingAnchor, constant: 16),
            midParentRowView.trailingAnchor.constraint(equalTo: midCardView.trailingAnchor, constant: -16),

            midParentIcon.leadingAnchor.constraint(equalTo: midParentRowView.leadingAnchor),
            midParentIcon.topAnchor.constraint(equalTo: midParentRowView.topAnchor, constant: 4),
            midParentIcon.widthAnchor.constraint(equalToConstant: 24),
            midParentIcon.heightAnchor.constraint(equalToConstant: 22),

            midParentTitleLabel.leadingAnchor.constraint(equalTo: midParentIcon.trailingAnchor, constant: 12),
            midParentTitleLabel.topAnchor.constraint(equalTo: midParentRowView.topAnchor),

            midParentInfoButton.trailingAnchor.constraint(equalTo: midParentRowView.trailingAnchor),
            midParentInfoButton.centerYAnchor.constraint(equalTo: midParentCodeField.centerYAnchor),
            midParentInfoButton.widthAnchor.constraint(equalToConstant: 26),
            midParentInfoButton.heightAnchor.constraint(equalToConstant: 26),

            midParentArrowButton.trailingAnchor.constraint(equalTo: midParentInfoButton.leadingAnchor, constant: -6),
            midParentArrowButton.centerYAnchor.constraint(equalTo: midParentCodeField.centerYAnchor),
            midParentArrowButton.widthAnchor.constraint(equalToConstant: 26),
            midParentArrowButton.heightAnchor.constraint(equalToConstant: 26),

            midParentCheckmark.trailingAnchor.constraint(equalTo: midParentArrowButton.leadingAnchor, constant: -6),
            midParentCheckmark.centerYAnchor.constraint(equalTo: midParentCodeField.centerYAnchor),
            midParentCheckmark.widthAnchor.constraint(equalToConstant: 20),
            midParentCheckmark.heightAnchor.constraint(equalToConstant: 20),

            midParentCodeField.leadingAnchor.constraint(equalTo: midParentIcon.trailingAnchor, constant: 12),
            midParentCodeField.topAnchor.constraint(equalTo: midParentTitleLabel.bottomAnchor, constant: 4),
            midParentCodeField.trailingAnchor.constraint(equalTo: midParentCheckmark.leadingAnchor, constant: -8),
            midParentCodeField.heightAnchor.constraint(equalToConstant: 28),

            midParentUnderline.leadingAnchor.constraint(equalTo: midParentCodeField.leadingAnchor),
            midParentUnderline.trailingAnchor.constraint(equalTo: midParentCodeField.trailingAnchor),
            midParentUnderline.topAnchor.constraint(equalTo: midParentCodeField.bottomAnchor, constant: 2),
            midParentUnderline.heightAnchor.constraint(equalToConstant: 1.5),
            midParentUnderline.bottomAnchor.constraint(equalTo: midParentRowView.bottomAnchor),

            midParentSpinner.centerXAnchor.constraint(equalTo: midParentArrowButton.centerXAnchor),
            midParentSpinner.centerYAnchor.constraint(equalTo: midParentArrowButton.centerYAnchor),

            // Mid Bottom Bar
            midBottomBar.leadingAnchor.constraint(equalTo: midCardView.leadingAnchor),
            midBottomBar.trailingAnchor.constraint(equalTo: midCardView.trailingAnchor),
            midBottomBar.bottomAnchor.constraint(equalTo: midCardView.bottomAnchor),
            midBottomBar.heightAnchor.constraint(equalToConstant: 54),

            midCancelButton.leadingAnchor.constraint(equalTo: midBottomBar.leadingAnchor, constant: 20),
            midCancelButton.centerYAnchor.constraint(equalTo: midBottomBar.centerYAnchor)
        ])
    }

    // MARK: - Card 3: Full User Details Card (Screenshot 1 & 2)
    private func buildDetailsCard() {
        detailsCardView.translatesAutoresizingMaskIntoConstraints = false
        detailsCardView.backgroundColor = .white
        detailsCardView.layer.cornerRadius = 18
        detailsCardView.layer.masksToBounds = true
        detailsCardView.isHidden = true
        contentView.addSubview(detailsCardView)

        // 1. Trust Code Row
        buildDetailRow(container: dtTrustRow, iconView: dtTrustBadgeIcon, iconWrapper: dtTrustBadge, isBadge: true, label: dtTrustTitleLabel, title: "Trust/Institution code*", field: dtTrustCodeField, text: "SAT6677", underline: dtTrustUnderline, isEnabled: false)
        dtTrustCheckmark.translatesAutoresizingMaskIntoConstraints = false
        dtTrustCheckmark.image = UIImage(systemName: "checkmark")
        dtTrustCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        dtTrustRow.addSubview(dtTrustCheckmark)

        dtTrustArrowButton.translatesAutoresizingMaskIntoConstraints = false
        dtTrustArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        dtTrustArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        dtTrustRow.addSubview(dtTrustArrowButton)

        dtTrustInfoButton.translatesAutoresizingMaskIntoConstraints = false
        dtTrustInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        dtTrustInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        dtTrustInfoButton.addTarget(self, action: #selector(showTrustInfo), for: .touchUpInside)
        dtTrustRow.addSubview(dtTrustInfoButton)

        NSLayoutConstraint.activate([
            dtTrustInfoButton.trailingAnchor.constraint(equalTo: dtTrustRow.trailingAnchor),
            dtTrustInfoButton.centerYAnchor.constraint(equalTo: dtTrustCodeField.centerYAnchor),
            dtTrustInfoButton.widthAnchor.constraint(equalToConstant: 26),
            dtTrustInfoButton.heightAnchor.constraint(equalToConstant: 26),

            dtTrustArrowButton.trailingAnchor.constraint(equalTo: dtTrustInfoButton.leadingAnchor, constant: -6),
            dtTrustArrowButton.centerYAnchor.constraint(equalTo: dtTrustCodeField.centerYAnchor),
            dtTrustArrowButton.widthAnchor.constraint(equalToConstant: 26),
            dtTrustArrowButton.heightAnchor.constraint(equalToConstant: 26),

            dtTrustCheckmark.trailingAnchor.constraint(equalTo: dtTrustArrowButton.leadingAnchor, constant: -6),
            dtTrustCheckmark.centerYAnchor.constraint(equalTo: dtTrustCodeField.centerYAnchor),
            dtTrustCheckmark.widthAnchor.constraint(equalToConstant: 20),
            dtTrustCheckmark.heightAnchor.constraint(equalToConstant: 20),

            dtTrustCodeField.trailingAnchor.constraint(equalTo: dtTrustCheckmark.leadingAnchor, constant: -8)
        ])
        detailsCardView.addSubview(dtTrustRow)

        // 2. Title*
        buildDetailRow(container: dtTitleRow, iconView: dtTitleIcon, iconName: "person.crop.circle.fill", iconColor: UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0), label: dtTitleLabel, title: "Title*", field: dtTitleField, placeholder: "Choose Title", underline: dtTitleUnderline)
        dtTitleField.text = selectedTitle
        let titleTap = UITapGestureRecognizer(target: self, action: #selector(presentTitlePickerSheet))
        dtTitleField.addGestureRecognizer(titleTap)
        dtTitleField.isUserInteractionEnabled = true
        detailsCardView.addSubview(dtTitleRow)

        // 3. First Name*
        buildDetailRow(container: dtFnameRow, iconView: dtFnameIcon, iconName: "person.fill", iconColor: UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0), label: dtFnameLabel, title: "First Name*", field: dtFnameField, placeholder: "Type your First Name", underline: dtFnameUnderline)
        detailsCardView.addSubview(dtFnameRow)

        // 4. Last Name*
        buildDetailRow(container: dtLnameRow, iconView: dtLnameIcon, iconName: "person.fill", iconColor: UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0), label: dtLnameLabel, title: "Last Name*", field: dtLnameField, placeholder: "Type your Last Name", underline: dtLnameUnderline)
        detailsCardView.addSubview(dtLnameRow)

        // 5. Password*
        buildDetailRow(container: dtPasswordRow, iconView: dtPasswordIcon, iconName: "lock.fill", iconColor: UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0), label: dtPasswordLabel, title: "Password*", field: dtPasswordField, placeholder: "Type Your Password", underline: dtPasswordUnderline, hasCustomTrailing: true)
        dtPasswordField.isSecureTextEntry = true
        dtShowPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        dtShowPasswordButton.setTitle("Show", for: .normal)
        dtShowPasswordButton.setTitleColor(UIColor(red: 100/255, green: 110/255, blue: 120/255, alpha: 1.0), for: .normal)
        dtShowPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        dtShowPasswordButton.addTarget(self, action: #selector(toggleShowPassword), for: .touchUpInside)
        dtPasswordRow.addSubview(dtShowPasswordButton)
        NSLayoutConstraint.activate([
            dtShowPasswordButton.trailingAnchor.constraint(equalTo: dtPasswordRow.trailingAnchor),
            dtShowPasswordButton.centerYAnchor.constraint(equalTo: dtPasswordField.centerYAnchor),
            dtShowPasswordButton.widthAnchor.constraint(equalToConstant: 44),
            dtPasswordField.trailingAnchor.constraint(equalTo: dtShowPasswordButton.leadingAnchor, constant: -8)
        ])
        detailsCardView.addSubview(dtPasswordRow)

        // 6. Center Emblem Logo
        dtEmblemImageView.translatesAutoresizingMaskIntoConstraints = false
        if let emblem = UIImage(named: "trust_emblem") ?? UIImage(named: "AppIcon-1024") ?? UIImage(named: "AppIcon") {
            dtEmblemImageView.image = emblem
        } else {
            dtEmblemImageView.image = UIImage(systemName: "seal.fill")
        }
        dtEmblemImageView.contentMode = .scaleAspectFit
        detailsCardView.addSubview(dtEmblemImageView)

        // 7. Email*
        buildDetailRow(container: dtEmailRow, iconView: dtEmailIcon, iconName: "envelope.fill", iconColor: UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0), label: dtEmailLabel, title: "Email*", field: dtEmailField, text: "dhyey.khanpara26087@gmail.com", underline: dtEmailUnderline, hasCustomTrailing: true)
        dtEmailCheckmark.translatesAutoresizingMaskIntoConstraints = false
        dtEmailCheckmark.image = UIImage(systemName: "checkmark")
        dtEmailCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        dtEmailRow.addSubview(dtEmailCheckmark)
        NSLayoutConstraint.activate([
            dtEmailCheckmark.trailingAnchor.constraint(equalTo: dtEmailRow.trailingAnchor),
            dtEmailCheckmark.centerYAnchor.constraint(equalTo: dtEmailField.centerYAnchor),
            dtEmailCheckmark.widthAnchor.constraint(equalToConstant: 20),
            dtEmailCheckmark.heightAnchor.constraint(equalToConstant: 20),
            dtEmailField.trailingAnchor.constraint(equalTo: dtEmailCheckmark.leadingAnchor, constant: -8)
        ])
        detailsCardView.addSubview(dtEmailRow)

        // 8. Mobile phone*
        buildDetailRow(container: dtMobileRow, iconView: dtMobileIcon, iconName: "hand.tap.fill", iconColor: UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1.0), label: dtMobileLabel, title: "Mobile phone*", field: dtMobileField, text: "7894562130", underline: dtMobileUnderline, hasCustomTrailing: true)
        dtMobileInfoButton.translatesAutoresizingMaskIntoConstraints = false
        dtMobileInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        dtMobileInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        dtMobileInfoButton.addTarget(self, action: #selector(showMobileInfo), for: .touchUpInside)
        dtMobileRow.addSubview(dtMobileInfoButton)

        dtMobileArrowButton.translatesAutoresizingMaskIntoConstraints = false
        dtMobileArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        dtMobileArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        dtMobileRow.addSubview(dtMobileArrowButton)

        dtMobileCheckmark.translatesAutoresizingMaskIntoConstraints = false
        dtMobileCheckmark.image = UIImage(systemName: "checkmark")
        dtMobileCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        dtMobileRow.addSubview(dtMobileCheckmark)

        NSLayoutConstraint.activate([
            dtMobileInfoButton.trailingAnchor.constraint(equalTo: dtMobileRow.trailingAnchor),
            dtMobileInfoButton.centerYAnchor.constraint(equalTo: dtMobileField.centerYAnchor),
            dtMobileInfoButton.widthAnchor.constraint(equalToConstant: 26),
            dtMobileInfoButton.heightAnchor.constraint(equalToConstant: 26),

            dtMobileArrowButton.trailingAnchor.constraint(equalTo: dtMobileInfoButton.leadingAnchor, constant: -6),
            dtMobileArrowButton.centerYAnchor.constraint(equalTo: dtMobileField.centerYAnchor),
            dtMobileArrowButton.widthAnchor.constraint(equalToConstant: 26),
            dtMobileArrowButton.heightAnchor.constraint(equalToConstant: 26),

            dtMobileCheckmark.trailingAnchor.constraint(equalTo: dtMobileArrowButton.leadingAnchor, constant: -6),
            dtMobileCheckmark.centerYAnchor.constraint(equalTo: dtMobileField.centerYAnchor),
            dtMobileCheckmark.widthAnchor.constraint(equalToConstant: 20),
            dtMobileCheckmark.heightAnchor.constraint(equalToConstant: 20),

            dtMobileField.trailingAnchor.constraint(equalTo: dtMobileCheckmark.leadingAnchor, constant: -8)
        ])
        detailsCardView.addSubview(dtMobileRow)

        // 9. Mobile phone # for OTP
        buildDetailRow(container: dtOtpMobileRow, iconView: dtOtpMobileIcon, iconName: "hand.tap.fill", iconColor: UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1.0), label: dtOtpMobileLabel, title: "Mobile phone # for OTP", field: dtOtpMobileField, text: "7894562130", underline: dtOtpMobileUnderline)
        detailsCardView.addSubview(dtOtpMobileRow)

        // 10. Gender
        dtGenderRow.translatesAutoresizingMaskIntoConstraints = false
        dtGenderIcon.translatesAutoresizingMaskIntoConstraints = false
        dtGenderIcon.image = UIImage(systemName: "person.crop.circle.fill")
        dtGenderIcon.tintColor = UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0)
        dtGenderIcon.contentMode = .scaleAspectFit
        dtGenderRow.addSubview(dtGenderIcon)

        dtGenderLabel.translatesAutoresizingMaskIntoConstraints = false
        dtGenderLabel.text = "Gender"
        dtGenderLabel.textColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        dtGenderLabel.font = UIFont.systemFont(ofSize: 14.5, weight: .bold)
        dtGenderRow.addSubview(dtGenderLabel)

        dtMaleRadioButton.translatesAutoresizingMaskIntoConstraints = false
        dtMaleRadioButton.setTitle(" 🔘 Male", for: .normal)
        dtMaleRadioButton.setTitleColor(UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0), for: .normal)
        dtMaleRadioButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        dtMaleRadioButton.addTarget(self, action: #selector(selectMale), for: .touchUpInside)
        dtGenderRow.addSubview(dtMaleRadioButton)

        dtFemaleRadioButton.translatesAutoresizingMaskIntoConstraints = false
        dtFemaleRadioButton.setTitle(" ⚪ Female", for: .normal)
        dtFemaleRadioButton.setTitleColor(UIColor(red: 100/255, green: 110/255, blue: 120/255, alpha: 1.0), for: .normal)
        dtFemaleRadioButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        dtFemaleRadioButton.addTarget(self, action: #selector(selectFemale), for: .touchUpInside)
        dtGenderRow.addSubview(dtFemaleRadioButton)

        NSLayoutConstraint.activate([
            dtGenderIcon.leadingAnchor.constraint(equalTo: dtGenderRow.leadingAnchor),
            dtGenderIcon.centerYAnchor.constraint(equalTo: dtGenderRow.centerYAnchor),
            dtGenderIcon.widthAnchor.constraint(equalToConstant: 24),
            dtGenderIcon.heightAnchor.constraint(equalToConstant: 22),

            dtGenderLabel.leadingAnchor.constraint(equalTo: dtGenderIcon.trailingAnchor, constant: 12),
            dtGenderLabel.centerYAnchor.constraint(equalTo: dtGenderRow.centerYAnchor),

            dtMaleRadioButton.leadingAnchor.constraint(equalTo: dtGenderLabel.trailingAnchor, constant: 16),
            dtMaleRadioButton.centerYAnchor.constraint(equalTo: dtGenderRow.centerYAnchor),

            dtFemaleRadioButton.leadingAnchor.constraint(equalTo: dtMaleRadioButton.trailingAnchor, constant: 16),
            dtFemaleRadioButton.centerYAnchor.constraint(equalTo: dtGenderRow.centerYAnchor),
            dtFemaleRadioButton.trailingAnchor.constraint(lessThanOrEqualTo: dtGenderRow.trailingAnchor)
        ])
        detailsCardView.addSubview(dtGenderRow)

        // 11. Enter Main/Parent Branch Code#
        buildDetailRow(container: dtParentRow, iconView: dtParentIcon, iconName: "person.crop.circle.badge.checkmark", iconColor: UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0), label: dtParentLabel, title: "Enter Main/Parent Branch Code#", field: dtParentCodeField, text: "0001", underline: dtParentUnderline, hasCustomTrailing: true)
        dtParentInfoButton.translatesAutoresizingMaskIntoConstraints = false
        dtParentInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        dtParentInfoButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        dtParentInfoButton.addTarget(self, action: #selector(showParentInfo), for: .touchUpInside)
        dtParentRow.addSubview(dtParentInfoButton)

        dtParentArrowButton.translatesAutoresizingMaskIntoConstraints = false
        dtParentArrowButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        dtParentArrowButton.tintColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        dtParentRow.addSubview(dtParentArrowButton)

        dtParentCheckmark.translatesAutoresizingMaskIntoConstraints = false
        dtParentCheckmark.image = UIImage(systemName: "checkmark")
        dtParentCheckmark.tintColor = UIColor(red: 40/255, green: 183/255, blue: 121/255, alpha: 1.0)
        dtParentRow.addSubview(dtParentCheckmark)

        NSLayoutConstraint.activate([
            dtParentInfoButton.trailingAnchor.constraint(equalTo: dtParentRow.trailingAnchor),
            dtParentInfoButton.centerYAnchor.constraint(equalTo: dtParentCodeField.centerYAnchor),
            dtParentInfoButton.widthAnchor.constraint(equalToConstant: 26),
            dtParentInfoButton.heightAnchor.constraint(equalToConstant: 26),

            dtParentArrowButton.trailingAnchor.constraint(equalTo: dtParentInfoButton.leadingAnchor, constant: -6),
            dtParentArrowButton.centerYAnchor.constraint(equalTo: dtParentCodeField.centerYAnchor),
            dtParentArrowButton.widthAnchor.constraint(equalToConstant: 26),
            dtParentArrowButton.heightAnchor.constraint(equalToConstant: 26),

            dtParentCheckmark.trailingAnchor.constraint(equalTo: dtParentArrowButton.leadingAnchor, constant: -6),
            dtParentCheckmark.centerYAnchor.constraint(equalTo: dtParentCodeField.centerYAnchor),
            dtParentCheckmark.widthAnchor.constraint(equalToConstant: 20),
            dtParentCheckmark.heightAnchor.constraint(equalToConstant: 20),

            dtParentCodeField.trailingAnchor.constraint(equalTo: dtParentCheckmark.leadingAnchor, constant: -8)
        ])
        detailsCardView.addSubview(dtParentRow)

        // 12. Id Document
        buildDetailRow(container: dtIdDocRow, iconView: dtIdDocIcon, iconName: "person.crop.circle.fill", iconColor: UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0), label: dtIdDocLabel, title: "Id Document", field: dtIdDocField, placeholder: "Choose Id Document", underline: dtIdDocUnderline)
        dtIdDocField.text = selectedIdDocument
        let idDocTap = UITapGestureRecognizer(target: self, action: #selector(presentIdDocumentPickerSheet))
        dtIdDocField.addGestureRecognizer(idDocTap)
        dtIdDocField.isUserInteractionEnabled = true
        detailsCardView.addSubview(dtIdDocRow)

        // 13. Government Id Number
        buildDetailRow(container: dtGovtIdRow, iconView: dtGovtIdIcon, iconName: "person.crop.circle.fill", iconColor: UIColor(red: 255/255, green: 184/255, blue: 72/255, alpha: 1.0), label: dtGovtIdLabel, title: "Government Id Number", field: dtGovtIdField, placeholder: "Choose Government Id Number", underline: dtGovtIdUnderline)
        detailsCardView.addSubview(dtGovtIdRow)

        // 14. Document Upload Box (Dotted gray box)
        dtUploadBox.translatesAutoresizingMaskIntoConstraints = false
        dtUploadBox.backgroundColor = UIColor(red: 245/255, green: 247/255, blue: 250/255, alpha: 1.0)
        dtUploadBox.layer.cornerRadius = 6
        dtUploadBox.layer.borderWidth = 1.2
        dtUploadBox.layer.borderColor = UIColor(red: 210/255, green: 215/255, blue: 225/255, alpha: 1.0).cgColor
        let uploadTap = UITapGestureRecognizer(target: self, action: #selector(handleUploadBoxTap))
        dtUploadBox.addGestureRecognizer(uploadTap)
        dtUploadBox.isUserInteractionEnabled = true
        detailsCardView.addSubview(dtUploadBox)

        dtUploadIcon.translatesAutoresizingMaskIntoConstraints = false
        dtUploadIcon.image = UIImage(systemName: "square.and.arrow.up")
        dtUploadIcon.tintColor = UIColor(red: 100/255, green: 110/255, blue: 120/255, alpha: 1.0)
        dtUploadIcon.contentMode = .scaleAspectFit
        dtUploadBox.addSubview(dtUploadIcon)

        dtUploadLabel.translatesAutoresizingMaskIntoConstraints = false
        dtUploadLabel.text = "Upload"
        dtUploadLabel.textColor = UIColor(red: 100/255, green: 110/255, blue: 120/255, alpha: 1.0)
        dtUploadLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        dtUploadBox.addSubview(dtUploadLabel)

        dtUploadPreview.translatesAutoresizingMaskIntoConstraints = false
        dtUploadPreview.contentMode = .scaleAspectFill
        dtUploadPreview.layer.cornerRadius = 6
        dtUploadPreview.layer.masksToBounds = true
        dtUploadPreview.isHidden = true
        dtUploadBox.addSubview(dtUploadPreview)

        NSLayoutConstraint.activate([
            dtUploadIcon.topAnchor.constraint(equalTo: dtUploadBox.topAnchor, constant: 10),
            dtUploadIcon.centerXAnchor.constraint(equalTo: dtUploadBox.centerXAnchor),
            dtUploadIcon.widthAnchor.constraint(equalToConstant: 22),
            dtUploadIcon.heightAnchor.constraint(equalToConstant: 22),

            dtUploadLabel.topAnchor.constraint(equalTo: dtUploadIcon.bottomAnchor, constant: 4),
            dtUploadLabel.centerXAnchor.constraint(equalTo: dtUploadBox.centerXAnchor),
            dtUploadLabel.bottomAnchor.constraint(equalTo: dtUploadBox.bottomAnchor, constant: -10),

            dtUploadPreview.topAnchor.constraint(equalTo: dtUploadBox.topAnchor),
            dtUploadPreview.leadingAnchor.constraint(equalTo: dtUploadBox.leadingAnchor),
            dtUploadPreview.trailingAnchor.constraint(equalTo: dtUploadBox.trailingAnchor),
            dtUploadPreview.bottomAnchor.constraint(equalTo: dtUploadBox.bottomAnchor)
        ])

        // Details Bottom Bar
        dtBottomBar.translatesAutoresizingMaskIntoConstraints = false
        dtBottomBar.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        detailsCardView.addSubview(dtBottomBar)

        dtCancelButton.translatesAutoresizingMaskIntoConstraints = false
        dtCancelButton.setTitle("Cancel", for: .normal)
        dtCancelButton.setTitleColor(.white, for: .normal)
        dtCancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        dtCancelButton.addTarget(self, action: #selector(handleCancelTap), for: .touchUpInside)
        dtBottomBar.addSubview(dtCancelButton)

        dtRegisterButton.translatesAutoresizingMaskIntoConstraints = false
        dtRegisterButton.setTitle("Register Branch  ➔", for: .normal)
        dtRegisterButton.setTitleColor(.white, for: .normal)
        dtRegisterButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        dtRegisterButton.addTarget(self, action: #selector(handleFinalUserRegistration), for: .touchUpInside)
        dtBottomBar.addSubview(dtRegisterButton)

        dtRegisterSpinner.translatesAutoresizingMaskIntoConstraints = false
        dtRegisterSpinner.hidesWhenStopped = true
        dtRegisterSpinner.color = .white
        dtBottomBar.addSubview(dtRegisterSpinner)

        // Details Card Constraints
        NSLayoutConstraint.activate([
            detailsCardView.topAnchor.constraint(equalTo: errorBanner.bottomAnchor, constant: 14),
            detailsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // 1. Trust Code Row
            dtTrustRow.topAnchor.constraint(equalTo: detailsCardView.topAnchor, constant: 18),
            dtTrustRow.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            dtTrustRow.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),

            // 2. Title*
            dtTitleRow.topAnchor.constraint(equalTo: dtTrustRow.bottomAnchor, constant: 14),
            dtTitleRow.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            dtTitleRow.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),

            // 3. First Name*
            dtFnameRow.topAnchor.constraint(equalTo: dtTitleRow.bottomAnchor, constant: 14),
            dtFnameRow.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            dtFnameRow.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),

            // 4. Last Name*
            dtLnameRow.topAnchor.constraint(equalTo: dtFnameRow.bottomAnchor, constant: 14),
            dtLnameRow.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            dtLnameRow.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),

            // 5. Password*
            dtPasswordRow.topAnchor.constraint(equalTo: dtLnameRow.bottomAnchor, constant: 14),
            dtPasswordRow.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            dtPasswordRow.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),

            // 6. Center Emblem Logo
            dtEmblemImageView.topAnchor.constraint(equalTo: dtPasswordRow.bottomAnchor, constant: 16),
            dtEmblemImageView.centerXAnchor.constraint(equalTo: detailsCardView.centerXAnchor),
            dtEmblemImageView.widthAnchor.constraint(equalToConstant: 125),
            dtEmblemImageView.heightAnchor.constraint(equalToConstant: 125),

            // 7. Email*
            dtEmailRow.topAnchor.constraint(equalTo: dtEmblemImageView.bottomAnchor, constant: 16),
            dtEmailRow.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            dtEmailRow.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),

            // 8. Mobile*
            dtMobileRow.topAnchor.constraint(equalTo: dtEmailRow.bottomAnchor, constant: 14),
            dtMobileRow.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            dtMobileRow.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),

            // 9. Mobile for OTP
            dtOtpMobileRow.topAnchor.constraint(equalTo: dtMobileRow.bottomAnchor, constant: 14),
            dtOtpMobileRow.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            dtOtpMobileRow.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),

            // 10. Gender
            dtGenderRow.topAnchor.constraint(equalTo: dtOtpMobileRow.bottomAnchor, constant: 14),
            dtGenderRow.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            dtGenderRow.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),
            dtGenderRow.heightAnchor.constraint(equalToConstant: 32),

            // 11. Parent Branch Code#
            dtParentRow.topAnchor.constraint(equalTo: dtGenderRow.bottomAnchor, constant: 14),
            dtParentRow.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            dtParentRow.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),

            // 12. Id Document
            dtIdDocRow.topAnchor.constraint(equalTo: dtParentRow.bottomAnchor, constant: 14),
            dtIdDocRow.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            dtIdDocRow.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),

            // 13. Govt Id Number
            dtGovtIdRow.topAnchor.constraint(equalTo: dtIdDocRow.bottomAnchor, constant: 14),
            dtGovtIdRow.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 16),
            dtGovtIdRow.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -16),

            // 14. Upload Box
            dtUploadBox.topAnchor.constraint(equalTo: dtGovtIdRow.bottomAnchor, constant: 16),
            dtUploadBox.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 28),
            dtUploadBox.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -28),

            // Bottom Bar
            dtBottomBar.topAnchor.constraint(equalTo: dtUploadBox.bottomAnchor, constant: 20),
            dtBottomBar.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor),
            dtBottomBar.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor),
            dtBottomBar.bottomAnchor.constraint(equalTo: detailsCardView.bottomAnchor),
            dtBottomBar.heightAnchor.constraint(equalToConstant: 54),

            dtCancelButton.leadingAnchor.constraint(equalTo: dtBottomBar.leadingAnchor, constant: 20),
            dtCancelButton.centerYAnchor.constraint(equalTo: dtBottomBar.centerYAnchor),

            dtRegisterButton.trailingAnchor.constraint(equalTo: dtBottomBar.trailingAnchor, constant: -20),
            dtRegisterButton.centerYAnchor.constraint(equalTo: dtBottomBar.centerYAnchor),

            dtRegisterSpinner.centerYAnchor.constraint(equalTo: dtRegisterButton.centerYAnchor),
            dtRegisterSpinner.centerXAnchor.constraint(equalTo: dtRegisterButton.centerXAnchor)
        ])
    }

    // Helper: Build a consistent visual row with zero constraint clipping
    private func buildDetailRow(
        container: UIView,
        iconView: UIImageView,
        iconWrapper: UIView? = nil,
        isBadge: Bool = false,
        iconName: String = "",
        iconColor: UIColor = .gray,
        label: UILabel,
        title: String,
        field: UITextField,
        text: String? = nil,
        placeholder: String? = nil,
        underline: UIView,
        isEnabled: Bool = true,
        hasCustomTrailing: Bool = false
    ) {
        container.translatesAutoresizingMaskIntoConstraints = false

        if isBadge, let badge = iconWrapper {
            badge.translatesAutoresizingMaskIntoConstraints = false
            badge.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 0.85)
            badge.layer.cornerRadius = 6
            badge.layer.masksToBounds = true
            container.addSubview(badge)

            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.image = UIImage(systemName: "person.crop.rectangle.fill") ?? UIImage(systemName: "person.fill")
            iconView.tintColor = .white
            iconView.contentMode = .scaleAspectFit
            badge.addSubview(iconView)

            NSLayoutConstraint.activate([
                badge.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                badge.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
                badge.widthAnchor.constraint(equalToConstant: 34),
                badge.heightAnchor.constraint(equalToConstant: 24),

                iconView.centerXAnchor.constraint(equalTo: badge.centerXAnchor),
                iconView.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
                iconView.widthAnchor.constraint(equalToConstant: 20),
                iconView.heightAnchor.constraint(equalToConstant: 16)
            ])
        } else {
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.image = UIImage(systemName: iconName)
            iconView.tintColor = iconColor
            iconView.contentMode = .scaleAspectFit
            container.addSubview(iconView)

            NSLayoutConstraint.activate([
                iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                iconView.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
                iconView.widthAnchor.constraint(equalToConstant: 24),
                iconView.heightAnchor.constraint(equalToConstant: 22)
            ])
        }

        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = createRequiredLabel(title)
        container.addSubview(label)

        field.translatesAutoresizingMaskIntoConstraints = false
        if let placeholder = placeholder {
            field.placeholder = placeholder
        }
        if let text = text {
            field.text = text
        }
        field.textColor = UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0)
        field.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        field.isEnabled = isEnabled
        field.delegate = self
        field.addTarget(self, action: #selector(clearBannerError), for: .editingChanged)
        container.addSubview(field)

        underline.translatesAutoresizingMaskIntoConstraints = false
        underline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)
        container.addSubview(underline)

        let anchorLeading = (isBadge && iconWrapper != nil) ? iconWrapper!.trailingAnchor : iconView.trailingAnchor

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: anchorLeading, constant: 12),
            label.topAnchor.constraint(equalTo: container.topAnchor),

            field.leadingAnchor.constraint(equalTo: anchorLeading, constant: 12),
            field.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),
            field.heightAnchor.constraint(equalToConstant: 28),

            underline.leadingAnchor.constraint(equalTo: field.leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: field.trailingAnchor),
            underline.topAnchor.constraint(equalTo: field.bottomAnchor, constant: 2),
            underline.heightAnchor.constraint(equalToConstant: 1.5),
            underline.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        if !hasCustomTrailing {
            field.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        }
    }

    private func createRequiredLabel(_ text: String) -> NSAttributedString {
        let isRequired = text.hasSuffix("*")
        let cleanText = isRequired ? String(text.dropLast()) : text

        let attr = NSMutableAttributedString(
            string: cleanText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14.5, weight: .bold),
                .foregroundColor: UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
            ]
        )
        if isRequired {
            attr.append(NSAttributedString(
                string: "*",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 15, weight: .bold),
                    .foregroundColor: UIColor(red: 220/255, green: 53/255, blue: 69/255, alpha: 1.0)
                ]
            ))
        }
        return attr
    }

    // MARK: - Floating OTP Modal Dialog (Screenshot 3)
    private func setupOTPDialogUI() {
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

    // MARK: - Actions & Network Calls

    // Step 1: Check Trust Code (POST /api/check-trust-code)
    @objc private func handleTrustCodeSubmit() {
        view.endEditing(true)
        let code = initTrustCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !code.isEmpty else {
            initTrustUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            showBannerError("Please enter valid trust code. Contact helpline.")
            return
        }

        initTrustArrowButton.isHidden = true
        initTrustSpinner.startAnimating()
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
                guard let self = self else { return }
                self.initTrustArrowButton.isHidden = false
                self.initTrustSpinner.stopAnimating()

                if let error = error {
                    self.showBannerError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.showBannerError("Invalid response from server.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let apiMessage = self.extractMessage(from: json, fallback: "Please enter valid trust code. Contact helpline.")

                if status {
                    let dataObj = (json["data"] as? [String: Any]) ?? (json["response"] as? [String: Any]) ?? [:]
                    self.verifiedMerchantId = (dataObj["id"] as? Int) ?? (dataObj["merchant_id"] as? Int) ?? 6
                    self.verifiedMerchantName = (dataObj["name"] as? String) ?? "SHRI ANANDPUR TRUST"
                    self.verifiedRoleId = (dataObj["role_id"] as? Int) ?? 0

                    self.midTrustCodeField.text = code
                    self.dtTrustCodeField.text = code

                    if let titles = dataObj["MerchantTitle"] as? [[String: Any]], !titles.isEmpty {
                        let parsed = titles.compactMap { $0["title"] as? String }.filter { !$0.isEmpty }
                        if !parsed.isEmpty {
                            self.availableTitles = parsed
                            self.selectedTitle = parsed[0]
                            self.dtTitleField.text = parsed[0]
                        }
                    }

                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                    // Transition to midCardView with Email row active
                    self.contentBottomConstraint?.isActive = false
                    self.contentBottomConstraint = self.contentView.bottomAnchor.constraint(equalTo: self.midCardView.bottomAnchor, constant: 40)
                    self.contentBottomConstraint?.isActive = true

                    UIView.transition(with: self.contentView, duration: 0.35, options: .transitionCrossDissolve) {
                        self.initialCardView.isHidden = true
                        self.midCardView.isHidden = false
                    }
                    self.midEmailField.becomeFirstResponder()
                } else {
                    self.initTrustUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
                    self.showBannerError(apiMessage)
                }
            }
        }.resume()
    }

    // Step 2: Verify Email first, then reveal Mobile field (Chart Flow)
    @objc private func handleEmailVerifyAndRevealMobile() {
        view.endEditing(true)
        let email = midEmailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !email.isEmpty, email.contains("@"), email.contains(".") else {
            midEmailUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            showBannerError("Please enter a valid Email address.")
            return
        }

        clearBannerError()
        midEmailArrowButton.isHidden = true
        midEmailSpinner.startAnimating()

        // Verify Email Format & Readiness
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.midEmailSpinner.stopAnimating()
            self.midEmailArrowButton.isHidden = false

            self.isEmailVerified = true
            self.midEmailCheckmark.isHidden = false
            self.midEmailUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)

            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            // Expand mid card to show Mobile Row
            self.midEmailToBottomConstraint?.isActive = false
            self.midMobileToBottomConstraint?.isActive = true

            UIView.animate(withDuration: 0.3) {
                self.midMobileRowView.isHidden = false
                self.view.layoutIfNeeded()
            }
            self.midMobileField.becomeFirstResponder()
        }
    }

    // Step 3: Send OTP for Mobile (POST /api/register-otp-send)
    @objc private func handleMobileSubmitAndSendOTP() {
        view.endEditing(true)
        let email = midEmailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let mobile = midMobileField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trustCode = midTrustCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard isEmailVerified else {
            showBannerError("Please verify your email first.")
            return
        }

        guard !mobile.isEmpty, mobile.count == 10 else {
            midMobileUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            showBannerError("Please enter a valid 10-digit mobile number.")
            return
        }

        midMobileArrowButton.isHidden = true
        midMobileSpinner.startAnimating()
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
            "merchant_id": "\(verifiedMerchantId)",
            "mobile_device_id": AppConfig.mobileDeviceId,
            "device_id": AppConfig.deviceId
        ]
        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.midMobileArrowButton.isHidden = false
                self.midMobileSpinner.stopAnimating()

                if let error = error {
                    self.showBannerError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.showBannerError("Invalid response from server.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let apiMessage = self.extractMessage(from: json, fallback: "Failed to send OTP. Please check mobile number.")

                if status {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    self.presentOTPDialog()
                } else {
                    self.midMobileUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
                    self.showBannerError(apiMessage)
                }
            }
        }.resume()
    }

    private func presentOTPDialog() {
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
                self.otpTimerLabel.text = String(format: "00 : %02d", self.otpRemainingSeconds)
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

    // Step 4: Verify OTP (POST /api/check-register-otp)
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

        let mobile = midMobileField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

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
                guard let self = self else { return }
                self.otpSpinner.stopAnimating()
                self.otpVerifyButton.setTitle("Verify OTP", for: .normal)

                if let error = error {
                    self.otpErrorLabel.text = "Network error: \(error.localizedDescription)"
                    self.otpErrorLabel.isHidden = false
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.otpErrorLabel.text = "Invalid response from server."
                    self.otpErrorLabel.isHidden = false
                    return
                }

                let status = json["status"] as? Bool ?? false
                let apiMessage = self.extractMessage(from: json, fallback: "Invalid OTP code entered.")

                if status {
                    self.otpTimer?.invalidate()
                    self.isMobileVerified = true

                    self.midMobileCheckmark.isHidden = false
                    self.midMobileUnderline.backgroundColor = UIColor(red: 65/255, green: 132/255, blue: 214/255, alpha: 1.0)

                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

                    UIView.animate(withDuration: 0.2, animations: {
                        self.otpOverlayBackdrop.alpha = 0
                    }) { _ in
                        self.otpOverlayBackdrop.isHidden = true
                    }

                    // Reveal Parent Code Row on Mid Card
                    self.midMobileToBottomConstraint?.isActive = false
                    self.midParentToBottomConstraint?.isActive = true

                    UIView.animate(withDuration: 0.3) {
                        self.midParentRowView.isHidden = false
                        self.view.layoutIfNeeded()
                    }
                    self.midParentCodeField.becomeFirstResponder()
                } else {
                    self.otpUnderline.backgroundColor = UIColor(red: 255/255, green: 107/255, blue: 107/255, alpha: 1.0)
                    self.otpErrorLabel.text = apiMessage
                    self.otpErrorLabel.isHidden = false
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }.resume()
    }

    // Step 5: Verify Parent Code & Reveal Detailed User Registration Form (Screenshot 1 & 2)
    @objc private func handleParentCodeSubmitAndOpenDetails() {
        view.endEditing(true)
        let parentCode = midParentCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !parentCode.isEmpty else {
            midParentUnderline.backgroundColor = UIColor(red: 218/255, green: 84/255, blue: 46/255, alpha: 1.0)
            showBannerError("Please enter Main/Parent Branch Code.")
            return
        }

        midParentArrowButton.isHidden = true
        midParentSpinner.startAnimating()
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
                guard let self = self else { return }
                self.midParentArrowButton.isHidden = false
                self.midParentSpinner.stopAnimating()

                // Sync verified values to details card
                self.dtEmailField.text = self.midEmailField.text
                self.dtMobileField.text = self.midMobileField.text
                self.dtOtpMobileField.text = self.midMobileField.text
                self.dtParentCodeField.text = parentCode

                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

                // Update dynamic bottom constraint to detailsCardView
                self.contentBottomConstraint?.isActive = false
                self.contentBottomConstraint = self.contentView.bottomAnchor.constraint(equalTo: self.detailsCardView.bottomAnchor, constant: 50)
                self.contentBottomConstraint?.isActive = true

                // Reveal Subtitle "Enter Detail Of User" and switch to Card 3 (Screenshot 1 & 2)
                self.headerSubtitleLabel.isHidden = false
                UIView.transition(with: self.contentView, duration: 0.35, options: .transitionCrossDissolve) {
                    self.midCardView.isHidden = true
                    self.detailsCardView.isHidden = false
                }
                self.dtFnameField.becomeFirstResponder()
            }
        }.resume()
    }

    // Step 6: Final User Registration (POST /api/register)
    @objc private func handleFinalUserRegistration() {
        view.endEditing(true)
        let fname = dtFnameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lname = dtLnameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = dtPasswordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = dtEmailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let mobile = dtMobileField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let parentCode = dtParentCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trustCode = dtTrustCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let govtId = dtGovtIdField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !fname.isEmpty else { showBannerError("First Name is required."); return }
        guard !lname.isEmpty else { showBannerError("Last Name is required."); return }
        guard password.count >= 6 else { showBannerError("Password must be at least 6 characters."); return }

        dtRegisterButton.setTitle("", for: .normal)
        dtRegisterSpinner.startAnimating()
        clearBannerError()

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
            "id_document": selectedIdDocument,
            "govt_id_number": govtId,
            "device_type": AppConfig.deviceType,
            "device_id": AppConfig.deviceId,
            "mobile_device_id": AppConfig.mobileDeviceId
        ]
        let body = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.dtRegisterSpinner.stopAnimating()
                self.dtRegisterButton.setTitle("Register Branch  ➔", for: .normal)

                if let error = error {
                    self.showBannerError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.showBannerError("Invalid server response.")
                    return
                }

                let status = json["status"] as? Bool ?? false
                let apiMessage = self.extractMessage(from: json, fallback: "Registration failed. Please try again.")

                if status {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    let alert = UIAlertController(
                        title: "Registration Successful!",
                        message: "Your account under \(self.verifiedMerchantName) has been successfully created.\nYou can now log in.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Log In Now", style: .default) { [weak self] _ in
                        self?.dismiss(animated: true) {
                            self?.onSignUpSuccess?(email)
                        }
                    })
                    self.present(alert, animated: true)
                } else {
                    self.showBannerError(apiMessage)
                }
            }
        }.resume()
    }

    // MARK: - Picker Action Sheets
    @objc private func presentTitlePickerSheet() {
        let alert = UIAlertController(title: "Choose Title", message: nil, preferredStyle: .actionSheet)
        for t in availableTitles {
            alert.addAction(UIAlertAction(title: t, style: .default) { [weak self] _ in
                self?.selectedTitle = t
                self?.dtTitleField.text = t
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func presentIdDocumentPickerSheet() {
        let alert = UIAlertController(title: "Choose Id Document", message: nil, preferredStyle: .actionSheet)
        for doc in idDocumentOptions {
            alert.addAction(UIAlertAction(title: doc, style: .default) { [weak self] _ in
                self?.selectedIdDocument = doc
                self?.dtIdDocField.text = doc
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func handleUploadBoxTap() {
        let alert = UIAlertController(title: "Upload ID Document", message: "Choose document source", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self?.present(picker, animated: true)
            })
        }
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self?.present(picker, animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let img = info[.originalImage] as? UIImage {
            uploadedDocumentImage = img
            dtUploadPreview.image = img
            dtUploadPreview.isHidden = false
            dtUploadIcon.isHidden = true
            dtUploadLabel.isHidden = true
        }
    }

    @objc private func toggleShowPassword() {
        dtPasswordField.isSecureTextEntry.toggle()
        let title = dtPasswordField.isSecureTextEntry ? "Show" : "Hide"
        dtShowPasswordButton.setTitle(title, for: .normal)
    }

    @objc private func selectMale() {
        selectedGender = 1
        dtMaleRadioButton.setTitle(" 🔘 Male", for: .normal)
        dtMaleRadioButton.setTitleColor(UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0), for: .normal)
        dtFemaleRadioButton.setTitle(" ⚪ Female", for: .normal)
        dtFemaleRadioButton.setTitleColor(UIColor(red: 100/255, green: 110/255, blue: 120/255, alpha: 1.0), for: .normal)
    }

    @objc private func selectFemale() {
        selectedGender = 2
        dtFemaleRadioButton.setTitle(" 🔘 Female", for: .normal)
        dtFemaleRadioButton.setTitleColor(UIColor(red: 19/255, green: 59/255, blue: 124/255, alpha: 1.0), for: .normal)
        dtMaleRadioButton.setTitle(" ⚪ Male", for: .normal)
        dtMaleRadioButton.setTitleColor(UIColor(red: 100/255, green: 110/255, blue: 120/255, alpha: 1.0), for: .normal)
    }

    @objc private func handleCancelTap() {
        dismiss(animated: true)
    }

    // MARK: - Dynamic Error Helpers
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

    private func showBannerError(_ msg: String) {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        errorLabel.text = msg
        errorBanner.isHidden = false
    }

    @objc private func clearBannerError() {
        errorBanner.isHidden = true
    }

    @objc private func showTrustInfo() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        showHelpAlert(
            title: "Trust/Institution Code",
            message: "A unique identification code assigned to your trust or branch (e.g. SAT6677). Contact your Trust Head Office if you do not have one."
        )
    }

    @objc private func showEmailInfo() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        showHelpAlert(
            title: "Email Address",
            message: "Enter your official email address to receive important registration updates and notifications."
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
            message: "Enter the code or ID of your parent Head Office branch (e.g. 0001 or 6)."
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
        if textField == initTrustCodeField {
            handleTrustCodeSubmit()
        } else if textField == midEmailField {
            handleEmailVerifyAndRevealMobile()
        } else if textField == midMobileField {
            handleMobileSubmitAndSendOTP()
        } else if textField == midParentCodeField {
            handleParentCodeSubmitAndOpenDetails()
        } else if textField == dtFnameField {
            dtLnameField.becomeFirstResponder()
        } else if textField == dtLnameField {
            dtPasswordField.becomeFirstResponder()
        } else if textField == dtPasswordField {
            handleFinalUserRegistration()
        }
        return true
    }
}
