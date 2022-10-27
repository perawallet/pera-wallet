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

//   PasswordMigrationTests.swift

import XCTest

@testable import pera_staging

final class PasswordMigrationTests: XCTestCase {
    func testNonMigratedPassword() throws {
        let session = Session()
        session.reset(includingContacts: true)
        session.savePasswordToDatabase("123456")
        XCTAssertTrue(session.hasPasswordOnDatabase())
        XCTAssertFalse(session.isPasswordMatchingOnDatabase(with: "1234566"))
        XCTAssertTrue(session.isPasswordMatchingOnDatabase(with: "123456"))

        let migrator = PasswordMigration(session: session)
        migrator.migratePasswordToKeychain()
        /// After migration, it should be on keychain instead of database
        /// If there is a password on db, it should be deleted after migration
        XCTAssertFalse(session.hasPasswordOnDatabase())
        XCTAssertTrue(session.hasPassword())
        /// After migration this method should be return
        XCTAssertTrue(session.isPasswordMatching(with: "123456"))
    }

    func testMigratedPassword() throws {
        let session = Session()
        session.reset(includingContacts: true)
        session.savePassword("123456")
        XCTAssertFalse(session.hasPasswordOnDatabase())
        XCTAssertFalse(session.isPasswordMatchingOnDatabase(with: "1234566"))
        XCTAssertFalse(session.isPasswordMatchingOnDatabase(with: "123456"))
        XCTAssertTrue(session.hasPassword())
        XCTAssertTrue(session.isPasswordMatching(with: "123456"))

        let migrator = PasswordMigration(session: session)
        migrator.migratePasswordToKeychain()
        /// After migration, it should be on keychain instead of database
        /// If there is a password on db, it should be deleted after migration
        XCTAssertFalse(session.hasPasswordOnDatabase())
        XCTAssertTrue(session.hasPassword())
        /// After migration this method should be return
        XCTAssertTrue(session.isPasswordMatching(with: "123456"))
    }

    func testMigrationOnDatabaseFail() throws {
        let session = Session()
        session.reset(includingContacts: true)
        session.savePasswordToDatabase("123456")
        XCTAssertTrue(session.hasPasswordOnDatabase())
        XCTAssertFalse(session.isPasswordMatchingOnDatabase(with: "1234566"))
        XCTAssertTrue(session.isPasswordMatchingOnDatabase(with: "123456"))

        let migrator = PasswordMigration(session: session)
        migrator.migratePasswordToKeychain()
        /// After migration, it should be on keychain instead of database
        /// If there is a password on db, it should be deleted after migration
        XCTAssertFalse(session.hasPasswordOnDatabase())
        XCTAssertTrue(session.hasPassword())
        /// After migration this method should be return
        XCTAssertTrue(session.isPasswordMatching(with: "123456"))

        /// Update password on keychain
        session.savePassword("000000")

        /// Simulate DB fails
        session.savePasswordToDatabase("123456")
        XCTAssertTrue(session.hasPasswordOnDatabase())

        /// I don't add `XCTAssertFalse(session.hasPasswordOnDatabase())` because we simulate DB fail operation
        /// Migration shouldn't override password because we already have updated one on keychain
        migrator.migratePasswordToKeychain()

        XCTAssertFalse(session.isPasswordMatching(with: "123456"))
        XCTAssertTrue(session.isPasswordMatching(with: "000000"))
    }
}
