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

//   SwapDisplayStore.swift

import Foundation

final class SwapDisplayStore: Storable {
    typealias Object = Any

    static var isOnboardedToSwapNotification: Notification.Name {
        .init(rawValue: "isOnboardedToSwap")
    }

    var isOnboardedToSwap: Bool {
        get { userDefaults.bool(forKey: isOnboardedToSwapKey) }
        set { userDefaults.set(newValue, forKey: isOnboardedToSwapKey) }
    }

    var isConfirmedSwapUserAgreement: Bool {
        get { userDefaults.bool(forKey: isConfirmedSwapUserAgreementKey) }
        set { userDefaults.set(newValue, forKey: isConfirmedSwapUserAgreementKey) }
    }

    private let isOnboardedToSwapKey = "cache.key.swap.isOnboarded"
    private let isConfirmedSwapUserAgreementKey = "cache.key.swap.isConfirmedUserAgreement"
}
