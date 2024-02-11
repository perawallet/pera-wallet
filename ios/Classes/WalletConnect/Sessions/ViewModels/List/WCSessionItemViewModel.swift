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
//   WCSessionItemViewModel.swift

import CoreGraphics
import MacaroonUIKit
import SwiftDate
import MacaroonURLImage
import Foundation

struct WCSessionItemViewModel: ViewModel {
    private(set) var image: ImageSource?
    private(set) var name: TextProvider?
    private(set) var wcV1Badge: TextProvider?
    private(set) var description: TextProvider?

    init(_ draft: WCSessionDraft) {
        if let wcV1Session = draft.wcV1Session {
            bindImage(wcV1Session)
            bindName(wcV1Session)
            bindWCv1Badge()
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

extension WCSessionItemViewModel {
    private mutating func bindImage(_ wcV1Session: WCSession) {
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

    private mutating func bindName(_ wcV1Session: WCSession) {
        name = wcV1Session.peerMeta.name.bodyMedium(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindWCv1Badge() {
        wcV1Badge = "WCV1".footnoteMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }

    private mutating func bindDescription(_ wcV1Session: WCSession) {
        let dateFormat = "MMM d, yyyy, h:mm a"
        let connectedOnDate = wcV1Session.date.toFormat(dateFormat)
        description =
            "wallet-connect-session-connected-on-date"
                .localized(params: connectedOnDate)
                .footnoteRegular(lineBreakMode: .byWordWrapping)
    }
}

extension WCSessionItemViewModel {
    private mutating func bindImage(_ wcV2Session: WalletConnectV2Session) {
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

    private mutating func bindName(_ wcV2Session: WalletConnectV2Session) {
        name = wcV2Session.peer.name.bodyMedium(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindDescription(_ wcV2Session: WalletConnectV2Session) {
        let dateFormat = "MMM d, yyyy, h:mm a"
        let validUntilDate = wcV2Session.expiryDate.toFormat(dateFormat)
        description =
            "wallet-connect-v2-session-expires-on-date"
                .localized(validUntilDate)
                .footnoteRegular(lineBreakMode: .byWordWrapping)
    }
}
