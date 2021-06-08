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
//  ContactsEmptyView.swift

import UIKit

class ContactsEmptyView: EmptyStateView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: ContactsEmptyViewDelegate?
    
    private lazy var addContactButton: UIButton = {
        let button = UIButton(type: .custom)
            .withTitle("contacts-add".localized)
            .withAlignment(.center)
            .withTitleColor(Colors.ButtonText.primary)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withBackgroundColor(Colors.Main.primary600)
        button.layer.cornerRadius = 26.0
        return button
    }()
    
    override func setListeners() {
        addContactButton.addTarget(self, action: #selector(notifyDelegateToAddContact), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupAddContactButtonLayout()
    }
}

extension ContactsEmptyView {
    @objc
    private func notifyDelegateToAddContact() {
        delegate?.contactsEmptyViewDidTapAddContactButton(self)
    }
}

extension ContactsEmptyView {
    private func setupAddContactButtonLayout() {
        addSubview(addContactButton)
        
        addContactButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(subtitleLabel.snp.bottom).offset(layout.current.topInset)
            make.size.equalTo(layout.current.buttonSize)
        }
    }
}

extension ContactsEmptyView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 12.0
        let buttonSize = CGSize(width: 142.0, height: 52.0)
    }
}

protocol ContactsEmptyViewDelegate: class {
    func contactsEmptyViewDidTapAddContactButton(_ contactsEmptyView: ContactsEmptyView)
}
