// Copyright 2019 Algorand, Inc.

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

class RecoverInputView: BaseView {

    weak var delegate: RecoverInputViewDelegate?

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 158.0, height: 48.0)
    }

    private let layout = Layout<LayoutConstants>()

    var isFilled: Bool {
        return !input.isNilOrEmpty
    }

    var input: String? {
        return inputTextField.text
    }

    var isEditing: Bool {
        return inputTextField.isFirstResponder
    }

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

    private lazy var backgroundImageView = UIImageView()

    private lazy var numberLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.hint)
            .withAlignment(.left)
    }()

    private lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textColor = Colors.Text.primary
        textField.tintColor = Colors.General.success
        textField.font = UIFont.font(withWeight: .regular(size: 16.0))
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.RecoverInputView.separatorColor
        return view
    }()

    override func setListeners() {
        inputTextField.addTarget(self, action: #selector(didChange(textField:)), for: .editingChanged)
    }

    override func linkInteractors() {
        inputTextField.delegate = self
    }

    override func configureAppearance() {
        backgroundColor = .clear
    }

    override func prepareLayout() {
        setupBackgroundImageViewLayout()
        setupNumberLabelLayout()
        setupInputTextFieldLayout()
        setupSeparatorViewLayout()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        beginEditing()
    }
}

extension RecoverInputView {
    private func setupBackgroundImageViewLayout() {
        addSubview(backgroundImageView)

        backgroundImageView.snp.makeConstraints { make in
            make.leading.trailing.bottom.top.equalToSuperview()
        }
    }

    private func setupNumberLabelLayout() {
        addSubview(numberLabel)

        numberLabel.setContentHuggingPriority(.required, for: .horizontal)
        numberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        numberLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.bottom.equalToSuperview().inset(layout.current.numberVerticalInset)
        }
    }

    private func setupInputTextFieldLayout() {
        addSubview(inputTextField)

        inputTextField.snp.makeConstraints { make in
            make.leading.equalTo(numberLabel.snp.trailing).offset(layout.current.defaultInset)
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.centerY.equalTo(numberLabel)
        }
    }

    private func setupSeparatorViewLayout() {
        addSubview(separatorView)

        separatorView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalTo(numberLabel.snp.trailing).offset(layout.current.defaultInset)
            make.bottom.equalTo(numberLabel)
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
}

extension RecoverInputView {
    func beginEditing() {
        _ = inputTextField.becomeFirstResponder()
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
        return delegate?.recoverInputViewShouldReturn(self) ?? true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        delegate?.recoverInputView(self, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
}

extension RecoverInputView {
    func bind(_ viewModel: RecoverInputViewModel) {
        backgroundImageView.image = viewModel.backgroundImage
        numberLabel.text = viewModel.number
        numberLabel.textColor = viewModel.numberColor
        inputTextField.textColor = viewModel.passphraseColor
        separatorView.isHidden = viewModel.isSeparatorHidden
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

extension Colors {
    fileprivate enum RecoverInputView {
        static let separatorColor = color("recoverSeparatorColor")
    }
}

extension RecoverInputView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 8.0
        let numberVerticalInset: CGFloat = 12.0
        let separatorHeight: CGFloat = 1.0
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
