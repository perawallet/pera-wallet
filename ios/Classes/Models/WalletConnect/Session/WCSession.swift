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
//   WCSession.swift

import Foundation

final class WCSession:
    Codable,
    Hashable {
    let urlMeta: WCURLMeta
    let peerMeta: WCPeerMeta
    let walletMeta: WCWalletMeta?
    let date: Date
    var isSubscribed: Bool

    private enum CodingKeys: CodingKey {
        case urlMeta
        case peerMeta
        case walletMeta
        case date
        case isSubscribed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.urlMeta = try container.decode(
            WCURLMeta.self,
            forKey: .urlMeta
        )
        self.peerMeta = try container.decode(
            WCPeerMeta.self,
            forKey: .peerMeta
        )
        self.walletMeta = try container.decodeIfPresent(
            WCWalletMeta.self,
            forKey: .walletMeta
        )
        self.date = try container.decode(
            Date.self,
            forKey: .date
        )
        self.isSubscribed = try container.decodeIfPresent(
            Bool.self,
            forKey: .isSubscribed
        ) ?? false
    }

    init(urlMeta: WCURLMeta, peerMeta: WCPeerMeta, walletMeta: WCWalletMeta?, date: Date) {
        self.urlMeta = urlMeta
        self.peerMeta = peerMeta
        self.walletMeta = walletMeta
        self.date = date
        self.isSubscribed = false
    }

    var sessionBridgeValue: WalletConnectSession {
        WalletConnectSession(url: urlMeta.wcURL, dAppInfo: peerMeta.dappInfo, walletInfo: walletMeta?.walletInfo)
    }

    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(urlMeta.topic)
    }

    static func == (
        lhs: WCSession,
        rhs: WCSession
    ) -> Bool {
        return lhs.urlMeta.topic == rhs.urlMeta.topic
    }
}
