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
//   WCPeerMeta.swift

import Foundation

final class WCPeerMeta: Codable {
    let id: String
    let name: String
    let description: String?
    let icons: [URL]
    let url: URL

    init(dappInfo: WalletConnectSession.DAppInfo) {
        self.id = dappInfo.peerId
        self.name = dappInfo.peerMeta.name
        self.description = dappInfo.peerMeta.description
        self.icons = dappInfo.peerMeta.icons
        self.url = dappInfo.peerMeta.url
    }

    var dappInfo: WalletConnectSession.DAppInfo {
        return WalletConnectSession.DAppInfo(peerId: id, peerMeta: clientMeta, approved: true)
    }

    var clientMeta: WalletConnectSession.ClientMeta {
        return WalletConnectSession.ClientMeta(
            name: name,
            description: description,
            icons: icons,
            url: url
        )
    }
}
