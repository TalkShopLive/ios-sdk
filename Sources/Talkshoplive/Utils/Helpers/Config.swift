//
//  Config.swift
//
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation

// MARK: - Configuration Singleton

public class Config {
    
    // MARK: - Singleton
    
    public static let shared = Config()
    
    // MARK: - Properties
    private var clientKey: String? // Print all console logs
    private var debugMode: Bool = false // Print all console logs
    private var testMode: Bool = false // Switch to staging if true
    private var hasInitialized: Bool = false // SDK initialization
    
    
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
    
    // MARK: - Configuration Loading Methods
    
    /// Load environment configuration from the "env.json" file in the module's bundle.
    /// - Returns: An instance of EnvConfig with loaded configuration.
    public static func loadConfig() throws -> EnvConfig {
        guard let fileURL = Bundle.module.url(forResource: "env", withExtension: "json") else {
            return EnvConfig.init(PUBLISH_KEY: "", SUBSCRIBE_KEY: "", USER_ID: "")
        }
        
        let data = try Data(contentsOf:fileURL)
        let decoder = JSONDecoder()
        return try decoder.decode(EnvConfig.self, from: data)
    }
    
    /// Load API configuration based on the test mode ("Staging.json" for testMode=true, "Production.json" otherwise).
    /// - Returns: An instance of APIConfig with loaded configuration.
    public static func loadAPIConfig() throws -> APIConfig {
        var fileName = ""
        if Config.shared.isTestMode() {
            fileName = "Staging"
        } else {
            fileName = "Production"
        }
        
        guard let fileURL = Bundle.module.url(forResource: fileName, withExtension: "json") else {
            return APIConfig.init(BASE_URL: "", ASSETS_URL: "")
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        return try decoder.decode(APIConfig.self, from: data)
    }
}

