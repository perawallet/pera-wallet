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

//   MoonPayTransactionViewTheme.swift

import Foundation
import MacaroonUIKit

struct MoonPayTransactionViewTheme:
    StyleSheet,
    LayoutSheet {
    let titleLabel: TextStyle
    let descriptionLabel: TextStyle
    let accountLabel: TextStyle
    let addressLabel: TextStyle
    let doneButton: ButtonStyle
    let separator: Separator
    
    let topPadding: LayoutMetric
    let titleTopPadding: LayoutMetric
    let descriptionTopPadding: LayoutMetric
    let descriptionSeparatorTopPadding: LayoutMetric
    let accountTopPadding: LayoutMetric
    let accountSeparatorTopPadding: LayoutMetric
    let amountTopPadding: LayoutMetric
    let doneButtonTopPadding: LayoutMetric
    let doneButtonBottomPadding: LayoutMetric
    let buttonContentEdgeInsets: LayoutPaddings
    let buttonCorner: Corner
    
    let horizontalPadding: LayoutMetric

    let imageViewSize: LayoutSize
    
    init(_ family: LayoutFamily) {
        titleLabel = [
            .textColor(Colors.Text.main),
            .textOverflow(FittingText())
        ]
        descriptionLabel = [
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(Colors.Text.main),
            .textOverflow(FittingText())
        ]
        accountLabel = [
            .text("title-account".localized),
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(Colors.Text.grayLighter),
            .textOverflow(FittingText())
        ]
        addressLabel = [
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineText(lineBreakMode: .byTruncatingMiddle))
        ]
        doneButton = [
            .title("title-done".localized),
            .titleColor([
                .normal(Colors.Button.Primary.text)
            ]),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(Colors.Button.Primary.background)
        ]
        buttonContentEdgeInsets = (14, 0, 14, 0)
        buttonCorner = Corner(radius: 4)
        separator = Separator(color: Colors.Layer.grayLighter, size: 1)
        
        topPadding = 56
        titleTopPadding = 16
        descriptionTopPadding = 16
        descriptionSeparatorTopPadding = 40
        accountTopPadding = 61
        accountSeparatorTopPadding = 20
        amountTopPadding = 41
        doneButtonTopPadding = 40
        doneButtonBottomPadding = 16
        
        horizontalPadding = 24
        imageViewSize = (48, 48)
    }
}
