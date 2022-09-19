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

//   OptOutAssetScreenTheme.swift

import Foundation
import MacaroonUIKit

struct OptOutAssetScreenTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var contentEdgeInsets: LayoutPaddings
    var separator: Separator
    var spacingBetweenSecondaryListItemAndSeparator: LayoutMetric
    var title: PrimaryTitleViewTheme
    var spacingBetweenTitleAndSeparator: LayoutMetric
    var assetIDView: SecondaryListItemViewTheme
    var accountView: SecondaryListItemViewTheme
    var transactionFeeView: SecondaryListItemViewTheme
    var descriptionTopPadding: LayoutMetric
    var description: TextStyle
    var approveActionView: ButtonStyle
    var closeActionView: ButtonStyle
    var spacingBetweenActions: LayoutMetric
    var actionContentEdgeInsets: LayoutPaddings
    var actionsContentEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contentEdgeInsets = (36, 24, 32, 24)
        self.separator = Separator(
            color: Colors.Layer.grayLighter,
            size: 1,
            position: .bottom((contentEdgeInsets.leading, contentEdgeInsets.trailing))
        )
        self.spacingBetweenSecondaryListItemAndSeparator = 10
        self.title = OptOutAssetNameViewTheme()
        self.spacingBetweenTitleAndSeparator = 20
        self.assetIDView = AssetIDSecondaryListItemViewTheme()
        self.accountView = SecondaryListItemCommonViewTheme()
        self.transactionFeeView = TransactionFeeSecondaryListItemViewTheme()
        self.descriptionTopPadding = 22
        self.description = [
            .textOverflow(FittingText())
        ]
        self.approveActionView = [
            .titleColor([ .normal(Colors.Button.Primary.text) ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
            ])
        ]
        self.closeActionView = [
            .titleColor([ .normal(Colors.Button.Secondary.text) ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted"),
            ])
        ]
        self.spacingBetweenActions = 16
        self.actionContentEdgeInsets = (16, 24, 16, 24)
        self.actionsContentEdgeInsets = (16, 24, 16, 24)
    }
}
