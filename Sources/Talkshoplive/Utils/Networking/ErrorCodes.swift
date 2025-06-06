//
//  ErrorCodes.swift
//
//
//  Created by TalkShopLive on 2024-03-27.
//

import Foundation

// MARK: - Error codes for the API client.
public enum APIClientError: Error{
    case INVALID_URL
    case REQUEST_FAILED(Error)
    case NO_DATA
    case USER_ALREADY_AUTHENTICATED
    case HTTP_ERROR(Int)
    case AUTHENTICATION_FAILED
    case AUTHENTICATION_EXCEPTION
    case SHOW_NOT_FOUND
    case SHOW_NOT_LIVE
    case EVENT_NOT_FOUND
    case EVENT_UNKNOWN_EXCEPTION
    case PRODUCT_NOT_FOUND
    case INVALID_USER_TOKEN
    case USER_TOKEN_EXPIRED
    case USER_TOKEN_EXCEPTION
    case MESSAGE_SENDING_FAILED
    case MESSAGE_SENDING_GIPHY_DATA_NOT_FOUND
    case MESSAGE_LIST_FAILED
    case LIKE_COMMENT_FAILED
    case UNLIKE_COMMENT_FAILED
    case CHAT_TIMEOUT
    case UNKNOWN_EXCEPTION
    case PERMISSION_DENIED
    case CHAT_CONNECTION_ERROR
    case CHAT_TOKEN_EXPIRED
}

// MARK: - APIClientError extension

extension APIClientError: LocalizedError {
    /// Localized description for each error case.
    public var localizedDescription: String {
        switch self {
        case .INVALID_URL:
            return "Invalid API URL"
        case .REQUEST_FAILED(let error):
            return "API Request failed: \(error.localizedDescription)"
        case .NO_DATA:
            return "No data found"
        case .USER_ALREADY_AUTHENTICATED:
            return "Same token error"
        case .HTTP_ERROR(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .AUTHENTICATION_FAILED:
            return "Authentication failed"
        case .AUTHENTICATION_EXCEPTION:
            return "Authentication exception"
        case .SHOW_NOT_FOUND:
            return "Show not found"
        case .SHOW_NOT_LIVE:
            return "Show not live"
        case .EVENT_NOT_FOUND:
            return "Event not found"
        case .EVENT_UNKNOWN_EXCEPTION:
            return "Event unknown exception"
        case .PRODUCT_NOT_FOUND:
            return "Product not found"
        case .INVALID_USER_TOKEN:
            return "Invalid user token"
        case .USER_TOKEN_EXPIRED:
            return "User token expired"
        case .USER_TOKEN_EXCEPTION:
            return "User token exception"
        case .MESSAGE_SENDING_FAILED:
            return "Message sending failed"
        case . MESSAGE_SENDING_GIPHY_DATA_NOT_FOUND:
            return "Giphy data not found"
        case .MESSAGE_LIST_FAILED:
            return "Message list failed"
        case .LIKE_COMMENT_FAILED:
            return "Like comment failed"
        case .UNLIKE_COMMENT_FAILED:
            return "Unlike comment failed"
        case .CHAT_TIMEOUT:
            return "Chat timeout"
        case .UNKNOWN_EXCEPTION:
            return "Unknown exception"
        case .PERMISSION_DENIED:
            //If token is revoked
            return "Permission Denied"
        case .CHAT_CONNECTION_ERROR:
            return "Chat connection error"
        case .CHAT_TOKEN_EXPIRED :
            return "Chat token expired"
        }
    }
}
