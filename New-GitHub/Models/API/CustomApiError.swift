//
//  CustomApiError.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-09.
//

import Foundation

public enum CustomApiError: Error {
    case badURL, badServerResponse
    case parsingError(String)
    case invalidStatusCode(Int)
    case unknownError(String)
    
    var customDescription: String {
        switch self {
        case .badURL:
            return "Bad URL"
        case .badServerResponse:
            return "Bad server respose"
        case .parsingError(let error):
            return "Failed to parse data: \(error)"
        case .invalidStatusCode(let statusCode):
            return statusCodeDescription(statusCode)
        case .unknownError(let error):
            return "Unknown error: \(error)"
        }
    }
    
    private func statusCodeDescription(_ statusCode: Int) -> String {
        switch statusCode {
        case 400:
            return "Bad Request"
        case 401:
            return "Unauthorized"
        case 403:
            return "Limit reached. Wait a moment and try again."
        case 404:
            return "Not Found"
        case 500:
            return "Internal Server Error"
        case 502:
            return "Bad Gateway"
        case 503:
            return "Service Unavailable"
        case 504:
            return "Gateway Timeout"
        default:
            return "Other Error"
        }
    }
}
