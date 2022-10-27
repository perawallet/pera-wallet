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

//   PasswordMigration.swift

import Foundation

final class PasswordMigration {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func migratePasswordToKeychain() {
        guard !session.hasPassword() else {
            /// <note>
            /// If password is exist on keychain, we shouldn't update/migrate the password
            /// We should try to remove password on database if needed
            session.deletePasswordFromDatabase()
            return
        }

        guard session.hasPasswordOnDatabase() else {
            /// <note>
            /// If password is not exist in database, no need to migrate
            return
        }

        session.savePasswordToKeychain()
    }
}

extension Session {
    fileprivate func savePasswordToKeychain() {
        guard let password = passwordOnDatabase() else {
            return
        }

        deletePasswordFromDatabase()
        savePassword(password)
    }

    private func passwordOnDatabase() -> String? {
        applicationConfiguration?.password
    }

    fileprivate func deletePasswordFromDatabase() {
        guard hasPasswordOnDatabase() else {
            return
        }
        
        if let config = applicationConfiguration {
            config.removeValue(entity: ApplicationConfiguration.entityName, with: ApplicationConfiguration.DBKeys.password.rawValue)
        }
    }
}
