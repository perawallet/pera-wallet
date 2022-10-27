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

//   Cryptor.swift

import Foundation
import CommonCrypto
import CryptoSwift
import AlgoSDK


final class Cryptor {
    typealias EncryptionData = (data: Data?, error: EncryptionError?)

    let key: String

    init(key: String) {
        self.key = key
    }

    func encrypt(data: Data) -> EncryptionData {
        let encryptedContent = AlgoMobileEncrypt(data, generateKeyData())
        let error = EncryptionError(rawValue: encryptedContent?.errorCode ?? EncryptionError.unknown.rawValue)
        return (encryptedContent?.encryptedData, error)
    }

    func decrypt(data: Data) -> EncryptionData? {
        let decryptedContent = AlgoMobileDecrypt(data, generateKeyData())
        let error = EncryptionError(rawValue: decryptedContent?.errorCode ?? EncryptionError.unknown.rawValue)
        return (decryptedContent?.decryptedData, error)
    }

    private func generateKeyData() -> Data {
        let data = key.convertToByteArray(using: ",")

        return Data(bytes: data)
    }
}

enum EncryptionError: Int {
    // ErrorCode Descriptions
    // 0 => No Error
    // 1 => Invalid SecretKey
    // 2 => Random Generator Error
    // 3 => Invalid encrypted data length
    // 4 => Decryption error

    case noError = 0
    case invalidSecretKey = 1
    case invalidRandomGenerator = 2
    case invalidEncryptedData = 3
    case decryptionError = 4
    case unknown

    init?(rawValue: Int) {
        switch rawValue {
        case 0:
            self = .noError
        case 1:
            self = .invalidSecretKey
        case 2:
            self = .invalidRandomGenerator
        case 3:
            self = .invalidEncryptedData
        case 4:
            self = .decryptionError
        default:
            self = .unknown
        }
    }
}
