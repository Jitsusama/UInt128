//
//  UInt128+UUID.swift
//  UInt128
//
//  Created by Alfons Hoogervorst on 15/08/2023.
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

import Foundation

extension UInt128 {
    
    /// Creates a UInt128 from a UUID. Since a UUID is always 128 bits,
    /// no truncation is needed.
    public init(uuid: UUID) {
        let val = uuid.uuid
        let lowerBits: UInt64 = UInt64(val.0) << (0 * 8) |
            UInt64(val.1) << (1 * 8) |
            UInt64(val.2) << (2 * 8) |
            UInt64(val.3) << (3 * 8) |
            UInt64(val.4) << (4 * 8) |
            UInt64(val.5) << (5 * 8) |
            UInt64(val.6) << (6 * 8) |
            UInt64(val.7) << (7 * 8)
        let upperBits: UInt64 = UInt64(val.8) << (0 * 8) |
            UInt64(val.9) << (1 * 8) |
            UInt64(val.10) << (2 * 8) |
            UInt64(val.11) << (3 * 8) |
            UInt64(val.12) << (4 * 8) |
            UInt64(val.13) << (5 * 8) |
            UInt64(val.14) << (6 * 8) |
            UInt64(val.15) << (7 * 8)
        self = .init(upperBits: upperBits, lowerBits: lowerBits)
    }
    
}
