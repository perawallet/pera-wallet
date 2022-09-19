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
//   NumpadViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol NumpadViewTheme: StyleSheet, LayoutSheet {
    var backgroundColor: Color { get }
    var stackViewSpacing: LayoutMetric { get }
    var stackViewHeight: LayoutMetric { get }
    var stackViewTopPadding: LayoutMetric { get }
}

struct NumpadViewCommonTheme: NumpadViewTheme {
    let backgroundColor: Color
    let stackViewSpacing: LayoutMetric
    let stackViewHeight: LayoutMetric
    let stackViewTopPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background

        self.stackViewTopPadding = 20 * verticalScale
        self.stackViewSpacing = 40 * verticalScale
        self.stackViewHeight = 72 * verticalScale
    }
}

struct TransactionNumpadViewTheme: NumpadViewTheme {
    let backgroundColor: Color
    let stackViewSpacing: LayoutMetric
    let stackViewHeight: LayoutMetric
    let stackViewTopPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background

        self.stackViewTopPadding = 0
        self.stackViewSpacing = 40 * verticalScale
        self.stackViewHeight = 72 * verticalScale
    }
}
