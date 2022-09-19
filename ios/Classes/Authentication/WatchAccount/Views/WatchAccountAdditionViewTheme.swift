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
//   WatchAccountAdditionViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct WatchAccountAdditionViewTheme: StyleSheet, LayoutSheet {
    let title: TextStyle
    let description: TextStyle
    let pasteButton: ButtonStyle
    let qr: ButtonStyle

    let mainButtonTheme: ButtonTheme

    let pasteTextAttributes: [AttributedTextBuilder.Attribute]
    let copiedTextAttributes: [AttributedTextBuilder.Attribute]

    let textInputVerticalInset: LayoutMetric
    let buttonVerticalInset: LayoutMetric
    let horizontalInset: LayoutMetric
    let bottomInset: LayoutMetric
    let topInset: LayoutMetric
    let containerTopInset: LayoutMetric
    let pasteButtonTopInset: LayoutMetric
    let pasteButtonSize: LayoutSize
    let pasteButtonCorner: Corner
    let pasteButtonContentEdgeInsets: LayoutPaddings

    init(_ family: LayoutFamily) {
        self.title = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(32)),
            .text("watch-account-create".localized)
        ]

        self.description = [
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .text("watch-account-explanation-title".localized)
        ]
        self.pasteButton = [
            .backgroundColor(Colors.Other.Global.gray800),
            .font(Fonts.DMMono.regular.make(15))
        ]
        self.pasteButtonCorner = Corner(radius: 20)
        self.qr = [
            .icon([.normal("icon-qr-scan")])
        ]

        self.mainButtonTheme = ButtonPrimaryTheme()
        self.pasteTextAttributes = [
            .font(Fonts.DMSans.regular.make(15).uiFont),
            .textColor(Colors.Text.white.uiColor)
        ]

        self.copiedTextAttributes = [
            .font(Fonts.DMMono.regular.make(11).uiFont),
            .textColor(Colors.Text.grayLighter.uiColor)
        ]

        self.textInputVerticalInset = 40
        self.buttonVerticalInset = 60
        self.horizontalInset = 24
        self.bottomInset = 16
        self.topInset = 2
        self.containerTopInset = 32
        self.pasteButtonTopInset = 20
        self.pasteButtonSize = (175, 40)
        self.pasteButtonContentEdgeInsets = (10, 16, 10, 16)
    }
}
