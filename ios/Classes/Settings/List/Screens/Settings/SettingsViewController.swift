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
//  SettingsViewController.swift

import UIKit
import MacaroonUIKit

final class SettingsViewController: BaseViewController {
    private lazy var bottomModalTransition = BottomSheetTransition(presentingViewController: self)
    
    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: session!,
        api: api!,
        bannerController: bannerController
    )
    
    private lazy var theme = Theme()
    private lazy var settingsView = SettingsView()

    private lazy var dataSource = SettingsDataSource(session: session)

    override var prefersLargeTitle: Bool {
        return true
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }
    
    override func linkInteractors() {
        dataSource.delegate = self
        settingsView.collectionView.delegate = self
        settingsView.collectionView.dataSource = dataSource
    }
    
    override func setListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didApplicationEnterForeground),
            name: .ApplicationWillEnterForeground,
            object: nil
        )
    }

    override func configureAppearance() {
        title = "settings-title".localized
    }
    
    override func prepareLayout() {
        addSettingsView()
    }
}

extension SettingsViewController {
    @objc
    private func didApplicationEnterForeground() {
        settingsView.collectionView.reloadData()
    }
}

extension SettingsViewController {
    private func addSettingsView() {
        view.addSubview(settingsView)

        settingsView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension SettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.cellSize)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(theme.headerSize)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        if dataSource.sections[section] == .support {
            return CGSize(theme.footerSize)
        }
        return .zero
    }
}

extension SettingsViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let section = dataSource.sections[safe: indexPath.section] {
            switch section {
            case .account:
                if let setting = dataSource.accountSettings[safe: indexPath.item] {
                    didSelectItemFromAccountSettings(setting)
                }
            case .appPreferences:
                if let setting = dataSource.appPreferenceSettings[safe: indexPath.item] {
                    didSelectItemFromAppPreferenceSettings(setting)
                }
            case .support:
                if let setting = dataSource.supportSettings[safe: indexPath.item] {
                    didSelectItemFromSupportSettings(setting)
                }
            }
        }
    }
    
    private func didSelectItemFromAccountSettings(_ setting: AccountSettings) {
        switch setting {
        case .security:
            open(.securitySettings, by: .push)
        case .contacts:
            open(.contacts, by: .push)
        case .notifications:
            open(.notificationFilter, by: .push)
        case .walletConnect:
            open(.walletConnectSessionList, by: .push)
        }
    }
    
    private func didSelectItemFromAppPreferenceSettings(_ setting: AppPreferenceSettings?) {
        switch setting {
        case .language:
            displayProceedAlertWith(
                title: "settings-language-change-title".localized,
                message: "settings-language-change-detail".localized
            ) { _ in
                UIApplication.shared.openAppSettings()
            }
        case .currency:
            open(.currencySelection, by: .push)
        case .appearance:
            open(.appearanceSelection, by: .push)
        default:
            break
        }
    }
    
    private func didSelectItemFromSupportSettings(_ setting: SupportSettings) {
        switch setting {
        case .feedback:
            open(AlgorandWeb.support.link)
        case .appReview:
            bottomModalTransition.perform(
                .walletRating, by: .presentWithoutNavigationController
            )
        case .termsAndServices:
            open(AlgorandWeb.termsAndServices.link)
        case .privacyPolicy:
            open(AlgorandWeb.privacyPolicy.link)
        case .developer:
            open(.developerSettings, by: .push)
        }
    }
}

extension SettingsViewController: SettingsDataSourceDelegate {
    func settingsDataSourceDidTapLogout(
        _ settingsDataSource: SettingsDataSource,
        _ settingsFooterSupplementaryView: SettingsFooterSupplementaryView
    ) {
        presentLogoutAlert()
    }
    
    private func presentLogoutAlert() {
        let bottomWarningViewConfigurator = BottomWarningViewConfigurator(
            image: "icon-settings-logout".uiImage,
            title: "settings-delete-data-title".localized,
            description: .plain("settings-logout-detail".localized),
            primaryActionButtonTitle: "settings-logout-button-delete".localized,
            secondaryActionButtonTitle: "settings-logout-button-cancel".localized,
            primaryAction: { [weak self] in
                guard let self = self else {
                    return
                }
                self.logout()
            }
        )
        
        bottomModalTransition.perform(
            .bottomWarning(configurator: bottomWarningViewConfigurator),
            by: .presentWithoutNavigationController
        )
    }
    
    private func logout() {
        guard let rootViewController = UIApplication.shared.rootViewController() else {
            return
        }

        rootViewController.deleteAllData() { [weak self] isCompleted in
            guard let self = self else {
                return
            }

            if isCompleted {
                self.presentLogoutSuccessScreen()
                return
            }

            self.bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "pass-phrase-verify-sdk-error".localized
            )
        }
    }

    private func presentLogoutSuccessScreen() {
        let configurator = BottomWarningViewConfigurator(
            image: "icon-approval-check".uiImage,
            title: "settings-logout-success-message".localized,
            secondaryActionButtonTitle: "title-close".localized
        )

        bottomModalTransition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
    }
}
