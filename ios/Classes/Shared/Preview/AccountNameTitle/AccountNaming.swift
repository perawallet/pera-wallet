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

//   AccountNaming.swift

import Foundation

enum AccountNaming {
    static func getPrimaryName(for account: Account) -> String {
        return account.name.unwrap(or: account.address.shortAddressDisplay)
    }

    static func getSecondaryName(for account: Account) -> String? {
        let name = account.name
        let address = account.address
        let shortAddressDisplay = address.shortAddressDisplay

        if account.type == .standard,
           name == shortAddressDisplay {
            return nil
        }

        let subtitle: String?

        if (name != nil && name != shortAddressDisplay) {
            subtitle = shortAddressDisplay
        } else {
            subtitle = account.typeTitle
        }

        return subtitle
    }
}
