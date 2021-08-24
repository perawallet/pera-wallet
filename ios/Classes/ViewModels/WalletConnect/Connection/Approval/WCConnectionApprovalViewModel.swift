// Copyright 2019 Algorand, Inc.

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
//   WCConnectionApprovalViewModel.swift

import UIKit
import Macaroon

class WCConnectionApprovalViewModel {
    private(set) var image: ImageSource?
    private(set) var description: NSAttributedString?
    private(set) var urlString: String?
    private(set) var connectionAccountSelectionViewModel: WCConnectionAccountSelectionViewModel?

    init(session: WalletConnectSession, account: Account) {
        setImage(from: session)
        setDescription(from: session)
        setUrlString(from: session)
        setConnectionAccountSelectionViewModel(from: account)
    }

    private func setImage(from session: WalletConnectSession) {
        image = PNGImageSource(
            url: session.dAppInfo.peerMeta.icons.first,
            color: nil,
            size: .resize(CGSize(width: 72.0, height: 72.0), .aspectFit),
            shape: .circle,
            placeholder: nil,
            forceRefresh: false
        )
    }

    private func setDescription(from session: WalletConnectSession) {
        let dappName = session.dAppInfo.peerMeta.name
        let fullText = "wallet-connect-session-connection-description".localized(dappName)
        let attributedText = NSMutableAttributedString(
            string: fullText,
            attributes: [.font: UIFont.font(withWeight: .regular(size: 18.0)), .foregroundColor: Colors.Text.primary]
        )

        let range = (fullText as NSString).range(of: dappName)
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.font(withWeight: .semiBold(size: 18.0)), range: range)
        description = attributedText
    }

    private func setUrlString(from session: WalletConnectSession) {
        urlString = session.dAppInfo.peerMeta.url.absoluteString
    }

    private func setConnectionAccountSelectionViewModel(from account: Account) {
        connectionAccountSelectionViewModel = WCConnectionAccountSelectionViewModel(account: account)
    }
}
