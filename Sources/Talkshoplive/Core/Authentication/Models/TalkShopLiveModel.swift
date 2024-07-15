//
//  TalkShopLiveModel.swift
//  
//
//  Created by TalkShopLive on 2024-01-30.
//

import Foundation

// MARK: - StatusCode

// Define an enumeration for status codes with a raw value of String
enum StatusCode: String {
    case ok = "ok"
}

// MARK: - RegisteredClientData

// Define a struct for registered client data that conforms to Codable
public struct RegisteredClientData: Codable {
    
    // Declare a variable to store the status as a String
    public var validKey: Bool?

    // Define CodingKeys enumeration to map keys during encoding and decoding
    enum CodingKeys: String, CodingKey {
        case validKey = "valid_key"
    }

    // Implement the custom initializer required for decoding
    public init(from decoder: Decoder) throws {
        // Create a container using CodingKeys for decoding
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the status from the container, and handle potential errors
        validKey = try container.decodeIfPresent(Bool.self, forKey: .validKey)
    }
}

