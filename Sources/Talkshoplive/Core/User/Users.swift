//
//  Users.swift
//  
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation

// MARK: - Users Class

// Users class responsible for managing users-related functionality through UsersProvider
public class Users {
    
    // MARK: - Properties
    public static let shared = Users() // Singleton instance 
    
    // MARK: - Initializer
    init() {
        
    }
    
    // MARK: - Internal Methods

    /// Fetch user metadata from the server.
    /// - Parameters:
    ///   - uuid: The UUID of the user whose metadata is to be fetched.
    ///   - completion: A closure to be executed once the fetching is complete.
    internal func fetchUserMetaData(
        uuid:String,
        completion: @escaping (Result<Sender, APIClientError>) -> Void)
    {
        // Fetch user metadata using the provider
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
