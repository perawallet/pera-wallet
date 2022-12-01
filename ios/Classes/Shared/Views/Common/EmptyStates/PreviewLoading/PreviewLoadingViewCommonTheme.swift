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
//   PreviewLoadingViewCommonTheme.swift

import Foundation
import MacaroonUIKit

struct PreviewLoadingViewCommonTheme: PreviewLoadingViewTheme {
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

    init(
        _ family: LayoutFamily
    ) {
        self.imageViewCorner = 20
        self.imageViewSize = (40, 40)

        self.titleViewCorner = 4
        self.titleMargin = (16, 16, .noMetric, .noMetric)
        self.titleViewSize = (114, 20)

        self.subtitleViewCorner = 4
        self.subtitleMargin = (8, 16, 16, .noMetric)
        self.subtitleViewSize = (44, 16)

        self.supplementaryViewCorner = 4
        self.supplementaryViewSize = (49, 20)
    }
}
