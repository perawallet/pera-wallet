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

//   QRBackupParameters.swift

import Foundation

enum QRBackupAction: RawRepresentable, ALGAPIModel {
    var rawValue: String {
        switch self {
        case .import:
            return "import"
        case .unsupported(let unsupportedValue):
            return unsupportedValue
        }
    }

    init?(rawValue: String) {
        switch rawValue {
        case "import":
            self = .import
        default:
            self = .unsupported(rawValue)
        }
    }

    init() {
        self = .unsupported("unsupported")
    }

    case `import`
    case unsupported(String)
}

final class QRBackupParameters: ALGAPIModel, Identifiable {
    let id: String
    let modificationKey: String?
    let encryptionKey: String
    let version: String
    let action: QRBackupAction

    init() {
        id = ""
        modificationKey = nil
        encryptionKey = ""
        version = ""
        action = QRBackupAction()
    }

    func isSupported() -> Bool {
        return version == "1"
    }
}

extension QRBackupParameters {
    enum CodingKeys: String, CodingKey {
        case id = "backupId"
        case modificationKey
        case encryptionKey
        case version
        case action
    }
}
