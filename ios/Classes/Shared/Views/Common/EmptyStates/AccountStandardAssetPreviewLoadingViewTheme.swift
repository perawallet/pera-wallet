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

//   AccountStandardAssetPreviewLoadingViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AccountStandardAssetPreviewLoadingViewTheme:
    StyleSheet,
    LayoutSheet {
    var corner: Corner
    var background: ViewStyle
    var contentEdgeInsets: LayoutPaddings
    var iconSize: LayoutSize
    var iconCorner: Corner
    var spacingBetweenIconAndInfo: LayoutMetric
    var infoSize: LayoutSize
    var spacingBetweeenPrimaryValueAndInfo: LayoutMetric
    var primaryValueSize: LayoutSize
    var spacingBetweeenPrimaryValueAndSecondaryValue: LayoutMetric
    var secondaryValueSize: LayoutSize
    var spacingBetweenActionsAndSecondaryValue: LayoutMetric
    var actionWidth: LayoutMetric
    var spacingBetweenImageAndTitle: LayoutMetric
    var sendAction: ButtonStyle
    var spacingBetweenActions: LayoutMetric
    var receiveAction: ButtonStyle

    init(
        _ family: LayoutFamily
    ) {
        corner = Corner(radius: 4)
        contentEdgeInsets = (44, 0, 36, 0)
        background = [
            .backgroundColor(Colors.Helpers.heroBackground)
        ]
        iconSize = (40, 40)
        iconCorner = Corner(radius: iconSize.h / 2)
        spacingBetweenIconAndInfo = 20
        infoSize = (89, 20)
        spacingBetweeenPrimaryValueAndInfo = 8
        primaryValueSize = (210, 36)
        spacingBetweeenPrimaryValueAndSecondaryValue = 8
        secondaryValueSize = (41, 20)
        spacingBetweenActionsAndSecondaryValue = 48
        actionWidth = 64
        spacingBetweenImageAndTitle = 12
        spacingBetweenActions = 16
        sendAction = [
            .title(Self.getActionTitle("quick-actions-send-title".localized)),
            .icon( [ .normal("send-icon") ]),
            .font(Fonts.DMSans.regular.make(13)),
            .titleColor([ .normal(Colors.Text.main) ])
        ]
        receiveAction = [
            .title(Self.getActionTitle("quick-actions-receive-title".localized)),
            .icon( [ .normal("receive-icon") ]),
            .font(Fonts.DMSans.regular.make(13)),
            .titleColor([ .normal(Colors.Text.main) ])
        ]
        sendAction.title = "quick-actions-send-title".localized
    }

    static func getActionTitle(
        _ title: String
    ) -> EditText {
        .attributedString(
            title.footnoteRegular(
                alignment: .center
            )
        )
    }
}
