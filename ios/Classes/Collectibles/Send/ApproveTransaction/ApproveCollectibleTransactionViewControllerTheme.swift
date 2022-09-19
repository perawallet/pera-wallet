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
    let minimumHorizontalSpacing: LayoutMetric
    let background: ViewStyle
    let separator: Separator
    let contentEdgeInsets: LayoutPaddings

    let title: TextStyle
    let description: TextStyle
    let descriptionTopMargin: LayoutMetric
    let spacingBetweenDescriptionAndSeparator: LayoutMetric
    let spacingBetweenInfoAndSeparator: LayoutMetric

    let info: CollectibleTransactionInfoViewTheme

    let optOutCheckbox: ButtonStyle
    let optOutTitle: TextStyle
    let optOutInfo: ButtonStyle
    let optOutTitleLeadingMargin: LayoutMetric

    let actionContentEdgeInsets: LayoutPaddings
    let actionCorner: Corner
    let confirmActionIndicator: ImageStyle
    let confirmActionViewTopPadding: LayoutMetric
    let confirmAction: ButtonStyle
    let confirmActionHeight: LayoutMetric
    let cancelAction: ButtonStyle
    let spacingBetweenActions: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        minimumHorizontalSpacing = 8
        background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        separator = Separator(color: Colors.Layer.grayLighter, size: 1)
        contentEdgeInsets = (24, 24, 16, 24)

        title = [
            .text(Self.getTitle()),
            .textColor(Colors.Text.main),
            .textOverflow(FittingText())
        ]
        description = [
            .text(Self.getDescription()),
            .textColor(Colors.Text.main),
            .textOverflow(FittingText())

        ]
        descriptionTopMargin = 16
        spacingBetweenDescriptionAndSeparator = 32
        spacingBetweenInfoAndSeparator = 20

        info = CollectibleTransactionInfoViewTheme()

        optOutCheckbox = [
            .icon(
                [
                    .normal("icon-border-checkbox-unselected"),
                    .selected("icon-border-checkbox-selected")
                ]
            ),
            .tintColor(Colors.Helpers.success)
        ]
        optOutTitle = [
            .text(Self.getOptOutTitle()),
            .textColor(Colors.Text.main),
            .textOverflow(FittingText())
        ]
        optOutInfo = [
            .icon([.normal("icon-info-24".templateImage)]),
            .tintColor(Colors.Text.grayLighter)
        ]
        optOutTitleLeadingMargin = 12

        actionContentEdgeInsets = (14, 0, 14, 0)
        actionCorner = Corner(radius: 4)
        confirmActionIndicator = [
            .image("button-loading-indicator"),
            .contentMode(.scaleAspectFit)
        ]
        confirmActionViewTopPadding = 40
        confirmAction = [
            .title(Self.getActionTitle("collectible-approve-transaction-action-title")),
            .titleColor([
                .normal(Colors.Button.Primary.text),
            ]),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(Colors.Button.Primary.background)
        ]
        cancelAction = [
            .title(Self.getActionTitle("title-cancel")),
            .titleColor([
                .normal(Colors.Button.Secondary.text),
            ]),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(Colors.Button.Secondary.background)
        ]
        confirmActionHeight = 52
        spacingBetweenActions = 12
    }
}

extension ApproveCollectibleTransactionViewControllerTheme {
    private static func getTitle() -> EditText {
        return .attributedString(
            "collectible-approve-transaction-title"
                .localized
                .titleSmallMedium()
        )
    }

    private static func getDescription() -> EditText {
        return .attributedString(
            "collectible-approve-transaction-description"
                .localized
                .bodyRegular()
        )
    }

    private static func getOptOutTitle() -> EditText {
        return .attributedString(
            "collectible-approve-transaction-opt-out"
                .localized
                .bodyRegular()
        )
    }

    private static func getActionTitle(
        _ aTitle: String
    ) -> EditText {
        return .attributedString(
            aTitle
                .localized
                .bodyMedium()
        )
    }
}
