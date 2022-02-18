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
//   TransactionStatusViewTheme.swift

import MacaroonUIKit
import UIKit

struct TransactionStatusViewTheme: LayoutSheet, StyleSheet {
    let statusLabel: TextStyle
    let corner: Corner
    let statusLabelEdgeInsets: LayoutPaddings
    
    init(_ family: LayoutFamily) {
        self.statusLabel = [
            .textAlignment(.center),
            .textOverflow(SingleLineText()),
            .font(Fonts.DMSans.medium.make(13))
        ]
        self.corner = Corner(radius: 14)
        self.statusLabelEdgeInsets = (4, 12, 4, 12)
    }
}
