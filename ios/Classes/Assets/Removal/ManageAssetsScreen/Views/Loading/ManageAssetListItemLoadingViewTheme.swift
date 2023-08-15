// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ManageAssetListItemLoadingViewTheme.swift

import Foundation
import MacaroonUIKit

struct ManageAssetListItemLoadingViewTheme: StyleSheet, LayoutSheet {
    var imageCorner: LayoutMetric
    var imageSize: LayoutSize

    var textContainerWidth: LayoutMetric
    var textContainerLeadingMargin: LayoutMetric
    
    var titleCorner: LayoutMetric
    var titleSize: LayoutSize
    
    var subtitleCorner: LayoutMetric
    var subtitleSize: LayoutSize
    var subtitleTopPadding: LayoutMetric
    
    var actionCorner: LayoutMetric
    var actionSize: LayoutSize
    
    init(_ family: LayoutFamily) {
        self.imageCorner = 20
        self.imageSize = (40, 40)
        
        self.textContainerWidth = 114
        self.textContainerLeadingMargin = 16
        
        self.titleCorner = 4
        self.titleSize = (114, 20)

        self.subtitleCorner = 4
        self.subtitleSize = (44, 16)
        self.subtitleTopPadding = 10

        self.actionCorner = 8
        self.actionSize = (36, 36)
    }
}
