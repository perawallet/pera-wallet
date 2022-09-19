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
//   LedgerAccountDetailViewController+Theme.swift

import MacaroonUIKit
import UIKit

extension LedgerAccountDetailViewController {
    struct Theme: LayoutSheet, StyleSheet {
        let backgroundColor: Color
        let sectionInset: LayoutPaddings
        let headerSize: LayoutSize
        let cellSize: LayoutSize
        let assetCellSize: LayoutSize

        init(_ family: LayoutFamily) {
            backgroundColor = Colors.Defaults.background
            sectionInset = (0, 24, 32, 24)
            headerSize = (UIScreen.main.bounds.width, 24)
            cellSize = (UIScreen.main.bounds.width - 48, 72)
            assetCellSize = (UIScreen.main.bounds.width, 72)
        }
    }
}
