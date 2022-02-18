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
//   TransactionsListLayout+Theme.swift

import MacaroonUIKit
import UIKit

extension TransactionsListLayout {
    struct Theme: LayoutSheet, StyleSheet {
        let transactionHistoryTitleCellSize: LayoutSize
        let transactionHistoryCellSize: LayoutSize
        let transactionHistoryFilterCellSize: LayoutSize

        init(_ family: LayoutFamily) {
            self.transactionHistoryTitleCellSize = (UIScreen.main.bounds.width, 49)
            self.transactionHistoryCellSize = (UIScreen.main.bounds.width, 72)
            self.transactionHistoryFilterCellSize = (UIScreen.main.bounds.width, 40)
        }
    }
}
