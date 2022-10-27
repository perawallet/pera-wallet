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
//   AccountsPortfolioDataSource.swift

import Foundation
import UIKit

protocol HomeDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<HomeSectionIdentifier, HomeItemIdentifier>
    typealias Updates = (totalPortfolioItem: TotalPortfolioItem?, snapshot: Snapshot)
    
    var eventHandler: ((HomeDataControllerEvent) -> Void)? { get set }
    
    subscript (address: String?) -> AccountHandle? { get }
    
    func load()
    func reload()
    func fetchAnnouncements()
    func hideAnnouncement()

    func removeAccount(_ account: Account)
}

enum HomeSectionIdentifier:
    Int,
    Hashable {
    case empty
    case portfolio
    case announcement
    case accounts
}

enum HomeItemIdentifier: Hashable {
    case empty(HomeEmptyItemIdentifier)
    case portfolio(HomePortfolioItemIdentifier)
    case announcement(AnnouncementViewModel)
    case account(HomeAccountItemIdentifier)
}

enum HomeEmptyItemIdentifier: Hashable {
    case loading
    case noContent
}

enum HomePortfolioItemIdentifier: Hashable {
    case portfolio(HomePortfolioViewModel)
    case quickActions
}

enum HomeAccountItemIdentifier: Hashable {
    case header(ManagementItemViewModel)
    case cell(AccountPreviewViewModel)
}

enum HomeDataControllerEvent {
    case didUpdate(HomeDataController.Updates)
    
    var snapshot: HomeDataController.Snapshot {
        switch self {
        case .didUpdate(let updates): return updates.snapshot
        }
    }
}
