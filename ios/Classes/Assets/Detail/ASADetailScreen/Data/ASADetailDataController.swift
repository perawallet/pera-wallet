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

//   ASADetailDataController.swift

import Foundation
import MagpieCore
import MagpieHipo

protocol ASADetailScreenDataController: AnyObject {
    typealias EventHandler = (ASADetailScreenDataControllerEvent) -> Void
    typealias Error = HIPNetworkError<NoAPIModel>

    var eventHandler: EventHandler? { get set }
    var configuration: ASADetailScreenConfiguration { get }

    var account: Account { get }
    var asset: Asset { get }

    func loadData()
}

enum ASADetailScreenDataControllerEvent {
    case willLoadData
    case didLoadData
    case didFailToLoadData(ASADiscoveryScreenDataController.Error)
    case didUpdateAccount(old: Account)
}

struct ASADetailScreenConfiguration {
    let shouldDisplayAccountActionsBarButtonItem: Bool
    let shouldDisplayQuickActions: Bool
}
