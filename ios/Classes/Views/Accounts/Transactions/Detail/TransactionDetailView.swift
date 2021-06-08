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
//  TransactionDetailView.swift

import UIKit

class TransactionDetailView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: TransactionDetailViewDelegate?
    
    private let transactionType: TransactionType
    
    private lazy var closeToCopyValueGestureRecognizer = UILongPressGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToCopyCloseToView)
    )
    
    private lazy var opponentCopyValueGestureRecognizer = UILongPressGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToCopyOpponentView)
    )
    
    private lazy var noteCopyValueGestureRecognizer = UILongPressGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToCopyNoteView)
    )
    
    private(set) lazy var statusView: TransactionStatusInformationView = {
        let statusView = TransactionStatusInformationView()
        statusView.setTitle("transaction-detail-status".localized)
        return statusView
    }()
    
    private(set) lazy var amountView: TransactionAmountInformationView = {
        let amountView = TransactionAmountInformationView()
        amountView.setTitle("transaction-detail-amount".localized)
        return amountView
    }()
    
    private(set) lazy var closeAmountView: TransactionAmountInformationView = {
        let rewardView = TransactionAmountInformationView()
        rewardView.setTitle("transaction-detail-close-amount".localized)
        return rewardView
    }()
    
    private(set) lazy var rewardView: TransactionAmountInformationView = {
        let rewardView = TransactionAmountInformationView()
        rewardView.setTitle("transaction-detail-reward".localized)
        return rewardView
    }()
    
    private(set) lazy var userView = TransactionTextInformationView()
    
    private(set) lazy var opponentView = TransactionContactInformationView()
    
    private(set) lazy var closeToView: TransactionTextInformationView = {
        let closeToView = TransactionTextInformationView()
        closeToView.setTitle("transaction-detail-close-to".localized)
        closeToView.isUserInteractionEnabled = true
        return closeToView
    }()
    
    private(set) lazy var feeView: TransactionAmountInformationView = {
        let feeView = TransactionAmountInformationView()
        feeView.setTitle("transaction-detail-fee".localized)
        return feeView
    }()
    
    private lazy var dateView: TransactionTextInformationView = {
        let dateView = TransactionTextInformationView()
        dateView.setTitle("transaction-detail-date".localized)
        return dateView
    }()
    
    private(set) lazy var roundView: TransactionTextInformationView = {
        let roundView = TransactionTextInformationView()
        roundView.setTitle("transaction-detail-round".localized)
        return roundView
    }()
    
    private(set) lazy var idView = TransactionIDLabel()
    
    private(set) lazy var noteView: TransactionTitleInformationView = {
        let noteView = TransactionTitleInformationView()
        noteView.setTitle("transaction-detail-note".localized)
        noteView.isUserInteractionEnabled = true
        return noteView
    }()
    
    init(transactionType: TransactionType) {
        self.transactionType = transactionType
        super.init(frame: .zero)
    }
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
        opponentView.isUserInteractionEnabled = true
        closeToView.copyImageView.isHidden = false
        opponentView.copyImageView.isHidden = false
        noteView.copyImageView.isHidden = false
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        opponentView.delegate = self
        closeToView.addGestureRecognizer(closeToCopyValueGestureRecognizer)
        idView.delegate = self
        opponentView.addGestureRecognizer(opponentCopyValueGestureRecognizer)
        noteView.addGestureRecognizer(noteCopyValueGestureRecognizer)
    }
    
    override func prepareLayout() {
        setupStatusViewLayout()
        setupAmountViewLayout()
        setupCloseAmountViewLayout()
        setupRewardViewLayout()
        
        if transactionType == .received {
            setupOpponentViewLayout()
            setupUserViewLayout()
            setupCloseToViewLayout()
        } else {
            setupUserViewLayout()
            setupOpponentViewLayout()
            setupCloseToViewLayout()
        }

        setupFeeViewLayout()
        setupDateViewLayout()
        setupRoundViewLayout()
        setupIdViewLayout()
        setupNoteViewLayout()
    }
}

extension TransactionDetailView {
    private func setupStatusViewLayout() {
        addSubview(statusView)
        
        statusView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.statusViewTopInset)
        }
    }
    
    private func setupAmountViewLayout() {
        addSubview(amountView)
        
        amountView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(statusView.snp.bottom)
        }
    }
    
    private func setupCloseAmountViewLayout() {
        addSubview(closeAmountView)
        
        closeAmountView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(amountView.snp.bottom)
        }
    }
    
    private func setupRewardViewLayout() {
        addSubview(rewardView)
        
        rewardView.snp.makeConstraints { make in
            make.top.equalTo(closeAmountView.snp.bottom)
            make.top.equalTo(amountView.snp.bottom).priority(.low)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupUserViewLayout() {
        addSubview(userView)
        
        userView.snp.makeConstraints { make in
            if transactionType == .received {
                make.top.equalTo(opponentView.snp.bottom)
            } else {
                make.top.equalTo(rewardView.snp.bottom)
                make.top.equalTo(closeAmountView.snp.bottom).priority(.medium)
                make.top.equalTo(amountView.snp.bottom).priority(.low)
            }
            
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupOpponentViewLayout() {
        addSubview(opponentView)
        
        opponentView.snp.makeConstraints { make in
            if transactionType == .received {
                make.top.equalTo(amountView.snp.bottom).priority(.low)
                make.top.equalTo(closeAmountView.snp.bottom).priority(.medium)
                make.top.equalTo(rewardView.snp.bottom)
            } else {
                make.top.equalTo(userView.snp.bottom)
            }
            
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupCloseToViewLayout() {
        addSubview(closeToView)
        
        closeToView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if transactionType == .received {
                make.top.equalTo(userView.snp.bottom)
            } else {
                make.top.equalTo(opponentView.snp.bottom)
            }
        }
    }
    
    private func setupFeeViewLayout() {
        addSubview(feeView)
        
        feeView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if transactionType == .received {
                make.top.equalTo(closeToView.snp.bottom)
                make.top.equalTo(userView.snp.bottom).priority(.low)
            } else {
                make.top.equalTo(closeToView.snp.bottom)
                make.top.equalTo(opponentView.snp.bottom).priority(.low)
            }
        }
    }
    
    private func setupDateViewLayout() {
        addSubview(dateView)
        
        dateView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(feeView.snp.bottom)
        }
    }
    
    private func setupRoundViewLayout() {
        addSubview(roundView)
        
        roundView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(dateView.snp.bottom)
        }
    }
    
    private func setupIdViewLayout() {
        addSubview(idView)
        
        idView.snp.makeConstraints { make in
            make.top.equalTo(roundView.snp.bottom)
            make.top.equalTo(feeView.snp.bottom).priority(.low)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset).priority(.low)
        }
    }
    
    private func setupNoteViewLayout() {
        addSubview(noteView)
        
        noteView.snp.makeConstraints { make in
            make.top.equalTo(idView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension TransactionDetailView: TransactionContactInformationViewDelegate {
    func transactionContactInformationViewDidTapActionButton(_ transactionContactInformationView: TransactionContactInformationView) {
        delegate?.transactionDetailViewDidTapOpponentActionButton(self)
    }
}

extension TransactionDetailView {
    @objc
    private func notifyDelegateToCopyCloseToView() {
        delegate?.transactionDetailViewDidCopyCloseToAddress(self)
    }
    
    @objc
    private func notifyDelegateToCopyOpponentView() {
        delegate?.transactionDetailViewDidCopyOpponentAddress(self)
    }
    
    @objc
    private func notifyDelegateToCopyNoteView() {
        delegate?.transactionDetailViewDidCopyTransactionNote(self)
    }
}

extension TransactionDetailView {
    func setTransactionID(_ id: String) {
        idView.setDetail(id)
    }
    
    func setDate(_ date: String) {
        dateView.setDetail(date)
    }
}

extension TransactionDetailView: TransactionIDLabelDelegate {
    func transactionIDLabel(_ transactionIDLabel: TransactionIDLabel, didOpen explorer: AlgoExplorerType) {
        delegate?.transactionDetailView(self, didOpen: explorer)
    }
}

extension TransactionDetailView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let statusViewTopInset: CGFloat = 12.0
        let bottomInset: CGFloat = 20.0
    }
}

protocol TransactionDetailViewDelegate: class {
    func transactionDetailViewDidTapOpponentActionButton(_ transactionDetailView: TransactionDetailView)
    func transactionDetailViewDidCopyOpponentAddress(_ transactionDetailView: TransactionDetailView)
    func transactionDetailViewDidCopyCloseToAddress(_ transactionDetailView: TransactionDetailView)
    func transactionDetailView(_ transactionDetailView: TransactionDetailView, didOpen explorer: AlgoExplorerType)
    func transactionDetailViewDidCopyTransactionNote(_ transactionDetailView: TransactionDetailView)
}
