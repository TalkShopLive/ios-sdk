//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation

public class Users {
    
    // MARK: - Singleton
    
    public static let shared = Users()
    
    // MARK: - Properties
    
    init() {
        
    }
    
    internal func fetchUserMetaData(uuid:String,completion: @escaping (Result<Sender, APIClientError>) -> Void) {
        UsersProvider().fetchUserMetaData(uuid: uuid) { result in
            switch result {
            case .success(let userMetadata):
                // Set the details and invoke the completion with success.
                completion(.success(userMetadata))
            case .failure(let error):
                // Invoke the completion with failure if an error occurs.
                completion(.failure(error))
            }
        }
    }
}
