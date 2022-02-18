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
//   WCURLMeta.swift

import Foundation

final class WCURLMeta: Codable {
    let topic: String
    let version: String
    let bridge: URL
    let key: String

    init(wcURL: WalletConnectURL) {
        self.topic = wcURL.topic
        self.version = wcURL.version
        self.bridge = wcURL.bridgeURL
        self.key = wcURL.key
    }

    var wcURL: WalletConnectURL {
        return WalletConnectURL(topic: topic, version: version, bridgeURL: bridge, key: key)
    }
}
