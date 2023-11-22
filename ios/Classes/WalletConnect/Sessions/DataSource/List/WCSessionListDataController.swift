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

//   WCSessionListDataController.swift

import UIKit

protocol WCSessionListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<WCSessionListSection, WCSessionListItem>

    var eventHandler: ((WCSessionListDataControllerEvent) -> Void)? { get set }

    var shouldShowDisconnectAllAction: Bool { get }

    func load()

    func disconnectAllSessions(_ snapshot: Snapshot)

    subscript(sessionForTopic: WalletConnectTopic) -> WCSessionListItem? { get }
}

enum WCSessionListSection:
    Hashable {
    case empty
    case sessions
}

enum WCSessionListItem: Hashable {
    case empty
    case session(WCSessionListItemContainer)
}

extension WCSessionListItem {
    var session: WCSessionDraft? {
        if case .session(let item) = self {
            return item.session
        }

        return nil
    }
}

enum WCSessionListDataControllerEvent {
    case didUpdate(WCSessionListDataController.Snapshot)
    case didStartDisconnectingFromSessions
    case didDisconnectFromSessions
    case didFailDisconnectingFromSession
    
    var snapshot: WCSessionListDataController.Snapshot? {
        switch self {
        case .didUpdate(let snapshot): return snapshot
        default: return nil
        }
    }
}

struct WCSessionListItemContainer:
    Hashable {
    let session: WCSessionDraft
    let viewModel: WCSessionItemViewModel

    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(session)
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.session == rhs.session
    }
}
