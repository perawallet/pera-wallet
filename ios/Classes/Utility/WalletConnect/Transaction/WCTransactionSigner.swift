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
//   WCTransactionSigner.swift

import Foundation
import Magpie

class WCTransactionSigner {

    weak var delegate: WCTransactionSignerDelegate?

    private lazy var ledgerTransactionOperation = LedgerTransactionOperation(api: api)

    private let api: AlgorandAPI

    private var account: Account?
    private var transaction: WCTransaction?
    private var transactionRequest: WalletConnectRequest?

    init(api: AlgorandAPI) {
        self.api = api
    }

    func signTransaction(_ transaction: WCTransaction, with transactionRequest: WalletConnectRequest, for account: Account) {
        if account.requiresLedgerConnection() {
            signLedgerTransaction(transaction, with: transactionRequest, for: account)
        } else {
            signStandardTransaction(transaction, with: transactionRequest, for: account)
        }
    }

    func disonnectFromLedger() {
        ledgerTransactionOperation.disconnectFromCurrentDevice()
        ledgerTransactionOperation.stopScan()
        ledgerTransactionOperation.stopTimer()
    }
}

extension WCTransactionSigner {
    private func signLedgerTransaction(_ transaction: WCTransaction, with transactionRequest: WalletConnectRequest, for account: Account) {
        guard let unsignedTransaction = transaction.unparsedTransactionDetail else {
            return
        }

        self.account = account
        self.transaction = transaction
        self.transactionRequest = transactionRequest

        ledgerTransactionOperation.setTransactionAccount(account)
        ledgerTransactionOperation.delegate = self
        ledgerTransactionOperation.startTimer()
        ledgerTransactionOperation.setUnsignedTransactionData(unsignedTransaction)

        // Needs a bit delay since the bluetooth scanning for the first time is working initially
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.ledgerTransactionOperation.startScan()
        }
    }

    private func signStandardTransaction(_ transaction: WCTransaction, with request: WalletConnectRequest, for account: Account) {
        if let signature = api.session.privateData(for: account.address) {
            sign(signature, signer: SDKTransactionSigner(), for: transaction, with: request)
        }
    }

    private func sign(_ signature: Data?, signer: TransactionSigner, for transaction: WCTransaction, with request: WalletConnectRequest) {
        signer.delegate = self

        guard let unsignedTransaction = transaction.unparsedTransactionDetail,
              let signedTransaction = signer.sign(unsignedTransaction, with: signature) else {
            return
        }

        delegate?.wcTransactionSigner(self, didSign: transaction, signedTransaction: signedTransaction)
    }
}

extension WCTransactionSigner: LedgerTransactionOperationDelegate {
    func ledgerTransactionOperation(_ ledgerTransactionOperation: LedgerTransactionOperation, didReceiveSignature data: Data) {
        guard let account = account,
              let transaction = transaction,
              let request = transactionRequest else {
            return
        }

        sign(data, signer: LedgerTransactionSigner(account: account), for: transaction, with: request)
    }

    func ledgerTransactionOperation(_ ledgerTransactionOperation: LedgerTransactionOperation, didFailed error: LedgerOperationError) {
        delegate?.wcTransactionSigner(self, didFailedWith: .ledger(error: error))
    }
}

extension WCTransactionSigner: TransactionSignerDelegate {
    func transactionSigner(_ transactionSigner: TransactionSigner, didFailedSigning error: HIPError<TransactionError>) {
        delegate?.wcTransactionSigner(self, didFailedWith: .api(error: error))
    }
}

extension WCTransactionSigner {
    enum WCSignError: Error {
        case ledger(error: LedgerOperationError)
        case api(error: HIPError<TransactionError>)
    }
}

protocol WCTransactionSignerDelegate: AnyObject {
    func wcTransactionSigner(_ wcTransactionSigner: WCTransactionSigner, didSign transaction: WCTransaction, signedTransaction: Data)
    func wcTransactionSigner(_ wcTransactionSigner: WCTransactionSigner, didFailedWith error: WCTransactionSigner.WCSignError)
}
