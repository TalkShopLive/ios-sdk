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
    case authenticationInvalid
    case sameToken
    case somethingWentWrong
    case httpError(Int)
    case tokenRetrievalFailed
    case invalidShowKey

}

extension APIClientError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .noData:
            return "No data found"
        case .responseDecodingFailed(let error):
            return "Response decoding failed: \(error.localizedDescription)"
        case .invalidData:
            return "Invalid data"
        case .requestDisabled:
            return "Request is disabled"
        case .authenticationInvalid:
            return "Authentication is invalid"
        case .sameToken:
            return "Same token error"
        case .somethingWentWrong:
            return "Something went wrong"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .tokenRetrievalFailed:
            return "Token retrieval failed"
        case .invalidShowKey:
            return "Invalid showKey"
        }
    }
}

public struct EnvConfig: Codable {
    public let PUBLISH_KEY: String
    public let SUBSCRIBE_KEY: String
    public let USER_ID: String
}

public struct APIConfig: Codable {
    public let BASE_URL: String
    public let ASSETS_URL: String
    public let COLLECTOR_BASE_URL: String
    public let EVENTS_BASE_URL: String
}
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
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
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIClientError.invalidData))
                return
            }
            
            // Check for HTTP status code indicating an error
            let statusCode = httpResponse.statusCode
            if statusCode >= 400 {
                let statusCodeError = APIClientError.httpError(statusCode)
                completion(.failure(statusCodeError))
                return
            }else if (200..<299).contains(statusCode) {
                if let data = data, !data.isEmpty {
                    do {
                        // Convert the response data to a JSON string
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        // Handle the case where the response is null by creating an empty instance
                        if json is NSNull {
                            let emptyInstance = try JSONDecoder().decode(T.self, from: "{}".data(using: .utf8)!)
                            completion(.success(emptyInstance))
                            return
                        }
                        
                        let apiResponse = try JSONDecoder().decode(responseType, from: data)
                        completion(.success(apiResponse))
                    } catch {
                        completion(.failure(APIClientError.responseDecodingFailed(error)))
                    }
                } else {
                    // Handle the case where the response data is empty
                    let emptyInstance = try! JSONDecoder().decode(T.self, from: "{}".data(using: .utf8)!)
                    completion(.success(emptyInstance))
                    return
                }
            }
        }
        
        task.resume()
    }
    
    public func requestToRegister<T: Decodable>(clientKey: String, endpoint: APIEndpoint, method: HTTPMethod, body: Encodable?, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        
        let fullURL = endpoint.baseURL + endpoint.path
        
        guard let url = URL(string: fullURL) else {
            completion(.failure(APIClientError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add x-tsl-sdk-key header
        request.addValue(clientKey, forHTTPHeaderField: "x-tsl-sdk-key")

        print("URL", url)
        
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
            
            guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIClientError.invalidData))
                    return
                }
                
            // Check for HTTP status code indicating an error
            let statusCode = httpResponse.statusCode
            if statusCode >= 400 {
                let statusCodeError = APIClientError.httpError(statusCode)
                completion(.failure(statusCodeError))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIClientError.noData))
                return
            }
            
            do {
                // Convert the response data to a JSON string
//                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                print("API Response: ", json)
                
                let apiResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(apiResponse))
            } catch {
                completion(.failure(APIClientError.responseDecodingFailed(error)))
            }
        }
        
        task.resume()
    }
    
    public func requestToken<T: Decodable>(jwtToken: String, endpoint: APIEndpoint, method: HTTPMethod, body: Encodable?, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        
        // Check if the SDK is initialized or not
        guard Config.shared.isInitialized() else {
            print("SDK is not initialized")
            completion(.failure(APIClientError.requestDisabled))
            return
        }
        
        let fullURL = endpoint.baseURL + endpoint.path
        
        guard let url = URL(string: fullURL) else {
            completion(.failure(APIClientError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add x-tsl-sdk-key header
        if let clientKey = Config.shared.getClientKey() {
            request.addValue(clientKey, forHTTPHeaderField: "x-tsl-sdk-key")
        }

        // Add the JWT token to the Authorization header
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        
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
            
            guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIClientError.invalidData))
                    return
                }
                
            // Check for HTTP status code indicating an error
            let statusCode = httpResponse.statusCode
            if statusCode >= 400 {
                let statusCodeError = APIClientError.httpError(statusCode)
                completion(.failure(statusCodeError))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIClientError.noData))
                return
            }
            
            do {
                // Convert the response data to a JSON string
//                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                print("API Response: ", json)
                
                let apiResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(apiResponse))
            } catch {
                completion(.failure(APIClientError.responseDecodingFailed(error)))
            }
        }
        
        task.resume()
    }
    
    public func requestDelete(jwtToken: String? = nil, endpoint: APIEndpoint, method: HTTPMethod, body: Encodable?, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        // Check if the SDK is initialized or not
        guard Config.shared.isInitialized() else {
            print("SDK is not initialized")
            completion(.failure(APIClientError.requestDisabled))
            return
        }
        
        let fullURL = endpoint.baseURL + endpoint.path
        
        guard let url = URL(string: fullURL) else {
            completion(.failure(APIClientError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add x-tsl-sdk-key header
        if let clientKey = Config.shared.getClientKey() {
            request.addValue(clientKey, forHTTPHeaderField: "x-tsl-sdk-key")
        }

        // Add x-tsl-sdk-key header
        if let jwtToken = jwtToken {
            // Add the JWT token to the Authorization header
            request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

        }
        
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
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIClientError.invalidData))
                return
            }
            
            // Check for HTTP status code indicating an error
            let statusCode = httpResponse.statusCode
            if statusCode >= 400 {
                let statusCodeError = APIClientError.httpError(statusCode)
                completion(.failure(statusCodeError))
                return
            }else if (200..<299).contains(statusCode) {
                completion(.success(true))
                return
            } else {
                completion(.failure(error ?? APIClientError.somethingWentWrong))
                return
            }
        }
        
        task.resume()
    }
    
}
