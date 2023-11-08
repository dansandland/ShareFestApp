//
//  DateFormatter+actDate.swift
//  ShareFest
//
//  Created by Daniel Sandland on 11/7/23.
//

import Foundation

extension DateFormatter {
    
    static func actDate(fromDate: Date, toDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        
        let formattedFromDate = dateFormatter.string(from: fromDate)
        let formattedToDate = dateFormatter.string(from: toDate)
        
        return "\(formattedFromDate) - \(formattedToDate)"
    }
    
    /// Returns the provided date string as a Date type.
    /// Returns empty Date() object if formatting fails.
    static func actDate(_ dateString: String) -> Date {
        let format = "yyyy-MM-dd'T'HH:mm"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = dateFormatter.date(from: dateString) {
            return date
        }
        
        return Date()
    }
    
}
