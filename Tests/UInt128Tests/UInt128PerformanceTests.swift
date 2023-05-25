//
//  UInt128PerformanceTests.swift
//  UInt128Tests
//
//  Created by Craig A. Munro on 5/17/23.
//

import XCTest

@testable import UInt128

final class UInt128PerformanceTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPerformance_valueToString() throws {
        
        let value = UInt128.max

        let options = XCTMeasureOptions()
        options.iterationCount = 1000
        
        self.measure(options: options) {
            _ = value._valueToString()
        }
    }
    
//    func testPerformance_valueToStringPrevious() throws {
//        
//        let value = UInt128.max
//
//        let options = XCTMeasureOptions()
//        options.iterationCount = 1000
//        
//        self.measure(options: options) {
//            _ = value._valueToStringPrevious()
//        }
//    }
    
    func testPerformance_valueFromString() throws {
        
        let options = XCTMeasureOptions()
        options.iterationCount = 1000
        
        self.measure(options: options) {
            _ = UInt128._valueFromString("0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF")!
        }
    }
}


