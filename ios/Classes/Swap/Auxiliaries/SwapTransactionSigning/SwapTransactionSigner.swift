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

//   SwapTransactionSigner.swift

import Foundation

final class SwapTransactionSigner:
    LedgerTransactionOperationDelegate,
    TransactionSignerDelegate {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var ledgerTransactionOperation = LedgerTransactionOperation(
        api: api,
        analytics: analytics
    )

    private var timer: Timer?

    private let api: ALGAPI
    private let analytics: ALGAnalytics

    private var account: Account?
    private var unsignedTransaction: Data?

    init(
        api: ALGAPI,
        analytics: ALGAnalytics
    ) {
        self.api = api
        self.analytics = analytics
    }

    func signTransaction(
        _ unsignedTransaction: Data,
        for account: Account
    ) {
        if account.requiresLedgerConnection() {
            signLedgerTransaction(
                unsignedTransaction,
                for: account
            )
        } else {
            signStandardTransaction(
                unsignedTransaction,
                for: account
            )
        }
    }

    func disonnectFromLedger() {
        ledgerTransactionOperation.disconnectFromCurrentDevice()
        ledgerTransactionOperation.stopScan()
        stopTimer()
    }
}

extension SwapTransactionSigner {
    private func signLedgerTransaction(
        _ unsignedTransaction: Data,
        for account: Account
    ) {
        self.unsignedTransaction = unsignedTransaction
        self.account = account

        ledgerTransactionOperation.setTransactionAccount(account)
        ledgerTransactionOperation.delegate = self
        startTimer()
        ledgerTransactionOperation.setUnsignedTransactionData(unsignedTransaction)

        // Needs a bit delay since the bluetooth scanning for the first time is working initially
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.ledgerTransactionOperation.startScan()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            self.ledgerTransactionOperation.bleConnectionManager.stopScan()
            self.eventHandler?(.didFailSigning(error: .ledger(error: .ledgerConnectionWarning)))
            self.stopTimer()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func signStandardTransaction(
        _ unsignedTransaction: Data,
        for account: Account
    ) {
        self.unsignedTransaction = unsignedTransaction
        self.account = account

        guard let signature = api.session.privateData(for: account.signerAddress) else {
            return
        }

        sign(
            signature: signature,
            signer: SDKTransactionSigner(),
            unsignedTransaction: unsignedTransaction
        )
    }

    private func sign(
        signature: Data?,
        signer: TransactionSigner,
        unsignedTransaction: Data
    ) {
        signer.delegate = self

        guard let signedTransaction = signer.sign(unsignedTransaction, with: signature) else {
            return
        }

        eventHandler?(.didSignTransaction(signedTransaction: signedTransaction))
    }
}

extension SwapTransactionSigner {
    func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didReceiveSignature data: Data
    ) {
        if let account {
            sign(
                signature: data,
                signer: LedgerTransactionSigner(account: account),
                unsignedTransaction: unsignedTransaction!
            )
        }
    }

    func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didFailed error: LedgerOperationError
    ) {
        eventHandler?(.didFailSigning(error: .ledger(error: error)))
    }

    func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didRequestUserApprovalFor ledger: String
    ) {
        eventHandler?(.didLedgerRequestUserApproval(ledger: ledger))
    }

    func ledgerTransactionOperationDidFinishTimingOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        stopTimer()
        eventHandler?(.didFinishTiming)
    }

    func ledgerTransactionOperationDidResetOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        eventHandler?(.didLedgerReset)
    }

    func ledgerTransactionOperationDidRejected(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        eventHandler?(.didLedgerRejectSigning)
    }
}

extension SwapTransactionSigner {
    func transactionSigner(
        _ transactionSigner: TransactionSigner,
        didFailedSigning error: HIPTransactionError
    ) {
        eventHandler?(.didFailSigning(error: .api(error: error)))
    }
}

extension SwapTransactionSigner {
    enum SignError: Error {
        case ledger(error: LedgerOperationError)
        case api(error: HIPTransactionError)
    }
}

extension SwapTransactionSigner {
    enum Event {
        case didSignTransaction(signedTransaction: Data)
        case didFailSigning(error: SignError)
        case didLedgerRequestUserApproval(ledger: String)
        case didFinishTiming
        case didLedgerReset
        case didLedgerRejectSigning
    }
}
