//
//  ShoppettesProvider.swift
//  Talkshoplive
//
//  Created by Talkshoplive on 2025-09-22.
//

import Foundation

// MARK: - ShoppettesProvider Class

// Show class responsible for managing Shoppettes-related functionality
public class ShoppettesProvider {
    
    private var jwtToken: String?
    
    // MARK: - Initializer
    public init(
        jwtToken: String) {
            self.jwtToken = jwtToken
    }
    
    // MARK: - Private Methods

    /// Fetch show details from the network.
    /// - Parameters:
    ///   - showKey: The key of the show to fetch.
    ///   - completion: A closure to be executed once the fetching is complete.
    internal func fetchShoppettes(
        channelId: String,
        completion: @escaping (Result<[ShoppetteData], APIClientError>) -> Void)
    {
        if let jwtToken = self.jwtToken {
            // Call the network function to fetch show details
            Networking.getShoppettes(jwtToken: jwtToken, channelId: channelId, completion: { result in
                completion(result)
            })
        } else {
            completion(.failure(APIClientError.SHOPPETTES_TOKEN_NOT_FOUND))
        }
    }
}
