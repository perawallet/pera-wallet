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

    private var lastSnapshot: Snapshot?
    
    private let sharedDataController: SharedDataController
    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.homeDataController")
    
    init(
        _ sharedDataController: SharedDataController
    ) {
        self.sharedDataController = sharedDataController
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
    }
    
    func reload() {
        deliverContentSnapshot()
    }
}

extension HomeAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didBecomeIdle:
            deliverInitialSnapshot()
        case .didStartRunning(let isFirst):
            if isFirst ||
               lastSnapshot == nil {
                deliverInitialSnapshot()
            }
        case .didFinishRunning:
            deliverContentSnapshot()
        }
    }
}

extension HomeAPIDataController {
    private func deliverInitialSnapshot() {
        if sharedDataController.isPollingAvailable {
            deliverLoadingSnapshot()
        } else {
            deliverNoContentSnapshot()
        }
    }
    
    private func deliverLoadingSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.loading])
            snapshot.appendItems(
                [.empty(.loading)],
                toSection: .loading
            )
            return snapshot
        }
    }
    
    private func deliverContentSnapshot() {
        if sharedDataController.accountCollection.isEmpty {
            deliverNoContentSnapshot()
            return
        }
        
        deliverSnapshot {
            [weak self] in
            guard let self = self else { return Snapshot() }
            
            var accounts: [AccountHandle] = []
            var accountItems: [HomeItem] = []
            var watchAccounts: [AccountHandle] = []
            var watchAccountItems: [HomeItem] = []
            
            let currency = self.sharedDataController.currency
            let calculator = ALGPortfolioCalculator()
            
            self.sharedDataController.accountCollection
                .sorted()
                .forEach {
                    let isNonWatchAccount = $0.value.type != .watch
                    let accountPortfolio =
                        AccountPortfolio(account: $0, currency: currency, calculator: calculator)
                    let cellItem: HomeAccountItem =
                        .cell(AccountPreviewViewModel(accountPortfolio))
                    let item: HomeItem = .account(cellItem)
                
                    if isNonWatchAccount {
                        accounts.append($0)
                        accountItems.append(item)
                    } else {
                        watchAccounts.append($0)
                        watchAccountItems.append(item)
                    }
                }
            
            var snapshot = Snapshot()
            
            snapshot.appendSections([.portfolio])
            
            let portfolio =
                Portfolio(accounts: accounts, currency: currency, calculator: calculator)
            let portfolioItem = HomePortfolioViewModel(portfolio)

            snapshot.appendItems(
                [.portfolio(portfolioItem)],
                toSection: .portfolio
            )
            
            if !accounts.isEmpty {
                let headerItem: HomeAccountItem =
                    .header(HomeAccountSectionHeaderViewModel(.standard))
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
            
            if !watchAccounts.isEmpty {
                let headerItem: HomeAccountItem =
                    .header(HomeAccountSectionHeaderViewModel(.watch))
                watchAccountItems.insert(
                    .account(headerItem),
                    at: 0
                )
                
                snapshot.appendSections([.watchAccounts])
                snapshot.appendItems(
                    watchAccountItems,
                    toSection: .watchAccounts
                )
            }
            
            return snapshot
        }
    }
    
    private func deliverNoContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty(.noContent)],
                toSection: .empty
            )
            return snapshot
        }
    }
    
    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else { return }
            self.publish(.didUpdate(snapshot()))
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
