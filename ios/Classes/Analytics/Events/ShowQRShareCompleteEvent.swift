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
//  ShowQRShareCompleteEvent.swift

import Foundation
import MacaroonVendors

struct ShowQRShareCompleteEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        account: Account
    ) {
        self.name = .showQRShareComplete
        self.metadata = [
            .accountAddress: account.address
        ]
    }
}

extension AnalyticsEvent where Self == ShowQRShareCompleteEvent {
    static func showQRShareComplete(
        account: Account
    ) -> Self {
        return ShowQRShareCompleteEvent(account: account)
    }

    static func showQRShareComplete(
        address: String
    ) -> Self {
        let account = Account(address: address)
        return ShowQRShareCompleteEvent(account: account)
    }
}
