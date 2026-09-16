import UIKit
import WebKit
import Network

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

    private let initialURLString: String
    private var webView: WKWebView!
    private var refreshControl: UIRefreshControl!
    private var offlineOverlayView: UIView!

    // MARK: - Native Blue App Frame
    private let topFrameView = UIView()

    // MARK: - Native Round Activity Loader (Replaces Web Line Loader)
    private let loaderHUD = UIView()
    private let activitySpinner = UIActivityIndicatorView(style: .large)
    private var loaderDismissWorkItem: DispatchWorkItem?

    private let networkMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "WebNetworkMonitorQueue")
    private var isConnected: Bool = true
    private var wasOffline: Bool = false
    private var lastRegisteredFcmToken: String? = nil

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
        view.backgroundColor = UIColor(red: 22/255, green: 48/255, blue: 96/255, alpha: 1.0) // Rich SAT Deep Blue

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
    }

    // MARK: - Top Blue App Frame (Covers Status Bar & Encloses Screen)
    private func setupTopFrame() {
        topFrameView.translatesAutoresizingMaskIntoConstraints = false
        topFrameView.backgroundColor = UIColor(red: 22/255, green: 48/255, blue: 96/255, alpha: 1.0) // Android-matched SAT Deep Blue
        view.addSubview(topFrameView)

        NSLayoutConstraint.activate([
            topFrameView.topAnchor.constraint(equalTo: view.topAnchor),
            topFrameView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topFrameView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topFrameView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }

    // MARK: - WKWebView Setup (Enclosed Inside Native App Shell)
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.websiteDataStore = WKWebsiteDataStore.default() // Persistent session & cache
        config.applicationNameForUserAgent = " SATMobileApp/1.0 (iOS/Swift; WKWebView)"

        // Two-way Bridge between Web JavaScript and Native Swift
        let contentController = WKUserContentController()
        contentController.add(self, name: "satPushBridge")

        // Polyfill window.Notification and navigator.serviceWorker for in-page Firebase Web Push compatibility
        let bridgeScript = WKUserScript(
            source: """
            (function() {
                window.isNativeIOSApp = true;
                window.satApp = {
                    postMessage: function(msg) {
                        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.satPushBridge) {
                            window.webkit.messageHandlers.satPushBridge.postMessage(msg);
                        }
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
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        contentController.addUserScript(bridgeScript)
        config.userContentController = contentController

        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true // Native swipe back/forward
        webView.scrollView.bounces = true
        webView.backgroundColor = UIColor(red: 245/255, green: 247/255, blue: 252/255, alpha: 1.0) // Dashboard light background
        webView.isOpaque = true

        if #available(iOS 16.4, *) {
            webView.isInspectable = false // Safari Web Inspector support
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
        loaderHUD.backgroundColor = UIColor(red: 22/255, green: 48/255, blue: 96/255, alpha: 0.92) // Deep SAT Blue Glass HUD
        loaderHUD.layer.cornerRadius = 16
        loaderHUD.layer.shadowColor = UIColor.black.cgColor
        loaderHUD.layer.shadowOpacity = 0.25
        loaderHUD.layer.shadowOffset = CGSize(width: 0, height: 4)
        loaderHUD.layer.shadowRadius = 8
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
            loaderHUD.widthAnchor.constraint(equalToConstant: 72),
            loaderHUD.heightAnchor.constraint(equalToConstant: 72),

            activitySpinner.centerXAnchor.constraint(equalTo: loaderHUD.centerXAnchor),
            activitySpinner.centerYAnchor.constraint(equalTo: loaderHUD.centerYAnchor)
        ])
    }

    private func showRoundLoader() {
        loaderDismissWorkItem?.cancel()
        loaderHUD.isHidden = false
        activitySpinner.startAnimating()
        UIView.animate(withDuration: 0.15) {
            self.loaderHUD.alpha = 1.0
        }

        // Safety auto-dismiss timeout (5 seconds)
        let workItem = DispatchWorkItem { [weak self] in
            self?.hideRoundLoader()
        }
        loaderDismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: workItem)
    }

    private func hideRoundLoader() {
        loaderDismissWorkItem?.cancel()
        loaderDismissWorkItem = nil
        UIView.animate(withDuration: 0.2, animations: {
            self.loaderHUD.alpha = 0.0
        }, completion: { _ in
            self.loaderHUD.isHidden = true
            self.activitySpinner.stopAnimating()
        })
    }

    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
    }

    // MARK: - Native Offline Screen (App Store Guideline 4.2 Compliant)
    private func setupOfflineOverlay() {
        offlineOverlayView = UIView()
        offlineOverlayView.translatesAutoresizingMaskIntoConstraints = false
        offlineOverlayView.backgroundColor = UIColor(red: 22/255, green: 48/255, blue: 96/255, alpha: 1.0)
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
        iconContainer.backgroundColor = UIColor(red: 30/255, green: 60/255, blue: 115/255, alpha: 1.0)
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
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
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
        retryButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        offlineOverlayView.addSubview(retryButton)

        // Offline Contact / Help Button
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
            message: "You are currently offline. You can contact support directly via telephone or email.\n\n• Helpline: \(AppConfig.helplineNumber)\n• Email: \(AppConfig.supportEmail)",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "📞  Call Helpline", style: .default, handler: { _ in
            if let url = URL(string: "tel://\(AppConfig.helplineNumber)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "✉️  Send Support Email", style: .default, handler: { _ in
            if let url = URL(string: "mailto:\(AppConfig.supportEmail)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Smart Network Monitoring (Prevents Redundant Auto-Reloads)
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let isNowConnected = path.status == .satisfied
                self.isConnected = isNowConnected
                self.offlineOverlayView.isHidden = isNowConnected

                if !isNowConnected {
                    self.wasOffline = true
                } else if self.wasOffline {
                    // Only reload when recovering from a true disconnected state
                    self.wasOffline = false
                    self.webView.reload()
                }
            }
        }
        networkMonitor.start(queue: monitorQueue)
    }

    private func loadInitialURL() {
        guard let url = URL(string: initialURLString) else { return }
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        webView.load(request)
    }

    @objc private func handleRefresh() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        if networkMonitor.currentPath.status == .satisfied {
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

    // MARK: - WKNavigationDelegate (Native Round Spinner Control & Apple Standards)
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

        // Smart Success-Only Detector: check for "Record added successfully" and forward to native iOS notification
        detectAndForwardSuccessAlerts()
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
        refreshControl.endRefreshing()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // Intercept logout to deactivate FCM token and return smoothly to LoginViewController
        if url.absoluteString.contains("/logout") {
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
        // Apple Crash Recovery: Automatically reload web content if process was killed by iOS
        webView.reload()
    }

    // MARK: - WKUIDelegate (Native iOS Alerts per Apple Documentation)
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

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
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

        // Bridge to WebView JS runtime in case frontend web code listens for in-app events
        if let jsonData = try? JSONSerialization.data(withJSONObject: userInfo),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            DispatchQueue.main.async {
                self.webView.evaluateJavaScript("if (window.onSATPushNotification) { window.onSATPushNotification(\(jsonString)); }")
            }
        }
    }

    // MARK: - WKScriptMessageHandler (Web to Native Communication)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "satPushBridge" else { return }
        print("[WebView Bridge] Received message from Web JavaScript: \(message.body)")

        if let dict = message.body as? [String: Any] {
            let action = dict["action"] as? String ?? ""
            if action == "fcmTokenRegistered" {
                if let token = dict["token"] as? String {
                    self.lastRegisteredFcmToken = token
                    print("[SAT iOS] Web Push token registered successfully with backend: \(token)")
                }
            } else if action == "showLocalNotification" || action == "notify" {
                let title = (dict["title"] as? String) ?? "BRE"
                let body = (dict["body"] as? String) ?? (dict["message"] as? String) ?? ""
                if !body.isEmpty {
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
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }
                }
            }
        }
    }

    // MARK: - Smart Web Notification Message Detector
    private func detectAndForwardSuccessAlerts() {
        let js = """
        (function() {
            function cleanText(text) {
                if (!text) return '';
                return text.replace(/^[×xX\\s]+/, '').replace(/[\\s\\r\\n]+/g, ' ').trim();
            }

            function isSuccessElement(el) {
                if (!el) return false;

                // STRICT NEGATIVE FILTER: Must NOT be an error, danger, or warning
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

                // Check element visibility
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

                // Extract Branch Name
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

                // Extract Amount
                var amount = '';
                var amountCell = document.querySelector('table tbody tr:first-child td.amount, table tbody tr:first-child td:nth-child(6), table tbody tr:first-child td:nth-child(7)');
                if (amountCell && amountCell.innerText) {
                    var amtClean = amountCell.innerText.replace(/[^0-9.]/g, '');
                    if (amtClean.length > 0 && !isNaN(parseFloat(amtClean))) {
                        amount = amtClean;
                    }
                }

                // Format exact message matching CexpPVController.php:1451
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

                    // Additional negative safety check on message content
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
                        var lastFired = parseInt(sessionStorage.getItem(sigKey) || '0', 10);
                        var now = Date.now();

                        // 5-second anti-bounce cooldown
                        if (now - lastFired > 5000) {
                            sessionStorage.setItem(sigKey, String(now));

                            // Build the exact web notification message
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
            }

            checkSuccessAlerts();

            // Observe dynamic DOM changes (e.g. AJAX or Single-page form submits)
            if (!window._satSuccessObserverAttached) {
                window._satSuccessObserverAttached = true;
                var observer = new MutationObserver(function(mutations) {
                    checkSuccessAlerts();
                });
                if (document.body) {
                    observer.observe(document.body, { childList: true, subtree: true });
                }
            }
        })();
        """
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "satPushBridge")
    }
}
