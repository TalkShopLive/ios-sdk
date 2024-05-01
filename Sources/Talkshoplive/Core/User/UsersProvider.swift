//
//  UsersProvider.swift
//
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation

// MARK: - UsersProvider Class

// Users class responsible for managing users-related functionality 
public class UsersProvider {
    
    // MARK: - Properties
    public static let shared = UsersProvider() // Singleton instance
    private var userMetadataDictionary: [String: Sender] = [:]
    
    // MARK: - Initializer
    public init() {
        
    }
    
    // MARK: - Public Methods
    
    // Method to add or update user metadata
    public func setUserMetadata(forUser user: String, metadata: Sender) {
        userMetadataDictionary[user] = metadata
    }
    
    // Method to get metadata for a specific user
    public func getUserMetadata(forUser user: String) -> Sender? {
        return userMetadataDictionary[user]
    }
    
    // MARK: - Private Methods
    
    /// Fetch user metadata from the network.
    /// - Parameters:
    ///   - uuid: The UUID of the user whose metadata is to be fetched.
    ///   - completion: A closure to be executed once the fetching is complete.
    internal func fetchUserMetaData(
        uuid: String,
        completion: @escaping (Result<Sender, APIClientError>) -> Void)
    {
        // Check if user metadata exists in the dictionary
        if let userMetadata = self.getUserMetadata(forUser: uuid) {
            // If metadata exists in the dictionary, return it
            completion(.success(userMetadata))
        } else {
            // If metadata doesn't exist in the dictionary, fetch it from the network
            Networking.getUserMetadata(uuid: uuid) { result in
                switch result {
                case .success(let senderData):
                    // Save sender data to the dictionary for future use
                    self.setUserMetadata(forUser: uuid, metadata: senderData)
                    completion(.success(senderData))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
    }
    
}
