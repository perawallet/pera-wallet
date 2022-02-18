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
//   LedgerAccountVerifyOperation.swift

import UIKit
import CoreBluetooth

class LedgerAccountVerifyOperation: LedgerOperation, BLEConnectionManagerDelegate, LedgerBLEControllerDelegate {

    let bleConnectionManager = BLEConnectionManager()
    let ledgerBleController = LedgerBLEController()

    var connectedDevice: CBPeripheral?

    weak var delegate: LedgerAccountVerifyOperationDelegate?

    private var ledgerDetail: LedgerDetail?

    init() {
        bleConnectionManager.delegate = self
        ledgerBleController.delegate = self
    }

    func setLedgerDetail(_ ledgerDetail: LedgerDetail?) {
        self.ledgerDetail = ledgerDetail
    }
}

extension LedgerAccountVerifyOperation {
    func startOperation() {
        guard let accountIndex = ledgerDetail?.indexInLedger else {
            return
        }

        ledgerBleController.verifyAddress(at: accountIndex)
    }

    func completeOperation(with data: Data) {
        if data.isErrorResponseFromLedger {
            if data.isLedgerTransactionCancelledError {
                delegate?.ledgerAccountVerifyOperation(self, didFailed: .cancelled)
            } else {
                delegate?.ledgerAccountVerifyOperation(self, didFailed: .closedApp)
            }

            reset()
            return
        }

        guard let address = parseAddress(from: data) else {
            reset()
            delegate?.ledgerAccountVerifyOperation(self, didFailed: .failedToFetchAddress)
            return
        }

        delegate?.ledgerAccountVerifyOperation(self, didVerify: address)
    }

    func handleDiscoveryResults(_ peripherals: [CBPeripheral]) {
        guard let savedPeripheralId = ledgerDetail?.id,
              let savedPeripheral = peripherals.first(where: { $0.identifier == savedPeripheralId }) else {
            return
        }

        bleConnectionManager.connectToDevice(savedPeripheral)
    }

    func reset() {
        connectedDevice = nil
        stopScan()
        disconnectFromCurrentDevice()
    }

    func returnError(_ error: LedgerOperationError) {
        delegate?.ledgerAccountVerifyOperation(self, didFailed: error)
    }

    func finishTimingOperation() {
        delegate?.ledgerAccountVerifyOperationDidFinishTimingOperation(self)
    }

    func requestUserApproval() {}
}

protocol LedgerAccountVerifyOperationDelegate: AnyObject {
    func ledgerAccountVerifyOperation(_ ledgerAccountVerifyOperation: LedgerAccountVerifyOperation, didVerify account: String)
    func ledgerAccountVerifyOperation(_ ledgerAccountVerifyOperation: LedgerAccountVerifyOperation, didFailed error: LedgerOperationError)
    func ledgerAccountVerifyOperationDidFinishTimingOperation(_ ledgerAccountVerifyOperation: LedgerAccountVerifyOperation)
}
