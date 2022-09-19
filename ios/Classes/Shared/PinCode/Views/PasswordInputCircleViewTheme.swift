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
//   PasswordInputCircleViewTheme.swift

import MacaroonUIKit
import Foundation
import UIKit

struct PasswordInputCircleViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let imageSet: StateImageGroup
    let negativeTintColor: Color
    let contentMode: UIView.ContentMode

    let size: LayoutSize
    let corner: Corner

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        let filledButtonImage: Image = "black-button-filled"
        self.imageSet = [
            .normal("gray-button-border"),
            .highlighted(filledButtonImage),
            .selected(filledButtonImage),
            .disabled(filledButtonImage)
        ]
        self.negativeTintColor = Colors.Helpers.negative
        self.contentMode = .center

        self.size = (16, 16)
        self.corner = Corner(radius: size.h / 2)
    }
}
