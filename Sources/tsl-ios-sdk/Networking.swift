//
//  Networking.swift
//
//
//  Created by TalkShopLive on 2024-01-19.
//

import Foundation

public enum APIClientError: Error {
    case invalidURL
    case requestFailed(Error)
    case noData
    case responseDecodingFailed(Error)
}

public struct MessagingTokenRequest: Codable {
    let name: String
    let id: String
    let guest_token: String
    let refresh: Bool
}

struct MessagingTokenResponse: Codable {
    let user_id: String
    let token: String
}

public class APIClient {
    
    public static func postMessagingToken(completion: @escaping (Result<String, Error>) -> Void) {
        let apiUrl = "https://staging.cms.talkshop.live/api/messaging_tokens"

        guard let url = URL(string: apiUrl) else {
            completion(.failure(APIClientError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let messagingTokenRequest = MessagingTokenRequest(
            name: "Guest User Walmart",
            id: "guest_user_123",
            guest_token: "oyrVT6p94Ep",
            refresh: true // or false
        )

        do {
            let requestBody = try JSONEncoder().encode(messagingTokenRequest)
            request.httpBody = requestBody
        } catch {
            completion(.failure(APIClientError.requestFailed(error)))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(APIClientError.requestFailed(error)))
                return
            }

            guard let data = data else {
                completion(.failure(APIClientError.noData))
                return
            }

            do {
                let apiResponse = try JSONDecoder().decode(MessagingTokenResponse.self, from: data)
                completion(.success(apiResponse.token))
            } catch {
                completion(.failure(APIClientError.responseDecodingFailed(error)))
            }
        }

        task.resume()
    }

}

