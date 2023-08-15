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
//  AssetDetail.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AssetDetailResponse: ALGEntityModel {
    let assetDetail: AssetDetail
    let currentRound: UInt64

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.assetDetail = apiModel.asset.unwrap(AssetDetail.init) ?? AssetDetail()
        self.currentRound = apiModel.currentRound ?? 0
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.asset = assetDetail.encode()
        apiModel.currentRound = currentRound
        return apiModel
    }
}

extension AssetDetailResponse {
    struct APIModel: ALGAPIModel {
        var asset: AssetDetail.APIModel?
        var currentRound: UInt64?

        init() {
            self.asset = nil
            self.currentRound = nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case asset
        case currentRound = "current-round"
    }
}

final class AssetDetail: ALGEntityModel {
    let id: Int64
    let creator: String
    let total: UInt64?
    let isDefaultFrozen: Bool?
    let unitName: String?
    let assetName: String?
    let url: String?
    let managerKey: String?
    let reserveAddress: String?
    let freezeAddress: String?
    let clawBackAddress: String?
    let fractionDecimals: Int
    
    var isVerified: Bool = false

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.id = apiModel.index ?? -1
        self.creator = apiModel.params?.creator ?? ""
        self.total = apiModel.params?.total
        self.isDefaultFrozen = apiModel.params?.defaultFrozen
        self.unitName = apiModel.params?.unitName ?? apiModel.params?.unitNameBase64?.utf8String
        self.assetName = apiModel.params?.name ?? apiModel.params?.nameBase64?.utf8String
        self.url = apiModel.params?.url
        self.managerKey = apiModel.params?.manager
        self.reserveAddress = apiModel.params?.reserve
        self.freezeAddress = apiModel.params?.freeze
        self.clawBackAddress = apiModel.params?.clawback
        self.fractionDecimals = apiModel.params?.decimals ?? 0
    }
    
    init(assetDecoration: AssetDecoration) {
        self.id = assetDecoration.id
        self.assetName = assetDecoration.name
        self.unitName = assetDecoration.unitName
        self.isVerified = assetDecoration.verificationTier.isVerified
        self.fractionDecimals = assetDecoration.decimals
        self.total = 0
        self.creator = assetDecoration.creator?.address ?? ""
        isDefaultFrozen = nil
        url = nil
        managerKey = nil
        reserveAddress = nil
        freezeAddress = nil
        clawBackAddress = nil
    }

    func encode() -> APIModel {
        var params = APIModel.Params()
        params.creator = creator
        params.total = total
        params.defaultFrozen = isDefaultFrozen
        params.unitName = unitName
        params.name = assetName
        params.url = url
        params.manager = managerKey
        params.reserve = reserveAddress
        params.freeze = freezeAddress
        params.clawback = clawBackAddress
        params.decimals = fractionDecimals

        var apiModel = APIModel()
        apiModel.index = id
        apiModel.params = params
        return apiModel
    }
}

extension AssetDetail {
    func getDisplayNames() -> (String, String?) {
        if let name = assetName, !name.isEmptyOrBlank,
           let code = unitName, !code.isEmptyOrBlank {
            return (name, "\(code.uppercased())")
        } else if let name = assetName, !name.isEmptyOrBlank {
            return (name, nil)
        } else if let code = unitName, !code.isEmptyOrBlank {
            return ("\(code.uppercased())", nil)
        } else {
            return ("title-unknown".localized, nil)
        }
    }
    
    func hasOnlyAssetName() -> Bool {
        return !assetName.isNilOrEmpty && unitName.isNilOrEmpty
    }
    
    func hasOnlyUnitName() -> Bool {
        return assetName.isNilOrEmpty && !unitName.isNilOrEmpty
    }
    
    func hasBothDisplayName() -> Bool {
        return !assetName.isNilOrEmpty && !unitName.isNilOrEmpty
    }
    
    func hasDisplayName() -> Bool {
        return !assetName.isNilOrEmpty || !unitName.isNilOrEmpty
    }
    
    func hasNoDisplayName() -> Bool {
        return assetName.isNilOrEmpty && unitName.isNilOrEmpty
    }
    
    func getAssetName() -> String {
        if let name = assetName, !name.isEmptyOrBlank {
            return name
        }
        return "title-unknown".localized
    }
    
    func getAssetCode() -> String {
        if let code = unitName, !code.isEmptyOrBlank {
            return code.uppercased()
        }
        return "title-unknown".localized
    }
}

extension AssetDetail: Comparable {
    static func == (lhs: AssetDetail, rhs: AssetDetail) -> Bool {
        let lhsId = lhs.id
        let rhsId = rhs.id
        
        if lhsId == rhsId && lhs.fractionDecimals != rhs.fractionDecimals {
            return false
        }
        
        if lhsId == rhsId && lhs.isVerified != rhs.isVerified {
            return false
        }
        
        if lhsId == rhsId && lhs.assetName != rhs.assetName {
            return false
        } else if lhsId == rhsId && lhs.unitName != rhs.unitName {
            return false
        } else {
            return lhsId == rhsId
        }
    }
    
    static func < (lhs: AssetDetail, rhs: AssetDetail) -> Bool {
        return lhs.id < rhs.id
    }
}

extension AssetDetail: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}

extension AssetDetail {
    struct APIModel: ALGAPIModel {
        var index: Int64?
        var params: Params?

        init() {
            self.index = nil
            self.params = nil
        }
    }
}

extension AssetDetail.APIModel {
    struct Params: ALGAPIModel {
        var creator: String?
        var total: UInt64?
        var defaultFrozen: Bool?
        var unitName: String?
        var unitNameBase64: Data?
        var name: String?
        var nameBase64: Data?
        var url: String?
        var manager: String?
        var reserve: String?
        var freeze: String?
        var clawback: String?
        var decimals: Int?

        init() {
            self.creator = nil
            self.total = nil
            self.defaultFrozen = nil
            self.unitName = nil
            self.unitNameBase64 = nil
            self.name = nil
            self.nameBase64 = nil
            self.url = nil
            self.manager = nil
            self.reserve = nil
            self.freeze = nil
            self.clawback = nil
            self.decimals = nil
        }

        private enum CodingKeys: String, CodingKey {
            case creator
            case total
            case defaultFrozen = "default-frozen"
            case unitName = "unit-name"
            case unitNameBase64 = "unit-name-b64"
            case name
            case nameBase64 = "name-b64"
            case url
            case manager
            case reserve
            case freeze
            case clawback
            case decimals
        }
    }
}
