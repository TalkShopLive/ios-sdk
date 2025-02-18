//
//  TalkShopLive_Extension.swift
//
//
//  Created by TalkShopLive on 2024-01-26.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// Function to convert a JSON string to a specified model object.
///
/// - Parameters:
///   - from: The JSON string to convert.
///   - responseType: The type of the model object to decode the JSON into.
/// - Returns: An instance of the specified model object if successful, otherwise nil.
func convertToModel<T: Decodable>(
    from: String,
    responseType: T.Type) -> T?
{
    // Check if the JSON string can be converted to Data
    if let jsonData = from.data(using: .utf8) {
        do {
            // Decode JSON data into MessageData object
            let messageData = try JSONDecoder().decode(responseType, from: jsonData)
            return messageData
        } catch {
//          Config.shared.isDebugMode() ? print("Error decoding JSON: \(error)") : ()
            return nil
        }
    } else {
//      Config.shared.isDebugMode() ? print("Error converting payload to Data.") : ()
        return nil
    }
}

func getScreenResolution() -> String {
#if canImport(UIKit)
    
    let screenSize = UIScreen.main.bounds.size
    let scale = UIScreen.main.scale
    let screenWidth = Int(screenSize.width * scale)
    let screenHeight = Int(screenSize.height * scale)
    
    return "\(screenWidth)x\(screenHeight)"
#else
    return "NOT SET"
#endif
}
