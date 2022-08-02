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
//  AssetDecoration.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AssetDecoration: ALGEntityModel {
    let id: Int64
    let name: String?
    let unitName: String?
    let decimals: Int
    let usdValue: Decimal?
    let total: Int64?
    let isVerified: Bool
    let creator: AssetCreator?
    let collectible: Collectible?
    let explorerURL: URL?
    let url: String?

    var state: AssetState = .ready

    var isCollectible: Bool {
        return collectible != nil
    }

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.id = apiModel.assetId
        self.name = apiModel.name
        self.unitName = apiModel.unitName
        self.decimals = apiModel.fractionDecimals ?? 0
        self.usdValue = apiModel.usdValue.unwrap { Decimal(string: $0) }
        self.total = apiModel.total.unwrap { Int64($0) }
        self.isVerified = apiModel.isVerified ?? false
        self.creator = apiModel.creator.unwrap(AssetCreator.init)
        self.explorerURL = apiModel.explorerURL
        self.collectible = apiModel.collectible.unwrap(Collectible.init)
        self.url = apiModel.url
    }
    
    init(assetDetail: AssetDetail) {
        self.id = assetDetail.id
        self.name = assetDetail.assetName
        self.unitName = assetDetail.unitName
        self.decimals = assetDetail.fractionDecimals
        self.usdValue = nil
        self.total = nil
        self.isVerified = assetDetail.isVerified
        self.creator = AssetCreator(address: assetDetail.creator)
        self.explorerURL = nil
        self.collectible = nil
        self.url = assetDetail.url
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.assetId = id
        apiModel.name = name
        apiModel.unitName = unitName
        apiModel.fractionDecimals = decimals
        apiModel.usdValue = usdValue.unwrap { String(describing: $0) }
        apiModel.total = total.unwrap { String(describing: $0) }
        apiModel.isVerified = isVerified
        apiModel.creator = creator?.encode()
        apiModel.explorerURL = explorerURL
        apiModel.collectible = collectible?.encode()
        apiModel.url = url
        return apiModel
    }

    init(asset: Asset) {
        self.id = asset.id
        self.name = asset.presentation.name
        self.unitName = asset.presentation.unitName
        self.decimals = asset.presentation.decimals
        self.usdValue = nil
        self.total = nil
        self.isVerified = asset.presentation.isVerified
        self.creator = asset.creator
        self.explorerURL = nil
        self.collectible = nil
        self.url = asset.presentation.url
    }
}

extension AssetDecoration {
    struct APIModel: ALGAPIModel {
        var assetId: Int64
        var name: String?
        var unitName: String?
        var fractionDecimals: Int?
        var usdValue: String?
        var isVerified: Bool?
        var creator: AssetCreator.APIModel?
        var explorerURL: URL?
        var collectible: Collectible.APIModel?
        var url: String?
        var total: String?

        init() {
            self.assetId = 0
            self.name = nil
            self.unitName = nil
            self.fractionDecimals = nil
            self.usdValue = nil
            self.isVerified = nil
            self.creator = nil
            self.explorerURL = nil
            self.collectible = nil
            self.url = nil
            self.total = nil
        }

        private enum CodingKeys: String, CodingKey {
            case assetId = "asset_id"
            case name
            case unitName = "unit_name"
            case fractionDecimals = "fraction_decimals"
            case usdValue = "usd_value"
            case isVerified = "is_verified"
            case creator
            case explorerURL = "explorer_url"
            case collectible
            case url
            case total
        }
    }
}

extension AssetDecoration {
    var displayNames: (primaryName: String, secondaryName: String) {
        if let name = name, !name.isEmptyOrBlank,
            let code = unitName, !code.isEmptyOrBlank {
            return (name, "\(code.uppercased())")
        } else if let name = name, !name.isEmptyOrBlank {
            return (name, "title-unknown".localized)
        } else if let code = unitName, !code.isEmptyOrBlank {
            return ("\(code.uppercased())", "title-unknown".localized)
        } else {
            return ("title-unknown".localized, "title-unknown".localized)
        }
    }
}

extension AssetDecoration: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}

extension AssetDecoration: Comparable {
    static func == (lhs: AssetDecoration, rhs: AssetDecoration) -> Bool {
        return lhs.id == rhs.id &&
            lhs.decimals == rhs.decimals &&
            lhs.isVerified == rhs.isVerified &&
            lhs.name == rhs.name &&
            lhs.unitName == rhs.unitName
    }

    static func < (lhs: AssetDecoration, rhs: AssetDecoration) -> Bool {
        return lhs.id < rhs.id
    }
}

/// <todo>
/// Rethink the paginated list model. Should be more reusable.
final class AssetDecorationList:
    PaginatedList<AssetDecoration>,
    ALGEntityModel {
    convenience init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.init(
            pagination: apiModel,
            results: apiModel.results.unwrapMap(AssetDecoration.init)
        )
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.count = count
        apiModel.next = next
        apiModel.previous = previous
        apiModel.results = results.map { $0.encode() }
        return apiModel
    }
}

extension AssetDecorationList {
    struct APIModel:
        ALGAPIModel,
        PaginationComponents {
        var count: Int?
        var next: URL?
        var previous: String?
        var results: [AssetDecoration.APIModel]?

        init() {
            self.count = nil
            self.next = nil
            self.previous = nil
            self.results = []
        }
    }
}

typealias AssetID = Int64

extension AssetID {
    var stringWithHashtag: String {
        "#".appending(String(self))
    }
}
