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

//   ReceiverAccountSelectionListScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ReceiverAccountSelectionListScreenTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let horizontalPadding: LayoutMetric
    let searchInputHeight: LayoutMetric
    let searchInputTopPadding: LayoutMetric
    let clipboard: AccountClipboardViewTheme
    let clipboardPaddings: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        horizontalPadding = 24
        searchInputHeight = 40
        searchInputTopPadding = 16
        clipboard = AccountClipboardViewTheme()
        clipboardPaddings = (20, 0, 0, 0)
    }
}
