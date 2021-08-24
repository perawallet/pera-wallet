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
//  TransactionActionsView.swift

import UIKit

class TransactionActionsView: BaseView {
    
    weak var delegate: TransactionActionsViewDelegate?
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var sendButton: UIButton = {
        UIButton(type: .custom).withImage(img("img-send")).withAlignment(.center)
    }()
    
    private lazy var sendTitle: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.secondary)
            .withText("title-send".localized)
    }()
    
    private lazy var receiveButton: UIButton = {
        UIButton(type: .custom).withImage(img("img-receive")).withAlignment(.center)
    }()
    
    private lazy var receiveTitle: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.secondary)
            .withText("title-receive".localized)
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendTransaction), for: .touchUpInside)
        receiveButton.addTarget(self, action: #selector(notifyDelegateToRequestTransaction), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupSendButtonLayout()
        setupReceiveButtonLayout()
        setupSendTitleLayout()
        setupReceiveTitleLayout()
    }
}

extension TransactionActionsView {
    @objc
    private func notifyDelegateToSendTransaction() {
        delegate?.transactionActionsViewDidSendTransaction(self)
    }
    
    @objc
    private func notifyDelegateToRequestTransaction() {
        delegate?.transactionActionsViewDidRequestTransaction(self)
    }
}

extension TransactionActionsView {
    private func setupSendButtonLayout() {
        addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.buttonTopInset)
            make.centerX.equalToSuperview().offset(-layout.current.buttonCenterOffset)
            make.size.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupReceiveButtonLayout() {
        addSubview(receiveButton)
        
        receiveButton.snp.makeConstraints { make in
            make.top.equalTo(sendButton)
            make.centerX.equalToSuperview().offset(layout.current.buttonCenterOffset)
            make.size.equalTo(sendButton)
        }
    }
    
    private func setupSendTitleLayout() {
        addSubview(sendTitle)
        
        sendTitle.snp.makeConstraints { make in
            make.top.equalTo(sendButton.snp.bottom).offset(layout.current.titleTopInset)
            make.centerX.equalTo(sendButton)
        }
    }
    
    private func setupReceiveTitleLayout() {
        addSubview(receiveTitle)
        
        receiveTitle.snp.makeConstraints { make in
            make.top.equalTo(receiveButton.snp.bottom).offset(layout.current.titleTopInset)
            make.centerX.equalTo(receiveButton)
        }
    }
}

extension TransactionActionsView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let buttonTopInset: CGFloat = 16.0
        let buttonCenterOffset: CGFloat = 46.0
        let buttonSize = CGSize(width: 48.0, height: 48.0)
        let titleTopInset: CGFloat = 4.0
    }
}

protocol TransactionActionsViewDelegate: AnyObject {
    func transactionActionsViewDidRequestTransaction(_ transactionActionsView: TransactionActionsView)
    func transactionActionsViewDidSendTransaction(_ transactionActionsView: TransactionActionsView)
}
