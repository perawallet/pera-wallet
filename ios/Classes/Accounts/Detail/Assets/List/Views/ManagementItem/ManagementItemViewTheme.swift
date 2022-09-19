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

//   AssetManagementItemViewTheme.swift

import Foundation
import MacaroonUIKit

struct ManagementItemViewTheme:
    StyleSheet,
    LayoutSheet {
    let primaryButton: ButtonStyle
    var secondaryButton: ButtonStyle
    let buttonHeight: LayoutMetric
    var spacing: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.primaryButton = [
            .titleColor([.normal(Colors.Helpers.positive)])
        ]
        self.secondaryButton = [
            .titleColor([.normal(Colors.Helpers.positive)])
        ]
        self.buttonHeight = 40
        self.spacing = 16
    }
}

extension ManagementItemViewTheme {
    mutating func configureForSingleAction() {
        secondaryButton = []
        spacing = .zero
    }
}
