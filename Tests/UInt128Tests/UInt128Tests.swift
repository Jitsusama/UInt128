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
    // Picked up by the LinuxMain.swift test runner.
    static var allTests = {
        return [
            ("testCanReceiveAnInt", testCanReceiveAnInt),
            ("testCanBeSentToAnInt", testCanBeSentToAnInt),
            ("testIntegerLiteralInput", testIntegerLiteralInput),
            ("testCanReceiveAString", testCanReceiveAString),
            ("testStringLiteralInput", testStringLiteralInput),
            ("testCanBeSentToAFloat", testCanBeSentToAFloat)]
    }
    
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
    // Picked up by the LinuxMain.swift test runner.
    static var allTests = {
        return [
            ("testSignificantBitsReturnsProperBitCount", testSignificantBitsReturnsProperBitCount),
            ("testDesignatedInitializerProperlySetsInternalValue", testDesignatedInitializerProperlySetsInternalValue),
            ("testDefaultInitializerSetsUpperAndLowerBitsToZero", testDefaultInitializerSetsUpperAndLowerBitsToZero),
            ("testInitWithUInt128", testInitWithUInt128),
            ("testStringInitializerWithEmptyString", testStringInitializerWithEmptyString),
            ("testStringInitializerWithSupportedNumberFormats", testStringInitializerWithSupportedNumberFormats)]
    }
    
    func testSignificantBitsReturnsProperBitCount() {
        var tests = [(input: UInt128(),
                      expected: UInt128(upperBits: 0, lowerBits: 0))]
        tests.append((input: UInt128(upperBits: 0, lowerBits: 1),
                      expected: UInt128(upperBits: 0, lowerBits: 1)))
        tests.append((input: UInt128(upperBits: 0, lowerBits: UInt64.max),
                      expected: UInt128(upperBits: 0, lowerBits: 64)))
        tests.append((input: UInt128.max,
                      expected: UInt128(upperBits: 0, lowerBits: 128)))
        
        tests.forEach { test in
            XCTAssertEqual(test.input.significantBits, test.expected)
        }
    }
    
    func testDesignatedInitializerProperlySetsInternalValue() {
        var tests = [(input: (upperBits: UInt64.min, lowerBits: UInt64.min),
                      output: (upperBits: UInt64.min, lowerBits: UInt64.min))]
        tests.append((input: (upperBits: UInt64.max, lowerBits: UInt64.max),
                      output: (upperBits: UInt64.max, lowerBits: UInt64.max)))
        
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
        var tests = [UInt128()]
        tests.append(UInt128(upperBits: 0, lowerBits: 1))
        tests.append(UInt128(upperBits: 0, lowerBits: UInt64.max))
        tests.append(UInt128.max)
        
        tests.forEach { test in
            XCTAssertEqual(UInt128(test), test)
        }
    }
    
    func testStringInitializerWithEmptyString() {
        XCTAssertThrowsError(try UInt128(""))
    }
    
    func testStringInitializerWithSupportedNumberFormats() {
        var tests = ["0b2"]
        tests.append("0o8")
        tests.append("0xG")
        
        try! tests.forEach { test in
            XCTAssertThrowsError(try UInt128(test))
        }
    }
}

class FixedWidthIntegerTests : XCTestCase {
    // Picked up by the LinuxMain.swift test runner.
    static var allTests = {
        return [
            ("testNonzeroBitCount", testNonzeroBitCount),
            ("testLeadingZeroBitCount", testLeadingZeroBitCount),
            ("testBigEndianProperty", testBigEndianProperty),
            ("testBigEndianInitializer", testBigEndianInitializer),
            ("testLittleEndianProperty", testLittleEndianProperty),
            ("testLittleEndianInitializer", testLittleEndianInitializer),
            ("testByteSwappedProperty", testByteSwappedProperty),
            ("testInitWithTruncatingBits", testInitWithTruncatingBits),
            ("testAddingReportingOverflow", testAddingReportingOverflow),
            ("testSubtractingReportingOverflow", testSubtractingReportingOverflow),
            ("testMultipliedReportingOverflow", testMultipliedReportingOverflow),
            ("testMultipliedFullWidth", testMultipliedFullWidth),
            ("testDividedReportingOverflow", testDividedReportingOverflow),
            ("testBitFromDoubleWidth", testBitFromDoubleWidth),
            ("testDividingFullWidth", testDividingFullWidth),
            ("testRemainderReportingOverflow", testRemainderReportingOverflow),
            ("testQuotientAndRemainder", testQuotientAndRemainder)]
    }
    
    func testNonzeroBitCount() {
        var tests = [(input: UInt128.min, result: 0)]
        tests.append((input: UInt128(1), result: 1))
        tests.append((input: UInt128(3), result: 2))
        tests.append((input: UInt128(UInt64.max), result: 64))
        tests.append((input: UInt128(upperBits: 1, lowerBits: 0), result: 1))
        tests.append((input: UInt128(upperBits: 3, lowerBits: 0), result: 2))
        tests.append((input: UInt128.max, result: 128))
        
        tests.forEach { test in
            XCTAssertEqual(test.input.nonzeroBitCount, test.result)
        }
    }
    
    func testLeadingZeroBitCount() {
        var tests = [(input: UInt128.min, result: 128)]
        tests.append((input: UInt128(1), result: 127))
        tests.append((input: UInt128(UInt64.max), result: 64))
        tests.append((input: UInt128(upperBits: 1, lowerBits: 0), result: 63))
        tests.append((input: UInt128.max, result: 0))
        
        tests.forEach { test in
            XCTAssertEqual(test.input.leadingZeroBitCount, test.result)
        }
    }
    
    func endianTests() -> [(input: UInt128, byteSwapped: UInt128)] {
        var tests = [(input: UInt128(), byteSwapped: UInt128())]
        tests.append((input: UInt128(1),
                      byteSwapped: UInt128(upperBits: 72057594037927936, lowerBits: 0)))
        tests.append((input: UInt128(upperBits: 17434549027881090559, lowerBits: 18373836492640810226),
                      byteSwapped: UInt128(upperBits: 17506889200551263486, lowerBits: 18446176699804939249)))
        return tests
    }
    
    func testBigEndianProperty() {
        endianTests().forEach { test in
            #if arch(i386) || arch(x86_64) || arch(arm) || arch(arm64)
                let expectedResult = test.byteSwapped
            #else
                let expectedResult = test.input
            #endif
            
            XCTAssertEqual(test.input.bigEndian, expectedResult)
        }
    }
    
    func testBigEndianInitializer() {
        endianTests().forEach { test in
            #if arch(i386) || arch(x86_64) || arch(arm) || arch(arm64)
                let expectedResult = test.byteSwapped
            #else
                let expectedResult = test.input
            #endif
            
            XCTAssertEqual(UInt128(bigEndian: test.input), expectedResult)
        }
    }
    
    func testLittleEndianProperty() {
        endianTests().forEach { test in
            #if arch(i386) || arch(x86_64) || arch(arm) || arch(arm64)
                let expectedResult = test.input
            #else
                let expectedResult = test.byteSwapped
            #endif
            
            XCTAssertEqual(test.input.littleEndian, expectedResult)
        }
    }
    
    func testLittleEndianInitializer() {
        endianTests().forEach { test in
            #if arch(i386) || arch(x86_64) || arch(arm) || arch(arm64)
                let expectedResult = test.input
            #else
                let expectedResult = test.byteSwapped
            #endif
            
            XCTAssertEqual(UInt128(littleEndian: test.input), expectedResult)
        }
    }
    
    func testByteSwappedProperty() {
        endianTests().forEach { test in
            XCTAssertEqual(test.input.byteSwapped, test.byteSwapped)
        }
    }
    
    func testInitWithTruncatingBits() {
        let testResult = UInt128(_truncatingBits: UInt.max)
        XCTAssertEqual(testResult, UInt128(upperBits: 0, lowerBits: UInt64(UInt.max)))
    }
    
    func testAddingReportingOverflow() {
        // 0 + 0 = 0
        var tests = [(augend: UInt128.min, addend: UInt128.min,
                      sum: (partialValue: UInt128.min, overflow: false))]
        // UInt128.max + 0 = UInt128.max
        tests.append((augend: UInt128.max, addend: UInt128.min,
                      sum: (partialValue: UInt128.max, overflow: false)))
        // UInt128.max + 1 = 0, with overflow
        tests.append((augend: UInt128.max, addend: UInt128(1),
                      sum: (partialValue: UInt128.min, overflow: true)))
        // UInt128.max + 2 = 1, with overflow
        tests.append((augend: UInt128.max, addend: UInt128(2),
                      sum: (partialValue: UInt128(1), overflow: true)))
        // UInt64.max + 1 = UInt64.max + 1
        tests.append((augend: UInt128(UInt64.max), addend: UInt128(1),
                      sum: (partialValue: UInt128(upperBits: 1, lowerBits: 0), overflow: false)))
        
        tests.forEach { test in
            let sum = test.augend.addingReportingOverflow(test.addend)
            XCTAssertEqual(sum.partialValue, test.sum.partialValue)
            XCTAssertEqual(sum.overflow, test.sum.overflow)
        }
    }
    
    func testSubtractingReportingOverflow() {
        // 0 - 0 = 0
        var tests = [(minuend: UInt128.min, subtrahend: UInt128.min,
                      difference: (partialValue: UInt128.min, overflow: false))]
        // Uint128.max - 0 = UInt128.max
        tests.append((minuend: UInt128.max, subtrahend: UInt128.min,
                      difference: (partialValue: UInt128.max, overflow: false)))
        // UInt128.max - 1 = UInt128.max - 1
        tests.append((minuend: UInt128.max, subtrahend: UInt128(1),
                      difference: (partialValue: UInt128(upperBits: UInt64.max, lowerBits: (UInt64.max >> 1) << 1), overflow: false)))
        // UInt64.max + 1 - 1 = UInt64.max
        tests.append((minuend: UInt128(upperBits: 1, lowerBits: 0), subtrahend: UInt128(1),
                      difference: (partialValue: UInt128(UInt64.max), overflow: false)))
        // 0 - 1 = UInt128.max, with overflow
        tests.append((minuend: UInt128.min, subtrahend: UInt128(1),
                      difference: (partialValue: UInt128.max, overflow: true)))
        // 0 - 2 = UInt128.max - 1, with overflow
        tests.append((minuend: UInt128.min, subtrahend: UInt128(2),
                      difference: (partialValue: (UInt128.max >> 1) << 1, overflow: true)))
        
        tests.forEach { test in
            let difference = test.minuend.subtractingReportingOverflow(test.subtrahend)
            XCTAssertEqual(difference.partialValue, test.difference.partialValue)
            XCTAssertEqual(difference.overflow, test.difference.overflow)
        }
    }
    
    func testMultipliedReportingOverflow() {
        // 0 * 0 = 0
        var tests = [(multiplier: UInt128.min, multiplicator: UInt128.min,
                      product: (partialValue: UInt128.min, overflow: false))]
        // UInt64.max * UInt64.max = UInt128.max - UInt64.max - 1
        tests.append((multiplier: UInt128(UInt64.max), multiplicator: UInt128(UInt64.max),
                      product: (partialValue: UInt128(upperBits: (UInt64.max >> 1) << 1, lowerBits: 1), overflow: false)))
        // UInt128.max * 0 = 0
        tests.append((multiplier: UInt128.max, multiplicator: UInt128.min,
                      product: (partialValue: UInt128.min, overflow: false)))
        // UInt128.max * 1 = UInt128.max
        tests.append((multiplier: UInt128.max, multiplicator: UInt128(1),
                      product: (partialValue: UInt128.max, overflow: false)))
        // UInt128.max * 2 = UInt128.max - 1, with overflow
        tests.append((multiplier: UInt128.max, multiplicator: UInt128(2),
                      product: (partialValue: (UInt128.max >> 1) << 1, overflow: true)))
        // UInt128.max * UInt128.max = 1, with overflow
        tests.append((multiplier: UInt128.max, multiplicator: UInt128.max,
                      product: (partialValue: UInt128(1), overflow: true)))
        
        tests.forEach { test in
            let product = test.multiplier.multipliedReportingOverflow(by: test.multiplicator)
            XCTAssertEqual(product.partialValue, test.product.partialValue)
            XCTAssertEqual(product.overflow, test.product.overflow)
        }
    }
    
    func testMultipliedFullWidth() {
        var tests = [(multiplier: UInt128.min, multiplicator: UInt128.min,
                      product: (high: UInt128.min, low: UInt128.min))]
        tests.append((multiplier: UInt128(1), multiplicator: UInt128(1),
                      product: (high: UInt128.min, low: UInt128(1))))
        tests.append((multiplier: UInt128(UInt64.max), multiplicator: UInt128(UInt64.max),
                      product: (high: UInt128.min, low: UInt128(upperBits: UInt64.max - 1, lowerBits: 1))))
        tests.append((multiplier: UInt128.max, multiplicator: UInt128.max,
                      product: (high: UInt128.max ^ 1, low: UInt128(1))))
        
        tests.forEach { test in
            let product = test.multiplier.multipliedFullWidth(by: test.multiplicator)
            XCTAssertEqual(
                product.high, test.product.high,
                "\n\(test.multiplier) * \(test.multiplicator) == (high: \(test.product.high), low: \(test.product.low)) != (high: \(product.high), low: \(product.low))\n")
            XCTAssertEqual(
                product.low, test.product.low,
                "\n\(test.multiplier) * \(test.multiplicator) == (high: \(test.product.high), low: \(test.product.low)) != (high: \(product.high), low: \(product.low))\n")
        }
    }
    
    func divisionTests() -> [(dividend: UInt128, divisor: UInt128, quotient: (partialValue: UInt128, overflow: Bool), remainder: (partialValue: UInt128, overflow: Bool))] {
        // 0 / 0 = 0, remainder 0, with overflow
        var tests = [(dividend: UInt128.min, divisor: UInt128.min,
                      quotient: (partialValue: UInt128.min, overflow: true),
                      remainder: (partialValue: UInt128.min, overflow: true))]
        // 0 / 1 = 0, remainder 0
        tests.append((dividend: UInt128.min, divisor: UInt128(1),
                      quotient: (partialValue: UInt128.min, overflow: false),
                      remainder: (partialValue: UInt128.min, overflow: false)))
        // 0 / UInt128.max = 0, remainder 0
        tests.append((dividend: UInt128.min, divisor: UInt128.max,
                      quotient: (partialValue: UInt128.min, overflow: false),
                      remainder: (partialValue: UInt128.min, overflow: false)))
        // 1 / 0 = 1, remainder 1, with overflow
        tests.append((dividend: UInt128(1), divisor: UInt128.min,
                      quotient: (partialValue: UInt128(1), overflow: true),
                      remainder: (partialValue: UInt128(1), overflow: true)))
        // UInt128.max / UInt64.max = UInt128(upperBits: 1, lowerBits: 1), remainder 0
        tests.append((dividend: UInt128.max, divisor: UInt128(UInt64.max),
                      quotient: (partialValue: UInt128(upperBits: 1, lowerBits: 1), overflow: false),
                      remainder: (partialValue: UInt128.min, overflow: false)))
        // UInt128.max / UInt128.max = 1, remainder 0
        tests.append((dividend: UInt128.max, divisor: UInt128.max,
                      quotient: (partialValue: UInt128(1), overflow: false),
                      remainder: (partialValue: UInt128.min, overflow: false)))
        // UInt64.max / UInt128.max = 0, remainder UInt64.max
        tests.append((dividend: UInt128(UInt64.max), divisor: UInt128.max,
                      quotient: (partialValue: UInt128.min, overflow: false),
                      remainder: (partialValue: UInt128(UInt64.max), overflow: false)))
        return tests
    }
    
    func testDividedReportingOverflow() {
        divisionTests().forEach { test in
            let quotient = test.dividend.dividedReportingOverflow(by: test.divisor)
            XCTAssertEqual(
                quotient.partialValue, test.quotient.partialValue,
                "\(test.dividend) / \(test.divisor) == \(test.quotient.partialValue)")
            XCTAssertEqual(
                quotient.overflow, test.quotient.overflow,
                "\(test.dividend) / \(test.divisor) has overflow? \(test.remainder.overflow)")
        }
    }
    
    func testBitFromDoubleWidth() {
        var tests = [(input: (high: UInt128(1), low: UInt128.min),
                      position: UInt128.min, result: UInt128.min)]
        tests.append((input: (high: UInt128(1), low: UInt128.min),
                      position: UInt128(128), result: UInt128(1)))
        tests.append((input: (high: UInt128(2), low: UInt128.min),
                      position: UInt128(128), result: UInt128.min))
        tests.append((input: (high: UInt128(2), low: UInt128.min),
                      position: UInt128(129), result: UInt128(1)))
        tests.append((input: (high: UInt128.min, low: UInt128(2)),
                      position: UInt128.min, result: UInt128.min))
        tests.append((input: (high: UInt128.min, low: UInt128(2)),
                      position: UInt128(1), result: UInt128(1)))
        
        tests.forEach { test in
            let result = UInt128._bitFromDoubleWidth(at: test.position, for: test.input)
            XCTAssertEqual(
                result, test.result,
                "\n\(test.input), bit \(test.position) != \(test.result)")
        }
    }
    
    func testDividingFullWidth() {
        // (0, 1) / 1 = 1r0
        var tests = [(dividend: (high: UInt128.min, low: UInt128(1)),
                      divisor: UInt128(1),
                      result: (quotient: UInt128(1), remainder: UInt128.min))]
        // (1, 0) / 1 = 0r0
        tests.append((dividend: (high: UInt128(1), low: UInt128.min),
                      divisor: UInt128(1),
                      result: (quotient: UInt128.min, remainder: UInt128.min)))
        // (1, 0) / 2 = 170141183460469231731687303715884105728r0
        tests.append((dividend: (high: UInt128(1), low: UInt128.min),
                      divisor: UInt128(2),
                      result: (quotient: UInt128(stringLiteral: "170141183460469231731687303715884105728"),
                               remainder: UInt128.min)))
        
        tests.forEach { test in
            let result = test.divisor.dividingFullWidth(test.dividend)
            XCTAssertEqual(
                result.quotient, test.result.quotient,
                "\n\(test.dividend) / \(test.divisor) == \(test.result)")
            XCTAssertEqual(
                result.remainder, test.result.remainder,
                "\n\(test.dividend) / \(test.divisor) == \(test.result)")
        }
    }
    
    func testRemainderReportingOverflow() {
        divisionTests().forEach { test in
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
        divisionTests().forEach { test in
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
    // Picked up by the LinuxMain.swift test runner.
    static var allTests = {
        return [
            ("testBitWidthEquals128", testBitWidthEquals128),
            ("testTrailingZeroBitCount", testTrailingZeroBitCount),
            ("testInitFailableFloatingPointExactlyExpectedSuccesses", testInitFailableFloatingPointExactlyExpectedSuccesses),
            ("testInitFailableFloatingPointExactlyExpectedFailures", testInitFailableFloatingPointExactlyExpectedFailures),
            ("testInitFloatingPoint", testInitFloatingPoint),
            ("test_word", test_word),
            ("testDivideOperator", testDivideOperator),
            ("testDivideEqualOperator", testDivideEqualOperator),
            ("testModuloOperator", testModuloOperator),
            ("testModuloEqualOperator", testModuloEqualOperator),
            ("testBooleanAndEqualOperator", testBooleanAndEqualOperator),
            ("testBooleanOrEqualOperator", testBooleanOrEqualOperator),
            ("testBooleanXorEqualOperator", testBooleanXorEqualOperator),
            ("testMaskingRightShiftEqualOperatorStandardCases", testMaskingRightShiftEqualOperatorStandardCases),
            ("testMaskingRightShiftEqualOperatorEdgeCases", testMaskingRightShiftEqualOperatorEdgeCases),
            ("testMaskingLeftShiftEqualOperatorStandardCases", testMaskingLeftShiftEqualOperatorStandardCases),
            ("testMaskingLeftShiftEqualOperatorEdgeCases", testMaskingLeftShiftEqualOperatorEdgeCases)]
    }
    
    func testBitWidthEquals128() {
        XCTAssertEqual(UInt128.bitWidth, 128)
    }
    
    func testTrailingZeroBitCount() {
        var tests = [(input: UInt128.min, expected: 128)]
        tests.append((input: UInt128(1), expected: 0))
        tests.append((input: UInt128(upperBits: 1, lowerBits: 0), expected: 64))
        tests.append((input: UInt128.max, expected: 0))
        
        tests.forEach { test in
            XCTAssertEqual(test.input.trailingZeroBitCount, test.expected)}
    }
    
    func testInitFailableFloatingPointExactlyExpectedSuccesses() {
        var tests = [(input: Float(), result: UInt128())]
        tests.append((input: Float(1), result: UInt128(1)))
        tests.append((input: Float(1.0), result: UInt128(1)))
        
        tests.forEach { test in
            XCTAssertEqual(UInt128(exactly: test.input), test.result)
        }
    }
    
    func testInitFailableFloatingPointExactlyExpectedFailures() {
        var tests = [Float(1.1)]
        tests.append(Float(0.1))
        
        tests.forEach { test in
            XCTAssertEqual(UInt128(exactly: test), nil)
        }
    }
    
    func testInitFloatingPoint() {
        var tests = [(input: Float80(), result: UInt128())]
        tests.append((input: Float80(0.1), result: UInt128()))
        tests.append((input: Float80(1.0), result: UInt128(1)))
        tests.append((input: Float80(UInt64.max), result: UInt128(UInt64.max)))
        
        tests.forEach { test in
            XCTAssertEqual(UInt128(test.input), test.result)
        }
    }
    
    func test_word() {
        let lowerBits = UInt64("100000000000000000000000000000001", radix: 2)!
        let upperBits = UInt64("100000000000000000000000000000001", radix: 2)!
        let testResult = UInt128(upperBits: upperBits, lowerBits: lowerBits)

        testResult.words.forEach { (currentWord) in
            if UInt.bitWidth == 64 {
                XCTAssertEqual(currentWord, 4294967297)
            }
        }
    }
    
    func divisionTests() -> [(dividend: UInt128, divisor: UInt128, quotient: UInt128, remainder: UInt128)] {
        // 0 / 1 = 0, remainder 0
        var tests = [(dividend: UInt128.min, divisor: UInt128(1),
                      quotient: UInt128.min, remainder: UInt128.min)]
        // 2 / 1 = 2, remainder 0
        tests.append((dividend: UInt128(2), divisor: UInt128(1),
                      quotient: UInt128(2), remainder: UInt128.min))
        // 1 / 2 = 0, remainder 1
        tests.append((dividend: UInt128(1), divisor: UInt128(2),
                      quotient: UInt128(0), remainder: UInt128(1)))
        // UInt128.max / UInt64.max = UInt128(upperBits: 1, lowerBits: 1), remainder 0
        tests.append((dividend: UInt128.max, divisor: UInt128(UInt64.max),
                      quotient: UInt128(upperBits: 1, lowerBits: 1), remainder: UInt128.min))
        // UInt128.max / UInt128.max = 1, remainder 0
        tests.append((dividend: UInt128.max, divisor: UInt128.max,
                      quotient: UInt128(1), remainder: UInt128.min))
        // UInt64.max / UInt128.max = 0, remainder UInt64.max
        tests.append((dividend: UInt128(UInt64.max), divisor: UInt128.max,
                      quotient: UInt128.min, remainder: UInt128(UInt64.max)))
        return tests
    }
    
    func testDivideOperator() {
        divisionTests().forEach { test in
            let quotient = test.dividend / test.divisor
            XCTAssertEqual(
                quotient, test.quotient,
                "\(test.dividend) / \(test.divisor) == \(test.quotient)")
        }
    }
    
    func testDivideEqualOperator() {
        divisionTests().forEach { test in
            var quotient = test.dividend
            quotient /= test.divisor
            XCTAssertEqual(
                quotient, test.quotient,
                "\(test.dividend) /= \(test.divisor) == \(test.quotient)")
        }
    }
    
    func moduloTests() -> [(dividend: UInt128, divisor: UInt128, remainder: UInt128)] {
        // 0 % 1 = 0
        var tests = [(dividend: UInt128.min, divisor: UInt128(1),
                      remainder: UInt128.min)]
        // 1 % 2 = 1
        tests.append((dividend: UInt128(1), divisor: UInt128(2),
                      remainder: UInt128(1)))
        // 0 % UInt128.max = 0
        tests.append((dividend: UInt128.min, divisor: UInt128.max,
                      remainder: UInt128.min))
        // UInt128.max % UInt64.max = 0
        tests.append((dividend: UInt128.max, divisor: UInt128(UInt64.max),
                      remainder: UInt128.min))
        // UInt128.max % UInt128.max = 0
        tests.append((dividend: UInt128.max, divisor: UInt128.max,
                      remainder: UInt128.min))
        // UInt64.max % UInt128.max = UInt64.max
        tests.append((dividend: UInt128(UInt64.max), divisor: UInt128.max,
                      remainder: UInt128(UInt64.max)))
        return tests
    }
    
    func testModuloOperator() {
        moduloTests().forEach { test in
            let remainder = test.dividend % test.divisor
            XCTAssertEqual(
                remainder, test.remainder,
                "\(test.dividend) % \(test.divisor) == \(test.remainder)")
        }
    }
    
    func testModuloEqualOperator() {
        moduloTests().forEach { test in
            var remainder = test.dividend
            remainder %= test.divisor
            XCTAssertEqual(
                remainder, test.remainder,
                "\(test.dividend) %= \(test.divisor) == \(test.remainder)")
        }
    }
    
    func testBooleanAndEqualOperator() {
        var tests = [(lhs: UInt128.min, rhs: UInt128.min, result: UInt128.min)]
        tests.append((lhs: UInt128(1), rhs: UInt128(1), result: UInt128(1)))
        tests.append((lhs: UInt128.min, rhs: UInt128.max, result: UInt128.min))
        tests.append((lhs: UInt128(upperBits: UInt64.min, lowerBits: UInt64.max),
                      rhs: UInt128(upperBits: UInt64.max, lowerBits: UInt64.min),
                      result: UInt128.min))
        tests.append((lhs: UInt128(upperBits: 17434549027881090559, lowerBits: 18373836492640810226),
                      rhs: UInt128(upperBits: 17506889200551263486, lowerBits: 18446176699804939249),
                      result: UInt128(upperBits: 17361645879185571070, lowerBits: 18373836492506460400)))
        tests.append((lhs: UInt128.max, rhs: UInt128.max, result: UInt128.max))
        
        tests.forEach { test in
            var result = test.lhs
            result &= test.rhs
            XCTAssertEqual(result, test.result)
        }
    }
    
    func testBooleanOrEqualOperator() {
        var tests = [(lhs: UInt128.min, rhs: UInt128.min, result: UInt128.min)]
        tests.append((lhs: UInt128(1), rhs: UInt128(1), result: UInt128(1)))
        tests.append((lhs: UInt128.min, rhs: UInt128.max, result: UInt128.max))
        tests.append((lhs: UInt128(upperBits: UInt64.min, lowerBits: UInt64.max),
                      rhs: UInt128(upperBits: UInt64.max, lowerBits: UInt64.min),
                      result: UInt128.max))
        tests.append((lhs: UInt128(upperBits: 17434549027881090559, lowerBits: 18373836492640810226),
                      rhs: UInt128(upperBits: 17506889200551263486, lowerBits: 18446176699804939249),
                      result: UInt128(upperBits: 17579792349246782975, lowerBits: 18446176699939289075)))
        tests.append((lhs: UInt128.max, rhs: UInt128.max, result: UInt128.max))
        
        tests.forEach { test in
            var result = test.lhs
            result |= test.rhs
            XCTAssertEqual(result, test.result)
        }
    }
    
    func testBooleanXorEqualOperator() {
        var tests = [(lhs: UInt128.min, rhs: UInt128.min, result: UInt128.min)]
        tests.append((lhs: UInt128(1), rhs: UInt128(1), result: UInt128.min))
        tests.append((lhs: UInt128.min, rhs: UInt128.max, result: UInt128.max))
        tests.append((lhs: UInt128(upperBits: UInt64.min, lowerBits: UInt64.max),
                      rhs: UInt128(upperBits: UInt64.max, lowerBits: UInt64.min),
                      result: UInt128.max))
        tests.append((lhs: UInt128(upperBits: 17434549027881090559, lowerBits: 18373836492640810226),
                      rhs: UInt128(upperBits: 17506889200551263486, lowerBits: 18446176699804939249),
                      result: UInt128(upperBits: 218146470061211905, lowerBits: 72340207432828675)))
        tests.append((lhs: UInt128.max, rhs: UInt128.max, result: UInt128.min))
        
        tests.forEach { test in
            var result = test.lhs
            result ^= test.rhs
            XCTAssertEqual(result, test.result)
        }
    }
    
    func testMaskingRightShiftEqualOperatorStandardCases() {
        var tests = [(input: UInt128(upperBits: UInt64.max, lowerBits: 0),
                      shiftWidth: UInt64(127),
                      expected: UInt128(upperBits: 0, lowerBits: 1))]
        tests.append((input: UInt128(upperBits: 1, lowerBits: 0),
                      shiftWidth: UInt64(64),
                      expected: UInt128(upperBits: 0, lowerBits: 1)))
        tests.append((input: UInt128(upperBits: 0, lowerBits: 1),
                      shiftWidth: UInt64(1),
                      expected: UInt128()))
        
        tests.forEach { test in
            var testValue = test.input
            testValue &>>= UInt128(upperBits: 0, lowerBits: test.shiftWidth)
            XCTAssertEqual(testValue, test.expected)
        }
    }
    
    func testMaskingRightShiftEqualOperatorEdgeCases() {
        var tests = [(input: UInt128(upperBits: 0, lowerBits: 2),
                      shiftWidth: UInt64(129),
                      expected: UInt128(upperBits: 0, lowerBits: 1))]
        tests.append((input: UInt128(upperBits: UInt64.max, lowerBits: 0),
                      shiftWidth: UInt64(128),
                      expected: UInt128(upperBits: UInt64.max, lowerBits: 0)))
        tests.append((input: UInt128(upperBits: 0, lowerBits: 1),
                      shiftWidth: UInt64(0),
                      expected: UInt128(upperBits: 0, lowerBits: 1)))
        
        tests.forEach { test in
            var testValue = test.input
            testValue &>>= UInt128(upperBits: 0, lowerBits: test.shiftWidth)
            XCTAssertEqual(testValue, test.expected)
        }
    }
    
    func testMaskingLeftShiftEqualOperatorStandardCases() {
        let uint64_1_in_msb: UInt64 = 2 << 62
        var tests = [(input: UInt128(upperBits: 0, lowerBits: 1),
                      shiftWidth: UInt64(127),
                      expected: UInt128(upperBits: uint64_1_in_msb, lowerBits: 0))]
        tests.append((input: UInt128(upperBits: 0, lowerBits: 1),
                      shiftWidth: UInt64(64),
                      expected: UInt128(upperBits: 1, lowerBits: 0)))
        tests.append((input: UInt128(upperBits: 0, lowerBits: 1),
                      shiftWidth: UInt64(1),
                      expected: UInt128(upperBits: 0, lowerBits: 2)))
        
        tests.forEach { test in
            var testValue = test.input
            testValue &<<= UInt128(upperBits: 0, lowerBits: test.shiftWidth)
            XCTAssertEqual(testValue, test.expected)
        }
    }
    
    func testMaskingLeftShiftEqualOperatorEdgeCases() {
        var tests = [(input: UInt128(upperBits: 0, lowerBits: 2),
                      shiftWidth: UInt64(129),
                      expected: UInt128(upperBits: 0, lowerBits: 4))]
        tests.append((input: UInt128(upperBits: 0, lowerBits: 2),
                      shiftWidth: UInt64(128),
                      expected: UInt128(upperBits: 0, lowerBits: 2)))
        tests.append((input: UInt128(upperBits: 0, lowerBits: 1),
                      shiftWidth: UInt64(0),
                      expected: UInt128(upperBits: 0, lowerBits: 1)))
        
        tests.forEach { test in
            var testValue = test.input
            testValue &<<= UInt128(upperBits: 0, lowerBits: test.shiftWidth)
            XCTAssertEqual(testValue, test.expected)
        }
    }
}

class HashableTests : XCTestCase {
    // Picked up by the LinuxMain.swift test runner.
    static var allTests = {
        return [("testHashValueProperty", testHashValueProperty)]
    }
    
    func hashableTests() -> [(input: UInt128, result: Int)] {
        var tests = [(input: UInt128(), result: 0)]
        tests.append((input: UInt128(1), result: 1))
        tests.append((input: UInt128(Int.max), result: Int.max))
        tests.append((input: try! UInt128("85070591730234615862769194512323794261"),
                      result: -1537228672809129302))
        return tests
    }
        
    func testHashValueProperty() {
        hashableTests().forEach { test in
            XCTAssertEqual(test.input.hashValue, test.result)
        }
    }
}

class NumericTests : XCTestCase {
    // Picked up by the LinuxMain.swift test runner.
    static var allTests = {
        return [
            ("testAdditionOperator", testAdditionOperator),
            ("testAdditionEqualOperator", testAdditionEqualOperator),
            ("testSubtractionOperator", testSubtractionOperator),
            ("testSubtractionEqualOperator", testSubtractionEqualOperator),
            ("testMultiplicationOperator", testMultiplicationOperator),
            ("testMultiplicationEqualOperator", testMultiplicationEqualOperator)]
    }
    
    func additionTests() -> [(augend: UInt128, addend: UInt128, sum: UInt128)] {
        // 0 + 0 = 0
        var tests = [(augend: UInt128.min, addend: UInt128.min, sum: UInt128.min)]
        // 1 + 1 = 2
        tests.append((augend: UInt128(1), addend: UInt128(1), sum: UInt128(2)))
        // UInt128.max + 0 = UInt128.max
        tests.append((augend: UInt128.max, addend: UInt128.min, sum: UInt128.max))
        // UInt64.max + 1 = UInt64.max + 1
        tests.append((augend: UInt128(UInt64.max), addend: UInt128(1),
                      sum: UInt128(upperBits: 1, lowerBits: 0)))
        return tests
    }
    
    func testAdditionOperator() {
        additionTests().forEach { test in
            let sum = test.augend + test.addend
            XCTAssertEqual(
                sum, test.sum,
                "\(test.augend) + \(test.addend) == \(test.sum)")
        }
    }
    
    func testAdditionEqualOperator() {
        additionTests().forEach { test in
            var sum = test.augend
            sum += test.addend
            XCTAssertEqual(
                sum, test.sum,
                "\(test.augend) += \(test.addend) == \(test.sum)")
        }
    }
    
    func subtractionTests() -> [(minuend: UInt128, subtrahend: UInt128, difference: UInt128)] {
        // 0 - 0 = 0
        var tests = [(minuend: UInt128.min, subtrahend: UInt128.min,
                      difference: UInt128.min)]
        // Uint128.max - 0 = UInt128.max
        tests.append((minuend: UInt128.max, subtrahend: UInt128.min,
                      difference: UInt128.max))
        // UInt128.max - 1 = UInt128.max - 1
        tests.append((minuend: UInt128.max, subtrahend: UInt128(1),
                      difference: UInt128(upperBits: UInt64.max, lowerBits: (UInt64.max >> 1) << 1)))
        // UInt64.max + 1 - 1 = UInt64.max
        tests.append((minuend: UInt128(upperBits: 1, lowerBits: 0), subtrahend: UInt128(1),
                      difference: UInt128(UInt64.max)))
        return tests
    }
    
    func testSubtractionOperator() {
        subtractionTests().forEach { test in
            let difference = test.minuend - test.subtrahend
            XCTAssertEqual(
                difference, test.difference,
                "\(test.minuend) - \(test.subtrahend) == \(test.difference)")
        }
    }
    
    func testSubtractionEqualOperator() {
        subtractionTests().forEach { test in
            var difference = test.minuend
            difference -= test.subtrahend
            XCTAssertEqual(
                difference, test.difference,
                "\(test.minuend) -= \(test.subtrahend) == \(test.difference)")
        }
    }
    
    func multiplicationTests() -> [(multiplier: UInt128, multiplicator: UInt128, product: UInt128)] {
        // 0 * 0 = 0
        var tests = [(multiplier: UInt128.min, multiplicator: UInt128.min,
                      product: UInt128.min)]
        // UInt64.max * UInt64.max = UInt128.max - UInt64.max - 1
        tests.append((multiplier: UInt128(UInt64.max), multiplicator: UInt128(UInt64.max),
                      product: UInt128(upperBits: (UInt64.max >> 1) << 1, lowerBits: 1)))
        // UInt128.max * 0 = 0
        tests.append((multiplier: UInt128.max, multiplicator: UInt128.min,
                      product: UInt128.min))
        // UInt128.max * 1 = UInt128.max
        tests.append((multiplier: UInt128.max, multiplicator: UInt128(1),
                      product: UInt128.max))
        return tests
    }
    
    func testMultiplicationOperator() {
        multiplicationTests().forEach { test in
            let product = test.multiplier * test.multiplicator
            XCTAssertEqual(
                product, test.product,
                "\(test.multiplier) * \(test.multiplicator) == \(test.product)")
        }
    }
    
    func testMultiplicationEqualOperator() {
        multiplicationTests().forEach { test in
            var product = test.multiplier
            product *= test.multiplicator
            XCTAssertEqual(
                product, test.product,
                "\(test.multiplier) *= \(test.multiplicator) == \(test.product)")
        }
    }
}

class EquatableTests : XCTestCase {
    // Picked up by the LinuxMain.swift test runner.
    static var allTests = {
        return [("testBooleanEqualsOperator", testBooleanEqualsOperator)]
    }
    
    func testBooleanEqualsOperator() {
        var tests = [(lhs: UInt128.min,
                      rhs: UInt128.min, result: true)]
        tests.append((lhs: UInt128.min,
                      rhs: UInt128(1), result: false))
        tests.append((lhs: UInt128.max,
                      rhs: UInt128.max, result: true))
        tests.append((lhs: UInt128(UInt64.max),
                      rhs: UInt128(upperBits: UInt64.max, lowerBits: UInt64.min), result: false))
        tests.append((lhs: UInt128(upperBits: 1, lowerBits: 0),
                      rhs: UInt128(upperBits: 1, lowerBits: 0), result: true))
        tests.append((lhs: UInt128(upperBits: 1, lowerBits: 0),
                      rhs: UInt128(), result: false))
        
        tests.forEach { test in
            XCTAssertEqual(test.lhs == test.rhs, test.result)
        }
    }
}

class ExpressibleByIntegerLiteralTests : XCTestCase {
    // Picked up by the LinuxMain.swift test runner.
    static var allTests = {
        return [("testInitWithIntegerLiteral", testInitWithIntegerLiteral)]
    }
    
    func testInitWithIntegerLiteral() {
        var tests = [(input: 0, result: UInt128())]
        tests.append((input: 1, result: UInt128(upperBits: 0, lowerBits: 1)))
        tests.append((input: Int.max, result: UInt128(upperBits: 0, lowerBits: UInt64(Int.max))))
        
        tests.forEach { test in
            XCTAssertEqual(UInt128(integerLiteral: test.input), test.result)
        }
    }
}

class CustomStringConvertibleTests : XCTestCase {
    // Picked up by the LinuxMain.swift test runner.
    static var allTests = {
        return [
            ("testDescriptionProperty", testDescriptionProperty),
            ("testStringDescribingInitializer", testStringDescribingInitializer),
            ("testStringUInt128InitializerLowercased", testStringUInt128InitializerLowercased),
            ("testStringUInt128InitializerUppercased", testStringUInt128InitializerUppercased)]
    }
    
    func stringTests() -> [(input: UInt128, result: [Int: String])] {
        var tests = [(input: UInt128(), result:[
            2: "0", 8: "0", 10: "0", 16: "0", 18: "0", 36: "0"])]
        tests.append((input: UInt128(1), result: [
            2: "1", 8: "1", 10: "1", 16: "1", 18: "1", 36: "1"]))
        tests.append((input: UInt128(UInt64.max), result: [
            2: "1111111111111111111111111111111111111111111111111111111111111111",
            8: "1777777777777777777777",
            10: "18446744073709551615",
            16: "ffffffffffffffff",
            18: "2d3fgb0b9cg4bd2f",
            36: "3w5e11264sgsf"]))
        tests.append((input: UInt128(upperBits: 1, lowerBits: 0), result: [
            2: "10000000000000000000000000000000000000000000000000000000000000000",
            8: "2000000000000000000000",
            10: "18446744073709551616",
            16: "10000000000000000",
            18: "2d3fgb0b9cg4bd2g",
            36: "3w5e11264sgsg"]))
        tests.append((input: UInt128.max, result: [
            2: "11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111",
            8: "3777777777777777777777777777777777777777777",
            10: "340282366920938463463374607431768211455",
            16: "ffffffffffffffffffffffffffffffff",
            18: "78a399ccdeb5bd6ha3184c0fh64da63",
            36: "f5lxx1zz5pnorynqglhzmsp33"]))
        return tests
    }
    
    func testDescriptionProperty() {
        stringTests().forEach { test in
            XCTAssertEqual(test.input.description, test.result[10])
        }
    }
    
    func testStringDescribingInitializer() {
        stringTests().forEach { test in
            XCTAssertEqual(String(describing: test.input), test.result[10])
        }
    }
    
    func testStringUInt128InitializerLowercased() {
        stringTests().forEach { test in
            test.result.forEach { result in
                let (radix, result) = result
                let testOutput = String(test.input, radix: radix)
                XCTAssertEqual(testOutput, result)
            }
        }
    }
    
    func testStringUInt128InitializerUppercased() {
        stringTests().forEach { test in
            test.result.forEach { result in
                let (radix, result) = result
                let testOutput = String(test.input, radix: radix, uppercase: true)
                XCTAssertEqual(testOutput, result.uppercased())
            }
        }
    }
    
}

class CustomDebugStringConvertible : XCTestCase {
    // Picked up by the LinuxMain.swift test runner.
    static var allTests = {
        return [
            ("testDebugDescriptionProperty", testDebugDescriptionProperty),
            ("testStringReflectingInitializer", testStringReflectingInitializer)]
    }
    
    func stringTests() -> [(input: UInt128, result: String)] {
        var tests = [(input: UInt128(),
                      result:"0")]
        tests.append((input: UInt128(1),
                      result: "1"))
        tests.append((input: UInt128(UInt64.max),
                      result: "18446744073709551615"))
        tests.append((input: UInt128(upperBits: 1, lowerBits: 0),
                      result: "18446744073709551616"))
        tests.append((input: UInt128.max,
                      result: "340282366920938463463374607431768211455"))
        return tests
    }
    
    
    func testDebugDescriptionProperty() {
        stringTests().forEach { test in
            XCTAssertEqual(test.input.debugDescription, test.result)
        }
    }
    
    func testStringReflectingInitializer() {
        stringTests().forEach { test in
            XCTAssertEqual(String(reflecting: test.input), test.result)
        }
    }
}

class ComparableTests : XCTestCase {
    // Picked up by the LinuxMain.swift test runner.
    static var allTests = {
        return [("testLessThanOperator", testLessThanOperator)]
    }
    
    func testLessThanOperator() {
        var tests = [(lhs: UInt128.min, rhs: UInt128(1), result: true)]
        tests.append((lhs: UInt128.min, rhs: UInt128(upperBits: 1, lowerBits: 0), result: true))
        tests.append((lhs: UInt128(1), rhs: UInt128(upperBits: 1, lowerBits: 0), result: true))
        tests.append((lhs: UInt128(UInt64.max), rhs: UInt128.max, result: true))
        tests.append((lhs: UInt128.min, rhs: UInt128.min, result: false))
        tests.append((lhs: UInt128.max, rhs: UInt128.max, result: false))
        tests.append((lhs: UInt128.max, rhs: UInt128(UInt64.max), result: false))
        
        tests.forEach { test in
            XCTAssertEqual(test.lhs < test.rhs, test.result)
        }
    }
}

class ExpressibleByStringLiteralTests : XCTestCase {
    // Picked up by the LinuxMain.swift test runner.
    static var allTests = {
        return [
            ("testInitWithStringLiteral", testInitWithStringLiteral),
            ("testEvaluatedWithStringLiteral", testEvaluatedWithStringLiteral)]
    }
    
    func stringTests() -> [(input: String, result: UInt128)] {
        var tests = [(input: "", result: UInt128())]
        tests.append((input: "0", result: UInt128()))
        tests.append((input: "1", result: UInt128(1)))
        tests.append((input: "99", result: UInt128(99)))
        tests.append((input: "0b0101", result: UInt128(5)))
        tests.append((input: "0o11", result: UInt128(9)))
        tests.append((input: "0xFF", result: UInt128(255)))
        tests.append((input: "0z1234", result: UInt128()))
        return tests
    }
    
    func testInitWithStringLiteral() {
        stringTests().forEach { test in
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
}

@available(swift, deprecated: 3.2)
class DeprecatedAPITests : XCTestCase {
    // Picked up by the LinuxMain.swift test runner.
    static var allTests = {
        return [
            ("testSuccessor", testSuccessor),
            ("testPredecessor", testPredecessor),
            ("testAdvancedBy", testAdvancedBy),
            ("testDistanceTo", testDistanceTo),
            ("testAllZeros", testAllZeros),
            ("testFromUnparsedString", testFromUnparsedString),
            ("testDivideRemainder", testDivideRemainder),
            ("testPrefixIncrement", testPrefixIncrement),
            ("testSuffixIncrement", testSuffixIncrement),
            ("testPrefixDecrement", testPrefixDecrement),
            ("testSuffixDecrement", testSuffixDecrement)]
    }
    
    func testSuccessor() {
        XCTAssertEqual(UInt128(1).successor(), UInt128(2))
    }
    
    func testPredecessor() {
        XCTAssertEqual(UInt128(1).predecessor(), UInt128.min)
    }
    
    func testAdvancedBy() {
        XCTAssertEqual(UInt128(1).advancedBy(1), UInt128(2))
    }
    
    func testDistanceTo() {
        XCTAssertEqual(UInt128(1).distanceTo(2), 1)
    }
    
    func testAllZeros() {
        XCTAssertEqual(UInt128.allZeros, UInt128.min)
    }
    
    func testFromUnparsedString() {
        XCTAssertThrowsError(try UInt128.fromUnparsedString(""))
        XCTAssertEqual(try UInt128.fromUnparsedString("1"), UInt128(1))
    }
    
    func testDivideRemainder() {
        XCTAssertEqual((UInt128(1) /% UInt128(1)).quotient, UInt128(1))
    }
    
    func testPrefixIncrement() {
        var value = UInt128(1)
        XCTAssertEqual(++value, UInt128(2))
    }
    
    func testSuffixIncrement() {
        var value = UInt128(1)
        XCTAssertEqual(value++, UInt128(1))
    }
    
    func testPrefixDecrement() {
        var value = UInt128(1)
        XCTAssertEqual(--value, UInt128.min)
    }
    
    func testSuffixDecrement() {
        var value = UInt128(1)
        XCTAssertEqual(value--, UInt128(1))
    }
}

class FloatingPointInterworkingTests : XCTestCase {
    // Picked up by the LinuxMain.swift test runner.
    static var allTests = {
        return [
            ("testNonFailableInitializer", testNonFailableInitializer),
            ("testFailableInitializer", testFailableInitializer),
            ("testSignBitIndex", testSignBitIndex)]
    }
    
    func testNonFailableInitializer() {
        var tests = [(input: UInt128(), output: Float(0))]
        tests.append((input: UInt128(upperBits: 0, lowerBits: UInt64.max),
                      output: Float(UInt64.max)))
        
        tests.forEach { test in
            XCTAssertEqual(Float(test.input), test.output)
        }
    }
    
    func testFailableInitializer() {
        var tests = [(input: UInt128(),
                      output: Float(0) as Float?)]
        tests.append((input: UInt128(upperBits: 0, lowerBits: UInt64.max),
                      output: Float(UInt64.max) as Float?))
        tests.append((input: UInt128(upperBits: 1, lowerBits: 0),
                      output: nil))
        
        tests.forEach { test in
            XCTAssertEqual(Float(exactly: test.input), test.output)
        }
    }
    
    func testSignBitIndex() {
        var tests = [(input: UInt128.min, output: Int(-1))]
        tests.append((input: UInt128.max, output: Int(127)))
        
        tests.forEach { test in
            XCTAssertEqual(test.input.signBitIndex, test.output)
        }
    }
}
