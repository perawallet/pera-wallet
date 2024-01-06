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

//   BackupParameters.swift

import Foundation

final class BackupParameters: ALGAPIModel {
    let accounts: [AccountImportParameters]
    let providerName: String?

    init() {
        accounts = []
        providerName = nil
    }

    init(accounts: [AccountImportParameters], providerName: String? = nil) {
        self.accounts = accounts
        self.providerName = providerName ?? "Pera Wallet"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let accountsApiModel = try container.decode([AccountImportParameters.APIModel].self, forKey: .accounts)
        accounts = accountsApiModel.map { .init($0) }
        providerName = try container.decodeIfPresent(String.self, forKey: .providerName)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accounts.map { $0.encode() }, forKey: .accounts)
        try container.encodeIfPresent(providerName, forKey: .providerName)
    }
}

extension BackupParameters {
    enum CodingKeys: String, CodingKey {
        case accounts = "accounts"
        case providerName = "provider_name"
    }
}
