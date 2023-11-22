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

//
//   WalletConnectSingleTransactionRequestPresentable.swift

import Foundation
import MacaroonUtils

protocol WalletConnectSingleTransactionRequestPresentable: AnyObject {
    func presentSingleWCTransaction(
        _ transaction: WCTransaction,
        with request: WalletConnectRequestDraft,
        wcSession: WCSessionDraft
    )
}

extension WalletConnectSingleTransactionRequestPresentable where Self: BaseViewController {
    func presentSingleWCTransaction(
        _ transaction: WCTransaction,
        with request: WalletConnectRequestDraft,
        wcSession: WCSessionDraft
    ) {
        guard
            let transactionDetail = transaction.transactionDetail,
            let senderAddress = transactionDetail.sender
        else {
            return
        }

        let account = sharedDataController.accountCollection[senderAddress]?.value
        
        guard
            let transactionType = transactionDetail.transactionType(for: account)
        else {
            if let wcV1Request = request.wcV1Request {
                let params = WalletConnectV1RejectTransactionRequestParams(v1Request: wcV1Request, error: .unsupported(.unknownTransaction))
                configuration.peraConnect.rejectTransactionRequest(params)
                dismissScreen()
                return
            }

            if let wcV2Request = request.wcV2Request {
                let params = WalletConnectV2RejectTransactionRequestParams(
                    error: .unsupported(.unknownTransaction),
                    v2Request: wcV2Request
                )
                configuration.peraConnect.rejectTransactionRequest(params)
                dismissScreen()
                return
            }

            return
        }

        switch transactionType {
        case .algos:
            open(
                .wcAlgosTransaction(
                    transaction: transaction,
                    transactionRequest: request,
                    wcSession: wcSession
                ),
                by: .push
            )
        case .asset:
            open(
                .wcAssetTransaction(
                    transaction: transaction,
                    transactionRequest: request,
                    wcSession: wcSession
                ),
                by: .push
            )
        case .assetAddition,
                .possibleAssetAddition:
            open(
                .wcAssetAdditionTransaction(
                    transaction: transaction,
                    transactionRequest: request,
                    wcSession: wcSession
                ),
                by: .push
            )
        case .appCall:
            open(
                .wcAppCall(
                    transaction: transaction,
                    transactionRequest: request,
                    wcSession: wcSession
                ),
                by: .push
            )
        case let .assetConfig(type):
            switch type {
            case .create:
                open(
                    .wcAssetCreationTransaction(
                        transaction: transaction,
                        transactionRequest: request,
                        wcSession: wcSession
                    ),
                    by: .push
                )
            case .reconfig:
                open(
                    .wcAssetReconfigurationTransaction(
                        transaction: transaction,
                        transactionRequest: request,
                        wcSession: wcSession
                    ),
                    by: .push
                )
            case .delete:
                open(
                    .wcAssetDeletionTransaction(
                        transaction: transaction,
                        transactionRequest: request,
                        wcSession: wcSession
                    ),
                    by: .push
                )
            }
        case .keyReg:
            open(
                .wcKeyRegTransaction(
                    transaction: transaction,
                    transactionRequest: request,
                    wcSession: wcSession
                ),
                by: .push
            )
        }
    }
}
