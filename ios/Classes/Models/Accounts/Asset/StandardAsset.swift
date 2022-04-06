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

//   StandardAsset.swift

import Foundation

final class StandardAsset: Asset {
    let id: AssetID
    let amount: UInt64
    let isFrozen: Bool?
    let isDeleted: Bool?
    let name: String?
    let unitName: String?
    let decimals: Int
    let usdValue: Decimal?
    let isVerified: Bool
    let creator: AssetCreator?
    let url: String?

    var state: AssetState = .ready

    var presentation: AssetPresentation {
        return AssetPresentation(
            id: id,
            decimals: decimals,
            name: name,
            unitName: unitName,
            isVerified: isVerified,
            url: url
        )
    }

    var amountWithFraction: Decimal {
        return amount.assetAmount(fromFraction: decimals)
    }

    var amountDisplayWithFraction: String? {
        return amountWithFraction.toExactFractionLabel(fraction: decimals)
    }

    var amountNumberWithAutoFraction: String? {
        return amountWithFraction.toNumberStringWithSeparatorForLabel(fraction: decimals)
    }

    init(
        asset: ALGAsset,
        decoration: AssetDecoration
    ) {
        self.id = asset.id
        self.amount = asset.amount
        self.isFrozen = asset.isFrozen
        self.isDeleted = asset.isDeleted
        self.name = decoration.name
        self.unitName = decoration.unitName
        self.decimals = decoration.decimals
        self.usdValue = decoration.usdValue
        self.isVerified = decoration.isVerified
        self.creator = decoration.creator
        self.url = decoration.url
    }
}

extension StandardAsset {
    var assetNameRepresentation: String {
        if let name = name,
           !name.isEmptyOrBlank {
            return name
        }

        return "title-unknown".localized
    }

    var unitNameRepresentation: String {
        if let code = unitName,
            !code.isEmptyOrBlank {
            return code.uppercased()
        }

        return "title-unknown".localized
    }

    var hasDisplayName: Bool {
        return !name.isNilOrEmpty || !unitName.isNilOrEmpty
    }
}

extension StandardAsset: Comparable {
    static func == (lhs: StandardAsset, rhs: StandardAsset) -> Bool {
        return lhs.id == rhs.id &&
            lhs.amount == rhs.amount &&
            lhs.isFrozen == rhs.isFrozen &&
            lhs.isDeleted == rhs.isDeleted &&
            lhs.name == rhs.name &&
            lhs.unitName == rhs.unitName &&
            lhs.decimals == rhs.decimals &&
            lhs.usdValue == rhs.usdValue &&
            lhs.isVerified == rhs.isVerified
    }

    static func < (lhs: StandardAsset, rhs: StandardAsset) -> Bool {
        return lhs.id < rhs.id
    }
}

extension StandardAsset: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}
