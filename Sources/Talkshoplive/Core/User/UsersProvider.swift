//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation

public class UsersProvider {
    
    // Singleton instance
    public static let shared = UsersProvider()
    
    private var userMetadataDictionary: [String: Sender] = [:]
    
    public init() {
        
    }
    
    // Method to add or update user metadata
    public func setUserMetadata(forUser user: String, metadata: Sender) {
        userMetadataDictionary[user] = metadata
    }
    
    // Method to get metadata for a specific user
    public func getUserMetadata(forUser user: String) -> Sender? {
        return userMetadataDictionary[user]
    }
    
    // MARK: - Private Methods
    internal func fetchUserMetaData(uuid: String, completion: @escaping (Result<Sender, APIClientError>) -> Void) {
        if let userMetadata = self.getUserMetadata(forUser: uuid) {
            completion(.success(userMetadata))
        } else {
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
