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
//   WCWalletMeta.swift

import Foundation

final class WCWalletMeta: Codable {
    let accounts: [String]?
    let chainId: Int?
    let peerId: String?
    let peerMeta: WCPeerMeta

    init(walletInfo: WalletConnectSession.WalletInfo?, dappInfo: WalletConnectSession.DAppInfo) {
        self.accounts = walletInfo?.accounts
        self.chainId = walletInfo?.chainId
        self.peerId = walletInfo?.peerId
        self.peerMeta = WCPeerMeta(dappInfo: dappInfo)
    }

    var walletInfo: WalletConnectSession.WalletInfo? {
        guard let accounts = accounts,
              let chainId = chainId,
              let peerId = peerId else {
            return nil
        }

        return WalletConnectSession.WalletInfo(
            approved: true,
            accounts: accounts,
            chainId: chainId,
            peerId: peerId,
            peerMeta: peerMeta.clientMeta
        )
    }
}
