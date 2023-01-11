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

//   WCConnectionViewTheme.swift

import UIKit
import MacaroonUIKit

struct WCConnectionViewTheme:
    StyleSheet,
    LayoutSheet {
    let backgroundColor: Color
    let horizontalPadding: LayoutMetric
    
    let dappImageSize: LayoutSize
    let dappImageCorner: Corner
    let dappImageTopPadding: LayoutMetric
    
    let title: TextStyle
    let titleTopPadding: LayoutMetric
    
    let urlAction: ButtonStyle
    let urlActionHeight: LayoutMetric
    let urlActionTopPadding: LayoutMetric
    
    let subtitleContainer: ViewStyle
    let subtitleContainerTopPadding: LayoutMetric
    
    let subtitle: TextStyle
    let subtitleContentEdgeInsets: LayoutPaddings
    let subtitleHorizontalPadding: LayoutMetric
    
    let subtitleSeparator: Separator
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.horizontalPadding = 24
        
        self.dappImageSize = (72, 72)
        self.dappImageCorner = Corner(radius: dappImageSize.h / 2)
        self.dappImageTopPadding = 28
        
        self.title = [
            .textAlignment(.center),
            .textOverflow(MultilineText(numberOfLines: 0)),
            .textColor(Colors.Text.main),
            .font(Typography.bodyLargeRegular())
        ]
        self.titleTopPadding = 20
        
        self.urlAction = [
            .backgroundColor(Colors.Defaults.background),
            .font(Typography.bodyBold()),
            .tintColor(Colors.Helpers.positive),
            .titleColor([
                .normal(Colors.Helpers.positive)
            ])
        ]
        self.urlActionHeight = 24
        self.urlActionTopPadding = 16
        
        self.subtitleContainer = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.subtitleContainerTopPadding = 28
        
        self.subtitle = [
            .textAlignment(.center),
            .textOverflow(SingleLineFittingText()),
            .textColor(Colors.Text.gray),
            .font(Typography.captionMedium()),
            .backgroundColor(Colors.Defaults.background)
        ]
        self.subtitleContentEdgeInsets = (0, 16, 0, 16)
        self.subtitleHorizontalPadding = 16
        
        self.subtitleSeparator = Separator(
            color: Colors.Layer.grayLighter,
            size: 1,
            position: .centerY((0, 0))
        )
    }
}
