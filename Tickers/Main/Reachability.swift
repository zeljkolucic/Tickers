//
//  Reachability.swift
//  Tickers
//
//  Created by Zeljko Lucic on 23.3.24..
//

import SwiftUI
import Network

public final class Reachability: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    
    @Published var isConnected = false
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let newValue = path.status == .satisfied
                if self?.isConnected != newValue {
                    self?.isConnected = newValue
                }
            }
        }
        monitor.start(queue: queue)
    }
}
