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

//   SwapAssetErrorViewModel.swift

import Foundation
import MacaroonUIKit

struct SwapAssetErrorViewModel: ErrorViewModel {
    private(set) var icon: Image?
    private(set) var message: MessageTextProvider?

    init(
        message: String,
        messageHighlightedText: String? = nil,
        messageHighlightedTextURL: URL? = nil
    ) {
        bindIcon()
        bindMessage(
            text: message,
            highlightedText: messageHighlightedText,
            highlightedTextURL: messageHighlightedTextURL
        )
    }
}

extension SwapAssetErrorViewModel {
    private mutating func bindIcon() {
        self.icon = getIcon()
    }

    private mutating func bindMessage(
        text: String,
        highlightedText: String?,
        highlightedTextURL: URL?
    ) {
        let message: MessageTextProvider

        if let highlightedText {
            var messageHighlightedTextAttributes = Typography.footnoteMediumAttributes(alignment: .center)
            messageHighlightedTextAttributes.insert(.textColor(Colors.Helpers.positive.uiColor))

            let messageHighlightedText = HighlightedText(
                text: highlightedText,
                url: highlightedTextURL,
                attributes: messageHighlightedTextAttributes
            )

            message = MessageTextProvider(
                text: text.footnoteMedium(),
                highlightedText: messageHighlightedText
            )
        } else {
            message = MessageTextProvider(text: text.footnoteMedium())
        }

        self.message = message
    }
}
