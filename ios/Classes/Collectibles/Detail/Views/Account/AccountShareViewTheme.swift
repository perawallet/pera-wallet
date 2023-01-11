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

//   AccountShareViewTheme.swift

import MacaroonUIKit

struct AccountShareViewTheme:
    StyleSheet,
    LayoutSheet {
    let image: ImageStyle
    let name: TextStyle
    let copy: ButtonStyle
    let shareQR: ButtonStyle

    let imageSize: LayoutSize
    let buttonSize: LayoutSize
    let verticalInset: LayoutMetric
    let nameHorizontalPaddings: LayoutHorizontalPaddings

    init(
        _ family: LayoutFamily
    ) {
        image = [
            .contentMode(.center)
        ]
        name = [
            .textOverflow(SingleLineText()),
            .textAlignment(.left),
            .textColor(Colors.Text.main)
        ]
        copy = [
            .icon([.normal("icon-copy-24")]),
            .backgroundImage([.highlighted("icon-24-selected-bg")])
        ]
        shareQR = [
            .icon([.normal("icon-qr-code-24")])
        ]

        imageSize = (40, 40)
        buttonSize = (40, 40)
        verticalInset = 12
        nameHorizontalPaddings = (16, 4)
    }
}
