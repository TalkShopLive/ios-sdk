//
//  File.swift
//  
//
//  Created by Mayuri on 2024-01-26.
//

import Foundation

public extension TSLSDK {
    func getShows(productKey:String, completion: @escaping (Result<TSLShow, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let showService = ShowService(productKey: productKey)
            showService.getShows { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
}
