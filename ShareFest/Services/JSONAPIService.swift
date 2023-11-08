//
//  JSONAPIService.swift
//  ShareFest
//
//  Created by Daniel Sandland on 11/7/23.
//

import Combine
import Foundation

struct JSONAPIService: APIService {
    
    func fetchLineup() -> AnyPublisher<[[Act]], APIError> {
        guard let url = Constants.Urls.fetchLineupUrl() else {
            return Fail(error: APIError.invalidUrlString).eraseToAnyPublisher()
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { _ in APIError.invalidRequest }
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                    throw APIError.invalidResponse
                }
                return data
            }
            .decode(type: [[Act]].self, decoder: decoder)
            .mapError { error in
                print("Decoding Error:", error)
                return APIError.decodingError
            }
            .eraseToAnyPublisher()
    }
    
}
