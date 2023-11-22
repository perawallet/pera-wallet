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
//   DeeplinkSource.swift

import Foundation

enum DeeplinkSource {
    typealias UserInfo = [AnyHashable: Any]

    /// <note>
    /// `waitForUserConfirmation`
    /// true => Show message and wait for the user to confirm before taking any action.
    /// false => Take the action immediately.
    case remoteNotification(UserInfo, waitForUserConfirmation: Bool)
    case walletConnectSessionRequest(URL, prefersConnectionApproval: Bool = true)
    case walletConnectTransactionSignRequest(WalletConnectTransactionSignRequestDraft)
    case walletConnectArbitraryDataSignRequest(WalletConnectArbitraryDataSignRequestDraft)
    case qrText(QRText)
    case externalInAppBrowser(DiscoverExternalDestination)

    static func walletConnectSessionRequestForDiscover(_ url: URL) -> DeeplinkSource {
        return .walletConnectSessionRequest(url, prefersConnectionApproval: false)
    }
}

extension DeeplinkSource {
    static func decode(
        _ userInfo: UserInfo
    ) -> AlgorandNotification? {
        guard let aps = userInfo["aps"] else {
            return nil
        }

        guard let apsData = try? JSONSerialization.data(withJSONObject: aps) else {
            return nil
        }

        return try? AlgorandNotification.decoded(apsData)
    }
}

/// <todo>
/// I think we should move it elsewhere, but let's think about it later when refactoring Wallet
/// Connect infrastructure.
struct WalletConnectTransactionSignRequestDraft {
    let request: WalletConnectRequestDraft
    let transactions: [WCTransaction]
    var option: WCTransactionOption?
    let session: WCSessionDraft
}

struct WalletConnectArbitraryDataSignRequestDraft {
    let request: WalletConnectRequestDraft
    let arbitraryData: [WCArbitraryData]
    let session: WCSessionDraft
}
