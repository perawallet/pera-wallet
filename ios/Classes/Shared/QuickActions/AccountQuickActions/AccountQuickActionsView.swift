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
        .buyAlgo: TargetActionInteraction(),
        .send: TargetActionInteraction(),
        .address: TargetActionInteraction(),
        .more: TargetActionInteraction()
    ]

    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var actionsView = HStackView()

    func customize(
        _ theme: AccountQuickActionsViewTheme
    ) {
        addActions(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    class func calculatePreferredSize(
        for theme: AccountQuickActionsViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let maxActionSize = CGSize(width: size.width, height: .greatestFiniteMagnitude)
        let buyActionSize = calculateActionPreferredSize(
            for: theme.buyAlgoAction,
            fittingIn: maxActionSize
        )
        let sendActionSize = calculateActionPreferredSize(
            for: theme.sendAction,
            fittingIn: maxActionSize
        )
        let addressActionSize = calculateActionPreferredSize(
            for: theme.addressAction,
            fittingIn: maxActionSize
        )
        let moreActionSize = calculateActionPreferredSize(
            for: theme.moreAction,
            fittingIn: maxActionSize
        )
        let preferredHeight = [
            buyActionSize.height,
            sendActionSize.height,
            addressActionSize.height,
            moreActionSize.height
        ].max()!
        return CGSize(width: size.width, height: min(preferredHeight.ceil(), size.height))
    }

    class func calculateActionPreferredSize(
        for theme: AccountQuickActionViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let font = theme.style.font?.uiFont
        let maxWidth = min(theme.width, size.width)
        let iconSize = theme.icon?.uiImage.size
        let titleSize = theme.title?.boundingSize(
            attributes: .font(font),
            multiline: true,
            fittingSize: CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        )
        let preferredHeight =
            (iconSize?.height ?? 48) +
            HomeQuickActionViewTheme.spacingBetweenIconAndTitle +
            (titleSize?.height ?? 20)
        return CGSize(width: maxWidth, height: min(preferredHeight.ceil(), size.height))
    }
}


extension AccountQuickActionsView {
    private func addActions(
        _ theme: AccountQuickActionsViewTheme
    ) {
        addSubview(actionsView)
        actionsView.distribution = .equalSpacing
        actionsView.spacing = theme.spacingBetweenActions
        actionsView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == 0
            $0.leading <= theme.maxContentHorizontalInsets.leading
            $0.bottom == 0
            $0.trailing >= theme.maxContentHorizontalInsets.trailing
        }

        addBuyAction(theme)
        addSendAction(theme)
        addAddressAction(theme)
        addMoreAction(theme)
    }

    private func addBuyAction(
        _ theme: AccountQuickActionsViewTheme
    ) {
        let buyAlgoActionView = createAction(theme.buyAlgoAction)
        actionsView.addArrangedSubview(buyAlgoActionView)

        startPublishing(
            event: .buyAlgo,
            for: buyAlgoActionView
        )
    }

    private func addSendAction(
        _ theme: AccountQuickActionsViewTheme
    ) {
        let sendActionView = createAction(theme.sendAction)
        actionsView.addArrangedSubview(sendActionView)

        startPublishing(
            event: .send,
            for: sendActionView
        )
    }

    private func addAddressAction(
        _ theme: AccountQuickActionsViewTheme
    ) {
        let addressActionView = createAction(theme.addressAction)
        actionsView.addArrangedSubview(addressActionView)

        startPublishing(
            event: .address,
            for: addressActionView
        )
    }

    private func addMoreAction(
        _ theme: AccountQuickActionsViewTheme
    ) {
        let moreActionView = createAction(theme.moreAction)
        actionsView.addArrangedSubview(moreActionView)

        startPublishing(
            event: .more,
            for: moreActionView
        )
    }

    private func createAction(
        _ theme: AccountQuickActionViewTheme
    ) -> UIControl {
        let actionView = MacaroonUIKit.Button(
            .imageAtTopmost(
                padding: 0,
                titleAdjustmentY: AccountQuickActionViewTheme.spacingBetweenIconAndTitle
            )
        )
        actionView.customizeAppearance(theme.style)
        actionView.snp.makeConstraints {
            $0.fitToWidth(theme.width)
        }
        return actionView
    }
}

extension AccountQuickActionsView {
    enum Event {
        case buyAlgo
        case send
        case address
        case more
    }
}
