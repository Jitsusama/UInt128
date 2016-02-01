//
// UInt128Tests.swift
//
// UInt128 unit test cases.
//
// Copyright 2016 Joel Gerber
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
// import UInt128 module and mark as testable so we can, y'know, test it.
@testable import UInt128
/// This class' purpose in life is to test UInt128 like there's no tomorrow.
class UInt128Tests: XCTestCase {
    let bizarreUInt128: UInt128 = "0xf0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0"
    override func setUp() {
        super.setUp()
    }
    override func tearDown() {
        super.tearDown()
    }
    func testMax() {
        XCTAssertEqual(
            UInt128.max,
            UInt128(upperBits: UInt64.max, lowerBits: UInt64.max)
        )
    }
    func testMin() {
        XCTAssertEqual(
            UInt128.min,
            UInt128(upperBits: UInt64.min, lowerBits: UInt64.min)
        )
    }
    func testSignificantBits() {
        // Verify 0 = 0 bits long.
        XCTAssertEqual(UInt128(0).significantBits, 0)
        // Verify max = 128 bits long.
        XCTAssertEqual(UInt128.max.significantBits, 128)
        // Verify lower.max = 64 bits long.
        XCTAssertEqual(UInt128(UInt64.max).significantBits, 64)
        // Verify 1 = 1 bits long.
        XCTAssertEqual(UInt128(1).significantBits, 1)
    }
    func testBigEndian() {
        let testUInt128Native: UInt128 = bizarreUInt128
        // Test whether native value matches expected mutated value.
        #if arch(i386) || arch (x86_64) || arch(arm) || arch(arm64)
            XCTAssertFalse(testUInt128Native.bigEndian == testUInt128Native)
        #else
            XCTAssertTrue(testUInt128Native.bigEndian == testUInt128Native)
        #endif
        // Test instantiation with bigEndian value matches expected value.
        let testUInt128BigEndian = UInt128(bigEndian: testUInt128Native.bigEndian)
        let original = String(testUInt128Native.bigEndian, radix: 16)
        let result = String(testUInt128BigEndian, radix: 16)
        #if arch(i386) || arch (x86_64) || arch(arm) || arch(arm64)
            XCTAssertTrue(
                testUInt128Native.bigEndian == testUInt128BigEndian,
                "Result: \(result), Original: \(original)"
            )
        #else
            XCTAssertTrue(testUInt128Native.bigEndian == testUInt128BigEndian)
        #endif
    }
    func testLittleEndian() {
        let testUInt128Native = bizarreUInt128
        #if arch(i386) || arch (x86_64) || arch(arm) || arch(arm64)
            XCTAssertTrue(testUInt128Native.littleEndian == testUInt128Native)
        #else
            XCTAssertFalse(testUInt128Native.bigEndian == testUInt128Native)
        #endif
        let testUInt128LittleEndian = UInt128(littleEndian: testUInt128Native.littleEndian)
        #if arch(i386) || arch (x86_64) || arch(arm) || arch(arm64)
            XCTAssertTrue(
                testUInt128Native.littleEndian == testUInt128LittleEndian,
                "Result:\(testUInt128LittleEndian), Original: \(testUInt128Native)"
            )
        #else
            XCTAssertTrue(testUInt128Native.littleEndian == testUInt128LittleEndian)
        #endif
    }
    /*func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }*/
}