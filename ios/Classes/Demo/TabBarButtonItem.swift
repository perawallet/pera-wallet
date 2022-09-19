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
//   TabBarButtonItem.swift

import Foundation
import MacaroonUIKit
import UIKit

struct TabBarButtonItem: MacaroonUIKit.TabBarButtonItem {
    let style: ButtonStyle
    let spacingBetweenIconAndTitle: LayoutMetric

    init(
        icon: StateImageGroup?,
        title: String?,
        spacingBetweenIconAndTitle: LayoutMetric = 2
    ) {
        var style = ButtonStyle()

        if let icon = icon {
            style.icon = icon
        }

        if let title = title {
            style.title = title
            style.titleColor = [
                .normal(Colors.Text.grayLighter.uiColor),
                .selected(Colors.Text.main.uiColor),
                .disabled(
                    Colors.Text.grayLighter.uiColor.withAlphaComponent(0.5)
                )
            ]
            style.font =  Fonts.DMSans.medium.make(11).uiFont
        }

        self.style = style
        self.spacingBetweenIconAndTitle = spacingBetweenIconAndTitle
    }
}
