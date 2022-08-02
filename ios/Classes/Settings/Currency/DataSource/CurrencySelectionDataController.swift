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

//   CurrencySelectionDataController.swift

import Foundation
import UIKit

protocol CurrencySelectionDataController: AnyObject {
    typealias Updates = (snapshot: Snapshot, isLoading: Bool)
    typealias Snapshot = NSDiffableDataSourceSnapshot<CurrencySelectionSection, CurrencySelectionItem>

    var eventHandler: ((CurrencySelectionDataControllerEvent) -> Void)? { get set }

    var selectedCurrencyID: CurrencyID? { get }

    subscript (indexPath: IndexPath) -> RemoteCurrency? { get }
    
    func loadData()

    func search(
        for query: String
    )
    func resetSearch()

    func selectCurrency(
        at indexPath: IndexPath
    ) -> RemoteCurrency?
}

enum CurrencySelectionDataControllerEvent {
    case didUpdate(CurrencySelectionDataController.Updates)
}

enum CurrencySelectionSection:
    Int,
    Hashable {
    case currencies
    case empty
    case error
}

enum CurrencySelectionItem: Hashable {
    case currency(SingleSelectionViewModel)
    case empty(CurrencySelectionEmptyItem)
    case error
}

enum CurrencySelectionEmptyItem: Hashable {
    case noContent(CurrencySelectionNoContentViewModel)
    case loading
}
