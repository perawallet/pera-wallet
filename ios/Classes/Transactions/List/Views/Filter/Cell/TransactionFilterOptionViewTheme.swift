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
//   TransactionFilterOptionViewTheme.swift

import MacaroonUIKit

struct TransactionFilterOptionViewTheme: StyleSheet, LayoutSheet {
    let title: TextStyle
    let date: TextStyle
    let checkmarkImage: ImageStyle
    let dateImageViewLabel: TextStyle

    let titleLabelLeadingInset: LayoutMetric
    let verticalInset: LayoutMetric
    let iconImageSize: LayoutSize
    let checkmarkImageSize: LayoutSize
    let dateImageVerticalInset: LayoutMetric
    let minimumHorizontalInset: LayoutMetric
    let dateImageLabelTopPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.title = [
            .textAlignment(.left),
            .textOverflow(SingleLineText()),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(Colors.Text.main)
        ]
        self.date = [
            .textAlignment(.left),
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.grayLighter),
            .font(Fonts.DMSans.regular.make(13))
        ]
        self.checkmarkImage = [
           .image("icon-circle-check")
       ]
        self.dateImageViewLabel = [
            .textAlignment(.center),
            .textOverflow(SingleLineFittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.bold.make(10))
        ]
        self.verticalInset = 8
        self.titleLabelLeadingInset = 20
        self.checkmarkImageSize = (40, 40)
        self.iconImageSize = (24, 24)
        self.dateImageVerticalInset = 18
        self.minimumHorizontalInset = 4
        self.dateImageLabelTopPadding = 4
    }
}

