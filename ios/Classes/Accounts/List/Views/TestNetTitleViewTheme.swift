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

//   TestNetTitleViewTheme.swift

import MacaroonUIKit

struct TestNetTitleViewTheme:
    LayoutSheet,
    StyleSheet {
    let titleLabel: TextStyle
    let testNetLabel: TextStyle

    let titleOffset: LayoutMetric
    let testNetLabelSize: LayoutSize
    let testNetLabelCorner: Corner

    init(_ family: LayoutFamily) {
        titleLabel = [
            .textOverflow(SingleLineFittingText()),
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(Colors.Text.main),
            .textAlignment(.left),
        ]
        testNetLabel = [
            .textOverflow(SingleLineFittingText()),
            .text("title-testnet".localized),
            .font(Fonts.DMSans.bold.make(11)),
            .textAlignment(.center),
            .textColor(Colors.Testnet.text),
            .backgroundColor(Colors.Testnet.background)
        ]
        
        titleOffset = -8
        testNetLabelSize = (63,  24)
        testNetLabelCorner = Corner(radius: testNetLabelSize.h / 2)
    }
}
