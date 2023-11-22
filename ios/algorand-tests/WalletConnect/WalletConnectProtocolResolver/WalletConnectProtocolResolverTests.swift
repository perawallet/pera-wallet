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

//   WalletConnectProtocolResolverTests.swift

import XCTest
@testable import pera_staging

final class WalletConnectProtocolResolverTests: XCTestCase {
    private let walletConnectProtocolResolver = ALGWalletConnectProtocolResolver(
        api: ALGAPI(session: MockSession()),
        analytics: MockALGAnalytics(),
        pushToken: ""
    )
    
    func test_getWalletConnectProtocol_fromSession_v1_success() {
        let text = "wc:87ae23c4-37d3-40c1-b72f-e00d510b5e66@1?bridge=https%3A%2F%2F0.bridge.walletconnect.org&key=c3a898e05817b4af9a40d5f15e806984e30b04d84e770275a6cb4ad17859da1d&algorand=true"
        let wcProtocol = walletConnectProtocolResolver.getWalletConnectProtocol(from: text)
        XCTAssertNotNil(wcProtocol)
    }
    
    func test_getWalletConnectProtocol_fromSession_v2_success() {
        let text =     "wc:12557c6675a1a439ea5ee69a6dfd08aa7ad737fef6b93ad538aedd0a42d6ddc0@2?relay-protocol=irn&symKey=a5321d9154e743657c9685c0c6aef3ae02a00ce98c9c1db3dbb3ab0aa09584e3"
        let wcProtocol = walletConnectProtocolResolver.getWalletConnectProtocol(from: text)
        XCTAssertNotNil(wcProtocol)
    }

    func test_getWalletConnectProtocol_fromSession_failure() {
        let text = "ww:87ae23c4-37d3-40c1-b72f-e00d510b5e66@1?bridge=https%3A%2F%2F0.bridge.walletconnect.org&key=c3a898e05817b4af9a40d5f15e806984e30b04d84e770275a6cb4ad17859da1d&algorand=true"
        let wcProtocol = walletConnectProtocolResolver.getWalletConnectProtocol(from: text)
        XCTAssertNil(wcProtocol)
    }
    
    func test_getWalletConnectProtocol_fromVersion_v1_success() {
        let wcProtocol = walletConnectProtocolResolver.getWalletConnectProtocol(from: .v1)
        XCTAssertTrue(wcProtocol is WalletConnectV1Protocol)
    }
    
    
    func test_getWalletConnectProtocol_fromVersion_v2_success() {
        let wcProtocol = walletConnectProtocolResolver.getWalletConnectProtocol(from: .v2)
        XCTAssertTrue(wcProtocol is WalletConnectV2Protocol)
    }
    
    func test_getWalletConnectProtocol_fromVersion_v1_failure() {
        let wcProtocol = walletConnectProtocolResolver.getWalletConnectProtocol(from: .v1)
        XCTAssertFalse(wcProtocol is WalletConnectV2Protocol)
    }

    func test_getWalletConnectProtocol_fromVersion_v2_failure() {
        let wcProtocol = walletConnectProtocolResolver.getWalletConnectProtocol(from: .v2)
        XCTAssertFalse(wcProtocol is WalletConnectV1Protocol)
    }
}
