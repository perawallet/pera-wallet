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
//   OneTimeDisplayStorage.swift

import UIKit

class OneTimeDisplayStorage: Storable {
    typealias Object = Any

    func setDisplayedOnce(for key: StorageKey) {
        save(true, for: key.rawValue, to: .defaults)
    }

    func isDisplayedOnce(for key: StorageKey) -> Bool {
        return bool(with: key.rawValue, to: .defaults)
    }
}

extension OneTimeDisplayStorage {
    enum StorageKey: String {
        case wcInitialWarning = "com.algorand.algorand.wc.warning.displayed"
        case ledgerPairingWarning = "com.algorand.algorand.ledger.pairing.warning.displayed"
    }
}
