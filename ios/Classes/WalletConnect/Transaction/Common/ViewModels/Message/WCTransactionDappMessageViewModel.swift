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

    private let placeholderImages = [
        img("icon-session-placeholder-1"),
        img("icon-session-placeholder-2"),
        img("icon-session-placeholder-3"),
        img("icon-session-placeholder-4")
    ]

    init(session: WCSession, imageSize: CGSize, transactionOption: WCTransactionOption?, transaction: WCTransaction?) {
        setImage(from: session, and: imageSize)
        setName(from: session)
        setMessage(from: session, option: transactionOption, transaction: transaction)
        setIsReadMoreHidden()
    }

    init(
        session: WCSession,
        imageSize: CGSize
    ) {
        setImage(
            from: session,
            and: imageSize
        )
        setName(from: session)
    }

    private func setImage(from session: WCSession, and imageSize: CGSize) {
        let randomIndex = Int.random(in: 0..<placeholderImages.count)
        let placeholderImage = placeholderImages[randomIndex]

        image = DefaultURLImageSource(
            url: session.peerMeta.icons.first,
            color: nil,
            size: .resize(imageSize, .aspectFit),
            shape: .circle,
            placeholder: ImagePlaceholder(image: AssetImageSource(asset: placeholderImage), text: nil),
            forceRefresh: false
        )
    }

    private func setName(from session: WCSession) {
        name = session.peerMeta.name
    }

    private func setMessage(
        from session: WCSession,
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
