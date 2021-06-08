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
//  SendAlgosTransactionViewController.swift

import UIKit

class SendAlgosTransactionViewController: SendTransactionViewController, TestNetTitleDisplayable {
    
    private var algosTransactionSendDraft: AlgosTransactionSendDraft
    
    init(
        algosTransactionSendDraft: AlgosTransactionSendDraft,
        assetReceiverState: AssetReceiverState,
        transactionController: TransactionController,
        isSenderEditable: Bool,
        configuration: ViewControllerConfiguration
    ) {
        self.algosTransactionSendDraft = algosTransactionSendDraft
        super.init(
            assetReceiverState: assetReceiverState,
            transactionController: transactionController,
            isSenderEditable: isSenderEditable,
            configuration: configuration
        )
        
        fee = algosTransactionSendDraft.fee
        transactionController.setTransactionDraft(algosTransactionSendDraft)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        sendTransactionView.bind(SendTransactionViewModel(transactionDraft: algosTransactionSendDraft))
        displayTestNetTitleView(with: "send-algos-title".localized)
    }
    
    override func completeTransaction(with id: TransactionID) {
        algosTransactionSendDraft.identifier = id.identifier
        
        log(
            TransactionEvent(
                accountType: algosTransactionSendDraft.from.type,
                assetId: nil,
                isMaxTransaction: algosTransactionSendDraft.isMaxTransaction,
                amount: algosTransactionSendDraft.amount?.toMicroAlgos
            )
        )
    }
}
