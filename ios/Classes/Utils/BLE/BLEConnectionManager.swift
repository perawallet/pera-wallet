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
//  BLEConnectionManager.swift

import UIKit
import CoreBluetooth

final class BLEConnectionManager: NSObject {
    weak var delegate: BLEConnectionManagerDelegate?
    
    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    
    private var writeCharacteristic: CBCharacteristic?
    private var readCharacteristic: CBCharacteristic?
    
    private var peripherals: [CBPeripheral] = []
    private var isScanning = false
    private var isDisconnectedInternally = false

    var state: CBManagerState {
        return centralManager?.state ?? .unknown
    }
}

extension BLEConnectionManager {
    func startScanForPeripherals() {
        if isScanning {
            return
        }

        isScanning = true

        guard let centralManager else {
            centralManager = makeCentralManager()
            return
        }

        let state = centralManager.state
        guard state == .poweredOn else {
            delegate?.bleConnectionManager(self, didFailWith: .failedBLEConnection(state: state))
            return
        }

        scanForPeripherals()
    }

    private func scanForPeripherals() {
        peripherals = []

        centralManager?.scanForPeripherals(
            withServices: [BLEConnectionManager.Keys.serviceUuid],
            options: [
                CBCentralManagerScanOptionAllowDuplicatesKey: false,
                CBCentralManagerOptionShowPowerAlertKey: true
            ]
        )
    }
    
    func stopScan() {
        if !isScanning {
            return
        }

        isScanning = false

        let state = centralManager?.state
        guard state == .poweredOn else {
            return
        }

        peripherals = []
        centralManager?.stopScan()
    }
    
    func connectToDevice(_ peripheral: CBPeripheral) {
        centralManager?.connect(peripheral)
    }
    
    func disconnect(from connectedPeripheral: CBPeripheral?) {
        if let peripheral = connectedPeripheral {
            isDisconnectedInternally = true
            centralManager?.cancelPeripheralConnection(peripheral)
            self.connectedPeripheral = nil
        }
    }
    
    func sendDataToPeripheral(_ data: Data) {
        if let writeCharacteristic = writeCharacteristic {
            connectedPeripheral?.writeValue(data, for: writeCharacteristic, type: .withResponse)
        }
    }
}

extension BLEConnectionManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let state = central.state
        guard state == .poweredOn else {
            delegate?.bleConnectionManager(self, didFailWith: .failedBLEConnection(state: state))
            return
        }

        if isScanning {
            scanForPeripherals()
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        peripherals.append(peripheral)
        delegate?.bleConnectionManager(self, didDiscover: peripherals)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        stopScan()
        connectedPeripheral = peripheral
        isDisconnectedInternally = false
        peripheral.delegate = self
        peripheral.discoverServices([BLEConnectionManager.Keys.serviceUuid])
        
        delegate?.bleConnectionManager(self, didConnect: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate?.bleConnectionManager(self, didFailWith: .failedPeripheralConnection)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if isDisconnectedInternally {
            return
        }
        
        if peripheral.identifier == connectedPeripheral?.identifier {
            connectedPeripheral = nil
        }
        
        delegate?.bleConnectionManager(self, didFailWith: .disconnected)
    }
}

extension BLEConnectionManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        
        discoverCharacteristics(of: peripheral, for: services)
    }
    
    private func discoverCharacteristics(of peripheral: CBPeripheral, for services: [CBService]) {
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil,
              let characteristics = service.characteristics else {
            return
        }
        
        processCharacteristics(peripheral, of: characteristics)
    }
    
    private func processCharacteristics(_ peripheral: CBPeripheral, of characteristics: [CBCharacteristic]) {
        for characteristic in characteristics {
            if characteristic.uuid.isEqual(BLEConnectionManager.Keys.readCharacteristicUuid) {
                readCharacteristic = characteristic
                
                guard let readCharacteristic = readCharacteristic else {
                    return
                }
                
                peripheral.setNotifyValue(true, for: readCharacteristic)
                peripheral.readValue(for: readCharacteristic)
            }
            
            if characteristic.uuid.isEqual(BLEConnectionManager.Keys.writeCharacteristicUuid) {
                writeCharacteristic = characteristic
                
                /// Can write a data to the device since write characteristic is set.
                delegate?.bleConnectionManagerEnabledToWrite(self)
            }
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            return
        }
        
        if characteristic == readCharacteristic,
           let characteristicData = characteristic.value {
            delegate?.bleConnectionManager(self, didRead: characteristicData.toHexString())
        }
        return
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    
    }
}

extension BLEConnectionManager {
    private func makeCentralManager() -> CBCentralManager {
        return CBCentralManager(
            delegate: self,
            queue: nil,
            options: [
                CBCentralManagerScanOptionAllowDuplicatesKey: false,
                CBCentralManagerOptionShowPowerAlertKey: true
            ]
        )
    }
}

extension BLEConnectionManager {
    enum BLEError: Error {
        case failedBLEConnection(state: CBManagerState)
        case failedPeripheralConnection
        case disconnected
    }
}

extension BLEConnectionManager {
    enum Keys {
        private static let serviceUuidKey = "13D63400-2C97-0004-0000-4C6564676572"
        private static let writeCharacteristicKey = "13D63400-2C97-0004-0002-4C6564676572"
        private static let readCharacteristicKey = "13D63400-2C97-0004-0001-4C6564676572"

        fileprivate static let serviceUuid = CBUUID(string: serviceUuidKey)
        fileprivate static let writeCharacteristicUuid = CBUUID(string: writeCharacteristicKey)
        fileprivate static let readCharacteristicUuid = CBUUID(string: readCharacteristicKey)
    }
}

protocol BLEConnectionManagerDelegate: AnyObject {
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didDiscover peripherals: [CBPeripheral])
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didConnect peripheral: CBPeripheral)
    func bleConnectionManagerEnabledToWrite(_ bleConnectionManager: BLEConnectionManager)
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didRead string: String)
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didFailWith error: BLEConnectionManager.BLEError)
}
