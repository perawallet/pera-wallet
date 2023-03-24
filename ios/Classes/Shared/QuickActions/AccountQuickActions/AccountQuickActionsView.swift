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

//   AccountQuickActionsView.swift

import Foundation
import MacaroonUIKit
import SnapKit
import UIKit

final class AccountQuickActionsView:
    View,
    ListReusable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .buySell: TargetActionInteraction(),
        .swap: TargetActionInteraction(),
        .send: TargetActionInteraction(),
        .more: TargetActionInteraction()
    ]

    private lazy var contentView = HStackView()
    private lazy var buySellActionView = makeActionView()
    private lazy var swapActionView = makeBadgeActionView()
    private lazy var sendActionView =  makeActionView()
    private lazy var moreActionView = makeActionView()

    private var theme: AccountQuickActionsViewTheme!

    var isSwapBadgeVisible: Bool = false {
        didSet {
            swapActionView.isBadgeVisible = isSwapBadgeVisible
        }
    }

    func customize(_ theme: AccountQuickActionsViewTheme) {
        self.theme = theme

        addActions(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    class func calculatePreferredSize(
        for theme: AccountQuickActionsViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let maxActionSize = CGSize((size.width, .greatestFiniteMagnitude))
        let buySellActionSize = calculateActionPreferredSize(
            theme,
            for: theme.buySellAction,
            fittingIn: maxActionSize
        )
        let sendActionSize = calculateActionPreferredSize(
            theme,
            for: theme.sendAction,
            fittingIn: maxActionSize
        )
        let swapActionSize = calculateActionPreferredSize(
            theme,
            for: theme.swapAction,
            fittingIn: maxActionSize
        )
        let moreActionSize = calculateActionPreferredSize(
            theme,
            for: theme.moreAction,
            fittingIn: maxActionSize
        )
        let preferredHeight = [
            buySellActionSize.height,
            swapActionSize.height,
            sendActionSize.height,
            moreActionSize.height
        ].max()!
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }

    class func calculateActionPreferredSize(
        _ theme: AccountQuickActionsViewTheme,
        for actionStyle: ButtonStyle,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = theme.actionWidth
        let iconSize = actionStyle.icon?.first?.uiImage.size ?? .zero
        let titleSize = actionStyle.title?.text.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let preferredHeight =
            iconSize.height +
            theme.actionSpacingBetweenIconAndTitle +
            titleSize.height
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AccountQuickActionsView {
    private func addActions(_ theme: AccountQuickActionsViewTheme) {
        addSubview(contentView)
        contentView.distribution = .fillEqually
        contentView.alignment = .top
        contentView.spacing = theme.spacingBetweenActions
        contentView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == 0
            $0.leading >= 0
            $0.bottom == 0
            $0.trailing <= 0
        }

        addBuySellAction(theme)
        addSwapAction(theme)
        addSendAction(theme)
        addMoreAction(theme)
    }

    private func addBuySellAction(_ theme: AccountQuickActionsViewTheme) {
        buySellActionView.customizeAppearance(theme.buySellAction)
        customizeAction(
            buySellActionView,
            theme
        )

        contentView.addArrangedSubview(buySellActionView)

        startPublishing(
            event: .buySell,
            for: buySellActionView
        )
    }

    private func addSwapAction(_ theme: AccountQuickActionsViewTheme) {
        swapActionView.customize(theme: theme.swapBadge)
        swapActionView.customizeAppearance(theme.swapAction)
        customizeAction(
            swapActionView,
            theme
        )

        contentView.addArrangedSubview(swapActionView)

        startPublishing(
            event: .swap,
            for: swapActionView
        )
    }

    private func addSendAction(_ theme: AccountQuickActionsViewTheme) {
        sendActionView.customizeAppearance(theme.sendAction)
        customizeAction(
            sendActionView,
            theme
        )

        contentView.addArrangedSubview(sendActionView)

        startPublishing(
            event: .send,
            for: sendActionView
        )
    }

    private func addMoreAction(_ theme: AccountQuickActionsViewTheme) {
        moreActionView.customizeAppearance(theme.moreAction)
        customizeAction(
            moreActionView,
            theme
        )

        contentView.addArrangedSubview(moreActionView)

        startPublishing(
            event: .more,
            for: moreActionView
        )
    }

    private func customizeAction(
        _ actionView: MacaroonUIKit.Button,
        _ theme: AccountQuickActionsViewTheme
    ) {
        actionView.snp.makeConstraints {
            $0.fitToWidth(theme.actionWidth)
        }
    }
}

extension AccountQuickActionsView {
    private func makeActionView() -> MacaroonUIKit.Button {
        let titleAdjustmentY = theme.actionSpacingBetweenIconAndTitle
        return MacaroonUIKit.Button(.imageAtTopmost(
            padding: 0,
            titleAdjustmentY: titleAdjustmentY)
        )
    }

    private func makeBadgeActionView() -> BadgeButton {
        let titleAdjustmentY = theme.actionSpacingBetweenIconAndTitle
        let swapBadgeEdgeInsets = theme.swapBadgeEdgeInsets
        return BadgeButton(
            badgePosition: .topTrailing(swapBadgeEdgeInsets),
            .imageAtTopmost(
                padding: 0,
                titleAdjustmentY: titleAdjustmentY
            )
        )
    }
}

extension AccountQuickActionsView {
    enum Event {
        case buySell
        case swap
        case send
        case more
    }
}
