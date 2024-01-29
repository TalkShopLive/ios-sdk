//
//  File.swift
//  
//
//  Created by Mayuri on 2024-01-24.
//

import Foundation

public class ShowService: ShowProvider {
   
    let productKey: String
    
    init(productKey: String) {
        self.productKey = productKey
    }

    public func getShows(completion: @escaping (Result<TSLShow, Error>) -> Void) {
        Networking.getShows(productKey: self.productKey) { result in
            switch result {
            case .success(let apiResponse):
                completion(.success(apiResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    

}
