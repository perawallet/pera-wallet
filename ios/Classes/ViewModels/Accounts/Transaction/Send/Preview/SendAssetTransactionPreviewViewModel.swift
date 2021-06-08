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
//  SendAssetTransactionPreviewViewModel.swift

import UIKit

class SendAssetTransactionPreviewViewModel {
    private let assetDetail: AssetDetail
    private let isForcedMaxTransaction: Bool
    private let isAccountSelectionEnabled: Bool
    
    init(assetDetail: AssetDetail, isForcedMaxTransaction: Bool, isAccountSelectionEnabled: Bool) {
        self.assetDetail = assetDetail
        self.isForcedMaxTransaction = isForcedMaxTransaction
        self.isAccountSelectionEnabled = isAccountSelectionEnabled
    }
    
    func configure(_ view: SendTransactionPreviewView, with selectedAccount: Account?) {
        if isAccountSelectionEnabled {
            view.transactionAccountInformationView.setEnabled()
        } else {
            view.transactionAccountInformationView.setDisabled()
        }
        
        view.transactionAccountInformationView.setAssetName(for: assetDetail)
        
        if !assetDetail.isVerified {
            view.transactionAccountInformationView.removeVerifiedAsset()
        }
        
        if let account = selectedAccount,
            let assetAmount = account.amount(for: assetDetail) {
            view.transactionAccountInformationView.setAccountImage(account.accountImage())
            view.transactionAccountInformationView.setAccountName(account.name)
            
            view.amountInputView.maxAmount = assetAmount
            view.transactionAccountInformationView.setAmount(assetAmount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals))
        }
        
        if isForcedMaxTransaction {
            view.amountInputView.inputTextField.text = selectedAccount?.amountDisplayWithFraction(for: assetDetail)
            view.amountInputView.setEnabled(false)
        }
    }
    
    func update(_ view: SendTransactionPreviewView, with account: Account, isMaxTransaction: Bool) {
        guard let assetAmount = account.amount(for: assetDetail) else {
            return
        }
        
        view.transactionAccountInformationView.setAccountImage(account.accountImage())
        view.transactionAccountInformationView.setAccountName(account.name)
        
        view.amountInputView.maxAmount = assetAmount
        view.transactionAccountInformationView.setAmount(assetAmount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals))
        
        if isMaxTransaction {
            view.amountInputView.inputTextField.text = assetAmount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
        }
    }
}
