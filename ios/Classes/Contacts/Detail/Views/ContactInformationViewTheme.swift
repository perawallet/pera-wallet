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
//   ContactInformationViewTheme.swift

import MacaroonUIKit

struct ContactInformationViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let nameLabel: TextStyle
    let accountShortAddressLabel: TextStyle
    let accountAddressTitleLabel: TextStyle
    let accountAddressValueLabel: TextStyle
    let qrCode: ButtonStyle
    let divider: ViewStyle
    let imageViewCorner: Corner

    let nameLabelTopPadding: LayoutMetric
    let shortAccountAddressLabelTopPadding: LayoutMetric
    let dividerVerticalPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let accountAddressValueLabelPaddings: LayoutPaddings
    let qrButtonTopPadding: LayoutMetric
    let dividerHeight: LayoutMetric
    let imageViewSize: LayoutSize

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.nameLabel = [
            .textOverflow(FittingText()),
            .textAlignment(.center),
            .font(Fonts.DMSans.medium.make(19)),
            .textColor(Colors.Text.main)
        ]
        self.accountShortAddressLabel = [
            .textOverflow(FittingText()),
            .textAlignment(.center),
            .font(Fonts.DMMono.regular.make(13)),
            .textColor(Colors.Text.grayLighter)
        ]
        self.accountAddressTitleLabel = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(Colors.Text.main),
            .text("contacts-info-address".localized)
        ]
        self.accountAddressValueLabel = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .font(Fonts.DMMono.regular.make(15)),
            .textColor(Colors.Text.main)
        ]
        self.qrCode = [
            .icon([.normal("icon-qr")]),
            .tintColor(Colors.Text.main)
        ]
        self.divider = [
            .backgroundColor(Colors.Layer.grayLighter)
        ]
        self.imageViewCorner = Corner(radius: 40)

        self.imageViewSize = (80, 80)
        self.nameLabelTopPadding = 20
        self.shortAccountAddressLabelTopPadding = 4
        self.dividerVerticalPadding = 32
        self.horizontalPadding = 24
        self.accountAddressValueLabelPaddings = (8, 0, 0, 68)
        self.qrButtonTopPadding = 60
        self.dividerHeight = 1
    }
}
