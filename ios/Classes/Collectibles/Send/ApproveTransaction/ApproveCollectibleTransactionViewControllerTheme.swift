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

//   ApproveCollectibleTransactionViewControllerTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ApproveCollectibleTransactionViewControllerTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let separator: Separator
    let contentEdgeInsets: LayoutPaddings
    let title: TextStyle
    let description: TextStyle
    let descriptionTopMargin: LayoutMetric
    let spacingBetweenDescriptionAndSeparator: LayoutMetric
    let spacingBetweenInfoAndSeparator: LayoutMetric
    let actionContentEdgeInsets: LayoutPaddings
    let actionCorner: Corner
    let confirmActionIndicator: ImageStyle
    let confirmActionViewTopPadding: LayoutMetric
    let confirmAction: ButtonStyle
    let confirmActionHeight: LayoutMetric
    let cancelAction: ButtonStyle
    let spacingBetweenActions: LayoutMetric
    let info: CollectibleTransactionInfoViewTheme

    init(
        _ family: LayoutFamily
    ) {
        background = [
            .backgroundColor(AppColors.Shared.System.background)
        ]
        separator = Separator(color: AppColors.Shared.Layer.grayLighter, size: 1)
        contentEdgeInsets = (24, 24, 16, 24)
        title = [
            .text(Self.getTitle()),
            .textColor(AppColors.Components.Text.main),
            .textOverflow(FittingText())
        ]
        description = [
            .text(Self.getDescription()),
            .textColor(AppColors.Components.Text.main),
            .textOverflow(FittingText())
        ]
        descriptionTopMargin = 16
        spacingBetweenDescriptionAndSeparator = 32
        spacingBetweenInfoAndSeparator = 20
        actionContentEdgeInsets = (14, 0, 14, 0)
        actionCorner = Corner(radius: 4)
        confirmActionIndicator = [
            .image("button-loading-indicator"),
            .contentMode(.scaleAspectFit)
        ]
        confirmActionViewTopPadding = 44
        confirmAction = [
            .title(Self.getActionTitle("collectible-approve-transaction-action-title")),
            .titleColor([
                .normal(AppColors.Components.Button.Primary.text),
            ]),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(AppColors.Components.Button.Primary.background)
        ]
        cancelAction = [
            .title(Self.getActionTitle("title-cancel")),
            .titleColor([
                .normal(AppColors.Components.Button.Secondary.text),
            ]),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(AppColors.Components.Button.Secondary.background)
        ]
        confirmActionHeight = 52
        spacingBetweenActions = 12
        info = CollectibleTransactionInfoViewTheme()
    }
}

extension ApproveCollectibleTransactionViewControllerTheme {
    private static func getTitle() -> EditText {
        let font = Fonts.DMSans.medium.make(28)
        let lineHeightMultiplier = 0.99

        return .attributedString(
            "collectible-approve-transaction-title"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }

    private static func getDescription() -> EditText {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        return .attributedString(
            "collectible-approve-transaction-description"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }

    private static func getActionTitle(
        _ aTitle: String
    ) -> EditText {
        let font = Fonts.DMSans.medium.make(15)
        let lineHeightMultiplier = 1.23

        return .attributedString(
            aTitle
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }
}
