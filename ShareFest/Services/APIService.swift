//
//  APIService.swift
//  ShareFest
//
//  Created by Daniel Sandland on 11/7/23.
//

import Combine
import Foundation

protocol APIService {
    /// Fetches lineup data and returns an array of acts for each day of the festival.
    func fetchLineup() -> AnyPublisher<[[Act]], APIError>
}
