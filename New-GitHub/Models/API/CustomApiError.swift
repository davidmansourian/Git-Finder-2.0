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
            return "Invalid status code: \(statusCode)"
        case .unknownError(let error):
            return "Unknown error: \(error)"
        }
    }
}
