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
//  SendAssetTransactionViewController.swift

import UIKit

class SendAssetTransactionViewController: SendTransactionViewController, TestNetTitleDisplayable {
    
    private var assetTransactionSendDraft: AssetTransactionSendDraft
    
    init(
        assetTransactionSendDraft: AssetTransactionSendDraft,
        assetReceiverState: AssetReceiverState,
        transactionController: TransactionController,
        isSenderEditable: Bool,
        configuration: ViewControllerConfiguration
    ) {
        self.assetTransactionSendDraft = assetTransactionSendDraft
        super.init(
            assetReceiverState: assetReceiverState,
            transactionController: transactionController,
            isSenderEditable: isSenderEditable,
            configuration: configuration
        )
        
        fee = assetTransactionSendDraft.fee
        transactionController.setTransactionDraft(assetTransactionSendDraft)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        setTitle()
        sendTransactionView.bind(SendTransactionViewModel(transactionDraft: assetTransactionSendDraft))
    }
    
    override func completeTransaction(with id: TransactionID) {
        assetTransactionSendDraft.identifier = id.identifier
        
        if let assetId = assetTransactionSendDraft.assetIndex {
            log(
                TransactionEvent(
                    accountType: assetTransactionSendDraft.from.type,
                    assetId: String(assetId),
                    isMaxTransaction: assetTransactionSendDraft.isMaxTransaction,
                    amount: assetTransactionSendDraft.amount?.toFraction(of: assetTransactionSendDraft.assetDecimalFraction),
                    transactionId: id.identifier
                )
            )
        }
        
        delegate?.sendTransactionViewController(self, didCompleteTransactionFor: assetTransactionSendDraft.assetIndex)
    }
}

extension SendAssetTransactionViewController {
    private func setTitle() {
        guard let assetIndex = assetTransactionSendDraft.assetIndex,
            let assetDetail = assetTransactionSendDraft.from.assetDetails.first(where: { $0.id == assetIndex }) else {
            return
        }
        
        let assetTitle = "title-send".localized + " \(assetDetail.getDisplayNames().0)"
        displayTestNetTitleView(with: assetTitle)
    }
}
