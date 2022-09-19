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
//   TutorialStepsViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct TutorialStepsViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let textViewLinkAttributes: [AttributedTextBuilder.Attribute]

    let verticalSpacing: LayoutMetric
    let horizontalSpacing: LayoutMetric
    let horizontalPadding: LayoutMetric
    let topPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.textViewLinkAttributes = [
            .textColor(Colors.Link.primary.uiColor),
            .underline(UIColor.clear),
            .font(Fonts.DMSans.medium.make(15).uiFont),
        ]
        self.verticalSpacing = 40
        self.horizontalSpacing = 16
        self.horizontalPadding = 24
        self.topPadding = 40
    }
}
