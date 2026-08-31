import UIKit
import SafariServices

struct GoogleAccountItem {
    let name: String
    let email: String
    let color: UIColor
    let initial: String
}

class GoogleAccountChooserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var onAccountSelected: ((String) -> Void)?

    private let backdropView = UIView()
    private let cardContainerView = UIView()
    private let appIconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let footerLabel = UILabel()

    private var accounts: [GoogleAccountItem] = []

    private let avatarColors: [UIColor] = [
        UIColor(red: 194/255, green: 24/255, blue: 91/255, alpha: 1.0),   // Magenta / Raspberry
        UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1.0),   // Pink
        UIColor(red: 141/255, green: 110/255, blue: 99/255, alpha: 1.0),  // Warm Brown
        UIColor(red: 84/255, green: 110/255, blue: 122/255, alpha: 1.0),  // Slate Teal
        UIColor(red: 25/255, green: 118/255, blue: 210/255, alpha: 1.0),  // Blue
        UIColor(red: 56/255, green: 142/255, blue: 60/255, alpha: 1.0),   // Green
        UIColor(red: 230/255, green: 81/255, blue: 0/255, alpha: 1.0)     // Amber Orange
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAccounts()
        setupUI()
    }

    private func loadAccounts() {
        // Load custom saved accounts from UserDefaults
        let savedEmails = UserDefaults.standard.stringArray(forKey: "saved_google_accounts") ?? []

        // Seed default accounts matching user's environment & Android reference
        var initialList: [(name: String, email: String)] = [
            ("Ritu Somaiya", "ritu.somaiya@dianapps.com"),
            ("homeutilities", "homeutilities09@gmail.com"),
            ("Homeutilities", "homeutilities499@gmail.com"),
            ("homeUtilities", "homeutilities201@gmail.com"),
            ("Latitude Support", "oneforall@latitudetechnolabs.com")
        ]

        // Prepend any saved emails if they are not already in the list
        for email in savedEmails.reversed() {
            if !initialList.contains(where: { $0.email.lowercased() == email.lowercased() }) {
                let namePart = email.components(separatedBy: "@").first?.capitalized ?? "Google User"
                initialList.insert((name: namePart, email: email), at: 0)
            }
        }

        // Build account items
        accounts = initialList.enumerated().map { index, item in
            let initial = String(item.name.prefix(1)).uppercased()
            let color = avatarColors[index % avatarColors.count]
            return GoogleAccountItem(name: item.name, email: item.email, color: color, initial: initial)
        }
    }

    private func setupUI() {
        view.backgroundColor = .clear

        // 1. Semi-transparent backdrop
        backdropView.translatesAutoresizingMaskIntoConstraints = false
        backdropView.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBackdropTap))
        backdropView.addGestureRecognizer(tap)
        view.addSubview(backdropView)

        // 2. White Card Container
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        cardContainerView.backgroundColor = .white
        cardContainerView.layer.cornerRadius = 18
        cardContainerView.layer.masksToBounds = true
        cardContainerView.layer.shadowColor = UIColor.black.cgColor
        cardContainerView.layer.shadowOpacity = 0.25
        cardContainerView.layer.shadowOffset = CGSize(width: 0, height: 6)
        cardContainerView.layer.shadowRadius = 14
        view.addSubview(cardContainerView)

        // 3. Top App Icon (Trust Emblem)
        appIconImageView.translatesAutoresizingMaskIntoConstraints = false
        if let iconImg = UIImage(named: "AppIcon-1024") ?? UIImage(systemName: "person.crop.circle.fill") {
            appIconImageView.image = iconImg
        }
        appIconImageView.contentMode = .scaleAspectFill
        appIconImageView.layer.cornerRadius = 10
        appIconImageView.layer.masksToBounds = true
        appIconImageView.layer.borderWidth = 0.5
        appIconImageView.layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor
        cardContainerView.addSubview(appIconImageView)

        // 4. Title: "Choose an account"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Choose an account"
        titleLabel.textColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        titleLabel.textAlignment = .center
        cardContainerView.addSubview(titleLabel)

        // 5. Subtitle: "to continue to SAT-Branches"
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "to continue to SAT-Branches"
        subtitleLabel.textColor = UIColor(red: 95/255, green: 99/255, blue: 104/255, alpha: 1.0)
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textAlignment = .center
        cardContainerView.addSubview(subtitleLabel)

        // 6. Accounts TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.register(GoogleAccountCell.self, forCellReuseIdentifier: "GoogleAccountCell")
        tableView.register(AddGoogleAccountCell.self, forCellReuseIdentifier: "AddGoogleAccountCell")
        cardContainerView.addSubview(tableView)

        // 7. Footer Disclaimer Text
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.numberOfLines = 0
        footerLabel.textColor = UIColor(red: 95/255, green: 99/255, blue: 104/255, alpha: 1.0)
        footerLabel.font = UIFont.systemFont(ofSize: 11.5)
        footerLabel.isUserInteractionEnabled = true

        let fullText = "To continue, Google will share your name, email address and profile picture with SAT-Branches. Before using this app, review its privacy policy and terms of service."
        let attributedString = NSMutableAttributedString(string: fullText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.5
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: fullText.count))

        if let privacyRange = fullText.range(of: "privacy policy") {
            let nsRange = NSRange(privacyRange, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: UIColor(red: 26/255, green: 115/255, blue: 232/255, alpha: 1.0), range: nsRange)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
        }
        footerLabel.attributedText = attributedString

        let footerTap = UITapGestureRecognizer(target: self, action: #selector(openPrivacyPolicy))
        footerLabel.addGestureRecognizer(footerTap)
        cardContainerView.addSubview(footerLabel)

        // Constraints
        let tableHeight = min(CGFloat(accounts.count + 1) * 58.0, 320.0)

        NSLayoutConstraint.activate([
            backdropView.topAnchor.constraint(equalTo: view.topAnchor),
            backdropView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdropView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backdropView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            cardContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cardContainerView.widthAnchor.constraint(lessThanOrEqualToConstant: 380),

            appIconImageView.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 24),
            appIconImageView.centerXAnchor.constraint(equalTo: cardContainerView.centerXAnchor),
            appIconImageView.widthAnchor.constraint(equalToConstant: 44),
            appIconImageView.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.topAnchor.constraint(equalTo: appIconImageView.bottomAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: tableHeight),

            footerLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 14),
            footerLabel.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 20),
            footerLabel.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -20),
            footerLabel.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: -22)
        ])
    }

    @objc private func handleBackdropTap() {
        dismiss(animated: true)
    }

    @objc private func openPrivacyPolicy() {
        guard let url = URL(string: "https://test.enin.io/privacy-policy") else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }

    // MARK: - TableView DataSource & Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? accounts.count : 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GoogleAccountCell", for: indexPath) as! GoogleAccountCell
            let item = accounts[indexPath.row]
            cell.configure(with: item)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddGoogleAccountCell", for: indexPath) as! AddGoogleAccountCell
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        if indexPath.section == 0 {
            let selectedAccount = accounts[indexPath.row]
            // Save to persistent list
            saveAccountEmail(selectedAccount.email)
            dismiss(animated: true) { [weak self] in
                self?.onAccountSelected?(selectedAccount.email)
            }
        } else {
            // "Add another account" tapped
            promptForNewAccount()
        }
    }

    private func saveAccountEmail(_ email: String) {
        var saved = UserDefaults.standard.stringArray(forKey: "saved_google_accounts") ?? []
        if !saved.contains(where: { $0.lowercased() == email.lowercased() }) {
            saved.insert(email, at: 0)
            UserDefaults.standard.set(saved, forKey: "saved_google_accounts")
        }
    }

    private func promptForNewAccount() {
        let alert = UIAlertController(
            title: "Add Google Account",
            message: "Enter your Gmail address to continue:",
            preferredStyle: .alert
        )
        alert.addTextField { tf in
            tf.placeholder = "username@gmail.com"
            tf.keyboardType = .emailAddress
            tf.autocapitalizationType = .none
            tf.autocorrectionType = .no
        }
        alert.addAction(UIAlertAction(title: "Sign In", style: .default) { [weak self, weak alert] _ in
            guard let email = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else { return }
            self?.saveAccountEmail(email)
            self?.dismiss(animated: true) {
                self?.onAccountSelected?(email)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - Google Account Cell
class GoogleAccountCell: UITableViewCell {

    private let avatarContainer = UIView()
    private let initialLabel = UILabel()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let separatorView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        backgroundColor = .white
        selectionStyle = .default

        avatarContainer.translatesAutoresizingMaskIntoConstraints = false
        avatarContainer.layer.cornerRadius = 18
        avatarContainer.layer.masksToBounds = true
        contentView.addSubview(avatarContainer)

        initialLabel.translatesAutoresizingMaskIntoConstraints = false
        initialLabel.textColor = .white
        initialLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        initialLabel.textAlignment = .center
        avatarContainer.addSubview(initialLabel)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = UIColor(red: 32/255, green: 33/255, blue: 36/255, alpha: 1.0)
        nameLabel.font = UIFont.systemFont(ofSize: 14.5, weight: .medium)
        contentView.addSubview(nameLabel)

        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.textColor = UIColor(red: 95/255, green: 99/255, blue: 104/255, alpha: 1.0)
        emailLabel.font = UIFont.systemFont(ofSize: 12.5, weight: .regular)
        contentView.addSubview(emailLabel)

        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor(red: 232/255, green: 234/255, blue: 237/255, alpha: 1.0)
        contentView.addSubview(separatorView)

        NSLayoutConstraint.activate([
            avatarContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            avatarContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 36),
            avatarContainer.heightAnchor.constraint(equalToConstant: 36),

            initialLabel.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            initialLabel.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),

            emailLabel.leadingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 14),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),

            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.8)
        ])
    }

    func configure(with item: GoogleAccountItem) {
        nameLabel.text = item.name
        emailLabel.text = item.email
        avatarContainer.backgroundColor = item.color
        initialLabel.text = item.initial
    }
}

// MARK: - Add Google Account Cell
class AddGoogleAccountCell: UITableViewCell {

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let separatorView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        backgroundColor = .white
        selectionStyle = .default

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: "person.badge.plus") ?? UIImage(systemName: "person.crop.circle.badge.plus")
        iconImageView.tintColor = UIColor(red: 60/255, green: 64/255, blue: 67/255, alpha: 1.0)
        iconImageView.contentMode = .scaleAspectFit
        contentView.addSubview(iconImageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Add another account"
        titleLabel.textColor = UIColor(red: 60/255, green: 64/255, blue: 67/255, alpha: 1.0)
        titleLabel.font = UIFont.systemFont(ofSize: 14.5, weight: .medium)
        contentView.addSubview(titleLabel)

        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor(red: 232/255, green: 234/255, blue: 237/255, alpha: 1.0)
        contentView.addSubview(separatorView)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.8)
        ])
    }
}
