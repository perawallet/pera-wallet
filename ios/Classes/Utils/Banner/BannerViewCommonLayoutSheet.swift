// Copyright 2019 Algorand, Inc.

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
//   BannerViewLayoutSheet.swift

import Foundation
import Macaroon
import UIKit

struct BannerViewCommonLayoutSheet: BannerViewLayoutSheet {
    let iconSize: LayoutSize
    let horizontalStackViewPaddings: LayoutPaddings
    let horizontalStackViewSpacing: LayoutMetric
    let verticalStackViewSpacing: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.iconSize = (20, 16)
        self.horizontalStackViewPaddings = (20, 20, 20, 20)
        self.horizontalStackViewSpacing = 14
        self.verticalStackViewSpacing = 4
    }
}
