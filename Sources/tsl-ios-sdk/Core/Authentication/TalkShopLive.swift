// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import PubNub

public class TalkShopLive {
    private let client: APIHandler // Rest API client
    private let clientKey: String // TSL authentication key
    private let debugMode: Bool
    private let dnt: Bool // Do not track - needed for Abbey/Collector
    
    public init(
        clientKey: String = "", // Provide a default value or replace with an appropriate default
        debugMode: Bool = false,
        dnt: Bool = false
    ) {
        self.client = APIHandler() // Initialize your APIHandler instance
        self.clientKey = clientKey
        self.debugMode = debugMode
        self.dnt = dnt
    }
    
    // -- Other methods
}

