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

//
//  UserTests.swift

import XCTest

@testable import pera_staging

class UserTests: XCTestCase {

    private let user = Bundle.main.decode(User.self, from: "User.json")
    private let accountInformationA = Bundle.main.decode(AccountInformation.self, from: "AccountInformationA.json")
    private let accountInformationB = Bundle.main.decode(AccountInformation.self, from: "AccountInformationB.json")

    func testAddAccount() {
        let accountCount = user.accounts.count
        user.addAccount(accountInformationA)
        XCTAssertNotEqual(accountCount, user.accounts.count)
    }

    func testRemoveAccount() {
        let accountCount = user.accounts.count
        user.removeAccount(accountInformationA)
        XCTAssertNotEqual(accountCount, user.accounts.count)
    }

    func testIndexOfAccount() {
        let index = user.index(of: accountInformationA)
        XCTAssertEqual(index, 0)
    }

    func testAccountAtIndex() {
        let accountInformation = user.account(at: 2)
        XCTAssertEqual(accountInformation?.address, accountInformationB.address)
    }

    func testUpdateAccount() {
        accountInformationA.name = "Updated Name"
        user.updateAccount(accountInformationA)
        let updatedAccount = user.account(address: accountInformationA.address)
        XCTAssertEqual(updatedAccount?.name, "Updated Name")
    }

    func preferredAlgorandNetwork() {
        let preferredNetwork = user.preferredAlgorandNetwork()
        XCTAssertEqual(preferredNetwork?.rawValue, "testnet")
    }
}
