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
//   EditNoteView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class EditNoteView: View {
    weak var delegate: EditNoteViewDelegate?

    private(set) lazy var noteInputView = createNoteTextInput(
        placeholder: "edit-note-note-explanation".localized,
        floatingPlaceholder: "edit-note-note-explanation".localized
    )

    private(set) lazy var doneButton = MacaroonUIKit.Button()

    func customize(_ theme: EditNoteViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addNoteInputView(theme)
        addDoneButton(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension EditNoteView {
    private func addNoteInputView(_ theme: EditNoteViewTheme) {
        addSubview(noteInputView)
        noteInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalToSuperview().offset(theme.verticalPadding)
        }
    }

    private func addDoneButton(_ theme: EditNoteViewTheme) {
        doneButton.contentEdgeInsets = UIEdgeInsets(theme.doneButtonContentEdgeInsets)
        doneButton.draw(corner: theme.doneButtonCorner)
        doneButton.customizeAppearance(theme.doneButton)
        
        addSubview(doneButton)
        doneButton.fitToVerticalIntrinsicSize()
        doneButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.greaterThanOrEqualTo(noteInputView.snp.bottom).offset(theme.verticalPadding)
            $0.bottom.equalToSuperview().inset(theme.verticalPadding + safeAreaBottom)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
}

extension EditNoteView {
    func createNoteTextInput(
        placeholder: String,
        floatingPlaceholder: String?
    ) -> MultilineTextInputFieldView {
        let view = MultilineTextInputFieldView()
        let textInputBaseStyle: TextInputStyle = [
            .font(Fonts.DMSans.regular.make(15, .body)),
            .tintColor(Colors.Text.main),
            .textColor(Colors.Text.main),
            .returnKeyType(.done)
        ]

        let theme =
            MultilineTextInputFieldViewCommonTheme(
                textInput: textInputBaseStyle,
                placeholder: placeholder,
                floatingPlaceholder: floatingPlaceholder
            )
        view.delegate = self
        view.customize(theme)
        view.snp.makeConstraints {
            $0.greaterThanHeight(48)
        }
        return view
    }
}

extension EditNoteView {
    func bindData(_ note: String?) {
        noteInputView.text = note
    }
}

extension EditNoteView {
    func beginEditing() {
        noteInputView.beginEditing()
    }

    func endEditing() {
        noteInputView.endEditing()
    }
}

extension EditNoteView: MultilineTextInputFieldViewDelegate {
    func multilineTextInputFieldViewDidReturn(_ view: MultilineTextInputFieldView) {
        view.endEditing()
        delegate?.editNoteViewDidReturn(self)
    }
}

protocol EditNoteViewDelegate: AnyObject {
    func editNoteViewDidReturn(_ editNoteView: EditNoteView)
}
