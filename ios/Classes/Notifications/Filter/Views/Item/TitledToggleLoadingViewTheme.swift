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

//   TitledToggleLoadingViewTheme.swift

import Foundation
import MacaroonUIKit

struct TitledToggleLoadingViewTheme:
    LayoutSheet,
    StyleSheet {
    let horizontalPadding: LayoutMetric
    let corner: Corner
    let titleSize: LayoutSize
    let toggleSize: LayoutSize

    init(
        _ family: LayoutFamily
    )  {
        self.corner = 4
        self.horizontalPadding = 24
        self.titleSize = (124, 20)
        self.toggleSize = (51, 31)
    }
}
