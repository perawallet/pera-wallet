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
//  TransactionReceiverSelectionView.swift

import UIKit

class TransactionReceiverSelectionView: BaseView {
    
    weak var delegate: TransactionReceiverSelectionViewDelegate?
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 12.0
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private lazy var accountsButton = TransactionReceiverButton(title: "accounts-title".localized, image: img("icon-receiver-accounts"))
    
    private lazy var contactButton = TransactionReceiverButton(title: "send-algos-contacts".localized, image: img("icon-receiver-contact"))
    
    private lazy var addressButton = TransactionReceiverButton(title: "send-algos-address".localized, image: img("icon-receiver-address"))
    
    private lazy var qrButton = TransactionReceiverButton(title: "send-algos-scan".localized, image: img("icon-receiver-qr"))
    
    override func setListeners() {
        accountsButton.addTarget(self, action: #selector(notifyDelegateToOpenAccounts), for: .touchUpInside)
        contactButton.addTarget(self, action: #selector(notifyDelegateToOpenContacts), for: .touchUpInside)
        addressButton.addTarget(self, action: #selector(notifyDelegateToOpenAddressInput), for: .touchUpInside)
        qrButton.addTarget(self, action: #selector(notifyDelegateToScanQR), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupStackViewLayout()
    }
}

extension TransactionReceiverSelectionView {
    @objc
    private func notifyDelegateToOpenAccounts() {
        delegate?.transactionReceiverSelectionViewDidTapAccountsButton(self)
    }
    
    @objc
    private func notifyDelegateToOpenContacts() {
        delegate?.transactionReceiverSelectionViewDidTapContactsButton(self)
    }
    
    @objc
    private func notifyDelegateToOpenAddressInput() {
        delegate?.transactionReceiverSelectionViewDidTapAddressButton(self)
    }
    
    @objc
    private func notifyDelegateToScanQR() {
        delegate?.transactionReceiverSelectionViewDidTapQRButton(self)
    }
}

extension TransactionReceiverSelectionView {
    private func setupStackViewLayout() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20.0)
            make.bottom.equalToSuperview()
        }
        
        stackView.addArrangedSubview(accountsButton)
        stackView.addArrangedSubview(contactButton)
        stackView.addArrangedSubview(addressButton)
        stackView.addArrangedSubview(qrButton)
    }
}

protocol TransactionReceiverSelectionViewDelegate: AnyObject {
    func transactionReceiverSelectionViewDidTapAccountsButton(_ transactionReceiverSelectionView: TransactionReceiverSelectionView)
    func transactionReceiverSelectionViewDidTapContactsButton(_ transactionReceiverSelectionView: TransactionReceiverSelectionView)
    func transactionReceiverSelectionViewDidTapAddressButton(_ transactionReceiverSelectionView: TransactionReceiverSelectionView)
    func transactionReceiverSelectionViewDidTapQRButton(_ transactionReceiverSelectionView: TransactionReceiverSelectionView)
}
