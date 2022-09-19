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
//   WelcomeViewTheme.swift

import MacaroonUIKit
import Foundation
import UIKit

struct WelcomeViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let termsOfConditionsAttributes: [AttributedTextBuilder.Attribute]
    let termsOfConditionsLinkAttributes: [AttributedTextBuilder.Attribute]
    let accountTypeViewTheme: AccountTypeViewTheme

    let horizontalInset: LayoutMetric
    let topInset: LayoutMetric
    let verticalInset: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.title = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(32))
        ]

        self.termsOfConditionsLinkAttributes = [
            .textColor(Colors.Link.primary.uiColor),
            .underline(UIColor.clear),
            .font(Fonts.DMSans.medium.make(13).uiFont),
        ]
        self.termsOfConditionsAttributes = [
            .textColor(Colors.Text.gray.uiColor),
            .font(Fonts.DMSans.medium.make(13).uiFont),
            .paragraph([
                .alignment(.center)
            ])
        ]
        self.accountTypeViewTheme = AccountTypeViewTheme()
        
        self.horizontalInset = 24
        self.topInset = 2
        self.verticalInset = 16
    }
}
