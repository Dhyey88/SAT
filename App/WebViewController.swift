import UIKit
import WebKit
import Network

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    private let initialURLString: String
    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var refreshControl: UIRefreshControl!
    private var offlineOverlayView: UIView!

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
        setupWebView()
        setupProgressView()
        setupRefreshControl()
        setupOfflineOverlay()
        setupNetworkMonitoring()
        loadInitialURL()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.applicationNameForUserAgent = " SATMobileApp/1.0 (iOS/Swift)"

        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = true
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }

    private func setupProgressView() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
        progressView.trackTintColor = .clear
        view.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2.5)
        ])
    }

    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red: 39/255, green: 169/255, blue: 227/255, alpha: 1.0)
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
    }

    private func setupOfflineOverlay() {
        offlineOverlayView = UIView()
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
        subtitleLabel.text = "Please connect to Wi-Fi or Mobile Data to continue."
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
        retryButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
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
        webView.load(URLRequest(url: url))
    }

    @objc private func handleRefresh() {
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

    // MARK: - Navigation Delegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // Intercept logout to return to LoginViewController
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

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNotConnectedToInternet {
            offlineOverlayView.isHidden = false
        }
        refreshControl.endRefreshing()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
            progressView.isHidden = webView.estimatedProgress >= 1.0
        }
    }

    deinit {
        webView?.removeObserver(self, forKeyPath: "estimatedProgress")
    }
}
