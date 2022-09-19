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
//   SearchInputViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol SearchInputViewTheme: LayoutSheet, StyleSheet {
    var textInput: TextInputStyle { get }
    var textInputBackground: ViewStyle { get }
    var textLeftInputAccessory: ImageStyle { get }
    var textRightInputAccessory: ButtonStyle? { get }
    var textClearInputAccessory: ButtonStyle { get }

    var intrinsicHeight: LayoutMetric { get }
    var textInputContentEdgeInsets: LayoutPaddings { get }
    var textInputPaddings: LayoutPaddings { get }
    var textInputAccessorySize: LayoutSize { get }
    var textRightInputAccessoryViewPaddings: LayoutPaddings { get }
    var textRightInputAccessoryViewMode: UITextField.ViewMode { get }
    var placeholder: String { get }
}

struct SearchInputViewCommonTheme: SearchInputViewTheme {
    let textInput: TextInputStyle
    let textInputBackground: ViewStyle
    let textLeftInputAccessory: ImageStyle
    let textRightInputAccessory: ButtonStyle?
    let textClearInputAccessory: ButtonStyle

    let intrinsicHeight: LayoutMetric
    let textInputContentEdgeInsets: LayoutPaddings
    let textInputPaddings: LayoutPaddings
    let textInputAccessorySize: LayoutSize
    let textRightInputAccessoryViewPaddings: LayoutPaddings
    let textRightInputAccessoryViewMode: UITextField.ViewMode
    let placeholder: String

    init(placeholder: String, family: LayoutFamily) {
        self.placeholder = placeholder

        self.textInput = [
            .tintColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(13)),
            .textColor(Colors.Text.main),
            .placeholder(placeholder),
            .placeholderColor(Colors.Text.gray),
            .returnKeyType(.search),
            .autocorrectionType(.no),
            .autocapitalizationType(.none)
        ]
        self.textInputBackground = [
            .backgroundColor(Colors.Layer.grayLighter)
        ]
        self.textLeftInputAccessory = [
            .image("icon-field-search")
        ]
        self.textRightInputAccessory = nil

        self.intrinsicHeight = 40
        self.textInputContentEdgeInsets = (0, 12, 0, 12)
        self.textInputPaddings = (0, 0, 0, 0)
        self.textInputAccessorySize = (24, 24)
        self.textRightInputAccessoryViewPaddings = (0, .noMetric, 0, 12)
        self.textRightInputAccessoryViewMode = .whileEditing
        self.textClearInputAccessory = [
            .icon([.normal("icon-field-close")])
        ]
    }

    init(_ family: LayoutFamily) {
        self.init(placeholder: .empty, family: family)
    }
}

struct QRSearchInputViewTheme: SearchInputViewTheme {
    let textInput: TextInputStyle
    let textInputBackground: ViewStyle
    let textLeftInputAccessory: ImageStyle
    let textRightInputAccessory: ButtonStyle?
    let textClearInputAccessory: ButtonStyle

    let intrinsicHeight: LayoutMetric
    let textInputContentEdgeInsets: LayoutPaddings
    let textInputPaddings: LayoutPaddings
    let textInputAccessorySize: LayoutSize
    let textRightInputAccessoryViewPaddings: LayoutPaddings
    let textRightInputAccessoryViewMode: UITextField.ViewMode
    let placeholder: String

    init(placeholder: String, family: LayoutFamily) {
        self.placeholder = placeholder

        self.textInput = [
            .tintColor(Colors.Text.main),
            .font(Fonts.DMSans.regular.make(13)),
            .textColor(Colors.Text.main),
            .placeholder(placeholder),
            .placeholderColor(Colors.Text.gray),
            .autocorrectionType(.no),
            .textContentType(.username),
            .returnKeyType(.done),
            .autocapitalizationType(.none)
        ]
        self.textInputBackground = [
            .backgroundColor(Colors.Layer.grayLighter)
        ]
        self.textLeftInputAccessory = [
            .image("icon-field-search")
        ]
        self.textRightInputAccessory = [
            .icon([.normal("icon-qr-scan")])
        ]

        self.intrinsicHeight = 40
        self.textInputContentEdgeInsets = (0, 12, 0, 12)
        self.textInputPaddings = (0, 0, 0, 0)
        self.textInputAccessorySize = (24, 24)
        self.textRightInputAccessoryViewPaddings = (0, .noMetric, 0, 12)
        self.textRightInputAccessoryViewMode = .whileEditing
        self.textClearInputAccessory = [
            .icon([.normal("icon-field-close")])
        ]
    }

    init(_ family: LayoutFamily) {
        self.init(placeholder: .empty, family: family)
    }
}
