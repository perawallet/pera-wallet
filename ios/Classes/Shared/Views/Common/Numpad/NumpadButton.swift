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
//  NumpadButton.swift

import UIKit
import MacaroonUIKit
import MacaroonUtils
import Foundation

final class NumpadButton: UIButton {
    override var intrinsicContentSize: CGSize {
        return CGSize(theme.size)
    }

    private lazy var theme = NumpadButtonViewTheme()

    private(set) var numpadKey: NumpadKey
    
    init(numpadKey: NumpadKey) {
        self.numpadKey = numpadKey
        super.init(frame: .zero)
        
        customize(theme)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func customize(_ theme: NumpadButtonViewTheme) {
        setBackgroundImage(theme.buttonBackgroundHighlightedImage.image?.uiImage, for: .highlighted)

        switch numpadKey {
        case .number(let value):
            customizeAppearance(theme.button)
            customizeBaseAppearance(title: value)
        case .delete:
            if let image = theme.deleteImage.image {
                customizeBaseAppearance(icon: [.normal(image)])
            } else {
                customizeBaseAppearance(icon: nil)
            }
        case .spacing:
            break
        case .decimalSeparator:
            customizeAppearance(theme.button)
            customizeBaseAppearance(title: Locale.current.decimalSeparator ?? ".")
        }
    }

    func customizeAppearance(_ styleSheet: NumpadButtonViewTheme) {}

    func prepareLayout(_ layoutSheet: NumpadButtonViewTheme) {}
}

extension NumpadButton {
    enum NumpadKey: Equatable {
        case spacing
        case number(String)
        case delete
        case decimalSeparator

        static func == (lhs: NumpadKey, rhs: NumpadKey) -> Bool {
            switch (lhs, rhs) {
            case (.spacing, .spacing):
                return true
            case (.delete, .delete):
                return true
            case (.decimalSeparator, .decimalSeparator):
                return true
            case (.number(let lNumber), .number(let rNumber)):
                return lNumber == rNumber
            default:
                return false
            }

        }
    }
}
