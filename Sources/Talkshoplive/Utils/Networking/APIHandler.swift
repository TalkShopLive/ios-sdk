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
    case invalidData
    case requestDisabled
}

public struct EnvConfig: Codable {
    public let PUBLISH_KEY: String
    public let SUBSCRIBE_KEY: String
    public let USER_ID: String
}

public struct APIConfig: Codable {
    public let BASE_URL: String
    public let ASSETS_URL: String
    
}
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    // Add other HTTP methods as needed
}

public class APIHandler {
    public init() {
        
    }
    
    public func request<T: Decodable>(endpoint: APIEndpoint, method: HTTPMethod, body: Encodable?, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        
        // Check if the SDK is initialized or not
        guard Config.shared.isInitialized() else {
            print("SDK is not initialized")
            completion(.failure(APIClientError.requestDisabled))
            return
        }
        
        let fullURL = endpoint.baseURL + endpoint.path
        print(fullURL)
        
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
                // Convert the response data to a JSON string
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print("API Response: ", json)
                
                let apiResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(apiResponse))
            } catch {
                completion(.failure(APIClientError.responseDecodingFailed(error)))
            }
        }
        
        task.resume()
    }
    
    public func requestToRegister<T: Decodable>(endpoint: APIEndpoint, method: HTTPMethod, body: Encodable?, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        
        let fullURL = endpoint.baseURL + endpoint.path
        print(fullURL)
        
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
                // Convert the response data to a JSON string
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print("API Response: ", json)
                
                let apiResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(apiResponse))
            } catch {
                completion(.failure(APIClientError.responseDecodingFailed(error)))
            }
        }
        
        task.resume()
    }
    
}