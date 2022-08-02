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

//   DeeplinkQR.swift

import Foundation

struct DeeplinkQR {
    let url: URL

    func qrText() -> QRText? {
        let deeplinkConfig = ALGAppTarget.current.deeplinkConfig
        let universalLinkConfig = ALGAppTarget.current.universalLinkConfig

        guard let scheme = url.scheme else {
            return nil
        }

        if deeplinkConfig.qr.canAcceptScheme(scheme) {
            return generateQRTextFromDeepLink()
        } else if universalLinkConfig.canAcceptQR(url) {
            return generateQRTextFromUniversalLink()
        }

        return nil
    }

    func walletConnectUrl() -> URL? {
        let deeplinkConfig = ALGAppTarget.current.deeplinkConfig
        let universalLinkConfig = ALGAppTarget.current.universalLinkConfig

        guard let scheme = url.scheme, url.host != nil else {
            return nil
        }

        if deeplinkConfig.walletConnect.canAcceptScheme(scheme) || universalLinkConfig.canAcceptWalletConnect(url) {
            return url
        }

        return nil
    }

    private func generateQRTextFromUniversalLink() -> QRText? {
        let address = url.pathComponents.last
        let queryParams = url.queryParameters

        return QRText.build(for: address, with: queryParams)
    }

    private func generateQRTextFromDeepLink() -> QRText? {
        let address = url.host
        let queryParams = url.queryParameters

        return QRText.build(for: address, with: queryParams)
    }
}
