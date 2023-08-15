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

//   WatchAccountQuickActionsView.swift

import Foundation
import MacaroonUIKit
import SnapKit
import UIKit

final class WatchAccountQuickActionsView:
    View,
    ListReusable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .copyAddress: TargetActionInteraction(),
        .showAddress: TargetActionInteraction(),
        .more: TargetActionInteraction()
    ]

    private lazy var contentView = HStackView()
    private lazy var copyAddressActionView = makeActionView()
    private lazy var showAddressActionView =  makeActionView()
    private lazy var moreActionView = makeActionView()

    private var theme: WatchAccountQuickActionsViewTheme!

    func customize(_ theme: WatchAccountQuickActionsViewTheme) {
        self.theme = theme

        addActions(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    class func calculatePreferredSize(
        for theme: WatchAccountQuickActionsViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let maxActionSize = CGSize((size.width, .greatestFiniteMagnitude))
        let copyAddressActionSize = calculateActionPreferredSize(
            theme,
            for: theme.copyAddressAction,
            fittingIn: maxActionSize
        )
        let showAddressActionSize = calculateActionPreferredSize(
            theme,
            for: theme.showAddressAction,
            fittingIn: maxActionSize
        )
        let moreActionSize = calculateActionPreferredSize(
            theme,
            for: theme.moreAction,
            fittingIn: maxActionSize
        )
        let preferredHeight = [
            copyAddressActionSize.height,
            showAddressActionSize.height,
            moreActionSize.height
        ].max()!
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }

    class func calculateActionPreferredSize(
        _ theme: WatchAccountQuickActionsViewTheme,
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

extension WatchAccountQuickActionsView {
    private func addActions(_ theme: WatchAccountQuickActionsViewTheme) {
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

        addCopyAddressAction(theme)
        addShowAddressAction(theme)
        addMoreAction(theme)
    }

    private func addCopyAddressAction(_ theme: WatchAccountQuickActionsViewTheme) {
        copyAddressActionView.customizeAppearance(theme.copyAddressAction)
        customizeAction(
            copyAddressActionView,
            theme
        )

        contentView.addArrangedSubview(copyAddressActionView)

        startPublishing(
            event: .copyAddress,
            for: copyAddressActionView
        )
    }

    private func addShowAddressAction(_ theme: WatchAccountQuickActionsViewTheme) {
        showAddressActionView.customizeAppearance(theme.showAddressAction)
        customizeAction(
            showAddressActionView,
            theme
        )

        contentView.addArrangedSubview(showAddressActionView)

        startPublishing(
            event: .showAddress,
            for: showAddressActionView
        )
    }

    private func addMoreAction(_ theme: WatchAccountQuickActionsViewTheme) {
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
        _ theme: WatchAccountQuickActionsViewTheme
    ) {
        actionView.snp.makeConstraints {
            $0.fitToWidth(theme.actionWidth)
        }
    }
}

extension WatchAccountQuickActionsView {
    private func makeActionView() -> MacaroonUIKit.Button {
        let titleAdjustmentY = theme.actionSpacingBetweenIconAndTitle
        return MacaroonUIKit.Button(.imageAtTopmost(
            padding: 0,
            titleAdjustmentY: titleAdjustmentY)
        )
    }
}

extension WatchAccountQuickActionsView {
    enum Event {
        case copyAddress
        case showAddress
        case more
    }
}
