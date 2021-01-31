//
//  String+DateExtension.swift
//  TransactionsEngineTests
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import Foundation

extension String {
    public var date: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
}
