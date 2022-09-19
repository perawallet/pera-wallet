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
//   PassphraseBackUpViewController+Theme.swift

import MacaroonUIKit
import Foundation
import UIKit

extension PassphraseBackUpViewController {
    struct Theme: LayoutSheet, StyleSheet {
        let passphraseBackUpViewTheme: PassphraseBackUpViewTheme
        let backgroundColor: Color
        let modalSize: LayoutSize
        let cellHeight: LayoutMetric

        init(_ family: LayoutFamily) {
            passphraseBackUpViewTheme = PassphraseBackUpViewTheme()
            backgroundColor = Colors.Defaults.background
            modalSize = (UIScreen.main.bounds.width, 338)
            cellHeight = 24
        }
    }
}
