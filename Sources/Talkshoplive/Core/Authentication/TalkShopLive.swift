// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import PubNub

public class TalkShopLive {
    
    private let clientKey: String // TSL authentication key
    public let debugMode: Bool
    public let testMode: Bool
    public let dnt: Bool // Do not track - needed for Abbey/Collector
    private var hasInitialized: Bool = false //SDK initialized or not
    
    public init(
        clientKey: String, // Provide a default value or replace with an appropriate default
        debugMode: Bool = false, //Print console logs if true
        testMode: Bool = false, //Switch to staging if true
        dnt: Bool = false,
        completion: ((Result<Void, APIClientError>) -> Void)? = nil)
    {
        self.clientKey = clientKey
        self.debugMode = debugMode
        self.testMode = testMode
        self.dnt = dnt
        
        // Set the debug mode in the shared configuration
        Config.shared.setClientKey(clientKey)
        
        // Set the test mode in the shared configuration
        Config.shared.setTestMode(testMode)
        
        // Set the debug mode in the shared configuration
        Config.shared.setDebugMode(debugMode)
        
        // Set the debug mode in the shared configuration
        Config.shared.setDntMode(dnt)
        
        // Register the SDK using the provided client key
        Networking.register(clientKey: self.clientKey) { result in
            completion?(result)
            //Analytics
            switch result {
            case .success():
                Collector.shared.collect(category: .interaction,action: .sdkInitialized)
            case .failure(_):
                break
            }
        }
    }
}
