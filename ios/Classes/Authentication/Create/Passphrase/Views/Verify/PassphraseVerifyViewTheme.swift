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
//   PassphraseVerifyViewTheme.swift

import MacaroonUIKit
import UIKit

struct PassphraseVerifyViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    
    let title: TextStyle
    let titleText: EditText
    let titleTopInset: LayoutMetric
    
    let listTopOffset: LayoutMetric
    
    let cardViewTheme: PassphraseVerifyCardViewTheme
    let cardViewBottomOffset: LayoutMetric

    let nextButtonTheme: ButtonTheme
    let buttonTopOffset: LayoutMetric
    let buttonBottomOffset: LayoutMetric

    let horizontalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        
        self.title = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
        ]

        var titleAttributes = Typography.titleMediumAttributes()
        titleAttributes.insert(.textColor(Colors.Text.main))
        self.titleText = .attributedString(
            "passphrase-verify-title"
                .localized
                .attributed(
                    titleAttributes
                )
        )

        self.titleTopInset = 2
        
        self.listTopOffset = 40
        
        self.cardViewTheme = PassphraseVerifyCardViewTheme()
        self.cardViewBottomOffset = 32
        
        self.nextButtonTheme = ButtonPrimaryTheme()
        self.buttonTopOffset = 24
        self.buttonBottomOffset = 16
        
        self.horizontalInset = 24
    }
}
