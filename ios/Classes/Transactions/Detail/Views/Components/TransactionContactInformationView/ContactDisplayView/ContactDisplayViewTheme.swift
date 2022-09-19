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
//   ContactDisplayViewTheme.swift

import MacaroonUIKit

struct ContactDisplayViewTheme: LayoutSheet, StyleSheet {
    let nameLabel: TextStyle
    let contactImage: ImageStyle
    let contactImageCorner: Corner
    let contactImageSize: LayoutSize
    let addContactButton: ButtonStyle
    let addContactButtonCorner: Corner

    let horizontalPadding: LayoutMetric
    let addContactButtonEdgeInsets: LayoutPaddings
    let addContactButtonSize: LayoutSize

    init(_ family: LayoutFamily) {
        self.nameLabel = [
            .isInteractable(true),
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMMono.regular.make(15))
        ]
        self.contactImage = [
            .contentMode(.scaleAspectFit)
        ]
        self.contactImageSize = (24, 24)
        self.contactImageCorner = Corner(radius: contactImageSize.h / 2)
        self.addContactButton = [
            .backgroundColor(Colors.Layer.grayLighter),
            .font(Fonts.DMSans.regular.make(15)),
            .titleColor([.normal(Colors.Text.gray)]),
            .title("transaction-detail-add".localized)
        ]
        self.addContactButtonEdgeInsets = (4, 12, 4, 12)
        self.addContactButtonCorner = Corner(radius: 16)
        self.horizontalPadding = 12
        self.addContactButtonSize = (53, 32)
    }
}
