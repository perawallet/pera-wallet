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

//   ASADetailQuickActionsMenuView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ASADetailQuickActionsView:
    UIView,
    ViewModelBindable,
    UIInteractable {
    var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .layoutChanged: UIBlockInteraction(),
        .buy: TargetActionInteraction(),
        .swap: TargetActionInteraction(),
        .send: TargetActionInteraction(),
        .receive: TargetActionInteraction()
    ]

    private(set) var isLayoutLoaded = false

    private lazy var contentView = HStackView()
    private lazy var buyActionView = makeActionView()
    private lazy var swapActionView = makeBadgeActionView()
    private lazy var sendActionView =  makeActionView()
    private lazy var receiveActionView = makeActionView()

    private var lastContentSize: CGSize = .zero
    private var theme = ASADetailQuickActionsViewTheme()

    func customize(_ theme: ASADetailQuickActionsViewTheme) {
        self.theme = theme

        addContent(theme)
    }

    func bindData(_ viewModel: ASADetailQuickActionsViewModel?) {
        let isBuyActionAvailable = viewModel?.isBuyActionAvailable ?? true
        buyActionView.isHidden = !isBuyActionAvailable

        let isSwapBadgeVisible = viewModel?.isSwapBadgeVisible ?? false
        swapActionView.isBadgeVisible = isSwapBadgeVisible
    }

    static func calculatePreferredSize(
        _ viewModel: ASADetailQuickActionsViewModel?,
        for layoutSheet: ASADetailQuickActionsViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        return .zero
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.isEmpty { return }

        isLayoutLoaded = true

        let isSaved = saveContentSizeIfNeeded()
        if isSaved {
            uiInteractions[.layoutChanged]?.publish()
        }
    }
}

extension ASADetailQuickActionsView {
    private func makeActionView() -> MacaroonUIKit.Button {
        let titleAdjustmentY = theme.actionSpacingBetweenIconAndTitle
        return MacaroonUIKit.Button(.imageAtTopmost(padding: 0, titleAdjustmentY: titleAdjustmentY))
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

extension ASADetailQuickActionsView {
    private func addContent(_ theme: ASADetailQuickActionsViewTheme) {
        addSubview(contentView)
        contentView.distribution = .fillEqually
        contentView.alignment = .top
        contentView.spacing = theme.spacingBetweenActions
        contentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        addSwapAction(theme)
        addBuyAction(theme)
        addSendAction(theme)
        addReceiveAction(theme)
    }

    private func addBuyAction(_ theme: ASADetailQuickActionsViewTheme) {
        buyActionView.customizeAppearance(theme.buyAction)
        customizeAction(
            buyActionView,
            theme
        )

        contentView.addArrangedSubview(buyActionView)

        startPublishing(
            event: .buy,
            for: buyActionView
        )
    }

    private func addSwapAction(_ theme: ASADetailQuickActionsViewTheme) {
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

    private func addSendAction(_ theme: ASADetailQuickActionsViewTheme) {
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

    private func addReceiveAction(_ theme: ASADetailQuickActionsViewTheme) {
        receiveActionView.customizeAppearance(theme.receiveAction)
        customizeAction(
            receiveActionView,
            theme
        )

        contentView.addArrangedSubview(receiveActionView)

        startPublishing(
            event: .receive,
            for: receiveActionView
        )
    }

    private func customizeAction(
        _ actionView: MacaroonUIKit.Button,
        _ theme: ASADetailQuickActionsViewTheme
    ) {
        actionView.snp.makeConstraints {
            $0.fitToWidth(theme.actionWidth)
        }
    }
}

extension ASADetailQuickActionsView {
    private func saveContentSizeIfNeeded() -> Bool {
        var isSaved = false

        let newContentSize = bounds.size
        if lastContentSize != newContentSize {
            lastContentSize = newContentSize
            isSaved = true
        }

        return isSaved
    }
}

extension ASADetailQuickActionsView {
    enum Event {
        case layoutChanged
        case buy
        case swap
        case send
        case receive
    }
}
