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
//   EditNoteScreenTheme.swift


import Foundation
import MacaroonUIKit

struct EditNoteScreenTheme:
    LayoutSheet,
    StyleSheet {
    let background: ViewStyle
    let contentEdgeInsets: LayoutPaddings
    let noteInput: MultilineTextInputFieldViewTheme
    let noteInputMinHeight: LayoutMetric

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contentEdgeInsets = (16, 24, 24, 24)
        let textInputBaseStyle: TextInputStyle = [
            .font(Typography.bodyRegular()),
            .tintColor(Colors.Text.main),
            .textColor(Colors.Text.main),
            .returnKeyType(.done),
        ]
        var noteInput = MultilineTextInputFieldViewCommonTheme(
            textInput: textInputBaseStyle,
            placeholder: "edit-note-note-explanation".localized,
            floatingPlaceholder: "edit-note-note-explanation".localized
        )
        noteInput.textContainerInsets.trailing = .zero
        self.noteInput = noteInput
        self.noteInputMinHeight = 48
    }
}
