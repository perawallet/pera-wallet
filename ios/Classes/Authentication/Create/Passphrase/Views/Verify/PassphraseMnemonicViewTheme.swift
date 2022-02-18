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
//   PassphraseMnemonicViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct PassphraseMnemonicViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let titleCorner: Corner

    let nextButtonTheme: ButtonTheme

    init(_ family: LayoutFamily) {
        self.backgroundColor = UIColor.clear
        self.title = [
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.medium.make(15)),
            .textAlignment(.center),
            .textOverflow(FittingText())
        ]
        self.titleCorner = Corner(radius: 4)
        self.nextButtonTheme = ButtonPrimaryTheme()
    }
}
