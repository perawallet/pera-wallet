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

//   CollectibleGalleryGridLoadingViewTheme.swift

import MacaroonUIKit

struct CollectibleGalleryGridLoadingViewTheme:
    StyleSheet,
    LayoutSheet {
    let assetVerticalSpacing: LayoutMetric
    let assetHorizontalSpacing: LayoutMetric
    let asset: CollectibleGridItemLoadingViewTheme
    let assetsRowCount: Int
    let assetColumnCount: Int

    init(
        _ family: LayoutFamily
    ) {
        self.assetVerticalSpacing = 20
        self.assetHorizontalSpacing = 24
        self.asset = CollectibleGridItemLoadingViewTheme(family)
        self.assetsRowCount = 4
        self.assetColumnCount = 2
    }
}
