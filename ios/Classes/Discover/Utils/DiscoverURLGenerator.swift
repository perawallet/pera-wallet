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

//   DiscoverURLGenerator.swift

import Foundation
import UIKit

final class DiscoverURLGenerator {
    static func generateUrl(
        discoverUrl: DiscoverURL,
        theme: UIUserInterfaceStyle,
        session: Session?
    ) -> URL? {
        var queryItems: [URLQueryItem] = []
        queryItems.append(.init(name: "version", value: "2"))
        queryItems.append(.init(name: "theme", value: theme.peraRawValue))
        queryItems.append(.init(name: "platform", value: "ios"))
        queryItems.append(.init(name: "currency", value: session?.preferredCurrencyID.localValue))
        if #available(iOS 16, *) {
            queryItems.append(.init(name: "language", value: Locale.preferred.language.languageCode?.identifier))
        } else {
            queryItems.append(.init(name: "language", value: Locale.preferred.languageCode))
        }
        if #available(iOS 16, *) {
            queryItems.append(.init(name: "region", value: Locale.current.region?.identifier))
        } else {
            queryItems.append(.init(name: "region", value: Locale.current.regionCode))
        }

        guard var components = URLComponents(string: Environment.current.discoverBaseUrl) else {
            return nil
        }

        switch discoverUrl {
        case .other(let url):
            return url
        case .assetDetail(let parameters):
            if let poolID = parameters.poolID {
                queryItems.append(.init(name: "poolId", value: poolID))
            }
            components.path = "/token-detail/\(parameters.assetID)/"
        case .home:
            break
        }

        components.queryItems = queryItems

        return components.url
    }
}

enum DiscoverURL {
    case assetDetail(parameters: DiscoverAssetParameters)
    case other(url: URL)
    case home
}
