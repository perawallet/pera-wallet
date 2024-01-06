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
//   AccountRecoverViewController+Theme.swift

import MacaroonUIKit
import UIKit

extension AccountRecoverViewController {
    struct Theme: LayoutSheet, StyleSheet {
        let accountRecoverViewTheme: AccountRecoverViewTheme
        let backgroundColor: Color

        let bottomInset: LayoutMetric
        let horizontalPadding: LayoutMetric
        let inputSuggestionsFrame: CGRect
        let keyboardInset: LayoutMetric
        let inputViewHeight: LayoutMetric

        init(_ family: LayoutFamily) {
            self.accountRecoverViewTheme = AccountRecoverViewCommonTheme()
            self.backgroundColor = Colors.Defaults.background

            self.horizontalPadding = 24
            self.bottomInset = 16
            self.inputSuggestionsFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
            self.keyboardInset = 92
            self.inputViewHeight = 732
        }
    }
}
