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
//   WCTransactionSigner.swift

import Foundation
import MagpieHipo

class WCTransactionSigner {

    weak var delegate: WCTransactionSignerDelegate?

    private lazy var ledgerTransactionOperation =
        LedgerTransactionOperation(api: api, analytics: analytics)

    private var timer: Timer?

    private let api: ALGAPI
    private let analytics: ALGAnalytics

    private var account: Account?
    private var transaction: WCTransaction?
    private var transactionRequest: WalletConnectRequest?

    init(
        api: ALGAPI,
        analytics: ALGAnalytics
    ) {
        self.api = api
        self.analytics = analytics
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
        stopTimer()
    }
}

extension WCTransactionSigner {
    private func signLedgerTransaction(_ transaction: WCTransaction, with transactionRequest: WalletConnectRequest, for account: Account) {
        guard let unsignedTransaction = transaction.unparsedTransactionDetail else {
            delegate?.wcTransactionSigner(self, didFailedWith: .missingUnparsedTransactionDetail)
            return
        }

        self.account = account
        self.transaction = transaction
        self.transactionRequest = transactionRequest

        ledgerTransactionOperation.setTransactionAccount(account)
        ledgerTransactionOperation.delegate = self
        startTimer()
        ledgerTransactionOperation.setUnsignedTransactionData(unsignedTransaction)
        ledgerTransactionOperation.startScan()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            self.ledgerTransactionOperation.bleConnectionManager.stopScan()
            self.delegate?.wcTransactionSigner(self, didFailedWith: .ledger(error: .ledgerConnectionWarning))
            self.stopTimer()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func signStandardTransaction(_ transaction: WCTransaction, with request: WalletConnectRequest, for account: Account) {
        if let signature = api.session.privateData(for: account.signerAddress) {
            sign(signature, signer: SDKTransactionSigner(), for: transaction, with: request)
        }
    }

    private func sign(
        _ signature: Data?,
        signer: TransactionSigner,
        for transaction: WCTransaction,
        with request: WalletConnectRequest
    ) {
        signer.delegate = self

        guard let unsignedTransaction = transaction.unparsedTransactionDetail else {
            delegate?.wcTransactionSigner(self, didFailedWith: .missingUnparsedTransactionDetail)
            return
        }

        guard let signedTransaction = signer.sign(unsignedTransaction, with: signature) else {
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

    func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didRequestUserApprovalFor ledger: String
    ) {
        delegate?.wcTransactionSigner(self, didRequestUserApprovalFrom: ledger)
    }

    func ledgerTransactionOperationDidFinishTimingOperation(_ ledgerTransactionOperation: LedgerTransactionOperation) {
        stopTimer()
        delegate?.wcTransactionSignerDidFinishTimingOperation(self)
    }

    func ledgerTransactionOperationDidResetOperation(_ ledgerTransactionOperation: LedgerTransactionOperation) {
        delegate?.wcTransactionSignerDidResetLedgerOperation(self)
    }

    func ledgerTransactionOperationDidResetOperationOnSuccess(_ ledgerTransactionOperation: LedgerTransactionOperation) {
        delegate?.wcTransactionSignerDidResetLedgerOperationOnSuccess(self)
    }

    func ledgerTransactionOperationDidRejected(_ ledgerTransactionOperation: LedgerTransactionOperation) {
        delegate?.wcTransactionSignerDidRejectedLedgerOperation(self)
    }
}

extension WCTransactionSigner: TransactionSignerDelegate {
    func transactionSigner(_ transactionSigner: TransactionSigner, didFailedSigning error: HIPTransactionError) {
        delegate?.wcTransactionSigner(self, didFailedWith: .api(error: error))
    }
}

extension WCTransactionSigner {
    enum WCSignError: Error {
        case ledger(error: LedgerOperationError)
        case api(error: HIPTransactionError)
        case missingUnparsedTransactionDetail
    }
}

protocol WCTransactionSignerDelegate: AnyObject {
    func wcTransactionSigner(_ wcTransactionSigner: WCTransactionSigner, didSign transaction: WCTransaction, signedTransaction: Data)
    func wcTransactionSigner(_ wcTransactionSigner: WCTransactionSigner, didFailedWith error: WCTransactionSigner.WCSignError)
    func wcTransactionSigner(_ wcTransactionSigner: WCTransactionSigner, didRequestUserApprovalFrom ledger: String)
    func wcTransactionSignerDidFinishTimingOperation(_ wcTransactionSigner: WCTransactionSigner)
    func wcTransactionSignerDidResetLedgerOperation(_ wcTransactionSigner: WCTransactionSigner)
    func wcTransactionSignerDidResetLedgerOperationOnSuccess(_ wcTransactionSigner: WCTransactionSigner)
    func wcTransactionSignerDidRejectedLedgerOperation(_ wcTransactionSigner: WCTransactionSigner)
}
