//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation

public struct MessagingTokenRequest: Codable {
    let name: String
    let id: String
    let guest_token: String
    let refresh: Bool
}
