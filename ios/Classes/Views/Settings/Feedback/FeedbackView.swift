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
//  FeedbackView.swift

import UIKit

class FeedbackView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: FeedbackViewDelegate?
    
    private(set) lazy var categorySelectionView: SelectionView = {
        let categorySelectionView = SelectionView()
        categorySelectionView.leftExplanationLabel.text = "feedback-title-category".localized
        categorySelectionView.detailLabel.text = "feedback-subtitle-category".localized
        categorySelectionView.rightInputAccessoryButton.setImage(img("icon-picker-selection-down"), for: .normal)
        return categorySelectionView
    }()
    
    private(set) lazy var categoryPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.isHidden = true
        return pickerView
    }()
    
    private(set) lazy var accountSelectionView: SelectionView = {
        let accountSelectionView = SelectionView()
        accountSelectionView.leftExplanationLabel.text = "feedback-subtitle-account-title".localized
        accountSelectionView.detailLabel.text = "feedback-subtitle-account-detail".localized
        accountSelectionView.rightInputAccessoryButton.setImage(img("icon-picker-selection-down"), for: .normal)
        return accountSelectionView
    }()
    
    private(set) lazy var emailInputView: SingleLineInputField = {
        let accountNameInputView = SingleLineInputField()
        accountNameInputView.explanationLabel.text = "feedback-title-email".localized
        accountNameInputView.placeholderText = "feedback-title-email".localized
        accountNameInputView.nextButtonMode = .next
        accountNameInputView.inputTextField.autocorrectionType = .no
        accountNameInputView.inputTextField.autocapitalizationType = .none
        accountNameInputView.inputTextField.keyboardType = .emailAddress
        return accountNameInputView
    }()
    
    private(set) lazy var noteInputView: MultiLineInputField = {
        let noteInputView = MultiLineInputField()
        noteInputView.explanationLabel.text = "feedback-title-note".localized
        noteInputView.placeholderLabel.text = "feedback-subtitle-note".localized
        noteInputView.nextButtonMode = .submit
        noteInputView.inputTextView.autocorrectionType = .no
        noteInputView.inputTextView.autocapitalizationType = .none
        return noteInputView
    }()
    
    private lazy var sendButton = MainButton(title: "feedback-title".localized)
    
    override func linkInteractors() {
        emailInputView.delegate = self
    }
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendButtonTapped), for: .touchUpInside)
        categorySelectionView.addTarget(self, action: #selector(notifyDelegateToSelectCategory), for: .touchUpInside)
        accountSelectionView.addTarget(self, action: #selector(notifyDelegateToSelectAccount), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupCategorySelectionViewLayout()
        setupCategoryPickerViewLayout()
        setupAccountSelectionViewLayout()
        setupEmailInputViewLayout()
        setupNoteInputViewLayout()
        setupSendButtonLayout()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !categorySelectionView.frame.contains(point) &&
            !categoryPickerView.frame.contains(point) &&
            !accountSelectionView.frame.contains(point) &&
            !sendButton.frame.contains(point) &&
            !categoryPickerView.isHidden {
            delegate?.feedbackViewDidSelectCategory(self)
        }
        
        return super.hitTest(point, with: event)
    }
}

extension FeedbackView {
    @objc
    private func notifyDelegateToSelectCategory() {
        delegate?.feedbackViewDidSelectCategory(self)
    }
    
    @objc
    private func notifyDelegateToSelectAccount() {
        delegate?.feedbackViewDidSelectAccount(self)
    }
    
    @objc
    private func notifyDelegateToSendButtonTapped() {
        delegate?.feedbackViewDidTapSendButton(self)
    }
}

extension FeedbackView {
    private func setupCategorySelectionViewLayout() {
        addSubview(categorySelectionView)
        
        categorySelectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupCategoryPickerViewLayout() {
        addSubview(categoryPickerView)
        
        categoryPickerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(categorySelectionView.snp.bottom)
            make.height.equalTo(layout.current.pickerInitialHeight)
        }
    }
    
    private func setupAccountSelectionViewLayout() {
        addSubview(accountSelectionView)
        
        accountSelectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(categoryPickerView.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupEmailInputViewLayout() {
        addSubview(emailInputView)
        
        emailInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(accountSelectionView.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupNoteInputViewLayout() {
        addSubview(noteInputView)
        
        noteInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(emailInputView.snp.bottom).offset(layout.current.verticalInset)
            make.height.equalTo(layout.current.noteViewHeight)
        }
    }
    
    private func setupSendButtonLayout() {
        addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.top.equalTo(noteInputView.snp.bottom).offset(layout.current.buttonTopInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension FeedbackView: InputViewDelegate {
    func inputViewDidReturn(inputView: BaseInputView) {
        delegate?.feedbackView(self, inputDidReturn: inputView)
    }
}

extension FeedbackView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let pickerInitialHeight: CGFloat = 0.0
        let topInset: CGFloat = 12.0
        let noteViewHeight: CGFloat = 136.0
        let verticalInset: CGFloat = 20.0
        let buttonHorizontalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 30.0
        let buttonTopInset: CGFloat = 28.0
    }
}

protocol FeedbackViewDelegate: class {
    func feedbackViewDidSelectCategory(_ feedbackView: FeedbackView)
    func feedbackViewDidSelectAccount(_ feedbackView: FeedbackView)
    func feedbackViewDidTapSendButton(_ feedbackView: FeedbackView)
    func feedbackView(_ feedbackView: FeedbackView, inputDidReturn inputView: BaseInputView)
}
