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
//   WCConnectionApprovalViewTheme.swift

import UIKit
import MacaroonUIKit

struct WCConnectionApprovalViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let dappImageViewCorner: Corner
    let URLButton: ButtonStyle
    let cancelButton: ButtonStyle
    let connectButton: ButtonStyle
    let buttonContentEdgeInset: LayoutPaddings
    let buttonCorner: Corner

    let dappImageSize: LayoutSize
    let verticalInset: LayoutMetric
    let horizontalInset: LayoutMetric
    let titleTopInset: LayoutMetric 
    let urlTopInset: LayoutMetric
    let imageTopInset: LayoutMetric
    let bottomInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.title = [
            .textAlignment(.center),
            .textOverflow(MultilineText(numberOfLines: 0)),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(19))
        ]
        self.URLButton = [
            .font(Fonts.DMSans.bold.make(15)),
            .titleColor([.normal(Colors.Helpers.positive)])
        ]
        self.cancelButton = ButtonStyles.secondaryButton(title: "title-cancel".localized).create()
        self.connectButton = ButtonStyles.primaryButton(title: "title-connect".localized).create()
        self.buttonContentEdgeInset = (14, 0, 14, 0)
        self.buttonCorner = Corner(radius: 4)

        self.imageTopInset = 40
        self.verticalInset = 32
        self.titleTopInset = 20
        self.horizontalInset = 24
        self.urlTopInset = 16
        self.dappImageSize = (72, 72)
        self.dappImageViewCorner = Corner(radius: dappImageSize.h / 2)
        self.bottomInset = 16
    }
}
