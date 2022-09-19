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

//   AccountStandardAssetPreviewLoadingView.swift

import UIKit
import MacaroonUIKit

final class AccountStandardAssetPreviewLoadingView:
    MacaroonUIKit.View,
    ShimmerAnimationDisplaying {
    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var iconView = ShimmerView()
    private lazy var infoView = ShimmerView()
    private lazy var primaryValueView = ShimmerView()
    private lazy var secondaryValueView = ShimmerView()
    private lazy var actionsView = HStackView()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        linkInteractors()
    }

    func customize(
        _ theme: AccountStandardAssetPreviewLoadingViewTheme
    ) {
        addBackground(theme)
        addContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func linkInteractors() {
        isUserInteractionEnabled = false
    }
}

extension AccountStandardAssetPreviewLoadingView {
    private func addBackground(
        _ theme: AccountStandardAssetPreviewLoadingViewTheme
    ) {
        customizeAppearance(theme.background)
    }

    private func addContent(
        _ theme: AccountStandardAssetPreviewLoadingViewTheme
    ) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == theme.contentEdgeInsets.top
            $0.leading == theme.contentEdgeInsets.leading
            $0.bottom == theme.contentEdgeInsets.bottom
            $0.trailing == theme.contentEdgeInsets.trailing
        }

        addIcon(theme)
        addInfo(theme)
        addPrimaryValue(theme)
        addSecondaryValue(theme)
        addActions(theme)
    }

    private func addIcon(
        _ theme: AccountStandardAssetPreviewLoadingViewTheme
    ) {
        iconView.draw(corner: theme.iconCorner)

        contentView.addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.centerX == 0
            $0.top == 0
        }
    }

    private func addInfo(
        _ theme: AccountStandardAssetPreviewLoadingViewTheme
    ) {
        infoView.draw(corner: theme.corner)

        contentView.addSubview(infoView)
        infoView.snp.makeConstraints {
            $0.fitToSize(theme.infoSize)
            $0.centerX == 0
            $0.top == iconView.snp.bottom + theme.spacingBetweenIconAndInfo
        }
    }

    private func addPrimaryValue(
        _ theme: AccountStandardAssetPreviewLoadingViewTheme
    ) {
        primaryValueView.draw(corner: theme.corner)

        contentView.addSubview(primaryValueView)
        primaryValueView.snp.makeConstraints {
            $0.fitToSize(theme.primaryValueSize)
            $0.centerX == 0
            $0.top == infoView.snp.bottom + theme.spacingBetweeenPrimaryValueAndInfo
        }
    }

    private func addSecondaryValue(
        _ theme: AccountStandardAssetPreviewLoadingViewTheme
    ) {
        secondaryValueView.draw(corner: theme.corner)

        contentView.addSubview(secondaryValueView)
        secondaryValueView.snp.makeConstraints {
            $0.fitToSize(theme.secondaryValueSize)
            $0.centerX == 0
            $0.top == primaryValueView.snp.bottom + theme.spacingBetweeenPrimaryValueAndSecondaryValue
        }
    }

    private func addActions(
        _ theme: AccountStandardAssetPreviewLoadingViewTheme
    ) {
        actionsView.distribution = .equalSpacing
        actionsView.spacing = theme.spacingBetweenActions

        contentView.addSubview(actionsView)
        actionsView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == secondaryValueView.snp.bottom + theme.spacingBetweenActionsAndSecondaryValue
            $0.leading >= 0
            $0.bottom == 0
            $0.trailing <= 0
        }

        addSendAction(theme)
        addReceiveAction(theme)
    }

    private func addSendAction(
        _ theme: AccountStandardAssetPreviewLoadingViewTheme
    ) {
        let action = createAction(theme)
        action.customizeAppearance(theme.sendAction)
        actionsView.addArrangedSubview(action)
    }

    private func addReceiveAction(
        _ theme: AccountStandardAssetPreviewLoadingViewTheme
    ) {
        let action = createAction(theme)
        action.customizeAppearance(theme.receiveAction)
        actionsView.addArrangedSubview(action)
    }

    private func createAction(
        _ theme: AccountStandardAssetPreviewLoadingViewTheme
    ) -> MacaroonUIKit.Button {
        let actionView = MacaroonUIKit.Button(
            .imageAtTopmost(
                padding: 0,
                titleAdjustmentY: theme.spacingBetweenImageAndTitle
            )
        )
        actionView.snp.makeConstraints {
            $0.fitToWidth(theme.actionWidth)
        }
        return actionView
    }
}
