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
//   WCTransaction.swift

import Magpie

class WCTransaction: Model {
    private(set) var unparsedTransactionDetail: Data? // Transaction that is not parsed for msgpack, needs to be used for signing
    var transactionDetail: WCTransactionDetail?
    let signers: [String]?
    let multisigMetadata: WCMultisigMetadata?
    let message: String?
    let authAddress: String?

    /// ID is used to separate the transactions that contains exactly the same elements.
    private let id = UUID()
    private(set) var signerAccount: Account?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        signers = try container.decodeIfPresent([String].self, forKey: .signers)
        multisigMetadata = try container.decodeIfPresent(WCMultisigMetadata.self, forKey: .multisigMetadata)
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

    func findSignerAccount(in session: Session) {
        if let authAddress = authAddress {
            signerAccount = findAccount(authAddress, in: session)
            return
        }

        switch signer() {
        case .sender:
            if let sender = transactionDetail?.sender {
                signerAccount = findAccount(sender, in: session)
                return
            }
        case let .current(address):
            if let address = address {
                signerAccount = findAccount(address, in: session)
                return
            }
        case .multisig:
            break
        case .unsignable:
            break
        }
    }

    private func findAccount(_ address: String, in session: Session) -> Account? {
        for account in session.accounts where !account.isWatchAccount() {
            if account.isRekeyed() && (account.address == address || account.authAddress == address) {
                return findRekeyedAccount(for: account, among: session.accounts)
            }

            if account.isLedger() && account.ledgerDetail != nil && account.address == address {
                return account
            }

            if session.privateData(for: address) != nil && account.address == address {
                return account
            }
        }

        return nil
    }

    private func findRekeyedAccount(for account: Account, among accounts: [Account]) -> Account? {
        guard let authAddress = account.authAddress else {
            return nil
        }

        if account.rekeyDetail?[authAddress] != nil {
            return account
        } else {
            if let authAccount = accounts.first(where: { account -> Bool in
                authAddress == account.address
            }),
            let ledgerDetail = authAccount.ledgerDetail {
                account.addRekeyDetail(ledgerDetail, for: authAddress)
                return account
            }

            return nil
        }
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
        return transactionDetail?.genesisId == params.genesisId && transactionDetail?.genesisHashData == params.genesisHashData
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
