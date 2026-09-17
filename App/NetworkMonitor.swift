import Foundation
import Network

/// Centralized network connectivity monitor for the SAT iOS application.
/// Manages a single shared NWPathMonitor instance across the app,
/// eliminating redundant socket monitoring and ensuring battery efficiency.
final class NetworkMonitor {

    static let shared = NetworkMonitor()

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "SATNetworkMonitorQueue", qos: .background)

    private(set) var isConnected: Bool = true {
        didSet {
            if oldValue != isConnected {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.onStatusChange?(self.isConnected)
                    NotificationCenter.default.post(
                        name: .SATNetworkStatusChanged,
                        object: nil,
                        userInfo: ["isConnected": self.isConnected]
                    )
                }
            }
        }
    }

    /// Optional closure callback triggered when connection status toggles.
    var onStatusChange: ((Bool) -> Void)?

    private init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = (path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}

extension Notification.Name {
    static let SATNetworkStatusChanged = Notification.Name("SATNetworkStatusChanged")
}
