//
//  ChatVersionProvider.swift
//  Talkshoplive
//
//  Created by TalkShopLive on 2026-01-27.
//

import Foundation


enum ChatVersion {
    case v1
    case v2
}

enum ChatVersionProvider {
    static func getVersion(showType: ShowType?, isGuest: Bool) -> ChatVersion {
        guard !isGuest else { return .v1 } // Guests always use legacy
        return showType == .legacy ? .v1 : .v2
    }
}
