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
//   WCTransactionFullDappDetailConfigurator.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class WCTransactionFullDappDetailConfigurator {
    private(set) var image: ImageSource?
    private(set) var title: String?
    private(set) var description: String?
    private(set) var primaryActionButtonTitle: String?
    private(set) var primaryAction: (() -> Void)?

    private let placeholderImages = [
        img("icon-session-placeholder-1"),
        img("icon-session-placeholder-2"),
        img("icon-session-placeholder-3"),
        img("icon-session-placeholder-4")
    ]

    init(
        from session: WCSessionDraft,
        option: WCTransactionOption?,
        transaction: WCTransaction?,
        primaryAction: (() -> Void)? = nil
    ) {
        if let wcV1Session = session.wcV1Session {
            setup(from: wcV1Session)
        }

        if let wcV2Session = session.wcV2Session {
            setup(from: wcV2Session)
        }

        if let option = option {
            setup(from: option)
        }

        if let transaction = transaction {
            setup(from: transaction)
        }

        self.primaryActionButtonTitle = "title-close".localized
        self.primaryAction = primaryAction
    }
}

extension WCTransactionFullDappDetailConfigurator {
    private func setup(from session: WCSession) {
        title = session.peerMeta.name

        setupImage(from: session)
    }

    private func setupImage(from session: WCSession) {
        let randomIndex = Int.random(in: 0..<placeholderImages.count)
        let placeholderImage = placeholderImages[randomIndex]
        image = DefaultURLImageSource(
            url: session.peerMeta.icons.first,
            color: nil,
            size: .resize(CGSize(width: 48.0, height: 48.0), .aspectFit),
            shape: .circle,
            placeholder: ImagePlaceholder(image: AssetImageSource(asset: placeholderImage), text: nil),
            forceRefresh: false
        )
    }
}

extension WCTransactionFullDappDetailConfigurator {
    private func setup(from session: WalletConnectV2Session) {
        title = session.peer.name

        setupImage(from: session)
    }

    private func setupImage(from session: WalletConnectV2Session) {
        let randomIndex = Int.random(in: 0..<placeholderImages.count)
        let placeholderImage = placeholderImages[randomIndex]
        image = DefaultURLImageSource(
            url: session.peer.icons.first.toURL(),
            color: nil,
            size: .resize(CGSize(width: 48.0, height: 48.0), .aspectFit),
            shape: .circle,
            placeholder: ImagePlaceholder(image: AssetImageSource(asset: placeholderImage), text: nil),
            forceRefresh: false
        )
    }
}

extension WCTransactionFullDappDetailConfigurator {
    private func setup(from option: WCTransactionOption) {
        if let message = option.message {
            description = message
        }
    }

    private func setup(from transaction: WCTransaction) {
        if let message = transaction.message {
            description = message
        }
    }
}
