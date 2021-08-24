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
//  UserInformationView.swift

import UIKit

class UserInformationView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: UserInformationViewDelegate?
    
    private lazy var imageBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Background.secondary
        view.layer.cornerRadius = layout.current.backgroundViewSize / 2
        return view
    }()
    
    private(set) lazy var userImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-user-placeholder-big"))
        imageView.layer.cornerRadius = layout.current.backgroundViewSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        return imageView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom).withBackgroundColor(Colors.Main.primary600).withImage(img("icon-add"))
        button.layer.cornerRadius = 16.0
        return button
    }()
    
    private(set) lazy var contactNameInputView: SingleLineInputField = {
        let contactNameInputView = SingleLineInputField()
        contactNameInputView.explanationLabel.text = "contacts-input-name-explanation".localized
        contactNameInputView.placeholderText = "contacts-input-name-placeholder".localized
        contactNameInputView.nextButtonMode = .next
        contactNameInputView.inputTextField.autocorrectionType = .no
        contactNameInputView.inputTextField.isEnabled = isEditable
        return contactNameInputView
    }()
    
    private(set) lazy var algorandAddressInputView: MultiLineInputField = {
        let algorandAddressInputView = MultiLineInputField(displaysRightInputAccessoryButton: true)
        algorandAddressInputView.explanationLabel.text = "contacts-input-address-explanation".localized
        algorandAddressInputView.placeholderLabel.text = "contacts-input-address-placeholder".localized
        algorandAddressInputView.nextButtonMode = .submit
        algorandAddressInputView.inputTextView.autocorrectionType = .no
        algorandAddressInputView.inputTextView.autocapitalizationType = .none
        algorandAddressInputView.rightInputAccessoryButton.setImage(img("icon-qr-scan"), for: .normal)
        algorandAddressInputView.inputTextView.textContainer.heightTracksTextView = true
        algorandAddressInputView.inputTextView.isScrollEnabled = false
        algorandAddressInputView.inputTextView.isEditable = isEditable
        return algorandAddressInputView
    }()
    
    private var isEditable: Bool
    
    init(isEditable: Bool = true) {
        self.isEditable = isEditable
        super.init(frame: .zero)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        imageBackgroundView.applySmallShadow()
    }
    
    override func setListeners() {
        addButton.addTarget(self, action: #selector(notifyDelegateToAddButtonTapped), for: .touchUpInside)
    }
    
    override func linkInteractors() {
        algorandAddressInputView.delegate = self
    }
    
    override func prepareLayout() {
        setupImageBackgroundViewLayout()
        setupUserImageViewLayout()
        setupAddButtonLayout()
        setupContactNameInputViewLayout()
        setupAlgorandAddressInputViewLayout()
    }
    
    @available(iOS 12.0, *)
    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        if userInterfaceStyle == .dark {
            imageBackgroundView.removeShadows()
        } else {
            imageBackgroundView.applySmallShadow()
        }
    }
}

extension UserInformationView {
    @objc
    private func notifyDelegateToAddButtonTapped() {
        delegate?.userInformationViewDidTapAddImageButton(self)
    }
}

extension UserInformationView {
    private func setupImageBackgroundViewLayout() {
        addSubview(imageBackgroundView)
        
        imageBackgroundView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.imageInset)
            make.width.height.equalTo(layout.current.backgroundViewSize)
        }
    }
    
    private func setupUserImageViewLayout() {
        addSubview(userImageView)
        
        userImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.imageInset)
            make.width.height.equalTo(layout.current.backgroundViewSize)
        }
    }
    
    private func setupAddButtonLayout() {
        addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(imageBackgroundView)
            make.width.height.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupContactNameInputViewLayout() {
        addSubview(contactNameInputView)
        
        contactNameInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(imageBackgroundView.snp.bottom).offset(layout.current.nameTopInset)
        }
    }
    
    private func setupAlgorandAddressInputViewLayout() {
        addSubview(algorandAddressInputView)
        
        algorandAddressInputView.snp.makeConstraints { make in
            make.top.equalTo(contactNameInputView.snp.bottom).offset(layout.current.addressTopInset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageBackgroundView.updateShadowLayoutWhenViewDidLayoutSubviews()
    }
}

extension UserInformationView: InputViewDelegate {
    func inputViewShouldChangeText(inputView: BaseInputView, with text: String) -> Bool {
        return (algorandAddressInputView.inputTextView.text + text).count <= validatedAddressLength
    }
    
    func inputViewDidTapAccessoryButton(inputView: BaseInputView) {
        delegate?.userInformationViewDidTapQRCodeButton(self)
    }
    
    func inputViewDidReturn(inputView: BaseInputView) {
        if inputView == contactNameInputView {
            algorandAddressInputView.beginEditing()
        } else {
            algorandAddressInputView.inputTextView.resignFirstResponder()
        }
    }
}

extension UserInformationView {
    func setAddButtonIcon(_ icon: UIImage?) {
        addButton.setImage(icon, for: .normal)
    }
    
    func setAddButtonHidden(_ isHidden: Bool) {
        addButton.isHidden = isHidden
    }
}

extension UserInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let backgroundViewSize: CGFloat = 88.0
        let imageInset: CGFloat = 40.0
        let nameTopInset: CGFloat = 40.0
        let addressTopInset: CGFloat = 20.0
        let buttonSize: CGFloat = 32.0
    }
}

protocol UserInformationViewDelegate: AnyObject {
    func userInformationViewDidTapAddImageButton(_ userInformationView: UserInformationView)
    func userInformationViewDidTapQRCodeButton(_ userInformationView: UserInformationView)
}
