//
// UInt128PerformanceTests.swift
//
// UInt128 performance test cases.
//
// Copyright 2023 Joel Gerber
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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


