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
//   TransactionCustomRangeSelectionViewTheme.swift

import MacaroonUIKit

struct TransactionCustomRangeSelectionViewTheme: LayoutSheet, StyleSheet {
    let backgroundColor: Color
    let horizontalInset: LayoutMetric
    let topInset: LayoutMetric
    let pickerTopInset: LayoutMetric
    let pickerBottomInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background

        self.horizontalInset = 24
        self.topInset = 8
        self.pickerTopInset = 19
        self.pickerBottomInset = 16
    }
}
