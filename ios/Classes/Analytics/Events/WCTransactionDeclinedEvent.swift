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
//   WCTransactionDeclinedEvent.swift

import Foundation
import MacaroonVendors

struct WCTransactionDeclinedEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        version: WalletConnectProtocolID,
        transactionCount: Int,
        dappName: String,
        dappURL: String,
        address: String?
    ) {
        var metadata: ALGAnalyticsMetadata = [:]
        metadata[.wcVersion] = version.rawValue
        metadata[.transactionCount] = transactionCount
        metadata[.dappName] = Self.regulate(dappName)
        metadata[.dappURL] = Self.regulate(dappURL)

        if let address = address {
            metadata[.accountAddress] = Self.regulate(address)
        }

        self.name = .wcTransactionDeclined
        self.metadata = metadata
    }
}

extension AnalyticsEvent where Self == WCTransactionDeclinedEvent {
    static func wcTransactionDeclined(
        version: WalletConnectProtocolID,
        transactionCount: Int,
        dappName: String,
        dappURL: String,
        address: String?
    ) -> Self {
        return WCTransactionDeclinedEvent(
            version: version,
            transactionCount: transactionCount,
            dappName: dappName,
            dappURL: dappURL,
            address: address
        )
    }
}
