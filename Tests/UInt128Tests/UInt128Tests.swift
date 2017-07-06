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

let didOverflow = ArithmeticOverflow(true)
let didNotOverflow = ArithmeticOverflow(false)

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
        let tests = [
            // 0 + 0 = 0
            (augend: UInt128.min, addend: UInt128.min,
             sum: (partialValue: UInt128.min, overflow: didNotOverflow)),
            // UInt128.max + 0 = UInt128.max
            (augend: UInt128.max, addend: UInt128.min,
             sum: (partialValue: UInt128.max, overflow: didNotOverflow)),
            // UInt128.max + 1 = 0, with overflow
            (augend: UInt128.max, addend: UInt128(1),
             sum: (partialValue: UInt128.min, overflow: didOverflow)),
            // UInt128.max + 2 = 1, with overflow
            (augend: UInt128.max, addend: UInt128(2),
             sum: (partialValue: UInt128(1), overflow: didOverflow)),
            // UInt64.max + 1 = UInt64.max + 1
            (augend: UInt128(UInt64.max), addend: UInt128(1),
             sum: (partialValue: UInt128(upperBits: 1, lowerBits: 0), overflow: ArithmeticOverflow(false)))]
        
        tests.forEach { test in
            let sum = test.augend.addingReportingOverflow(test.addend)
            XCTAssertEqual(sum.partialValue, test.sum.partialValue)
            XCTAssertEqual(sum.overflow, test.sum.overflow)
        }
    }
    
    func testSubtractingReportingOverflow() {
        let tests = [
            // 0 - 0 = 0
            (minuend: UInt128.min, subtrahend: UInt128.min,
             difference: (partialValue: UInt128.min, overflow: didNotOverflow)),
            // Uint128.max - 0 = UInt128.max
            (minuend: UInt128.max, subtrahend: UInt128.min,
             difference: (partialValue: UInt128.max, overflow: didNotOverflow)),
            // UInt128.max - 1 = UInt128.max - 1
            (minuend: UInt128.max, subtrahend: UInt128(1),
             difference: (partialValue: UInt128(upperBits: UInt64.max, lowerBits: (UInt64.max >> 1) << 1), overflow: didNotOverflow)),
            // UInt64.max + 1 - 1 = UInt64.max
            (minuend: UInt128(upperBits: 1, lowerBits: 0), subtrahend: UInt128(1),
             difference: (partialValue: UInt128(UInt64.max), overflow: didNotOverflow)),
            // 0 - 1 = UInt128.max, with overflow
            (minuend: UInt128.min, subtrahend: UInt128(1),
             difference: (partialValue: UInt128.max, overflow: didOverflow)),
            // 0 - 2 = UInt128.max - 1, with overflow
            (minuend: UInt128.min, subtrahend: UInt128(2),
             difference: (partialValue: (UInt128.max >> 1) << 1, overflow: didOverflow))]
        
        tests.forEach { test in
            let difference = test.minuend.subtractingReportingOverflow(test.subtrahend)
            XCTAssertEqual(difference.partialValue, test.difference.partialValue)
            XCTAssertEqual(difference.overflow, test.difference.overflow)
        }
    }
    
    func testMultipliedReportingOverflow() {
        let tests = [
            // 0 * 0 = 0
            (multiplier: UInt128.min, multiplicator: UInt128.min,
             product: (partialValue: UInt128.min, overflow: didNotOverflow)),
            // UInt64.max * UInt64.max = UInt128.max - UInt64.max - 1
            (multiplier: UInt128(UInt64.max), multiplicator: UInt128(UInt64.max),
             product: (partialValue: UInt128(upperBits: (UInt64.max >> 1) << 1, lowerBits: 1), overflow: didNotOverflow)),
            // UInt128.max * 0 = 0
            (multiplier: UInt128.max, multiplicator: UInt128.min,
             product: (partialValue: UInt128.min, overflow: didNotOverflow)),
            // UInt128.max * 1 = UInt128.max
            (multiplier: UInt128.max, multiplicator: UInt128(1),
             product: (partialValue: UInt128.max, overflow: didNotOverflow)),
            // UInt128.max * 2 = UInt128.max - 1, with overflow
            (multiplier: UInt128.max, multiplicator: UInt128(2),
             product: (partialValue: (UInt128.max >> 1) << 1, overflow: didOverflow)),
            // UInt128.max * UInt128.max = 1, with overflow
            (multiplier: UInt128.max, multiplicator: UInt128.max,
             product: (partialValue: UInt128(1), overflow: didOverflow))]
        
        tests.forEach { test in
            let product = test.multiplier.multipliedReportingOverflow(by: test.multiplicator)
            XCTAssertEqual(product.partialValue, test.product.partialValue)
            XCTAssertEqual(product.overflow, test.product.overflow)
        }
    }
    
    func testMultipliedFullWidth() {
        XCTFail("Test not written yet.")
    }
    
    let divisionTests = [
        // 0 / 0 = 0, remainder 0, with overflow
        (dividend: UInt128.min, divisor: UInt128.min,
         quotient: (partialValue: UInt128.min, overflow: didOverflow),
         remainder: (partialValue: UInt128.min, overflow: didOverflow)),
        // 0 / 1 = 0, remainder 0
        (dividend: UInt128.min, divisor: UInt128(1),
         quotient: (partialValue: UInt128.min, overflow: didNotOverflow),
         remainder: (partialValue: UInt128.min, overflow: didNotOverflow)),
        // 0 / UInt128.max = 0, remainder 0
        (dividend: UInt128.min, divisor: UInt128.max,
         quotient: (partialValue: UInt128.min, overflow: didNotOverflow),
         remainder: (partialValue: UInt128.min, overflow: didNotOverflow)),
        // 1 / 0 = 1, remainder 1, with overflow
        (dividend: UInt128(1), divisor: UInt128.min,
         quotient: (partialValue: UInt128(1), overflow: didOverflow),
         remainder: (partialValue: UInt128(1), overflow: didOverflow)),
        // UInt128.max / UInt64.max = UInt128(upperBits: 1, lowerBits: 1), remainder 0
        (dividend: UInt128.max, divisor: UInt128(UInt64.max),
         quotient: (partialValue: UInt128(upperBits: 1, lowerBits: 1), overflow: didNotOverflow),
         remainder: (partialValue: UInt128.min, overflow: didNotOverflow)),
        // UInt128.max / UInt128.max = 1, remainder 0
        (dividend: UInt128.max, divisor: UInt128.max,
         quotient: (partialValue: UInt128(1), overflow: didNotOverflow),
         remainder: (partialValue: UInt128.min, overflow: didNotOverflow)),
        // UInt64.max / UInt128.max = 0, remainder UInt64.max
        (dividend: UInt128(UInt64.max), divisor: UInt128.max,
         quotient: (partialValue: UInt128.min, overflow: didNotOverflow),
         remainder: (partialValue: UInt128(UInt64.max), overflow: didNotOverflow))]
    
    func testDividedReportingOverflow() {
        divisionTests.forEach { test in
            let quotient = test.dividend.dividedReportingOverflow(by: test.divisor)
            XCTAssertEqual(
                quotient.partialValue, test.quotient.partialValue,
                "\(test.dividend) / \(test.divisor) == \(test.quotient.partialValue)")
            XCTAssertEqual(
                quotient.overflow, test.quotient.overflow,
                "\(test.dividend) / \(test.divisor) has overflow? \(test.remainder.overflow)")
        }
    }
    
    func testDividingFullWidth() {
        XCTFail("Test not written yet.")
    }
    
    func testRemainderReportingOverflow() {
        divisionTests.forEach { test in
            let remainder = test.dividend.remainderReportingOverflow(dividingBy: test.divisor)
            XCTAssertEqual(
                remainder.partialValue, test.remainder.partialValue,
                "\(test.dividend) / \(test.divisor) has a remainder of \(test.remainder.partialValue)")
            XCTAssertEqual(
                remainder.overflow, test.remainder.overflow,
                "\(test.dividend) / \(test.divisor) has overflow? \(test.remainder.overflow)")
        }
    }
    
    func testQuotientAndRemainder() {
        divisionTests.forEach { test in
            guard test.divisor != 0 else { return }
            
            let result = test.dividend.quotientAndRemainder(dividingBy: test.divisor)
            XCTAssertEqual(
                result.quotient, test.quotient.partialValue,
                "\(test.dividend) / \(test.divisor) == \(test.quotient.partialValue)")
            XCTAssertEqual(
                result.remainder, test.remainder.partialValue,
                "\(test.dividend) / \(test.divisor) has a remainder of \(test.remainder.partialValue)")
        }
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
    
    func testModuloEqualOperator() {
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
    let additionTests = [
        // 0 + 0 = 0
        (augend: UInt128.min, addend: UInt128.min, sum: UInt128.min),
        // 1 + 1 = 2
        (augend: UInt128(1), addend: UInt128(1), sum: UInt128(2)),
        // UInt128.max + 0 = UInt128.max
        (augend: UInt128.max, addend: UInt128.min, sum: UInt128.max),
        // UInt64.max + 1 = UInt64.max + 1
        (augend: UInt128(UInt64.max), addend: UInt128(1), sum: UInt128(upperBits: 1, lowerBits: 0))]
    
    func testAdditionOperator() {
        additionTests.forEach { test in
            let sum = test.augend + test.addend
            XCTAssertEqual(
                sum, test.sum,
                "\(test.augend) + \(test.addend) == \(test.sum)")
        }
    }
    
    func testAdditionEqualOperator() {
        additionTests.forEach { test in
            var sum = test.augend
            sum += test.addend
            XCTAssertEqual(
                sum, test.sum,
                "\(test.augend) += \(test.addend) == \(test.sum)")
        }
    }
    
    let subtractionTests = [
        // 0 - 0 = 0
        (minuend: UInt128.min, subtrahend: UInt128.min,
         difference: UInt128.min),
        // Uint128.max - 0 = UInt128.max
        (minuend: UInt128.max, subtrahend: UInt128.min,
         difference: UInt128.max),
        // UInt128.max - 1 = UInt128.max - 1
        (minuend: UInt128.max, subtrahend: UInt128(1),
         difference: UInt128(upperBits: UInt64.max, lowerBits: (UInt64.max >> 1) << 1)),
        // UInt64.max + 1 - 1 = UInt64.max
        (minuend: UInt128(upperBits: 1, lowerBits: 0), subtrahend: UInt128(1),
         difference: UInt128(UInt64.max))]
    
    func testSubtractionOperator() {
        subtractionTests.forEach { test in
            let difference = test.minuend - test.subtrahend
            XCTAssertEqual(
                difference, test.difference,
                "\(test.minuend) - \(test.subtrahend) == \(test.difference)")
        }
    }
    
    func testSubtractionEqualOperator() {
        subtractionTests.forEach { test in
            var difference = test.minuend
            difference -= test.subtrahend
            XCTAssertEqual(
                difference, test.difference,
                "\(test.minuend) -= \(test.subtrahend) == \(test.difference)")
        }
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
        let tests = [
            (lhs: UInt128.min, rhs: UInt128.min, result: true),
            (lhs: UInt128.min, rhs: UInt128(1), result: false),
            (lhs: UInt128.max, rhs: UInt128.max, result: true),
            (lhs: UInt128(UInt64.max), rhs: UInt128(upperBits: UInt64.max, lowerBits: UInt64.min), result: false),
            (lhs: UInt128(upperBits: 1, lowerBits: 0), rhs: UInt128(upperBits: 1, lowerBits: 0), result: true),
            (lhs: UInt128(upperBits: 1, lowerBits: 0), rhs: UInt128(), result: false)]
        
        tests.forEach { test in
            XCTAssertEqual(test.lhs == test.rhs, test.result)
        }
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
        let tests = [
            (lhs: UInt128.min, rhs: UInt128(1), result: true),
            (lhs: UInt128.min, rhs: UInt128(upperBits: 1, lowerBits: 0), result: true),
            (lhs: UInt128(1), rhs: UInt128(upperBits: 1, lowerBits: 0), result: true),
            (lhs: UInt128(UInt64.max), rhs: UInt128.max, result: true),
            (lhs: UInt128.min, rhs: UInt128.min, result: false),
            (lhs: UInt128.max, rhs: UInt128.max, result: false),
            (lhs: UInt128.max, rhs: UInt128(UInt64.max), result: false)]
        
        tests.forEach { test in
            XCTAssertEqual(test.lhs < test.rhs, test.result)
        }
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
