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
//   PortfolioCalculationInfoViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct PortfolioCalculationInfoViewTheme:
    StyleSheet,
    LayoutSheet {
    var title: TextStyle
    var body: TextStyle
    var spacingBetweenTitleAndBody: LayoutMetric
    
    init(
        _ family: LayoutFamily
    ) {
        self.title = [
            .text(Self.getTitle()),
            .textColor(AppColors.Components.Text.main),
            .textOverflow(FittingText())
        ]
        self.body = [
            .text(Self.getBody()),
            .textColor(AppColors.Components.Text.gray),
            .textOverflow(FittingText())
        ]
        self.spacingBetweenTitleAndBody = 20
    }
}

extension PortfolioCalculationInfoViewTheme {
    private static func getTitle() -> EditText {
        let font = Fonts.DMSans.medium.make(19)
        let lineHeightMultiplier = 1.13
        
        return .attributedString(
            "portfolio-calculation-title"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }
    
    private static func getBody() -> EditText {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23
        
        return .attributedString(
            "portfolio-calculation-description"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }
}
