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

//   AdjustableSingleSelectionInputView.swift

import Foundation
import MacaroonForm
import MacaroonUIKit
import UIKit

final class AdjustableSingleSelectionInputView:
    MacaroonUIKit.BaseControl,
    FormInputFieldViewEditingDelegate {
    var textInputFormatter: MacaroonForm.TextInputFormatter? {
        get { textInputView.formatter }
        set { textInputView.formatter = newValue }
    }
    var textInputValidator: MacaroonForm.Validator? {
        get { textInputView.validator }
        set { textInputView.validator = newValue }
    }

    private(set) var value: Value?

    var isValid: Bool {
        switch textInputView.inputState {
        case .none, .focus: return true
        case .invalid, .incorrect: return false
        }
    }

    private var textInputOptionIndex: Int?

    private let selectionInputView: SegmentedControl
    private let textInputView: FloatingTextInputFieldView = .init()
    private let selectionInputScrollView: UIScrollView = .init()

    init(_ theme: AdjustableSingleSelectionInputViewTheme = .init()) {
        self.selectionInputView = SegmentedControl(theme.selectionInput)
        super.init(frame: .zero)

        addUI(theme)
    }

    func bind(_ viewModel: AdjustableSingleSelectionInputViewModel?) {
        textInputOptionIndex = viewModel?.customTextOptionIndex

        let customText = viewModel?.customText
        textInputView.text = customText

        let options = viewModel?.options ?? []
        selectionInputView.add(segments: options)

        let optionIndex = (viewModel?.selectedOptionIndex).unwrap(where: { $0 < options.count })
        let invalidOptionIndex = -1
        let selectedOptionIndex = optionIndex ?? invalidOptionIndex
        selectionInputView.selectedSegmentIndex = selectedOptionIndex

        if let text = customText.unwrapNonEmptyString() {
            value = .custom(text)
        } else if selectedOptionIndex != invalidOptionIndex {
            value = .option(selectedOptionIndex)
        } else {
            value = nil
        }
    }
}

extension AdjustableSingleSelectionInputView {
    func beginEditing() {
        textInputView.beginEditing()
    }

    func endEditing() {
        textInputView.endEditing()
    }
}

/// <mark>
/// FormInputFieldViewEditingDelegate
extension AdjustableSingleSelectionInputView {
    func formInputFieldViewDidBeginEditing(_ view: FormInputFieldView) {
        selectionInputView.selectedSegmentIndex = textInputOptionIndex ?? -1
    }

    func formInputFieldViewDidEdit(_ view: FormInputFieldView) {
        notifyForTextInputChange()
    }

    func formInputFieldViewDidEndEditing(_ view: FormInputFieldView) {}
}

extension AdjustableSingleSelectionInputView {
    private func addUI(_ theme: AdjustableSingleSelectionInputViewTheme) {
        addTextInput(theme)
        addSelectionInput(theme)
    }

    private func addTextInput(_ theme: AdjustableSingleSelectionInputViewTheme) {
        textInputView.customize(theme.textInput)

        addSubview(textInputView)
        textInputView.snp.makeConstraints {
            $0.greaterThanHeight(theme.textInputMinHeight)
            $0.top == theme.contentEdgeInsets.top
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
        }

        textInputView.editingDelegate = self
    }

    private func addSelectionInput(_ theme: AdjustableSingleSelectionInputViewTheme) {
        var contentInset = theme.selectionInputContentInset
        contentInset.left += theme.contentEdgeInsets.leading
        contentInset.right += theme.contentEdgeInsets.trailing

        addSubview(selectionInputScrollView)
        selectionInputScrollView.showsHorizontalScrollIndicator = false
        selectionInputScrollView.showsVerticalScrollIndicator = false
        selectionInputScrollView.alwaysBounceVertical = false
        selectionInputScrollView.contentInset = contentInset
        selectionInputScrollView.snp.makeConstraints {
            $0.top == textInputView.snp.bottom + theme.spacingBetweenTextInputAndSelectionInput
            $0.leading == 0
            $0.bottom == theme.contentEdgeInsets.bottom
            $0.trailing == 0
        }

        selectionInputScrollView.addSubview(selectionInputView)
        selectionInputView.snp.makeConstraints {
            /// <workaround>
            /// Since the scroll views don't have an intrinsic size, the layout adjustments below
            /// will make the height of the scroll view matches with the input view plus content
            /// inset.
            $0.top == 0
            $0.top == textInputView.snp.bottom +
                theme.spacingBetweenTextInputAndSelectionInput +
                theme.selectionInputContentInset.top ~ .defaultHigh
            $0.leading == 0
            $0.bottom == 0
            $0.bottom == self - theme.selectionInputContentInset.bottom ~ .defaultHigh
            $0.trailing == 0
        }

        selectionInputView.addTarget(
            self,
            action: #selector(notifyForSelectionInputChange),
            for: .valueChanged
        )
    }
}

extension AdjustableSingleSelectionInputView {
    @objc
    private func notifyForTextInputChange() {
        value = textInputView.text
            .unwrapNonEmptyString()
            .unwrap { .custom($0) }

        validateTextInputChange()
        notifyForValueChange()
    }

    @objc
    private func notifyForSelectionInputChange() {
        let selectedOptionIndex = selectionInputView.selectedSegmentIndex

        if selectedOptionIndex == textInputOptionIndex {
            notifyForTextInputChange()
            beginEditing()

            return
        }

        value = .option(selectedOptionIndex)

        textInputView.text = nil
        textInputView.inputState = .none

        notifyForValueChange()
    }

    private func notifyForValueChange() {
        sendActions(for: .valueChanged)
    }
}

extension AdjustableSingleSelectionInputView {
    private func validateTextInputChange() {
        let validation = textInputValidator?.validate(textInputView)
        switch validation {
        case .none: textInputView.inputState = .none
        case .success: textInputView.inputState = .none
        case .failure(let error): textInputView.inputState = .invalid(error)
        }
    }
}

extension AdjustableSingleSelectionInputView {
    enum Value {
        case custom(String)
        case option(Int)
    }
}
