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
//   FloatingTextInputFieldView.swift

import Foundation
import MacaroonUIKit
import SnapKit
import UIKit
import MacaroonForm

class FloatingTextInputFieldView: View, FormTextInputFieldView, UITextFieldDelegate {
    weak var delegate: FloatingTextInputFieldViewDelegate?
    weak var editingDelegate: FormInputFieldViewEditingDelegate?

    var inputState: FormInputFieldState = .none {
        didSet { inputStateDidChange() }
    }

    var text: String? {
        get { textInputView.text }
        set {
            update(
                replacementString: newValue.someString,
                animated: false
            )
        }
    }
    var inputProvider: UIView? {
        get { textInputView.inputView }
        set { textInputView.inputView = newValue }
    }
    var inputProviderAccessory: UIView? {
        get { textInputView.inputAccessoryView }
        set { textInputView.inputAccessoryView = newValue }
    }
    var rightAccessory: TextFieldAccessory? {
        get { textInputView.rightAccessory }
        set { textInputView.rightAccessory = newValue }
    }

    var formatter: MacaroonForm.TextInputFormatter?
    var maskFormatter: MacaroonForm.TextInputFormatter?
    var validator: Validator?

    var isEnabled = true
    var alwaysFloatsOnEditing = true

    var unformattedText: String? {
        guard let formatter = formatter else {
            return text
        }

        return formatter.unformat(
            text
        )
    }

    var inputType: FormInputType  {
        return .keyboard
    }
    var isEditing: Bool {
        return textInputView.isEditing
    }

    private lazy var textInputView = TextField()
    private lazy var textInputMaskView = TextField()
    private lazy var placeholderView = Label()
    private lazy var focusIndicatorView = UIImageView()
    private lazy var accessoryView = Button()
    private lazy var assistiveView = FormInputFieldAssistiveView()

    private var placeholderViewCenterYConstraint: Constraint?
    private var placeholderViewTopConstraint: Constraint?

    private var theme: FloatingTextInputFieldViewTheme?

    private var isLayoutFinalized = false

    override init(
        frame: CGRect
    ) {
        super.init(
            frame: frame
        )

        setListeners()
        linkInteractors()
    }

    func customize(
        _ theme: FloatingTextInputFieldViewTheme
    ) {
        self.theme = theme

        customizeTextInputAppearance(
            theme
        )
        customizePlaceholderAppearance(
            theme
        )
        customizeFocusIndicatorAppearance(
            theme
        )
        customizeAssistiveAppearance(
            theme
        )

        recustomizeAppearanceWhenStyleSheetDidChange()

        addTextInput(
            theme
        )
        addPlaceholder(
            theme
        )
        addFocusIndicator(
            theme
        )
        addAssistive(
            theme
        )

        updateLayoutWhenLayoutSheetDidChange()
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func setListeners() {
        textInputView.delegate = self
    }

    func linkInteractors() {
        focusIndicatorView.isUserInteractionEnabled = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.isEmpty {
            return
        }

        /// <warning>
        /// Otherwise it intervenes the layout process of other states, i.e. animations.
        if !isLayoutFinalized {
            isLayoutFinalized = true

            /// <note>
            /// The position of the text input view depends on the placeholder bounds if it is first
            /// loaded on editing mode.
            if !textInputView.text.isNilOrEmpty {
                updateTextInputLayoutOnEditing()
            }
        }
    }

    /// <mark>
    /// UITextFieldDelegate
    func textFieldDidBeginEditing(
        _ textField: UITextField
    ) {
        if alwaysFloatsOnEditing,
           textField.text.someString.isEmpty {
            textWillEdit(
                animated: true
            )
        }

        editingDelegate?.formInputFieldViewDidBeginEditing(
            self
        )
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let isUpdated =
            update(
                changingCharactersIn: range,
                replacementString: string,
                animated: true
            )

        if isUpdated {
            editingDelegate?.formInputFieldViewDidEdit(
                self
            )
        }

        return false
    }

    func textFieldShouldClear(
        _ textField: UITextField
    ) -> Bool {
        let isUpdated =
            update(
                replacementString: "",
                animated: true
            )

        if !isUpdated {
            return false
        }

        editingDelegate?.formInputFieldViewDidEdit(
            self
        )

        return false
    }

    func textFieldShouldReturn(
        _ textField: UITextField
    ) -> Bool {
        guard let delegate = delegate else {
            return true
        }

        return delegate.floatingTextInputFieldViewShouldReturn(
            self
        )
    }

    func textFieldDidEndEditing(
        _ textField: UITextField
    ) {
        editingDelegate?.formInputFieldViewDidEndEditing(
            self
        )

        if alwaysFloatsOnEditing,
           textField.text.someString.isEmpty {
            textWillClear(
                animated: true
            )
        }
    }
}

extension FloatingTextInputFieldView {
    func beginEditing() {
        textInputView.becomeFirstResponder()
    }

    func endEditing() {
        textInputView.resignFirstResponder()
    }

    func shiftCaretToPositionFromStart(
        byOffset offset: Int
    ) {
        textInputView.shiftCaretToPositionFromStart(
            byOffset: offset
        )
    }
}

extension FloatingTextInputFieldView {
    private func inputStateDidChange() {
        switch inputState {
        case .none,
             .focus:
            updateFocusIndicatorAppearanceOnSuccess()
            assistiveView.editError = nil
        case .invalid(let validationError):
            updateFocusIndicatorAppearanceOnFailure()
            assistiveView.editError = validator?.getMessage(for: validationError)
        case .incorrect(let error):
            updateFocusIndicatorAppearanceOnFailure()
            assistiveView.editError = error
        }
    }
}

extension FloatingTextInputFieldView {
    private func textWillChange(
        _ newText: String,
        animated: Bool
    ) {
        let currentText = textInputView.text.someString

        switch (currentText.isEmpty, newText.isEmpty) {
        case (true, false):
            textWillEdit(
                animated: animated
            )
        case (false, true) where !alwaysFloatsOnEditing:
            textWillClear(
                animated: animated
            )
        default:
            break
        }
    }

    private func textWillEdit(
        animated: Bool
    ) {
        if !animated {
            recustomizePlaceholderAppearanceOnEditing()
            recustomizeFocusIndicatorOnEdit()
            updateLayoutOnEditing()

            return
        }

        recustomizeFocusIndicatorOnEdit()
        recustomizePlaceholderAppearanceOnEditing()
        /// <note>
        /// Update the placeholder view size immediately after the font change to prevent the
        /// glitch in the animation.
        layoutIfNeededInParent()

        updateLayoutOnEditing()

        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.1,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                [unowned self] in

                self.layoutIfNeeded()
            },
            completion: nil
        )
    }

    private func textWillClear(
        animated: Bool
    ) {
        if !animated {
            recustomizePlaceholderAppearanceOnClear()
            recustomizeFocusIndicatorOnClear()
            updateLayoutOnClear()

            return
        }

        recustomizeFocusIndicatorOnClear()
        recustomizePlaceholderAppearanceOnClear()
        /// <note>
        /// Update the placeholder view size immediately after the font change to prevent the
        /// glitch in the animation.
        layoutIfNeededInParent()

        updateLayoutOnClear()

        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.1,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                [unowned self] in

                self.layoutIfNeeded()
            },
            completion: nil
        )
    }
}

extension FloatingTextInputFieldView {
    private func recustomizeAppearanceWhenStyleSheetDidChange() {
        textInputView.text.isNilOrEmpty
            ? recustomizePlaceholderAppearanceOnClear()
            : recustomizePlaceholderAppearanceOnEditing()
    }

    private func customizeTextInputAppearance(
        _ styleSheet: FloatingTextInputFieldViewTheme
    ) {
        textInputView.customizeAppearance(
            styleSheet.textInput
        )
        textInputMaskView.customizeAppearance(
            styleSheet.textInputMask
        )
    }

    private func customizePlaceholderAppearance(
        _ styleSheet: FloatingTextInputFieldViewTheme
    ) {
        placeholderView.customizeAppearance(
            styleSheet.placeholder
        )
    }

    private func recustomizePlaceholderAppearanceOnEditing() {
        guard let theme = theme else {
            return
        }

        placeholderView.customizeAppearance(theme.floatingPlaceholder)
    }

    private func recustomizePlaceholderAppearanceOnClear() {
        guard let theme = theme else {
            return
        }

        customizePlaceholderAppearance(theme)
    }

    private func customizeFocusIndicatorAppearance(
        _ styleSheet: FloatingTextInputFieldViewTheme
    ) {
        focusIndicatorView.customizeAppearance(
            styleSheet.focusIndicator
        )
    }
    
    private func recustomizeFocusIndicatorOnEdit() {
        if let style = theme?.focusIndicatorActive {
            focusIndicatorView.customizeAppearance(style)
        }
    }
    
    private func recustomizeFocusIndicatorOnClear() {
        guard let theme = theme else {
            return
        }
        
        focusIndicatorView.customizeAppearance(theme.focusIndicator)
    }

    private func updateFocusIndicatorAppearanceOnSuccess() {
        if let style = theme?.focusIndicator {
            focusIndicatorView.customizeAppearance(style)
        }
    }

    private func updateFocusIndicatorAppearanceOnFailure() {
        if let style = theme?.errorFocusIndicator {
            focusIndicatorView.customizeAppearance(style)
        }
    }

    private func customizeAssistiveAppearance(
        _ styleSheet: FloatingTextInputFieldViewTheme
    ) {
        assistiveView.customize(
            styleSheet.assistive
        )
    }
}

extension FloatingTextInputFieldView {
    private func updateLayoutWhenLayoutSheetDidChange() {
        if textInputView.text.isNilOrEmpty {
            updateTextInputLayoutOnClear()
            updatePlaceholderLayoutOnClear()
        } else {
            updateTextInputLayoutOnEditing()
            updatePlaceholderLayoutOnEditing()
        }
    }

    private func updateLayoutOnEditing() {
        updateTextInputLayoutOnEditing()
        updatePlaceholderLayoutOnEditing()
        updateFocusIndicatorLayoutOnEditing()
    }

    private func updateLayoutOnClear() {
        updateTextInputLayoutOnClear()
        updatePlaceholderLayoutOnClear()
        updateFocusIndicatorLayoutOnClear()
    }

    private func addTextInput (
        _ layoutSheet: FloatingTextInputFieldViewTheme
    ) {
        addSubview(
            textInputView
        )
        textInputView.contentEdgeInsets = (0, 0, 0, 0)
        textInputView.textEdgeInsets = (0, 0, 0, 0)
        textInputView.snp.makeConstraints {
            $0.greaterThanHeight(layoutSheet.textInputMinHeight)
            $0.setPaddings((0, 0, .noMetric, 0))
        }

        addTextInputMask(
            layoutSheet
        )
    }

    private func addTextInputMask(
        _ layoutSheet: FloatingTextInputFieldViewTheme
    ) {
        insertSubview(
            textInputMaskView,
            belowSubview: textInputView
        )
        textInputMaskView.isUserInteractionEnabled = false
        textInputMaskView.contentEdgeInsets = (0, 0, 0, 0)
        textInputMaskView.textEdgeInsets = (0, 0, 0, 0)
        textInputMaskView.snp.makeConstraints {
            $0.top == textInputView.snp.top
            $0.leading == textInputView.snp.leading
            $0.bottom == textInputView.snp.bottom
            $0.trailing == textInputView.snp.trailing
        }
    }

    private func updateTextInputLayoutOnEditing() {
        if placeholderView.bounds.isEmpty {
            return
        }

        let topPaddingOnEditing = placeholderView.bounds.height

        if textInputView.contentEdgeInsets.top == topPaddingOnEditing {
            return
        }

        var newContentEdgeInsets = textInputView.contentEdgeInsets
        newContentEdgeInsets.top = topPaddingOnEditing

        textInputView.contentEdgeInsets = newContentEdgeInsets
        textInputView.setNeedsLayout()

        textInputMaskView.contentEdgeInsets = newContentEdgeInsets
        textInputMaskView.setNeedsLayout()
    }

    private func updateTextInputLayoutOnClear() {
        var textInputContentEdgeInsetsOnClear = textInputView.contentEdgeInsets
        textInputContentEdgeInsetsOnClear.top = 0

        textInputView.contentEdgeInsets = textInputContentEdgeInsetsOnClear
        textInputView.setNeedsLayout()

        textInputMaskView.contentEdgeInsets = textInputContentEdgeInsetsOnClear
        textInputMaskView.setNeedsLayout()
    }

    private func addPlaceholder(
        _ layoutSheet: FloatingTextInputFieldViewTheme
    ) {
        insertSubview(
            placeholderView,
            belowSubview: textInputView
        )
        placeholderView.fitToIntrinsicSize()
        placeholderView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing <= 0
        }

        placeholderViewCenterYConstraint =
            placeholderView.snp.prepareConstraints {
                $0.center(
                    offset: (.noMetric, 0),
                    of: textInputView
                )
            }.first
        placeholderViewTopConstraint =
            placeholderView.snp.prepareConstraints {
                $0.top == 0
            }.first
    }

    private func updatePlaceholderLayoutOnEditing() {
        placeholderViewCenterYConstraint?.deactivate()
        placeholderViewTopConstraint?.activate()
    }

    private func updatePlaceholderLayoutOnClear() {
        placeholderViewTopConstraint?.deactivate()
        placeholderViewCenterYConstraint?.activate()
    }

    private func addFocusIndicator(
        _ layoutSheet: FloatingTextInputFieldViewTheme
    ) {
        addSubview(
            focusIndicatorView
        )
        focusIndicatorView.snp.makeConstraints {
            $0.bottom == textInputView.snp.bottom
            $0.fitToHeight(1)
            $0.setHorizontalPaddings()
        }
    }

    private func updateFocusIndicatorLayoutOnEditing() {
        focusIndicatorView.snp.updateConstraints {
            $0.fitToHeight(1.5)
        }
    }

    private func updateFocusIndicatorLayoutOnClear() {
        focusIndicatorView.snp.updateConstraints {
            $0.fitToHeight(1)
        }
    }

    private func addAssistive(
        _ layoutSheet: FloatingTextInputFieldViewTheme
    ) {
        addSubview(
            assistiveView
        )
        assistiveView.snp.makeConstraints {
            $0.top == textInputView.snp.bottom

            $0.setPaddings((.noMetric, 0, 0, 0))
        }
    }
}

extension FloatingTextInputFieldView {
    @discardableResult
    private func update(
        replacementString string: String,
        animated: Bool
    ) -> Bool {
        let currentText = textInputView.text.someString

        return update(
            changingCharactersIn: NSRange(currentText.startIndex..<currentText.endIndex, in: currentText),
            replacementString: string,
            animated: animated
        )
    }

    @discardableResult
    private func update(
        changingCharactersIn range: NSRange,
        replacementString string: String,
        animated: Bool
    ) -> Bool {
        if !isEnabled {
            return false
        }

        let formatted =
            format(
                changingCharactersIn: range,
                replacementString: string
            )

        textWillChange(
            formatted.newText,
            animated: animated
        )

        textInputView.text = formatted.newText
        textInputMaskView.text = formatted.newMask

        if isEditing,
           let caretOffset = formatted.newCaretOffset {
            asyncMain(
                self,
                afterDuration: 0.01
            ) { strongSelf in

                strongSelf.shiftCaretToPositionFromStart(
                    byOffset: caretOffset
                )
            }
        }

        return true
    }

    // swiftlint:disable large_tuple
    private func format(
        changingCharactersIn range: NSRange,
        replacementString string: String
    ) -> (newText: String, newMask: String?, newCaretOffset: Int?) {
        // swiftlint:enable (large_tuple)
        let currentText = textInputView.text.someString
        let newMask = maskFormatter?.format(
            currentText,
            changingCharactersIn: range,
            replacementString: string
        ).text

        guard let formatter = formatter else {
            let startIndex = currentText.utf16.startIndex
            let minIndex =
                currentText.utf16.index(
                    startIndex,
                    offsetBy: range.location
                )
            let maxIndex =
                currentText.utf16.index(
                    startIndex,
                    offsetBy: range.location + range.length
                )

            guard
                let textMinIndex = minIndex.samePosition(in: currentText),
                let textMaxIndex = maxIndex.samePosition(in: currentText)
            else {
                return (
                    currentText,
                    nil,
                    nil
                )
            }
            let newText =
                currentText.replacingCharacters(
                    in: textMinIndex..<textMaxIndex,
                    with: string
                )

            let caretOffset: Int?

            if string.isEmpty {
                caretOffset = max(0, range.location)
            } else {
                caretOffset =
                    newText
                    .range(
                        of: string,
                        range: textMinIndex..<newText.endIndex
                    )
                    .unwrap {
                        $0.upperBound.utf16Offset(in: newText)
                    }
            }

            return (
                newText: newText,
                newMask: newMask,
                newCaretOffset: caretOffset
            )
        }

        let newOutput =
            formatter.format(
                self,
                changingCharactersIn: range,
                replacementString: string
            )

        return (
            newText: newOutput.text,
            newMask: newMask,
            newCaretOffset: newOutput.caretOffset
        )
    }
}

protocol FloatingTextInputFieldViewDelegate: AnyObject {
    func floatingTextInputFieldViewShouldReturn(_ view: FloatingTextInputFieldView) -> Bool
}

extension Optional where Wrapped == String {
    public var someString: String {
        return self ?? ""
    }
}

public func asyncMain<T: AnyObject>(
    _ instance: T,
    afterDuration d: TimeInterval,
    execute: @escaping (T) -> Void
) {
    asyncMain(afterDuration: d) {
        [weak instance] in

        guard let strongInstance = instance else {
            return
        }

        execute(strongInstance)
    }
}

public func asyncMain(
    afterDuration d: TimeInterval,
    execute: @escaping () -> Void
) {
    DispatchQueue
        .main
        .asyncAfter(
            deadline: DispatchTime.now() + d,
            execute: execute
        )
}
