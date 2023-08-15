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
        
        func byte(_ val: UInt8, nr: Int) -> UInt64 {
            let result = UInt64(integerLiteral: UInt64(val))
            return result << (nr * 8)
        }
        
        let val = uuid.uuid
        let lowerBits: UInt64 = byte(val.0, nr: 0) |
            byte(val.1, nr: 1) |
            byte(val.2, nr: 2) |
            byte(val.3, nr: 3) |
            byte(val.4, nr: 4) |
            byte(val.5, nr: 5) |
            byte(val.6, nr: 6) |
            byte(val.7, nr: 7)
        let upperBits: UInt64 = byte(val.8, nr: 0) |
            byte(val.9, nr: 1) |
            byte(val.10, nr: 2) |
            byte(val.11, nr: 3) |
            byte(val.12, nr: 4) |
            byte(val.13, nr: 5) |
            byte(val.14, nr: 6) |
            byte(val.15, nr: 7)        
        self = .init(upperBits: upperBits, lowerBits: lowerBits)
    }
    
}
