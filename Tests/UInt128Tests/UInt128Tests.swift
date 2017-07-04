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
             expected: UInt128(upperBits: 0, lowerBits: 128))]
        
        tests.forEach { test in
            XCTAssertEqual(test.input.significantBits, test.expected)
        }
    }
    
    func testDesignatedInitializerProperlySetsInternalValue() {
        let tests = [
            (input: (upperBits: 0, lowerBits: 0),
             output: (upperBits: 0, lowerBits: 0)),
            (input: (upperBits: UInt64.max, lowerBits: UInt64.max),
             output: (upperBits: UInt64.max, lowerBits: UInt64.max))]
        
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
        let tests = [
            (input: UInt128.min, result: 0),
            (input: UInt128(1), result: 1),
            (input: UInt128(3), result: 2),
            (input: UInt128(UInt64.max), result: 64),
            (input: UInt128(upperBits: 1, lowerBits: 0), result: 1),
            (input: UInt128(upperBits: 3, lowerBits: 0), result: 2),
            (input: UInt128.max, result: 128),]
        
        tests.forEach { test in
            XCTAssertEqual(test.input.nonzeroBitCount, test.result)
        }
    }
    
    func testLeadingZeroBitCount() {
        let tests = [
            (input: UInt128.min, result: 128),
            (input: UInt128(1), result: 127),
            (input: UInt128(UInt64.max), result: 64),
            (input: UInt128(upperBits: 1, lowerBits: 0), result: 63),
            (input: UInt128.max, result: 0)]
        
        tests.forEach { test in
            XCTAssertEqual(test.input.leadingZeroBitCount, test.result)
        }
    }
    
    let endianTests = [
        (input: UInt128(),
         byteSwapped: UInt128()),
        (input: UInt128(1),
         byteSwapped: UInt128(upperBits: 72057594037927936, lowerBits: 0)),
        (input: UInt128(upperBits: 17434549027881090559, lowerBits: 18373836492640810226),
         byteSwapped: UInt128(upperBits: 17506889200551263486, lowerBits: 18446176699804939249))]
    
    func testBigEndianProperty() {
        endianTests.forEach { test in
            #if arch(i386) || arch(x86_64) || arch(arm) || arch(arm64)
                let expectedResult = test.byteSwapped
            #else
                let expectedResult = test.input
            #endif
            
            XCTAssertEqual(test.input.bigEndian, expectedResult)
        }
    }
    
    func testBigEndianInitializer() {
        endianTests.forEach { test in
            #if arch(i386) || arch(x86_64) || arch(arm) || arch(arm64)
                let expectedResult = test.byteSwapped
            #else
                let expectedResult = test.input
            #endif
            
            XCTAssertEqual(UInt128(bigEndian: test.input), expectedResult)
        }
    }
    
    func testLittleEndianProperty() {
        endianTests.forEach { test in
            #if arch(i386) || arch(x86_64) || arch(arm) || arch(arm64)
                let expectedResult = test.input
            #else
                let expectedResult = test.byteSwapped
            #endif
            
            XCTAssertEqual(test.input.littleEndian, expectedResult)
        }
    }
    
    func testLittleEndianInitializer() {
        endianTests.forEach { test in
            #if arch(i386) || arch(x86_64) || arch(arm) || arch(arm64)
                let expectedResult = test.input
            #else
                let expectedResult = test.byteSwapped
            #endif
            
            XCTAssertEqual(UInt128(littleEndian: test.input), expectedResult)
        }
    }
    
    func testByteSwappedProperty() {
        endianTests.forEach { test in
            XCTAssertEqual(test.input.byteSwapped, test.byteSwapped)
        }
    }
    
    func testInitWithTruncatingBits() {
        let testResult = UInt128(_truncatingBits: UInt.max)
        XCTAssertEqual(testResult, UInt128(upperBits: 0, lowerBits: UInt64(UInt.max)))
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
        let tests = [
            (input: UInt128.min, expected: 128),
            (input: UInt128(1), expected: 0),
            (input: UInt128(upperBits: 1, lowerBits: 0), expected: 64),
            (input: UInt128.max, expected: 0)]
        
        tests.forEach { test in
            XCTAssertEqual(test.input.trailingZeroBitCount, test.expected)}
    }
    
    func testInitFailableFloatingPointExactlyExpectedSuccesses() {
        let tests = [
            (input: Float(), result: UInt128()),
            (input: Float(1), result: UInt128(1)),
            (input: Float(1.0), result: UInt128(1))]
        
        tests.forEach { test in
            XCTAssertEqual(UInt128(exactly: test.input), test.result)
        }
    }
    
    func testInitFailableFloatingPointExactlyExpectedFailures() {
        let testInputs = [
            Float(1.1),
            Float(0.1)]
        
        testInputs.forEach { testInput in
            XCTAssertEqual(UInt128(exactly: testInput), nil)
        }
    }
    
    func testInitFloatingPoint() {
        let tests = [
            (input: Float80(), result: UInt128()),
            (input: Float80(0.1), result: UInt128()),
            (input: Float80(1.0), result: UInt128(1)),
            (input: Float80(UInt64.max), result: UInt128(UInt64.max))]
        
        tests.forEach { test in
            XCTAssertEqual(UInt128(test.input), test.result)
        }
    }
    
    func test_word() {
        let lowerBits = UInt64("100000000000000000000000000000001", radix: 2)!
        let upperBits = UInt64("100000000000000000000000000000001", radix: 2)!
        let testResult = UInt128(upperBits: upperBits, lowerBits: lowerBits)

        for index in 0 ... UInt128.bitWidth / UInt.bitWidth {
            let currentWord = testResult._word(at: index)
            if UInt.bitWidth == 64 {
                XCTAssertEqual(currentWord, 4294967297)
            }
        }
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
        let tests = [
            (lhs: UInt128.min, rhs: UInt128.min, result: UInt128.min),
            (lhs: UInt128(1), rhs: UInt128(1), result: UInt128(1)),
            (lhs: UInt128.min, rhs: UInt128.max, result: UInt128.min),
            (lhs: UInt128(upperBits: UInt64.min, lowerBits: UInt64.max),
             rhs: UInt128(upperBits: UInt64.max, lowerBits: UInt64.min),
             result: UInt128.min),
            (lhs: UInt128(upperBits: 17434549027881090559, lowerBits: 18373836492640810226),
             rhs: UInt128(upperBits: 17506889200551263486, lowerBits: 18446176699804939249),
             result: UInt128(upperBits: 17361645879185571070, lowerBits: 18373836492506460400)),
            (lhs: UInt128.max, rhs: UInt128.max, result: UInt128.max)]
        
        tests.forEach { test in
            var result = test.lhs
            result &= test.rhs
            XCTAssertEqual(result, test.result)
        }
    }
    
    func testBooleanOrEqualOperator() {
        let tests = [
            (lhs: UInt128.min, rhs: UInt128.min, result: UInt128.min),
            (lhs: UInt128(1), rhs: UInt128(1), result: UInt128(1)),
            (lhs: UInt128.min, rhs: UInt128.max, result: UInt128.max),
            (lhs: UInt128(upperBits: UInt64.min, lowerBits: UInt64.max),
             rhs: UInt128(upperBits: UInt64.max, lowerBits: UInt64.min),
             result: UInt128.max),
            (lhs: UInt128(upperBits: 17434549027881090559, lowerBits: 18373836492640810226),
             rhs: UInt128(upperBits: 17506889200551263486, lowerBits: 18446176699804939249),
             result: UInt128(upperBits: 17579792349246782975, lowerBits: 18446176699939289075)),
            (lhs: UInt128.max, rhs: UInt128.max, result: UInt128.max)]
        
        tests.forEach { test in
            var result = test.lhs
            result |= test.rhs
            XCTAssertEqual(result, test.result)
        }
    }
    
    func testBooleanXorEqualOperator() {
        let tests = [
            (lhs: UInt128.min, rhs: UInt128.min, result: UInt128.min),
            (lhs: UInt128(1), rhs: UInt128(1), result: UInt128.min),
            (lhs: UInt128.min, rhs: UInt128.max, result: UInt128.max),
            (lhs: UInt128(upperBits: UInt64.min, lowerBits: UInt64.max),
             rhs: UInt128(upperBits: UInt64.max, lowerBits: UInt64.min),
             result: UInt128.max),
            (lhs: UInt128(upperBits: 17434549027881090559, lowerBits: 18373836492640810226),
             rhs: UInt128(upperBits: 17506889200551263486, lowerBits: 18446176699804939249),
             result: UInt128(upperBits: 218146470061211905, lowerBits: 72340207432828675)),
            (lhs: UInt128.max, rhs: UInt128.max, result: UInt128.min)]
        
        tests.forEach { test in
            var result = test.lhs
            result ^= test.rhs
            XCTAssertEqual(result, test.result)
        }
    }
    
    func testMaskingRightShiftEqualOperatorStandardCases() {
        let tests = [
            (input: UInt128(upperBits: UInt64.max, lowerBits: 0),
             shiftWidth: UInt64(127),
             expected: UInt128(upperBits: 0, lowerBits: 1)),
            (input: UInt128(upperBits: 1, lowerBits: 0),
             shiftWidth: UInt64(64),
             expected: UInt128(upperBits: 0, lowerBits: 1)),
            (input: UInt128(upperBits: 0, lowerBits: 1),
             shiftWidth: UInt64(1),
             expected: UInt128())]
        
        tests.forEach { test in
            var testValue = test.input
            testValue &>>= UInt128(upperBits: 0, lowerBits: test.shiftWidth)
            XCTAssertEqual(testValue, test.expected)
        }
    }
    
    func testMaskingRightShiftEqualOperatorEdgeCases() {
        let tests = [
            (input: UInt128(upperBits: 0, lowerBits: 2),
             shiftWidth: UInt64(129),
             expected: UInt128(upperBits: 0, lowerBits: 1)),
            (input: UInt128(upperBits: UInt64.max, lowerBits: 0),
             shiftWidth: UInt64(128),
             expected: UInt128(upperBits: UInt64.max, lowerBits: 0)),
            (input: UInt128(upperBits: 0, lowerBits: 1),
             shiftWidth: UInt64(0),
             expected: UInt128(upperBits: 0, lowerBits: 1))]
        
        tests.forEach { test in
            var testValue = test.input
            testValue &>>= UInt128(upperBits: 0, lowerBits: test.shiftWidth)
            XCTAssertEqual(testValue, test.expected)
        }
    }
    
    func testMaskingLeftShiftEqualOperatorStandardCases() {
        let uint64_1_in_msb: UInt64 = 2 << 62
        let tests = [
            (input: UInt128(upperBits: 0, lowerBits: 1),
             shiftWidth: UInt64(127),
             expected: UInt128(upperBits: uint64_1_in_msb, lowerBits: 0)),
            (input: UInt128(upperBits: 0, lowerBits: 1),
             shiftWidth: UInt64(64),
             expected: UInt128(upperBits: 1, lowerBits: 0)),
            (input: UInt128(upperBits: 0, lowerBits: 1),
             shiftWidth: UInt64(1),
             expected: UInt128(upperBits: 0, lowerBits: 2))]
        
        tests.forEach { test in
            var testValue = test.input
            testValue &<<= UInt128(upperBits: 0, lowerBits: test.shiftWidth)
            XCTAssertEqual(testValue, test.expected)
        }
    }
    
    func testMaskingLeftShiftEqualOperatorEdgeCases() {
        let tests = [
            (input: UInt128(upperBits: 0, lowerBits: 2),
             shiftWidth: UInt64(129),
             expected: UInt128(upperBits: 0, lowerBits: 4)),
            (input: UInt128(upperBits: 0, lowerBits: 2),
             shiftWidth: UInt64(128),
             expected: UInt128(upperBits: 0, lowerBits: 2)),
            (input: UInt128(upperBits: 0, lowerBits: 1),
             shiftWidth: UInt64(0),
             expected: UInt128(upperBits: 0, lowerBits: 1))]
        
        tests.forEach { test in
            var testValue = test.input
            testValue &<<= UInt128(upperBits: 0, lowerBits: test.shiftWidth)
            XCTAssertEqual(testValue, test.expected)
        }
    }
}

class HashableTests : XCTestCase {
    let tests = [
        (input: UInt128(), result: 0),
        (input: UInt128(1), result: 1),
        (input: UInt128(Int.max), result: Int.max),
        (input: try! UInt128("85070591730234615862769194512323794261"), result: -1537228672809129302)]
    
    func testHashValueProperty() {
        tests.forEach { test in
            XCTAssertEqual(test.input.hashValue, test.result)
        }
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
        let tests = [
            (input: 0, result: UInt128()),
            (input: 1, result: UInt128(upperBits: 0, lowerBits: 1)),
            (input: Int.max, result: UInt128(upperBits: 0, lowerBits: UInt64(Int.max)))]
        
        tests.forEach { test in
            XCTAssertEqual(UInt128(integerLiteral: test.input), test.result)
        }
    }
}

class CustomStringConvertibleTests : XCTestCase {
    let tests = [
        (input: UInt128(), result:[
            2: "0", 8: "0", 10: "0", 16: "0", 18: "0", 36: "0"]),
        (input: UInt128(1), result: [
            2: "1", 8: "1", 10: "1", 16: "1", 18: "1", 36: "1"]),
        (input: UInt128(UInt64.max), result: [
            2: "1111111111111111111111111111111111111111111111111111111111111111",
            8: "1777777777777777777777",
            10: "18446744073709551615",
            16: "ffffffffffffffff",
            18: "2d3fgb0b9cg4bd2f",
            36: "3w5e11264sgsf"]),
        (input: UInt128(upperBits: 1, lowerBits: 0), result: [
            2: "10000000000000000000000000000000000000000000000000000000000000000",
            8: "2000000000000000000000",
            10: "18446744073709551616",
            16: "10000000000000000",
            18: "2d3fgb0b9cg4bd2g",
            36: "3w5e11264sgsg"]),
        (input: UInt128.max, result: [
            2: "11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111",
            8: "3777777777777777777777777777777777777777777",
            10: "340282366920938463463374607431768211455",
            16: "ffffffffffffffffffffffffffffffff",
            18: "78a399ccdeb5bd6ha3184c0fh64da63",
            36: "f5lxx1zz5pnorynqglhzmsp33"])]
    
    func testDescriptionProperty() {
        tests.forEach { test in
            XCTAssertEqual(test.input.description, test.result[10])
        }
    }
    
    func testStringDescribingInitializer() {
        tests.forEach { test in
            XCTAssertEqual(String(describing: test.input), test.result[10])
        }
    }
    
    func testStringUInt128InitializerLowercased() {
        tests.forEach { test in
            test.result.forEach { (result) in
                let (radix, result) = result
                let testOutput = String(test.input, radix: radix)
                XCTAssertEqual(testOutput, result)
            }
        }
    }
    
    func testStringUInt128InitializerUppercased() {
        tests.forEach { test in
            test.result.forEach { (result) in
                let (radix, result) = result
                let testOutput = String(test.input, radix: radix, uppercase: true)
                XCTAssertEqual(testOutput, result.uppercased())
            }
        }
    }
    
}

class CustomDebugStringConvertible : XCTestCase {
    let tests = [
        (input: UInt128(), result:"0"),
        (input: UInt128(1), result: "1"),
        (input: UInt128(UInt64.max), result: "18446744073709551615"),
        (input: UInt128(upperBits: 1, lowerBits: 0), result: "18446744073709551616"),
        (input: UInt128.max, result: "340282366920938463463374607431768211455")]
    
    
    func testDebugDescriptionProperty() {
        tests.forEach { test in
            XCTAssertEqual(test.input.debugDescription, test.result)
        }
    }
    
    func testStringReflectingInitializer() {
        tests.forEach { test in
            XCTAssertEqual(String(reflecting: test.input), test.result)
        }
    }
}

class ComparableTests : XCTestCase {
    func testLessThanOperator() {
        let _ = UInt128() < UInt128()
        XCTFail("Test not written yet.")
    }
}

class ExpressibleByStringLiteralTests : XCTestCase {
    let tests = [
        (input: "0", result: UInt128()),
        (input: "1", result: UInt128(1)),
        (input: "99", result: UInt128(99)),
        (input: "0b0101", result: UInt128(5)),
        (input: "0o11", result: UInt128(9)),
        (input: "0xFF", result: UInt128(255))]
    
    func testInitWithStringLiteral() {
        tests.forEach { test in
            XCTAssertEqual(UInt128(stringLiteral: test.input), test.result)
        }
    }
    
    func testEvaluatedWithStringLiteral() {
        let binaryTest: UInt128 = "0b11"
        XCTAssertEqual(binaryTest, UInt128(3))
        
        let octalTest: UInt128 = "0o11"
        XCTAssertEqual(octalTest, UInt128(9))
        
        let decimalTest: UInt128 = "11"
        XCTAssertEqual(decimalTest, UInt128(11))
        
        let hexTest: UInt128 = "0x11"
        XCTAssertEqual(hexTest, UInt128(17))
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
            (input: UInt128.min, output: Int(-1)),
            (input: UInt128.max, output: Int(127))]
        
        tests.forEach { test in
            XCTAssertEqual(test.input.signBitIndex, test.output)
        }
    }
}
