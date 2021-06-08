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
//  SendAlgosTransactionPreviewViewModel.swift

import UIKit

class SendAlgosTransactionPreviewViewModel {
    private let isAccountSelectionEnabled: Bool
    
    init(isAccountSelectionEnabled: Bool) {
        self.isAccountSelectionEnabled = isAccountSelectionEnabled
    }
    
    func configure(_ view: SendTransactionPreviewView, with selectedAccount: Account?) {
        guard let account = selectedAccount else {
            return
        }
        
        if isAccountSelectionEnabled {
            view.transactionAccountInformationView.setEnabled()
        } else {
            view.transactionAccountInformationView.setDisabled()
        }
        
        view.transactionAccountInformationView.setAccountImage(account.accountImage())
        view.transactionAccountInformationView.setAccountName(account.name)
        view.transactionAccountInformationView.setAmount(account.amount.toAlgos.toAlgosStringForLabel)
        view.amountInputView.maxAmount = account.amount.toAlgos
        view.transactionAccountInformationView.setAssetName("asset-algos-title".localized)
        view.transactionAccountInformationView.removeAssetId()
    }
    
    func update(_ view: SendTransactionPreviewView, with account: Account, isMaxTransaction: Bool) {
        view.transactionAccountInformationView.setAccountName(account.name)
        view.transactionAccountInformationView.setAccountImage(account.accountImage())
        view.transactionAccountInformationView.setAmount(account.amount.toAlgos.toAlgosStringForLabel)
        view.amountInputView.maxAmount = account.amount.toAlgos

        if isMaxTransaction {
            view.amountInputView.inputTextField.text = account.amount.toAlgos.toAlgosStringForLabel
        }
    }
}
