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
//   RecoverInputViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct RecoverInputViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color

    let number: TextStyle
    let inputTextField: TextInputStyle
    let focusIndicator: ViewStyle

    let size: LayoutSize
    let defaultInset: LayoutMetric 
    let numberVerticalInset: LayoutMetric
    let focusIndicatorHeight: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = UIColor.clear

        self.number = [
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.left)
        ]
        self.inputTextField = [
            .backgroundColor(UIColor.clear),
            .textColor(Colors.Text.main),
            .tintColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(15)),
            .autocorrectionType(.no),
            .clearButtonMode(.whileEditing),
            .autocapitalizationType(.none)
        ]
        
        self.focusIndicator = [
            .backgroundColor(Colors.Layer.gray)
        ]

        self.size = (158, 48)
        self.defaultInset = 8
        self.numberVerticalInset = 12
        self.focusIndicatorHeight = 1
    }
}
