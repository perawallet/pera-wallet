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
//   BadgedImageViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct BadgedImageViewTheme: StyleSheet, LayoutSheet {
    let imageCorner: Corner
    let badgePaddings: LayoutPaddings
    let imageSize: LayoutSize
    let badgeSize: LayoutSize

    init(_ family: LayoutFamily) {
        badgePaddings = (4, .noMetric, .noMetric, 9)
        imageSize = (80, 80)
        badgeSize = (32, 32)
        imageCorner = Corner(radius: imageSize.h / 2)
    }
}
