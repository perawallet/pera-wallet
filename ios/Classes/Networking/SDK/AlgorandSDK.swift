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
//  AlgorandSDK.swift

import Crypto

class AlgorandSDK {
    
    let roundTreshold: Int64 = 1000
    
    func generatePrivateKey() -> Data? {
        return CryptoGenerateSK()
    }
    
    func sign(_ privateData: Data, with data: Data, error: inout NSError?) -> Data? {
        return CryptoSignTransaction(privateData, data, &error)
    }
    
    func getSignedTransaction(_ transaction: Data, from signature: Data, error: inout NSError?) -> Data? {
        return CryptoAttachSignature(signature, transaction, &error)
    }
    
    func getSignedTransaction(with signer: String?, transaction: Data, from signature: Data, error: inout NSError?) -> Data? {
        return CryptoAttachSignatureWithSigner(signature, transaction, signer, &error)
    }
}

extension AlgorandSDK {
    func mnemonicFrom(_ privateKey: Data, error: inout NSError?) -> String {
        return MnemonicFromPrivateKey(privateKey, &error)
    }
    
    func privateKeyFrom(_ mnemonic: String, error: inout NSError?) -> Data? {
        return MnemonicToPrivateKey(mnemonic, &error)
    }
    
    func addressFrom(_ privateKey: Data, error: inout NSError?) -> String? {
        return CryptoGenerateAddressFromSK(privateKey, &error)
    }
    
    func addressFromPublicKey(_ publicKey: Data, error: inout NSError?) -> String {
        return CryptoGenerateAddressFromPublicKey(publicKey, &error)
    }
}

extension AlgorandSDK {
    func sendAlgos(with draft: AlgosTransactionDraft, error: inout NSError?) -> Data? {
        let toAddress = draft.toAccount.trimmingCharacters(in: .whitespacesAndNewlines)
        return TransactionMakePaymentTxn(
            getTrimmedAddress(from: draft.from),
            toAddress,
            draft.transactionParams.fee,
            draft.amount,
            draft.transactionParams.lastRound,
            draft.transactionParams.lastRound + roundTreshold, // Need to add 1000 as last round
            draft.note,
            draft.isMaxTransaction ? toAddress : nil,
            nil,
            draft.transactionParams.genesisHashData,
            &error
        )
    }
}

extension AlgorandSDK {
    func sendAsset(with draft: AssetTransactionDraft, error: inout NSError?) -> Data? {
        return TransactionMakeAssetTransferTxn(
            getTrimmedAddress(from: draft.from),
            draft.toAccount.trimmingCharacters(in: .whitespacesAndNewlines),
            "", // closing address should be empty for asset transaction
            draft.amount,
            draft.transactionParams.fee,
            draft.transactionParams.lastRound,
            draft.transactionParams.lastRound + roundTreshold, // Need to add 1000 as last round
            draft.note,
            nil,
            draft.transactionParams.genesisHashData?.base64EncodedString(),
            draft.assetIndex,
            &error
        )
    }
    
    func addAsset(with draft: AssetAdditionDraft, error: inout NSError?) -> Data? {
        return TransactionMakeAssetAcceptanceTxn(
            getTrimmedAddress(from: draft.from),
            draft.transactionParams.fee,
            draft.transactionParams.lastRound,
            draft.transactionParams.lastRound + roundTreshold, // Need to add 1000 as last round
            nil,
            nil,
            draft.transactionParams.genesisHashData?.base64EncodedString(),
            draft.assetIndex,
            &error
        )
    }
    
    func removeAsset(with draft: AssetRemovalDraft, error: inout NSError?) -> Data? {
        return TransactionMakeAssetTransferTxn(
            getTrimmedAddress(from: draft.from),
            getTrimmedAddress(from: draft.from), // Receiver address should be same with the sender while removing an asset
            draft.assetCreatorAddress,
            draft.amount,
            draft.transactionParams.fee,
            draft.transactionParams.lastRound,
            draft.transactionParams.lastRound + roundTreshold, // Need to add 1000 as last round
            nil,
            nil,
            draft.transactionParams.genesisHashData?.base64EncodedString(),
            draft.assetIndex,
            &error
        )
    }
}

extension AlgorandSDK {
    func rekeyAccount(with draft: RekeyTransactionDraft, error: inout NSError?) -> Data? {
        return TransactionMakeRekeyTxn(
            getTrimmedAddress(from: draft.from),
            draft.rekeyedAccount.trimmingCharacters(in: .whitespacesAndNewlines),
            draft.transactionParams.fee,
            draft.transactionParams.lastRound,
            draft.transactionParams.lastRound + roundTreshold, // Need to add 1000 as last round
            nil,
            draft.transactionParams.genesisHashData,
            &error
        )
    }
}

extension AlgorandSDK {
    func isValidAddress(_ address: String) -> Bool {
        return UtilsIsValidAddress(address)
    }
}

extension AlgorandSDK {
    private func getTrimmedAddress(from account: Account) -> String {
        return account.address.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
