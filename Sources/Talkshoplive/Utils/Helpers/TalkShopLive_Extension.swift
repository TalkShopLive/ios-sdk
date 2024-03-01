//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-26.
//

import Foundation

func convertToModel<T: Decodable>(from:String, responseType: T.Type) -> T? {
    if let jsonData = from.data(using: .utf8) {
        do {
            // Decode JSON data into MessageData object
            let messageData = try JSONDecoder().decode(responseType, from: jsonData)
            return messageData
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    } else {
        print("Error converting payload to Data.")
        return nil
    }
}
