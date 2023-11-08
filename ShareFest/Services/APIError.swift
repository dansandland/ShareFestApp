//
//  APIError.swift
//  ShareFest
//
//  Created by Daniel Sandland on 11/7/23.
//

import Foundation

enum APIError: Error {
    case invalidUrlString
    case invalidRequest
    case invalidResponse
    case decodingError
}
