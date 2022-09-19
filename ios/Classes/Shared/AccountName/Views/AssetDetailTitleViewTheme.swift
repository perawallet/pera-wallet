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
//   AssetDetailTitleViewTheme.swift

import MacaroonUIKit

struct AssetDetailTitleViewTheme: LayoutSheet, StyleSheet {
    let horizontalPadding: LayoutMetric
    let imageSize: LayoutSize
    var titleLabel: TextStyle
    var assetImageViewTheme: PrimaryImageViewTheme

    init(_ family: LayoutFamily) {
        self.imageSize = (24, 24)
        self.horizontalPadding = 12
        self.titleLabel = [
            .textOverflow(SingleLineFittingText()),
            .textAlignment(.left),
            .textColor(Colors.Text.main),
        ]
        self.assetImageViewTheme = AssetImageViewTheme()
    }
}
