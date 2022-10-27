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
//  AccountTests.swift

import XCTest

@testable import pera_staging

class AccountTests: XCTestCase {

    private let account = Bundle.main.decode(response: Account.self, from: "AccountA.json")
    private let accountB = Bundle.main.decode(response: Account.self, from: "AccountB.json")
    private let assetDetail = Bundle.main.decode(response: AssetDetail.self, from: "HipoCoinAsset.json")

//    func testAmount() {
//        let amount = account.amount(for: assetDetail)
//        XCTAssertEqual(amount, 2759.49)
//    }

//    func testAmountDisplayWithFraction() {
//        let amountDisplayWithFraction = account.amountDisplayWithFraction(for: assetDetail)
//        XCTAssertEqual(amountDisplayWithFraction, "2,759.49")
//    }

//    func testIsThereAnyDifferentAsset() {
//        let isThereAnyDifferentAsset = account.isThereAnyDifferentAsset()
//        XCTAssertTrue(isThereAnyDifferentAsset)
//    }

    func testDoesAccountHasParticipationKey() {
        let doesAccountHasParticipationKey = account.hasParticipationKey()
        XCTAssertFalse(doesAccountHasParticipationKey)
    }

    func testHasDifferentAssets() {
        let hasDifferentAssets = account.hasDifferentAssets(than: accountB)
        XCTAssertTrue(hasDifferentAssets)
    }

//    func testRemoveAssets() {
//        let assetCount = account.assetDetails.count
//        account.removeAsset(assetDetail.id)
//        XCTAssertNotEqual(assetCount, account.assetDetails.count)
//    }

//    func testContainsAsset() {
//        let containsAsset = account.containsAsset(assetDetail.id)
//        XCTAssertTrue(containsAsset)
//    }

    func testRequiresLedgerConnection() {
        let requiresLedgerConnection = account.requiresLedgerConnection()
        XCTAssertFalse(requiresLedgerConnection)
    }

    func testAddRekeyDetail() {
        let ledgerDetail = Bundle.main.decode(LedgerDetail.self, from: "LedgerDetail.json")
        account.addRekeyDetail(ledgerDetail, for: accountB.address)
        XCTAssertNotNil(account.rekeyDetail)
    }

    func testCurrentLedgerDetailForRekey() {
        let rekeyedAccount = Bundle.main.decode(response: Account.self, from: "RekeyedAccount.json")
        let currentLedgerDetail = rekeyedAccount.currentLedgerDetail
        XCTAssertEqual(currentLedgerDetail?.id, currentLedgerDetail?.id)
    }

    func testCurrentLedgerDetailForLedger() {
        let ledgerAccount = Bundle.main.decode(response: Account.self, from: "LedgerAccount.json")
        let currentLedgerDetail = ledgerAccount.currentLedgerDetail
        XCTAssertEqual(currentLedgerDetail?.id, currentLedgerDetail?.id)
    }
}
