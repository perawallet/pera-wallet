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
//  Data+Hex.swift

import Foundation

extension Data {
    init?(fromHexEncodedString string: String) {
        self.init(capacity: string.utf16.count / 2)
        
        var isEven = true
        var byte: UInt8 = 0
        for character in string.utf16 {
            guard let decodedValue = decodeNibble(character) else {
                return nil
            }
            
            if isEven {
                byte = decodedValue << 4
            } else {
                byte += decodedValue
                append(byte)
            }
            
            isEven = !isEven
        }
        
        guard isEven else { return nil }
    }
    
    // Convert 0 ... 9, a ... f, A ...F to their decimal value, return nil for all other input characters
    private func decodeNibble(_ character: UInt16) -> UInt8? {
        switch character {
        case 0x30 ... 0x39:
            return UInt8(character - 0x30)
        case 0x41 ... 0x46:
            return UInt8(character - 0x41 + 10)
        case 0x61 ... 0x66:
            return UInt8(character - 0x61 + 10)
        default:
            return nil
        }
    }
}

extension Data {
    func toHexString() -> String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
    
    var isLedgerError: Bool {
        toHexString() == LedgerMessage.Response.ledgerError
    }
    
    var isLedgerTransactionCancelledError: Bool {
        return toHexString() == LedgerMessage.Response.ledgerTransactionCancelled ||
            toHexString() == LedgerMessage.Response.ledgerTransactionCancelledOldVersion
    }

    var hasNextPageForLedgerResponse: Bool {
        toHexString() == LedgerMessage.Response.nextPage
    }
    
    var isErrorResponseFromLedger: Bool {
        count == LedgerMessage.Size.error
    }
    
    var isAccountAddressResponseFromLedger: Bool {
        count == LedgerMessage.Size.address
    }
    
    var isSignedTransactionResponseFromLedger: Bool {
        count > LedgerMessage.Size.address
    }

    func getAlgorandAddressFromPublicKey() -> String? {
        var error: NSError?
        let addressString = AlgorandSDK().addressFromPublicKey(self, error: &error)
        return error == nil ? addressString : nil
    }
}

extension Data {
    init(bytes: [UInt8]) {
        self.init(bytes: bytes, count: bytes.count)
    }

    func toBytes() -> [UInt8] {
        return [UInt8](self)
    }
}
