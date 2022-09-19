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
//   ButtonStyles.swift

import UIKit
import MacaroonUIKit

/// <todo>
/// Remove `ButtonStyles` from the project.
enum ButtonStyles {
    case primaryButton(title: String)
    case secondaryButton(title: String)

    func create() -> ButtonStyle {
        switch self {
        case let .primaryButton(title):
            return PrimaryButton(title: title).create()
        case let .secondaryButton(title):
            return SecondaryButton(title: title).create()
        }
    }
}

extension ButtonStyles {
    private struct PrimaryButton {
        let title: String

        func create() -> ButtonStyle {
            return [
                .title(title),
                .titleColor([
                    .normal(Colors.Button.Primary.text),
                    .disabled(Colors.Button.Primary.disabledText)
                ]),
                .font(Fonts.DMSans.medium.make(15)),
                .backgroundColor(Colors.Button.Primary.background)
            ]
        }
    }

    private struct SecondaryButton {
        let title: String

        func create() -> ButtonStyle {
            return [
                .title(title),
                .titleColor([
                    .normal(Colors.Button.Secondary.text),
                    .disabled(Colors.Button.Secondary.disabledText)
                ]),
                .font(Fonts.DMSans.medium.make(15)),
                .backgroundColor(Colors.Button.Secondary.background)
            ]
        }
    }
}
