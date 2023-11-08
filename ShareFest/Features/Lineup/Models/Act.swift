//
//  Act.swift
//  ShareFest
//
//  Created by Daniel Sandland on 11/7/23.
//

import Foundation

struct Act: Decodable {
    let id: Int
    let name: String
    let location: String
    let date: String
    let end: String
    let artistImage: String?
    let artistInfo: String?
}
