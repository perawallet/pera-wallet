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
//   RecoverInputView.swift

import UIKit
import MacaroonUIKit

final class RecoverInputView: View {
    override var intrinsicContentSize: CGSize {
        return CGSize(theme.size)
    }

    weak var delegate: RecoverInputViewDelegate?

    private lazy var theme = RecoverInputViewTheme()

    private lazy var numberLabel = UILabel()
    private lazy var inputTextField = UITextField()
    private lazy var focusIndicatorView = UIView()

    var returnKey: ReturnKey = .next {
       didSet {
           switch returnKey {
           case .next:
               inputTextField.returnKeyType = .next
           case .go:
               inputTextField.returnKeyType = .go
           }
       }
   }

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize()
        setListeners()
        linkInteractors()
    }

    func customize() {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addNumberLabel(theme)
        addInputTextField(theme)
        addFocusIndicatorView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func setListeners() {
        inputTextField.addTarget(self, action: #selector(didChange(textField:)), for: .editingChanged)
    }

    func linkInteractors() {
        inputTextField.delegate = self
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        beginEditing()
    }
}

extension RecoverInputView {
    private func addNumberLabel(_ theme: RecoverInputViewTheme) {
        numberLabel.customizeAppearance(theme.number)

        addSubview(numberLabel)
        numberLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.defaultInset)
            $0.top.bottom.equalToSuperview().inset(theme.numberVerticalInset)
        }

        numberLabel.setContentHuggingPriority(.required, for: .horizontal)
        numberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private func addInputTextField(_ theme: RecoverInputViewTheme) {
        inputTextField.customizeAppearance(theme.inputTextField)
        /// <todo>
        /// Move this to Macaroon TextInputStyle
        /// <note>
        /// Since we use our own word suggestion bar, `spellCheckingType = .no` is
        /// also necessary to hide native suggestion word bar on the keyboard.
        inputTextField.spellCheckingType = .no

        addSubview(inputTextField)
        inputTextField.snp.makeConstraints {
           $0.leading.equalTo(numberLabel.snp.trailing).offset(theme.defaultInset)
           $0.trailing.equalToSuperview()
           $0.centerY.equalTo(numberLabel)
        }
    }

    private func addFocusIndicatorView(_ theme: RecoverInputViewTheme) {
        focusIndicatorView.customizeAppearance(theme.focusIndicator)

        addSubview(focusIndicatorView)
        focusIndicatorView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(numberLabel.snp.trailing).offset(theme.defaultInset)
            $0.bottom.equalTo(numberLabel)
            $0.height.equalTo(theme.focusIndicatorHeight)
        }
    }
}
extension RecoverInputView {
    var isFilled: Bool {
        return !input.isNilOrEmpty
    }

    var input: String? {
        return inputTextField.text
    }

    var isEditing: Bool {
        return inputTextField.isFirstResponder
    }
}

extension RecoverInputView {
    func beginEditing() {
        inputTextField.becomeFirstResponder()
    }

    func setText(_ text: String) {
        inputTextField.text = text
    }

    var isInputAccessoryViewSet: Bool {
        return inputTextField.inputAccessoryView != nil
    }

    func setInputAccessoryView(_ inputAccessoryView: UIView) {
        inputTextField.inputAccessoryView = inputAccessoryView
        inputTextField.reloadInputViews()
    }

    func removeInputAccessoryView() {
        inputTextField.inputAccessoryView = nil
        inputTextField.reloadInputViews()
    }
}

extension RecoverInputView {
    @objc
    func didChange(textField: UITextField) {
        delegate?.recoverInputViewDidChange(self)
    }
}

extension RecoverInputView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        inputTextField.layoutIfNeeded()
        delegate?.recoverInputViewDidEndEditing(self)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.recoverInputViewDidBeginEditing(self)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return (delegate?.recoverInputViewShouldReturn(self)).ifNil(true)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        (delegate?.recoverInputView(self, shouldChangeCharactersIn: range, replacementString: string)).ifNil(true)
    }
}

extension RecoverInputView: ViewModelBindable {
    func bindData(_ viewModel: RecoverInputViewModel?) {
        guard let viewModel = viewModel else {
            return
        }

        numberLabel.text = viewModel.number
        numberLabel.textColor = viewModel.numberColor
        inputTextField.textColor = viewModel.passphraseColor
        focusIndicatorView.backgroundColor = viewModel.focusIndicatorColor

        focusIndicatorView.snp.updateConstraints {
            $0.fitToHeight(viewModel.focusIndicatorHeight.unwrap(or: theme.focusIndicatorHeight))
        }
    }
}

extension RecoverInputView {
    enum State {
        case active
        case empty
        case filled
        case wrong
        case filledWrongly
    }
}

extension RecoverInputView {
    enum ReturnKey {
        case next
        case go
    }
}

protocol RecoverInputViewDelegate: AnyObject {
    func recoverInputViewDidBeginEditing(_ recoverInputView: RecoverInputView)
    func recoverInputViewDidChange(_ recoverInputView: RecoverInputView)
    func recoverInputViewDidEndEditing(_ recoverInputView: RecoverInputView)
    func recoverInputViewShouldReturn(_ recoverInputView: RecoverInputView) -> Bool
    func recoverInputView(
        _ recoverInputView: RecoverInputView,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool
}
