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

//   ConfirmSwapScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ConfirmSwapScreenTheme:
    StyleSheet,
    LayoutSheet {
    var navigationTitle: AccountNameTitleViewTheme
    var background: ViewStyle
    var userAsset: SwapAssetAmountViewTheme
    var assetHorizontalInset: LayoutMetric
    var userAssetTopInset: LayoutMetric
    var minimumUserAssetTopInset: LayoutMetric
    var toSeparator: TitleSeparatorViewTheme
    var toSeparatorTopInset: LayoutMetric
    var poolAsset: SwapAssetAmountViewTheme
    var poolAssetTopInset: LayoutMetric
    var assetSeparator: Separator
    var spacingBetweenToPoolAssetAndInfoSeparator: LayoutMetric
    var infoActionItem: SwapInfoActionItemViewTheme
    var infoItem: SwapInfoItemViewTheme
    var infoSectionPaddings: LayoutPaddings
    var infoSectionItemSpacing: LayoutMetric
    var warningTopInset: LayoutMetric
    var warning: SwapErrorViewTheme
    var viewSummary: ButtonStyle
    var confirmAction: ButtonStyle
    var confirmActionIndicator: ImageStyle
    var confirmActionHeight: LayoutMetric
    var confirmActionContentEdgeInsets: UIEdgeInsets
    var confirmActionEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        self.navigationTitle = AccountNameTitleViewTheme(family)
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]

        self.userAsset = SwapAssetAmountViewTheme(placeholder: "0.00")
        self.userAsset.spacingBetweenLeftTitleAndInputs = 0

        self.assetHorizontalInset = 24
        self.userAssetTopInset = 88
        self.minimumUserAssetTopInset = 28
        self.toSeparator = TitleSeparatorViewTheme()
        self.toSeparatorTopInset = 20

        self.poolAsset = SwapAssetAmountViewTheme(placeholder: "0.00")
        self.poolAsset.spacingBetweenLeftTitleAndInputs = 0

        self.poolAssetTopInset = 20
        self.assetSeparator = Separator(
            color: Colors.Layer.grayLighter,
            size: 1,
            position: .top((0, 0))
        )
        self.spacingBetweenToPoolAssetAndInfoSeparator = 36
        self.infoSectionPaddings = (28, 24, .noMetric, 24)
        self.infoActionItem = SwapInfoActionItemViewTheme()
        self.infoItem = SwapInfoItemViewTheme()
        self.infoSectionItemSpacing = 16
        self.viewSummary = [
            .title("swap-confirm-view-summary-title".localized),
            .titleColor([
                .normal(Colors.Helpers.positive)
            ]),
            .font(Typography.footnoteMedium()),
        ]
        self.warningTopInset = 28
        self.warning = SwapErrorViewTheme()
        self.confirmAction = [
            .title("swap-confirm-title".localized),
            .titleColor(
                [
                    .normal(Colors.Button.Primary.text),
                    .disabled(Colors.Button.Primary.disabledText)
                ]
            ),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .selected("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ])
        ]
        self.confirmActionIndicator = [
            .image("button-loading-indicator"),
            .contentMode(.scaleAspectFit)
        ]
        self.confirmActionHeight = 52
        self.confirmActionContentEdgeInsets = .init(
            (
                top: 16,
                leading: 0,
                bottom: 16,
                trailing: 0
            )
        )
        self.confirmActionEdgeInsets = (28, 24, 16, 24)
    }
}
