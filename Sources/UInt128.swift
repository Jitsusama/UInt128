//
// UInt128.swift
//
// An implementation of a 128-bit unsigned integer data type not
// relying on any outside libraries apart from Swift's standard
// library. It also seeks to implement the entirety of the
// UnsignedInteger protocol as well as standard functions supported
// by Swift's native unsigned integer types.
//
// Copyright 2017 Joel Gerber
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

// MARK: Error Type
/// An `ErrorType` for `UInt128` data types. It includes cases
/// for errors that can occur during string
/// conversion.
public enum UInt128Errors : Error {
    /// Input cannot be converted to a UInt128 value.
    case invalidString
}

// MARK: - Data Type
/// A 128-bit unsigned integer value type.
/// Storage is based upon a tuple of 2, 64-bit, unsigned integers.
public struct UInt128 {
    // MARK: Instance Properties
    /// Internal value is presented as a tuple of 2 64-bit
    /// unsigned integers.
    internal var value: (upperBits: UInt64, lowerBits: UInt64)

    /// Counts up the significant bits in stored data.
    public var significantBits: UInt128 {
        var significantBits: UInt128 = 0
        var bitsToWalk: UInt64 = 0 // The bits to crawl in loop.
        
        // When upperBits > 0, lowerBits are all significant.
        if self.value.upperBits > 0 {
            bitsToWalk = self.value.upperBits
            significantBits = 64
        } else if self.value.lowerBits > 0 {
            bitsToWalk = self.value.lowerBits
        }
        
        // Walk significant bits by shifting right until all bits are equal to 0.
        while bitsToWalk > 0 {
            bitsToWalk >>= 1
            significantBits += 1
        }
        
        return significantBits
    }
    
    /// Designated initializer for the UInt128 type.
    public init(upperBits: UInt64, lowerBits: UInt64) {
        value.upperBits = upperBits
        value.lowerBits = lowerBits
    }
    
    public init() {
        self.init(upperBits: 0, lowerBits: 0)
    }
    
    public init(_ source: UInt128) {
        self.init(upperBits: source.value.upperBits,
                  lowerBits: source.value.lowerBits)
    }
    
    public init(_ source: String) throws {
        if let result = UInt128._valueFromString(source) {
            self = result
        }
        else {
            throw UInt128Errors.invalidString
        }
    }
}

// MARK: - FixedWidthInteger Conformance

extension UInt128 : FixedWidthInteger {
    
    // MARK: Instance Properties
    
    public var nonzeroBitCount: Int {
        var nonZeroCount = 0
        var shiftWidth = 0
        
        while shiftWidth < 128 {
            let shiftedSelf = self &>> shiftWidth
            let currentBit = shiftedSelf & 1
            if currentBit == 1 {
                nonZeroCount += 1
            }
            shiftWidth += 1
        }
        
        return nonZeroCount
    }
    
    public var leadingZeroBitCount: Int {
        var zeroCount = 0
        var shiftWidth = 127
        
        while shiftWidth >= 0 {
            let currentBit = self &>> shiftWidth
            guard currentBit == 0 else { break }
            zeroCount += 1
            shiftWidth -= 1
        }
        
        return zeroCount
    }
    
    /// Returns the big-endian representation of the integer, changing the byte order if necessary.
    public var bigEndian: UInt128 {
        #if arch(i386) || arch(x86_64) || arch(arm) || arch(arm64)
            return self.byteSwapped
        #else
            return self
        #endif
    }

    /// Returns the little-endian representation of the integer, changing the byte order if necessary.
    public var littleEndian: UInt128 {
        #if arch(i386) || arch(x86_64) || arch(arm) || arch(arm64)
            return self
        #else
            return self.byteSwapped
        #endif
    }

    /// Returns the current integer with the byte order swapped.
    public var byteSwapped: UInt128 {
        return UInt128(upperBits: self.value.lowerBits.byteSwapped, lowerBits: self.value.upperBits.byteSwapped)
    }
    
    // MARK: Initializers
    /// Creates a UInt128 from a given value, with the input's value
    /// truncated to a size no larger than what UInt128 can handle.
    /// Since the input is constrained to an UInt, no truncation needs
    /// to occur, as a UInt is currently 64 bits at the maximum.
    public init(_truncatingBits bits: UInt) {
        self.init(upperBits: 0, lowerBits: UInt64(bits))
    }
    
    /// Creates an integer from its big-endian representation, changing the
    /// byte order if necessary.
    public init(bigEndian value: UInt128) {
        #if arch(i386) || arch(x86_64) || arch(arm) || arch(arm64)
            self = value.byteSwapped
        #else
            self = value
        #endif
    }
    
    /// Creates an integer from its little-endian representation, changing the
    /// byte order if necessary.
    public init(littleEndian value: UInt128) {
        #if arch(i386) || arch(x86_64) || arch(arm) || arch(arm64)
            self = value
        #else
            self = value.byteSwapped
        #endif
    }
    
    // MARK: Instance Methods
    public func addingReportingOverflow(_ rhs: UInt128) -> (partialValue: UInt128, overflow: ArithmeticOverflow) {
        var resultOverflow = ArithmeticOverflow.none
        // Add lower bits and check for overflow.
        let (lowerBits, lowerOverflow) = self.value.lowerBits.addingReportingOverflow(rhs.value.lowerBits)
        // Add upper bits and check for overflow.
        var (upperBits, upperOverflow) = self.value.upperBits.addingReportingOverflow(rhs.value.upperBits)
        // If the lower bits overflowed, we need to add 1 to upper bits.
        if lowerOverflow == .overflow {
            (upperBits, resultOverflow) = upperBits.addingReportingOverflow(1)
        }
        let hasOverflowed = (upperOverflow == .overflow) || (resultOverflow == .overflow)
        return (partialValue: UInt128(upperBits: upperBits, lowerBits: lowerBits),
                overflow: ArithmeticOverflow(hasOverflowed))
    }
    
    public func subtractingReportingOverflow(_ rhs: UInt128) -> (partialValue: UInt128, overflow: ArithmeticOverflow) {
        var resultOverflow = ArithmeticOverflow.none
        // Subtract lower bits and check for overflow.
        let (lowerBits, lowerOverflow) = self.value.lowerBits.subtractingReportingOverflow(rhs.value.lowerBits)
        // Subtract upper bits and check for overflow.
        var (upperBits, upperOverflow) = self.value.upperBits.subtractingReportingOverflow(rhs.value.upperBits)
        // If the lower bits overflowed, we need to subtract (borrow) 1 from the upper bits.
        if lowerOverflow == .overflow {
            (upperBits, resultOverflow) = upperBits.subtractingReportingOverflow(1)
        }
        let hasOverflowed = (upperOverflow == .overflow) || (resultOverflow == .overflow)
        return (partialValue: UInt128(upperBits: upperBits, lowerBits: lowerBits),
                overflow: ArithmeticOverflow(hasOverflowed))
    }
    
    public func multipliedReportingOverflow(by rhs: UInt128) -> (partialValue: UInt128, overflow: ArithmeticOverflow) {
        // Useful bitmasks to be used later.
        let lower32 = UInt64(UInt32.max)
        let upper32 = ~UInt64(UInt32.max)
        // Decompose lhs into an array of 4, 32 significant bit UInt64s.
        let lhsArray = [
            self.value.upperBits >> 32, /*0*/ self.value.upperBits & lower32, /*1*/
            self.value.lowerBits >> 32, /*2*/ self.value.lowerBits & lower32  /*3*/
        ]
        // Decompose rhs into an array of 4, 32 significant bit UInt64s.
        let rhsArray = [
            rhs.value.upperBits >> 32, /*0*/ rhs.value.upperBits & lower32, /*1*/
            rhs.value.lowerBits >> 32, /*2*/ rhs.value.lowerBits & lower32  /*3*/
        ]
        // The future contents of this array will be used to store segment
        // multiplication results.
        var resultArray = [[UInt64]].init(
            repeating: [UInt64].init(
                repeating: 0, count: 4
            ), count: 4
        )
        // Holds overflow status
        var overflow = ArithmeticOverflow.none
        // Loop through every combination of lhsArray[x] * rhsArray[y]
        for rhsSegment in 0 ..< rhsArray.count {
            for lhsSegment in 0 ..< lhsArray.count {
                let currentValue = lhsArray[lhsSegment] * rhsArray[rhsSegment]
                // Depending upon which segments we're looking at, we'll want to
                // check for overflow conditions and flag them when encountered.
                switch (lhsSegment, rhsSegment) {
                case (0, 0...2): // lhsSegment 1 * rhsSegment 1 to 3 shouldn't have a value.
                    if currentValue > 0 { overflow = .overflow }
                case (0, 3):     // lhsSegment 1 * rhsSegment 4 should only be 32 bits.
                    if currentValue >> 32 > 0 { overflow = .overflow }
                case (1, 0...1): // lhsSegment 2 * rhsSegment 1 or 2 shouldn't have a value.
                    if currentValue > 0 { overflow = .overflow }
                case (1, 2):     // lhsSegment 2 * rhsSegment 3 should only be 32 bits.
                    if currentValue >> 32 > 0 { overflow = .overflow }
                case (2, 0):     // lhsSegment 3 * rhsSegment 1 shouldn't have a value.
                    if currentValue > 0 { overflow = .overflow }
                case (2, 1):     // lhsSegment 3 * rhsSegment 2 should only be 32 bits.
                    if currentValue >> 32 > 0 { overflow = .overflow }
                case (3, 0):     // lhsSegment 4 * rhsSegment 1 should only be 32 bits.
                    if currentValue >> 32 > 0 { overflow = .overflow }
                default: break // only 1 overflow condition still exists which will be checked later.
                }
                // Save the current result into our two-dimensional result array.
                resultArray[lhsSegment][rhsSegment] = currentValue
            }
        }
        // Perform multiplication similar to pen and paper, ignoring calculations
        // that would definitely result in an overflow.
        let fourthBitSegment =  resultArray[3][3] & lower32
        var thirdBitSegment  =  resultArray[2][3] & lower32 +
                                resultArray[3][2] & lower32
        // Add overflow from 4th segment.
        thirdBitSegment     += (resultArray[3][3] & upper32) >> 32
        var secondBitSegment =  resultArray[1][3] & lower32 +
                                resultArray[2][2] & lower32 +
                                resultArray[3][1] & lower32
        // Add overflows from 3rd segment.
        secondBitSegment    += (resultArray[2][3] & upper32) >> 32
        secondBitSegment    += (resultArray[3][2] & upper32) >> 32
        var firstBitSegment  =  resultArray[0][3] & lower32 +
                                resultArray[1][2] & lower32 +
                                resultArray[2][1] & lower32 +
                                resultArray[3][0] & lower32
        // Add overflows from 2nd segment.
        firstBitSegment     += (resultArray[1][3] & upper32) >> 32
        firstBitSegment     += (resultArray[2][2] & upper32) >> 32
        firstBitSegment     += (resultArray[3][1] & upper32) >> 32
        // Slot the bit counts into the appropriate position with multiple adds.
        let hasOverflowed = (overflow == .overflow) || (firstBitSegment >> 32 > 0)
        let finalValue = UInt128(upperBits: firstBitSegment << 32, lowerBits: 0)
            &+ UInt128(upperBits: secondBitSegment, lowerBits: 0)
            &+ UInt128(upperBits: thirdBitSegment >> 32, lowerBits: thirdBitSegment << 32)
            &+ UInt128(fourthBitSegment)
        return (partialValue: finalValue, overflow: ArithmeticOverflow(hasOverflowed))
    }
    
    // TODO: Implement Me!
    public func multipliedFullWidth(by other: UInt128) -> (high: UInt128, low: UInt128.Magnitude) {
        fatalError("Not implemented!")
    }
    
    // TODO: Implement Me!
    public func dividedReportingOverflow(by rhs: UInt128) -> (partialValue: UInt128, overflow: ArithmeticOverflow) {
        fatalError("Not implemented!")
    }
    
    // TODO: Implement Me!
    public func dividingFullWidth(_ dividend: (high: UInt128, low: UInt128)) -> (quotient: UInt128, remainder: UInt128) {
        fatalError("Not implemented!")
    }
    
    // TODO: Implement Me!
    public func remainderReportingOverflow(dividingBy rhs: UInt128) -> (partialValue: UInt128, overflow: ArithmeticOverflow) {
        fatalError("Not implemented!")
    }
    
    /// Division and Modulus combined. Someone [else's] smart take on the
    /// [integer division with remainder] algorithm.
    ///
    /// [else's]:
    ///     https://github.com/calccrypto/uint128_t
    /// [integer division with remainder]:
    ///     https://en.wikipedia.org/wiki/Division_algorithm#Integer_division_.28unsigned.29_with_remainder
    public func quotientAndRemainder(dividingBy rhs: UInt128) -> (quotient: UInt128, remainder: UInt128) {
        // Naughty boy, trying to divide by 0.
        precondition(rhs != 0, "Division by 0")
        
        let (dividend, divisor) = (self, rhs)
        
        // x/1 = x
        if divisor == 1 {
            return (quotient: dividend, remainder: 0)
        }
        // x/x = 1
        if dividend == divisor {
            return (quotient: 1, remainder: 0)
        }
        // 0/x = 0
        if dividend == 0 {
            return (quotient: 0, remainder: 0)
        }
        // x = y/z, when y < z, x = 0, r: y
        // This would happen with below logic, but doing it now saves a few cycles.
        if dividend < divisor {
            return (quotient: 0, remainder: dividend)
        }
        // Prime the result making the remainder equal the dividend. This will get
        // decremented until no further even divisions can be made.
        var result: (quotient: UInt128, remainder: UInt128) = (0, dividend)
        // Initially shift the divisor left by significant bit difference so that quicker
        // division can take place. IE: Discover GCD (Greatest Common Divisor).
        // This value will get shifted right as the algorithm gets closer to the final solution.
        var shiftedDivisor = divisor << (dividend.significantBits - divisor.significantBits)
        // Initially shift 1 by the same amount as shiftedDivisor. Subtracting shiftedDivisor
        // from dividend will be equal to that many subtractions of divisor from dividend.
        var adder: UInt128 = 1 << (dividend.significantBits - divisor.significantBits)
        // Remainder cannot be allowed to get below the divisor.
        while result.remainder >= divisor {
            // If remainder is great than shiftedDivisor we need to loop again as our
            // bit shift is to high for even division.
            if result.remainder >= shiftedDivisor {
                result.remainder -= shiftedDivisor
                result.quotient += adder
            }
            // Protect ourselves from shifting too far too fast.
            if result.remainder.significantBits <= shiftedDivisor.significantBits {
                // Continue to shift down until we've reached our final even division.
                shiftedDivisor >>= 1
                adder >>= 1
            }
        }
        return result
    }
}

// MARK: - BinaryInteger Conformance
extension UInt128 : BinaryInteger {
    
    // MARK: Instance Properties
    
    public static var bitWidth : Int { return 128 }
    
    public var trailingZeroBitCount: Int {
        let mask: UInt128 = 1
        var bitsToWalk = self
        
        for currentPosition in 0...128 {
            if bitsToWalk & mask == 1 {
                return currentPosition
            }
            bitsToWalk >>= 1
        }
        
        return 128
    }
    
    // MARK: Initializers
    
    public init?<T : FloatingPoint>(exactly source: T) {
        if source.isZero {
            self = UInt128()
        }
        else if source.exponent < 0 || source.rounded() != source {
            return nil
        }
        else {
            self = UInt128(UInt64(source))
        }
    }
    
    // TODO: Implement Me! Stub implementation only!
    public init<T : FloatingPoint>(_ source: T) {
        self.init()
    }
    
    // MARK: Instance Methods
    
    /// Return the word at position `n` in self.
    public func _word(at n: Int) -> UInt {
        if self == UInt128() {
            return UInt()
        }
        
        let shiftAmount: UInt64 = UInt64(UInt.bitWidth) * UInt64(n)
        let mask = UInt64(UInt.max)
        
        var shifted = self
        if shiftAmount > 0 {
            shifted &>>= UInt128(upperBits: 0, lowerBits: shiftAmount)
        }
        
        let masked: UInt128 = shifted & UInt128(upperBits: 0, lowerBits: mask)
        
        return UInt(masked.value.lowerBits)
    }
    
    // MARK: Type Methods
    public static func /(_ lhs: UInt128, _ rhs: UInt128) -> UInt128 {
        let result = lhs.dividedReportingOverflow(by: rhs)
        return result.partialValue
    }
    public static func /=(_ lhs: inout UInt128, _ rhs: UInt128) {
        lhs = lhs / rhs
    }
    public static func %(_ lhs: UInt128, _ rhs: UInt128) -> UInt128 {
        let result = lhs.remainderReportingOverflow(dividingBy: rhs)
        return result.partialValue
    }
    public static func %=(_ lhs: inout UInt128, _ rhs: UInt128) {
        lhs = lhs % rhs
    }
    /// Performs a bitwise AND operation on 2 UInt128 data types.
    public static func &=(_ lhs: inout UInt128, _ rhs: UInt128) {
        let upperBits = lhs.value.upperBits & rhs.value.upperBits
        let lowerBits = lhs.value.lowerBits & rhs.value.lowerBits
        lhs = UInt128(upperBits: upperBits, lowerBits: lowerBits)
    }
    /// Performs a bitwise OR operation on 2 UInt128 data types.
    public static func |=(_ lhs: inout UInt128, _ rhs: UInt128) {
        let upperBits = lhs.value.upperBits | rhs.value.upperBits
        let lowerBits = lhs.value.lowerBits | rhs.value.lowerBits
        lhs = UInt128(upperBits: upperBits, lowerBits: lowerBits)
    }
    /// Performs a bitwise XOR operation on 2 UInt128 data types.
    public static func ^=(_ lhs: inout UInt128, _ rhs: UInt128) {
        let upperBits = lhs.value.upperBits ^ rhs.value.upperBits
        let lowerBits = lhs.value.lowerBits ^ rhs.value.lowerBits
        lhs = UInt128(upperBits: upperBits, lowerBits: lowerBits)
    }
    
    /// Perform a masked right SHIFT operation self.
    ///
    /// The masking operation will mask `rhs` against the highest
    /// shift value that will not cause an overflowing shift before
    /// performing the shift. IE: `rhs = 128` will become `rhs = 0`
    /// and `rhs = 129` will become `rhs = 1`.
    public static func &>>=(_ lhs: inout UInt128, _ rhs: UInt128) {
        let shiftWidth = rhs.value.lowerBits & 127
        switch shiftWidth {
        case 0: return // Do nothing shift.
        case 1...63:
            let upperBits = lhs.value.upperBits >> shiftWidth
            let lowerBits = (lhs.value.lowerBits >> shiftWidth) + (lhs.value.upperBits << (64 - shiftWidth))
            lhs = UInt128(upperBits: upperBits, lowerBits: lowerBits)
        case 64:
            // Shift 64 means move upper bits to lower bits.
            lhs = UInt128(upperBits: 0, lowerBits: lhs.value.upperBits)
        default:
            let lowerBits = lhs.value.upperBits >> (shiftWidth - 64)
            lhs = UInt128(upperBits: 0, lowerBits: lowerBits)
        }
    }
    
    /// Perform a masked left SHIFT operation on self.
    ///
    /// The masking operation will mask `rhs` against the highest
    /// shift value that will not cause an overflowing shift before
    /// performing the shift. IE: `rhs = 128` will become `rhs = 0`
    /// and `rhs = 129` will become `rhs = 1`.
    public static func &<<=(_ lhs: inout UInt128, _ rhs: UInt128) {
        let shiftWidth = rhs.value.lowerBits & 127
        switch shiftWidth {
        case 0: return // Do nothing shift.
        case 1...63:
            let upperBits = (lhs.value.upperBits << shiftWidth) + (lhs.value.lowerBits >> (64 - shiftWidth))
            let lowerBits = lhs.value.lowerBits << shiftWidth
            lhs = UInt128(upperBits: upperBits, lowerBits: lowerBits)
        case 64:
            // Shift 64 means move lower bits to upper bits.
            lhs = UInt128(upperBits: lhs.value.lowerBits, lowerBits: 0)
        default:
            let upperBits = lhs.value.lowerBits << (shiftWidth - 64)
            lhs = UInt128(upperBits: upperBits, lowerBits: 0)
        }
    }
}

// MARK: - UnsignedInteger Conformance
extension UInt128 : UnsignedInteger {}

// MARK: - Hashable Conformance
extension UInt128 : Hashable {
    public var hashValue: Int {
        return self.value.lowerBits.hashValue ^ self.value.upperBits.hashValue
    }
}

// MARK: - Numeric Conformance
extension UInt128 : Numeric {
    public static func +(_ lhs: UInt128, _ rhs: UInt128) -> UInt128 {
        precondition(~lhs >= rhs, "Addition overflow!")
        let result = lhs.addingReportingOverflow(rhs)
        return result.partialValue
    }
    public static func +=(_ lhs: inout UInt128, _ rhs: UInt128) {
        lhs = lhs + rhs
    }
    public static func -(_ lhs: UInt128, _ rhs: UInt128) -> UInt128 {
        precondition(lhs >= rhs, "Integer underflow")
        let result = lhs.subtractingReportingOverflow(rhs)
        return result.partialValue
    }
    public static func -=(_ lhs: inout UInt128, _ rhs: UInt128) {
        lhs = lhs - rhs
    }
    public static func *(_ lhs: UInt128, _ rhs: UInt128) -> UInt128 {
        let result = lhs.multipliedReportingOverflow(by: rhs)
        precondition(result.overflow != .overflow, "Multiplication overflow!")
        return result.partialValue
    }
    public static func *=(_ lhs: inout UInt128, _ rhs: UInt128) {
        lhs = lhs * rhs
    }
}

// MARK: - Equatable Conformance
extension UInt128 : Equatable {
    /// Checks if the `lhs` is equal to the `rhs`.
    public static func ==(lhs: UInt128, rhs: UInt128) -> Bool {
        if lhs.value.lowerBits == rhs.value.lowerBits && lhs.value.upperBits == rhs.value.upperBits {
            return true
        }
        return false
    }
}

// MARK: - ExpressibleByIntegerLiteral Conformance
extension UInt128 : ExpressibleByIntegerLiteral {
    // MARK: Initializers
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(upperBits: 0, lowerBits: UInt64(value))
    }
}

// MARK: - CustomStringConvertible Conformance
extension UInt128 : CustomStringConvertible {
    // MARK: Instance Properties
    public var description: String {
        return self.toString()
    }
    
    /// Converts the stored value into a string representation.
    /// - parameter radix:
    ///     The radix for the base numbering system you wish to have
    ///     the type presented in.
    /// - parameter uppercase:
    ///     Determines whether letter components of the outputted string will be in
    ///     uppercase format or not.
    /// - returns:
    ///     String representation of the stored UInt128 value.
    internal func toString(radix: Int = 10, uppercase: Bool = true) -> String {
        precondition(radix > 1 && radix < 17, "radix must be within the range of 2-16.")
        // Will store the final string result.
        var result = String()
        // Simple case.
        if self == 0 {
            result.append("0")
            return result
        }
        // Used as the check for indexing through UInt128 for string interpolation.
        var divmodResult = (quotient: self, remainder: UInt128(0))
        // Will hold the pool of possible values.
        let characterPool = (uppercase) ? "0123456789ABCDEF" : "0123456789abcdef"
        // Go through internal value until every base position is string(ed).
        repeat {
            divmodResult = divmodResult.quotient.quotientAndRemainder(dividingBy: UInt128(radix))
            let index = characterPool.characters.index(characterPool.startIndex, offsetBy: Int(divmodResult.remainder))
            result.insert(characterPool[index], at: result.startIndex)
        } while divmodResult.quotient > 0
        return result
    }
}

// MARK: - Comparable Conformance
extension UInt128 : Comparable {
    // MARK: Type Methods
    public static func <(lhs: UInt128, rhs: UInt128) -> Bool {
        if lhs.value.upperBits < rhs.value.upperBits {
            return true
        } else if lhs.value.upperBits == rhs.value.upperBits && lhs.value.lowerBits < rhs.value.lowerBits {
            return true
        }
        return false
    }
}

// MARK: - ExpressibleByStringLiteral Conformance
extension UInt128 : ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init()
        
        if let result = UInt128._valueFromString(value) {
            self = result
        }
    }
    
    internal static func _valueFromString(_ value: String) -> UInt128? {
        let radix = UInt128._determineRadixFromString(value)
        let inputString = radix == 10 ? value : String(value.dropFirst(2))
        
        return UInt128(inputString, radix: radix)
    }
    
    internal static func _determineRadixFromString(_ string: String) -> Int {
        let radix: Int
        
        if string.hasPrefix("0b") { radix = 2 }
        else if string.hasPrefix("0o") { radix = 8 }
        else if string.hasPrefix("0x") { radix = 16 }
        else { radix = 10 }
        
        return radix
    }
}

// MARK: - FloatingPoint Interworking
extension FloatingPoint {
    public init(_ value: UInt128) {
        precondition(value.value.upperBits == 0, "Value is too large to fit into a FloatingPoint until a 128bit FloatingPoint type is defined.")
        self.init(value.value.lowerBits)
    }
    
    public init?(exactly value: UInt128) {
        if value.value.upperBits > 0 {
            return nil
        }
        self = Self(value.value.lowerBits)
    }
}

extension UInt128 {
    /// Undocumented private variable required for passing this type
    /// to a FloatingPoint type. See FloatingPointTypes.swift.gyb in
    /// the Swift stdlib/public/core directory.
    var signBitIndex: Int {
        return 127 - leadingZeroBitCount
    }
}
