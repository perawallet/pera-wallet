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
//  WatchAccountAdditionView.swift

import UIKit

class WatchAccountAdditionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: WatchAccountAdditionViewDelegate?

    private(set) lazy var addressInputView: MultiLineInputField = {
        let addressInputView = MultiLineInputField(displaysRightInputAccessoryButton: true)
        addressInputView.explanationLabel.text = "watch-account-input-explanation".localized
        addressInputView.placeholderLabel.text = "watch-account-input-placeholder".localized
        addressInputView.nextButtonMode = .submit
        addressInputView.inputTextView.autocorrectionType = .no
        addressInputView.inputTextView.autocapitalizationType = .none
        addressInputView.rightInputAccessoryButton.setImage(img("icon-qr-scan"), for: .normal)
        addressInputView.inputTextView.textContainer.heightTracksTextView = true
        addressInputView.inputTextView.isScrollEnabled = false
        return addressInputView
    }()

    private lazy var bottomLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.secondary)
            .withLine(.contained)
            .withAlignment(.left)
            .withText("watch-account-explanation-title".localized)
    }()
    
    private(set) lazy var nextButton = MainButton(title: "title-verify".localized)
    
    override func linkInteractors() {
        addressInputView.delegate = self
    }
    
    override func setListeners() {
        nextButton.addTarget(self, action: #selector(notifyDelegateToOpenNextScreen), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupAddressInputViewLayout()
        setupBottomLabelLayout()
        setupNextButtonLayout()
    }
}

extension WatchAccountAdditionView {
    @objc
    func notifyDelegateToOpenNextScreen() {
        delegate?.watchAccountAdditionViewDidAddAccount(self)
    }
}

extension WatchAccountAdditionView {
    private func setupAddressInputViewLayout() {
        addSubview(addressInputView)
        
        addressInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }

    private func setupBottomLabelLayout() {
        addSubview(bottomLabel)

        bottomLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(addressInputView.snp.bottom).offset(layout.current.bottomLabelTopInset)
        }
    }

    private func setupNextButtonLayout() {
        addSubview(nextButton)
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(bottomLabel.snp.bottom).offset(layout.current.buttonTopInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.buttonBottomInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerX.equalToSuperview()
        }
    }
}

extension WatchAccountAdditionView {
    func beginEditing() {
        addressInputView.beginEditing()
    }
}

extension WatchAccountAdditionView: InputViewDelegate {
    func inputViewDidTapAccessoryButton(inputView: BaseInputView) {
        delegate?.watchAccountAdditionViewDidScanQR(self)
    }
    
    func inputViewDidReturn(inputView: BaseInputView) {
        delegate?.watchAccountAdditionViewDidAddAccount(self)
    }
}

extension WatchAccountAdditionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 36.0
        let fieldTopInset: CGFloat = 20.0
        let bottomLabelTopInset: CGFloat = 16.0
        let buttonBottomInset: CGFloat = 15.0
        let buttonTopInset: CGFloat = 24.0
        let horizontalInset: CGFloat = 20.0
    }
}

protocol WatchAccountAdditionViewDelegate: AnyObject {
    func watchAccountAdditionViewDidScanQR(_ watchAccountAdditionView: WatchAccountAdditionView)
    func watchAccountAdditionViewDidAddAccount(_ watchAccountAdditionView: WatchAccountAdditionView)
}
