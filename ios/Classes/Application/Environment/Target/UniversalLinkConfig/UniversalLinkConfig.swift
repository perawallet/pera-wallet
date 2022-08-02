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

//   UniversalLinkConfig.swift

import Foundation

protocol UniversalLinkConfig: AnyObject {
    var qr: UniversalLinkGroupConfig { get }
    var walletConnect: UniversalLinkGroupConfig { get }
    var url: URL { get }
}

extension UniversalLinkConfig {
    func canAccept(
        _ aUrl: URL
    ) -> Bool {
        return canAcceptQR(aUrl) || canAcceptWalletConnect(aUrl)
    }

    func canAcceptQR(
        _ aUrl: URL
    ) -> Bool {
        containsAcceptedPaths(qr.acceptedPaths, on: aUrl)
    }

    func canAcceptWalletConnect(
        _ aUrl: URL
    ) -> Bool {
        containsAcceptedPaths(walletConnect.acceptedPaths, on: aUrl)
    }

    private func containsAcceptedPaths(_ paths: [String], on aUrl: URL) -> Bool {
        let absoluteURLStrings = paths.map { path in
            url.absoluteString + path
        }

        let aURLAbsoluteString = aUrl.absoluteString

        for absoluteURLString in absoluteURLStrings {
            if aURLAbsoluteString.hasPrefix(absoluteURLString) {
                continue
            }

            return false
        }

        return true
    }
}

protocol UniversalLinkGroupConfig: AnyObject {
    var acceptedPaths: [String] { get }
}
