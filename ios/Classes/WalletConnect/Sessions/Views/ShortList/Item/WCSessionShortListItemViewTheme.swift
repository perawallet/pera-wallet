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
//   WCSessionShortListItemViewTheme.swift

import MacaroonUIKit
import UIKit

struct WCSessionShortListItemViewTheme: LayoutSheet, StyleSheet {
    let backgroundColor: Color
    let nameLabel: TextStyle
    let disconnectOptionsButton: ButtonStyle
    let descriptionLabel: TextStyle

    let imageBorder: Border
    let imageCorner: Corner
    let descriptionTopInset: LayoutMetric
    let nameLabelHorizontalInset: LayoutMetric
    let imageVerticalInset: LayoutMetric
    let imageSize: LayoutSize
    let disconnectOptionsButtonSize: LayoutSize
    let horizontalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.nameLabel = [
            .isInteractable(false),
            .text("wallet-connect-session-select-account".localized),
            .textAlignment(.left),
            .textOverflow(SingleLineText()),
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
        self.imageBorder = Border(color: Colors.Layer.grayLighter.uiColor, width: 1)

        self.horizontalInset = 24
        self.imageSize = (40, 40)
        self.imageCorner = Corner(radius: imageSize.h / 2)
        self.imageVerticalInset = 2
        self.disconnectOptionsButtonSize = (32, 32)
        self.nameLabelHorizontalInset = 16
        self.descriptionTopInset = 7
    }
}
