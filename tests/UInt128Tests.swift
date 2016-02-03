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
    let bizarreUInt128: UInt128 = "0xf1f3f5f7f9fbfdfffefcfaf0f8f6f4f2"
    let sanityValue = UInt128(upperBits: 1878316677920070929, lowerBits: 2022432965322149909)
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
        #if arch(i386) || arch (x86_64) || arch(arm) || arch(arm64)
            XCTAssertTrue(testUInt128Native == testUInt128BigEndian)
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
    func testFringeStringConversions() {
        // Test Empty String Input.
        do {
            let _ = try UInt128("")
            XCTFail("Empty String to UInt128 didn't throw")
        } catch UInt128Errors.EmptyString {
            XCTAssert(true)
        } catch {
            XCTFail("Empty String to UInt128 didn't throw correctly")
        }
        // Test out of bounds radix conversion
        do {
            let _ = try UInt128.fromParsedString("01234".utf16, radix: 37)
            XCTFail("Invalid Radix didn't throw")
        } catch UInt128Errors.InvalidRadix {
            XCTAssert(true)
        } catch {
            XCTFail("Invalid Radix didn't throw correctly.")
        }
        // Test 0 output from 0 input.
        let zero = UInt128(0)
        XCTAssert(zero.description == "0")
        // Test String Conversion from UInt128 Input.
        XCTAssertTrue(
            try! UInt128(String(bizarreUInt128)) == bizarreUInt128,
            "UInt128 Input to String Gave Incorrect Result"
        )
    }
    func testBinaryStringConversion() {
        // String conversion test.
        let binaryString = String.init([
            "0b00110100001000100011111000100010001101100011",
            "1100001110100010001000111000001000100100000000",
            "1000100010000000100010001000000010101"
            ].joinWithSeparator("")
        )
        XCTAssertTrue(
            try! UInt128(binaryString) == sanityValue,
            "Basic Binary String to UInt128 conversion failed"
        )
        // Valid string output conversion test (lowercase)
        XCTAssertTrue(
            String(sanityValue, radix: 2, uppercase: false) == String.init([
                "110100001000100011111000100010001101100011",
                "1100001110100010001000111000001000100100000000",
                "1000100010000000100010001000000010101"
                ].joinWithSeparator("")),
            "Basic UInt128 to Binary Lowercase String Conversion Failed"
        )
        // Valid string output conversion test (uppercase)
        XCTAssertTrue(
            String(sanityValue, radix: 2, uppercase: true) == String.init([
                "110100001000100011111000100010001101100011",
                "1100001110100010001000111000001000100100000000",
                "1000100010000000100010001000000010101"
                ].joinWithSeparator("")),
            "Basic UInt128 to Binary Uppercase String Conversion Failed"
        )
        // Invalid characters.
        do {
            let _ = try UInt128("0b002")
            XCTFail("Binary String with Invalid Character didn't throw.")
        } catch UInt128Errors.InvalidStringCharacter {
            XCTAssert(true)
        } catch {
            XCTFail("Binary String with Invalid Character didn't throw correctly.")
        }
        // Overflow.
        do {
            let _ = try UInt128([
                "0b11110100001000100011111000100010001101100011",
                "1100001110100010001000111000001000100100000000",
                "1000100010000000100010001000000010101010101"
                ].joinWithSeparator("")
            )
            XCTFail("Binary String Overflow didn't throw.")
        } catch UInt128Errors.StringInputOverflow {
            XCTAssert(true)
        } catch {
            XCTFail("Binary String Overflow didn't throw correctly.")
        }
    }
    func testOctalStringConversion() {
        // String conversion test.
        XCTAssertTrue(
            try! UInt128("0o00320421742106617035042160211001042004210025") == sanityValue,
            "Basic Octal String to UInt128 conversion failed"
        )
        // Valid string output conversion test (lowercase)
        XCTAssertTrue(
            String(sanityValue, radix: 8, uppercase: false) == "320421742106617035042160211001042004210025",
            "Basic UInt128 to Octal Lowercase String Conversion Failed"
        )
        // Valid string output conversion test (uppercase)
        XCTAssertTrue(
            String(sanityValue, radix: 8, uppercase: true) == "320421742106617035042160211001042004210025",
            "Basic UInt128 to Octal Uppercase String Conversion Failed"
        )
        // Invalid characters.
        do {
            let _ = try UInt128("0o008")
            XCTFail("Octal String with Invalid Character didn't throw.")
        } catch UInt128Errors.InvalidStringCharacter {
            XCTAssert(true)
        } catch {
            XCTFail("Octal String with Invalid Character didn't throw correctly.")
        }
        // Overflow.
        do {
            let _ = try UInt128("0o7654321076543210765432107654321765432107654")
            XCTFail("Octal String overflow didn't throw.")
        } catch UInt128Errors.StringInputOverflow {
            XCTAssert(true)
        } catch {
            XCTFail("Octal String overflow didn't throw correctly.")
        }
    }
    func testDecimalStringConversion() {
        // String input conversion test.
        XCTAssertTrue(
            try! UInt128("0034648827046971881013470724628828721173") == sanityValue,
            "Basic Decimal String to UInt128 conversion failed"
        )
        // Valid string output conversion test (lowercase)
        XCTAssertTrue(
            String(sanityValue, radix: 10, uppercase: false) == "34648827046971881013470724628828721173",
            "Basic UInt128 to Decimal Lowercase String Conversion Failed"
        )
        // Valid string output conversion test (uppercase)
        XCTAssertTrue(
            String(sanityValue, radix: 10, uppercase: true) == "34648827046971881013470724628828721173",
            "Basic UInt128 to Decimal Uppercase String Conversion Failed"
        )
        // Invalid character.
        do {
            let _ = try UInt128("00a")
            XCTFail("Decimal String with Invalid Character didn't throw.")
        } catch UInt128Errors.InvalidStringCharacter {
            XCTAssert(true)
        } catch {
            XCTFail("Decimal String with Invalid Character didn't throw correctly.")
        }
        // Overflow.
        do {
            let _ = try UInt128("987654321098765432109876543210987654320")
            XCTFail("Decimal String overflow didn't throw.")
        } catch UInt128Errors.StringInputOverflow {
            XCTAssert(true)
        } catch {
            XCTFail("Decimal String overflow didn't throw correctly.")
        }
    }
    func testHexadecimalStringConversion() {
        // Valid string input conversion test.
        XCTAssertTrue(
            // StringLiteralConvertible
            try! UInt128("0x001A111F111B1E1D111C11201110111015") == sanityValue,
            "Basic Hexadecimal String to UInt128 Conversion Failed"
        )
        // Valid string output conversion test (lowercase)
        XCTAssertTrue(
            String(sanityValue, radix: 16, uppercase: false) == "1a111f111b1e1d111c11201110111015",
            "Basic UInt128 to Hexadecimal Lowercase String Conversion Failed"
        )
        // Valid string output conversion test (uppercase)
        XCTAssertTrue(
            String(sanityValue, radix: 16, uppercase: true) == "1A111F111B1E1D111C11201110111015",
            "Basic UInt128 to Hexadecimal Uppercase String Conversion Failed"
        )
        // Invalid character.
        do {
            let _ = try UInt128("00g")
            XCTFail("Hexadecimal String with Invalid Character Didn't Throw.")
        } catch UInt128Errors.InvalidStringCharacter {
            XCTAssert(true)
        } catch {
            XCTFail("Hexadecimal String with Invalid Character Didn't Throw Correctly.")
        }
        // Overflow.
        do {
            let _ = try UInt128("0xfedcba9876543210fedcba9876543210f")
            XCTFail("Hexadecimal string overflow didn't throw.")
        } catch UInt128Errors.StringInputOverflow {
            XCTAssert(true)
        } catch {
            XCTFail("Hexadecimal string overflow didn't throw correctly.")
        }
    }
    /*func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }*/
}