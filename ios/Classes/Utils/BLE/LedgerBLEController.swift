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
//  LedgerBLEController.swift

import Foundation

/// To understand better how ledger app works, this is the Algorand app on the ledger device:
/// https://github.com/LedgerHQ/app-algorand/blob/master/src/main.c
/// Basically, the ledger app listens whether it receive an instruction via bluetooth message
/// It checks the first bytes of the message to decide it's related to algorand app (0x80)
/// Instructions can be fetch address instruction (0x03) or sign transaction (0x08) instruction
/// After the instruction process, it returns a response as requested data (signed transaction or address) or an error .

/// Bytes and Shorts used in communication with Ledger
/// Usage of these in Swift are UInt8 and UInt16: https://gorjanshukov.medium.com/working-with-bytes-in-ios-swift-4-de316a389a0c
typealias Byte = UInt8
typealias Short = UInt16

class LedgerBLEController: NSObject {
    
    private var mtuSize = LedgerMessage.MTU.default
    private var currentSequence: Short = 0
    private var remainingResponseBytes: Short = 0
    private var receivedData = NSMutableData()
    
    weak var delegate: LedgerBLEControllerDelegate?
    
    /// Handles response from the ledger device.
    func readIncomingData(with value: String) {
        guard let incomingData = Data(fromHexEncodedString: value),
            let processedIncomingData = processNextIncomingData(incomingData) else {
            return
        }
        
        resetState()
        delegate?.ledgerBLEController(self, didReceive: processedIncomingData)
    }
    
    private func resetState() {
        currentSequence = 0
        remainingResponseBytes = 0
        receivedData = NSMutableData()
    }
}

extension LedgerBLEController {
    /// Sends required address fetch instruction to the ledger device.
    func fetchAddress(at index: Int) {
        packetizeData(LedgerMessage.Instruction.addressFetch(for: index)).forEach { packet in
            delegate?.ledgerBLEController(self, shouldWrite: packet)
        }
    }

    /// Sends verify address instruction to the ledger device.
    func verifyAddress(at index: Int) {
        packetizeData(LedgerMessage.Instruction.verifyAddress(for: index)).forEach { packet in
            delegate?.ledgerBLEController(self, shouldWrite: packet)
        }
    }
    
    /// Sends required sign transaction instruction to the ledger device.
    func signTransaction(_ unsignedTransactionData: Data, atLedgerAccount index: Int) {
        var packets = [Data]()
        composeSignTransactionPackets(from: unsignedTransactionData, atLedgerAccount: index).forEach { appPacket in
            packetizeData(appPacket).forEach { subpacket in
                packets.append(subpacket)
            }
        }
        
        packets.forEach { packet in
            delegate?.ledgerBLEController(self, shouldWrite: packet)
        }
    }
}

extension LedgerBLEController {
    private func processNextIncomingData(_ incomingData: Data) -> Data? {
        let data = incomingData.toBytes()
        let dataLength = data.count
        var offset = 0

        /// Handle MTU size
        if data[offset] == LedgerMessage.CLA.ledger {
            offset += 1
            if (dataLength - offset) < LedgerMessage.MTU.offset {
                resetState()
                return nil
            }
            
            var mtu = Int(data[LedgerMessage.MTU.offset])
            mtu = mtu < LedgerMessage.MTU.min ? LedgerMessage.MTU.min : mtu
            mtu = mtu > LedgerMessage.MTU.max ? LedgerMessage.MTU.max : mtu
            mtuSize = mtu
            resetState()
            return nil
        }

        /// Handle received data
        if data[offset] == LedgerMessage.CLA.data {
            offset += 1
            
            /// Parse sequence number
            var sequenceNumber: Short = 0
            sequenceNumber += Short(data[offset]).shiftOneByteLeft()
            sequenceNumber += Short(data[offset + 1])
            offset += 2

            /// Check sequence number with the current one
            if sequenceNumber != currentSequence {
                resetState()
                return nil
            }
            
            /// 2 bytes of length if this is the first packet
            if currentSequence == 0 {
                if dataLength - offset < 2 {
                    resetState()
                    return nil
                }

                /// Read off the length and update bytes remaining
                var packetLength: Short = 0
                packetLength += Short(data[offset]).shiftOneByteLeft()
                packetLength += Short(data[offset + 1])
                offset += 2
                
                remainingResponseBytes = packetLength
            }
            
            /// Copy the rest of this packet
            let remainingPacket: Short = Short(dataLength) - Short(offset)
            let bytesToCopy = remainingPacket < remainingResponseBytes ? remainingPacket : remainingResponseBytes
            
            if bytesToCopy == 0 {
                resetState()
                return nil
            }
            
            var outputBuffer = [Byte](repeating: 0, count: Int(bytesToCopy))
            for i in 0..<bytesToCopy {
                outputBuffer[Int(i)] = data[offset]
                offset += 1
            }
            
            receivedData.append(Data(bytes: outputBuffer))
            
            /// Check remaining bytes
            remainingResponseBytes -= Short(bytesToCopy)
            
            if remainingResponseBytes == 0 {
                return receivedData as Data
            }
            
            if remainingResponseBytes > 0 {
                /// Wait for the next message
                currentSequence += 1
            }
        }
        
        resetState()
        return nil
    }
    
    /// Chunks up all of the data we send over BLE.
    /// Used to send messages related to address fetching and transaction signing.
    private func packetizeData(_ messageData: Data) -> [Data] {
        let messages = messageData.toBytes()
        var output = [Data]()
        var sequenceIndex: Short = 0
        var offset: UInt64 = 0
        var isFirst = true
        var remainingBytes = messageData.count
        
        while remainingBytes > 0 {
            var packet = [Byte]()
            
            /// Add algorand ledger application specifier
            packet.append(LedgerMessage.CLA.data)
            
            /// Encode sequence number
            packet.append(sequenceIndex.shiftOneByteRight().asByte)
            packet.append(sequenceIndex.removeExcessBytes().asByte)
            
            /// If this is the first packet, needs to encode the total message length
            if isFirst {
                packet.append(sequenceIndex.shiftOneByteRight().asByte)
                packet.append(messages.count.removeExcessBytes().asByte)
                isFirst = false
            }
            
            /// Copy some number of bytes into the packet
            let remainingSpaceInPacket = mtuSize - packet.count
            let bytesToCopy = remainingSpaceInPacket < remainingBytes ? remainingSpaceInPacket : remainingBytes
            remainingBytes -= bytesToCopy

            for byteIndex in 0..<bytesToCopy {
                packet.append(messages[Int(offset) + byteIndex])
            }
            
            sequenceIndex += 1
            offset += UInt64(bytesToCopy)
            
            output.append(Data(bytes: packet))
        }
        
        return output
    }
    
    /// Create app packet for transaction signing data that will contain information with the format:
    /// algorandCLA | sing instruction | initial packets | {transactionData}
    private func composeSignTransactionPackets(from transactionData: Data, atLedgerAccount index: Int) -> [Data] {
        var output = [Data]()
        var remainingBytes = transactionData.count + Int(LedgerMessage.Size.accountIndex)
        var offset = 0
        var p1 = LedgerMessage.Paging.p1Transaction
        var p2 = LedgerMessage.Paging.p2More
        
        while remainingBytes > 0 {
            /// Calculates header size and how many bytes should it send to the ledger
            let remainingBytesWithHeader = remainingBytes + Int(LedgerMessage.Size.header)
            let packetSize = remainingBytesWithHeader <= LedgerMessage.Size.chunk ? remainingBytesWithHeader : Int(LedgerMessage.Size.chunk)

            /// Copy some number of bytes into the packet
            let remainingSpaceInPacket = packetSize - Int(LedgerMessage.Size.header)
            var bytesToCopySize = remainingSpaceInPacket < remainingBytes ? remainingSpaceInPacket : remainingBytes
            remainingBytes -= bytesToCopySize
            
            /// Check if this is the last packet
            if remainingBytes == 0 {
                p2 = LedgerMessage.Paging.p2Last
            }
            
            var packet = [Byte]()
            
            /// Adds algorand cla key, signg instruction and other related data for transaction
            packet.append(contentsOf: [LedgerMessage.CLA.algorand, LedgerMessage.Instruction.sign, p1, p2, Byte(bytesToCopySize)])
            
            if p1 == LedgerMessage.Paging.p1Transaction {
                packet.append(contentsOf: index.toByteArray())
                bytesToCopySize -= Int(LedgerMessage.Size.accountIndex)
            }
            
            let transactionDataArray = [Byte](transactionData)
            for byteIndex in 0..<bytesToCopySize {
                packet.append(transactionDataArray[offset + byteIndex])
            }
            
            p1 = LedgerMessage.Paging.p1More
            offset += bytesToCopySize
            
            output.append(Data(bytes: packet))
        }
        
        return output
    }
}

protocol LedgerBLEControllerDelegate: AnyObject {
    func ledgerBLEController(_ ledgerBLEController: LedgerBLEController, shouldWrite data: Data)
    func ledgerBLEController(_ ledgerBLEController: LedgerBLEController, didReceive data: Data)
}
