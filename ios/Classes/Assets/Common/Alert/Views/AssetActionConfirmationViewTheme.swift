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

//
//   AssetActionConfirmationViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AssetActionConfirmationViewTheme: StyleSheet, LayoutSheet {
    let minimumHorizontalSpacing: LayoutMetric
    let backgroundColor: Color
    let mainButtonTheme: ButtonTheme
    let secondaryButtonTheme: ButtonTheme
    let titleLabel: TextStyle
    let warningIcon: ImageStyle
    let warningIconContentEdgeInsets: LayoutOffset
    let detail: TextStyle
    let assetName: PrimaryTitleViewTheme
    let assetNameSeparator: Separator
    let transactionFeeTitleLabel: TextStyle
    let transactionFeeAmountLabel: TextStyle
    let assetIDLabel: TextStyle
    let copyIDButton: ButtonStyle
    let separator: Separator

    let titleTopPadding: LayoutMetric
    let assetNameTopPadding: LayoutMetric
    let spacingBetweenAssetNameAndSeparator: LayoutMetric
    let assetIDPaddings: LayoutPaddings
    let transactionBottomPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let spacingBetweenButtonAndDetail: LayoutMetric
    var buttonInset: LayoutMetric
    let bottomInset: LayoutMetric
    let descriptionTopInset: LayoutMetric
    let separatorPadding: LayoutMetric
    let copyIDButtonEdgeInsets: LayoutPaddings
    let copyIDButtonHeight: LayoutMetric
    let copyIDButtonCorner: Corner

    init(_ family: LayoutFamily) {
        self.minimumHorizontalSpacing = 8
        self.backgroundColor = Colors.Defaults.background
        self.titleLabel = [
            .textAlignment(.center),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(15))
        ]
        self.warningIcon = [
            .image("icon-red-warning".templateImage),
            .tintColor(Colors.Helpers.negative),
            .contentMode(.left)
        ]
        self.warningIconContentEdgeInsets = (8, 0)
        self.detail = [
            .textColor(Colors.Helpers.negative),
            .font(Fonts.DMSans.medium.make(13)),
            .textAlignment(.left),
            .textOverflow(FittingText())
        ]
        self.assetName = OptInAssetNameViewTheme(family)
        self.assetNameSeparator = Separator(
            color: Colors.Layer.grayLighter,
            size: 1,
            position: .bottom((24, 24))
        )
        self.assetIDLabel = [
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText())
        ]
        self.copyIDButton = [
            .backgroundColor(Colors.Layer.grayLighter),
            .title("asset-copy-id".localized),
            .font(Fonts.DMSans.medium.make(13)),
            .titleColor([.normal(Colors.Text.main)])
        ]
        self.transactionFeeTitleLabel = [
            .text("collectible-approve-transaction-fee".localized),
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.left),
            .textOverflow(FittingText())
        ]
        self.transactionFeeAmountLabel = [
            .textColor(Colors.Helpers.negative),
            .font(Fonts.DMSans.medium.make(15)),
            .textAlignment(.right),
            .textOverflow(SingleLineText())
        ]
        self.separator = Separator(color: Colors.Layer.grayLighter, size: 1)
        self.separatorPadding = -20
        self.mainButtonTheme = ButtonPrimaryTheme()
        self.secondaryButtonTheme = ButtonSecondaryTheme()
        self.horizontalPadding = 24
        self.buttonInset = 12
        self.spacingBetweenButtonAndDetail = 24
        self.titleTopPadding = 10
        self.bottomInset = 16
        self.descriptionTopInset = 45
        self.assetNameTopPadding = 46
        self.spacingBetweenAssetNameAndSeparator = 20
        self.assetIDPaddings = (40, 8, .noMetric, .noMetric)
        self.transactionBottomPadding = 40
        self.copyIDButtonEdgeInsets = (6, 12, 6, 12)
        self.copyIDButtonHeight = 32
        self.copyIDButtonCorner = Corner(radius: 16)
    }
}
