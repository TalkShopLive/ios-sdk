//
// APIHandler.swift
//
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation

// MARK: - APIConfig Structure
public struct APIConfig: Codable {
    public let BASE_URL: String
    public let ASSETS_URL: String
    public let COLLECTOR_BASE_URL: String
    public let EVENTS_BASE_URL: String
}

// MARK: - HTTP methods
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    // Add other HTTP methods as needed
}

// MARK: - APIHandler Class 

// APIHandler class responsible for handling API requests.
public class APIHandler {
    
    // MARK: - Initializer
    public init() {
        
    }

    // MARK: - API Requests Methods

    /// Performs an API request.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint to which the request will be made.
    ///   - method: The HTTP method for the request.
    ///   - body: The body of the request, if any.
    ///   - responseType: The type of the expected response.
    ///   - completion: The completion handler to call when the request finishes.
    public func request<T: Decodable>(
        endpoint: APIEndpoint,
        method: HTTPMethod,
        body: Encodable?,
        responseType: T.Type,
        completion: @escaping (Result<T, APIClientError>) -> Void)
    {
        // Check if the SDK is initialized or not
        guard Config.shared.isInitialized() else {
            print("SDK is not initialized")
            completion(.failure(APIClientError.AUTHENTICATION_EXCEPTION))
            return
        }
        
        let fullURL = endpoint.baseURL + endpoint.path
        
        guard let url = URL(string: fullURL) else {
            Config.shared.isDebugMode() ? print("TSL.",APIClientError.INVALID_URL) : ()
            completion(.failure(APIClientError.INVALID_URL))
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
                Config.shared.isDebugMode() ? print("TSL.",APIClientError.REQUEST_FAILED(error)) : ()
                completion(.failure(APIClientError.REQUEST_FAILED(error)))
                return
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                Config.shared.isDebugMode() ? print("TSL.",APIClientError.REQUEST_FAILED(error)) : ()
                completion(.failure(APIClientError.REQUEST_FAILED(error)))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIClientError.UNKNOWN_EXCEPTION))
                return
            }
            
            // Check for HTTP status code indicating an error
            let statusCode = httpResponse.statusCode
            if statusCode >= 400 {
                let statusCodeError = APIClientError.HTTP_ERROR(statusCode)
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
                        completion(.failure(APIClientError.UNKNOWN_EXCEPTION))
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
    
    /// Performs an API request with additional client key.
    public func requestToRegister<T: Decodable>(
        clientKey: String,
        endpoint: APIEndpoint,
        method: HTTPMethod,
        body: Encodable?,
        responseType: T.Type,
        completion: @escaping (Result<T, APIClientError>) -> Void)
    {
        let fullURL = endpoint.baseURL + endpoint.path
        
        guard let url = URL(string: fullURL) else {
            Config.shared.isDebugMode() ? print("TSL.",APIClientError.INVALID_URL) : ()
            completion(.failure(APIClientError.INVALID_URL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add x-tsl-sdk-key header
        request.addValue(clientKey, forHTTPHeaderField: "x-tsl-sdk-key")
        
        if let param = body {
            do {
                let requestBody = try JSONEncoder().encode(param)
                request.httpBody = requestBody
            } catch {
                Config.shared.isDebugMode() ? print("TSL.",APIClientError.REQUEST_FAILED(error)) : ()
                completion(.failure(APIClientError.REQUEST_FAILED(error)))
                return
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                Config.shared.isDebugMode() ? print("TSL.",APIClientError.REQUEST_FAILED(error)) : ()
                completion(.failure(APIClientError.REQUEST_FAILED(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIClientError.UNKNOWN_EXCEPTION))
                    return
                }
                
            // Check for HTTP status code indicating an error
            let statusCode = httpResponse.statusCode
            if statusCode >= 400 {
                let statusCodeError = APIClientError.HTTP_ERROR(statusCode)
                completion(.failure(statusCodeError))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIClientError.NO_DATA))
                return
            }
            
            do {
                // Convert the response data to a JSON string
//                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                print("API Response: ", json)
                
                let apiResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(apiResponse))
            } catch {
                completion(.failure(APIClientError.UNKNOWN_EXCEPTION))
            }
        }
        
        task.resume()
    }
    
    /// Performs an API request with a JWT token.
    public func requestToken<T: Decodable>(
        jwtToken: String,
        endpoint: APIEndpoint,
        method: HTTPMethod,
        body: Encodable?,
        responseType: T.Type,
        completion: @escaping (Result<T, APIClientError>) -> Void)
    {
        // Check if the SDK is initialized or not
        guard Config.shared.isInitialized() else {
            print("SDK is not initialized")
            completion(.failure(APIClientError.AUTHENTICATION_EXCEPTION))
            return
        }
        
        let fullURL = endpoint.baseURL + endpoint.path
        
        guard let url = URL(string: fullURL) else {
            Config.shared.isDebugMode() ? print("TSL.",APIClientError.INVALID_URL) : ()
            completion(.failure(APIClientError.INVALID_URL))
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
                Config.shared.isDebugMode() ? print("TSL.",APIClientError.REQUEST_FAILED(error)) : ()
                completion(.failure(APIClientError.REQUEST_FAILED(error)))
                return
            }
        }
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                Config.shared.isDebugMode() ? print("TSL.",APIClientError.REQUEST_FAILED(error)) : ()
                completion(.failure(APIClientError.REQUEST_FAILED(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIClientError.UNKNOWN_EXCEPTION))
                    return
                }
                
            // Check for HTTP status code indicating an error
            let statusCode = httpResponse.statusCode
            if statusCode >= 400 {
                let statusCodeError = APIClientError.HTTP_ERROR(statusCode)
                completion(.failure(statusCodeError))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIClientError.NO_DATA))
                return
            }
            
            do {
                // Convert the response data to a JSON string
//                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                print("API Response: ", json)
                
                let apiResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(apiResponse))
            } catch {
                completion(.failure(APIClientError.UNKNOWN_EXCEPTION))
            }
        }
        
        task.resume()
    }
    
    /// Performs an API request for deletion.
    public func requestDelete(
        jwtToken: String? = nil,
        endpoint: APIEndpoint,
        method: HTTPMethod,
        body: Encodable?,
        completion: @escaping (Result<Bool, APIClientError>) -> Void)
    {
        // Check if the SDK is initialized or not
        guard Config.shared.isInitialized() else {
            print("SDK is not initialized")
            completion(.failure(APIClientError.AUTHENTICATION_EXCEPTION))
            return
        }
        
        let fullURL = endpoint.baseURL + endpoint.path
        
        guard let url = URL(string: fullURL) else {
            Config.shared.isDebugMode() ? print("TSL.",APIClientError.INVALID_URL) : ()
            completion(.failure(APIClientError.INVALID_URL))
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
                Config.shared.isDebugMode() ? print("TSL.",APIClientError.REQUEST_FAILED(error)) : ()
                completion(.failure(APIClientError.REQUEST_FAILED(error)))
                return
            }
        }
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                Config.shared.isDebugMode() ? print("TSL.",APIClientError.REQUEST_FAILED(error)) : ()
                completion(.failure(APIClientError.REQUEST_FAILED(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIClientError.UNKNOWN_EXCEPTION))
                return
            }
            
            // Check for HTTP status code indicating an error
            let statusCode = httpResponse.statusCode
            if statusCode >= 400 {
                let statusCodeError = APIClientError.HTTP_ERROR(statusCode)
                completion(.failure(statusCodeError))
                return
            }else if (200..<299).contains(statusCode) {
                completion(.success(true))
                return
            } else {
                completion(.failure(APIClientError.UNKNOWN_EXCEPTION))
                return
            }
        }
        
        task.resume()
    }
    
}
