//
// APIEndpoint.swift
//  
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation

public enum APIEndpoint {
    case messagingToken

    var path: String {
        switch self {
        case .messagingToken:
            return "/api/messaging_tokens"
        }
    }
}
