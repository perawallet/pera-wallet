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
//  InstructionItemView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class InstructionItemView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performHyperlinkAction: UIBlockInteraction()
    ]

    private lazy var orderBackgroundView = TripleShadowView()
    private lazy var orderView = UILabel()
    private lazy var contentView = UIView()
    private lazy var titleView = UILabel()
    private lazy var subtitleView = ALGActiveLabel()

    private var theme: InstructionItemViewTheme?

    func customize(_ theme: InstructionItemViewTheme) {
        self.theme = theme

        addOrder(theme)
        addContent(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: InstructionItemViewModel?) {
        if let order = viewModel?.order {
            order.load(in: orderView)
        } else {
            orderView.text = nil
            orderView.attributedText = nil
        }

        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        if let subtitle = viewModel?.subtitle {
            subtitleView.snp.updateConstraints {
                let inset = theme?.spacingBetweenTitleAndSubtitle ?? .zero
                $0.top == titleView.snp.bottom + inset
            }

            if let highlightedText = subtitle.highlightedText {
                let hyperlink: ALGActiveType = .word(highlightedText.text)
                subtitleView.attachHyperlink(
                    hyperlink,
                    to: subtitle.text,
                    attributes: highlightedText.attributes
                ) {
                    [unowned self] in
                    let interaction = self.uiInteractions[.performHyperlinkAction]
                    interaction?.publish()
                }
                return
            }

            subtitle.text.load(in: subtitleView)
        } else {
            subtitleView.text = nil
            subtitleView.attributedText = nil
        }
    }
}

extension InstructionItemView {
    private func addOrder(_ theme: InstructionItemViewTheme) {
        orderBackgroundView.drawAppearance(shadow: theme.orderFirstShadow)
        orderBackgroundView.drawAppearance(secondShadow: theme.orderSecondShadow)
        orderBackgroundView.drawAppearance(thirdShadow: theme.orderThirdShadow)

        addSubview(orderBackgroundView)
        orderBackgroundView.snp.makeConstraints {
            $0.leading == 0
            $0.fitToSize(theme.orderSize)
        }

        alignOrder(orderBackgroundView, with: theme)

        orderBackgroundView.addSubview(orderView)
        orderView.customizeAppearance(theme.order)
        orderView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func alignOrder(_ view: UIView, with theme: InstructionItemViewTheme) {
        switch theme.orderAlignment {
        case .top:
            view.snp.makeConstraints {
                $0.top == 0
            }
        case .center:
            view.snp.makeConstraints {
                $0.centerY == 0
            }
        }
    }

    private func addContent(_ theme: InstructionItemViewTheme) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.height >= orderBackgroundView
            $0.top == 0
            $0.leading == orderBackgroundView.snp.trailing + theme.spacingBetweenOrderAndContent
            $0.bottom == 0
            $0.trailing == 0
        }

        addTitle(theme)
        addSubtitle(theme)
    }

    private func addTitle(_ theme: InstructionItemViewTheme) {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addSubtitle(_ theme: InstructionItemViewTheme) {
        subtitleView.customizeAppearance(theme.subtitle)

        contentView.addSubview(subtitleView)
        subtitleView.fitToVerticalIntrinsicSize()
        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}

extension InstructionItemView {
    enum Event {
        case performHyperlinkAction
    }
}
