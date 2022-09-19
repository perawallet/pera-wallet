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
//   SettingsFooterViewTheme.swift

import Foundation
import MacaroonUIKit

struct SettingsFooterViewTheme: LayoutSheet, StyleSheet {
    let backgroundColor: Color
    let button: ButtonStyle
    let subTitle: TextStyle
    
    let buttonHeight: LayoutMetric
    let buttonCornerRadius: LayoutMetric
    let subTitleTopInset: LayoutMetric
    let horizontalInset: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.button = [
            .title("settings-logout-title".localized),
            .titleColor([.normal(Colors.Button.Secondary.text)]),
            .backgroundColor(Colors.Button.Secondary.background),
            .font(Fonts.DMSans.medium.make(15))
        ]
        self.subTitle = [
            .textAlignment(.center),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(13))
        ]
        
        self.buttonHeight = 52
        self.buttonCornerRadius = 4
        self.subTitleTopInset = 20
        self.horizontalInset = 24
    }
}
