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
//   WalletConnectSingleTransactionRequestPresentable.swift

import Foundation

protocol WalletConnectSingleTransactionRequestPresentable: AnyObject {
    func presentSingleWCTransaction(_ transaction: WCTransaction, with request: WalletConnectRequest)
}

extension WalletConnectSingleTransactionRequestPresentable where Self: BaseViewController {
    func presentSingleWCTransaction(_ transaction: WCTransaction, with request: WalletConnectRequest) {
        guard let transactionDetail = transaction.transactionDetail else {
            return
        }

        let account = session?.accounts.first(of: \.address, equalsTo: transactionDetail.sender)
        
        guard let transactionType = transactionDetail.transactionType(for: account) else {
            walletConnector.rejectTransactionRequest(request, with: .unsupported(.unknownTransaction))
            dismissScreen()
            return
        }

        switch transactionType {
        case .algos:
            open(.wcAlgosTransaction(transaction: transaction, transactionRequest: request), by: .push)
        case .asset:
            open(.wcAssetTransaction(transaction: transaction, transactionRequest: request), by: .push)
        case .assetAddition,
             .possibleAssetAddition:
            open(.wcAssetAdditionTransaction( transaction: transaction, transactionRequest: request), by: .push)
        case .appCall:
            open(.wcAppCall(transaction: transaction, transactionRequest: request), by: .push)
        case let .assetConfig(type):
            switch type {
            case .create:
                open(.wcAssetCreationTransaction(transaction: transaction, transactionRequest: request), by: .push)
            case .reconfig:
                open(.wcAssetReconfigurationTransaction(transaction: transaction, transactionRequest: request), by: .push)
            case .delete:
                open(.wcAssetDeletionTransaction(transaction: transaction, transactionRequest: request), by: .push)
            }
        }
    }
}
