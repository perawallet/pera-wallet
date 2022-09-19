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
//   PassphraseBackUpViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct PassphraseBackUpViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let description: TextStyle

    let mainButtonTheme: ButtonTheme
    let passphraseViewTheme: PassphraseViewTheme

    let topInset: LayoutMetric
    let containerTopInset: LayoutMetric
    let collectionViewHeight: LayoutMetric
    let bottomInset: LayoutMetric
    let horizontalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.title = [
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(32)),
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .text("recover-passphrase-title".localized)
        ]
        self.description = [
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .text("passphrase-bottom-title".localized)
        ]

        self.mainButtonTheme = ButtonPrimaryTheme()
        self.passphraseViewTheme = PassphraseViewTheme()

        self.topInset = 2
        self.containerTopInset = 33
        self.collectionViewHeight = 456
        self.bottomInset = 16
        self.horizontalInset = 24
    }
}
