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
//   ViewFactory.swift

import UIKit

/// <todo>
/// Remove `ViewFactory` from the project.
enum ViewFactory {
    enum Button { }
}

extension ViewFactory.Button {
    static func makePrimaryButton(_ title: String) -> UIButton {
        let button = UIButton()
        button.customizeAppearance(ButtonStyles.primaryButton(title: title).create())
        button.contentEdgeInsets = UIEdgeInsets((14, 0, 14, 0))
        button.layer.cornerRadius = 4
        return button
    }

    static func makeSecondaryButton(_ title: String) -> UIButton {
        let button = UIButton()
        button.customizeAppearance(ButtonStyles.secondaryButton(title: title).create())
        button.contentEdgeInsets = UIEdgeInsets((14, 0, 14, 0))
        button.layer.cornerRadius = 4
        return button
    }
}
