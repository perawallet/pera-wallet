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

//   ASADetailMarketView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ASADetailMarketView:
    UIView,
    CornerDrawable,
    ViewModelBindable,
    UIInteractable {
    var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .market: GestureInteraction()
    ]

    private lazy var contentView = HStackView()
    private lazy var titleView = Label()
    private lazy var accessoryIcon = ImageView()
    private lazy var priceView = Label()
    private lazy var priceChangeImageView = ImageView()
    private lazy var priceChangeView = Label()

    private var lastContentSize: CGSize = .zero
    private var theme = ASADetailMarketViewTheme()

    override var intrinsicContentSize: CGSize {
        CGSize((UIView.noIntrinsicMetric, theme.height))
    }

    func customize(_ theme: ASADetailMarketViewTheme) {
        self.theme = theme

        customizeAppearance(theme.background)
        draw(corner: theme.backgroundCorner)
        addTitleView(theme)
        addAccessoryIcon(theme)
        addContent(theme)

        startPublishing(event: .market, for: self)
    }

    func bindData(_ viewModel: ASADetailMarketViewModel?) {
        viewModel?.title?.load(in: titleView)

        if let price = viewModel?.price {
            priceView.isHidden = false
            price.load(in: priceView)
        } else {
            priceView.isHidden = true
        }
        if let priceChangeIcon = viewModel?.priceChangeIcon {
            priceChangeImageView.isHidden = false
            priceChangeIcon.load(in: priceChangeImageView, onCompleted: nil)
        } else {
            priceChangeImageView.isHidden = true
        }
        if let priceChange = viewModel?.priceChange {
            priceChangeView.isHidden = false
            priceChange.load(in: priceChangeView)
        } else {
            priceChangeView.isHidden = true
        }
    }

    static func calculatePreferredSize(
        _ viewModel: ASADetailMarketViewModel?,
        for layoutSheet: ASADetailMarketViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        return .zero
    }
}

extension ASADetailMarketView {
    private func addTitleView(_ theme: ASADetailMarketViewTheme) {
        titleView.customizeAppearance(theme.titleStyle)
        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == theme.titleLeading
        }
    }
    private func addAccessoryIcon(_ theme: ASADetailMarketViewTheme) {
        accessoryIcon.customizeAppearance(theme.detailImage)
        addSubview(accessoryIcon)
        accessoryIcon.snp.makeConstraints {
            $0.trailing == theme.accessoryIconTrailing
            $0.centerY == 0
            $0.width.equalTo(theme.accessoryIconSize.w)
            $0.height.equalTo(theme.accessoryIconSize.h)
        }
    }
    private func addContent(_ theme: ASADetailMarketViewTheme) {
        addSubview(contentView)
        contentView.alignment = .center
        contentView.spacing = theme.spacingBetweenItemsInStack
        contentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == titleView.snp.trailing + theme.contentLeading
            $0.trailing == accessoryIcon.snp.leading - theme.contentTrailing
            $0.bottom == 0
        }

        priceView.customizeAppearance(theme.priceStyle)
        contentView.addArrangedSubview(priceView)
        contentView.addArrangedSubview(priceChangeImageView)
        contentView.addArrangedSubview(priceChangeView)
    }
}

extension ASADetailMarketView {
    enum Event {
        case market
    }
}
