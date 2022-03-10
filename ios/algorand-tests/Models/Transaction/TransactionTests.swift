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
//  TransactionTests.swift

import XCTest

@testable import pera_staging

class TransactionTests: XCTestCase {

    private let algoTransaction = Bundle.main.decode(response: Transaction.self, from: "AlgoTransaction.json")
    private let assetTransaction = Bundle.main.decode(response: Transaction.self, from: "AssetTransaction.json")
    private let assetAdditionTransaction = Bundle.main.decode(response: Transaction.self, from: "AssetTransaction.json")
    
    func testIsPending() {
        XCTAssertFalse(algoTransaction.isPending())
    }

    func testIsAssetAdditionTransaction() {
        let address = "X2YHQU7W6OJG66TMLL3PZ7JQS2D42YEGATBBNDXH22Q6JSNOFR6LVZYXXM"
        XCTAssertTrue(assetAdditionTransaction.isAssetAdditionTransaction(for: address))
    }

    func testNoteRepresentation() {
        let note = assetTransaction.noteRepresentation()
        XCTAssertEqual(note, "hey")
    }
}
