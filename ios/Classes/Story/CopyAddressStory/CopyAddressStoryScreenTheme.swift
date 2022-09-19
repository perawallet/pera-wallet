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

//   CopyAddressStoryScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct CopyAddressStoryScreenTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var image: ImageStyle
    var imageTopInset: LayoutMetric
    var imageMinHorizontalInsets: LayoutHorizontalPaddings
    var title: TextStyle
    var titleTopInset: LayoutMetric
    var description: TextStyle
    var descriptionVerticalMargins: LayoutVerticalMargins
    var defaultInset: LayoutMetric
    var closeButtonTitle: String
    var closeButtonHeight: LayoutMetric
    var closeButtonPaddings: UIEdgeInsets
    
    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.image = [
            .image("copy-address-story")
        ]
        self.imageTopInset = 32
        self.imageMinHorizontalInsets = (32, 32)
        self.title = [
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(19)),
            .text("story-copy-address-title".localized),
            .textOverflow(FittingText()),
            .textAlignment(.center)
        ]
        self.titleTopInset = 32
        self.description = [
            .textColor(Colors.Text.gray),
            .font(Fonts.DMSans.regular.make(13)),
            .text("story-copy-address-description".localized),
            .textOverflow(FittingText()),
            .textAlignment(.center)
        ]
        self.descriptionVerticalMargins = (12, 54)
        self.defaultInset = 32
        self.closeButtonHeight = 44
        self.closeButtonPaddings = UIEdgeInsets(top: 20, left: 32, bottom: 32, right: 32)
        self.closeButtonTitle = "title-got-it".localized
    }
}
