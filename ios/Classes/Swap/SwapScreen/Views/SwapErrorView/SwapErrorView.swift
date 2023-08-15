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

//   SwapErrorView.swift

import Foundation
import MacaroonUIKit
import UIKit

/// <todo>
/// Update this component with  `ErrorView` by removing the separator and refactoring other used screens..
final class SwapErrorView:
    View,
    ViewModelBindable {
    var eventHandlers = EventHandlers()

    private lazy var iconView = ImageView()
    private lazy var messageView = ALGActiveLabel()

    func customize(
        _ theme: SwapErrorViewTheme
    ) {
        addIcon(theme)
        addMessage(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: ErrorViewModel?
    ) {
        iconView.image = viewModel?.icon?.uiImage

        if let message = viewModel?.message {
            if let highlightedText = message.highlightedText {
                let hyperlink: ALGActiveType = .word(highlightedText.text)
                messageView.attachHyperlink(
                    hyperlink,
                    to: message.text,
                    attributes: highlightedText.attributes
                ) {
                    [unowned self] in
                    self.eventHandlers.messageHyperlinkHandler?(highlightedText.url)
                }
                return
            }

            message.text.load(in: messageView)
        } else {
            messageView.text = nil
            messageView.attributedText = nil
        }
    }
}

extension SwapErrorView {
    private func addIcon(
        _ theme: SwapErrorViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.contentEdgeInsets = theme.iconContentEdgeInsets
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addMessage(
        _ theme: SwapErrorViewTheme
    ) {
        messageView.customizeAppearance(theme.message)

        addSubview(messageView)
        messageView.fitToVerticalIntrinsicSize()
        messageView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}

extension SwapErrorView {
    struct EventHandlers {
        var messageHyperlinkHandler: ((URL?) -> Void)?
    }
}
