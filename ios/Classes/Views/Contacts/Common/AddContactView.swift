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
//  AddContactView.swift

import UIKit

class AddContactView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var userInformationView = UserInformationView()
        
    private(set) lazy var addContactButton = MainButton(title: "contacts-add".localized)
    
    private(set) lazy var deleteContactButton: AlignedButton = {
        let button = AlignedButton(.imageAtLeft(spacing: 8.0))
        button.setImage(img("icon-trash", isTemplate: true), for: .normal)
        button.tintColor = Colors.General.error
        button.setTitle("contacts-delete-contact".localized, for: .normal)
        button.setTitleColor(Colors.General.error, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 16.0))
        return button
    }()
    
    weak var delegate: AddContactViewDelegate?
    
    override func setListeners() {
        addContactButton.addTarget(self, action: #selector(notifyDelegateToHandleAction), for: .touchUpInside)
        deleteContactButton.addTarget(self, action: #selector(notifyDelegateToHandleAction), for: .touchUpInside)
    }
    
    override func linkInteractors() {
        userInformationView.delegate = self
    }
    
    override func prepareLayout() {
        setupUserInformationViewLayout()
        setupAddButtonLayout()
        setupDeleteContactButtonLayout()
    }
}

extension AddContactView {
    @objc
    private func notifyDelegateToHandleAction() {
        delegate?.addContactViewDidTapActionButton(self)
    }
}

extension AddContactView {
    private func setupUserInformationViewLayout() {
        addSubview(userInformationView)
        
        userInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
        }
    }
    
    private func setupAddButtonLayout() {
        addSubview(addContactButton)
        
        addContactButton.snp.makeConstraints { make in
            make.top.equalTo(userInformationView.snp.bottom).offset(layout.current.topInset)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + layout.current.bottomInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
        }
    }
    
    private func setupDeleteContactButtonLayout() {
        addSubview(deleteContactButton)
        
        deleteContactButton.snp.makeConstraints { make in
            make.top.equalTo(userInformationView.snp.bottom).offset(layout.current.topInset)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + layout.current.bottomInset)
            make.size.equalTo(layout.current.deleteButtonSize)
        }
    }
}

extension AddContactView: UserInformationViewDelegate {
    func userInformationViewDidTapAddImageButton(_ userInformationView: UserInformationView) {
        delegate?.addContactViewDidTapAddImageButton(self)
    }
    
    func userInformationViewDidTapQRCodeButton(_ userInformationView: UserInformationView) {
        delegate?.addContactViewDidTapQRCodeButton(self)
    }
}

extension AddContactView {
    func setUserActionButtonIcon(_ image: UIImage?) {
        userInformationView.setAddButtonIcon(image)
    }
}

extension AddContactView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let bottomInset: CGFloat = 15.0
        let topInset: CGFloat = 28.0
        let buttonHorizontalInset: CGFloat = 20.0
        let deleteButtonSize = CGSize(width: 145.0, height: 44.0)
    }
}

protocol AddContactViewDelegate: AnyObject {
    func addContactViewDidTapActionButton(_ addContactView: AddContactView)
    func addContactViewDidTapAddImageButton(_ addContactView: AddContactView)
    func addContactViewDidTapQRCodeButton(_ addContactView: AddContactView)
}
