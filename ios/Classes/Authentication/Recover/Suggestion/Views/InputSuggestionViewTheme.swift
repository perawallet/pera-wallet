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
//   InputSuggestionViewTheme.swift

import MacaroonUIKit
import UIKit

struct InputSuggestionViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let suggestionTitle: TextStyle
    let separator: Separator

    let suggestionTrailingInset: LayoutMetric
    let separatorVerticalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Keyboard.accessoryBackground
        self.separator = Separator(color: Colors.Keyboard.accessoryLine)
        self.suggestionTitle = [
            .textOverflow(SingleLineFittingText(minimumScaleFactor: 0.7)),
            .textAlignment(.center),
            .font(UIFont.systemFont(ofSize: 16, weight: .regular)),
            .textColor(Colors.Defaults.systemElements),
        ]

        self.suggestionTrailingInset = 2
        self.separatorVerticalInset = 10
    }
}
