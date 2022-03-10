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
//  PaymentTests.swift

import XCTest

@testable import pera_staging

class PaymentTests: XCTestCase {

    private let payment = Bundle.main.decode(response: Payment.self, from: "Payment.json")

    func testAmountForTransaction() {
        let amount = payment.amountForTransaction(includesCloseAmount: false)
        XCTAssertEqual(amount, 200000)
    }

//    func testAmountForTransactionWithClose() {
//        let amount = payment.amountForTransaction(includesCloseAmount: true)
//        XCTAssertEqual(amount, 200100)
//    }
//
//    func testCloseAmountForTransaction() {
//        let closeAmount = payment.closeAmountForTransaction()
//        XCTAssertEqual(closeAmount, 100)
//    }
}
