//
//  Shoppettes.swift
//  Talkshoplive
//
//  Created by Talkshoplive on 2025-09-22.
//

import Foundation

// MARK: - Shoppettes Class

// Show class responsible for managing Shoppettes-related functionality through ShoppettesProvider
public class Shoppettes {
    
    // MARK: - Properties
    private var shoppettesProvider: ShoppettesProvider?

    
    // MARK: - Initializer
    public init(jwtToken:String)
    {
        self.shoppettesProvider = ShoppettesProvider(jwtToken: jwtToken)
    }
    
    // MARK: - Public Methods
    /// Get the details of the show.
    public func getShoppettes(
        channelId: String,
        page: Int,
        completion: @escaping (Result<([ShoppettesData],ShoppettesMeta), APIClientError>) -> Void)
    {
        // Fetch show details using the provider
        if !channelId.isEmpty {
            self.shoppettesProvider?.fetchShoppettes(channelId: channelId, page: page) {  result in
                completion(result)
            }
        } else {
            // Error occurred due to channel not found
            completion(.failure(APIClientError.CHANNEL_NOT_FOUND))
        }
        
    }
}
