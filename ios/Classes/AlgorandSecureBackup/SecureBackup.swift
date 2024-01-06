// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SecureBackup.swift

import Foundation

final class SecureBackup: ALGAPIModel {
    let cipherText: Data?
    let version: String?
    let suite: String?

    init() {
        cipherText = nil
        version = nil
        suite = nil
    }

    /// <note>: Initializer with data produce a secure backup object for export
    init(data: Data) {
        cipherText = data
        version = "1.0"
        suite = "HMAC-SHA256:sodium_secretbox_easy"
    }

    /// <note>: It is currently checking the suite is not empty or blank
    /// It may be updated in the future.
    func hasValidSuite() -> Bool {
        !suite.isNilOrEmpty
    }

    func hasValidCipherText() -> Bool {
        cipherText != nil
    }
}

extension SecureBackup {
    enum CodingKeys: String, CodingKey {
        case version
        case suite
        case cipherText = "ciphertext"
    }
}
