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
//   SelectAccountViewController+Theme.swift

import Foundation
import MacaroonUIKit
import UIKit

extension SelectAccountViewController {
    struct Theme: LayoutSheet, StyleSheet {
        let listBackgroundColor: UIColor
        let listMinimumLineSpacing: LayoutMetric
        let listItemHeight: LayoutMetric
        let listContentInsetTop: LayoutMetric
        let horizontalPadding: LayoutMetric

        init(_ family: LayoutFamily) {
            listBackgroundColor = Colors.Defaults.background.uiColor
            listMinimumLineSpacing = 0
            listItemHeight = 72
            listContentInsetTop = 28
            horizontalPadding = 24
        }
    }
}
