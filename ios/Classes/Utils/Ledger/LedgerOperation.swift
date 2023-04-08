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
//  LedgerOperation.swift

import UIKit
import CoreBluetooth

protocol LedgerOperation: AnyObject {
    func startOperation()
    func completeOperation(with data: Data)
    func handleDiscoveryResults(_ peripherals: [CBPeripheral])
    func reset()

    func returnError(_ error: LedgerOperationError)
    func finishTimingOperation()
    func requestUserApproval()
    
    var connectedDevice: CBPeripheral? { get set }
    
    var bleConnectionManager: BLEConnectionManager { get }
    var ledgerBleController: LedgerBLEController { get }
}

extension LedgerOperation {
    func startScan() {
        bleConnectionManager.startScanForPeripherals()
    }
    
    func stopScan() {
        bleConnectionManager.stopScan()
    }
    
    func connectToDevice(_ peripheral: CBPeripheral) {
        bleConnectionManager.connectToDevice(peripheral)
    }
    
    func disconnectFromCurrentDevice() {
        bleConnectionManager.disconnect(from: connectedDevice)
    }
}

extension LedgerOperation where Self: BLEConnectionManagerDelegate {
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didDiscover peripherals: [CBPeripheral]) {
        handleDiscoveryResults(peripherals)
    }
    
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didConnect peripheral: CBPeripheral) {
        connectedDevice = peripheral
        finishTimingOperation()
        requestUserApproval()
    }
    
    func bleConnectionManagerEnabledToWrite(_ bleConnectionManager: BLEConnectionManager) {
        startOperation()
    }
    
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didRead string: String) {
        ledgerBleController.readIncomingData(with: string)
    }
    
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didFailWith error: BLEConnectionManager.BLEError) {
        switch error {
        case let .failedBLEConnection(state):
            /// <todo>: Refactor
            /// Scanning should only be stopped on transaction operations.
            if self is LedgerTransactionOperation {
                stopScan()
            }
            returnError(.failedBLEConnectionError(state))
            finishTimingOperation()
        default:
            reset()
            returnError(.custom(title: "ble-error-connection-title".localized, message: ""))
            returnError(.ledgerConnectionWarning)
        }
    }
}

extension LedgerOperation where Self: LedgerBLEControllerDelegate {
    func ledgerBLEController(_ ledgerBLEController: LedgerBLEController, shouldWrite data: Data) {
        bleConnectionManager.sendDataToPeripheral(data)
    }
    
    func ledgerBLEController(_ ledgerBLEController: LedgerBLEController, didReceive data: Data) {
        completeOperation(with: data)
    }
}

extension LedgerOperation {
    func parseAddress(from data: Data) -> String? {
        /// Remove last two bytes to fetch data since it declares status codes.
        var mutableData = data
        mutableData.removeLast(2)

        var error: NSError?
        let address = AlgorandSDK().addressFromPublicKey(mutableData, error: &error)

        if error != nil || !address.isValidatedAddress {
            return nil
        }

        return address
    }
}

enum LedgerOperationError: Error {
    case connection
    case failedToFetchAddress
    case failedToFetchAccountFromIndexer
    case cancelled
    case closedApp
    case failedToSign
    case unknown
    case unmatchedAddress
    case ledgerConnectionWarning
    case custom(title: String, message: String)
    case failedBLEConnectionError(CBManagerState)
}
