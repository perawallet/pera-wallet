// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ImportAccountScreenTheme.swift

import Foundation
import MacaroonUIKit

struct ImportAccountScreenTheme: LayoutSheet, StyleSheet {
    let background: ViewStyle
    
    let image: ImageStyle
    
    let title: TextStyle
    let titleTopPadding: LayoutMetric
    
    let horizontalPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        
        image = [
            .image("import-loading"),
            .contentMode(.center)
        ]
        
        title = [
            .textColor(Colors.Text.main),
            .text("backup-operation-loading-body".localized),
            .font(Typography.bodyLargeMedium()),
            .textAlignment(.center)
        ]
        titleTopPadding = 40
        
        horizontalPadding = 44
    }
}
