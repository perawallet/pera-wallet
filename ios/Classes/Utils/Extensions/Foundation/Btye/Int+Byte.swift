// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  Int+Byte.swift

import Foundation

extension Int {
    func removeExcessBytes() -> Int {
        return self & 0xFF
    }
    
    func toByteArray() -> [UInt8] {
        return [(self >> 24).asByte, (self >> 16).asByte, (self >> 8).asByte, self.asByte]
    }
    
    var asByte: UInt8 {
        UInt8(self)
    }
}
