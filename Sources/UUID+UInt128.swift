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

        func byte(_ nr: Int) -> UInt8 {
            let bits = (16 - (16 - nr)) * 8
            return UInt8((longInt >> bits) & 0xFF)
        }
        
        let val: uuid_t = (
            byte(0),
            byte(1),
            byte(2),
            byte(3),
            byte(4),
            byte(5),
            byte(6),
            byte(7),
            byte(8),
            byte(9),
            byte(10),
            byte(11),
            byte(12),
            byte(13),
            byte(14),
            byte(15)
        )
        self = .init(uuid: val)
    }
    
}
