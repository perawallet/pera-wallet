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
//   AssetFetcher.swift

import Foundation
import MagpieCore

final class AssetFetcher: AssetFetching {
    private let api: ALGAPI
    private var assetInformationRequest: EndpointOperatable?

    var handlers = Handlers()

    init(
        api: ALGAPI
    ) {
        self.api = api
    }

    func getAssetsByIDs(
        _ ids: [AssetID]
    ) {
        assetInformationRequest = api.fetchAssetDetails(AssetFetchQuery(ids: ids), queue: .main, ignoreResponseOnCancelled: false) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .success(list):
                self.setAssetInformations(list.results)
                self.handlers.didFetchAssetInformations?(list.results)
            case let .failure(error, _):
                self.handlers.didFailFetchingAssetInformations?(error)
            }
        }
    }

    func cancelAssetInformationRequest() {
        assetInformationRequest?.cancel()
    }
}

extension AssetFetcher {
    private func setAssetInformations(
        _ assetInformations: [AssetInformation]
    ) {
        /// Store latest asset informations in memory with respect to the asset id.
        assetInformations.forEach { api.session.assetInformations[$0.id] = $0 }
    }
}

extension AssetFetcher {
    struct Handlers {
        var didFetchAssetInformations: (([AssetInformation]) -> Void)?
        var didFailFetchingAssetInformations: ((APIError) -> Void)?
    }
}

protocol AssetFetching {
    func getAssetsByIDs(
        _ ids: [AssetID]
    )
    func cancelAssetInformationRequest()
}
