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
//   PendingTransactionViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct PendingTransactionViewTheme: StyleSheet, LayoutSheet {
    let transactionHistoryContextViewTheme: TransactionHistoryContextViewTheme
    let transactionHistoryContextLeadingPadding: LayoutMetric
    let indicatorLeadingPadding: LayoutMetric
    let indicator: ImageStyle
    let indicatorSize: LayoutSize

    init(_ family: LayoutFamily) {
        self.transactionHistoryContextViewTheme = TransactionHistoryContextViewTheme()
        self.transactionHistoryContextLeadingPadding = 56
        self.indicatorLeadingPadding = 24
        self.indicator = [
            .image("loading-indicator"),
            .contentMode(.scaleAspectFit)
        ]
        self.indicatorSize = (16, 16)
    }
}
