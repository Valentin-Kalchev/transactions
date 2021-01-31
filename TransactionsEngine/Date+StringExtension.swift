//
//  Date+StringExtension.swift
//  TransactionsEngineTests
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import Foundation

extension Date {
    public var string: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}
