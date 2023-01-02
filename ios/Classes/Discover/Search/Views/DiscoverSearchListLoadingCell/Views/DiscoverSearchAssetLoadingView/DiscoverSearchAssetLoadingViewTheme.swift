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

//   DiscoverSearchLoadingAssetViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct DiscoverSearchAssetLoadingViewTheme: PreviewLoadingViewTheme {
    var imageViewCorner: LayoutMetric
    var imageViewSize: LayoutSize
    var titleViewCorner: LayoutMetric
    var titleViewSize: LayoutSize
    var titleMargin: LayoutMargins
    var subtitleViewCorner: LayoutMetric
    var subtitleViewSize: LayoutSize
    var subtitleMargin: LayoutMargins
    var supplementaryViewCorner: LayoutMetric
    var supplementaryViewSize: LayoutSize

    init(_ family: LayoutFamily) {
        let defaultTheme = PreviewLoadingViewCommonTheme(family)

        self.imageViewCorner = defaultTheme.imageViewCorner
        self.imageViewSize = defaultTheme.imageViewSize
        self.titleViewCorner = defaultTheme.titleViewCorner
        self.titleMargin = (18, 16, .noMetric, .noMetric)
        self.titleViewSize = (80, 20)
        self.subtitleViewCorner = defaultTheme.subtitleViewCorner
        self.subtitleMargin = (8, 16, .noMetric, .noMetric)
        self.subtitleViewSize = (120, 16)
        self.supplementaryViewCorner = defaultTheme.supplementaryViewCorner
        self.supplementaryViewSize = (72, 20)
    }
}
