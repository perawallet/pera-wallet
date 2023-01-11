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

    private let walletConnector: WalletConnector

    private var sessions: [WCSession]

    init(walletConnector: WalletConnector) {
        self.walletConnector = walletConnector
        self.sessions = walletConnector.allWalletConnectSessions
        super.init()
    }
}

extension WCSessionShortListDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sessions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(WCSessionShortListItemCell.self, at: indexPath)

        if let session = sessions[safe: indexPath.item] {
            cell.bindData(WCSessionShortListItemViewModel(session))
        }

        cell.delegate = self
        return cell
    }
}

extension WCSessionShortListDataSource {
    func session(at index: Int) -> WCSession? {
        return sessions[safe: index]
    }

    func disconnectFromSession(_ session: WCSession) {
        walletConnector.disconnectFromSession(session)
    }

    func updateSessions(_ updatedSessions: [WCSession]) {
        sessions = updatedSessions
    }
}

extension WCSessionShortListDataSource: WCSessionShortListItemCellDelegate {
    func wcSessionShortListItemCellDidOpenDisconnectionMenu(_ wcSessionShortListItemCell: WCSessionShortListItemCell) {
        delegate?.wcSessionShortListDataSource(self, didOpenDisconnectMenuFrom: wcSessionShortListItemCell)
    }
}

protocol WCSessionShortListDataSourceDelegate: AnyObject {
    func wcSessionShortListDataSource(_ wcSessionShortListDataSource: WCSessionShortListDataSource, didOpenDisconnectMenuFrom cell: WCSessionShortListItemCell)
}
