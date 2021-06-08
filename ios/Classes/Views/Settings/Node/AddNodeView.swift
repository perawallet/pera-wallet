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
//  AddNodeView.swift

import UIKit

class AddNodeView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let labelTopInset: CGFloat = 20.0
        let inputHeight: CGFloat = 87.0
        let tokenHeight: CGFloat = 119.0
        let verticalOffset: CGFloat = 20.0
        let buttonHorizontalInset: CGFloat = 20.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var nameInputView: SingleLineInputField = {
        let inputView = SingleLineInputField()
        inputView.explanationLabel.text = "node-settings-enter-node-name".localized
        inputView.placeholderText = "node-settings-placeholder-name".localized
        inputView.inputTextField.textColor = Colors.Text.primary
        inputView.inputTextField.tintColor = Colors.Text.primary
        inputView.inputTextField.font = UIFont.font(withWeight: .semiBold(size: 14.0))
        inputView.nextButtonMode = .next
        inputView.inputTextField.autocorrectionType = .no
        inputView.backgroundColor = .clear
        return inputView
    }()
    
    private(set) lazy var addressInputView: SingleLineInputField = {
        let inputView = SingleLineInputField()
        inputView.explanationLabel.text = "node-settings-enter-node-address".localized
        inputView.placeholderText = "node-settings-placeholder-address".localized
        inputView.inputTextField.textColor = Colors.Text.primary
        inputView.inputTextField.tintColor = Colors.Text.primary
        inputView.inputTextField.font = UIFont.font(withWeight: .semiBold(size: 14.0))
        inputView.nextButtonMode = .next
        inputView.inputTextField.autocorrectionType = .no
        inputView.backgroundColor = .clear
        return inputView
    }()
    
    private(set) lazy var tokenInputView: MultiLineInputField = {
        let algorandAddressInputView = MultiLineInputField()
        algorandAddressInputView.explanationLabel.text = "node-settings-api-key".localized
        algorandAddressInputView.placeholderLabel.attributedText = NSAttributedString(
            string: "node-settings-placeholder-api-key".localized,
            attributes: [NSAttributedString.Key.foregroundColor: Colors.Text.hint,
                         NSAttributedString.Key.font: UIFont.font(withWeight: .semiBold(size: 14.0))]
        )
        algorandAddressInputView.nextButtonMode = .submit
        algorandAddressInputView.inputTextView.autocorrectionType = .no
        algorandAddressInputView.inputTextView.autocapitalizationType = .none
        algorandAddressInputView.inputTextView.textContainer.heightTracksTextView = false
        algorandAddressInputView.inputTextView.textColor = Colors.Text.primary
        algorandAddressInputView.inputTextView.tintColor = Colors.Text.primary
        algorandAddressInputView.inputTextView.font = UIFont.font(withWeight: .semiBold(size: 14.0))
        algorandAddressInputView.inputTextView.isScrollEnabled = true
        algorandAddressInputView.backgroundColor = .clear
        
        algorandAddressInputView.inputTextView.isEditable = true
        return algorandAddressInputView
    }()
    
    private(set) lazy var testButton: MainButton = {
        let button = MainButton(title: "node-settings-test-button-title".localized)
        return button
    }()
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupNameInputViewLayout()
        setupAddressInputViewLayout()
        setupTokenInputViewLayout()
        setupTestButtonLayout()
    }
    
    private func setupNameInputViewLayout() {
        addSubview(nameInputView)
        
        nameInputView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.inputHeight)
        }
        
        nameInputView.explanationLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(layout.current.labelTopInset)
        }
    }
    
    private func setupAddressInputViewLayout() {
        addSubview(addressInputView)
        
        addressInputView.snp.makeConstraints { make in
            make.top.equalTo(nameInputView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.inputHeight)
        }
        
        addressInputView.explanationLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(layout.current.labelTopInset)
        }
    }
    
    private func setupTokenInputViewLayout() {
        addSubview(tokenInputView)
        
        tokenInputView.snp.makeConstraints { make in
            make.top.equalTo(addressInputView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.tokenHeight)
        }
        
        tokenInputView.explanationLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(layout.current.labelTopInset)
        }
    }
    
    private func setupTestButtonLayout() {
        addSubview(testButton)
        
        testButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(tokenInputView.snp.bottom).offset(layout.current.verticalOffset)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-layout.current.verticalOffset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
        }
    }
}
