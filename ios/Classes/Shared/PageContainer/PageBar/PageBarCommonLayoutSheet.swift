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
//   PageBarCommonLayoutSheet.swift

import Foundation
import MacaroonUIKit
import UIKit

struct PageBarCommonLayoutSheet: PageBarLayoutSheet {
    let intrinsicHeight: LayoutMetric
    let contentPaddings: LayoutPaddings
    let offIndicatorHeight: LayoutMetric
    let offIndicatorHorizontalPaddings: LayoutHorizontalPaddings
    let offIndicatorBottomPadding: LayoutMetric
    let onIndicatorHeight: LayoutMetric
    let onIndicatorBottomPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.intrinsicHeight = 52
        self.contentPaddings = (0, 0, 0, 0)
        self.offIndicatorHeight = 1
        self.offIndicatorHorizontalPaddings = (0, 0)
        self.offIndicatorBottomPadding = 0
        self.onIndicatorHeight = 2
        self.onIndicatorBottomPadding = 0
    }
}
