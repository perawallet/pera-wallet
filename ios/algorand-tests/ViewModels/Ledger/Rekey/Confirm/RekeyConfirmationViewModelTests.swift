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
//  RekeyConfirmationViewModelTests.swift

import XCTest

@testable import pera_staging

class RekeyConfirmationViewModelTests: XCTestCase {

    private let account = Bundle.main.decode(response: Account.self, from: "AccountA.json")

//    func testAssetText() {
//        let viewModel = RekeyConfirmationViewModel(account: account, ledgerName: "Ledger Name 1")
//        XCTAssertEqual(viewModel.assetText, "+5 more assets")
//    }

    func testOldTransitionTitle() {
        let viewModel = RekeyConfirmationViewModel(account: account, ledgerName: "Ledger Name 1", newAuthAddress: "")
        XCTAssertEqual(viewModel.oldTransitionTitle, "Passphrase")
    }

//    func testOldTransitionValue() {
//        let viewModel = RekeyConfirmationViewModel(account: account, ledgerName: "Ledger Name 1")
//        XCTAssertEqual(viewModel.oldTransitionValue, "*********")
//    }

    func testNewTransitionValue() {
        let viewModel = RekeyConfirmationViewModel(account: account, ledgerName: "Ledger Name 1", newAuthAddress: "")
        XCTAssertEqual(viewModel.newTransitionValue, "Ledger Name 1")
    }
}
