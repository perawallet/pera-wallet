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
//  LedgerAccountFetchOperation.swift

import UIKit
import CoreBluetooth

final class LedgerAccountFetchOperation: LedgerOperation, BLEConnectionManagerDelegate, LedgerBLEControllerDelegate {
    let bleConnectionManager = BLEConnectionManager()
    let ledgerBleController = LedgerBLEController()

    var connectedDevice: CBPeripheral?
    
    private var ledgerAccounts = [Account]()
    private var accountIndex: Int {
        return ledgerAccounts.count
    }

    weak var delegate: LedgerAccountFetchOperationDelegate?
    
    private let api: ALGAPI
    private let analytics: ALGAnalytics

    init(
        api: ALGAPI,
        analytics: ALGAnalytics
    ) {
        self.api = api
        self.analytics = analytics

        self.bleConnectionManager.delegate = self
        self.ledgerBleController.delegate = self
    }
}

extension LedgerAccountFetchOperation {
    func startOperation() {
        ledgerBleController.fetchAddress(at: accountIndex)
    }
    
    func completeOperation(with data: Data) {
        if data.isErrorResponseFromLedger {
            if data.isLedgerTransactionCancelledError {
                delegate?.ledgerAccountFetchOperation(self, didFailed: .cancelled)
            } else {
                delegate?.ledgerAccountFetchOperation(self, didFailed: .closedApp)
            }

            reset()
            return
        }

        guard let address = parseAddress(from: data) else {
            reset()
            delegate?.ledgerAccountFetchOperation(self, didFailed: .failedToFetchAddress)
            return
        }

        fetchAccount(address)
    }
    
    func handleDiscoveryResults(_ peripherals: [CBPeripheral]) {
        delegate?.ledgerAccountFetchOperation(self, didDiscover: peripherals)
    }
    
    func reset() {
        stopScan()
        disconnectFromCurrentDevice()
        connectedDevice = nil
        delegate?.ledgerAccountFetchOperationDidResetOperation(self)
        ledgerAccounts.removeAll()
    }

    func returnError(_ error: LedgerOperationError) {
        delegate?.ledgerAccountFetchOperation(self, didFailed: error)
    }

    func finishTimingOperation() {
        delegate?.ledgerAccountFetchOperationDidFinishTimingOperation(self)
    }

    func requestUserApproval() {
        delegate?.ledgerAccountFetchOperation(self, didRequestUserApprovalFor: (connectedDevice?.name).emptyIfNil)
    }
}

extension LedgerAccountFetchOperation {
    private func fetchAccount(_ address: String) {
        api.fetchAccount(
            AccountFetchDraft(publicKey: address),
            includesClosedAccounts: true,
            queue: .main,
            ignoreResponseOnCancelled: true
        ) { [weak self] response in
            guard let self = self else { return }

            switch response {
            case .success(let accountWrapper):
                if !accountWrapper.account.isSameAccount(with: address) {
                    self.delegate?.ledgerAccountFetchOperation(self, didFailed: .failedToFetchAccountFromIndexer)
                    self.returnAccounts()
                    return
                }

                if accountWrapper.account.isCreated {
                    accountWrapper.account.ledgerDetail = self.composeLedgerDetail()
                    self.ledgerAccounts.append(accountWrapper.account)
                    self.startOperation()
                } else {
                    self.returnAccounts()
                }
            case let .failure(error, _):
                if error.isHttpNotFound {
                    if self.isInitialAccount {
                        let account = Account(address: address)
                        account.authorization = .ledger
                        account.ledgerDetail = self.composeLedgerDetail()
                        self.ledgerAccounts.append(account)
                    }
                } else {
                    self.delegate?.ledgerAccountFetchOperation(self, didFailed: .failedToFetchAccountFromIndexer)
                }
                self.returnAccounts()
            }
        }
    }

    private func composeLedgerDetail() -> LedgerDetail? {
        guard let connectedDevice = connectedDevice else {
            return nil
        }

        return LedgerDetail(
            id: connectedDevice.identifier,
            name: connectedDevice.name,
            indexInLedger: accountIndex
        )
    }
    
    private func returnAccounts() {
        delegate?.ledgerAccountFetchOperation(self, didReceive: ledgerAccounts)
    }

    private var isInitialAccount: Bool {
        return accountIndex == 0
    }
}

protocol LedgerAccountFetchOperationDelegate: AnyObject {
    func ledgerAccountFetchOperation(
        _ ledgerAccountFetchOperation: LedgerAccountFetchOperation,
        didReceive accounts: [Account]
    )
    func ledgerAccountFetchOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation, didDiscover peripherals: [CBPeripheral])
    func ledgerAccountFetchOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation, didFailed error: LedgerOperationError)
    func ledgerAccountFetchOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation, didRequestUserApprovalFor ledger: String)
    func ledgerAccountFetchOperationDidFinishTimingOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation)
    func ledgerAccountFetchOperationDidResetOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation)
}
