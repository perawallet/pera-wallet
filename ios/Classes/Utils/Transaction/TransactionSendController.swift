// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   TransactionSendController.swift

import Foundation
import UIKit

final class TransactionSendController {
    weak var delegate: TransactionSendControllerDelegate?

    var isClosingToSameAccount: Bool {
        if let receiverAddress = draft.toAccount?.address {
            return draft.isMaxTransaction && receiverAddress == draft.from.address
        }

        if let contactAddress = draft.toContact?.address {
            return draft.isMaxTransaction && contactAddress == draft.from.address
        }

        return false
    }

    let draft: SendTransactionDraft

    private let api: ALGAPI
    private let analytics: ALGAnalytics

    init(
        draft: SendTransactionDraft,
        api: ALGAPI,
        analytics: ALGAnalytics
    ) {
        self.draft = draft
        self.api = api
        self.analytics = analytics
    }
    

    func validate() {
        if isClosingToSameAccount {
            delegate?.transactionSendController(self, didFailValidation: .closingSameAccount)
            return
        }

        switch draft.transactionMode {
        case .algo:
            validateForAlgoTransaction()
        case .asset:
            validateForAssetTransaction()
        }
    }
}

extension TransactionSendController {
    private func validateForAlgoTransaction() {
        guard let amount = draft.amount else {
            delegate?.transactionSendController(self, didFailValidation: .amountNotSpecified)
            return
        }

        if amount.toMicroAlgos < minimumTransactionMicroAlgosLimit {
            var receiverAddress: String?

            if let contact = draft.toContact {
                receiverAddress = contact.address
            } else {
                receiverAddress = draft.toAccount?.address
            }

            guard var receiverAddress = receiverAddress else {
                delegate?.transactionSendController(self, didFailValidation: .algo(.algoAddressNotSelected))
                return
            }

            receiverAddress = receiverAddress.trimmingCharacters(in: .whitespacesAndNewlines)

            if !receiverAddress.isValidatedAddress {
                delegate?.transactionSendController(self, didFailValidation: .algo(.invalidAddressSelected))
                return
            }

            let receiverFetchDraft = AccountFetchDraft(publicKey: receiverAddress)

            api.fetchAccount(
                receiverFetchDraft,
                queue: .main,
                ignoreResponseOnCancelled: true
            ) { [weak self] accountResponse in
                guard let self = self else { return }

                switch accountResponse {
                case let .failure(error, _):
                    if error.isHttpNotFound {
                        self.delegate?.transactionSendController(self, didFailValidation: .algo(.minimumAmount))
                    } else {
                        self.delegate?.transactionSendController(self, didFailValidation: .internetConnection)
                    }
                case let .success(accountWrapper):
                    if !accountWrapper.account.isSameAccount(with: receiverAddress) {
                        self.delegate?.transactionSendController(self, didFailValidation: .mismatchReceiverAddress)
                        return
                    }

                    if accountWrapper.account.algo.amount == 0 {
                        self.delegate?.transactionSendController(self, didFailValidation: .algo(.minimumAmount))
                    } else {
                        self.delegate?.transactionSendControllerDidValidate(self)
                    }
                }
            }
            return
        } else {
            self.delegate?.transactionSendControllerDidValidate(self)
        }
    }

    private func validateForAssetTransaction() {
        if let contact = draft.toContact, let contactAddress = contact.address {
            checkIfAddressIsValidForTransaction(contactAddress)
        } else if let address = draft.toAccount?.address {
            checkIfAddressIsValidForTransaction(address)
        }
    }

    private func checkIfAddressIsValidForTransaction(_ address: String) {
        guard let asset = draft.asset else {
            return
        }

        if !address.isValidatedAddress {
            self.delegate?.transactionSendController(self, didFailValidation: .algo(.invalidAddressSelected))
            return
        }

        let draft = AccountFetchDraft(publicKey: address)

        api.fetchAccount(
            draft,
            queue: .main,
            ignoreResponseOnCancelled: true
        ) { [weak self] fetchAccountResponse in
            guard let self = self else { return }

            switch fetchAccountResponse {
            case let .success(receiverAccountWrapper):
                if !receiverAccountWrapper.account.isSameAccount(with: address) {
                    self.delegate?.transactionSendController(self, didFailValidation: .mismatchReceiverAddress)
                    return
                }

                let receiverAccount = receiverAccountWrapper.account

                if let assets = receiverAccount.assets {
                    if assets.contains(where: { anAsset -> Bool in
                        asset.id == anAsset.id
                    }) {
                        self.validateAssetTransaction()
                    } else {
                        self.delegate?.transactionSendController(self, didFailValidation: .asset(.assetNotSupported(address)))
                    }
                } else {
                    self.delegate?.transactionSendController(self, didFailValidation: .asset(.assetNotSupported(address)))
                }
            case let .failure(error, _):
                if error.isHttpNotFound {
                    self.delegate?.transactionSendController(self, didFailValidation: .asset(.assetNotSupported(address)))
                } else {
                    self.delegate?.transactionSendController(self, didFailValidation: .internetConnection)
                }
            }
        }
    }

    private func validateAssetTransaction() {
        guard let amount = self.draft.amount,
              let asset = draft.asset else {
            self.delegate?.transactionSendController(self, didFailValidation: .amountNotSpecified)
            return
        }

        if asset.amountWithFraction < amount {
            self.delegate?.transactionSendController(self, didFailValidation: .asset(.minimumAmount))
            return
        }

        self.delegate?.transactionSendControllerDidValidate(self)
    }
}

protocol TransactionSendControllerDelegate: AnyObject {
    func transactionSendController(
        _ controller: TransactionSendController,
        didFailValidation error: TransactionSendControllerError
    )
    func transactionSendControllerDidValidate(_ controller: TransactionSendController)
}

enum TransactionSendControllerError {
    case closingSameAccount
    case amountNotSpecified
    case algo(TransactionSendControllerAlgoError)
    case asset(TransactionSendControllerAssetError)
    case internetConnection
    case mismatchReceiverAddress
}

enum TransactionSendControllerAlgoError {
    case algoAddressNotSelected
    case invalidAddressSelected
    case minimumAmount
}
enum TransactionSendControllerAssetError {
    case assetNotSupported(String)
    case minimumAmount
}

