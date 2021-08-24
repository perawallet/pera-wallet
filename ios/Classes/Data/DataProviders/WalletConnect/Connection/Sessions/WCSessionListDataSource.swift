// Copyright 2019 Algorand, Inc.

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
//   WCSessionListDataSource.swift

import UIKit

class WCSessionListDataSource: NSObject {

    weak var delegate: WCSessionListDataSourceDelegate?

    private let walletConnector: WalletConnector

    private var sessions: [WCSession]

    init(walletConnector: WalletConnector) {
        self.walletConnector = walletConnector
        self.sessions = walletConnector.allWalletConnectSessions
        super.init()
    }
}

extension WCSessionListDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sessions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WCSessionItemCell.reusableIdentifier,
            for: indexPath
        ) as? WCSessionItemCell else {
            fatalError("Unexpected cell type")
        }

        if let session = sessions[safe: indexPath.item] {
            cell.bind(WCSessionItemViewModel(session: session))
        }

        cell.delegate = self
        return cell
    }
}

extension WCSessionListDataSource {
    func session(at index: Int) -> WCSession? {
        return sessions[safe: index]
    }

    func index(of wcSession: WCSession) -> Int? {
        return sessions.firstIndex { $0.urlMeta.topic == wcSession.urlMeta.topic }
    }

    func disconnectFromSession(_ session: WCSession) {
        walletConnector.disconnectFromSession(session)
    }

    var isEmpty: Bool {
        return sessions.isEmpty
    }

    func updateSessions(_ updatedSessions: [WCSession]) {
        sessions = updatedSessions
    }
}

extension WCSessionListDataSource: WCSessionItemCellDelegate {
    func wcSessionItemCellDidOpenDisconnectionMenu(_ wcSessionItemCell: WCSessionItemCell) {
        delegate?.wSessionListDataSource(self, didOpenDisconnectMenuFrom: wcSessionItemCell)
    }
}

protocol WCSessionListDataSourceDelegate: AnyObject {
    func wSessionListDataSource(_ wSessionListDataSource: WCSessionListDataSource, didOpenDisconnectMenuFrom cell: WCSessionItemCell)
}
