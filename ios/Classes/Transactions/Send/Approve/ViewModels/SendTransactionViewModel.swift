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
//  SendTransactionViewModel.swift

import UIKit

class SendTransactionViewModel {
    private(set) var buttonTitle: String?
    private(set) var accountNameViewModel: AccountNameViewModel?
    private(set) var amount: TransactionAmountView.Mode?
    private(set) var fee: TransactionAmountView.Mode?
    private(set) var note: String?

    private(set) var assetName: String?
    private(set) var isDisplayingAssetId: Bool = false
    private(set) var isDisplayingUnitName: Bool = false
    private(set) var nameAlignment: NSTextAlignment = .right
    private(set) var assetId: String?
    private(set) var isVerifiedAsset: Bool = false

    private(set) var receiverName: String?
    private(set) var receiverContact: Contact?

    init(transactionDraft: TransactionSendDraft) {
        setButtonTitle(from: transactionDraft)
        setAccountNameViewModel(from: transactionDraft)
        setAmount(from: transactionDraft)
        setFee(from: transactionDraft)
        setNote(from: transactionDraft)
        setAssetName(from: transactionDraft)
        setIsDisplayingAssetId(from: transactionDraft)
        setIsDisplayingUnitName(from: transactionDraft)
        setNameAlignment()
        setAssetId(from: transactionDraft)
        setIsVerifiedAsset(from: transactionDraft)
        setReceiver(from: transactionDraft)
    }

    private func setButtonTitle(from transactionDraft: TransactionSendDraft) {
        if transactionDraft is AlgosTransactionSendDraft {
            buttonTitle = "send-algos-title".localized
            return
        }

        if let draft = transactionDraft as? AssetTransactionSendDraft,
           let assetIndex = draft.assetIndex,
           let assetDetail = draft.from.assetDetails.first(where: { $0.id == assetIndex }) {
            buttonTitle = "title-send".localized + " \(assetDetail.getDisplayNames().0)"
            return
        }
    }

    private func setAccountNameViewModel(from transactionDraft: TransactionSendDraft) {
        accountNameViewModel = AccountNameViewModel(account: transactionDraft.from)
    }

    private func setAmount(from transactionDraft: TransactionSendDraft) {
        if let transactionAmount = transactionDraft.amount {
            if transactionDraft is AlgosTransactionSendDraft {
                amount = .normal(amount: transactionAmount)
                return
            }

            if let draft = transactionDraft as? AssetTransactionSendDraft {
                amount = .normal(amount: transactionAmount, isAlgos: false, fraction: draft.assetDecimalFraction)
                return
            }
        }
    }

    private func setFee(from transactionDraft: TransactionSendDraft) {
        if var receivedFee = transactionDraft.fee {
            if receivedFee < Transaction.Constant.minimumFee {
                receivedFee = Transaction.Constant.minimumFee
            }

            fee = .normal(amount: receivedFee.toAlgos)
        }
    }

    private func setNote(from transactionDraft: TransactionSendDraft) {
        if let transactionNote = transactionDraft.note,
           !transactionNote.isEmpty {
            note = transactionNote
        }
    }

    private func setAssetName(from transactionDraft: TransactionSendDraft) {
        if transactionDraft is AlgosTransactionSendDraft {
            assetName = "asset-algos-title".localized
            return
        }

        if let draft = transactionDraft as? AssetTransactionSendDraft {
            guard let assetIndex = draft.assetIndex,
                let assetDetail = draft.from.assetDetails.first(where: { $0.id == assetIndex }) else {
                return
            }

            if assetDetail.hasBothDisplayName() || assetDetail.hasOnlyAssetName() {
                assetName = assetDetail.unitName
                return
            }

            if assetDetail.hasOnlyUnitName() {
                assetName = assetDetail.unitName
                return
            }

            if assetDetail.hasNoDisplayName() {
                assetName = "title-unknown".localized
                return
            }
        }
    }

    private func setIsDisplayingUnitName(from transactionDraft: TransactionSendDraft) {
        isDisplayingUnitName = false
    }

    private func setIsDisplayingAssetId(from transactionDraft: TransactionSendDraft) {
        isDisplayingAssetId = transactionDraft is AssetTransactionSendDraft
    }

    private func setNameAlignment() {
        nameAlignment = .right
    }

    private func setAssetId(from transactionDraft: TransactionSendDraft) {
        if let draft = transactionDraft as? AssetTransactionSendDraft,
           let assetIndex = draft.assetIndex,
           let assetDetail = draft.from.assetDetails.first(where: { $0.id == assetIndex }) {
            assetId = "\(assetDetail.id )"
        }
    }

    private func setIsVerifiedAsset(from transactionDraft: TransactionSendDraft) {
        if transactionDraft is AlgosTransactionSendDraft {
            isVerifiedAsset = true
            return
        }

        if let draft = transactionDraft as? AssetTransactionSendDraft {
            isVerifiedAsset = draft.isVerifiedAsset
            return
        }
    }
    
    private func setReceiver(from transactionDraft: TransactionSendDraft) {
        guard let receiverAddress = transactionDraft.toAccount?.address else {
            return
        }

        Contact.fetchAll(entity: Contact.entityName, with: NSPredicate(format: "address = %@", receiverAddress)) { response in
            switch response {
            case let .results(objects: objects):
                guard let contacts = objects as? [Contact], !contacts.isEmpty else {
                    self.receiverName = receiverAddress.shortAddressDisplay()
                    return
                }

                self.receiverContact = contacts[0]
            default:
                self.receiverName = receiverAddress.shortAddressDisplay()
            }
        }
    }
}
