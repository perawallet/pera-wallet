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
//   QRCreationViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct QRCreationViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let copyFeedbackLabel: TextStyle
    let copyButtonTheme: ButtonPrimaryTheme
    let shareButtonTheme: ButtonSecondaryTheme
    let addressTheme: QRAddressLabelTheme
    
    let copyFeedBackInsets: LayoutPaddings
    let topInset: LayoutMetric
    let labelTopInset: LayoutMetric
    let labelHorizontalInset: LayoutMetric
    let copyButtonTopInset: LayoutMetric
    let shareButtonTopInset: LayoutMetric
    let buttonTitleInset: LayoutMetric
    let buttonHorizontalInset: LayoutMetric
    let bottomInset: LayoutMetric
    let copyFeedbackLabelTopInset: LayoutMetric
    let copyFeedbackLabelCorner: Corner
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.copyFeedbackLabel = [
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(AppColors.Components.Text.main.uiColor.withAlphaComponent(0.9)),
            .textColor(AppColors.Components.TextField.defaultBackground),
            .text("qr-creation-copied".localized),
            .textAlignment(.center),
            .textOverflow(FittingText())
        ]
        self.copyFeedbackLabelCorner = Corner(radius: 4)
        self.copyButtonTheme = ButtonPrimaryTheme()
        self.shareButtonTheme = ButtonSecondaryTheme()
        self.addressTheme = QRAddressLabelTheme()
        
        self.copyFeedBackInsets = (8, 16, 8, 16)
        self.topInset = 92 * verticalScale
        self.labelTopInset = 28
        self.labelHorizontalInset = 40
        self.copyButtonTopInset = 16
        self.shareButtonTopInset = 16
        self.buttonTitleInset = 12
        self.buttonHorizontalInset = 24
        self.bottomInset = 16
        self.copyFeedbackLabelTopInset = 16
    }
}
