//
// APIHandler.swift
//
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation

public class APIHandler {
    private let baseURL: String

    public init() {
        do {
            self.baseURL = try ConfigLoader.loadAPIConfig().BASE_URL
        } catch {
            fatalError("Failed to load configuration: \(error)")
        }
    }

    public func postRequest<T: Decodable>(endpoint: APIEndpoint, body: Encodable, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        let fullURL = baseURL + endpoint.path

        guard let url = URL(string: fullURL) else {
            completion(.failure(APIClientError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let requestBody = try JSONEncoder().encode(body)
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
                let apiResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(apiResponse))
            } catch {
                completion(.failure(APIClientError.responseDecodingFailed(error)))
            }
        }

        task.resume()
    }
}
