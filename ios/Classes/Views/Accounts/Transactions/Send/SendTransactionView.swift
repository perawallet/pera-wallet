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
//  SendTransactionView.swift

import UIKit

class SendTransactionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var transactionDelegate: SendTransactionViewDelegate?
    
    private lazy var containerView = UIView()
    
    private lazy var accountInformationView = TransactionAccountNameView()
    
    private lazy var assetInformationView = TransactionAssetView()
    
    private lazy var amountInformationView = TransactionAmountInformationView()
    
    private lazy var receiverInformationView = TransactionContactInformationView()
    
    private lazy var feeInformationView = TransactionAmountInformationView()
    
    private lazy var noteInformationView = TransactionTitleInformationView()
    
    private lazy var sendButton = MainButton(title: "title-send".localized)
    
    override func configureAppearance() {
        super.configureAppearance()
        containerView.backgroundColor = Colors.Background.secondary
        containerView.layer.cornerRadius = 12.0
        if !isDarkModeDisplay {
            containerView.applySmallShadow()
        }
        amountInformationView.backgroundColor = Colors.Background.secondary
        receiverInformationView.backgroundColor = Colors.Background.secondary
        feeInformationView.backgroundColor = Colors.Background.secondary
        noteInformationView.backgroundColor = Colors.Background.secondary
        amountInformationView.setTitle("transaction-detail-amount".localized)
        receiverInformationView.setTitle("transaction-detail-to".localized)
        receiverInformationView.removeContactAction()
        feeInformationView.setTitle("transaction-detail-fee".localized)
        noteInformationView.setTitle("transaction-detail-note".localized)
    }
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendTransaction), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupContainerViewLayout()
        setupAccountInformationViewLayout()
        setupAssetInformationViewLayout()
        setupAmountInformationViewLayout()
        setupReceiverInformationViewLayout()
        setupFeeInformationViewLayout()
        setupNoteInformationViewLayout()
        setupSendButtonLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isDarkModeDisplay {
            containerView.updateShadowLayoutWhenViewDidLayoutSubviews()
        }
    }
    
    @available(iOS 12.0, *)
    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        if userInterfaceStyle == .dark {
            containerView.removeShadows()
        } else {
            containerView.applySmallShadow()
        }
    }
}

extension SendTransactionView {
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupAccountInformationViewLayout() {
        containerView.addSubview(accountInformationView)
        
        accountInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.itemVerticalInset)
        }
    }
    
    private func setupAssetInformationViewLayout() {
        containerView.addSubview(assetInformationView)
        
        assetInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(accountInformationView.snp.bottom)
        }
    }
    
    private func setupAmountInformationViewLayout() {
        containerView.addSubview(amountInformationView)
        
        amountInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(assetInformationView.snp.bottom)
        }
    }
    
    private func setupReceiverInformationViewLayout() {
        containerView.addSubview(receiverInformationView)
        
        receiverInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(amountInformationView.snp.bottom)
        }
    }
    
    private func setupFeeInformationViewLayout() {
        containerView.addSubview(feeInformationView)
        
        feeInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(receiverInformationView.snp.bottom)
            make.bottom.equalToSuperview().inset(layout.current.itemVerticalInset).priority(.low)
        }
    }
    
    private func setupNoteInformationViewLayout() {
        containerView.addSubview(noteInformationView)
        
        noteInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(feeInformationView.snp.bottom)
            make.bottom.equalToSuperview().inset(layout.current.itemVerticalInset)
        }
    }
    
    private func setupSendButtonLayout() {
        addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension SendTransactionView {
    @objc
    private func notifyDelegateToSendTransaction() {
        transactionDelegate?.sendTransactionViewDidTapSendButton(self)
    }
}

extension SendTransactionView {
    func bind(_ viewModel: SendTransactionViewModel) {
        sendButton.setTitle(viewModel.buttonTitle, for: .normal)
        accountInformationView.bind(viewModel.accountNameViewModel)

        if let amount = viewModel.amount {
            amountInformationView.setAmountViewMode(amount)
        }

        if let fee = viewModel.fee {
            feeInformationView.setAmountViewMode(fee)
        }

        if let note = viewModel.note {
            noteInformationView.setDetail(note)
            noteInformationView.setSeparatorView(hidden: true)
        } else {
            noteInformationView.removeFromSuperview()
            feeInformationView.setSeparatorHidden(true)
        }

        assetInformationView.setAssetName(viewModel.assetName)

        if !viewModel.isDisplayingAssetId {
            assetInformationView.removeAssetId()
        }

        if !viewModel.isDisplayingUnitName {
            assetInformationView.removeAssetUnitName()
        }

        assetInformationView.setAssetAlignment(viewModel.nameAlignment)
        assetInformationView.setAssetId(viewModel.assetId)

        if !viewModel.isVerifiedAsset {
            assetInformationView.removeVerifiedAsset()
        }

        if let contact = viewModel.receiverContact {
            receiverInformationView.setContact(contact)
        } else if let receiver = viewModel.receiverName {
            receiverInformationView.setName(receiver)
            receiverInformationView.removeContactImage()
        }
    }
}

extension SendTransactionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 12.0
        let itemVerticalInset: CGFloat = 8.0
        let verticalInset: CGFloat = 28.0
        let horizontalInset: CGFloat = 20.0
    }
}

protocol SendTransactionViewDelegate: AnyObject {
    func sendTransactionViewDidTapSendButton(_ sendTransactionView: SendTransactionView)
}
