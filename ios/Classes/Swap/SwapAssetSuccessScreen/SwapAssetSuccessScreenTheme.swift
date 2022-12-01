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

//   SwapAssetSuccessScreenTheme.swift

import MacaroonUIKit
import UIKit

struct SwapAssetSuccessScreenTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let successIconBackground: ViewStyle
    let successIconBackgroundCorner: Corner
    let icon: ImageStyle
    let iconSize: LayoutSize
    let spacingBetweenIconAndTitle: LayoutMetric
    let title: TextStyle
    let titleCenterOffset: LayoutMetric
    let titleHorizontalInset: LayoutMetric
    let detail: TextStyle
    let detailHorizontalInset: LayoutMetric
    let spacingBetweenTitleAndDetail: LayoutMetric
    let doneAction: ButtonStyle
    let doneActionContentEdgeInsets: LayoutPaddings
    let doneActionEdgeInsets: LayoutPaddings
    let summaryAction: ButtonStyle
    let summaryActionHorizontalInset: LayoutMetric
    let spacingBetweenSummaryActionAndDoneAction: LayoutMetric
    let separator: Separator
    let spacingBetweenSeparatorAndSummaryAction: LayoutMetric
    let viewDetailAction: ButtonStyle
    let viewDetailActionHorizontalInset: LayoutMetric
    let spacingBetweenViewDetailActionAndSummaryAction: LayoutMetric
    let minimumSpacingBetweenViewDetailActionAndDetail: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.successIconBackground = [
            .backgroundColor(Colors.Helpers.success)
        ]
        self.successIconBackgroundCorner = Corner(radius: 30)
        self.icon = [
            .image("icon-success-36")
        ]
        self.iconSize = (60, 60)
        self.spacingBetweenIconAndTitle = 24
        self.title = [
            .textColor(Colors.Text.main),
            .textOverflow(FittingText()),
            .textAlignment(.center)
        ]
        self.titleCenterOffset = -40
        self.titleHorizontalInset = 40
        self.detail = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText()),
            .textAlignment(.center)
        ]
        self.detailHorizontalInset = 40
        self.spacingBetweenTitleAndDetail = 12
        self.doneAction = [
            .title("title-done".localized),
            .titleColor([ .normal(Colors.Button.Primary.text) ]),
            .font(Typography.bodyMedium()),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
            ])
        ]
        self.doneActionContentEdgeInsets = (16, 0, 16, 0)
        self.doneActionEdgeInsets = (12, 24, 16, 24)
        self.summaryAction = [
            .font(Typography.bodyMedium()),
            .title("swap-success-view-summary".localized),
            .titleColor([.normal(Colors.Helpers.positive)])
        ]
        self.summaryActionHorizontalInset = 24
        self.spacingBetweenSummaryActionAndDoneAction = 22
        self.separator = Separator(
            color: Colors.Layer.grayLighter,
            position: .top((24, 24))
        )
        self.spacingBetweenSeparatorAndSummaryAction = 10
        self.viewDetailAction = [
            .font(Typography.bodyMedium()),
            .title("swap-success-view-explorer".localized),
            .titleColor([.normal(Colors.Helpers.positive)])
        ]
        self.viewDetailActionHorizontalInset = 24
        self.spacingBetweenViewDetailActionAndSummaryAction = 10
        self.minimumSpacingBetweenViewDetailActionAndDetail = 12
    }
}
