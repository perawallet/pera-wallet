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
//  LedgerTransactionOperation.swift

import UIKit
import CoreBluetooth

class LedgerTransactionOperation: LedgerOperation, BLEConnectionManagerDelegate, LedgerBLEControllerDelegate {
    var bleConnectionManager: BLEConnectionManager {
        return accountFetchOperation.bleConnectionManager
    }
    
    var ledgerBleController: LedgerBLEController {
        return accountFetchOperation.ledgerBleController
    }

    var connectedDevice: CBPeripheral?
    
    private var isCorrectLedgerAddressFetched = false
    
    weak var delegate: LedgerTransactionOperationDelegate?
    
    private var ledgerAccountIndex = 0
    
    private let api: ALGAPI
    private let analytics: ALGAnalytics

    private var transaction: WCTransaction?
    private var account: Account?
    private var unsignedTransactionData: Data?
    
    private lazy var accountFetchOperation =
        LedgerAccountFetchOperation(api: api, analytics: analytics)
    
    init(
        api: ALGAPI,
        analytics: ALGAnalytics
    ) {
        self.api = api
        self.analytics = analytics

        bleConnectionManager.delegate = self
        ledgerBleController.delegate = self
        accountFetchOperation.delegate = self
    }
    
    func setUnsignedTransactionData(_ unsignedTransaction: Data?) {
        self.unsignedTransactionData = unsignedTransaction
    }

    func setTransaction(_ transaction: WCTransaction) {
        self.transaction = transaction
    }
    
    func setTransactionAccount(_ account: Account) {
        self.account = account
    }
}

extension LedgerTransactionOperation {
    func startOperation() {
        if isCorrectLedgerAddressFetched {
            sendTransactionSignInstruction()
        } else {
            accountFetchOperation.startOperation()
        }
    }
    
    func completeOperation(with data: Data) {
        if data.isErrorResponseFromLedger {
            if data.hasNextPageForLedgerResponse {
                return
            }

            if data.isLedgerTransactionCancelledError {
                delegate?.ledgerTransactionOperationDidRejected(self)
                delegate?.ledgerTransactionOperation(self, didFailed: .cancelled)
            } else {
                delegate?.ledgerTransactionOperation(self, didFailed: .closedApp)
            }

            reset()
            return
        }

        if !isCorrectLedgerAddressFetched {
            accountFetchOperation.completeOperation(with: data)
            return
        }

        guard let signature = parseSignedTransaction(from: data) else {
            reset()
            delegate?.ledgerTransactionOperation(self, didFailed: .failedToSign)
            return
        }

        resetOnSuccess()
        
        delegate?.ledgerTransactionOperation(self, didReceiveSignature: signature)
    }
    
    func handleDiscoveryResults(_ peripherals: [CBPeripheral]) {
        let savedPeripheralId: UUID?

        if transaction?.authAddress != nil {
            savedPeripheralId = account?.ledgerDetail?.id
        } else {
            savedPeripheralId = account?.currentLedgerDetail?.id
        }

        guard let savedPeripheralId,
              let savedPeripheral = peripherals.first(where: { $0.identifier == savedPeripheralId }) else {
            return
        }
        
        bleConnectionManager.connectToDevice(savedPeripheral)
    }
    
    func reset() {
        reset {
            delegate?.ledgerTransactionOperationDidResetOperation(self)
        }
    }

    /// This is a temporary solution for handling reset operations as successful resets until the whole flow is refactored.
    /// A successful reset means that you should not cancel any pending opt-in/opt-out requests in the delegate method implementation.
    /// The actual `reset` method is used for failure cases.
    private func resetOnSuccess() {
        reset {
            delegate?.ledgerTransactionOperationDidResetOperationOnSuccess(self)
        }
    }

    private func reset(then completion: () -> Void) {
        accountFetchOperation.reset()
        stopScan()
        disconnectFromCurrentDevice()
        unsignedTransactionData = nil
        connectedDevice = nil
        completion()
        isCorrectLedgerAddressFetched = false
    }

    func returnError(_ error: LedgerOperationError) {
        delegate?.ledgerTransactionOperation(self, didFailed: error)
    }

    func finishTimingOperation() {
        delegate?.ledgerTransactionOperationDidFinishTimingOperation(self)
    }

    func requestUserApproval() {
        delegate?.ledgerTransactionOperation(self, didRequestUserApprovalFor: (connectedDevice?.name).emptyIfNil)
    }
}

extension LedgerTransactionOperation {
    private func sendTransactionSignInstruction() {
        guard let hexString = unsignedTransactionData?.toHexString(),
            let unsignedTransaction = Data(fromHexEncodedString: hexString) else {
            return
        }
        
        ledgerBleController.signTransaction(unsignedTransaction, atLedgerAccount: ledgerAccountIndex)
    }

    private func parseSignedTransaction(from data: Data) -> Data? {
        if data.isLedgerTransactionCancelledError || data.isLedgerError {
            return nil
        }
        
        /// Remove last two bytes to fetch data since it declares status codes.
        var signatureData = data
        signatureData.removeLast(2)
      
        if signatureData.isEmpty {
            return nil
        }
        
        return signatureData
    }
}

extension LedgerTransactionOperation: LedgerAccountFetchOperationDelegate {
    func ledgerAccountFetchOperation(
        _ ledgerAccountFetchOperation: LedgerAccountFetchOperation,
        didReceive accounts: [Account]
    ) {
        completeLedgerAccountFetchOperationResults(for: accounts)
        proceedSigningTransactionByLedgerIfPossible()
    }
    
    private func completeLedgerAccountFetchOperationResults(for accounts: [Account]) {
        guard let transactionAccount = account else {
            return
        }
        
        if let index = accounts.firstIndex(where: { account -> Bool in
            if let transactionAuthAddress = transaction?.authAddress {
                return transactionAuthAddress == account.address
            }

            return transactionAccount.authAddress.unwrap(or: transactionAccount.address) == account.address
        }) {
            ledgerAccountIndex = index
            isCorrectLedgerAddressFetched = true
        }
    }
    
    private func proceedSigningTransactionByLedgerIfPossible() {
        if isCorrectLedgerAddressFetched {
            sendTransactionSignInstruction()
        } else {
            reset()
            delegate?.ledgerTransactionOperation(self, didFailed: .unmatchedAddress)
        }
    }
    
    func ledgerAccountFetchOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation, didDiscover peripherals: [CBPeripheral]) {
    }
    
    func ledgerAccountFetchOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation, didFailed error: LedgerOperationError) {
        reset()
        delegate?.ledgerTransactionOperation(self, didFailed: error)
    }

    func ledgerAccountFetchOperation(
        _ ledgerAccountFetchOperation: LedgerAccountFetchOperation,
        didRequestUserApprovalFor ledger: String
    ) {

    }

    func ledgerAccountFetchOperationDidFinishTimingOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation) {
        delegate?.ledgerTransactionOperationDidFinishTimingOperation(self)
    }

    func ledgerAccountFetchOperationDidResetOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation) {
        
    }
}

protocol LedgerTransactionOperationDelegate: AnyObject {
    func ledgerTransactionOperation(_ ledgerTransactionOperation: LedgerTransactionOperation, didReceiveSignature data: Data)
    func ledgerTransactionOperation(_ ledgerTransactionOperation: LedgerTransactionOperation, didFailed error: LedgerOperationError)
    func ledgerTransactionOperationDidRejected(_ ledgerTransactionOperation: LedgerTransactionOperation)
    func ledgerTransactionOperation(_ ledgerTransactionOperation: LedgerTransactionOperation, didRequestUserApprovalFor ledger: String)
    func ledgerTransactionOperationDidFinishTimingOperation(_ ledgerTransactionOperation: LedgerTransactionOperation)
    func ledgerTransactionOperationDidResetOperation(_ ledgerTransactionOperation: LedgerTransactionOperation)

    /// This is a temporary solution for handling reset operations as successful resets until the whole flow is refactored.
    /// A successful reset means that you should not cancel any pending opt-in/opt-out requests in the delegate method implementation.
    /// The actual `reset` method is used for failure cases.
    func ledgerTransactionOperationDidResetOperationOnSuccess(_ ledgerTransactionOperation: LedgerTransactionOperation)
}

extension LedgerTransactionOperationDelegate {
    func ledgerTransactionOperationDidResetOperationOnSuccess(
        _ ledgerTransactionOperation: LedgerTransactionOperation
    ) {
        ledgerTransactionOperationDidResetOperation(ledgerTransactionOperation)
    }
}
