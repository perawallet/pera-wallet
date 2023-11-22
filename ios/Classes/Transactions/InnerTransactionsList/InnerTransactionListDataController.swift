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

//   InnerTransactionListDataController.swift

import UIKit

protocol InnerTransactionListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<InnerTransactionListSection, InnerTransactionListItem>

    var eventHandler: ((InnerTransactionListDataControllerEvent) -> Void)? { get set }

    var currencyFormatter: CurrencyFormatter { get }

    func load()

    var draft: InnerTransactionListDraft { get }
}

enum InnerTransactionListSection:
    Hashable {
    case transactions
}

enum InnerTransactionListItem: Hashable {
    case header(InnerTransactionListHeaderViewModel)
    case algoTransaction(
        InnerTransactionContainer<AlgoInnerTransactionPreviewViewModel>
    )
    case assetTransaction(
        InnerTransactionContainer<AssetInnerTransactionPreviewViewModel>
    )
    case assetConfigTransaction(
        InnerTransactionContainer<AssetConfigInnerTransactionPreviewViewModel>
    )
    case appCallTransaction(
        InnerTransactionContainer<AppCallInnerTransactionPreviewViewModel>
    )
    case keyRegTransaction(
        InnerTransactionContainer<KeyRegInnerTransactionPreviewViewModel>
    )
}

enum InnerTransactionListDataControllerEvent {
    case didUpdate(InnerTransactionListDataController.Snapshot)

    var snapshot: InnerTransactionListDataController.Snapshot {
        switch self {
        case .didUpdate(let snapshot):
            return snapshot
        }
    }
}

struct InnerTransactionContainer<T: InnerTransactionPreviewViewModel>:
    Identifiable,
    Hashable {
    private(set) var id = UUID()

    let transaction: Transaction
    let viewModel: T

    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(id)
    }

    static func == (
        lhs: InnerTransactionContainer,
        rhs: InnerTransactionContainer
    ) -> Bool {
        return lhs.id == rhs.id
    }
}
