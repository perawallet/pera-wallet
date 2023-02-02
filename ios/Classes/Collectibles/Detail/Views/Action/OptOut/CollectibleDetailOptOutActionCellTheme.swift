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

//   CollectibleDetailOptOutActionCellTheme.swift

import Foundation
import UIKit
import MacaroonUIKit

struct CollectibleDetailOptOutActionCellTheme:
    StyleSheet,
    LayoutSheet {
    private(set) var contextFont: UIFont
    private(set) var context: ButtonStyle
    private(set) var contextEdgeInsets: LayoutPaddings

    init(_ family: LayoutFamily) {
        let contextFont = Typography.bodyMedium()
        self.contextFont = contextFont
        self.context = [
            .title("collectible-detail-opt-out".localized),
            .titleColor([ .normal(Colors.Button.Secondary.text) ]),
            .font(contextFont),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted"),
            ])
        ]
        self.contextEdgeInsets = (16, 8, 16, 8)
    }
}
