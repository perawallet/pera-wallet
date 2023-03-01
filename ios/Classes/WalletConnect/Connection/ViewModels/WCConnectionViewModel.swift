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

//   WCConnectionViewModel.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage

final class WCConnectionViewModel: ViewModel {
    private(set) var image: ImageSource?
    private(set) var title: NSAttributedString?
    private(set) var actionIcon: Image?
    private(set) var urlString: String?
    private(set) var subtitle: String?
    
    init(
        session: WalletConnectSession,
        hasSingleAccount: Bool
    ) {
        bindImage(session)
        bindDescription(session)
        bindUrlState(session)
        bindUrlString(session)
        bindListHeader(hasSingleAccount)
    }
}

extension WCConnectionViewModel {
    private func bindImage(_ session: WalletConnectSession) {
        self.image = DefaultURLImageSource(
            url: session.dAppInfo.peerMeta.icons.first,
            color: nil,
            size: .resize(
                CGSize(width: 72, height: 72),
                .aspectFit
            ),
            shape: .circle,
            placeholder: nil,
            forceRefresh: false
        )
    }
    
    private func bindDescription(_ session: WalletConnectSession) {
        let dappName = session.dAppInfo.peerMeta.name
        let fullText = "wallet-connect-session-connection-description".localized(dappName)
        let attributedFullText = NSMutableAttributedString(string: fullText)
        
        let range = (fullText as NSString).range(of: dappName)
        attributedFullText.addAttribute(
            NSAttributedString.Key.font,
            value: Typography.bodyLargeMedium(),
            range: range
        )
        
        self.title = attributedFullText
    }
    
    private func bindUrlString(_ session: WalletConnectSession) {
        self.urlString = session.dAppInfo.peerMeta.url.presentationString
    }
    
    private func bindListHeader(_ hasSingleAccount: Bool) {
        self.subtitle = hasSingleAccount
            ? "send-algos-select".localized.uppercased()
            : "wallet-connect-select-accounts".localized.uppercased()
    }
    
    private func bindUrlState(_ session: WalletConnectSession) {
        if session.dAppInfo.approved ?? false {
            self.actionIcon = img("WalletConnect/dapp-approved")
        }
    }
}
