//
// UInt128PerformanceTests.swift
//
// UInt128 performance test cases.
//
// Copyright 2023 Joel Gerber
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

@testable import UInt128

final class CustomStringConvertiblePerformanceTests: XCTestCase {
  func testCustomStringInitializer() throws {
    let options = XCTMeasureOptions()
    options.iterationCount = 1000

    self.measure(options: options) {
      _ = String(UInt128.max)
    }
  }

  func testStringLiteralInitializer() throws {
    let options = XCTMeasureOptions()
    options.iterationCount = 1000

    self.measure(options: options) {
      _ = UInt128("0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF")!
    }
  }
    
}

final class UUIDConvertibalePerformanceTests: XCTestCase {
    
    func testUUIDConversion() {
        let uuid = UUID(uuidString: "1F349019-F3F5-489F-85F5-9CD214D6BD69")!
        let options = XCTMeasureOptions()
        options.iterationCount = 1000
        self.measure(options: options) {
            _ = UInt128(uuid: uuid)
        }
    }
    
}
