import UIKit
import WebKit
import UserNotifications

/// High-performance WebViewController hosting the SAT responsive web dashboard.
/// Encapsulates native loaders, pull-to-refresh, offline recovery, push notifications,
/// haptic feedback, and two-way JavaScript bridge communication.
class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

    // MARK: - Supported Bridge Actions
    private enum BridgeAction: String {
        case fcmTokenRegistered
        case clearBadge
        case resetBadge
        case clearAllDeliveredAndBadge
        case setBadge
        case decrementBadge
        case showLocalNotification
        case notify
    }

    private let initialURLString: String
    private var webView: WKWebView!

    // MARK: - Native Header Bar / Status Bar Protection Frame
    private let topFrameView = UIView()

    // MARK: - Pull to Refresh Control
    private let refreshControl = UIRefreshControl()

    // MARK: - Native Round Activity Loader (Replaces Web Line Loader)
    private let loaderHUD = UIView()
    private let activitySpinner = UIActivityIndicatorView(style: .large)
    private var loaderDismissWorkItem: DispatchWorkItem?

    // MARK: - Connectivity & Feedback
    private var isConnected: Bool = true
    private var wasOffline: Bool = false
    private let offlineOverlayView = UIView()
    private let notificationFeedback = UINotificationFeedbackGenerator()

    // MARK: - Notification Tracking & State
    private var lastRegisteredFcmToken: String? = nil
    private var lastFiredNotificationBody: String? = nil
    private var lastFiredNotificationTime: Date? = nil

    init(initialURLString: String) {
        self.initialURLString = initialURLString
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = AppTheme.satDeepBlue

        notificationFeedback.prepare()

        setupTopFrame()
        setupWebView()
        setupLoaderHUD()
        setupRefreshControl()
        setupOfflineOverlay()
        setupNetworkMonitoring()
        setupPushNotificationObserver()
        loadInitialURL()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        BadgeManager.shared.syncWithDeliveredNotifications()
    }

    // MARK: - Top Blue App Frame (Covers Status Bar & Encloses Screen)
    private func setupTopFrame() {
        topFrameView.translatesAutoresizingMaskIntoConstraints = false
        topFrameView.backgroundColor = AppTheme.satDeepBlue
        view.addSubview(topFrameView)

        NSLayoutConstraint.activate([
            topFrameView.topAnchor.constraint(equalTo: view.topAnchor),
            topFrameView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topFrameView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topFrameView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }

    // MARK: - WKWebView Setup
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.websiteDataStore = WKWebsiteDataStore.default()
        config.applicationNameForUserAgent = " SATMobileApp/\(AppConfig.appVersion) (iOS/Swift; WKWebView)"

        let contentController = WKUserContentController()
        contentController.add(self, name: "satPushBridge")

        // 1. In-page Web Push and Bridge Polyfill Script (Document Start)
        let bridgeScript = WKUserScript(
            source: WebViewController.webBridgePolyfillScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        contentController.addUserScript(bridgeScript)

        // 2. Success Alert Detector & Mutation Observer (Document End)
        let detectorScript = WKUserScript(
            source: WebViewController.successAlertDetectorScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        contentController.addUserScript(detectorScript)

        // 3. Modal Responsive & Screen-Fitting Engine (Document Start & End)
        let modalScript = WKUserScript(
            source: WebViewController.modalResponsiveEngineScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        contentController.addUserScript(modalScript)

        config.userContentController = contentController

        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = true
        webView.backgroundColor = UIColor(red: 245/255, green: 247/255, blue: 252/255, alpha: 1.0)
        webView.isOpaque = true

        if #available(iOS 16.4, *) {
            webView.isInspectable = false
        }

        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Native Round Circular Loader (App-Like Spinner)
    private func setupLoaderHUD() {
        loaderHUD.translatesAutoresizingMaskIntoConstraints = false
        loaderHUD.backgroundColor = AppTheme.satDeepBlue.withAlphaComponent(0.92)
        AppTheme.applyCardElevation(to: loaderHUD, cornerRadius: AppTheme.CornerRadius.xlarge)
        loaderHUD.layer.borderWidth = 1.0
        loaderHUD.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        loaderHUD.alpha = 0
        loaderHUD.isHidden = true
        view.addSubview(loaderHUD)

        activitySpinner.translatesAutoresizingMaskIntoConstraints = false
        activitySpinner.color = .white
        activitySpinner.hidesWhenStopped = true
        loaderHUD.addSubview(activitySpinner)

        NSLayoutConstraint.activate([
            loaderHUD.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loaderHUD.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loaderHUD.widthAnchor.constraint(equalToConstant: 80),
            loaderHUD.heightAnchor.constraint(equalToConstant: 80),

            activitySpinner.centerXAnchor.constraint(equalTo: loaderHUD.centerXAnchor),
            activitySpinner.centerYAnchor.constraint(equalTo: loaderHUD.centerYAnchor)
        ])
    }

    private func showRoundLoader() {
        loaderDismissWorkItem?.cancel()
        loaderDismissWorkItem = nil

        loaderHUD.isHidden = false
        activitySpinner.startAnimating()
        UIView.animate(withDuration: 0.2) {
            self.loaderHUD.alpha = 1.0
        }

        // Safety watchdog: auto-hide after 8s to prevent stuck overlays
        let workItem = DispatchWorkItem { [weak self] in
            self?.hideRoundLoader()
        }
        loaderDismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0, execute: workItem)
    }

    private func hideRoundLoader() {
        loaderDismissWorkItem?.cancel()
        loaderDismissWorkItem = nil

        UIView.animate(withDuration: 0.25, animations: {
            self.loaderHUD.alpha = 0.0
        }) { _ in
            self.activitySpinner.stopAnimating()
            self.loaderHUD.isHidden = true
        }
    }

    // MARK: - Native Pull to Refresh
    private func setupRefreshControl() {
        refreshControl.tintColor = AppTheme.satDeepBlue
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
    }

    // MARK: - App Store Compliant Offline Overlay (Guideline 4.2)
    private func setupOfflineOverlay() {
        offlineOverlayView.translatesAutoresizingMaskIntoConstraints = false
        offlineOverlayView.backgroundColor = UIColor(red: 245/255, green: 247/255, blue: 252/255, alpha: 1.0)
        offlineOverlayView.isHidden = true
        view.addSubview(offlineOverlayView)

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        AppTheme.applyCardElevation(to: card, cornerRadius: AppTheme.CornerRadius.xlarge)
        offlineOverlayView.addSubview(card)

        let container = UIStackView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.axis = .vertical
        container.alignment = .center
        container.spacing = 16
        card.addSubview(container)

        let badgeView = UIView()
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.backgroundColor = AppTheme.errorRed.withAlphaComponent(0.12)
        badgeView.layer.cornerRadius = 36
        badgeView.layer.masksToBounds = true
        container.addArrangedSubview(badgeView)

        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = UIImage(systemName: "wifi.slash")
        icon.tintColor = AppTheme.errorRed
        icon.contentMode = .scaleAspectFit
        badgeView.addSubview(icon)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "No Internet Connection"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = AppTheme.canvasBackground
        titleLabel.textAlignment = .center
        container.addArrangedSubview(titleLabel)

        let subLabel = UILabel()
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        subLabel.text = "Please check your network settings and try again."
        subLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subLabel.textColor = UIColor(red: 100/255, green: 110/255, blue: 125/255, alpha: 1.0)
        subLabel.textAlignment = .center
        subLabel.numberOfLines = 0
        container.addArrangedSubview(subLabel)

        let retryButton = UIButton(type: .system)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle("Retry Connection  ↻", for: .normal)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        retryButton.backgroundColor = AppTheme.satDeepBlue
        retryButton.layer.cornerRadius = AppTheme.CornerRadius.medium
        AppTheme.applyButtonElevation(to: retryButton)
        retryButton.addTarget(self, action: #selector(handleOfflineRetry), for: .touchUpInside)
        container.addArrangedSubview(retryButton)

        let helpButton = UIButton(type: .system)
        helpButton.translatesAutoresizingMaskIntoConstraints = false
        helpButton.setTitle(" Helpline Support", for: .normal)
        helpButton.setTitleColor(AppTheme.skyBlueAccent, for: .normal)
        helpButton.setImage(UIImage(systemName: "phone.circle.fill"), for: .normal)
        helpButton.tintColor = AppTheme.skyBlueAccent
        helpButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        helpButton.addTarget(self, action: #selector(handleOfflineHelp), for: .touchUpInside)
        container.addArrangedSubview(helpButton)

        NSLayoutConstraint.activate([
            offlineOverlayView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            offlineOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            offlineOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            offlineOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            card.centerXAnchor.constraint(equalTo: offlineOverlayView.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: offlineOverlayView.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: offlineOverlayView.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: offlineOverlayView.trailingAnchor, constant: -24),

            container.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            container.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
            container.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            badgeView.widthAnchor.constraint(equalToConstant: 72),
            badgeView.heightAnchor.constraint(equalToConstant: 72),

            icon.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 36),
            icon.heightAnchor.constraint(equalToConstant: 36),

            retryButton.widthAnchor.constraint(equalToConstant: 220),
            retryButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func handleOfflineRetry() {
        if NetworkMonitor.shared.isConnected {
            AppTheme.triggerHapticFeedback(notificationType: .success)
            offlineOverlayView.isHidden = true
            webView.reload()
        } else {
            AppTheme.triggerHapticFeedback(notificationType: .warning)

            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.duration = 0.4
            animation.values = [-10.0, 10.0, -8.0, 8.0, -5.0, 5.0, 0.0]
            offlineOverlayView.layer.add(animation, forKey: "shake")
        }
    }

    @objc private func handleOfflineHelp() {
        AppTheme.triggerHapticFeedback(style: .light)
        let alert = UIAlertController(
            title: "Support Contact",
            message: "For technical assistance:\n\nHelpline: \(AppConfig.helplineNumber)\nEmail: \(AppConfig.supportEmail)",
            preferredStyle: .alert
        )
        if let phoneURL = URL(string: "tel://\(AppConfig.helplineNumber)") {
            alert.addAction(UIAlertAction(title: "Call Helpline", style: .default, handler: { _ in
                if UIApplication.shared.canOpenURL(phoneURL) {
                    UIApplication.shared.open(phoneURL)
                }
            }))
        }
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Centralized Network Monitoring
    private func setupNetworkMonitoring() {
        NetworkMonitor.shared.onStatusChange = { [weak self] isNowConnected in
            guard let self = self else { return }
            self.isConnected = isNowConnected
            self.offlineOverlayView.isHidden = isNowConnected

            if !isNowConnected {
                self.wasOffline = true
            } else if self.wasOffline {
                self.wasOffline = false
                self.webView.reload()
            }
        }
        isConnected = NetworkMonitor.shared.isConnected
        offlineOverlayView.isHidden = isConnected
    }

    private func loadInitialURL() {
        guard let url = URL(string: initialURLString) else { return }
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        webView.load(request)
    }

    @objc private func handleRefresh() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        if NetworkMonitor.shared.isConnected {
            offlineOverlayView.isHidden = true
            webView.reload()
        } else {
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.duration = 0.4
            animation.values = [-10.0, 10.0, -8.0, 8.0, -5.0, 5.0, 0.0]
            offlineOverlayView.layer.add(animation, forKey: "shake")
        }
        refreshControl.endRefreshing()
    }

    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showRoundLoader()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideRoundLoader()
        refreshControl.endRefreshing()

        // Sync native Firebase FCM token with backend /save-web-push-token
        let fcmToken = AppConfig.fcmDeviceToken
        if !fcmToken.isEmpty {
            syncFcmTokenWithBackend(token: fcmToken)
        }

        // Trigger detection on document end
        detectAndForwardSuccessAlerts()

        // Refresh user activity timestamp in SessionManager
        SessionManager.shared.recordUserActivity()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideRoundLoader()
        refreshControl.endRefreshing()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        hideRoundLoader()
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain &&
            (nsError.code == NSURLErrorNotConnectedToInternet ||
             nsError.code == NSURLErrorCannotFindHost ||
             nsError.code == NSURLErrorTimedOut) {
            offlineOverlayView.isHidden = false
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // Track user interaction / navigation
        SessionManager.shared.recordUserActivity()

        // Intercept logout to deactivate FCM token and return smoothly to LoginViewController
        if url.absoluteString.contains("/logout") {
            SessionManager.shared.clearSession(reason: .userLogout)
            deactivateFcmTokenOnBackend()
            decisionHandler(.cancel)
            dismiss(animated: true)
            return
        }

        let scheme = url.scheme?.lowercased() ?? ""
        if ["tel", "mailto", "whatsapp", "upi"].contains(scheme) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }

    // MARK: - WKUIDelegate
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "SAT", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completionHandler() }))
        present(alert, animated: true)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "SAT", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in completionHandler(false) }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completionHandler(true) }))
        present(alert, animated: true)
    }

    // MARK: - Push Notification & Deep Linking Support
    private func setupPushNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePushNotificationTapped(_:)),
            name: NSNotification.Name("SATNotificationTapped"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFcmTokenUpdated(_:)),
            name: NSNotification.Name("SATFcmTokenUpdated"),
            object: nil
        )
    }

    @objc private func handleFcmTokenUpdated(_ notification: Notification) {
        if let token = notification.userInfo?["token"] as? String, !token.isEmpty {
            DispatchQueue.main.async {
                self.syncFcmTokenWithBackend(token: token)
            }
        }
    }

    private func syncFcmTokenWithBackend(token: String) {
        guard lastRegisteredFcmToken != token else { return }

        let js = """
        (function() {
            var csrfEl = document.querySelector('meta[name="csrf-token"]');
            if (!csrfEl) return;
            var csrf = csrfEl.getAttribute('content');
            if (!csrf || csrf.length < 5) return;

            var saveUrl = (typeof saveWebPushTokenUrl !== 'undefined') ? saveWebPushTokenUrl : '/save-web-push-token';

            fetch(saveUrl, {
                method: 'POST',
                credentials: 'same-origin',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrf
                },
                body: JSON.stringify({
                    device_id: '\(token)',
                    device_name: 'iPhone (SAT iOS App)'
                })
            }).then(function(res) {
                return res.json();
            }).then(function(data) {
                console.log('[SAT iOS] /save-web-push-token response:', data);
                if (data && data.status && window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.satPushBridge) {
                    window.webkit.messageHandlers.satPushBridge.postMessage({
                        action: 'fcmTokenRegistered',
                        token: '\(token)'
                    });
                }
            }).catch(function(err) {
                console.error('[SAT iOS] Error saving web push token:', err);
            });
        })();
        """
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    private func deactivateFcmTokenOnBackend() {
        let token = AppConfig.fcmDeviceToken
        guard !token.isEmpty else { return }
        lastRegisteredFcmToken = nil

        let js = """
        (function() {
            var csrfEl = document.querySelector('meta[name="csrf-token"]');
            var csrf = csrfEl ? csrfEl.getAttribute('content') : '';
            var deactUrl = (typeof deactivateWebPushTokenUrl !== 'undefined') ? deactivateWebPushTokenUrl : '/deactivate-web-push-token';

            fetch(deactUrl, {
                method: 'POST',
                credentials: 'same-origin',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrf
                },
                body: JSON.stringify({
                    device_id: '\(token)'
                })
            }).finally(function() {
                console.log('[SAT iOS] Deactivated FCM token on logout');
            });
        })();
        """
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    @objc private func handlePushNotificationTapped(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        print("[WebView] Push notification tapped, navigating with payload: \(userInfo)")

        BadgeManager.shared.syncWithDeliveredNotifications()

        var targetURLString: String? = nil

        if let clickAction = (userInfo["click_action"] as? String) ?? (userInfo["target_url"] as? String), !clickAction.isEmpty {
            targetURLString = clickAction.hasPrefix("http") ? clickAction : "\(AppConfig.baseURL)\(clickAction)"
        } else if let orderId = (userInfo["order_id"] as? Int) ?? Int("\(userInfo["order_id"] ?? "")"), orderId > 0 {
            targetURLString = "\(AppConfig.baseURL)/admin/orders/view/\(orderId)"
        }

        if let urlString = targetURLString, let url = URL(string: urlString) {
            DispatchQueue.main.async {
                self.webView.load(URLRequest(url: url))
            }
        }

        if let jsonData = try? JSONSerialization.data(withJSONObject: userInfo),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            DispatchQueue.main.async {
                self.webView.evaluateJavaScript("if (window.onSATPushNotification) { window.onSATPushNotification(\(jsonString)); }")
            }
        }
    }

    // MARK: - WKScriptMessageHandler (Type-Safe Web to Native Dispatcher)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "satPushBridge" else { return }
        print("[WebView Bridge] Received message from Web JavaScript: \(message.body)")

        guard let dict = message.body as? [String: Any],
              let rawAction = dict["action"] as? String,
              let action = BridgeAction(rawValue: rawAction) else {
            return
        }

        switch action {
        case .fcmTokenRegistered:
            if let token = dict["token"] as? String {
                self.lastRegisteredFcmToken = token
                print("[SAT iOS] Web Push token registered successfully with backend: \(token)")
            }

        case .clearBadge, .resetBadge:
            BadgeManager.shared.clearBadge()

        case .clearAllDeliveredAndBadge:
            BadgeManager.shared.clearAllDeliveredAndBadge()

        case .setBadge:
            let count = (dict["count"] as? Int) ?? Int("\(dict["count"] ?? "")") ?? 0
            BadgeManager.shared.setBadgeCount(count)

        case .decrementBadge:
            let amount = (dict["amount"] as? Int) ?? 1
            BadgeManager.shared.decrementBadgeCount(by: amount)

        case .showLocalNotification, .notify:
            let title = (dict["title"] as? String) ?? "BRE"
            let body = (dict["body"] as? String) ?? (dict["message"] as? String) ?? ""
            guard !body.isEmpty else { return }

            // Native Swift Deduplication Gate: Discard duplicate identical notifications within 30s
            if let lastBody = lastFiredNotificationBody, lastBody == body,
               let lastTime = lastFiredNotificationTime, Date().timeIntervalSince(lastTime) < 30.0 {
                print("[Push Notification] Discarding duplicate native notification within 30s: \(body)")
                return
            }
            lastFiredNotificationBody = body
            lastFiredNotificationTime = Date()

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            content.badge = NSNumber(value: (UIApplication.shared.applicationIconBadgeNumber + 1))
            content.userInfo = dict

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("[Push Notification] Failed to present local notification: \(error)")
                } else {
                    print("[Push Notification] Successfully presented native banner: [\(title)] \(body)")
                }
            }

            // Native haptic feedback
            DispatchQueue.main.async {
                self.notificationFeedback.notificationOccurred(.success)
                self.notificationFeedback.prepare()
            }
        }
    }

    // MARK: - Smart Web Notification Message Detector
    private func detectAndForwardSuccessAlerts() {
        webView.evaluateJavaScript("if (window.satApp && window.satApp.checkSuccessAlerts) { window.satApp.checkSuccessAlerts(); }", completionHandler: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "satPushBridge")
    }

    // MARK: - Static JavaScript Injections
    private static let webBridgePolyfillScript = """
    (function() {
        window.isNativeIOSApp = true;
        window.satApp = {
            postMessage: function(msg) {
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.satPushBridge) {
                    window.webkit.messageHandlers.satPushBridge.postMessage(msg);
                }
            },
            clearBadge: function() {
                this.postMessage({ action: 'clearBadge' });
            },
            setBadge: function(count) {
                this.postMessage({ action: 'setBadge', count: count });
            },
            decrementBadge: function() {
                this.postMessage({ action: 'decrementBadge' });
            }
        };

        // Polyfill window.Notification for in-page web push compatibility
        function MockNotification(title, options) {
            options = options || {};
            var clickAction = (options.data && options.data.click_action) || options.click_action || '';
            window.satApp.postMessage({
                action: 'notify',
                title: title || 'BRE',
                body: options.body || '',
                click_action: clickAction
            });
        }
        MockNotification.permission = 'granted';
        MockNotification.requestPermission = function() {
            return Promise.resolve('granted');
        };
        window.Notification = MockNotification;

        // Polyfill navigator.serviceWorker so web push scripts initialize in WKWebView
        if (navigator && !navigator.serviceWorker) {
            var mockRegistration = {
                scope: '/',
                showNotification: function(title, options) {
                    MockNotification(title, options);
                    return Promise.resolve();
                }
            };
            navigator.serviceWorker = {
                register: function() {
                    return Promise.resolve(mockRegistration);
                },
                ready: Promise.resolve(mockRegistration)
            };
        }
    })();
    """

    private static let successAlertDetectorScript = """
    (function() {
        function cleanText(text) {
            if (!text) return '';
            return text.replace(/^[×xX\\s]+/, '').replace(/[\\s\\r\\n]+/g, ' ').trim();
        }

        function isSuccessElement(el) {
            if (!el) return false;

            if (el.getAttribute('data-sat-notified') === 'true' || el.dataset.satNotified === 'true') {
                return false;
            }

            if (el.classList.contains('alert-danger') ||
                el.classList.contains('alert-error') ||
                el.classList.contains('alert-warning') ||
                el.classList.contains('gritter-error') ||
                el.classList.contains('gritter-warning') ||
                el.classList.contains('validation-error') ||
                el.closest('.alert-danger') ||
                el.closest('.alert-error')) {
                return false;
            }

            var style = window.getComputedStyle(el);
            if (style.display === 'none' || style.visibility === 'hidden' || style.opacity === '0') {
                return false;
            }

            return true;
        }

        function buildWebNotificationMessage() {
            var path = window.location.pathname || '';
            var typeName = 'Expense - Petty Cash';

            if (path.indexOf('cexp-pv') !== -1) {
                typeName = 'Expense - Petty Cash';
            } else if (path.indexOf('advc') !== -1) {
                typeName = 'Advance Cash';
            } else if (path.indexOf('crcpt') !== -1) {
                typeName = 'Cash Receipt';
            } else if (path.indexOf('ctfr') !== -1) {
                typeName = 'Cash Transfer';
            } else if (path.indexOf('sbill') !== -1) {
                typeName = 'Supplier Bill';
            } else if (path.indexOf('day-book') !== -1) {
                typeName = 'Expense';
            } else {
                var h1 = document.querySelector('.content-header h1, h1, .page-title');
                if (h1 && h1.innerText) {
                    var cleaned = cleanText(h1.innerText);
                    if (cleaned.length > 2 && cleaned.indexOf('List') === -1) {
                        typeName = cleaned;
                    }
                }
            }

            var branchName = '';
            var branchSelect = document.querySelector('select[name="merchant_id"], select[name="parent_merchant_id"], select#merchant_id');
            if (branchSelect && branchSelect.selectedIndex >= 0 && branchSelect.options[branchSelect.selectedIndex]) {
                var bText = branchSelect.options[branchSelect.selectedIndex].text;
                if (bText && bText !== 'All' && bText !== 'Select') {
                    branchName = cleanText(bText);
                }
            }
            if (!branchName) {
                var s2Chosen = document.querySelector('.select2-chosen');
                if (s2Chosen && s2Chosen.innerText && s2Chosen.innerText !== 'All') {
                    branchName = cleanText(s2Chosen.innerText);
                }
            }
            if (!branchName) {
                var branchCell = document.querySelector('table tbody tr:first-child td:nth-child(5)');
                if (branchCell && branchCell.innerText) {
                    branchName = cleanText(branchCell.innerText);
                }
            }

            var amount = '';
            var amountCell = document.querySelector('table tbody tr:first-child td.amount, table tbody tr:first-child td:nth-child(6), table tbody tr:first-child td:nth-child(7)');
            if (amountCell && amountCell.innerText) {
                var amtClean = amountCell.innerText.replace(/[^0-9.]/g, '');
                if (amtClean.length > 0 && !isNaN(parseFloat(amtClean))) {
                    amount = amtClean;
                }
            }

            var notif = 'Your ' + typeName;
            if (amount) {
                notif += ' (' + amount + ')';
            }
            if (branchName) {
                notif += ' , ' + branchName + ' Branch';
            }
            notif += ' is Submitted, You can check transactions now.';
            return notif;
        }

        function checkSuccessAlerts() {
            var successSelectors = [
                '.alert-success',
                '.hide-msgs.alert-success',
                'div.alert.alert-success',
                '.alert.alert-block.alert-success',
                '.gritter-item-wrapper.gritter-success .gritter-item',
                '.gritter-item-wrapper .gritter-item'
            ];

            var elements = document.querySelectorAll(successSelectors.join(', '));
            for (var i = 0; i < elements.length; i++) {
                var el = elements[i];
                if (!isSuccessElement(el)) continue;

                var rawText = el.innerText || el.textContent || '';
                var text = cleanText(rawText);

                var lower = text.toLowerCase();
                if (lower.indexOf('error') !== -1 ||
                    lower.indexOf('invalid') !== -1 ||
                    lower.indexOf('failed') !== -1 ||
                    lower.indexOf('danger') !== -1 ||
                    lower.indexOf('wrong') !== -1) {
                    continue;
                }

                if (text.length > 3) {
                    var sigKey = 'sat_success_alert_' + encodeURIComponent(window.location.pathname + '_' + text);
                    if (sessionStorage.getItem(sigKey) === 'fired') {
                        el.setAttribute('data-sat-notified', 'true');
                        continue;
                    }

                    el.setAttribute('data-sat-notified', 'true');
                    sessionStorage.setItem(sigKey, 'fired');

                    var webNotifBody = buildWebNotificationMessage();
                    var currentPath = window.location.pathname + window.location.search;

                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.satPushBridge) {
                        window.webkit.messageHandlers.satPushBridge.postMessage({
                            action: 'notify',
                            title: 'BRE',
                            body: webNotifBody,
                            click_action: currentPath
                        });
                    }
                    break;
                }
            }
        }

        window.satApp = window.satApp || {};
        window.satApp.checkSuccessAlerts = checkSuccessAlerts;

        // Auto-check at document end
        checkSuccessAlerts();

        if (!window._satSuccessObserverAttached) {
            window._satSuccessObserverAttached = true;
            var observer = new MutationObserver(function(mutations) {
                var hasNewAlert = false;
                for (var i = 0; i < mutations.length; i++) {
                    var added = mutations[i].addedNodes;
                    for (var j = 0; j < added.length; j++) {
                        var node = added[j];
                        if (node.nodeType === 1) {
                            if (node.matches && (node.matches('.alert-success, .gritter-item-wrapper') || node.matches('.alert-success *, .gritter-item-wrapper *'))) {
                                hasNewAlert = true;
                                break;
                            } else if (node.querySelector && (node.querySelector('.alert-success') || node.querySelector('.gritter-item-wrapper'))) {
                                hasNewAlert = true;
                                break;
                            }
                        }
                    }
                    if (hasNewAlert) break;
                }
                if (hasNewAlert) {
                    checkSuccessAlerts();
                }
            });
            if (document.body) {
                observer.observe(document.body, { childList: true, subtree: true });
            }
        }
    })();
    """

    // MARK: - WKUserScript: Responsive Modal Fitting Engine (Dual Mode: Daily Entry & Standard Popups)
    private static let modalResponsiveEngineScript = """
    (function() {
        var css = [
            '/* SAT iOS Mobile Viewport & Modal Responsive Override */',
            
            '/* 1. All Voucher Modals across ALL modules (Bills, Payables, Daily Entry, etc.) */',
            'html body div#myVoucherType,',
            'html body #myVoucherType,',
            'html body div#myVoucherType.modal,',
            'html body div#myVoucherType.ags-modal-responsive,',
            'div#myVoucherType.modal,',
            'div#myVoucherType,',
            '#myVoucherType,',
            'html body div#myVoucherTypeView,',
            'html body #myVoucherTypeView,',
            'html body div#myVoucherTypeView.modal,',
            'html body div#myVoucherTypeView.ags-modal-responsive,',
            'div#myVoucherTypeView.modal,',
            'div#myVoucherTypeView,',
            '#myVoucherTypeView,',
            'html body div#ViewNcModel.modal,',
            'html body #ViewNcModel,',
            'html body div#ViewBillModel.modal,',
            'html body #ViewBillModel,',
            'html body div#CloseBillModel.modal,',
            'html body #CloseBillModel,',
            'html body div#StateModel.modal,',
            'html body #StateModel,',
            'html body div#ViewModel.modal:not(.ags-modal-responsive),',
            'html body #ViewModel:not(.ags-modal-responsive),',
            'html body div#ViewModelRole.modal,',
            'html body #ViewModelRole,',
            'html body div#myModal.modal,',
            'html body #myModal,',
            'html body div#viewGI.modal,',
            'html body #viewGI,',
            'html body div.modal:not(.ags-modal-responsive),',
            'html body .modal:not(.ags-modal-responsive),',
            'body div.modal:not(.ags-modal-responsive),',
            'div.modal:not(.ags-modal-responsive) {',
            '    position: fixed !important;',
            '    left: 8px !important;',
            '    right: 8px !important;',
            '    top: 20px !important;',
            '    bottom: auto !important;',
            '    width: auto !important;',
            '    min-width: 0 !important;',
            '    max-width: calc(100vw - 16px) !important;',
            '    margin: 0 !important;',
            '    margin-left: 0 !important;',
            '    margin-right: 0 !important;',
            '    transform: none !important;',
            '    -webkit-transform: none !important;',
            '    box-sizing: border-box !important;',
            '    z-index: 10550 !important;',
            '    max-height: calc(100vh - 40px) !important;',
            '    border-radius: 12px !important;',
            '    box-shadow: 0 12px 35px rgba(0, 0, 0, 0.45) !important;',
            '    background-color: #FFFFFF !important;',
            '}',

            '/* 2. Daily Entry Modals (.ags-modal-responsive) Perfectly Centered */',
            'html body div.modal.ags-modal-responsive:not(#myVoucherType):not(#myVoucherTypeView),',
            'html body div.ags-modal-responsive:not(#myVoucherType):not(#myVoucherTypeView),',
            'html body .ags-modal-responsive:not(#myVoucherType):not(#myVoucherTypeView),',
            'html body div#ViewModeleninCalculater,',
            'html body div#ViewModelTransectionTotal,',
            'html body div#ViewModelVoucherTypes,',
            'html body div#ViewModeladdEntryList,',
            'html body div#ViewModelOpens3data,',
            'html body div#ViewModelcheckDraftOrders,',
            'html body div#ViewModelcheckNeedsClarityOrders {',
            '    position: fixed !important;',
            '    top: 50% !important;',
            '    left: 50% !important;',
            '    right: auto !important;',
            '    bottom: auto !important;',
            '    transform: translate(-50%, -50%) !important;',
            '    -webkit-transform: translate(-50%, -50%) !important;',
            '    width: calc(100vw - 20px) !important;',
            '    max-width: 580px !important;',
            '    margin: 0 !important;',
            '    box-sizing: border-box !important;',
            '    z-index: 10550 !important;',
            '    max-height: calc(100vh - 40px) !important;',
            '    border-radius: 12px !important;',
            '    box-shadow: 0 12px 35px rgba(0, 0, 0, 0.45) !important;',
            '    background-color: #FFFFFF !important;',
            '}',

            '/* Header & Close Buttons */',
            'html body .modal-header,',
            'html body #myVoucherType .modal-header,',
            'html body .ags-modal-header,',
            'html body #myVoucherType .ags-modal-header {',
            '    padding: 12px 16px !important;',
            '    border-bottom: 1px solid #E5E7EB !important;',
            '    background: #F9FAFB !important;',
            '    position: relative !important;',
            '    border-top-left-radius: 12px !important;',
            '    border-top-right-radius: 12px !important;',
            '}',
            'html body .modal-header h3,',
            'html body .modal-header h4,',
            'html body #myVoucherType .modal-header h3,',
            'html body .ags-modal-header h3,',
            'html body #myVoucherType .ags-modal-header h3 {',
            '    margin: 0 !important;',
            '    font-size: 16px !important;',
            '    font-weight: 700 !important;',
            '    color: #1F2937 !important;',
            '    line-height: 1.3 !important;',
            '    overflow: hidden !important;',
            '    text-overflow: ellipsis !important;',
            '    white-space: nowrap !important;',
            '    max-width: calc(100% - 36px) !important;',
            '}',
            'html body .modal-header .close,',
            'html body .modal-header button.close,',
            'html body #myVoucherType .modal-header .close,',
            'html body .ags-modal-header .close,',
            'html body #myVoucherType .ags-modal-header .close {',
            '    position: absolute !important;',
            '    right: 12px !important;',
            '    top: 10px !important;',
            '    font-size: 26px !important;',
            '    font-weight: 300 !important;',
            '    color: #4B5563 !important;',
            '    opacity: 0.85 !important;',
            '    cursor: pointer !important;',
            '    background: transparent !important;',
            '    border: none !important;',
            '    padding: 2px 8px !important;',
            '    line-height: 1 !important;',
            '    z-index: 25 !important;',
            '}',

            '/* Scrollable Body */',
            'html body .modal-body,',
            'html body div.modal .modal-body,',
            'html body .ags-modal-body,',
            'html body div#myVoucherType .modal-body,',
            'html body div#myVoucherType .ags-modal-body {',
            '    max-height: calc(100vh - 160px) !important;',
            '    overflow-y: auto !important;',
            '    -webkit-overflow-scrolling: touch !important;',
            '    padding: 14px !important;',
            '    box-sizing: border-box !important;',
            '}',

            '/* Tables & Form Controls */',
            'html body .modal table,',
            'html body .ags-modal-body table,',
            'html body #myVoucherType table {',
            '    max-width: 100% !important;',
            '    width: 100% !important;',
            '    box-sizing: border-box !important;',
            '}',
            'html body .modal .widget-content,',
            'html body .modal .table-responsive,',
            'html body .ags-modal-body .nopadding,',
            'html body #myVoucherType .widget-content,',
            'html body #myVoucherType .tableFormatVoucher,',
            'html body #myVoucherType div#showViewVoucherType {',
            '    overflow-x: auto !important;',
            '    -webkit-overflow-scrolling: touch !important;',
            '    max-width: 100% !important;',
            '    box-sizing: border-box !important;',
            '}',
            'html body .modal input,',
            'html body .modal textarea,',
            'html body .modal select,',
            'html body #myVoucherType input,',
            'html body #myVoucherType textarea,',
            'html body #myVoucherType select {',
            '    max-width: 100% !important;',
            '    box-sizing: border-box !important;',
            '}',
            'html body #myVoucherType .control-group,',
            'html body #myVoucherType .controls {',
            '    max-width: 100% !important;',
            '    margin-left: 0 !important;',
            '    box-sizing: border-box !important;',
            '}',

            '/* Backdrop */',
            'html body .modal-backdrop,',
            'html body .modal-backdrop.fade.in {',
            '    position: fixed !important;',
            '    top: 0 !important;',
            '    left: 0 !important;',
            '    right: 0 !important;',
            '    bottom: 0 !important;',
            '    width: 100vw !important;',
            '    height: 100vh !important;',
            '    z-index: 10500 !important;',
            '    opacity: 0.55 !important;',
            '    background-color: #000000 !important;',
            '}'
        ].join('\\n');

        function injectOrReorder() {
            var existing = document.getElementById('sat-modal-responsive-engine');
            if (!existing) {
                existing = document.createElement('style');
                existing.id = 'sat-modal-responsive-engine';
                existing.type = 'text/css';
                existing.appendChild(document.createTextNode(css));
            }
            var target = document.head || document.body || document.documentElement;
            if (target && target.lastElementChild !== existing) {
                target.appendChild(existing);
            }
        }

        injectOrReorder();
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', injectOrReorder);
        }
        window.addEventListener('load', injectOrReorder);
    })();
    """
}
