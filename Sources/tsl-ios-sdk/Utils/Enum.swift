//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation


public enum APIClientError: Error {
    case invalidURL
    case requestFailed(Error)
    case noData
    case responseDecodingFailed(Error)
}

public enum ConfigError: Error {
    case invalidConfigFile
}
