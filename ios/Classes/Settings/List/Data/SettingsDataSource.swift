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
//   SettingsDataSource.swift

import UIKit

final class SettingsDataSource: NSObject {
    weak var delegate: SettingsDataSourceDelegate?
    
    private(set) lazy var sections: [GeneralSettings] = [
        .account, .appPreferences, .support
    ]

    private(set) lazy var settings: [[Settings]] = [
        accountSettings, appPreferenceSettings, supportSettings
    ]

    private(set) lazy var accountSettings: [AccountSettings] = createAccountSettings()

    private(set) lazy var appPreferenceSettings: [AppPreferenceSettings] = [
        .language, .currency, .appearance
    ]

    private(set) lazy var supportSettings: [SupportSettings] = [
        .feedback, .appReview, .termsAndServices, .privacyPolicy, .developer
    ]

    private let sharedDataController: SharedDataController
    private var session: Session?
    
    init(
        sharedDataController: SharedDataController,
        session: Session?
    ) {
        self.sharedDataController = sharedDataController
        super.init()
        self.session = session

        sharedDataController.add(self)
    }
}

extension SettingsDataSource {
    func updateAccountSettings() {
        self.accountSettings = createAccountSettings()
    }

    private func createAccountSettings(_ accounts: [Account]? = nil) -> [AccountSettings] {
        let secureBackupSettings = createSecureBackupSettings(accounts)

        return [
            secureBackupSettings,
            .security,
            .contacts,
            .notifications,
            .walletConnect
        ]
    }

    private func createSecureBackupSettings(_ accounts: [Account]? = nil) -> AccountSettings {
        guard let accounts else {
            return .secureBackupLoading
        }

        let filteredAccounts = accounts.filter(\.authorization.isStandard)

        var numberOfAccountsNotBackedUp = 0
        for account in filteredAccounts {
            if session?.backups[account.address] == nil {
                numberOfAccountsNotBackedUp = numberOfAccountsNotBackedUp.advanced(by: 1)
            }
        }

        let secureBackupSettings: AccountSettings

        if !accounts.isEmpty && numberOfAccountsNotBackedUp == 0 {
            secureBackupSettings = .secureBackup(numberOfAccountsNotBackedUp: nil)
        } else {
            secureBackupSettings = .secureBackup(numberOfAccountsNotBackedUp: numberOfAccountsNotBackedUp)
        }

        return secureBackupSettings
    }
}

extension SettingsDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let section = sections[safe: indexPath.section] {
            switch section {
            case .account:
                if let setting = accountSettings[safe: indexPath.item] {
                    switch setting {
                    case .secureBackupLoading:
                        return setSettingsLoadingCell(from: setting, in: collectionView, at: indexPath)
                    default:
                        return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
                    }
                }
            case .appPreferences:
                if let setting = appPreferenceSettings[safe: indexPath.item] {
                    switch setting {
                    case .language, .currency, .appearance:
                        return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
                    }
                }
            case .support:
                if let setting = supportSettings[safe: indexPath.item] {
                    return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
                }
            }
        }
        
        fatalError("Index path is out of bounds")
    }

    private func setSettingsDetailCell(
        from setting: Settings,
        in collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> SettingsDetailCell {
        let cell = collectionView.dequeue(SettingsDetailCell.self, at: indexPath)
        cell.bindData(SettingsDetailViewModel(settingsItem: setting))
        return cell
    }

    private func setSettingsLoadingCell(
        from setting: Settings,
        in collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> SettingsLoadingCell {
        let cell = collectionView.dequeue(SettingsLoadingCell.self, at: indexPath)
        cell.bindData(SettingsDetailViewModel(settingsItem: setting))
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueFooter(SettingsFooterSupplementaryView.self, at: indexPath)
            footerView.delegate = self
            return footerView
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueHeader(SingleGrayTitleHeaderSuplementaryView.self, at: indexPath)
            headerView.bindData(SingleGrayTitleHeaderViewModel(sections[indexPath.section]))
            return headerView
        default:
            fatalError("Unexpected element kind")
        }
    }
}

extension SettingsDataSource: SharedDataControllerObserver {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        let accounts: [Account]

        switch event {
        case .didFinishRunning:
            accounts = sharedDataController.sortedAccounts().map { $0.value }
        default:
            return
        }

        self.accountSettings = createAccountSettings(accounts)
        self.delegate?.settingsDataSourceDidReloadAccounts(self)
    }
}

extension SettingsDataSource: SettingsFooterSupplementaryViewDelegate {
    func settingsFooterSupplementaryViewDidTapLogoutButton(_ settingsFooterSupplementaryView: SettingsFooterSupplementaryView) {
        delegate?.settingsDataSourceDidTapLogout(self, settingsFooterSupplementaryView)
    }
}

protocol SettingsDataSourceDelegate: AnyObject {
    func settingsDataSourceDidTapLogout(
        _ settingsDataSource: SettingsDataSource,
        _ settingsFooterSupplementaryView: SettingsFooterSupplementaryView
    )
    func settingsDataSourceDidReloadAccounts(_ settingsDataSource: SettingsDataSource)
}
