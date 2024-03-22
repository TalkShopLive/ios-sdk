//
//  File.swift
//
//
//  Created by TalkShopLive on 2024-03-01.
//

import Foundation

extension Date {
    var milliseconds: TimeInterval {
        return self.timeIntervalSince1970 * 1000.0
    }
    func toString(format: String = "yyyy-MM-dd'T'HH:mm:ssZ") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

