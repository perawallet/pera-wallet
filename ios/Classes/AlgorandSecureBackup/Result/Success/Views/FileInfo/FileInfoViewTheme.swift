// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   FileInfoViewTheme.swift

import Foundation
import MacaroonUIKit

struct FileInfoViewTheme:
    LayoutSheet,
    StyleSheet {
    var contentFirstShadow: MacaroonUIKit.Shadow
    var contentSecondShadow: MacaroonUIKit.Shadow
    var contentThirdShadow: MacaroonUIKit.Shadow
    var contentPaddings: LayoutPaddings
    var icon: ImageStyle
    var spacingBetweenIconAndInfoContent: LayoutMetric
    var infoName: TextStyle
    var spacingBetweenInfoNameAndInfoSize: LayoutMetric
    var infoSize: TextStyle
    var spacingBetweenInfoContentAndCopyAccessory: LayoutMetric
    var copyAccessory: ButtonStyle

    init(
        _ family: LayoutFamily
    ) {
        self.contentFirstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            spread: 1,
            cornerRadii: (20, 20),
            corners: .allCorners
        )
        self.contentSecondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: 0,
            cornerRadii: (20, 20),
            corners: .allCorners
        )
        self.contentThirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: -1,
            cornerRadii: (20, 20),
            corners: .allCorners
        )
        self.contentPaddings = (20, 20, 20, 20)
        self.icon = []
        self.spacingBetweenIconAndInfoContent = 16
        self.infoName = [
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineText()),
        ]
        self.spacingBetweenInfoNameAndInfoSize = 4
        self.infoSize = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText()),
        ]
        self.spacingBetweenInfoContentAndCopyAccessory = 16
        self.copyAccessory = [
            .backgroundImage([ .normal("icon-copy-circle"), .highlighted("icon-copy-circle")])
        ]
    }
}
