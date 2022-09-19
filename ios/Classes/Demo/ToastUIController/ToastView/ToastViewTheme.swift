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

//   ToastViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ToastViewTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var contentPaddings: UIEdgeInsets
    var title: TextStyle
    var body: TextStyle
    var bodyPaddings: UIEdgeInsets

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Toast.background)
        ]
        self.contentPaddings = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        self.title = [
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(Colors.Toast.title),
            .textAlignment(.center),
            .textOverflow(FittingText(lineBreakMode: .byWordWrapping))
        ]
        self.body = [
            .font(Fonts.DMSans.regular.make(13)),
            .textColor(Colors.Toast.description),
            .textAlignment(.center),
            .textOverflow(FittingText(lineBreakMode: .byWordWrapping))
        ]
        self.bodyPaddings = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
    }
}

extension ToastViewTheme {
    func configuredForSingleLineBody(
        _ lineBreakMode: NSLineBreakMode = .byTruncatingMiddle
    ) -> ToastViewTheme {
        var theme = ToastViewTheme()
        theme.body.textOverflow = SingleLineText(lineBreakMode: lineBreakMode)
        return theme
    }
}
