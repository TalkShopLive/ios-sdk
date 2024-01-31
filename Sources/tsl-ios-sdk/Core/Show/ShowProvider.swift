//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation

protocol ShowProviderData {
    func getDetails(showId:String, completion: @escaping (Result<ShowData, Error>) -> Void)
    func fetchShow(showId:String, completion: @escaping (Result<ShowData, Error>) -> Void)
    // Add other functions as needed
}

