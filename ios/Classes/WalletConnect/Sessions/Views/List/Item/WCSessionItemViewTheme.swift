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
//   WCSessionItemViewTheme.swift

import MacaroonUIKit
import UIKit

struct WCSessionItemViewTheme: LayoutSheet, StyleSheet {
    let horizontalPadding: LayoutMetric
    
    let image: URLImageViewStyleLayoutSheet
    let imageSize: LayoutSize
    let imageBorder: Border
    let imageCorner: Corner
    
    let name: TextStyle
    let nameHorizontalPadding: LayoutMetric
    
    let optionsAction: ButtonStyle
    
    let descriptionTopPadding: LayoutMetric
    let description: TextStyle
    
    let dateTopPadding: LayoutMetric
    let date: TextStyle
    
    let accountStatusTopPadding: LayoutMetric
    let spacingBetweenAccounts: LayoutMetric

    init(_ family: LayoutFamily) {
        self.horizontalPadding = 24
        
        self.image = URLImageViewNoStyleLayoutSheet()
        self.imageSize = (40, 40)
        self.imageBorder = Border(
            color: Colors.Layer.grayLighter.uiColor,
            width: 1
        )
        self.imageCorner = Corner(radius: imageSize.h / 2)
        
        self.name = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main)
        ]
        self.nameHorizontalPadding = 16
        
        self.description = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
        ]
        self.descriptionTopPadding = 8
        
        self.optionsAction = [
            .icon([ .normal("icon-options") ])
        ]
        
        self.date = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.grayLighter)
        ]
        self.dateTopPadding = 12
        
        self.accountStatusTopPadding = 8
        self.spacingBetweenAccounts = 6
    }
}
