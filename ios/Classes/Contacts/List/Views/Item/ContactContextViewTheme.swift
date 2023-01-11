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
//   ContactContextViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ContactContextViewTheme: StyleSheet, LayoutSheet {
    let userImage: ImageStyle
    let userImageCorner: Corner
    let nameLabel: TextStyle
    let addressLabel: TextStyle
    let qrButton: ButtonStyle

    let horizontalPadding: LayoutMetric
    let verticalPadding: LayoutMetric 
    let imageSize: LayoutSize
    let buttonSize: LayoutSize
    let labelHorizontalPaddings: LayoutHorizontalPaddings
    let addressLabelTopPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.userImage = [
            .image("icon-user-placeholder"),
            .contentMode(.center)
        ]
        self.nameLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(15))
        ]
        self.addressLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.grayLighter),
            .font(Fonts.DMMono.regular.make(13))
        ]
        self.qrButton = [
            .icon([.normal("icon-qr")]),
            .tintColor(Colors.Text.main)
        ]
        self.horizontalPadding = 24
        self.imageSize = (40, 40)
        self.userImageCorner = Corner(radius: imageSize.h / 2)
        self.verticalPadding = 12
        self.labelHorizontalPaddings = (15, 54)
        self.buttonSize = (24, 24)
        self.addressLabelTopPadding = 7
    }
}
