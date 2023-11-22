// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCSessionProfileViewModel.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage

struct WCSessionProfileViewModel: ViewModel {
    private(set) var icon: ImageSource?
    private(set) var title: TextProvider?
    private(set) var link: TextProvider?
    private(set) var description: TextProvider?

    init(_ draft: WCSessionDraft) {
        if let wcV1Session = draft.wcV1Session {
            bindIcon(wcV1Session)
            bindTitle(wcV1Session)
            bindLink(wcV1Session)
            bindDescription(wcV1Session)
            return
        }

        if let wcV2Session = draft.wcV2Session {
            bindIcon(wcV2Session)
            bindTitle(wcV2Session)
            bindLink(wcV2Session)
            bindDescription(wcV2Session)
            return
        }
    }
}

extension WCSessionProfileViewModel {
    private mutating func bindIcon(_ wcV1Session: WCSession) {
        let placeholderImages: [Image] = [
            "icon-session-placeholder-1",
            "icon-session-placeholder-2",
            "icon-session-placeholder-3",
            "icon-session-placeholder-4"
        ]
        let placeholderImage = placeholderImages.randomElement()!
        let placeholderAsset = AssetImageSource(asset: placeholderImage.uiImage)
        let placeholder = ImagePlaceholder(image: placeholderAsset, text: nil)

        let imageSize = CGSize(width: 72, height: 72)
        icon = DefaultURLImageSource(
            url: wcV1Session.peerMeta.icons.first,
            size: .resize(imageSize, .aspectFit),
            shape: .circle,
            placeholder: placeholder
        )
    }

    private mutating func bindTitle(_ wcV1Session: WCSession) {
        title = wcV1Session.peerMeta.name.bodyLargeMedium(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindLink(_ wcV1Session: WCSession) {
        self.link = wcV1Session.peerMeta.url.presentationString?.footnoteMedium(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindDescription(_ wcV1Session: WCSession) {
        description = wcV1Session.peerMeta.description?.footnoteRegular()
    }
}


extension WCSessionProfileViewModel {
    private mutating func bindIcon(_ wcV2Session: WalletConnectV2Session) {
        let placeholderImages: [Image] = [
            "icon-session-placeholder-1",
            "icon-session-placeholder-2",
            "icon-session-placeholder-3",
            "icon-session-placeholder-4"
        ]
        let placeholderImage = placeholderImages.randomElement()!
        let placeholderAsset = AssetImageSource(asset: placeholderImage.uiImage)
        let placeholder = ImagePlaceholder(image: placeholderAsset, text: nil)
        let imageSize = CGSize(width: 72, height: 72)
        icon = DefaultURLImageSource(
            url: wcV2Session.peer.icons.first.unwrap(URL.init),
            size: .resize(imageSize, .aspectFit),
            shape: .circle,
            placeholder: placeholder
        )
    }

    private mutating func bindTitle(_ wcV2Session: WalletConnectV2Session) {
        title = wcV2Session.peer.name.bodyLargeMedium(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindLink(_ wcV2Session: WalletConnectV2Session) {
        let url = URL(string: wcV2Session.peer.url)
        guard let link = url?.presentationString else {
            self.link = nil
            return
        }

        self.link = link.footnoteMedium(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindDescription(_ wcV2Session: WalletConnectV2Session) {
        description = wcV2Session.peer.description.footnoteRegular()
    }
}
