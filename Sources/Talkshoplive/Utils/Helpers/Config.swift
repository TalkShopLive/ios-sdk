//
//  Config.swift
//
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation

// MARK: - Configuration Singleton


public enum Environment {
    case staging
    case production
}

public class Config {
    
    // MARK: - Singleton
    
    public static let shared = Config()
    
    // MARK: - Properties
    private var clientKey: String? // Print all console logs
    private var debugMode: Bool = false // Print all console logs
    private var testMode: Bool = false // Switch to staging if true
    private var hasInitialized: Bool = false // SDK initialization
    private var dntMode: Bool = false // Print all console logs
    
    
    // MARK: - Debug Mode Methods
    func setClientKey(_ clientKey: String) {
        self.clientKey = clientKey
    }
    
    func getClientKey() -> String? {
        return self.clientKey
    }
    
    // MARK: - Debug Mode Methods
    func setDebugMode(_ isDebugMode: Bool) {
        debugMode = isDebugMode
    }
    
    func isDebugMode() -> Bool {
        return debugMode
    }
    
    // MARK: - Test Mode Methods
    
    func setTestMode(_ isTestMode: Bool) {
        testMode = isTestMode
    }
    
    func isTestMode() -> Bool {
        return testMode
    }
    
    // MARK: - Initialization Methods
    
    func setInitialized(_ hasInitialized: Bool) {
        self.hasInitialized = hasInitialized
    }
    
    func isInitialized() -> Bool {
        return self.hasInitialized
    }
    
    // MARK: - Debug Mode Methods
    func setDntMode(_ isDntMode: Bool) {
        dntMode = isDntMode
    }
    
    func isDntMode() -> Bool {
        return self.dntMode
    }
    
    // MARK: - Configuration Loading Methods
    
    /// Load API configuration based on the test mode ("Staging.json" for testMode=true, "Production.json" otherwise).
    /// - Returns: An instance of APIConfig with loaded configuration.
    public static func loadAPIConfig() throws -> APIConfig {
        var environment : Environment
        if Config.shared.isTestMode() {
            environment = .staging
        } else {
            environment = .production
        }
        switch environment {
                case .staging:
                    return APIConfig(
                        BASE_URL: "https://staging.cms.talkshop.live",
                        ASSETS_URL: "https://assets-dev.talkshop.live",
                        COLLECTOR_BASE_URL: "https://staging.collector.talkshop.live",
                        EVENTS_BASE_URL: "https://staging.events-api.talkshop.live"
                    )
                case .production:
                    return APIConfig(
                        BASE_URL: "https://cms.talkshop.live",
                        ASSETS_URL: "https://assets.talkshop.live",
                        COLLECTOR_BASE_URL: "https://collector.talkshop.live",
                        EVENTS_BASE_URL: "https://events-api.talkshop.live"
                    )
                }
    }
}

