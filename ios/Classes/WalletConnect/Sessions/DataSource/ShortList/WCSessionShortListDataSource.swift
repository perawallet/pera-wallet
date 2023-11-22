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
//   WCSessionShortListDataSource.swift

import UIKit

final class WCSessionShortListDataSource: NSObject {
    weak var delegate: WCSessionShortListDataSourceDelegate?

    private let walletConnectCoordinator: WalletConnectCoordinator

    private var sessions: [WCSessionDraft]

    init(walletConnectCoordinator: WalletConnectCoordinator) {
        self.walletConnectCoordinator = walletConnectCoordinator
        self.sessions = Self.getSortedSessions(walletConnectCoordinator)

        super.init()
    }
}

extension WCSessionShortListDataSource {
    private static func getSortedSessions(_ walletConnectCoordinator: WalletConnectCoordinator) -> [WCSessionDraft] {
        func getConnectionDate(session: WCSessionDraft) -> Date? {
            if let wcV1SessionDate = session.wcV1Session?.date {
                return wcV1SessionDate
            } else if let wcV2SessionTopic = session.wcV2Session?.topic {
                return wcV2SessionConnectionDates[wcV2SessionTopic]
            }

            return nil
        }

        let sessions = walletConnectCoordinator.getSessions()
        let wcV2SessionConnectionDates =
            walletConnectCoordinator.walletConnectProtocolResolver.walletConnectV2Protocol.getConnectionDates()
        let sortedSessionsByDescendingConnectionDate = sessions.sorted { firstSession, secondSession in
            guard let firstConnectionDate = getConnectionDate(session: firstSession),
                  let secondConnectionDate = getConnectionDate(session: secondSession) else {
                return false
            }

            return firstConnectionDate > secondConnectionDate
        }
        return sortedSessionsByDescendingConnectionDate
    }
}

extension WCSessionShortListDataSource: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return sessions.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeue(WCSessionShortListItemCell.self, at: indexPath)

        if let session = sessions[safe: indexPath.item] {
            let viewModel = WCSessionShortListItemViewModel(session)
            cell.bindData(viewModel)
        }

        cell.delegate = self
        return cell
    }
}

extension WCSessionShortListDataSource {
    func session(at index: Int) -> WCSessionDraft? {
        return sessions[safe: index]
    }

    func session(for topic: WalletConnectTopic) -> WCSessionDraft? {
        return sessions.first(matching: (\.topic, topic))
    }

    func disconnectFromSession(_ session: WCSessionDraft) {
        if let wcV1Session = session.wcV1Session {
            let params = WalletConnectV1SessionDisconnectionParams(session: wcV1Session)
            walletConnectCoordinator.disconnectFromSession(params)
            return
        }

        if let wcV2Session = session.wcV2Session {
            let params = WalletConnectV2SessionDisconnectionParams(session: wcV2Session)
            walletConnectCoordinator.disconnectFromSession(params)
            return
        }
    }

    func updateSessions(_ updatedSessions: [WCSessionDraft]) {
        sessions = updatedSessions
    }
}

extension WCSessionShortListDataSource: WCSessionShortListItemCellDelegate {
    func wcSessionShortListItemCellDidOpenDisconnectionMenu(_ wcSessionShortListItemCell: WCSessionShortListItemCell) {
        delegate?.wcSessionShortListDataSource(self, didOpenDisconnectMenuFrom: wcSessionShortListItemCell)
    }
}

protocol WCSessionShortListDataSourceDelegate: AnyObject {
    func wcSessionShortListDataSource(
        _ wcSessionShortListDataSource: WCSessionShortListDataSource,
        didOpenDisconnectMenuFrom cell: WCSessionShortListItemCell
    )
}

fileprivate extension WCSessionDraft {
    var topic: WalletConnectTopic? {
        return wcV1Session?.urlMeta.topic ?? wcV2Session?.topic
    }
}
