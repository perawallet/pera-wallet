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

//   WalletConnectV2SessionValidatorTests.swift

import XCTest

@testable import pera_staging

final class WalletConnectV2SessionValidatorTests: XCTestCase {
    private let sessionValidator = WalletConnectV2SessionValidator()
    
    func test_isValidSession_valid() {
        let sessionURL = "wc:12557c6675a1a439ea5ee69a6dfd08aa7ad737fef6b93ad538aedd0a42d6ddc0@2?relay-protocol=irn&symKey=a5321d9154e743657c9685c0c6aef3ae02a00ce98c9c1db3dbb3ab0aa09584e3"
        let isValidSession = sessionValidator.isValidSession(sessionURL)
        XCTAssertTrue(isValidSession)
    }
    
    func test_isValidSession_invalid_prefix() {
        let sessionWrongPrefixURL = "ww:12557c6675a1a439ea5ee69a6dfd08aa7ad737fef6b93ad538aedd0a42d6ddc0@2?relay-protocol=irn&symKey=a5321d9154e743657c9685c0c6aef3ae02a00ce98c9c1db3dbb3ab0aa09584e3"
        let isValidSession = sessionValidator.isValidSession(sessionWrongPrefixURL)
        XCTAssertFalse(isValidSession)
    }
    
    func test_isValidSession_invalid_url() {
        let invalidSessionURL = "wc12557c6675a1a439ea5ee69a6dfd08aa7ad737fef6b93ad538aedd0a42d6ddc0@2relay-protocol=irnsymKey=a5321d9154e743657c9685c0c6aef3ae02a00ce98c9c1db3dbb3ab0aa09584e3"
        let isValidSession = sessionValidator.isValidSession(invalidSessionURL)
        XCTAssertFalse(isValidSession)
    }
    
    func test_isValidSession_invalid_missingRelayProtocol() {
        let sessionMissingRelayProtocolURL = "wc:12557c6675a1a439ea5ee69a6dfd08aa7ad737fef6b93ad538aedd0a42d6ddc0@2?symKey=a5321d9154e743657c9685c0c6aef3ae02a00ce98c9c1db3dbb3ab0aa09584e3"
        let isValidSession = sessionValidator.isValidSession(sessionMissingRelayProtocolURL)
        XCTAssertFalse(isValidSession)
    }
    
    func test_isValidSession_invalid_missingSymKey() {
        let sessionMissingSymKeyURL = "wc:12557c6675a1a439ea5ee69a6dfd08aa7ad737fef6b93ad538aedd0a42d6ddc0@2?relay-protocol=irn"
        let isValidSession = sessionValidator.isValidSession(sessionMissingSymKeyURL)
        XCTAssertFalse(isValidSession)
    }
}
