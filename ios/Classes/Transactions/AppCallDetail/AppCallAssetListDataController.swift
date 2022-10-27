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

//   AppCallAssetListDataController.swift

import UIKit

protocol AppCallAssetListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<AppCallAssetListSection, AppCallAssetListItem>

    var eventHandler: ((AppCallAssetListDataControllerEvent) -> Void)? { get set }

    var assets: [Asset] { get }

    func load()
}

enum AppCallAssetListSection:
    Hashable {
    case assets
}

enum AppCallAssetListItem: Hashable {
    case cell(AppCallAssetListAssetPreviewWithImageContainer)
}

enum AppCallAssetListDataControllerEvent {
    case didUpdate(AppCallAssetListDataController.Snapshot)

    var snapshot: AppCallAssetListDataController.Snapshot {
        switch self {
        case .didUpdate(let snapshot):
            return snapshot
        }
    }
}

struct AppCallAssetListAssetPreviewWithImageContainer:
    Identifiable,
    Hashable {
    private(set) var id: UUID = UUID()

    let viewModel: AppCallAssetPreviewWithImageViewModel

    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(id)
    }

    static func == (
        lhs: AppCallAssetListAssetPreviewWithImageContainer,
        rhs: AppCallAssetListAssetPreviewWithImageContainer
    ) -> Bool {
        return lhs.id == rhs.id
    }
}
