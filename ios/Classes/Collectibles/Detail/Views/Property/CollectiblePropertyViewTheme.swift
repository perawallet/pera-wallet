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

//   CollectiblePropertyViewTheme.swift

import MacaroonUIKit

struct CollectiblePropertyViewTheme:
    StyleSheet,
    LayoutSheet {
    let name: TextStyle
    let value: TextStyle
    let corner: Corner
    let border: Border

    let horizontalInset: LayoutMetric
    let verticallInset: LayoutMetric
    let labelPadding: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.name = [
            .textOverflow(SingleLineText()),
            .textAlignment(.left),
            .textColor(Colors.Text.gray)
        ]
        self.value = [
            .textOverflow(SingleLineText()),
            .textAlignment(.left),
            .textColor(Colors.Text.main)
        ]
        self.corner = Corner(radius: 8)
        self.border = Border(
            color: Colors.Layer.grayLighter.uiColor,
            width: 2
        )

        self.horizontalInset = 16
        self.verticallInset = 8
        self.labelPadding = 4
    }
}
