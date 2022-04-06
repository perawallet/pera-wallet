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
//  String+Address.swift

import Foundation

let validatedAddressLength = 58
let defaultParticipationKey = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

extension String {
    var hasValidAddressLength: Bool {
        count == validatedAddressLength
    }

    var isValidatedAddress: Bool {
        return AlgorandSDK().isValidAddress(self)
    }
    
    var shortAddressDisplay: String {
        return String(prefix(6)) + "..." + String(suffix(6))
    }

    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension Optional where Wrapped == String {
    var shortAddressDisplay: String? {
        guard let string = self else {
            return self
        }

        return string.shortAddressDisplay
    }
}
