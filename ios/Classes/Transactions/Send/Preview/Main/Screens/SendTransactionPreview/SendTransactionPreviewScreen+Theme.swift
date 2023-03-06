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
import UIKit

extension SendTransactionPreviewScreen {
    struct Theme: LayoutSheet, StyleSheet {
        let background: Color
        let contentBottomEdgeInset: CGFloat
        let nextButtonStyle: ButtonPrimaryTheme
        let nextButtonContentEdgeInsets: NSDirectionalEdgeInsets

        init(_ family: LayoutFamily) {
            self.background = Colors.Defaults.background
            self.contentBottomEdgeInset = 16
            self.nextButtonStyle = ButtonPrimaryTheme(family)
            self.nextButtonContentEdgeInsets = .init(top: 8, leading: 24, bottom: 12, trailing: 24)
        }
    }
}
