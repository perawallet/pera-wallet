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
//   MultilineTextInputFieldView.swift

import Foundation
import MacaroonUIKit
import UIKit
import SnapKit
import MacaroonForm

final class MultilineTextInputFieldView: View, FormTextInputFieldView, UITextViewDelegate {
    weak var delegate: MultilineTextInputFieldViewDelegate?
    weak var editingDelegate: FormInputFieldViewEditingDelegate?
    
    var inputState: FormInputFieldState = .none {
        didSet { inputStateDidChange() }
    }
    
    var text: String? {
        get {
            textInputView.text
        }
        set {
            textInputView.text = newValue
            textViewDidEdit(textInputView)
        }
    }
    
    var formatter: MacaroonForm.TextInputFormatter?
    var validator: Validator?
    
    var inputType: FormInputType {
        return .keyboard
    }
    
    private lazy var placeholderView = Label()
    private lazy var textInputView = UITextView()
    private lazy var focusIndicatorView = UIImageView()
    private lazy var assistiveView = FormInputFieldAssistiveView()
    
    private var placeholderTopConstraint: Constraint?
    private var floatingPlaceholderTopConstraint: Constraint?
    
    private var theme: MultilineTextInputFieldViewTheme?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setListeners()
        linkInteractors()
    }
    
    func customize(_ theme: MultilineTextInputFieldViewTheme) {
        self.theme = theme
        
        customizeTextInputAppearance(theme)
        customizePlaceholderAppearance(theme)
        customizeFocusIndicatorAppearance(theme)
        customizeAssistiveAppearance(theme)
        
        recustomizeAppearanceWhenStyleSheetDidChange()
        
        addPlaceholder(theme)
        addTextInput(theme)
        addFocusIndicator(theme)
        addAssistive(theme)
        
        updateLayoutWhenLayoutSheetDidChange()
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoStyleSheet) {}
    
    func setListeners() {
        textInputView.delegate = self
    }
    
    func linkInteractors() {
        focusIndicatorView.isUserInteractionEnabled = false
    }
    
    /// <mark>
    /// UITextFieldDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        updateFocusIndicatorLayoutOnEditing()
        updatePlaceholderLayoutOnEditing()
        recustomizeFocusIndicatorOnEdit()
        recustomizePlaceholderOnEditing()
        
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
        
        editingDelegate?.formInputFieldViewDidBeginEditing(self)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        editingDelegate?.formInputFieldViewDidEdit(self)
    }
    
    func textViewDidEdit(_ textView: UITextView) {
        if !textView.text.isEmpty {
            updateFocusIndicatorLayoutOnEditing()
            updatePlaceholderLayoutOnEditing()
            recustomizeFocusIndicatorOnEdit()
            recustomizePlaceholderOnEditing()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            updateFocusIndicatorLayoutOnEnd()
            updatePlaceholderLayoutOnClear()
            recustomizePlaceholderOnClear()
            recustomizeFocusIndicatorOnClear()
            
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
        
        editingDelegate?.formInputFieldViewDidEndEditing(self)
    }

    func textView(
        _ textView: UITextView, shouldChangeTextIn
        range: NSRange, replacementText text: String
    ) -> Bool {
        guard let delegate = delegate else {
            return true
        }

        if let character = text.first,
           character.isNewline {
            delegate.multilineTextInputFieldViewDidReturn(
                self
            )

            return false
        }

        return delegate.multilineTextInputFieldView(
            self,
            shouldChangeCharactersIn: range,
            replacementString: text
        )
    }
}

extension MultilineTextInputFieldView {
    func beginEditing() {
        textInputView.becomeFirstResponder()
    }
    
    func endEditing() {
        textInputView.resignFirstResponder()
    }
}

extension MultilineTextInputFieldView {
    private func inputStateDidChange() {
        switch inputState {
        case .focus:
            updateFocusIndicatorAppearanceOnSuccess()
            assistiveView.editError = nil
        case .invalid(let validationError):
            updateFocusIndicatorAppearanceOnFailure()
            assistiveView.editError = validator?.getMessage(for: validationError)
        case .incorrect(let error):
            updateFocusIndicatorAppearanceOnFailure()
            assistiveView.editError = error
        case .none:
            resetFocusIndicatorAppearance()
            assistiveView.editError = nil
        }
    }
}

extension MultilineTextInputFieldView {
    private func recustomizeAppearanceWhenStyleSheetDidChange() {
        textInputView.text.isNilOrEmpty
            ? recustomizePlaceholderOnClear()
            : recustomizePlaceholderOnEditing()
    }
    
    private func customizeTextInputAppearance(_ styleSheet: MultilineTextInputFieldViewTheme) {
        textInputView.isScrollEnabled = false
        textInputView.textContainerInset = .zero
        textInputView.textContainer.lineFragmentPadding = 0.0
        textInputView.backgroundColor = .clear
        textInputView.customizeAppearance(styleSheet.textInput)
    }
    
    private func customizePlaceholderAppearance(_ styleSheet: MultilineTextInputFieldViewTheme) {
        placeholderView.customizeAppearance(styleSheet.placeholder)
    }
    
    private func recustomizePlaceholderOnEditing() {
        guard let theme = theme else {
            return
        }
        
        placeholderView.customizeAppearance(theme.floatingPlaceholder)
    }
    
    private func recustomizePlaceholderOnClear() {
        guard let theme = theme else {
            return
        }
        
        placeholderView.customizeAppearance(theme.placeholder)
    }
    
    private func customizeFocusIndicatorAppearance(_ styleSheet: MultilineTextInputFieldViewTheme) {
        focusIndicatorView.customizeAppearance(styleSheet.focusIndicator)
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

    private func resetFocusIndicatorAppearance() {
        if let style = theme?.focusIndicator {
            focusIndicatorView.customizeAppearance(style)
        }
    }
    
    private func updateFocusIndicatorAppearanceOnSuccess() {
        if let style = theme?.focusIndicatorActive {
            focusIndicatorView.customizeAppearance(style)
        }
    }
    
    private func updateFocusIndicatorAppearanceOnFailure() {
        if let style = theme?.errorFocusIndicator {
            focusIndicatorView.customizeAppearance(style)
        }
    }
    
    private func customizeAssistiveAppearance(_ styleSheet: MultilineTextInputFieldViewTheme) {
        assistiveView.customize(styleSheet.assistive)
    }
}

extension MultilineTextInputFieldView {
    private func updateLayoutWhenLayoutSheetDidChange() {
        if textInputView.text.isNilOrEmpty {
            updatePlaceholderLayoutOnClear()
        } else {
            updatePlaceholderLayoutOnEditing()
        }
    }
    
    private func addTextInput(_ layoutSheet: MultilineTextInputFieldViewTheme) {
        textInputView.textContainerInset = UIEdgeInsets(layoutSheet.textContainerInsets)

        addSubview(textInputView)
        textInputView.fitToVerticalIntrinsicSize()
        textInputView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(layoutSheet.textInputMinHeight)
            $0.top.leading.trailing.equalToSuperview()
        }
    }
    
    private func addPlaceholder(_ layoutSheet: MultilineTextInputFieldViewTheme) {
        addSubview(placeholderView)
        placeholderView.fitToIntrinsicSize()
        placeholderView.snp.makeConstraints {
            $0.leading.equalToSuperview()
        }
        
        floatingPlaceholderTopConstraint = placeholderView.snp.prepareConstraints {
            $0.top == 0
        }.first
        
        placeholderTopConstraint = placeholderView.snp.prepareConstraints {
            $0.centerY.equalToSuperview()
        }.first
    }
    
    private func updatePlaceholderLayoutOnEditing() {
        placeholderTopConstraint?.deactivate()
        floatingPlaceholderTopConstraint?.activate()
    }
    
    private func updatePlaceholderLayoutOnClear() {
        placeholderTopConstraint?.activate()
        floatingPlaceholderTopConstraint?.deactivate()
    }
    
    private func addFocusIndicator(_ layoutSheet: MultilineTextInputFieldViewTheme) {
        addSubview(focusIndicatorView)
        focusIndicatorView.snp.makeConstraints {
            $0.bottom == textInputView.snp.bottom + layoutSheet.focusIndicatorTopInset
            $0.fitToHeight(1)
            $0.setHorizontalPaddings()
        }
    }
    
    private func updateFocusIndicatorLayoutOnEditing() {
        focusIndicatorView.snp.updateConstraints {
            $0.fitToHeight(1.5)
        }
    }

    private func updateFocusIndicatorLayoutOnEnd() {
        focusIndicatorView.snp.updateConstraints {
            $0.fitToHeight(1)
        }
    }
    
    private func addAssistive(_ layoutSheet: MultilineTextInputFieldViewTheme) {
        addSubview(assistiveView)
        assistiveView.snp.makeConstraints {
            $0.top == textInputView.snp.bottom
            $0.setPaddings((.noMetric, 0, 0, 0))
        }
    }
}

extension MultilineTextInputFieldView {
    func addRightAccessoryItem(_ accessoryView: UIView) {
        addSubview(accessoryView)
        accessoryView.snp.makeConstraints {
            $0.centerY == textInputView
            $0.trailing == 0
        }
    }
}

protocol MultilineTextInputFieldViewDelegate: AnyObject {
    func multilineTextInputFieldViewDidReturn(_ view: MultilineTextInputFieldView)
    func multilineTextInputFieldView(
        _ view: MultilineTextInputFieldView,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool
}

extension MultilineTextInputFieldViewDelegate {
    func multilineTextInputFieldView(
        _ view: MultilineTextInputFieldView,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        return true
    }
}
