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

//   CollectibleMediaPreviewViewController+Theme.swift

import MacaroonUIKit

extension CollectibleMediaPreviewViewController {
    struct Theme:
        StyleSheet,
        LayoutSheet {
        let cellSpacing: LayoutMetric
        let horizontalInset: LayoutMetric
        let pageControlHeight: LayoutMetric
        let pageControlScale: LayoutMetric
        let pageIndicatorTintColor: Color
        let currentPageIndicatorTintColor: Color

        init(
            _ family: LayoutFamily
        ) {
            self.cellSpacing = 12
            self.horizontalInset = 24
            self.pageControlHeight = 26
            self.pageControlScale = 0.5
            self.pageIndicatorTintColor = Colors.Text.grayLighter.uiColor
            self.currentPageIndicatorTintColor = Colors.Text.gray.uiColor
        }
    }
}
