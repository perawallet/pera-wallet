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
//   WCSessionShortListItemViewModel.swift

import UIKit
import MacaroonUIKit
import SwiftDate
import MacaroonURLImage

final class WCSessionShortListItemViewModel: PairedViewModel {
    private(set) var image: ImageSource?
    private(set) var name: String?
    private(set) var description: String?

    init(_ draft: WCSessionDraft) {
        if let wcV1Session = draft.wcV1Session {
            bindImage(wcV1Session)
            bindName(wcV1Session)
            bindDescription(wcV1Session)
            return
        }

        if let wcV2Session = draft.wcV2Session {
            bindImage(wcV2Session)
            bindName(wcV2Session)
            bindDescription(wcV2Session)
            return
        }
    }
}

extension WCSessionShortListItemViewModel {
    private func bindImage(_ wcV1Session: WCSession) {
        let placeholderImages: [Image] = [
            "icon-session-placeholder-1",
            "icon-session-placeholder-2",
            "icon-session-placeholder-3",
            "icon-session-placeholder-4"
        ]
        let placeholderImage = placeholderImages.randomElement()!
        let placeholderAsset = AssetImageSource(asset: placeholderImage.uiImage)
        let placeholder = ImagePlaceholder(image: placeholderAsset, text: nil)

        let imageSize = CGSize(width: 40, height: 40)
        image = DefaultURLImageSource(
            url: wcV1Session.peerMeta.icons.first,
            size: .resize(imageSize, .aspectFit),
            shape: .circle,
            placeholder: placeholder
        )
    }

    private func bindName(_ wcV1Session: WCSession) {
        name = wcV1Session.peerMeta.name
    }

    private func bindDescription(_ wcV1Session: WCSession) {
        let dateFormat = "MMM d, yyyy, h:mm a"
        let connectedOnDate = wcV1Session.date.toFormat(dateFormat)
        description =
            "wallet-connect-session-connected-on-date"
                .localized(params: connectedOnDate)
    }
}

extension WCSessionShortListItemViewModel {
    private func bindImage(_ wcV2Session: WalletConnectV2Session) {
        let placeholderImages: [Image] = [
            "icon-session-placeholder-1",
            "icon-session-placeholder-2",
            "icon-session-placeholder-3",
            "icon-session-placeholder-4"
        ]
        let placeholderImage = placeholderImages.randomElement()!
        let placeholderAsset = AssetImageSource(asset: placeholderImage.uiImage)
        let placeholder = ImagePlaceholder(image: placeholderAsset, text: nil)

        let imageSize = CGSize(width: 40, height: 40)
        image = DefaultURLImageSource(
            url: wcV2Session.peer.icons.first.toURL(),
            size: .resize(imageSize, .aspectFit),
            shape: .circle,
            placeholder: placeholder
        )
    }

    private func bindName(_ wcV2Session: WalletConnectV2Session) {
        name = wcV2Session.peer.name
    }

    private func bindDescription(_ wcV2Session: WalletConnectV2Session) {
        let dateFormat = "MMM d, yyyy, h:mm a"
        let validUntilDate = wcV2Session.expiryDate.toFormat(dateFormat)
        description =
            "wallet-connect-v2-session-expires-on-date"
                .localized(params: validUntilDate)
    }
}
