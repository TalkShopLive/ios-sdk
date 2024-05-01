//
//  Config.swift
//
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation

// MARK: - Different environments for the application.
public enum Environment {
    case staging
    case production
}

// MARK: - Config Class

// Config class responsible for managing sdk configuration functionality
public class Config {
    
    // MARK: - Properties
    public static let shared = Config() // Singleton instance
    private var clientKey: String? // TSL autentication key
    private var debugMode: Bool = false // Print all console logs if true
    private var testMode: Bool = false // Switch to staging if true
    private var hasInitialized: Bool = false // SDK initialization
    private var dntMode: Bool = false // Do not track - needed for Abbey/Collector
    
    
    // MARK: - Client Key Methods
    
    /// Set the client key for authentication.
    func setClientKey(_ clientKey: String) {
        self.clientKey = clientKey
    }
    
    /// Get the client key for authentication.
    func getClientKey() -> String? {
        return self.clientKey
    }
    
    // MARK: - Debug Mode Methods
    
    /// Enable or disable debug mode.
    func setDebugMode(_ isDebugMode: Bool) {
        debugMode = isDebugMode
    }
    
    /// Check if debug mode is enabled.
    func isDebugMode() -> Bool {
        return debugMode
    }
    
    // MARK: - Test Mode Methods
    
    /// Enable or disable test mode.
    func setTestMode(_ isTestMode: Bool) {
        testMode = isTestMode
    }
    
    /// Check if test mode is enabled.
    func isTestMode() -> Bool {
        return testMode
    }
    
    // MARK: - SDK Initialization Methods
    
    /// Set whether the SDK has been initialized.
    func setInitialized(_ hasInitialized: Bool) {
        self.hasInitialized = hasInitialized
    }
    
    /// Check if the SDK has been initialized.
    func isInitialized() -> Bool {
        return self.hasInitialized
    }
    
    // MARK: - Do Not Track Mode Methods
    
    /// Enable or disable Do Not Track mode.
    func setDntMode(_ isDntMode: Bool) {
        dntMode = isDntMode
    }
    
    /// Check if Do Not Track mode is enabled.
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

