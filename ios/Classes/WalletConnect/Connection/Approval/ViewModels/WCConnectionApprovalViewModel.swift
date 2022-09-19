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
//   WCConnectionApprovalViewModel.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class WCConnectionApprovalViewModel: PairedViewModel {
    private(set) var image: ImageSource?
    private(set) var description: NSAttributedString?
    private(set) var urlString: String?

    init(_ session: WalletConnectSession) {
        bindImage(session)
        bindDescription(session)
        bindUrlString(session)
    }
}

extension WCConnectionApprovalViewModel {
    private func bindImage(_ session: WalletConnectSession) {
        image = PNGImageSource(
            url: session.dAppInfo.peerMeta.icons.first,
            color: nil,
            size: .resize(CGSize(width: 72, height: 72), .aspectFit),
            shape: .circle,
            placeholder: nil,
            forceRefresh: false
        )
    }

    private func bindDescription(_ session: WalletConnectSession) {
        let dappName = session.dAppInfo.peerMeta.name
        let fullText = "wallet-connect-session-connection-description".localized(dappName)
        let attributedText = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.font(withWeight: .regular(size: 18)),
                .foregroundColor: Colors.Text.main.uiColor
            ]
        )

        let range = (fullText as NSString).range(of: dappName)
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.font(withWeight: .semiBold(size: 18)), range: range)
        description = attributedText
    }

    private func bindUrlString(_ session: WalletConnectSession) {
        urlString = session.dAppInfo.peerMeta.url.absoluteString
    }
}
