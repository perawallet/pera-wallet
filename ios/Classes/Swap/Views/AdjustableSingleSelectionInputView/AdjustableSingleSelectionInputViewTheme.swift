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

//   AdjustableSingleSelectionInputViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AdjustableSingleSelectionInputViewTheme:
    StyleSheet,
    LayoutSheet {
    var contentEdgeInsets: NSDirectionalEdgeInsets
    var textInput: FloatingTextInputFieldViewTheme
    var textInputMinHeight: CGFloat
    var selectionInput: SegmentedControlTheme
    var selectionInputContentInset: UIEdgeInsets
    var spacingBetweenTextInputAndSelectionInput: CGFloat

    init(
        textInputPlaceholder: String?,
        textInputFloatingPlaceholder: String? = nil,
        family: LayoutFamily = .current
    ) {
        self.contentEdgeInsets = .zero
        self.textInput = FloatingTextInputFieldViewCommonTheme(
            textInput: [
                .autocorrectionType(.no),
                .clearButtonMode(.never),
                .font(Typography.bodyRegular()),
                .keyboardType(.decimalPad),
                .textColor(Colors.Text.main),
                .tintColor(Colors.Text.main)
            ],
            placeholder: textInputPlaceholder.someString,
            floatingPlaceholder: textInputFloatingPlaceholder,
            family
        )
        self.textInputMinHeight = 52
        self.selectionInput = SingleSelectionInputViewTheme(family)
        self.selectionInputContentInset = .init(top: 6, left: 0, bottom: 6, right: 0)
        self.spacingBetweenTextInputAndSelectionInput = 22
    }

    init(_ family: LayoutFamily) {
        self.init(
            textInputPlaceholder: nil,
            family: family
        )
    }
}

struct SingleSelectionInputViewTheme: SegmentedControlTheme {
    var background: ImageStyle?
    var divider: ImageStyle?
    var spacingBetweenSegments: CGFloat

    init(_ family: LayoutFamily) {
        self.background = nil
        self.divider = nil
        self.spacingBetweenSegments = 12
    }
}
