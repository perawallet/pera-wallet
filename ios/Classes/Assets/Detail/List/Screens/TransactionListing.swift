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
//   TransactionListing.swift

import MacaroonUIKit
import UIKit

/// <todo>
/// Get rid of this object.
protocol TransactionListing {
    var type: TransactionTypeFilter { get }
    var accountHandle: AccountHandle { get set }
    var asset: Asset? { get }
}

extension TransactionListing {
    var asset: Asset? {
        return nil
    }
}

struct AlgoTransactionListing: TransactionListing {
    var type: TransactionTypeFilter {
        return .algos
    }
    var asset: Asset? {
        return accountHandle.value.algo
    }

    var accountHandle: AccountHandle
}

struct AssetTransactionListing: TransactionListing {
    var type: TransactionTypeFilter {
        return .asset
    }

    var accountHandle: AccountHandle
    var asset: Asset?
}

struct AccountTransactionListing: TransactionListing {
    var type: TransactionTypeFilter {
        return .all
    }

    var accountHandle: AccountHandle
}

enum TransactionTypeFilter {
    case algos
    case asset
    case all

    var currentTransactionType: TransactionType? {
        switch self {
        case .algos:
            return .payment
        case .asset:
            return .assetTransfer
        case .all:
            return nil
        }
    }
}
