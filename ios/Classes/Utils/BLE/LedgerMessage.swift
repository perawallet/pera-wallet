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
//  LedgerConstants.swift

import Foundation

enum LedgerMessage {
    enum Instruction {
        static let sign: Byte = 0x08
        static let publicKey: Byte = 0x03
        
        static func addressFetch(for index: Int) -> Data {
            var addressFetchInstruction = Data(bytes: [LedgerMessage.CLA.algorand, Instruction.publicKey, 0x00, 0x00, Size.accountIndex])
            addressFetchInstruction.append(contentsOf: index.toByteArray())
            return addressFetchInstruction
        }

        static func verifyAddress(for index: Int) -> Data {
            var verifyAddressInstruction = Data(bytes: [LedgerMessage.CLA.algorand, Instruction.publicKey, 0x80, 0x00, Size.accountIndex])
            verifyAddressInstruction.append(contentsOf: index.toByteArray())
            return verifyAddressInstruction
        }
    }
    
    enum Response {
        static let ledgerError = "6e00"
        static let ledgerTransactionCancelledOldVersion = "6985"
        static let ledgerTransactionCancelled = "6986"
        static let nextPage = "9000"
    }
    
    enum Size {
        static let address = 34
        static let error = 2
        static let chunk: Byte = 0xFF
        static let header: Byte = 0x05
        static let accountIndex: Byte = 0x04
    }
    
    enum Paging {
        static let p1First: Byte = 0x00
        static let p1Transaction: Byte = 0x01
        static let p1More: Byte = 0x80
        static let p2Last: Byte = 0x00
        static let p2More: Byte = 0x80
    }
    
    enum MTU {
        static let `default` = 23
        static let min = 23
        static let max = 100
        static let offset = 5
    }

    enum CLA {
        static let ledger: Byte = 0x08
        static let data: Byte = 0x05
        static let algorand: Byte = 0x80
    }
}
