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
//   NumpadButtonViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct NumpadButtonViewTheme: StyleSheet, LayoutSheet {
    let deleteImage: ImageStyle
    let button: ButtonStyle
    let buttonBackgroundHighlightedImage: ImageStyle

    let size: LayoutSize

    init(_ family: LayoutFamily) {
        self.deleteImage = [
            .image("icon-delete-number")
        ]
        self.button = [
            .backgroundColor(Colors.Defaults.background),
            .font(Fonts.DMMono.regular.make(24).uiFont),
            .titleColor([.normal(Colors.Button.Ghost.text.uiColor)])
        ]
        self.buttonBackgroundHighlightedImage = [
            .image("bg-passcode-number-selected")
        ]

        self.size = (72 * verticalScale, 72 * verticalScale)
    }
}
