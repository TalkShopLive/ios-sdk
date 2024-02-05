//
// APIHandler.swift
//
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation

public enum APIClientError: Error {
    case invalidURL
    case requestFailed(Error)
    case noData
    case responseDecodingFailed(Error)
}

public struct Config: Codable {
    public let PUBLISH_KEY: String
    public let SUBSCRIBE_KEY: String
    public let USER_ID: String
}

public struct APIConfig: Codable {
    public let BASE_URL: String
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    // Add other HTTP methods as needed
}

public class APIHandler {
    private let baseURL: String

    public init() {
        do {
            self.baseURL = try ConfigLoader.loadAPIConfig().BASE_URL
        } catch {
            fatalError("Failed to load configuration: \(error)")
        }
    }

    public func request<T: Decodable>(endpoint: APIEndpoint, method: HTTPMethod, body: Encodable?, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        let fullURL = baseURL + endpoint.path

        guard let url = URL(string: fullURL) else {
            completion(.failure(APIClientError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let param = body {
            do {
                let requestBody = try JSONEncoder().encode(param)
                request.httpBody = requestBody
            } catch {
                completion(.failure(APIClientError.requestFailed(error)))
                return
            }
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
