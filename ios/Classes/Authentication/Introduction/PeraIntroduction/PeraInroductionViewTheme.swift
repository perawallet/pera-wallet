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

//   PeraInroductionViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct PeraInroductionViewTheme:
    StyleSheet,
    LayoutSheet {
    let closeButton: ButtonStyle
    let topViewContainer: ViewStyle
    let peraLogoImageView: ImageStyle
    let titleLabel: TextStyle
    let subtitleLabel: TextStyle
    let descriptionLabel: TextStyle
    let actionButton: ButtonStyle
    let actionButtonContentEdgeInsets: LayoutPaddings
    let actionButtonCorner: Corner

    let horizontalPadding: LayoutMetric
    let bottomPadding: LayoutMetric
    let topContainerMaxHeight: LayoutMetric
    let peraLogoMaxSize: LayoutSize
    let peraLogoMinSize: LayoutSize
    let topContainerMinHeight: LayoutMetric
    let titleLabelTopPadding: LayoutMetric
    let subtitleLabelTopPadding: LayoutMetric
    let descriptionLabelTopPadding: LayoutMetric
    let descriptionLabelBottomPadding: LayoutMetric
    let closeButtonSize: LayoutSize
    let closeButtonTopPadding: LayoutMetric
    let linearGradientHeight: LayoutMetric
    
    init(
        _ family: LayoutFamily
    ) {
        let closeButtonIcon = "icon-close".uiImage.withRenderingMode(.alwaysTemplate)
        closeButton = [
            .icon([.normal(closeButtonIcon)]),
            .tintColor(UIColor.black)
        ]
        topViewContainer = [
            .backgroundColor(AppColors.Shared.Global.yellow400)
        ]
        peraLogoImageView = [
            .contentMode(.scaleAspectFit)
        ]

        titleLabel = [
            .textColor(AppColors.Components.Text.main),
            .textOverflow(FittingText())
        ]

        subtitleLabel = [
            .textColor(AppColors.Components.Text.main),
            .textOverflow(FittingText())
        ]

        actionButton = [
            .title("pera-announcement-action-title".localized),
            .titleColor([ .normal(AppColors.Components.Button.Primary.text) ]),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(AppColors.Components.Button.Primary.background)
        ]
        actionButtonContentEdgeInsets = (14, 0, 14, 0)
        actionButtonCorner = Corner(radius: 4)

        descriptionLabel = [
            .isInteractable(true),
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(AppColors.Components.Text.main),
            .textOverflow(FittingText())
        ]

        horizontalPadding = 24
        bottomPadding = 16
        topContainerMaxHeight = 254
        topContainerMinHeight = 132
        titleLabelTopPadding = 40
        subtitleLabelTopPadding = 12
        descriptionLabelTopPadding = 20
        descriptionLabelBottomPadding = 2
        peraLogoMaxSize = (148, 64)
        peraLogoMinSize = (112, 48)
        closeButtonSize = (40, 40)
        closeButtonTopPadding = 10
        let buttonHeight: LayoutMetric = 52
        let additionalLinearGradientHeightForButtonTop: LayoutMetric = 4
        linearGradientHeight = bottomPadding + buttonHeight + additionalLinearGradientHeightForButtonTop
    }
}
