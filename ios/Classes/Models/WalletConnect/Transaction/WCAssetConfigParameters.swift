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
//   WCAssetConfigParameters.swift

import Foundation
import MagpieCore

final class WCAssetConfigParameters: Codable {
    let totalSupply: UInt64?
    let decimal: Int?
    let isFrozen: Bool?
    let unitName: String?
    let name: String?
    let url: String?
    let metadataHash: Data?
    let managerAddress: String?
    let reserveAddress: String?
    let frozenAddress: String?
    let clawbackAddress: String?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalSupply = try container.decodeIfPresent(UInt64.self, forKey: .totalSupply)
        decimal = try container.decodeIfPresent(Int.self, forKey: .decimal)
        isFrozen = try container.decodeIfPresent(Bool.self, forKey: .isFrozen)
        unitName = try container.decodeIfPresent(String.self, forKey: .unitName)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        metadataHash = try container.decodeIfPresent(Data.self, forKey: .metadataHash)

        if let managerAddressMsgpack = try container.decodeIfPresent(Data.self, forKey: .managerAddress) {
            managerAddress = managerAddressMsgpack.getAlgorandAddressFromPublicKey()
        } else {
            managerAddress = nil
        }

        if let reserveAddressMsgpack = try container.decodeIfPresent(Data.self, forKey: .reserveAddress) {
            reserveAddress = reserveAddressMsgpack.getAlgorandAddressFromPublicKey()
        } else {
            reserveAddress = nil
        }

        if let frozenAddressMsgpack = try container.decodeIfPresent(Data.self, forKey: .frozenAddress) {
            frozenAddress = frozenAddressMsgpack.getAlgorandAddressFromPublicKey()
        } else {
            frozenAddress = nil
        }

        if let clawbackAddressMsgpack = try container.decodeIfPresent(Data.self, forKey: .clawbackAddress) {
            clawbackAddress = clawbackAddressMsgpack.getAlgorandAddressFromPublicKey()
        } else {
            clawbackAddress = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(totalSupply, forKey: .totalSupply)
        try container.encodeIfPresent(decimal, forKey: .decimal)
        try container.encodeIfPresent(isFrozen, forKey: .isFrozen)
        try container.encodeIfPresent(unitName, forKey: .unitName)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(metadataHash, forKey: .metadataHash)
        try container.encodeIfPresent(managerAddress, forKey: .managerAddress)
        try container.encodeIfPresent(reserveAddress, forKey: .reserveAddress)
        try container.encodeIfPresent(frozenAddress, forKey: .frozenAddress)
        try container.encodeIfPresent(clawbackAddress, forKey: .clawbackAddress)
    }
}

extension WCAssetConfigParameters {
    private enum CodingKeys: String, CodingKey {
        case totalSupply = "t"
        case decimal = "dc"
        case isFrozen = "df"
        case unitName = "un"
        case name = "an"
        case url = "au"
        case metadataHash = "am"
        case managerAddress = "m"
        case reserveAddress = "r"
        case frozenAddress = "f"
        case clawbackAddress = "c"
    }
}
