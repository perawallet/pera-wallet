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
    static func generateURL(
        destination: DiscoverDestination,
        theme: UIUserInterfaceStyle,
        session: Session?
    ) -> URL? {
        switch destination {
        case .home:
            return generateURLForHome(
                theme: theme,
                session: session
            )
        case .assetDetail(let params):
            return generateURLForAssetDetail(
                params: params,
                theme: theme,
                session: session
            )
        case .dappDetail(let params):
            return generateURLForDappDetail(
                params: params,
                theme: theme,
                session: session
            )
        case .generic(let params):
            return generateGenericURL(
                params: params,
                theme: theme,
                session: session
            )
        }
    }

    private static func generateURLForHome(
        theme: UIUserInterfaceStyle,
        session: Session?
    ) -> URL? {
        var components = URLComponents(string: Environment.current.discoverBaseUrl)
        components?.queryItems = makeInHouseQueryItems(
            theme: theme,
            session: session
        )
        return components?.url
    }

    private static func generateURLForAssetDetail(
        params: DiscoverAssetParameters,
        theme: UIUserInterfaceStyle,
        session: Session?
    ) -> URL? {
        var queryItems = makeInHouseQueryItems(
            theme: theme,
            session: session
        )
        if let poolID = params.poolID {
            queryItems.append(.init(name: "poolId", value: poolID))
        }

        var components = URLComponents(string: Environment.current.discoverBaseUrl)
        components?.path = "/token-detail/\(params.assetID)/"
        components?.queryItems = queryItems
        return components?.url
    }

    private static func generateURLForDappDetail(
        params: DiscoverDappParamaters,
        theme: UIUserInterfaceStyle,
        session: Session?
    ) -> URL? {
        return URL(string: params.url)
    }

    private static func generateGenericURL(
        params: DiscoverGenericParameters,
        theme: UIUserInterfaceStyle,
        session: Session?
    ) -> URL? {
        var components = URLComponents(url: params.url, resolvingAgainstBaseURL: false)

        let presentQueryItems = (components?.queryItems).someArray
        let additionalQueryItems = makeInHouseQueryItems(
            theme: theme,
            session: session
        )
        components?.queryItems = presentQueryItems + additionalQueryItems

        return components?.url
    }

    private static func makeInHouseQueryItems(
        theme: UIUserInterfaceStyle,
        session: Session?
    ) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        queryItems.append(.init(name: "version", value: "3"))
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
        return queryItems
    }
}

enum DiscoverDestination {
    case home
    case assetDetail(DiscoverAssetParameters)
    case dappDetail(DiscoverDappParamaters)
    case generic(DiscoverGenericParameters)
}
