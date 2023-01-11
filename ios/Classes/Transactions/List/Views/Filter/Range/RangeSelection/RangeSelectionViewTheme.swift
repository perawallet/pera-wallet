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
//   RangeSelectionViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct RangeSelectionViewTheme: StyleSheet, LayoutSheet {
    let titleLabel: TextStyle
    let dateLabel: TextStyle
    let focusIndicator: ViewStyle

    let intrinsicContentSize: LayoutSize
    let imageViewSize: LayoutSize
    let imageViewTopInset: LayoutMetric
    let focusIndicatorViewSelectedColor: Color
    let focusIndicatorViewSelectedHeight: LayoutMetric
    let focusIndicatorViewDefaultColor: Color
    let focusIndicatorViewDefaultHeight: LayoutMetric
    let dateLabelLeadingPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.titleLabel = [
            .isInteractable(false),
            .textAlignment(.left),
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.grayLighter),
            .font(Fonts.DMSans.regular.make(13)),
        ]
        self.dateLabel = [
            .isInteractable(false),
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(15)),
        ]
        self.focusIndicator = [
            .isInteractable(false),
            .backgroundColor(Colors.Text.main)
        ]
        self.focusIndicatorViewSelectedColor = Colors.Text.main
        self.focusIndicatorViewDefaultColor = Colors.Layer.gray

        self.intrinsicContentSize = (UIView.noIntrinsicMetric, 53.5)
        self.imageViewSize = (24, 24)
        self.imageViewTopInset = 4
        self.focusIndicatorViewSelectedHeight = 1.5
        self.focusIndicatorViewDefaultHeight = 1
        self.dateLabelLeadingPadding = 8
    }
}
