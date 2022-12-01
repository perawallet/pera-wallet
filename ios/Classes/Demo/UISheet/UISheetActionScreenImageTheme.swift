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

//   UISheetActionScreenImageTheme.swift

import Foundation
import MacaroonUIKit

struct UISheetActionScreenImageTheme:
    UISheetActionScreenTheme {
    let contextEdgeInsets: LayoutPaddings
    let image: ImageStyle
    let imageLayoutOffset: LayoutOffset
    let title: TextStyle
    let spacingBetweenTitleAndBody: LayoutMetric
    let body: TextStyle
    let actionSpacing: LayoutMetric
    let actionsEdgeInsets: LayoutPaddings
    let actionContentEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        self.contextEdgeInsets = (32, 24, 24, 24)
        self.image = [
            .contentMode(.top)
        ]
        self.imageLayoutOffset = (0, 16)
        self.title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Typography.bodyLargeMedium())
        ]
        self.spacingBetweenTitleAndBody = 12
        self.body = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
            .font(Typography.bodyRegular())
        ]
        self.actionSpacing = 16
        self.actionsEdgeInsets = (8, 24, 16, 24)
        self.actionContentEdgeInsets = (16, 24, 16, 24)
    }
}
