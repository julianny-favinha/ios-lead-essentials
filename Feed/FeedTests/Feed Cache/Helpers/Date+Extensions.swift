//
//  Date+Extensions.swift
//  FeedTests
//
//  Created by Julianny Favinha Donda on 29/12/21.
//

import Foundation

extension Date {
    func minusFeedCache() -> Date {
        return adding(days: -7)
    }
    
    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        return self.addingTimeInterval(seconds)
    }
}
