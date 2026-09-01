import UIKit
import WebKit
import Network

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    private let initialURLString: String
    private var webView: WKWebView!
    private var refreshControl: UIRefreshControl!
    private var offlineOverlayView: UIView!

    // MARK: - Native Blue App Frame
    private let topFrameView = UIView()

    // MARK: - Native Round Activity Loader (Replaces Web Line Loader)
    private let loaderHUD = UIView()
    private let activitySpinner = UIActivityIndicatorView(style: .large)

    private let networkMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "WebNetworkMonitorQueue")
    private var isConnected: Bool = true

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

        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true // Native swipe back/forward
        webView.scrollView.bounces = true
        webView.backgroundColor = UIColor(red: 245/255, green: 247/255, blue: 252/255, alpha: 1.0) // Dashboard light background
        webView.isOpaque = true

        if #available(iOS 16.4, *) {
            webView.isInspectable = true // Safari Web Inspector support
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
        loaderHUD.isHidden = false
        activitySpinner.startAnimating()
        UIView.animate(withDuration: 0.2) {
            self.loaderHUD.alpha = 1.0
        }
    }

    private func hideRoundLoader() {
        UIView.animate(withDuration: 0.25, animations: {
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

    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let isNowConnected = path.status == .satisfied
                self?.isConnected = isNowConnected
                self?.offlineOverlayView.isHidden = isNowConnected
                if isNowConnected {
                    self?.webView.reload()
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

        // Intercept logout to return smoothly to LoginViewController
        if url.absoluteString.contains("/logout") {
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
}
