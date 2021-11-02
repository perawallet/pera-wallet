// Copyright 2019 Algorand, Inc.

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

import Magpie

class AssetDetailResponse: Model {
    let assetDetail: AssetDetail
    let currentRound: UInt64
}

extension AssetDetailResponse {
    enum CodingKeys: String, CodingKey {
        case assetDetail = "asset"
        case currentRound = "current-round"
    }
}

class AssetDetail: Model {
    let creator: String
    let total: UInt64
    let isDefaultFrozen: Bool?
    let unitName: String?
    let assetName: String?
    let url: String?
    let managerKey: String?
    let reserveAddress: String?
    let freezeAddress: String?
    let clawBackAddress: String?
    let fractionDecimals: Int
    let id: Int64
    var isDeleted: Bool?
    
    var isVerified: Bool = false
    var isRemoved: Bool = false
    var isRecentlyAdded: Bool = false

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        let paramsContainer = try container.nestedContainer(keyedBy: ParamsCodingKeys.self, forKey: .params)
        
        creator = try paramsContainer.decode(String.self, forKey: .creator)
        total = try paramsContainer.decode(UInt64.self, forKey: .total)
        isDefaultFrozen = try paramsContainer.decodeIfPresent(Bool.self, forKey: .isDefaultFrozen)
        unitName = try paramsContainer.decodeIfPresent(String.self, forKey: .unitName)
        assetName = try paramsContainer.decodeIfPresent(String.self, forKey: .assetName)
        url = try paramsContainer.decodeIfPresent(String.self, forKey: .url)
        managerKey = try paramsContainer.decodeIfPresent(String.self, forKey: .managerKey)
        reserveAddress = try? paramsContainer.decodeIfPresent(String.self, forKey: .reserveAddress)
        freezeAddress = try? paramsContainer.decodeIfPresent(String.self, forKey: .freezeAddress)
        clawBackAddress = try paramsContainer.decodeIfPresent(String.self, forKey: .clawBackAddress)
        fractionDecimals = try paramsContainer.decodeIfPresent(Int.self, forKey: .fractionDecimals) ?? 0
        
        isVerified = try paramsContainer.decodeIfPresent(Bool.self, forKey: .isVerified) ?? false
        isRemoved = try paramsContainer.decodeIfPresent(Bool.self, forKey: .isRemoved) ?? false
        isRecentlyAdded = try paramsContainer.decodeIfPresent(Bool.self, forKey: .isRecentlyAdded) ?? false
        isDeleted = try paramsContainer.decodeIfPresent(Bool.self, forKey: .isDeleted)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        
        var paramsContainer = container.nestedContainer(keyedBy: ParamsCodingKeys.self, forKey: .params)
        try paramsContainer.encode(creator, forKey: .creator)
        try paramsContainer.encode(total, forKey: .total)
        try paramsContainer.encodeIfPresent(isDefaultFrozen, forKey: .isDefaultFrozen)
        try paramsContainer.encodeIfPresent(unitName, forKey: .unitName)
        try paramsContainer.encodeIfPresent(assetName, forKey: .assetName)
        try paramsContainer.encodeIfPresent(url, forKey: .url)
        try paramsContainer.encodeIfPresent(managerKey, forKey: .managerKey)
        try paramsContainer.encodeIfPresent(reserveAddress, forKey: .reserveAddress)
        try paramsContainer.encodeIfPresent(freezeAddress, forKey: .freezeAddress)
        try paramsContainer.encodeIfPresent(clawBackAddress, forKey: .clawBackAddress)
        try paramsContainer.encodeIfPresent(fractionDecimals, forKey: .fractionDecimals)
        try paramsContainer.encodeIfPresent(isVerified, forKey: .isVerified)
        try paramsContainer.encodeIfPresent(isRemoved, forKey: .isRemoved)
        try paramsContainer.encodeIfPresent(isRecentlyAdded, forKey: .isRecentlyAdded)
        try paramsContainer.encodeIfPresent(isDeleted, forKey: .isDeleted)
    }
    
    init(searchResult: AssetSearchResult) {
        self.id = searchResult.id
        self.assetName = searchResult.name
        self.unitName = searchResult.unitName
        self.isVerified = searchResult.isVerified
        
        self.fractionDecimals = 0
        self.total = 0
        self.creator = ""
        
        isDefaultFrozen = nil
        url = nil
        managerKey = nil
        reserveAddress = nil
        freezeAddress = nil
        clawBackAddress = nil
    }
}

extension AssetDetail {
    private enum CodingKeys: String, CodingKey {
        case id = "index"
        case params = "params"
    }
    
    private enum ParamsCodingKeys: String, CodingKey {
        case creator = "creator"
        case total = "total"
        case isDefaultFrozen = "default-frozen"
        case unitName = "unit-name"
        case assetName = "name"
        case url = "url"
        case managerKey = "manager"
        case reserveAddress = "reserve"
        case freezeAddress = "freeze"
        case clawBackAddress = "clawback"
        case id = "index"
        case isRemoved = "isRemoved"
        case isRecentlyAdded = "isRecentlyAdded"
        case isVerified = "is_verified"
        case fractionDecimals = "decimals"
        case isDeleted = "deleted"
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

extension AssetDetail: Encodable {
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
