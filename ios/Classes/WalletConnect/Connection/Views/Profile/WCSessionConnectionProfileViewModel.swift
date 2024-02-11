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

//   WCSessionConnectionProfileViewModel.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage

struct WCSessionConnectionProfileViewModel: ViewModel {
    private(set) var icon: ImageSource?
    private(set) var title: TextProvider?
    private(set) var link: ButtonStyle?

    init(_ draft: WCSessionConnectionDraft) {
        bindIcon(draft)
        bindTitle(draft)
        bindLink(draft)
    }
}

extension WCSessionConnectionProfileViewModel {
    private mutating func bindIcon(_ draft: WCSessionConnectionDraft) {
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
            url: draft.image,
            size: .resize(imageSize, .aspectFit),
            shape: .circle,
            placeholder: placeholder
        )
    }

    private mutating func bindTitle(_ draft: WCSessionConnectionDraft) {
        let dAppName = draft.dappName
        let dAppNameAttributes = Typography.bodyLargeMediumAttributes(alignment: .center)

        let aTitle =
        "wallet-connect-session-connection-description"
            .localized(params: dAppName)
            .bodyLargeRegular(alignment: .center)
            .addAttributes(
                to: dAppName,
                newAttributes: dAppNameAttributes
            )
        title = aTitle
    }

    private mutating func bindLink(_ draft: WCSessionConnectionDraft) {
        guard let link = draft.dappURL?.presentationString else {
            self.link = nil
            return
        }

        var attributes: [ButtonStyle.Attribute] = [
            .title(link),
            .font(Typography.bodyMedium()),
            .titleColor([ .normal(Colors.Helpers.positive)])
        ]
        let isApproved = draft.isApproved
        if isApproved {
            let icon = "icon-trusted"
            attributes.append(.icon([ .normal(icon), .highlighted(icon) ]))
        }

        self.link = .init(attributes: attributes)
    }
}
