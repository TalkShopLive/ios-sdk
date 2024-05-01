//
//  Date_Extension.swift
//
//
//  Created by TalkShopLive on 2024-03-01.
//

import Foundation

// MARK: - Date Extension

extension Date {
    
    /// Property to get the date in milliseconds since the Unix epoch.
    var milliseconds: TimeInterval {
        return self.timeIntervalSince1970 * 1000
    }
    
    /// Property to get the date in nanoseconds since the Unix epoch.
    var nanoseconds: TimeInterval {
        return self.timeIntervalSince1970 * 10000000
    }
    
    /// Convert the date to a string with a specified format.
    /// - Parameter format: The format string for the date. Default is "yyyy-MM-dd'T'HH:mm:ssZ".
    /// - Returns: A string representation of the date.
    func toString(format: String = "yyyy-MM-dd'T'HH:mm:ssZ") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }    
}

