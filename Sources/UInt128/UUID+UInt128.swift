//
//  UUID+UInt128.swift
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


extension UUID {
    
    /// Creates a UUID representation of a UInt128. Since a UUID is always
    /// 128 bits, no truncation occurs.
    public init(_ longInt: UInt128) {
        let lowerBits = longInt.value.lowerBits
        let upperBita = longInt.value.upperBits
        let val: uuid_t = (
            UInt8((lowerBits >> (0 * 8)) & 0xFF),
            UInt8((lowerBits >> (1 * 8)) & 0xFF),
            UInt8((lowerBits >> (2 * 8)) & 0xFF),
            UInt8((lowerBits >> (3 * 8)) & 0xFF),
            UInt8((lowerBits >> (4 * 8)) & 0xFF),
            UInt8((lowerBits >> (5 * 8)) & 0xFF),
            UInt8((lowerBits >> (6 * 8)) & 0xFF),
            UInt8((lowerBits >> (7 * 8)) & 0xFF),
            UInt8((upperBita >> (0 * 8)) & 0xFF),
            UInt8((upperBita >> (1 * 8)) & 0xFF),
            UInt8((upperBita >> (2 * 8)) & 0xFF),
            UInt8((upperBita >> (3 * 8)) & 0xFF),
            UInt8((upperBita >> (4 * 8)) & 0xFF),
            UInt8((upperBita >> (5 * 8)) & 0xFF),
            UInt8((upperBita >> (6 * 8)) & 0xFF),
            UInt8((upperBita >> (7 * 8)) & 0xFF)
        )
        self = .init(uuid: val)
    }
    
}
