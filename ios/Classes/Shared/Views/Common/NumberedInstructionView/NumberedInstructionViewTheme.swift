// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   NumberedInstructionViewTheme.swift

import Foundation
import MacaroonUIKit

struct NumberedInstructionViewTheme: LayoutSheet, StyleSheet {
    let instruction: TextStyle
    let numberBackground: ImageStyle
    let number: TextStyle
    let numberTopInset: LayoutMetric
    let numberImageSize: LayoutSize
    let numberBackgroundCenterYOffset: LayoutMetric
    let horizontalPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.instruction = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .font(Typography.bodyRegular()),
            .textColor(Colors.Text.main)
        ]
        self.numberBackground = [
            .image("bg-import-account-instruction")
        ]
        self.number = [
            .textOverflow(SingleLineText()),
            .textAlignment(.center),
            .font(Typography.bodyRegular()),
            .textColor(Colors.Text.gray)
        ]
        self.numberTopInset = 8
        self.numberImageSize = (48, 48)
        self.numberBackgroundCenterYOffset = 3
        self.horizontalPadding = 16
    }
}
