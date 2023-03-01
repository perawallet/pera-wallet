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
//   SettingsToggleViewTheme.swift

import Foundation
import MacaroonUIKit

struct SettingsToggleViewTheme: LayoutSheet, StyleSheet {
    let backgroundColor: Color
    let name: TextStyle
    let toggle: ToggleTheme
    
    let imageSize: LayoutSize
    let nameOffset: LayoutMetric
    let horizontalInset: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.name = [
            .textColor(Colors.Text.main),
            .textOverflow(FittingText()),
            .font(Fonts.DMSans.regular.make(15))
        ]
        
        self.imageSize = (24, 24)
        self.nameOffset = 16
        self.horizontalInset = 24
        self.toggle = ToggleTheme(family)
    }
}
