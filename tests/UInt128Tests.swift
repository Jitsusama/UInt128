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
// A UInt128 with a decently complicated bit pattern
let bizarreUInt128: UInt128 = "0xf1f3f5f7f9fbfdfffefcfaf0f8f6f4f2"
/// This class' purpose in life is to test UInt128 like there's no tomorrow.
class UInt128Tests: XCTestCase {
    let sanityValue = UInt128(hi: 1878316677920070929, lo: 2022432965322149909)
    func testMax() {
        XCTAssertEqual(
            UInt128.max,
            UInt128(hi: .max, lo: .max)
        )
    }
    func testMin() {
        XCTAssertEqual(
            UInt128.min,
            UInt128(hi: .min, lo: .min)
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
    func testSize() {
        XCTAssertEqual(
            MemoryLayout<UInt128>.bitSize, 128,
            "UInt128 Must be 128 Bits in Size"
        )
        XCTAssertEqual(
            MemoryLayout<UInt128>.size, 16,
            "UInt128 Must be 16 Bytes in Size"
        )
    }
}
class UInt128StringTests: XCTestCase {
    let bizarreUInt128: UInt128 = "0xf1f3f5f7f9fbfdfffefcfaf0f8f6f4f2"
    let sanityValue = UInt128(hi: 1878316677920070929, lo: 2022432965322149909)
    func testFringeStringConversions() {
        // Test Empty String Input.
        do {
            let _ = try UInt128("")
            XCTFail("Empty String to UInt128 didn't throw")
        } catch UInt128Errors.emptyString {
            XCTAssert(true)
        } catch {
            XCTFail("Empty String to UInt128 didn't throw correctly")
        }
        // Test out of bounds radix conversion
        do {
            let _ = try UInt128.fromParsedString("01234".utf16, radix: 37)
            XCTFail("Invalid Radix didn't throw")
        } catch UInt128Errors.invalidRadix {
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
        // Test literalStringConversion Failure
        var invalidStringLiteral: UInt128 = "0z1234"
        XCTAssertEqual(
            invalidStringLiteral, UInt128(0),
            "Invalid StringLiteral Didn't Return 0"
        )
        // Test Inconceivable Failure
        do {
            invalidStringLiteral = try UInt128.fromParsedString("!".utf16, radix: 16)
            XCTFail("Inconceiveable character didn't throw")
        } catch UInt128Errors.invalidStringCharacter {
            XCTAssert(true)
        } catch {
            XCTFail("Inconceivable character didn't throw correctly")
        }
        
        //
        let unicodeScalarLiteral = UInt128(unicodeScalarLiteral: "\u{0032}")
        XCTAssertEqual(
            unicodeScalarLiteral, UInt128(2),
            "UnicodeScalarLiteral Didn't Return 2"
        )
        //
        let extendedGraphemeCluster = UInt128(extendedGraphemeClusterLiteral: "\u{00032}\u{00032}")
        XCTAssertEqual(
            extendedGraphemeCluster, UInt128(22),
            "ExtendedGraephmeCluster Didn't Return 22"
        )
    }
    func testBinaryStringConversion() {
        // String conversion test.
        let binaryString = String.init([
            "0b00110100001000100011111000100010001101100011",
            "1100001110100010001000111000001000100100000000",
            "1000100010000000100010001000000010101"
            ].joined(separator: "")
        )
        XCTAssertTrue(
            try! UInt128(binaryString!) == sanityValue,
            "Basic Binary String to UInt128 conversion failed"
        )
        // Valid string output conversion test (lowercase)
        XCTAssertTrue(
            String(sanityValue, radix: 2, uppercase: false) == String.init([
                "110100001000100011111000100010001101100011",
                "1100001110100010001000111000001000100100000000",
                "1000100010000000100010001000000010101"
                ].joined(separator: "")),
            "Basic UInt128 to Binary Lowercase String Conversion Failed"
        )
        // Valid string output conversion test (uppercase)
        XCTAssertTrue(
            String(sanityValue, radix: 2, uppercase: true) == String.init([
                "110100001000100011111000100010001101100011",
                "1100001110100010001000111000001000100100000000",
                "1000100010000000100010001000000010101"
                ].joined(separator: "")),
            "Basic UInt128 to Binary Uppercase String Conversion Failed"
        )
        // Invalid characters.
        do {
            let _ = try UInt128("0b002")
            XCTFail("Binary String with Invalid Character didn't throw.")
        } catch UInt128Errors.invalidStringCharacter {
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
                ].joined(separator: "")
            )
            XCTFail("Binary String Overflow didn't throw.")
        } catch UInt128Errors.stringInputOverflow {
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
        } catch UInt128Errors.invalidStringCharacter {
            XCTAssert(true)
        } catch {
            XCTFail("Octal String with Invalid Character didn't throw correctly.")
        }
        // Overflow.
        do {
            let _ = try UInt128("0o7654321076543210765432107654321765432107654")
            XCTFail("Octal String overflow didn't throw.")
        } catch UInt128Errors.stringInputOverflow {
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
        } catch UInt128Errors.invalidStringCharacter {
            XCTAssert(true)
        } catch {
            XCTFail("Decimal String with Invalid Character didn't throw correctly.")
        }
        // Overflow.
        do {
            let _ = try UInt128("987654321098765432109876543210987654320")
            XCTFail("Decimal String overflow didn't throw.")
        } catch UInt128Errors.stringInputOverflow {
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
        } catch UInt128Errors.invalidStringCharacter {
            XCTAssert(true)
        } catch {
            XCTFail("Hexadecimal String with Invalid Character Didn't Throw Correctly.")
        }
        // Overflow.
        do {
            let _ = try UInt128("0xfedcba9876543210fedcba9876543210f")
            XCTFail("Hexadecimal string overflow didn't throw.")
        } catch UInt128Errors.stringInputOverflow {
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
class UInt128UnsignedIntegerTests: XCTestCase {
    func testUIntInputs() {
        // Test UInt8 Input
        XCTAssertEqual(
            UInt128(UInt8.max).toUIntMax(), UInt8.max.toUIntMax(),
            "UInt8.max Fed Into UInt128 Doesn't Equal UInt8.max"
        )
        // Test UInt16 Input
        XCTAssertEqual(
            UInt128(UInt16.max).toUIntMax(), UInt16.max.toUIntMax(),
            "UInt16.max Fed Into UInt128 Doesn't Equal UInt16.max"
        )
        // Test UInt32 Input
        XCTAssertEqual(
            UInt128(UInt32.max).toUIntMax(), UInt32.max.toUIntMax(),
            "UInt32.max Fed Into UInt128 Doesn't Equal UInt32.max"
        )
        // Test UInt64 Input
        XCTAssertEqual(
            UInt128(UInt64.max).toUIntMax(), UInt64.max.toUIntMax(),
            "UInt64.max Fed Into UInt64 Doesn't Equal UInt64.max"
        )
        // Test UInt Input
        XCTAssertEqual(
            UInt128(UInt.max).toUIntMax(), UInt.max.toUIntMax(),
            "UInt.max Fed Into UInt128 Doesn't Equal UInt.max"
        )
    }
    func testToUIntMax() {
        XCTAssertEqual(
            UInt128.max.toUIntMax(), UIntMax.max,
            "UInt128.max Converted to UIntMax.max Doesn't Equal UIntMax.max"
        )
    }
    /// An imperfect test of hash values. This method will walk through
    /// most of the possible values within a UInt128 type and make sure
    /// that 2 consecutive hash values are not the same.
    func testHashValues() {
        var previousValue = UInt128.min
        var currentValue = UInt128.min + 1
        while currentValue <= UInt128.max >> 1 {
            currentValue = (currentValue << 1) + 1
            if currentValue.hashValue == previousValue.hashValue {
                XCTFail("Hash Value is Not Unique")
            }
            previousValue = currentValue
        }
    }

}
class UInt128StrideableTests: XCTestCase {
    func testAdvancedBy() {
        XCTAssertEqual(
            UInt128.min.advanced(by: 1), UInt128(integerLiteral: 1),
            "0 Advanced by 1 Does Not Equal 1"
        )
        XCTAssertEqual(
            UInt128.min.advanced(by: -1), UInt128.max,
            "0 Advanced by -1 Does Not Equal UInt128.max"
        )
        XCTAssertEqual(
            UInt128.max.advanced(by: 1), UInt128.min,
            "UInt128.max Advanced by 1 Does not Equal UInt128.min"
        )
    }
    func testDistanceTo() {
        XCTAssertEqual(
            UInt128.min.distance(to: UInt128(Int.max)), Int.max,
            "0 Advanced by Int.max Does Not Equal Int.max"
        )
        XCTAssertEqual(
            UInt128(Int.max).distance(to: 0), -Int.max,
            "Distance to 0 from Int.max Doesn't Equal -Int.max"
        )
        XCTAssertEqual(
            UInt128(integerLiteral: 0).distance(to: UInt128(Int.max)), Int.max,
            "Distance to Int.max from 0 Doesn't Equal Int.max"
        )
        /*
        These tests need to wait for such a time that preconditions can be properly checked
        without requiring magical wizardry.
        XCTAssertEqual(
            UInt128(0).distanceTo(UInt128(Int.max) + 2), 0,
            "Distance to Int.max + 1 from 0 Doesn't Equal 0"
        )
        XCTAssertEqual(
            UInt128.max.distanceTo(UInt128(1) << 70), 1,
            "Things happened"
        )
        */
    }
}
class UInt128BitwiseOperationsTests: XCTestCase {
    let allZeros = UInt128.allZeros
    let allOnes = UInt128.max
    func testAllZeros() {
        XCTAssertEqual(
            allZeros.hi, 0,
            "Upper Bits of UInt128.allZeros Does Not Equal 0"
        )
        XCTAssertEqual(
            allZeros.lo, 0,
            "Lower Bits of UInt128.allZeros Does Not Equal 0"
        )
    }
    func testAND() {
        XCTAssertEqual(
            allZeros & allOnes, allZeros,
            "All Bits Equal To 0 ANDed With All Bits Equal to 1 Does Not Return an All Zero Pattern"
        )
        XCTAssertEqual(
            allZeros & allZeros, allZeros,
            "All Bits Equal to 0 ANDed With All Bits Equal to 0 Does Not Return an All Zero Pattern"
        )
        XCTAssertEqual(
            allOnes & allOnes, allOnes,
            "All Bits Equal to 1 ANDed With All Bits Equal to 1 Does Not Return an All Zero Pattern"
        )
        XCTAssertEqual(
            bizarreUInt128 & bizarreUInt128.bigEndian, try! UInt128("0xF0F0F4F0F0FAFCFEFEFCFAF0F0F4F0F0"),
            "Complicated Bit Pattern ANDed With Its Big Endian Conversion Doesn't Equal Expected Value"
        )
        var testValue = allZeros
        testValue &= allOnes
        XCTAssertEqual(
            testValue, allZeros,
            "All Bits Equal to 0 &= With All Bits Equal to 1 Does Not Return an All Zero Pattern"
        )
    }
    func testOR() {
        XCTAssertEqual(
            allZeros | allOnes, allOnes,
            "All Bits Equal to 0 ORed With All Bits Equal to 1 Does Not Return an All One Pattern"
        )
        XCTAssertEqual(
            allZeros | allZeros, allZeros,
            "All Bits Equal to 0 ORed With All Bits Equal to 0 Does Not Return an All Zero Pattern"
        )
        XCTAssertEqual(
            allOnes | allOnes, allOnes,
            "All Bits Equal to 1 ORed With All Bits Equal to 1 Does Not Retun an All One Pattern"
        )
        XCTAssertEqual(
            bizarreUInt128 | bizarreUInt128.bigEndian, try! UInt128("0xF3F7F7FFF9FBFDFFFFFDFBF9FFF7F7F3"),
            "Complicated Bit Pattern ORed With Its Big Endian Conversion Doesn't Equal Expected Value"
        )
        var testValue = allZeros
        testValue += allOnes
        XCTAssertEqual(
            testValue, allOnes,
            "All Bits Equal to 0 += With All Bits Equal to 1 Does Not Return an All One Pattern"
        )
    }
    func testXOR() {
        XCTAssertEqual(
            allZeros ^ allOnes, allOnes,
            "All Bits Equal to 0 XORed With All Bits Equal to 1 Does Not Return an All One Pattern"
        )
        XCTAssertEqual(
            allZeros ^ allZeros, allZeros,
            "All Bits Equal to 0 XORed With All Bits Equal to 0 Does Not Return an All Zero Pattern"
        )
        XCTAssertEqual(
            allOnes ^ allOnes, allZeros,
            "All Bits Equal to 1 XORed With All Bits Equal to 1 Does Not Return an All Zero Pattern"
        )
        XCTAssertEqual(
            bizarreUInt128 ^ bizarreUInt128.bigEndian, try! UInt128("0x307030F09010101010101090F030703"),
            "Complicated Bit Pattern XORed With Its Big Endian Conversion Doesn't Equal Expected Value"
        )
        var testValue = bizarreUInt128
        testValue ^= bizarreUInt128.bigEndian
        XCTAssertEqual(
            testValue, try! UInt128("0x307030F09010101010101090F030703"),
            "Complicated Bit Pattern ^= With All Its Big Endian Conversion Doesn't Equal Expected Value"
        )
    }
    func testComplement() {
        XCTAssertEqual(
            ~allZeros, allOnes,
            "Complement of All Bits Equal to 0 Does Not Return an All One Pattern"
        )
        XCTAssertEqual(
            ~allOnes, allZeros,
            "Complement of All Bits Equal to 1 Does Not Return an All Zero Pattern"
        )
        XCTAssertEqual(
            ~bizarreUInt128, try! UInt128("0xE0C0A08060402000103050F07090B0D"),
            "Complement of Complicated Bit Pattern Doesn't Equal Expected Value"
        )
    }
    func testShiftLeft() {
        XCTAssertEqual(
            UInt128(1) << UInt128(hi: 1, lo: 0), 0,
            "1 Shifted by UIntMax.max + 1 Didn't Shift Out All Values"
        )
        XCTAssertEqual(
            UInt128(1) << 129, 0,
            "1 Shifted by Bit Storage Area + 1 Didn't Shift Out All Values"
        )
        XCTAssertEqual(
            UInt128(1) << 128, 0,
            "1 Shifted by Bit Storage Area Didn't Shift Out All Values"
        )
        XCTAssertEqual(
            bizarreUInt128 << 0, bizarreUInt128,
            "Complicated Bit Pattern Shifted by 0 Bits Doesn't Equal Complicated Bit Pattern"
        )
        XCTAssertEqual(
            (bizarreUInt128 << 64).hi, bizarreUInt128.lo,
            "Complicated Bit Pattern Shifted by 64 Bits Doesn't Have hi Equal Original lo"
        )
        XCTAssertEqual(
            (bizarreUInt128 << 64).lo, 0,
            "Complicated Bit Pattern Shifted by 64 Bits Has a Value in Lower 64 Bits"
        )
        XCTAssertEqual(
            try! UInt128("0b101") << 3, 40,
            "5 Shifted 3 Bits Doesn't Equal 40"
        )
        XCTAssertEqual(
            try! UInt128("0b1101") << 67, try! UInt128("0x680000000000000000"),
            "13 Shifted 67 Bits Doesn't Equal Expected Value"
        )
        var testValue: UInt128 = 5
        testValue <<= 3
        XCTAssertEqual(
            testValue, 40,
            "5 <<= 3 Doesn't Equal 40"
        )
    }
    func testShiftRight() {
        XCTAssertEqual(
            bizarreUInt128 >> UInt128(hi: 1, lo: 0), 0,
            "Complicated Number Shifted by UIntMax.max + 1 Didn't Shift Out All Values"
        )
        XCTAssertEqual(
            bizarreUInt128 >> 129, 0,
            "Complicated Number by Bit Storage Area + 1 Didn't Shift Out All Values"
        )
        XCTAssertEqual(
            bizarreUInt128 >> 128, 0,
            "Complicated Number Shifted by Bit Storage Area Didn't Shift Out All Values"
        )
        XCTAssertEqual(
            bizarreUInt128 >> 0, bizarreUInt128,
            "Complicated Bit Pattern Shifted by 0 Bits Doesn't Equal Complicated Bit Pattern"
        )
        XCTAssertEqual(
            (bizarreUInt128 >> 64).lo, bizarreUInt128.hi,
            "Complicated Bit Pattern Shifted by 64 Bits Doesn't Have Lower 64 Bits Equal Original Upper 64 Bits"
        )
        XCTAssertEqual(
            (bizarreUInt128 >> 64).hi, 0,
            "Complicated Bit Pattern Shifted by 64 Bits Has a Value in Upper 64 Bits"
        )
        XCTAssertEqual(
            try! UInt128("0b101000") >> 3, 5,
            "40 Shifted 3 Bits Doesn't Equal 5"
        )
        XCTAssertEqual(
            try! UInt128("0x680000000000000000") >> 67, try! UInt128("0b1101"),
            "Large Number Shifted 67 Bits Doesn't Equal 15"
        )
        var testValue: UInt128 = 40
        testValue >>= 3
        XCTAssertEqual(
            testValue, 5,
            "40 >>= 3 Doesn't Equal 5"
        )
    }
}
class UInt128IntegerArithmeticTests: XCTestCase {
    func testAddition() {
        var mathOperation = UInt128.addWithOverflow(UInt128(UInt64.max), 1)
        XCTAssert(
            mathOperation.overflow == false && mathOperation.0 == UInt128(hi: 1, lo: 0),
            "Crossing the 64 Bit Boundary by 1 Didn't Give the Expected Result"
        )
        mathOperation = UInt128.addWithOverflow(UInt128.max, 1)
        XCTAssert(
            mathOperation.overflow == true && mathOperation.0 == 0,
            "128 Bit Overflow by 1 Didn't Give the Expected Result"
        )
        mathOperation = UInt128.addWithOverflow(0, UInt128.max)
        XCTAssert(
            mathOperation.overflow == false && mathOperation.0 == UInt128.max,
            "Adding UInt128.max to 0 Doesn't Equal UInt128.max"
        )
        mathOperation = UInt128.addWithOverflow(2, UInt128.max)
        XCTAssert(
            mathOperation.overflow == true && mathOperation.0 == 1,
            "Adding UInt128.max to 2 Doesn't Equal 1"
        )
        mathOperation = UInt128.addWithOverflow(bizarreUInt128, bizarreUInt128.bigEndian)
        let expectedResult = try! UInt128("0xE4E8ECF0EAF6FAFEFEFAF6EAF0ECE8E3")
        XCTAssert(
            mathOperation.overflow == true && mathOperation.0 == expectedResult,
            "Complicated Bit Pattern Added to its Big Endian Representation Didn't Give Expected Result"
        )
        var testInteger: UInt128 = 2
        testInteger += 5
        XCTAssertEqual(
            testInteger, 7,
            "2 += 5 Doesn't Equal Expected Result"
        )
    }
    func testSubtraction() {
        var mathOperation = UInt128.subtractWithOverflow(UInt128(UInt64.max) + 1, 1)
        XCTAssert(
            mathOperation.overflow == false && mathOperation.0 == UInt128(UInt64.max),
            "Crossing the 64 Bit Boundary by 1 Didn't Give the Expected Result"
        )
        mathOperation = UInt128.subtractWithOverflow(UInt128.min, 1)
        XCTAssert(
            mathOperation.overflow == true && mathOperation.0 == UInt128.max,
            "128 Bit Underflow by 1 Didn't Give the Expected Result"
        )
        mathOperation = UInt128.subtractWithOverflow(UInt128.max, UInt128.max)
        XCTAssert(
            mathOperation.overflow == false && mathOperation.0 == 0,
            "Subtracting Across the Whole Value Range Didn't Equal 0"
        )
        mathOperation = UInt128.subtractWithOverflow(UInt128(UInt64.max), UInt128.max)
        XCTAssert(
            mathOperation.overflow == true && mathOperation.0 == UInt128(UInt64.max) + 1,
            "Underflow Across 64 Bit Boundaries Didn't Give the Expected Result"
        )
        mathOperation = UInt128.subtractWithOverflow(bizarreUInt128, bizarreUInt128.bigEndian)
        let expectedResult = try! UInt128("0xFEFEFEFF09010100FEFEFEF701010101")
        XCTAssert(
            mathOperation.overflow == true && mathOperation.0 == expectedResult,
            "Complicated Bit Pattern's Big Endian Representation Subtracted From Itself Didn't Give the Expected Result"
        )
        var testInteger: UInt128 = 7
        testInteger -= 2
        XCTAssertEqual(
            testInteger, 5,
            "7 -= 2 Doesn't Equal Expected Result"
        )
    }
    func testDivisionAndModulus() {
        var mathOperation = bizarreUInt128 /% 1
        XCTAssert(
            mathOperation.quotient == bizarreUInt128 && mathOperation.remainder == 0,
            "Complicated Bit Pattern / 1 Doesn't Equal Complicated Bit Pattern"
        )
        mathOperation = bizarreUInt128 /% bizarreUInt128
        XCTAssert(
            mathOperation.quotient == 1 && mathOperation.remainder == 0,
            "Complicated Bit Pattern / Itself Doesn't Equal 1"
        )
        mathOperation = 0 /% bizarreUInt128
        XCTAssert(
            mathOperation.quotient == 0 && mathOperation.remainder == 0,
            "0 / Complicated Bit Pattern Doesn't Equal 0"
        )
        mathOperation = bizarreUInt128 /% bizarreUInt128.bigEndian
        XCTAssert(
            mathOperation.quotient == 0 && mathOperation.remainder == bizarreUInt128,
            "Complicated Bit Pattern Divided by a Smaller Complicated Bit Pattern Doesn't Equal the First Bit Pattern"
        )
        mathOperation = UInt128.max /% (UInt128(UInt64.max) + 1)
        XCTAssert(
            mathOperation.quotient == UInt128(UInt64.max) && mathOperation.remainder == UInt128(UInt64.max),
            "Maximum Value Divided by Half the Bit Count of Maximum Value + 1 (Division Across 64 Bit Boundary) Doesn't Equal Half the Bit Count of Maximum Value"
        )
        var newMathOperation = UInt128.max
        newMathOperation /= UInt128(UInt64.max) + 1
        XCTAssertEqual(
            newMathOperation, UInt128(UInt64.max),
            "/= Doesn't Give the Same Result as /%'s Quotient"
        )
        newMathOperation = UInt128.max
        newMathOperation %= UInt128(UInt64.max) + 1
        XCTAssertEqual(
            newMathOperation, UInt128(UInt64.max),
            "%= Doesn't Give the Same Result as /%'s Remainder"
        )
    }
    func testMultiplication() {
        var mathOperation = UInt128.multiplyWithOverflow(1, 1)
        XCTAssert(
            mathOperation.0 == 1 && mathOperation.overflow == false,
            "1 * 1 Doesn't Equal 1"
        )
        mathOperation = UInt128.multiplyWithOverflow(UInt128(UInt64.max), 2)
        var expectedResult = try! UInt128("0x1FFFFFFFFFFFFFFFE")
        XCTAssert(
            mathOperation.0 == expectedResult && mathOperation.overflow == false,
            "Crossing the 64 Bit Boundary by 1 Bit Didn't Give the Correct Result"
        )
        mathOperation = UInt128.multiplyWithOverflow(UInt128.max, 1)
        XCTAssert(
            mathOperation.0 == UInt128.max && mathOperation.overflow == false,
            "UInt128.max Times 1 Doesn't Equal Expected Result"
        )
        mathOperation = UInt128.multiplyWithOverflow(1 << 97, 1 << 33)
        XCTAssert(
            mathOperation.0 == 0 && mathOperation.overflow == true,
            "LHS, 32bit Position 0 * RHS, 32bit Position 0 Overflow Check Failed"
        )
        mathOperation = UInt128.multiplyWithOverflow(1 << 97, UInt128(UInt32.max))
        expectedResult = try! UInt128("0xFFFFFFFE000000000000000000000000")
        XCTAssert(
            mathOperation.0 == expectedResult && mathOperation.overflow == true,
            "LHS, 32bit Position 1 * RHS, 32bit Position 4 Overflow Check Failed"
        )
        mathOperation = UInt128.multiplyWithOverflow(1 << 65, 1 << 65)
        XCTAssert(
            mathOperation.0 == 0 && mathOperation.overflow == true,
            "LHS, 32bit Position 2 * RHS, 32bit Position 2 Overflow Check Failed"
        )
        mathOperation = UInt128.multiplyWithOverflow(1 << 65, UInt128(UInt32.max) << 32)
        XCTAssert(
            mathOperation.0 == expectedResult && mathOperation.overflow == true,
            "LHS, 32bit Position 2 * RHS, 32bit Position 3 Overflow Check Failed"
        )
        mathOperation = UInt128.multiplyWithOverflow(1 << 32, 1 << 96)
        XCTAssert(
            mathOperation.0 == 0 && mathOperation.overflow == true,
            "LHS, 32bit Position 3 * RHS, 32bit Position 1 Overflow Check Failed"
        )
        mathOperation = UInt128.multiplyWithOverflow(UInt128(UInt32.max) << 32, 1 << 65)
        XCTAssert(
            mathOperation.0 == expectedResult && mathOperation.overflow == true,
            "LHS, 32bit Position 3 * RHS, 32bit Position 2 Overflow Check Failed"
        )
        mathOperation = UInt128.multiplyWithOverflow(UInt128(UInt32.max), 1 << 97)
        XCTAssert(
            mathOperation.0 == expectedResult && mathOperation.overflow == true,
            "LHS, 32bit Position 4 * RHS, 32bit Position 1 Overflow Check Failed"
        )
        mathOperation = UInt128.multiplyWithOverflow(bizarreUInt128, bizarreUInt128.bigEndian)
        expectedResult = try! UInt128("0b11110110110100010000100101011011111001100001000011011101111010010100001010110111000010010011110010110100100110000100110111010010")
        XCTAssert(
            mathOperation.0 == expectedResult && mathOperation.overflow == true,
            "Complicated Number Multiplied by Its Big Endian Version Didn't Give Expected Result"
        )
        var newMathOperation = UInt128(UInt64.max)
        newMathOperation *= 2
        expectedResult = try! UInt128("0x1FFFFFFFFFFFFFFFE")
        XCTAssertEqual(
            newMathOperation, expectedResult,
            "*= Didn't Give the Same Result as multiplyWithOverflow"
        )
    }
}
class UInt128ComparableTests: XCTestCase {
    func testComparable() {
        XCTAssertGreaterThan(
            UInt128(UInt64.max) << 64, UInt128(UInt64.max),
            "RHS Upper 64 Bits Equal to LHS Lower 64 Bits Didn't Compare Correctly"
        )
        XCTAssertGreaterThan(
            UInt128(1), 0,
            "1 Isn't Greater Than 0"
        )
        XCTAssertLessThan(
            UInt128(UInt64.max), UInt128(UInt64.max) << 64,
            "LHS Upper 64 Bits Equal to LHS 64 Bits Didn't Compare Correctly"
        )
        XCTAssertLessThan(
            UInt128(0), 1,
            "0 Isn't Less Than 1"
        )
    }
    func testEquatable() {
        XCTAssertEqual(
            UInt128.max, UInt128.max,
            "Max Doesn't Equal Max"
        )
        XCTAssertEqual(
            UInt64(UInt128(0)), 0,
            "0 Doesn't Equal 0"
        )
        XCTAssertNotEqual(
            bizarreUInt128, bizarreUInt128.bigEndian,
            "Complicated Pattern Equals its Big Endian Counterpart"
        )
    }
}
