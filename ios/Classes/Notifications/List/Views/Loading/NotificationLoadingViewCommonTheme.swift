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

//   NotificationLoadingViewCommonTheme.swift

import Foundation
import MacaroonUIKit

struct NotificationLoadingViewCommonTheme: NotificationLoadingViewTheme {
    var imageViewCorner: LayoutMetric
    var imageViewSize: LayoutSize
    var imageViewMargin: LayoutMargins

    var titleViewCorner: LayoutMetric
    var titleViewHeight: LayoutMetric
    var titleMargin: LayoutMargins

    var subtitleViewCorner: LayoutMetric
    var subtitleViewSize: LayoutSize
    var subtitleMargin: LayoutMargins

    var supplementaryViewCorner: LayoutMetric
    var supplementaryViewSize: LayoutSize
    var supplementaryViewMargin: LayoutMargins

    init(
        _ family: LayoutFamily
    ) {
        self.imageViewCorner = 20
        self.imageViewSize = (40, 40)
        self.imageViewMargin = (16, .noMetric, .noMetric, .noMetric)

        self.titleViewCorner = 4
        self.titleMargin = (16, 12, .noMetric, 28)
        self.titleViewHeight = 20

        self.subtitleViewCorner = 4
        self.subtitleMargin = (8, 12, .noMetric, .noMetric)
        self.subtitleViewSize = (141, 20)

        self.supplementaryViewCorner = 4
        self.supplementaryViewSize = (84, 16)
        self.supplementaryViewMargin = (8, 12, .noMetric, .noMetric)
    }
}

