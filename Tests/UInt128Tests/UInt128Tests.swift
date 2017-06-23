//
// UInt128UnitTests.swift
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

// Import UInt128 module and mark as testable so we can, y'know, test it.
@testable import UInt128

// A UInt128 with a decently complicated bit pattern
let bizarreUInt128: UInt128 = "0xf1f3f5f7f9fbfdfffefcfaf0f8f6f4f2"

/// User tests that act as a basic smoke test on library functionality.
class SystemTests : XCTestCase {
    func testCanReceiveAnInt() {
        let expectedResult = UInt128(upperBits: 0, lowerBits: 1)
        let testResult = UInt128(Int(1))
        XCTAssertEqual(testResult, expectedResult)
    }
    
    func testCanBeSentToAnInt() {
        let expectedResult: Int = 1
        let testResult = Int(UInt128(upperBits: 0, lowerBits: 1))
        XCTAssertEqual(testResult, expectedResult)
    }
    
    func testIntegerLiteralInput() {
        let expectedResult = UInt128(upperBits: 0, lowerBits: 1)
        let testResult: UInt128 = 1
        XCTAssertEqual(testResult, expectedResult)
    }
    
    func testCanReceiveAString() {
        let expectedResult = UInt128(upperBits: 0, lowerBits: 1)
        let testResult = try! UInt128(String("1"))
        XCTAssertEqual(testResult, expectedResult)
    }
    
    func testStringLiteralInput() {
        let expectedResult = UInt128(upperBits: 0, lowerBits: 1)
        let testResult: UInt128 = "1"
        XCTAssertEqual(testResult, expectedResult)
    }
    
    func testCanBeSentToAFloat() {
        let expectedResult: Float = 1
        let testResult = Float(UInt128(upperBits: 0, lowerBits: 1))
        XCTAssertEqual(testResult, expectedResult)
    }
}

/// Test properties and methods that are not tied to protocol conformance.
class BaseTypeTests : XCTestCase {
    func testSignificantBitsReturnsProperBitCount() {
        let tests = [
            (input: UInt128(),
             expected: UInt128(upperBits: 0, lowerBits: 0)),
            (input: UInt128(upperBits: 0, lowerBits: 1),
             expected: UInt128(upperBits: 0, lowerBits: 1)),
            (input: UInt128(upperBits: 0, lowerBits: UInt64.max),
             expected: UInt128(upperBits: 0, lowerBits: 64)),
            (input: UInt128.max,
             expected: UInt128(upperBits: 0, lowerBits: 128)),
        ]
        
        tests.forEach { test in
            XCTAssertEqual(test.input.significantBits, test.expected)
        }
    }
    
    func testDesignatedInitializerProperlySetsInternalValue() {
        let tests = [
            (input: (upperBits: 0, lowerBits: 0),
             output: (upperBits: 0, lowerBits: 0)),
            (input: (upperBits: UInt64.max, lowerBits: UInt64.max),
             output: (upperBits: UInt64.max, lowerBits: UInt64.max))
        ]
        
        tests.forEach { test in
            let result = UInt128(upperBits: test.input.upperBits,
                                 lowerBits: test.input.lowerBits)
            
            XCTAssertEqual(result.value.upperBits, test.output.upperBits)
            XCTAssertEqual(result.value.lowerBits, test.output.lowerBits)
        }
    }
    
    func testDefaultInitializerSetsUpperAndLowerBitsToZero() {
        let result = UInt128()
        
        XCTAssertEqual(result.value.upperBits, 0)
        XCTAssertEqual(result.value.lowerBits, 0)
    }
    
    func testInitWithUInt128() {
        let tests = [
            UInt128(),
            UInt128(upperBits: 0, lowerBits: 1),
            UInt128(upperBits: 0, lowerBits: UInt64.max),
            UInt128.max]
        
        tests.forEach { test in
            XCTAssertEqual(UInt128(test), test)
        }
    }
    
    func testStringInitializerWithEmptyString() {
        XCTAssertThrowsError(try UInt128(""))
    }
    
    func testStringInitializerWithSupportedNumberFormats() {
        let tests = ["0b2", "0o8", "0xG"]
        
        try! tests.forEach { test in
            XCTAssertThrowsError(try UInt128(test))
        }
    }
}

class FixedWidthIntegerTests : XCTestCase {
    func testNonzeroBitCount() {
        let thing = String.init(UInt128(), radix: 2, uppercase: true)
        XCTAssertEqual(thing, "0")
    }
    
    func testLeadingZeroBitCount() {
        XCTFail("Test not written yet.")
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
    
    func testByteSwapped() {
        XCTFail("Test not written yet.")
    }
    
    func testInitWithTruncatingBits() {
        let testResult = UInt128(_truncatingBits: UInt.max)
        XCTAssertEqual(testResult, UInt128(upperBits: 0, lowerBits: UInt64(UInt.max)))
    }
    
    func testInitWithBigEndian() {
        XCTFail("Test not written yet.")
    }
    
    func testInitWithLittleEndian() {
        XCTFail("Test not written yet.")
    }
    
    func testAddingReportingOverflow() {
        XCTFail("Test not written yet.")
    }
    
    func testSubtractingReportingOverflow() {
        XCTFail("Test not written yet.")
    }
    
    func testMultipliedReportingOverflow() {
        XCTFail("Test not written yet.")
    }
    
    func testMultipliedFullWidth() {
        XCTFail("Test not written yet.")
    }
    
    func testDividedReportingOverflow() {
        XCTFail("Test not written yet.")
    }
    
    func testDividingFullWidth() {
        XCTFail("Test not written yet.")
    }
    
    func testRemainderReportingOverflow() {
        XCTFail("Test not written yet.")
    }
    
    func testQuotientAndRemainder() {
        XCTFail("Test not written yet.")
    }
}

class BinaryIntegerTests : XCTestCase {
    func testBitWidthEquals128() {
        XCTAssertEqual(UInt128.bitWidth, 128)
    }
    
    func testTrailingZeroBitCount() {
        let _ = UInt128().trailingZeroBitCount
        XCTFail("Test not written yet.")
    }
    
    func testInitFailableFloatingPointExactly() {
        let _ = UInt128(exactly: Float())
        XCTFail("Test not written yet.")
    }
    
    func testInitFloatingPoint() {
        let _ = UInt128(Float())
        XCTFail("Test not written yet.")
    }
    
    func test_word() {
        let _ = UInt128()._word(at: 0)
        XCTFail("Test not written yet.")
    }
    
    func testDivideOperator() {
        let _ = UInt128(upperBits: 0, lowerBits: 1) / UInt128(upperBits: 0, lowerBits: 1)
        XCTFail("Test not written yet.")
    }
    
    func testDivideEqualOperator() {
        var thing = UInt128(upperBits: 0, lowerBits: 1)
        thing /= UInt128(upperBits: 0, lowerBits: 1)
        XCTFail("Test not written yet.")
    }
    
    func testModuloOperator() {
        let _ = UInt128(upperBits: 0, lowerBits: 1) % UInt128(upperBits: 0, lowerBits: 1)
        XCTFail("Test not written yet.")
    }
    
    func testModuleEqualOperator() {
        var thing = UInt128(upperBits: 0, lowerBits: 1)
        thing %= UInt128(upperBits: 0, lowerBits: 1)
        XCTFail("Test not written yet.")
    }
    
    func testBooleanAndEqualOperator() {
        var thing = UInt128()
        thing &= UInt128()
        XCTFail("Test not written yet.")
    }
    
    func testBooleanOrEqualOperator() {
        var thing = UInt128()
        thing |= UInt128()
        XCTFail("Test not written yet.")
    }
    
    func testBooleanXorEqualOperator() {
        var thing = UInt128()
        thing ^= UInt128()
        XCTFail("Test not written yet.")
    }
    
    func testMaskingRightShiftEqualOperator() {
        var thing = UInt128()
        thing &>>= UInt128(upperBits: 0, lowerBits: 1)
        XCTFail("Test not written yet.")
    }
    
    func testMaskingLeftShiftEqualOperator() {
        let tests = [
            (input: UInt128(upperBits: 0, lowerBits: 1),
             shiftWidth: UInt64(127),
             expected: UInt128(upperBits: 9223372036854775808, lowerBits: 0)),
            (input: UInt128(upperBits: 0, lowerBits: 1),
             shiftWidth: UInt64(64),
             expected: UInt128(upperBits: 1, lowerBits: 0)),
            (input: UInt128(upperBits: 0, lowerBits: 1),
             shiftWidth: UInt64(1),
             expected: UInt128(upperBits: 0, lowerBits: 2)),
            (input: UInt128(upperBits: 0, lowerBits: 1),
             shiftWidth: UInt64(0),
             expected: UInt128(upperBits: 0, lowerBits: 1))
        ]
        
        tests.forEach { test in
            var testValue = test.input
            testValue &<<= UInt128(upperBits: 0, lowerBits: test.shiftWidth)
            XCTAssertEqual(testValue, test.expected)
        }
    }
}

class HashableTests : XCTestCase {
    func testHashValueProperty() {
        let _ = UInt128().hashValue
        XCTFail("Test not written yet.")
    }
}

class NumericTests : XCTestCase {
    func testAdditionOperator() {
        let _ = UInt128() + UInt128()
        XCTFail("Test not written yet.")
    }
    
    func testAdditionEqualOperator() {
        var thing = UInt128()
        thing += UInt128()
        XCTFail("Test not written yet.")
    }
    
    func testSubtractionOperator() {
        let _ = UInt128() - UInt128()
        XCTFail("Test not written yet.")
    }
    
    func testSubtractionEqualOperator() {
        var thing = UInt128()
        thing -= UInt128()
        XCTFail("Test not written yet.")
    }
    
    func testMultiplicationOperator() {
        let _ = UInt128() * UInt128()
        XCTFail("Test not written yet.")
    }
    
    func testMultiplicationEqualOperator() {
        var thing = UInt128()
        thing *= UInt128()
        XCTFail("Test not written yet.")
    }
}

class EquatableTests : XCTestCase {
    func testBooleanEqualsOperator() {
        let _ = UInt128() == UInt128()
        XCTFail("Test not written yet.")
    }
}

class ExpressibleByIntegerLiteralTests : XCTestCase {
    func testInitWithIntegerLiteral() {
        let _ = UInt128(integerLiteral: 0)
        let _ : UInt128 = 0
        XCTFail("Test not written yet.")
    }
}

class CustomStringConvertibleTests : XCTestCase {
    func testDescriptionProperty() {
        let _ = UInt128().description
        let _ = String(describing: UInt128())
        XCTFail("Test not written yet.")
    }
}

class ComparableTests : XCTestCase {
    func testLessThanOperator() {
        let _ = UInt128() < UInt128()
        XCTFail("Test not written yet.")
    }
}

class ExpressibleByStringLiteralTests : XCTestCase {
    func testInitWithStringLiteral() {
        let _ = UInt128(stringLiteral: "0")
        let _ : UInt128 = "0"
        XCTFail("Test not written yet.")
    }
    
    func testFailingInputs() {
        let tests = ["", "0z1234"]
        
        tests.forEach { test in
            XCTAssertEqual(UInt128(stringLiteral: test), UInt128())
        }
    }
}

class FloatingPointInterworkingTests : XCTestCase {
    func testNonFailableInitializer() {
        let tests = [
            (input: UInt128(), output: Float(0)),
            (input: UInt128(upperBits: 0, lowerBits: UInt64.max), output: Float(UInt64.max))]
        
        tests.forEach { test in
            XCTAssertEqual(Float(test.input), test.output)
        }
    }
    
    func testFailableInitializer() {
        let tests = [
            (input: UInt128(), output: Float(0)),
            (input: UInt128(upperBits: 0, lowerBits: UInt64.max), output: Float(UInt64.max)),
            (input: UInt128(upperBits: 1, lowerBits: 0), output: nil)]
        
        tests.forEach { test in
            XCTAssertEqual(Float(exactly: test.input), test.output)
        }
    }
    
    func testSignBitIndex() {
        let tests = [
            (input: UInt128(), output: Int(127)),
            (input: UInt128.max, output: Int(0))]
        
        tests.forEach { test in
            XCTAssertEqual(test.input.signBitIndex, test.output)
        }
    }
}
