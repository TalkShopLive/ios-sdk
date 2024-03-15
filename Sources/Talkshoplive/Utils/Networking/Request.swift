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
