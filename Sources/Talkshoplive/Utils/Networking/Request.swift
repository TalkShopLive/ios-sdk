//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation

struct MessagingTokenRequest: Codable {
    let mode: String
    let user: User

    struct User: Codable {
        let prefix: String
    }
}

struct RefreshTokenRequest: Codable {
    let mode: String
    let user: User
    let refresh: Bool

    struct User: Codable {
        let prefix: String
    }
}
