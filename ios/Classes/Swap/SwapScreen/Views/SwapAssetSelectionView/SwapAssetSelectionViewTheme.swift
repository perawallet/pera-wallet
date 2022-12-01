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

//   SwapAssetSelectionViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SwapAssetSelectionViewTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let corner: Corner
    let contentPaddings: LayoutPaddings
    let title: TextStyle
    let verificationTier: ImageStyle
    let verificationTierContentEdgeInsets: LayoutOffset
    let accessory: ImageStyle
    let accessoryContentEdgeInsets: LayoutOffset

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Layer.grayLightest)
        ]
        self.corner = Corner(radius: 16)
        self.contentPaddings = (12, 12, 12, 12)
        self.title = [
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineText())
        ]
        self.verificationTier = [
            .contentMode(.right),
        ]
        self.verificationTierContentEdgeInsets = (6, 0)
        self.accessory = [
            .contentMode(.right)
        ]
        self.accessoryContentEdgeInsets = (8, 0)
    }
}
