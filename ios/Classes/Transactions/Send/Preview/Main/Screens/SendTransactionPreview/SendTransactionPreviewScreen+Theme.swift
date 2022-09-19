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
//   SendTransactionPreviewScreen+Theme.swift


import Foundation
import MacaroonUIKit

extension SendTransactionPreviewScreen {
    struct Theme: LayoutSheet, StyleSheet {
        let background: Color
        let nextButtonStyle: ButtonPrimaryTheme
        let nextButtonTopPadding: LayoutMetric
        let nextButtonLeadingInset: LayoutMetric
        let nextButtonHeight: LayoutMetric
        let nextButtonBottomInset: LayoutMetric
        let linearGradientHeight: LayoutMetric

        init(_ family: LayoutFamily) {
            self.background = Colors.Defaults.background
            self.nextButtonStyle = ButtonPrimaryTheme(family)
            self.nextButtonTopPadding = -24
            self.nextButtonLeadingInset = 24
            self.nextButtonHeight = 52
            self.nextButtonBottomInset = 16
            let buttonHeight: LayoutMetric = 52
            let additionalLinearGradientHeightForButtonTop: LayoutMetric = 4
            self.linearGradientHeight = nextButtonBottomInset + buttonHeight + additionalLinearGradientHeightForButtonTop
        }
    }
}
