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
//  NotificationsDataSource.swift

import UIKit
import Magpie

class NotificationsDataSource: NSObject {
    
    private let api: AlgorandAPI
    private var notifications = [NotificationMessage]()
    private var viewModels = [NotificationsViewModel]()
    private var contacts = [Contact]()
    private var lastRequest: EndpointOperatable?
    
    private let paginationRequestThreshold = 3
    private var paginationCursor: String?
    var hasNext: Bool {
        return paginationCursor != nil
    }
    
    weak var delegate: NotificationsDataSourceDelegate?

    init(api: AlgorandAPI) {
        self.api = api
        super.init()
        startObserving()
    }
}

extension NotificationsDataSource {
    func loadData(withRefresh refresh: Bool = true, isPaginated: Bool = false) {
        guard let deviceId = api.session.authenticatedUser?.deviceId else {
            delegate?.notificationsDataSourceDidFailToFetch(self)
            return
        }
        
        let latesTimestamp = api.session.notificationLatestFetchTimestamp
        lastRequest = api.getNotifications(for: deviceId, with: CursorQuery(cursor: paginationCursor)) { response in
            switch response {
            case let .success(notifications):
                if refresh {
                    self.viewModels.removeAll()
                    self.notifications.removeAll()
                    self.paginationCursor = nil
                }
                
                self.api.session.notificationLatestFetchTimestamp = Date().timeIntervalSince1970
                self.paginationCursor = notifications.parsePaginationCursor()
                
                if isPaginated {
                    self.notifications.append(contentsOf: notifications.results)
                } else {
                    self.notifications = notifications.results
                }
                
                var viewModels = [NotificationsViewModel]()
                notifications.results.forEach { notification in
                    viewModels.append(self.formViewModel(from: notification, latesTimestamp: latesTimestamp))
                }
                self.viewModels = viewModels
                
                self.delegate?.notificationsDataSourceDidFetchNotifications(self)
            case .failure:
                self.delegate?.notificationsDataSourceDidFailToFetch(self)
            }
        }
    }
}

extension NotificationsDataSource {
    func fetchContacts() {
        Contact.fetchAll(entity: Contact.entityName) { response in
            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Contact] else {
                    return
                }
                
                self.contacts = results
            default:
                break
            }
        }
    }
}

extension NotificationsDataSource {
    private func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didDeviceIDSet(notification:)),
            name: .DeviceIDDidSet,
            object: nil
        )
    }
    
    @objc
    private func didDeviceIDSet(notification: Notification) {
        if lastRequest == nil {
            loadData()
        }
    }
}

extension NotificationsDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < notifications.count {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NotificationCell.reusableIdentifier,
                for: indexPath
            ) as? NotificationCell,
                let viewModel = viewModel(at: indexPath.item) {
                viewModel.configure(cell)
                return cell
            }
        }
        fatalError("Index path is out of bounds")
    }
    
    private func formViewModel(from notification: NotificationMessage, latesTimestamp: TimeInterval?) -> NotificationsViewModel {
        return NotificationsViewModel(
            notification: notification,
            senderAccount: getSenderAccountIfExists(for: notification),
            receiverAccount: getReceiverAccountIfExists(for: notification),
            contact: getContactIfExists(for: notification),
            latestReadTimestamp: latesTimestamp
        )
    }
    
    private func getSenderAccountIfExists(for notification: NotificationMessage) -> Account? {
        guard let details = notification.detail,
            let senderAddress = details.senderAddress else {
            return nil
        }
        
        return api.session.account(from: senderAddress)
    }
    
    private func getReceiverAccountIfExists(for notification: NotificationMessage) -> Account? {
        guard let details = notification.detail,
            let receiverAddress = details.receiverAddress else {
            return nil
        }
        
        return api.session.account(from: receiverAddress)
    }
    
    private func getContactIfExists(for notification: NotificationMessage) -> Contact? {
        guard let details = notification.detail else {
            return nil
        }
        
        return contacts.first { contact -> Bool in
            if let contactAddress = contact.address {
                return contactAddress == details.senderAddress || contactAddress == details.receiverAddress
            }
            return false
        }
    }
}

extension NotificationsDataSource {
    var isEmpty: Bool {
        return notifications.isEmpty
    }
    
    func notification(at index: Int) -> NotificationMessage? {
        return notifications[safe: index]
    }
    
    func viewModel(at index: Int) -> NotificationsViewModel? {
        return viewModels[safe: index]
    }
    
    func shouldSendPaginatedRequest(at index: Int) -> Bool {
        return index == notifications.count - paginationRequestThreshold && hasNext
    }
    
    func clear() {
        lastRequest?.cancel()
        lastRequest = nil
        viewModels.removeAll()
        notifications.removeAll()
        paginationCursor = nil
    }
    
    func getUserAccount(from notificationDetail: NotificationDetail) -> (account: Account?, assetDetail: AssetDetail?) {
        guard let account = api.session.accounts.first(where: { account -> Bool in
            account.address == notificationDetail.senderAddress || account.address == notificationDetail.receiverAddress
        }) else {
            return (account: nil, assetDetail: nil)
        }
        
        var assetDetail: AssetDetail?
        if let assetId = notificationDetail.asset?.id {
            assetDetail = account.assetDetails.first { $0.id == assetId }
        }
        return (account: account, assetDetail: assetDetail)
    }
}

protocol NotificationsDataSourceDelegate: AnyObject {
    func notificationsDataSourceDidFetchNotifications(_ notificationsDataSource: NotificationsDataSource)
    func notificationsDataSourceDidFailToFetch(_ notificationsDataSource: NotificationsDataSource)
}
