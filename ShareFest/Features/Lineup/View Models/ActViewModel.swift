//
//  ActViewModel.swift
//  ShareFest
//
//  Created by Daniel Sandland on 11/7/23.
//

import Foundation

struct ActViewModel: Identifiable, Hashable {
    let act: Act
    
    var id: Int {
        act.id
    }
    
    var name: String {
        act.name
    }
    
    var location: String {
        act.location
            .components(separatedBy: "_")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    
    var startDate: Date {
        DateFormatter.actDate(act.date)
    }
    
    var endDate: Date {
        DateFormatter.actDate(act.end)
    }
    
    var artistImageUrl: String? {
        act.artistImage
    }
    
    var artistInfo: String? {
        act.artistInfo
    }
    
    // MARK: - Hashable Conformance
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ActViewModel, rhs: ActViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
