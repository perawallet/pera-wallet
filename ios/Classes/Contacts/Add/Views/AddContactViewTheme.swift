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
//   AddContactViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AddContactViewTheme: StyleSheet, LayoutSheet {
    let photoLabel: TextStyle
    let qrButton: ButtonStyle
    let addContactButtonViewTheme: ButtonTheme

    let horizontalPadding: LayoutMetric
    let badgedImageViewTopPadding: LayoutMetric
    let addPhotoLabelTopPadding: LayoutMetric
    let bottomPadding: LayoutMetric
    let topPadding: LayoutMetric
    let inputTopPadding: LayoutMetric
    let inputSpacing: LayoutMetric

    init(_ family: LayoutFamily) {
        self.photoLabel = [
            .text("contacts-add-photo".localized),
            .textAlignment(.center),
            .textOverflow(SingleLineFittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(18))
        ]
        self.qrButton = [
            .icon([.normal("icon-qr-scan")])
        ]
        self.addContactButtonViewTheme = ButtonPrimaryTheme()

        self.horizontalPadding = 24
        self.badgedImageViewTopPadding = 32
        self.addPhotoLabelTopPadding = 20
        self.bottomPadding = 16
        self.topPadding = 32
        self.inputTopPadding = 74
        self.inputSpacing = 26
    }
}
