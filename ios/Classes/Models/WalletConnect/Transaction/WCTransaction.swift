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
//   WCTransaction.swift

import Foundation
import Alamofire

final class WCTransaction: Codable {
    private(set) var unparsedTransactionDetail: Data? // Transaction that is not parsed for msgpack, needs to be used for signing
    var transactionDetail: WCTransactionDetail?
    let signers: [String]?
    let multisigMetadata: WCMultisigMetadata?
    let message: String?
    let authAddress: String?

    /// ID is used to separate the transactions that contains exactly the same elements.
    private let id = UUID()
    private(set) var requestedSigner = WCTransactionRequestedSigner()

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        signers = try container.decodeIfPresent([String].self, forKey: .signers)
        multisigMetadata = try
            container.decodeIfPresent(WCMultisigMetadata.self, forKey: .multisigMetadata)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        authAddress = try container.decodeIfPresent(String.self, forKey: .authAddress)
        if let transactionMsgpack = try container.decodeIfPresent(Data.self, forKey: .transaction) {
            unparsedTransactionDetail = transactionMsgpack
            transactionDetail = parseTransaction(from: transactionMsgpack)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(transactionDetail, forKey: .transaction)
        try container.encodeIfPresent(signers, forKey: .signers)
        try container.encodeIfPresent(multisigMetadata, forKey: .multisigMetadata)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(authAddress, forKey: .authAddress)
    }
}

extension WCTransaction {
    private enum CodingKeys: String, CodingKey {
        case transaction = "txn"
        case signers = "signers"
        case multisigMetadata = "msig"
        case message = "message"
        case authAddress = "authAddr"
    }
}

extension WCTransaction {
    private func parseTransaction(from msgpack: Data) -> WCTransactionDetail? {
        var error: NSError?
        let jsonString = AlgorandSDK().msgpackToJSON(msgpack, error: &error)

        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }

        return try? JSONDecoder().decode(WCTransactionDetail.self, from: jsonData)
    }

    func findSignerAccount(in accountCollection: AccountCollection, on session: Session) {
        requestedSigner.findSignerAccount(
            in: accountCollection,
            on: session, transactionDetail: transactionDetail,
            authAddress: authAddress,
            signer: signer()
        )
    }

    func signer() -> Signer {
        guard let signers = signers else {
            return .sender
        }

        if signers.isEmpty {
            return .unsignable
        } else if signers.count == 1 {
            return .current(address: signers.first)
        } else {
            return .multisig
        }
    }

    var hasValidAuthAddressForSigner: Bool {
        switch signer() {
        case let .current(address):
            guard let authAddress = authAddress else {
                return true
            }

            return authAddress == address
        default:
            return true
        }
    }

    var hasValidSignerAddress: Bool {
        switch signer() {
        case let .current(address):
            guard let address = address else {
                return false
            }

            return address == transactionDetail?.sender
        default:
            return true
        }
    }

    var isMultisig: Bool {
        switch signer() {
        case .multisig:
            return true
        default:
            break
        }

        return multisigMetadata != nil
    }

    var validationAddresses: [String?] {
        var addresses: [String?] = [authAddress]

        if let transactionDetail = transactionDetail {
            addresses.append(contentsOf: transactionDetail.validationAddresses)
        }

        switch signer() {
        case let .current(address):
            addresses.append(address)
        default:
            break
        }

        return addresses
    }

    func isInTheSameNetwork(with params: TransactionParams) -> Bool {
        return
            transactionDetail?.genesisId == params.genesisId &&
            transactionDetail?.genesisHashData == params.genesisHashData
    }

    func isFutureTransaction(with params: TransactionParams) -> Bool {
        guard let firstRound = transactionDetail?.firstValidRound else {
            return false
        }

        let futureTransactionThreshold: UInt64 = 500
        return firstRound > params.lastRound + futureTransactionThreshold
    }
}

extension WCTransaction {
    enum Signer {
        case sender // Transaction should be signed by the sender
        case unsignable // Transaction should not be signed
        case current(address: String?) // Transaction should be signed by the address in the list
        case multisig // Transaction requires multisignature
    }
}

extension WCTransaction: Equatable {
    static func == (lhs: WCTransaction, rhs: WCTransaction) -> Bool {
        return lhs.id == rhs.id
    }
}
