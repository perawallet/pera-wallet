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

import AlgoSDK

class AlgorandSDK {
    
    static let roundTreshold: Int64 = 1000
    
    func generatePrivateKey() -> Data? {
        return AlgoMobileGenerateSK()
    }
    
    func sign(_ privateData: Data, with data: Data, error: inout NSError?) -> Data? {
        return AlgoMobileSignTransaction(privateData, data, &error)
    }
    
    func getSignedTransaction(_ transaction: Data, from signature: Data, error: inout NSError?) -> Data? {
        return AlgoMobileAttachSignature(signature, transaction, &error)
    }
    
    func getSignedTransaction(with signer: String?, transaction: Data, from signature: Data, error: inout NSError?) -> Data? {
        return AlgoMobileAttachSignatureWithSigner(signature, transaction, signer, &error)
    }
}

extension AlgorandSDK {
    func mnemonicFrom(_ privateKey: Data, error: inout NSError?) -> String {
        return AlgoMobileMnemonicFromPrivateKey(privateKey, &error)
    }
    
    func privateKeyFrom(_ mnemonic: String, error: inout NSError?) -> Data? {
        return AlgoMobileMnemonicToPrivateKey(mnemonic, &error)
    }
    
    func addressFrom(_ privateKey: Data, error: inout NSError?) -> String? {
        return AlgoMobileGenerateAddressFromSK(privateKey, &error)
    }
    
    func addressFromPublicKey(_ publicKey: Data, error: inout NSError?) -> String {
        return AlgoMobileGenerateAddressFromPublicKey(publicKey, &error)
    }
}

extension AlgorandSDK {
    func sendAlgos(with draft: AlgosTransactionDraft, error: inout NSError?) -> Data? {
        let toAddress = draft.toAccount.trimmingCharacters(in: .whitespacesAndNewlines)
        return AlgoMobileMakePaymentTxn(
            getTrimmedAddress(from: draft.from),
            toAddress,
            draft.amount.toSDKInt64(),
            draft.note,
            draft.isMaxTransaction ? toAddress : nil,
            draft.transactionParams.toSDKSuggestedParams(),
            &error
        )
    }
}

extension AlgorandSDK {
    func sendAsset(with draft: AssetTransactionDraft, error: inout NSError?) -> Data? {
        return AlgoMobileMakeAssetTransferTxn(
            getTrimmedAddress(from: draft.from),
            draft.toAccount.trimmingCharacters(in: .whitespacesAndNewlines),
            "", // closing address should be empty for asset transaction
            draft.amount.toSDKInt64(),
            draft.note,
            draft.transactionParams.toSDKSuggestedParams(),
            draft.assetIndex,
            &error
        )
    }
    
    func addAsset(with draft: AssetAdditionDraft, error: inout NSError?) -> Data? {
        return AlgoMobileMakeAssetAcceptanceTxn(
            getTrimmedAddress(from: draft.from),
            draft.note,
            draft.transactionParams.toSDKSuggestedParams(),
            draft.assetIndex,
            &error
        )
    }
    
    func removeAsset(with draft: AssetRemovalDraft, error: inout NSError?) -> Data? {
        return AlgoMobileMakeAssetTransferTxn(
            getTrimmedAddress(from: draft.from),
            getTrimmedAddress(from: draft.from), // Receiver address should be same with the sender while removing an asset
            draft.assetCreatorAddress,
            draft.amount.toSDKInt64(),
            draft.note,
            draft.transactionParams.toSDKSuggestedParams(),
            draft.assetIndex,
            &error
        )
    }
}

extension AlgorandSDK {
    func rekeyAccount(with draft: RekeyTransactionDraft, error: inout NSError?) -> Data? {
        return AlgoMobileMakeRekeyTxn(
            getTrimmedAddress(from: draft.from),
            draft.rekeyedAccount.trimmingCharacters(in: .whitespacesAndNewlines),
            draft.transactionParams.toSDKSuggestedParams(),
            &error
        )
    }
}

extension AlgorandSDK {
    func isValidAddress(_ address: String) -> Bool {
        return AlgoMobileIsValidAddress(address)
    }

    func msgpackToJSON(_ msgpack: Data?, error: inout NSError?) -> String {
        return AlgoMobileTransactionMsgpackToJson(msgpack, &error)
    }

    func jsonToMsgpack(_ json: String, error: inout NSError?) -> Data? {
        return AlgoMobileTransactionJsonToMsgpack(json, &error)
    }

    func findAndVerifyTransactionGroups(for transactions: [Data], error: inout NSError?) -> [Int64]? {
        return AlgoMobileFindAndVerifyTxnGroups(transactions.toSDKByteArray(), &error)?.toIntArray()
    }

    func getTransactionID(for transaction: Data) -> String {
        return AlgoMobileGetTxID(transaction)
    }

    func getAddressfromProgram(_ program: Data?) -> String {
        return AlgoMobileAddressFromProgram(program)
    }
}

extension AlgorandSDK {
    private func getTrimmedAddress(from account: Account) -> String {
        return account.address.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

fileprivate extension TransactionParams {
    func toSDKSuggestedParams() -> AlgoMobileSuggestedParams {
        let params = AlgoMobileSuggestedParams()
        params.fee = Int64(fee)
        params.firstRoundValid = Int64(lastRound)
        params.lastRoundValid = Int64(lastRound) + AlgorandSDK.roundTreshold // Need to add 1000 as last round
        params.genesisHash = genesisHashData
        params.genesisID = genesisId.unwrap(or: "")
        return params
    }
}

fileprivate extension Array where Element == Data {
    func toSDKByteArray() -> AlgoMobileBytesArray {
        let transactionByteArray = AlgoMobileBytesArray()
        forEach {
            transactionByteArray.append($0)
        }
        return transactionByteArray
    }
}

fileprivate extension AlgoMobileInt64Array {
    func toIntArray() -> [Int64] {
        var intArray = [Int64]()

        for i in 0...length() - 1 {
            intArray.append(get(i))
        }

        return intArray
    }
}

fileprivate extension UInt64 {
    // Received from: https://github.com/algorand/go-algorand-sdk/blob/MobileWrapper/mobile/utils.go#L22-L27
    func toSDKInt64() -> AlgoMobileUint64 {
        let int64 = AlgoMobileUint64()
        let upperValue = (self >> 32)
        int64.upper = Int64(upperValue)
        let lowerValue = UInt64(UInt32.max) & self
        int64.lower = Int64(lowerValue)
        return int64
    }
}
