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
//  DeveloperSettingsViewController.swift

import UIKit
import MacaroonUtils

final class DeveloperSettingsViewController:
    BaseViewController,
    NotificationObserver {
    var notificationObservations: [NSObjectProtocol] = []

    private lazy var theme = Theme()
    private lazy var developerSettingsView = DeveloperSettingsView()
    
    private var settings: [DeveloperSettings] = [.nodeSettings]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reload()
    }
    
    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        navigationItem.title = "settings-developer".localized
    }
    
    override func linkInteractors() {
        developerSettingsView.collectionView.delegate = self
        developerSettingsView.collectionView.dataSource = self
    }

    override func setListeners() {
        observe(notification: NodeSettingsViewController.didUpdateNetwork) {
            [weak self] _ in
            self?.reload()
        }
    }
    
    override func prepareLayout() {
        addDeveloperSettingsView()
    }
}

extension DeveloperSettingsViewController {
    private func reload() {
        switch api?.network {
        case .mainnet, .none:
            settings = [.nodeSettings]
        case .testnet:
            settings = [.nodeSettings, .dispenser]
        }

        developerSettingsView.collectionView.reloadData()
    }
}

extension DeveloperSettingsViewController {
    private func addDeveloperSettingsView() {
        view.addSubview(developerSettingsView)
        
        developerSettingsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.safeEqualToTop(of: self)
            $0.bottom.safeEqualToBottom(of: self)
        }
    }
}

extension DeveloperSettingsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(SettingsDetailCell.self, at: indexPath)
        
        if let setting = settings[safe: indexPath.item] {
            cell.bindData(SettingsDetailViewModel(setting: setting))
            return cell
        }
        
        fatalError("Index path is out of bounds")
    }
}

extension DeveloperSettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let setting = settings[safe: indexPath.item] else {
            fatalError("Index path is out of bounds")
        }
        
        switch setting {
        case .nodeSettings:
            open(.nodeSettings, by: .push)
        case .dispenser:
            guard let url = AlgorandWeb.dispenser.link else {
                return
            }

            guard let firstAccount = self.sharedDataController.sortedAccounts().first else {
                open(url)
                return
            }

            let params = [
                URLQueryItem(
                    name: "account",
                    value: firstAccount.value.address
                )
            ]
            let newUrl = url.appendQueryParameters(params)

            open(newUrl)
        }
    }
}
