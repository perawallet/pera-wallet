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
//   PassphraseBackUpCellViewTheme.swift

import MacaroonUIKit
import Foundation
import UIKit

struct PassphraseCellViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let numberLabel: TextStyle
    let phraseLabel: TextStyle

    let leadingInset: LayoutMetric
    let numberLabelSize: LayoutSize

    init(_ family: LayoutFamily) {
        self.backgroundColor = UIColor.clear
        self.numberLabel = [
            .textColor(Colors.Text.gray),
            .font(Fonts.DMMono.regular.make(13)),
            .textAlignment(.right),
            .textOverflow(SingleLineFittingText())
        ]
        self.phraseLabel = [
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.left),
            .textOverflow(FittingText())
        ]
        self.leadingInset = 16.0 * horizontalScale
        self.numberLabelSize = (20, 20)
    }
}
