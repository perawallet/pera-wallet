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
//  TransactionParamsTests.swift

import XCTest

@testable import pera_staging

class TransactionParamsTests: XCTestCase {

    private let params = Bundle.main.decode(response: TransactionParams.self, from: "TransactionParams.json")

    func testGetProjectedTransactionFee() {
        let projectedFee = params.getProjectedTransactionFee()
        XCTAssertEqual(projectedFee, 1000)
    }

    func testGetProjectedTransactionFeeWithData() {
        let projectedFee = params.getProjectedTransactionFee(from: 300)
        XCTAssertEqual(projectedFee, 1000)
    }
}
