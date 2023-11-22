// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WalletConnectV1SessionValidatorTests.swift

import XCTest

@testable import pera_staging

final class WalletConnectV1SessionValidatorTests: XCTestCase {
    private let sessionValidator = WalletConnectV1SessionValidator()
    
    func test_isValidSession_valid() {
        let sessionURL = "wc:87ae23c4-37d3-40c1-b72f-e00d510b5e66@1?bridge=https%3A%2F%2F0.bridge.walletconnect.org&key=c3a898e05817b4af9a40d5f15e806984e30b04d84e770275a6cb4ad17859da1d&algorand=true"
        let isValidSession = sessionValidator.isValidSession(sessionURL)
        XCTAssertTrue(isValidSession)
    }
    
    func test_isValidSession_invalid_prefix() {
        let sessionWrongPrefixURL = "ww:87ae23c4-37d3-40c1-b72f-e00d510b5e66@1?bridge=https%3A%2F%2F0.bridge.walletconnect.org&key=c3a898e05817b4af9a40d5f15e806984e30b04d84e770275a6cb4ad17859da1d&algorand=true"
        let isValidSession = sessionValidator.isValidSession(sessionWrongPrefixURL)
        XCTAssertFalse(isValidSession)
    }
    
    func test_isValidSession_invalid_urlConfig() {
        let sessionInvalidURL = "ww:87ae23c4-37d3-40c1-b72f-e00d510b5e66@1?bridge=https%3A%2F%2F0.bridge.walletconnect.org&c3a898e05817b4af9a40d5f15e806984e30b04d84e770275a6cb4ad17859da1d&algorand=true"
        let isValidSession = sessionValidator.isValidSession(sessionInvalidURL)
        XCTAssertFalse(isValidSession)
    }
}
