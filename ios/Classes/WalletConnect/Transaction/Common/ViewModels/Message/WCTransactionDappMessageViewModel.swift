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
//   WCTransactionDappMessageViewModel.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class WCTransactionDappMessageViewModel {
    private(set) var image: ImageSource?
    private(set) var name: String?
    private(set) var message: String?
    private(set) var isReadMoreHidden = true

    init(
        session: WCSessionDraft,
        imageSize: CGSize,
        transactionOption: WCTransactionOption?,
        transaction: WCTransaction?
    ) {
        if let wcV1Session = session.wcV1Session {
            setImage(
                from: wcV1Session,
                and: imageSize
            )
            setName(from: wcV1Session)
            setMessage(
                option: transactionOption,
                transaction: transaction
            )
            setIsReadMoreHidden()
            return
        }

        if let wcV2Session = session.wcV2Session {
            setImage(
                from: wcV2Session,
                and: imageSize
            )
            setName(from: wcV2Session)
            setMessage(
                option: transactionOption,
                transaction: transaction
            )
            setIsReadMoreHidden()
            return
        }
    }

    init(
        session: WCSessionDraft,
        imageSize: CGSize
    ) {
        if let wcV1Session = session.wcV1Session {
            setImage(
                from: wcV1Session,
                and: imageSize
            )
            setName(from: wcV1Session)
            return
        }

        if let wcV2Session = session.wcV2Session {
            setImage(
                from: wcV2Session,
                and: imageSize
            )
            setName(from: wcV2Session)
            return
        }
    }
}

extension WCTransactionDappMessageViewModel {
    private func setImage(
        from session: WCSession,
        and imageSize: CGSize
    ) {
        let placeholderImages: [Image] = [
            "icon-session-placeholder-1",
            "icon-session-placeholder-2",
            "icon-session-placeholder-3",
            "icon-session-placeholder-4"
        ]
        let placeholderImage = placeholderImages.randomElement()!
        let placeholderAsset = AssetImageSource(asset: placeholderImage.uiImage)
        let placeholder = ImagePlaceholder(image: placeholderAsset, text: nil)

        image = DefaultURLImageSource(
            url: session.peerMeta.icons.first,
            size: .resize(imageSize, .aspectFit),
            shape: .circle,
            placeholder: placeholder
        )
    }

    private func setName(from session: WCSession) {
        name = session.peerMeta.name
    }
}

extension WCTransactionDappMessageViewModel {
    private func setImage(
        from session: WalletConnectV2Session,
        and imageSize: CGSize
    ) {
        let placeholderImages: [Image] = [
            "icon-session-placeholder-1",
            "icon-session-placeholder-2",
            "icon-session-placeholder-3",
            "icon-session-placeholder-4"
        ]
        let placeholderImage = placeholderImages.randomElement()!
        let placeholderAsset = AssetImageSource(asset: placeholderImage.uiImage)
        let placeholder = ImagePlaceholder(image: placeholderAsset, text: nil)

        image = DefaultURLImageSource(
            url: session.peer.icons.first.toURL(),
            size: .resize(imageSize, .aspectFit),
            shape: .circle,
            placeholder: placeholder
        )
    }

    private func setName(from session: WalletConnectV2Session) {
        name = session.peer.name
    }
}

extension WCTransactionDappMessageViewModel {
    private func setMessage(
        option: WCTransactionOption?,
        transaction: WCTransaction?
    ) {
        if let optionMessage = option?.message {
            message = optionMessage
        }

        if let transactionMessage = transaction?.message {
            message = transactionMessage
        }
    }

    private func setIsReadMoreHidden() {
        isReadMoreHidden = message.isNilOrEmpty
    }
}
