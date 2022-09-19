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

//   AssetActionConfirmationLoadingViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AssetActionConfirmationLoadingViewTheme:
    StyleSheet,
    LayoutSheet {
    var contentEdgeInsets: NSDirectionalEdgeInsets
    var title: TextStyle
    var spacingBetweenTitleAndPrimaryName: CGFloat
    var primaryNameSize: CGSize
    var spacingBetweenPrimaryAndSecondaryName: CGFloat
    var secondaryNameSize: CGSize
    var spacingBetweenSecondaryNameAndSeparator: CGFloat
    var spacingBetweenSecondaryNameAndID: CGFloat
    var idSize: CGSize
    var spacingBetweenIDAndSeparator: CGFloat
    var spacingBetweenIDAndBody: CGFloat
    var body: TextStyle
    var bodyAccessory: ImageStyle
    var bodyAccessoryContentOffset: LayoutOffset
    var spacingBetweenBodyAndPrimaryAction: CGFloat
    var primaryAction: ButtonStyle
    var primaryActionContentEdgeInset: UIEdgeInsets
    var spacingBetweenPrimaryAndSecondaryAction: CGFloat
    var secondaryAction: ButtonStyle
    var secondaryActionContentEdgeInset: UIEdgeInsets
    var shimmeringCorner: Corner
    var separator: Separator

    init(_ family: LayoutFamily) {
        self.contentEdgeInsets = .init(top: 10, leading: 24, bottom: 16, trailing: 24)
        self.title = [
            .textAlignment(.center),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Fonts.DMSans.medium.make(15))
        ]
        self.spacingBetweenTitleAndPrimaryName = 46
        self.primaryNameSize = .init(width: 105, height: 36)
        self.spacingBetweenPrimaryAndSecondaryName = 6
        self.secondaryNameSize = .init(width: 67, height: 20)
        self.spacingBetweenSecondaryNameAndSeparator = 22
        self.spacingBetweenSecondaryNameAndID = 48
        self.idSize = .init(width: 105, height: 20)
        self.spacingBetweenIDAndSeparator = 26
        self.spacingBetweenIDAndBody = 48
        self.body = [
            .textColor(Colors.Helpers.negative),
            .font(Fonts.DMSans.medium.make(13)),
            .textAlignment(.left),
            .textOverflow(FittingText())
        ]
        self.bodyAccessory = [
            .contentMode(.left)
        ]
        self.bodyAccessoryContentOffset = (8, 0)
        self.spacingBetweenBodyAndPrimaryAction = 24
        self.primaryAction = [
            .backgroundImage([ .normal("components/buttons/primary/bg-disabled") ]),
            .font(Typography.bodyMedium()),
            .titleColor([ .normal(Colors.Button.Primary.disabledText) ])
        ]
        self.primaryActionContentEdgeInset = .init(top: 14, left: 0, bottom: 14, right: 0)
        self.spacingBetweenPrimaryAndSecondaryAction = 12
        self.secondaryAction = [
            .backgroundImage([ .normal("components/buttons/primary/bg-disabled") ]),
            .font(Typography.bodyMedium()),
            .titleColor([ .normal(Colors.Button.Primary.disabledText) ])
        ]
        self.secondaryActionContentEdgeInset = .init(top: 14, left: 0, bottom: 14, right: 0)
        self.shimmeringCorner = 4
        self.separator = Separator(color: Colors.Layer.grayLighter)
    }
}
