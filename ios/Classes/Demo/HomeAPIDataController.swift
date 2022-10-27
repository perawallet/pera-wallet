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
//   AccountsPortfolioAPIDataController.swift

import Foundation

final class HomeAPIDataController:
    HomeDataController,
    SharedDataControllerObserver {

    var eventHandler: ((HomeDataControllerEvent) -> Void)?

    private lazy var currencyFormatter = CurrencyFormatter()

    private let sharedDataController: SharedDataController
    private let announcementDataController: AnnouncementAPIDataController
    
    private var visibleAnnouncement: Announcement?

    private var lastSnapshot: Snapshot?
    
    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.homeDataController")
    
    init(
        _ sharedDataController: SharedDataController,
        announcementDataController: AnnouncementAPIDataController
    ) {
        self.sharedDataController = sharedDataController
        self.announcementDataController = announcementDataController
    }
    
    deinit {
        sharedDataController.remove(self)
    }

    subscript (address: String?) -> AccountHandle? {
        return address.unwrap {
            sharedDataController.accountCollection[$0]
        }
    }
}

extension HomeAPIDataController {
    func load() {
        sharedDataController.add(self)
        announcementDataController.delegate = self
    }
    
    func reload() {
        deliverContentUpdates()
    }
    
    func fetchAnnouncements() {
        announcementDataController.loadData()
    }

    func hideAnnouncement() {
        defer {
            self.visibleAnnouncement = nil
            reload()
        }

        guard let visibleAnnouncement = self.visibleAnnouncement else {
            return
        }

        announcementDataController.hideAnnouncement(visibleAnnouncement)
    }

    func removeAccount(_ account: Account) {
        sharedDataController.resetPollingAfterRemoving(account)
        reload()
    }
}

extension HomeAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didBecomeIdle:
            deliverInitialUpdates()
        case .didStartRunning(let isFirst):
            if isFirst || lastSnapshot == nil {
                deliverInitialUpdates()
            }
        case .didFinishRunning:
            deliverContentUpdates()
        }
    }
}

extension HomeAPIDataController {
    private func deliverInitialUpdates() {
        if sharedDataController.isPollingAvailable {
            deliverLoadingUpdates()
        } else {
            deliverNoContentUpdates()
        }
    }
    
    private func deliverLoadingUpdates() {
        deliverUpdates {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty(.loading)],
                toSection: .empty
            )
            return (nil as TotalPortfolioItem?, snapshot)
        }
    }
    
    private func deliverContentUpdates() {
        if sharedDataController.accountCollection.isEmpty {
            deliverNoContentUpdates()
            return
        }
        
        deliverUpdates {
            [weak self] in
            guard let self = self else { return nil }
            
            var accounts: [AccountHandle] = []
            var accountItems: [HomeItemIdentifier] = []

            let currency = self.sharedDataController.currency
            let currencyFormatter = self.currencyFormatter
            
            self.sharedDataController.sortedAccounts().forEach {
                let accountPortfolioItem = AccountPortfolioItem(
                    accountValue: $0,
                    currency: currency,
                    currencyFormatter: currencyFormatter
                )
                let accountPreviewViewModel = AccountPreviewViewModel(accountPortfolioItem)
                let cellItem: HomeAccountItemIdentifier = .cell(accountPreviewViewModel)
                let item: HomeItemIdentifier = .account(cellItem)

                accounts.append($0)
                accountItems.append(item)
            }
            
            var snapshot = Snapshot()
            
            snapshot.appendSections([.portfolio])

            let nonWatchAccounts = accounts.filter { !$0.value.isWatchAccount() }
            let totalPortfolioItem = TotalPortfolioItem(
                accountValues: nonWatchAccounts,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
            let totalPortfolioViewModel = HomePortfolioViewModel(totalPortfolioItem)

            snapshot.appendItems(
                [.portfolio(.portfolio(totalPortfolioViewModel))],
                toSection: .portfolio
            )

            /// note: If accounts empty which means there is no any authenticated account, quick actions will be hidden
            if !accounts.isEmpty {
                snapshot.appendItems(
                    [.portfolio(.quickActions)],
                    toSection: .portfolio
                )
            }

            if let visibleAnnouncement = self.visibleAnnouncement {
                snapshot.appendSections([.announcement])

                let announcementItem = AnnouncementViewModel(visibleAnnouncement)
                snapshot.appendItems([.announcement(announcementItem)], toSection: .announcement)
            }
            
            if !accounts.isEmpty {
                let headerItem: HomeAccountItemIdentifier =
                    .header(ManagementItemViewModel(.account))
                accountItems.insert(
                    .account(headerItem),
                    at: 0
                )
                
                snapshot.appendSections([.accounts])
                snapshot.appendItems(
                    accountItems,
                    toSection: .accounts
                )
            }

            return (totalPortfolioItem, snapshot)
        }
    }
    
    private func deliverNoContentUpdates() {
        deliverUpdates {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty(.noContent)],
                toSection: .empty
            )
            return (nil as TotalPortfolioItem?, snapshot)
        }
    }
    
    private func deliverUpdates(
        _ updates: @escaping () -> Updates?
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else { return }

            guard let updates = updates() else {
                return
            }

            self.publish(.didUpdate(updates))
        }
    }
}

extension HomeAPIDataController {
    private func publish(
        _ event: HomeDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }
            
            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}

extension HomeAPIDataController: AnnouncementAPIDataControllerDelegate {
    func announcementAPIDataController(_ dataController: AnnouncementAPIDataController, didFetch announcement: Announcement) {
        self.visibleAnnouncement = announcement
    }
}
