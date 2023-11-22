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

//   HomeQuickActionsView.swift

import Foundation
import MacaroonUIKit
import SnapKit
import UIKit

final class HomeQuickActionsView:
    View,
    ListReusable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .buySell: TargetActionInteraction(),
        .swap: TargetActionInteraction(),
        .send: TargetActionInteraction(),
        .scanQR: TargetActionInteraction()
    ]

    private lazy var contentView = HStackView()
    private lazy var buySellActionView = makeActionView()
    private lazy var swapActionView = makeBadgeActionView()
    private lazy var sendActionView =  makeActionView()
    private lazy var scanActionView = makeActionView()

    private var theme: HomeQuickActionsViewTheme!

    var isSwapBadgeVisible: Bool = false {
        didSet {
            swapActionView.isBadgeVisible = isSwapBadgeVisible
        }
    }

    func customize(_ theme: HomeQuickActionsViewTheme) {
        self.theme = theme

        addActions(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    class func calculatePreferredSize(
        for theme: HomeQuickActionsViewTheme,
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
        let scanActionSize = calculateActionPreferredSize(
            theme,
            for: theme.scanAction,
            fittingIn: maxActionSize
        )
        let preferredHeight = [
            buySellActionSize.height,
            swapActionSize.height,
            sendActionSize.height,
            scanActionSize.height
        ].max()!
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }

    class func calculateActionPreferredSize(
        _ theme: HomeQuickActionsViewTheme,
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

extension HomeQuickActionsView {
    private func addActions(_ theme: HomeQuickActionsViewTheme) {
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

        addSwapAction(theme)
        addBuySellAction(theme)
        addSendAction(theme)
        addScanAction(theme)
    }

    private func addBuySellAction(_ theme: HomeQuickActionsViewTheme) {
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

    private func addSwapAction(_ theme: HomeQuickActionsViewTheme) {
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

    private func addSendAction(_ theme: HomeQuickActionsViewTheme) {
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

    private func addScanAction(_ theme: HomeQuickActionsViewTheme) {
        scanActionView.customizeAppearance(theme.scanAction)
        customizeAction(
            scanActionView,
            theme
        )

        contentView.addArrangedSubview(scanActionView)

        startPublishing(
            event: .scanQR,
            for: scanActionView
        )
    }

    private func customizeAction(
        _ actionView: MacaroonUIKit.Button,
        _ theme: HomeQuickActionsViewTheme
    ) {
        actionView.snp.makeConstraints {
            $0.fitToWidth(theme.actionWidth)
        }
    }
}

extension HomeQuickActionsView {
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

extension HomeQuickActionsView {
    enum Event {
        case buySell
        case swap
        case send
        case scanQR
    }
}
