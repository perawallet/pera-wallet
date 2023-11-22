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
//   WCSessionDisconnectedEvent.swift

import Foundation
import MacaroonVendors

struct WCSessionDisconnectedEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        version: WalletConnectProtocolID,
        dappName: String,
        dappURL: String,
        address: String?
    ) {
        var metadata: ALGAnalyticsMetadata = [:]
        metadata[.wcVersion] = version.rawValue
        metadata[.dappName] = Self.regulate(dappName)
        metadata[.dappURL] = Self.regulate(dappURL)

        if let address = address {
            metadata[.accountAddress] = Self.regulate(address)
        }

        self.name = .wcSessionDisconnected
        self.metadata = metadata
    }
}

extension AnalyticsEvent where Self == WCSessionDisconnectedEvent {
    static func wcSessionDisconnected(
        version: WalletConnectProtocolID,
        dappName: String,
        dappURL: String,
        address: String?
    ) -> Self {
        return WCSessionDisconnectedEvent(
            version: version,
            dappName: dappName,
            dappURL: dappURL,
            address: address
        )
    }
}
