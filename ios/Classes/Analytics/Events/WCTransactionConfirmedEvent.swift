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
//   WCTransactionConfirmedEvent.swift

import Foundation
import MacaroonVendors

struct WCTransactionConfirmedEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        version: WalletConnectProtocolID,
        transactionID: String,
        dappName: String,
        dappURL: String
    ) {
        self.name = .wcTransactionConfirmed
        self.metadata = [
            .wcVersion: version.rawValue,
            .transactionID: transactionID,
            .dappName: Self.regulate(dappName),
            .dappURL: Self.regulate(dappURL)
        ]
    }
}

extension AnalyticsEvent where Self == WCTransactionConfirmedEvent {
    static func wcTransactionConfirmed(
        version: WalletConnectProtocolID,
        transactionID: String,
        dappName: String,
        dappURL: String
    ) -> Self {
        return WCTransactionConfirmedEvent(
            version: version,
            transactionID: transactionID,
            dappName: dappName,
            dappURL: dappURL
        )
    }
}
