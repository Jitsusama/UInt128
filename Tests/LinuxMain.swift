import XCTest

@testable import UInt128Tests

XCTMain([
  testCase(UInt128Tests.allTests),
  testCase(UInt128StringTests.allTests),
  testCase(UInt128UnsignedIntegerTests.allTests),
  testCase(UInt128StrideableTests.allTests),
  testCase(UInt128BitwiseOperationsTests.allTests),
  testCase(UInt128IntegerArithmeticTests.allTests),
  testCase(UInt128ComparableTests.allTests),
])
