//
//  NetworkMonitor.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 08/06/2026.
//

import Network
import Foundation

/// Observes device network reachability in real-time.
/// Inject via `.environmentObject(NetworkMonitor.shared)` at the app root.
final class NetworkMonitor: ObservableObject {

    static let shared = NetworkMonitor()

    /// `true` when the device has a usable network path.
    @Published private(set) var isConnected: Bool = true

    private let monitor = NWPathMonitor()
    private let queue   = DispatchQueue(label: "com.climaswift.network.monitor", qos: .utility)

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
