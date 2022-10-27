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
//  TransactionFeeCalculatorTests.swift

import XCTest

@testable import pera_staging

class TransactionFeeCalculatorTests: XCTestCase {

    private let account = Bundle.main.decode(response: Account.self, from: "AccountA.json")
    private let transactionSendDraft = AlgosTransactionSendDraft(from: Bundle.main.decode(response: Account.self, from: "AccountA.json"))
    private let transactionData = TransactionData()
    private let params = Bundle.main.decode(response: TransactionParams.self, from: "TransactionParams.json")

    private lazy var transactionFeeCalculator: TransactionFeeCalculator = {
        transactionData.setSignedTransaction(Data(count: 250))
        return TransactionFeeCalculator(transactionDraft: transactionSendDraft, transactionData: transactionData, params: params)
    }()

    private lazy var notValidTransactionFeeCalculator: TransactionFeeCalculator = {
        let minAccountBalanceAccount = Bundle.main.decode(response: Account.self, from: "AccountA.json")
//        minAccountBalanceAccount.amount = 600000

        transactionData.setSignedTransaction(Data(count: 250))

        let minBalanceTransactionSendDraft = AlgosTransactionSendDraft(from: minAccountBalanceAccount)

        return TransactionFeeCalculator(transactionDraft: minBalanceTransactionSendDraft, transactionData: transactionData, params: params)
    }()

    override func setUp() {
        super.setUp()

        let minAccountBalanceAccount = Bundle.main.decode(response: Account.self, from: "AccountA.json")
//        minAccountBalanceAccount.amount = 600000
        let minBalanceTransactionSendDraft = AlgosTransactionSendDraft(from: minAccountBalanceAccount)
        notValidTransactionFeeCalculator = TransactionFeeCalculator(
            transactionDraft: minBalanceTransactionSendDraft,
            transactionData: transactionData,
            params: params
        )
    }

    func testAlgosTransactionFeeCalculation() {
        let fee = transactionFeeCalculator.calculate(for: .algosTransaction)
        XCTAssertEqual(fee, 1000)
    }

//    func testMinimumamountAfterAlgosTransaction() {
//        let minAmount = transactionFeeCalculator.calculateMinimumAmount(
//            for: account,
//            with: .algosTransaction,
//            calculatedFee: 1000,
//            isAfterTransaction: true
//        )
//        XCTAssertEqual(minAmount, 701000)
//    }

    func testIsValidAlgosTransaction() {
        XCTAssertTrue(transactionFeeCalculator.isValidTransactionAmount(for: .algosTransaction, calculatedFee: 1000))
    }

    func testIsNotValidAlgosTransaction() {
        XCTAssertFalse(notValidTransactionFeeCalculator.isValidTransactionAmount(for: .algosTransaction, calculatedFee: 1000))
    }

    func testAssetTransactionFeeCalculation() {
        let fee = transactionFeeCalculator.calculate(for: .assetTransaction)
        XCTAssertEqual(fee, 1000)
    }

//    func testMinimumamountAfterAssetTransaction() {
//        let minAmount = transactionFeeCalculator.calculateMinimumAmount(
//            for: account,
//            with: .assetTransaction,
//            calculatedFee: 1000,
//            isAfterTransaction: true
//        )
//        XCTAssertEqual(minAmount, 701000)
//    }

    func testIsValidAssetTransaction() {
        XCTAssertTrue(transactionFeeCalculator.isValidTransactionAmount(for: .assetTransaction, calculatedFee: 1000))
    }

    func testIsNotValidAssetTransaction() {
        XCTAssertFalse(notValidTransactionFeeCalculator.isValidTransactionAmount(for: .assetTransaction, calculatedFee: 1000))
    }

    func testAddAssetTransactionFeeCalculation() {
        let fee = transactionFeeCalculator.calculate(for: .assetAddition)
        XCTAssertEqual(fee, 1000)
    }

//    func testMinimumamountAfterAddAssetTransaction() {
//        let minAmunt = transactionFeeCalculator.calculateMinimumAmount(
//            for: account,
//            with: .assetAddition,
//            calculatedFee: 1000,
//            isAfterTransaction: true
//        )
//        XCTAssertEqual(minAmunt, 801000)
//    }

    func testIsValidAddAssetTransaction() {
        XCTAssertTrue(transactionFeeCalculator.isValidTransactionAmount(for: .assetAddition, calculatedFee: 1000))
    }

    func testIsNotValidAddAssetTransaction() {
        XCTAssertFalse(notValidTransactionFeeCalculator.isValidTransactionAmount(for: .assetAddition, calculatedFee: 1000))
    }

    func testRemoveAssetTransactionFeeCalculation() {
        let fee = transactionFeeCalculator.calculate(for: .assetRemoval)
        XCTAssertEqual(fee, 1000)
    }

//    func testMinimumamountAfterRemoveAssetTransaction() {
//        let minAmunt = transactionFeeCalculator.calculateMinimumAmount(
//            for: account,
//            with: .assetRemoval,
//            calculatedFee: 1000,
//            isAfterTransaction: true
//        )
//        XCTAssertEqual(minAmunt, 601000)
//    }

    func testIsValidRemoveAssetTransaction() {
        XCTAssertTrue(transactionFeeCalculator.isValidTransactionAmount(for: .assetRemoval, calculatedFee: 1000))
    }

    func testIsNotValidRemoveAssetTransaction() {
        XCTAssertFalse(notValidTransactionFeeCalculator.isValidTransactionAmount(for: .assetRemoval, calculatedFee: 1000))
    }

//    func testMinimumamountAfterRekeyTransaction() {
//        let minAmunt = transactionFeeCalculator.calculateMinimumAmount(
//            for: account,
//            with: .rekey,
//            calculatedFee: 1000,
//            isAfterTransaction: true
//        )
//        XCTAssertEqual(minAmunt, 701000)
//    }

    func testIsValidRekeyTransaction() {
        XCTAssertTrue(transactionFeeCalculator.isValidTransactionAmount(for: .rekey, calculatedFee: 1000))
    }

    func testIsNotValidRekeyTransaction() {
        XCTAssertFalse(notValidTransactionFeeCalculator.isValidTransactionAmount(for: .rekey, calculatedFee: 1000))
    }
}
