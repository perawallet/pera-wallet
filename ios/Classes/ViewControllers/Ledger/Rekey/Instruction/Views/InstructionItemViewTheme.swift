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
//   InstructionItemViewTheme.swift

import MacaroonUIKit
import UIKit

protocol InstructionItemViewTheme:
    StyleSheet,
    LayoutSheet {
    var image: ImageStyle { get }
    var title: TextStyle { get }

    var infoImageSize: LayoutSize { get }
    var horizontalPadding: LayoutMetric { get }
}

struct SmallerInstructionItemViewTheme: InstructionItemViewTheme {
    let image: ImageStyle
    let title: TextStyle
    let infoImageSize: LayoutSize
    let horizontalPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.image = [
            .image("icon-rekey-info")
        ]
        self.title = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.regular.make(13)),
            .textColor(Colors.Text.main)
        ]

        self.infoImageSize = (40, 40)
        self.horizontalPadding = 16
    }
}

struct LargerInstructionItemViewTheme: InstructionItemViewTheme {
    let image: ImageStyle
    let title: TextStyle
    let infoImageSize: LayoutSize
    let horizontalPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.image = [
            .image("icon-rekey-info")
        ]
        self.title = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(Colors.Text.main)
        ]

        self.infoImageSize = (40, 40)
        self.horizontalPadding = 16
    }
}
