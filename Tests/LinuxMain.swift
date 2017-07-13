import XCTest
@testable import UInt128Tests

XCTMain([
    testCase(BaseTypeTests.allTests),
    testCase(BinaryIntegerTests.allTests),
    testCase(ComparableTests.allTests),
    testCase(CustomDebugStringConvertibleTests.allTests),
    testCase(CustomStringConvertibleTests.allTests),
    testCase(DeprecatedAPITests.allTests),
    testCase(EquatableTests.allTests),
    testCase(ExpressibleByIntegerLiteralTests.allTests),
    testCase(ExpressibleByStringLiteralTests.allTests),
    testCase(FixedWidthIntegerTests.allTests),
    testCase(FloatingPointInterworkingTests.allTests),
    testCase(HashableTests.allTests),
    testCase(NumericTests.allTests),
    testCase(SystemTests.allTests),
])
