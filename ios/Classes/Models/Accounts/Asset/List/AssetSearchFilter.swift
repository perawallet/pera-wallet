// Copyright 2019 Algorand, Inc.

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
//  AssetSearchFilter.swift

import Foundation

struct AssetSearchFilter: OptionSet {
    let rawValue: Int
        
    static let verified = AssetSearchFilter(rawValue: 1 << 0)
    static let unverified = AssetSearchFilter(rawValue: 1 << 1)
    static let all: AssetSearchFilter = [.verified, .unverified]
    
    var stringValue: String? {
        if self == .verified {
            return "verified"
        }
        
        if self == .unverified {
            return "unverified"
        }
        
        return nil
    }
    
    func canToggle(_ filterOption: AssetSearchFilter) -> Bool {
        return subtracting(filterOption) != []
    }
    
    mutating func toggle(_ filterOption: AssetSearchFilter) {
        if self == .all {
            subtract(filterOption)
        } else if self != filterOption {
            formUnion(filterOption)
        }
    }
}
