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

//   MoonpayIntroductionViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct BuyAlgoHomeViewTheme:
    StyleSheet,
    LayoutSheet {
    let closeButton: ButtonStyle
    let headerBackgroundView: ImageStyle
    let logoView: ImageStyle
    let titleLabel: TextStyle
    let subtitleLabel: TextStyle
    let descriptionLabel: TextStyle
    let securityLabel: TextStyle
    let buyAlgoButton: ButtonStyle
    let buttonContentEdgeInsets: LayoutPaddings
    let buttonCorner: Corner
    let header: ViewStyle
    
    let closeButtonSize: LayoutSize
    let closeButtonTopPadding: LayoutMetric
    let closeButtonLeadingPadding: LayoutMetric
    let titleTopPadding: LayoutMetric
    let headerMaxHeight: LayoutMetric
    let headerMinHeight: LayoutMetric
    let logoMaxSize: LayoutSize
    let logoMinSize: LayoutSize
    let subtitleLabelTopPadding: LayoutMetric
    let descriptionLabelTopPadding: LayoutMetric
    let descriptionLabelBottomPadding: LayoutMetric
    let securityImageTopPadding: LayoutMetric
    let securityLabelLeadingPadding: LayoutMetric
    let paymentViewTopPadding: LayoutMetric
    let paymentViewBottomPadding: LayoutMetric
    let paymentViewTrailingPadding: LayoutMetric
    let paymentViewSpacing: LayoutMetric
    let bottomPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let linearGradientHeight: LayoutMetric
    
    init(_ family: LayoutFamily) {
        let closeButtonIcon = "icon-close".uiImage.withRenderingMode(.alwaysTemplate)
        closeButton = [
            .icon([.normal(closeButtonIcon)]),
            .tintColor(UIColor.white)
        ]
        header = [
            .backgroundColor(Colors.Dapp.moonpay)
        ]
        headerBackgroundView = [
            .contentMode(.bottomLeft),
        ]
        logoView = [
            .contentMode(.scaleAspectFit)
        ]
        titleLabel = [
            .textColor(UIColor.white)
        ]
        subtitleLabel = [
            .textColor(Colors.Text.main),
            .textOverflow(FittingText())
        ]
        descriptionLabel = [
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText())
        ]
        securityLabel = [
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(Colors.Helpers.positive),
            .textOverflow(FittingText())
        ]
        buyAlgoButton = [
            .title("moonpay-introduction-title".localized),
            .titleColor([
                .normal(Colors.Button.Primary.text)
            ]),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(Colors.Button.Primary.background)
        ]
        buttonContentEdgeInsets = (14, 0, 14, 0)
        buttonCorner = Corner(radius: 4)
        
        closeButtonSize = (40, 40)
        closeButtonTopPadding = 10
        closeButtonLeadingPadding = 12
        titleTopPadding = 18
        headerMaxHeight = 254
        headerMinHeight = 132
        logoMaxSize = (200, 37)
        logoMinSize = (133, 27)
        subtitleLabelTopPadding = 40
        descriptionLabelTopPadding = 20
        descriptionLabelBottomPadding = 2
        securityImageTopPadding = 24
        securityLabelLeadingPadding = 8
        paymentViewTopPadding = 16
        paymentViewBottomPadding = 58
        paymentViewTrailingPadding = 190
        paymentViewSpacing = 24
        bottomPadding = 16
        horizontalPadding = 24
        
        let buttonHeight: LayoutMetric = 52
        let additionalLinearGradientHeightForButtonTop: LayoutMetric = 4
        linearGradientHeight = bottomPadding + buttonHeight + additionalLinearGradientHeightForButtonTop
    }
}
