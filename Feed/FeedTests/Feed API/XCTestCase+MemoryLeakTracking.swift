//
//  XCTestCase+MemoryLeakTracking.swift
//  FeedTests
//
//  Created by Julianny Favinha Donda on 17/11/21.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMamoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
