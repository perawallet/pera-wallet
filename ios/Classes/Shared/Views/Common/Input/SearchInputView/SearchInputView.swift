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
//   SearchInputView.swift

import Foundation
import MacaroonUIKit
import SnapKit
import UIKit

final class SearchInputView:
    View,
    UITextFieldDelegate,
    ListReusable {
    weak var delegate: SearchInputViewDelegate?

    var text: String? {
        return textInputView.text
    }
    var isEditing: Bool {
        return textInputView.isFirstResponder
    }

    override var intrinsicContentSize: CGSize {
        return intrinsicHeight.unwrap({
            CGSize((UIView.noIntrinsicMetric, $0))
        }, or: super.intrinsicContentSize
        )
    }

    private lazy var textInputBackgroundView = MacaroonUIKit.BaseView()
    private lazy var textInputView = TextField()
    private lazy var textLeftInputAccessoryView = UIImageView()
    private lazy var textRightInputAccessoryView = UIButton()
    private lazy var textClearInputAccessoryView = UIButton()

    private var rightAccessoryView: TextFieldAccessory?
    private var clearAccessoryView: TextFieldAccessory?

    private var intrinsicHeight: LayoutMetric?
    private var textInputBackgroundHeightConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setListeners()
        linkInteractors()
    }

    func customize(_ theme: SearchInputViewTheme) {
        customizeAppearance(theme)
        prepareLayout(theme)
    }

    func customizeAppearance(_ theme: SearchInputViewTheme) {
        /// <note>
        /// Setting  `spellCheckingType` to `.no` hides native suggestion word bar on the keyboard.
        textInputView.spellCheckingType = .no

        customizeTextInputBackgroundAppearance(theme)
        customizeTextInputAppearance(theme)
        customizeTextInputLeftAccessoryAppearance(theme)
        customizeTextInputRightAccessoryAppearance(theme)
    }

    func prepareLayout(_ theme: SearchInputViewTheme) {
        addTextInputBackground(theme)
        addTextInput(theme)
        addTextInputLeftAccessory(theme)
        addRightInputAccessory(theme)

        intrinsicHeight = theme.intrinsicHeight
        invalidateIntrinsicContentSize()
    }

    func setListeners() {
        textInputView.delegate = self
    }

    func linkInteractors() {
        textInputView.addTarget(self, action: #selector(notifyDelegateForEditing), for: .editingChanged)
        textRightInputAccessoryView.addTarget(self, action: #selector(didTapRightAccessory), for: .touchUpInside)
        textClearInputAccessoryView.addTarget(self, action: #selector(clearText), for: .touchUpInside)
    }

    func setText(_ text: String?) {
        textInputView.text = text
        notifyDelegateForEditing()
    }
}

extension SearchInputView {
    func beginEditing() {
        textInputView.becomeFirstResponder()
    }

    func endEditing() {
        textInputView.resignFirstResponder()
    }
}

extension SearchInputView {
    @objc
    private func clearText() {
        textInputView.text = nil
        notifyDelegateForEditing()
    }

    @objc
    private func didTapRightAccessory() {
        guard rightAccessoryView != nil else {
            return
        }

        delegate?.searchInputViewDidTapRightAccessory(self)
    }
}

extension SearchInputView {
    private func customizeTextInputBackgroundAppearance(_ theme: SearchInputViewTheme) {
        textInputBackgroundView.customizeAppearance(
            theme.textInputBackground
        )
        textInputBackgroundView.draw(corner: theme.textInputBackgroundRadius)
    }

    private func customizeTextInputAppearance(_ theme: SearchInputViewTheme) {
        textInputView.customizeAppearance(theme.textInput)
    }

    private func customizeTextInputLeftAccessoryAppearance(_ theme: SearchInputViewTheme) {
        textLeftInputAccessoryView.customizeAppearance(theme.textLeftInputAccessory)
    }

    private func customizeTextInputRightAccessoryAppearance(_ theme: SearchInputViewTheme) {
        if let textRightInputAccessory = theme.textRightInputAccessory {
            textRightInputAccessoryView.customizeAppearance(textRightInputAccessory)
        }
        textClearInputAccessoryView.customizeAppearance(theme.textClearInputAccessory)
    }
}

extension SearchInputView {
    private func addTextInputBackground(_ theme: SearchInputViewTheme) {
        addSubview(textInputBackgroundView)
        textInputBackgroundView.snp.makeConstraints {
            textInputBackgroundHeightConstraint =
            $0.fitToHeight(
                theme.intrinsicHeight -
                theme.textInputPaddings.top -
                theme.textInputPaddings.bottom
            )
            $0.setPaddings(
                (
                    theme.textInputPaddings.top,
                    theme.textInputPaddings.leading,
                    .noMetric,
                    theme.textInputPaddings.trailing
                )
            )
        }
    }

    private func addTextInput(_ theme: SearchInputViewTheme) {
        textInputBackgroundView.addSubview(textInputView)
        textInputView.contentEdgeInsets = theme.textInputContentEdgeInsets
        textInputView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func addTextInputLeftAccessory(_ theme: SearchInputViewTheme) {
        textInputView.leftAccessory = TextFieldAccessory(
            content: textLeftInputAccessoryView,
            size: CGSize(theme.textInputAccessorySize)
        )
    }

    private func addRightInputAccessory(_ theme: SearchInputViewTheme) {
        if theme.textRightInputAccessory != nil {
            rightAccessoryView = TextFieldAccessory(
                content: textRightInputAccessoryView,
                mode: .always,
                size: CGSize(width: theme.textInputAccessorySize.w,
                             height: theme.textInputAccessorySize.h),
                ignoresContentEdgeInsets: true
            )
        }

        clearAccessoryView = TextFieldAccessory(
            content: textClearInputAccessoryView,
            mode: .whileEditing,
            size: CGSize(width: theme.textInputAccessorySize.w,
                         height: theme.textInputAccessorySize.h),
            ignoresContentEdgeInsets: true
        )

        textInputView.rightAccessory = rightAccessoryView
    }
}

extension SearchInputView {
    @objc
    private func notifyDelegateForEditing() {
        let isTextInputEmpty = textInputView.text?.isEmpty ?? true
        if isTextInputEmpty {
            textInputView.rightAccessory = rightAccessoryView
        } else {
            textInputView.rightAccessory = clearAccessoryView
        }
        delegate?.searchInputViewDidEdit(self)
    }
}

/// <mark>
/// UITextFieldDelegate
extension SearchInputView {
    func textFieldShouldReturn(
        _ textField: UITextField
    ) -> Bool {
        guard let delegate = delegate else {
            return true
        }

        delegate.searchInputViewDidReturn(self)

        return false
    }

    func textFieldDidBeginEditing(
        _ textField: UITextField
    ) {
        delegate?.searchInputViewDidBeginEditing(self)
    }

    func textFieldDidEndEditing(
        _ textField: UITextField
    ) {
        delegate?.searchInputViewDidEndEditing(self)
    }
}

protocol SearchInputViewDelegate: AnyObject {
    func searchInputViewDidEdit(_ view: SearchInputView)
    func searchInputViewDidBeginEditing(_ view: SearchInputView)
    func searchInputViewDidEndEditing(_ view: SearchInputView)
    func searchInputViewDidReturn(_ view: SearchInputView)
    func searchInputViewDidTapRightAccessory(_ view: SearchInputView)
}

extension SearchInputViewDelegate {
    func searchInputViewDidTapRightAccessory(
        _ view: SearchInputView
    ) {}

    func searchInputViewDidBeginEditing(
        _ view: SearchInputView
    ) {}

    func searchInputViewDidEndEditing(
        _ view: SearchInputView
    ) {}
}
