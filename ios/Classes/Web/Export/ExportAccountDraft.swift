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

//   ExportAccountDraft.swift

import Foundation
import MagpieCore

final class ExportAccountDraft: JSONObjectBody {
    var deviceId: String = "-1"
    var accounts: [[String: String]] = []

    var bodyParams: [APIBodyParam] {
        var params: [APIBodyParam] = []
        params.append(.init(.deviceId, deviceId))
        params.append(.init(.accounts, accounts))
        return params
    }

    init() {
        deviceId = "-1"
        accounts = []
    }

    init(deviceId: String) {
        self.accounts = []
        self.deviceId = deviceId
    }

    func populate(accounts: [Account], with session: Session?) {
        let tempAccounts: [[String: String]] = accounts.compactMap { account in
            guard let privateKey = session?.privateData(for: account.address) else {
                return nil
            }

            let bytes = privateKey.toBytes().map({ String($0) }).joined(separator: ",")

            return [
                APIParamKey.name.rawValue: account.name ?? "",
                APIParamKey.privateKey.rawValue: bytes
            ]
        }

        self.accounts = tempAccounts
    }
}

final class EncryptedExportAccountDraft: JSONObjectBody {
    let draft: ExportAccountDraft
    let qrExportInformations: QRExportInformations

    private(set) var encryptionError: EncryptionError?

    private(set) lazy var encryptedContent: String? = {
        do {
            let encodedContent = try draft.encoded()
            let cryptor = Cryptor(key: qrExportInformations.encryptionKey)
            let encryptedContent = cryptor.encrypt(data: encodedContent)

            if let data = encryptedContent.data {
                let content = data.toBytes().map({ String($0) }).joined(separator: ",")
                self.encryptionError = .noError
                return content
            }

            self.encryptionError = encryptedContent.error
            return nil
        } catch {
            self.encryptionError = .unknown
            return nil
        }
    }()

    var bodyParams: [APIBodyParam] {
        var params: [APIBodyParam] = []

        if let content = encryptedContent {
            params.append(.init(.encryptedContent, content))
        }
        
        return params
    }

    init(draft: ExportAccountDraft, qrExportInformations: QRExportInformations) {
        self.draft = draft
        self.qrExportInformations = qrExportInformations
    }
}
