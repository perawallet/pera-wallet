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
//   WCSessionItemViewTheme.swift

import MacaroonUIKit
import UIKit

struct WCSessionItemViewTheme: LayoutSheet, StyleSheet {
    let backgroundColor: Color
    let nameLabel: TextStyle
    let disconnectOptionsButton: ButtonStyle
    let descriptionLabel: TextStyle
    let statusLabel: TextStyle
    let dateLabel: TextStyle

    let imageBorder: Border
    let imageCorner: Corner
    let dateLabelTopInset: LayoutMetric
    let descriptionTopInset: LayoutMetric
    let nameLabelHorizontalInset: LayoutMetric
    let imageTopInset: LayoutMetric
    let imageSize: LayoutSize
    let disconnectOptionsButtonSize: LayoutSize
    let horizontalInset: LayoutMetric
    let statusLabelSize: LayoutSize
    let statusLabelCorner: Corner
    let statusLabelTopInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.nameLabel = [
            .isInteractable(false),
            .text("wallet-connect-session-select-account".localized),
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(Colors.Text.main)
        ]
        self.descriptionLabel = [
            .isInteractable(false),
            .textAlignment(.left),
            .textOverflow(MultilineText(numberOfLines: 0)),
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(13))
        ]
        self.disconnectOptionsButton = [
            .icon([.normal("icon-options")])
        ]
        self.statusLabel = [
            .isInteractable(false),
            .textAlignment(.center),
            .textOverflow(SingleLineFittingText()),
            .font(Fonts.DMSans.regular.make(13)),
            .textColor(Colors.Helpers.positive),
            .backgroundColor(Colors.Helpers.positive.uiColor.withAlphaComponent(0.1))
        ]
        self.dateLabel = [
            .isInteractable(false),
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .font(Fonts.DMSans.regular.make(13)),
            .textColor(Colors.Text.grayLighter)
        ]
        self.imageBorder = Border(color: Colors.Layer.grayLighter.uiColor, width: 1)

        self.horizontalInset = 24
        self.statusLabelSize = (226, 24)
        self.statusLabelCorner = Corner(radius: statusLabelSize.h / 2)
        self.imageSize = (40, 40)
        self.imageCorner = Corner(radius: imageSize.h / 2)
        self.imageTopInset = 4
        self.disconnectOptionsButtonSize = (32, 32)
        self.nameLabelHorizontalInset = 16
        self.descriptionTopInset = 8
        self.dateLabelTopInset = 12
        self.statusLabelTopInset = 8
    }
}
