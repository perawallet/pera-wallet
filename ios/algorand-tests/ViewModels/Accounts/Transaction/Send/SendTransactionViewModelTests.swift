// Copyright 2019 Algorand, Inc.

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
//  SendTransactionViewModelTests.swift

import XCTest

@testable import algorand_staging

class SendTransactionViewModelTests: XCTestCase {

    private let account = Bundle.main.decode(Account.self, from: "AccountA.json")

    private var algosDraft: AlgosTransactionSendDraft {
        return AlgosTransactionSendDraft(
            from: account,
            toAccount: "X2YHQU7W6OJG66TMLL3PZ7JQS2D42YEGATBBNDXH22Q6JSNOFR6LVZYXXM",
            amount: 1234567,
            fee: 1000,
            isMaxTransaction: false,
            identifier: "id",
            note: "This is note"
        )
    }

    private var assetDraft: AssetTransactionSendDraft {
        return AssetTransactionSendDraft(
            from: account,
            toAccount: "X2YHQU7W6OJG66TMLL3PZ7JQS2D42YEGATBBNDXH22Q6JSNOFR6LVZYXXM",
            amount: 1234567,
            fee: 1000,
            isMaxTransaction: false,
            identifier: "id",
            assetIndex: 11711,
            assetCreator: "",
            closeAssetsTo: nil,
            assetDecimalFraction: 2,
            isVerifiedAsset: false,
            note: "This is note"
        )
    }

    func testButtonTitle() {
        let viewModel = SendTransactionViewModel(transactionDraft: algosDraft)
        XCTAssertEqual(viewModel.buttonTitle, "Send Algos")
    }

    func testAssetName() {
        let viewModel = SendTransactionViewModel(transactionDraft: algosDraft)
        XCTAssertEqual(viewModel.assetName, "Algos")
    }

    func testAssetId() {
        let viewModel = SendTransactionViewModel(transactionDraft: algosDraft)
        XCTAssertNil(viewModel.assetId)
    }

    func testReceiverName() {
        let viewModel = SendTransactionViewModel(transactionDraft: algosDraft)
        XCTAssertEqual(viewModel.receiverName, "X2YHQU...VZYXXM")
    }

    func testButtonTitleAssetTransaction() {
        let viewModel = SendTransactionViewModel(transactionDraft: assetDraft)
        XCTAssertEqual(viewModel.buttonTitle, "Send HipoCoin")
    }

    func testAssetNameForAssetTransaction() {
        let viewModel = SendTransactionViewModel(transactionDraft: assetDraft)
        XCTAssertEqual(viewModel.assetName, "HIPO")
    }

    func testAssetIdAssetTransaction() {
        let viewModel = SendTransactionViewModel(transactionDraft: assetDraft)
        XCTAssertEqual(viewModel.assetId, "11711")
    }

    func testReceiverNameAssetTransaction() {
        let viewModel = SendTransactionViewModel(transactionDraft: assetDraft)
        XCTAssertEqual(viewModel.receiverName, "X2YHQU...VZYXXM")
    }
}
