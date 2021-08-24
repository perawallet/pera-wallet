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
//  LedgerAccountFetchOperation.swift

import UIKit
import CoreBluetooth

class LedgerAccountFetchOperation: LedgerOperation, BLEConnectionManagerDelegate, LedgerBLEControllerDelegate {
    
    let bleConnectionManager = BLEConnectionManager()
    let ledgerBleController = LedgerBLEController()
    
    var ledgerApprovalViewController: LedgerApprovalViewController?

    var shouldDisplayLedgerApprovalModal: Bool {
        return true
    }

    var ledgerMode: LedgerApprovalViewController.Mode {
        return ledgerApprovalMode
    }
    
    var timer: Timer?
    var connectedDevice: CBPeripheral?
    
    private var ledgerAccounts = [Account]()
    private var accountIndex: Int {
        return ledgerAccounts.count
    }
    
    weak var delegate: LedgerAccountFetchOperationDelegate?
    
    private let api: AlgorandAPI
    private let ledgerApprovalMode: LedgerApprovalViewController.Mode
    
    init(api: AlgorandAPI, ledgerApprovalMode: LedgerApprovalViewController.Mode) {
        self.api = api
        self.ledgerApprovalMode = ledgerApprovalMode
        bleConnectionManager.delegate = self
        ledgerBleController.delegate = self
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
            NotificationBanner.showError(
                "ble-error-transmission-title".localized,
                message: "ble-error-fail-fetch-account-address".localized
            )
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
        ledgerApprovalViewController?.dismissIfNeeded()
        ledgerAccounts.removeAll()
    }
}

extension LedgerAccountFetchOperation {
    private func fetchAccount(_ address: String) {
        api.fetchAccount(with: AccountFetchDraft(publicKey: address)) { response in
            switch response {
            case .success(let accountWrapper):
                if accountWrapper.account.isCreated {
                    accountWrapper.account.assets = accountWrapper.account.nonDeletedAssets()
                    accountWrapper.account.ledgerDetail = self.composeLedgerDetail()
                    self.ledgerAccounts.append(accountWrapper.account)
                    self.startOperation()
                } else {
                    self.returnAccounts()
                }
            case let .failure(error, _):
                if error.isHttpNotFound {
                    if self.isInitialAccount {
                        let account = Account(address: address, type: .ledger)
                        account.ledgerDetail = self.composeLedgerDetail()
                        self.ledgerAccounts.append(account)
                    }
                } else {
                    NotificationBanner.showError("title-error".localized, message: "ledger-account-fetct-error".localized)
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
        delegate?.ledgerAccountFetchOperation(self, didReceive: ledgerAccounts, in: ledgerApprovalViewController)
    }

    private var isInitialAccount: Bool {
        return accountIndex == 0
    }
}

protocol LedgerAccountFetchOperationDelegate: AnyObject {
    func ledgerAccountFetchOperation(
        _ ledgerAccountFetchOperation: LedgerAccountFetchOperation,
        didReceive accounts: [Account],
        in ledgerApprovalViewController: LedgerApprovalViewController?
    )
    func ledgerAccountFetchOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation, didDiscover peripherals: [CBPeripheral])
    func ledgerAccountFetchOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation, didFailed error: LedgerOperationError)
}
