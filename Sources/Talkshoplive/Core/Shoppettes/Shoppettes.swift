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
        completion: @escaping (Result<[ShoppetteData], APIClientError>) -> Void)
    {
        // Fetch show details using the provider
        if !channelId.isEmpty {
            self.shoppettesProvider?.fetchShoppettes(channelId: channelId) {  result in
                switch result {
                case .success(let shoppettes):
                    // Set the details and invoke the completion with success.
                    completion(.success(shoppettes))
                case .failure(let error):
                    // Invoke the completion with failure if an error occurs.
                    Config.shared.isDebugMode() ? print(String(describing: self),"::",error.localizedDescription) : ()
                    completion(.failure(error))
                }
            }
        } else {
            // Error occurred due to channel not found
            completion(.failure(APIClientError.CHANNEL_NOT_FOUND))
        }
        
    }
}
