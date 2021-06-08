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
//  SettingsViewController.swift

import UIKit
import SVProgressHUD

class SettingsViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var bottomModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 402.0))
    )
    
    private lazy var pushNotificationController: PushNotificationController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return PushNotificationController(api: api)
    }()
    
    private lazy var settings: [[GeneralSettings]] = [securitySettings, preferenceSettings, appSettings, developerSettings]
    private lazy var securitySettings: [GeneralSettings] = [.password, .localAuthentication]
    private lazy var preferenceSettings: [GeneralSettings] = {
        var settings: [GeneralSettings] = [.notifications, .rewards, .language, .currency]
        if #available(iOS 13.0, *) {
            settings.append(.appearance)
        }
        return settings
    }()
    private lazy var appSettings: [GeneralSettings] = [.support, .appReview, .termsAndServices, .privacyPolicy]
    private lazy var developerSettings: [GeneralSettings] = [.developer]
    
    private lazy var settingsView = SettingsView()
    
    private let localAuthenticator = LocalAuthenticator()
    
    override func customizeTabBarAppearence() {
        isTabBarHidden = false
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.tertiary
    }
    
    override func linkInteractors() {
        settingsView.collectionView.delegate = self
        settingsView.collectionView.dataSource = self
    }
    
    override func setListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didApplicationEnterForeground),
            name: .ApplicationWillEnterForeground,
            object: nil
        )
    }
    
    override func prepareLayout() {
        setupSettingsViewLayout()
    }
}

extension SettingsViewController {
    @objc
    private func didApplicationEnterForeground() {
        settingsView.collectionView.reloadData()
    }
}

extension SettingsViewController {
    private func setupSettingsViewLayout() {
        view.addSubview(settingsView)
        
        settingsView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.safeEqualToTop(of: self)
            make.bottom.safeEqualToBottom(of: self)
        }
    }
}

extension SettingsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let settings = settings[safe: indexPath.section],
            let setting = settings[safe: indexPath.item] {
            switch setting {
            case .password:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .localAuthentication:
                let localAuthenticationStatus = localAuthenticator.localAuthenticationStatus == .allowed
                return setSettingsToggleCell(from: setting, isOn: localAuthenticationStatus, in: collectionView, at: indexPath)
            case .notifications:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .rewards:
                let rewardDisplayPreference = session?.rewardDisplayPreference == .allowed
                return setSettingsToggleCell(from: setting, isOn: rewardDisplayPreference, in: collectionView, at: indexPath)
            case .language:
                let defaultLanguageText = "settings-language-english".localized
                guard let preferredLocalization = Bundle.main.preferredLocalizations.first,
                      let displayName = NSLocale(localeIdentifier: preferredLocalization).displayName(
                        forKey: .identifier,
                        value: preferredLocalization
                      ) else {
                    return setSettingsInfoCell(from: setting, info: defaultLanguageText, in: collectionView, at: indexPath)
                }
                return setSettingsInfoCell(from: setting, info: displayName, in: collectionView, at: indexPath)
            case .currency:
                let preferredCurrency = api?.session.preferredCurrency ?? "settings-currency-usd".localized
                return setSettingsInfoCell(from: setting, info: preferredCurrency, in: collectionView, at: indexPath)
            case .appearance:
                let preferredAppearance = api?.session.userInterfaceStyle ?? .system
                return setSettingsInfoCell(from: setting, info: preferredAppearance.representation(), in: collectionView, at: indexPath)
            case .support:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .appReview:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .termsAndServices:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .privacyPolicy:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .developer:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            }
        }
        
        fatalError("Index path is out of bounds")
    }
    
    private func setSettingsDetailCell(
        from setting: Settings,
        in collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> SettingsDetailCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsDetailCell.reusableIdentifier,
            for: indexPath
        ) as? SettingsDetailCell {
            if shouldHideSeparator(at: indexPath, in: collectionView) {
                cell.contextView.setSeparatorHidden(true)
            }
            SettingsDetailViewModel(setting: setting).configure(cell)
            return cell
        }
        
        fatalError("Index path is out of bounds")
    }
    
    private func setSettingsInfoCell(
        from setting: Settings,
        info: String?,
        in collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> SettingsInfoCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsInfoCell.reusableIdentifier,
            for: indexPath
        ) as? SettingsInfoCell {
            if shouldHideSeparator(at: indexPath, in: collectionView) {
                cell.contextView.setSeparatorHidden(true)
            }
            SettingsInfoViewModel(setting: setting, info: info).configure(cell)
            return cell
        }
        
        fatalError("Index path is out of bounds")
    }
    
    private func setSettingsToggleCell(
        from setting: Settings,
        isOn: Bool,
        in collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> SettingsToggleCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsToggleCell.reusableIdentifier,
            for: indexPath
        ) as? SettingsToggleCell {
            if shouldHideSeparator(at: indexPath, in: collectionView) {
                cell.contextView.setSeparatorHidden(true)
            }
            cell.delegate = self
            SettingsToggleViewModel(setting: setting, isOn: isOn).configure(cell)
            return cell
        }
        
        fatalError("Index path is out of bounds")
    }
    
    private func shouldHideSeparator(at indexPath: IndexPath, in collectionView: UICollectionView) -> Bool {
        return isDarkModeDisplay && collectionView.numberOfItems(inSection: indexPath.section) == indexPath.item + 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind != UICollectionView.elementKindSectionFooter {
            fatalError("Unexpected element kind")
        }
        
        guard let footerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SettingsFooterSupplementaryView.reusableIdentifier,
            for: indexPath
        ) as? SettingsFooterSupplementaryView else {
            fatalError("Unexpected element kind")
        }
        
        footerView.delegate = self
        return footerView
    }
}

extension SettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 72.0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        if section == settings.count - 1 {
            return CGSize(width: UIScreen.main.bounds.width, height: 128.0)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let settings = settings[safe: indexPath.section],
            let setting = settings[safe: indexPath.item] {
        
            switch setting {
            case .password:
                open(
                    .choosePassword(
                        mode: .resetPassword, flow: nil, route: nil),
                        by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
                )
            case .support:
                if let url = AlgorandWeb.support.link {
                    open(url)
                }
            case .notifications:
                open(.notificationFilter(flow: .settings), by: .push)
            case .appReview:
                AlgorandAppStoreReviewer().requestManualReview(forAppWith: Environment.current.appID)
            case .language:
                displayProceedAlertWith(
                    title: "settings-language-change-title".localized,
                    message: "settings-language-change-detail".localized
                ) { _ in
                    UIApplication.shared.openAppSettings()
                }
            case .currency:
                let controller = open(.currencySelection, by: .push) as? CurrencySelectionViewController
                controller?.delegate = self
            case .appearance:
                let appearanceSelectionViewController = open(.appearanceSelection, by: .push) as? AppearanceSelectionViewController
                appearanceSelectionViewController?.delegate = self
            case .termsAndServices:
                guard let url = AlgorandWeb.termsAndServices.link else {
                    return
                }
                
                open(url)
            case .privacyPolicy:
                guard let url = AlgorandWeb.privacyPolicy.link else {
                    return
                }
                
                open(url)
            case .developer:
                open(.developerSettings, by: .push)
            default:
                break
            }
        }
    }
}

extension SettingsViewController: SettingsFooterSupplementaryViewDelegate {
    func settingsFooterSupplementaryViewDidTapLogoutButton(_ settingsFooterSupplementaryView: SettingsFooterSupplementaryView) {
        presentLogoutAlert()
    }
}

extension SettingsViewController: SettingsToggleCellDelegate {
    func settingsToggleCell(_ settingsToggleCell: SettingsToggleCell, didChangeValue value: Bool) {
        guard let indexPath = settingsView.collectionView.indexPath(for: settingsToggleCell),
            let settings = settings[safe: indexPath.section],
            let setting = settings[safe: indexPath.item] else {
            return
        }
        
        switch setting {
        case .localAuthentication:
            if !value {
                localAuthenticator.localAuthenticationStatus = .notAllowed
                return
            }
            
            if localAuthenticator.isLocalAuthenticationAvailable {
                localAuthenticator.authenticate { error in
                    guard error == nil else {
                        settingsToggleCell.contextView.setToggleOn(false, animated: true)
                        return
                    }
                    
                    self.localAuthenticator.localAuthenticationStatus = .allowed
                }
                return
            }
            
            presentDisabledLocalAuthenticationAlert()
        case .rewards:
            session?.rewardDisplayPreference = value ? .allowed : .disabled
        default:
            return
        }
    }
    
    private func presentDisabledLocalAuthenticationAlert() {
        let alertController = UIAlertController(
            title: "local-authentication-go-settings-title".localized,
            message: "local-authentication-go-settings-text".localized,
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "title-go-to-settings".localized, style: .default) { _ in
            UIApplication.shared.openAppSettings()
        }
        
        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel) { _ in
            let indexPath = IndexPath(item: 1, section: 0)
            guard let cell = self.settingsView.collectionView.cellForItem(at: indexPath) as? SettingsToggleCell else {
                return
            }
            
            cell.contextView.setToggleOn(!cell.contextView.isToggleOn, animated: true)
        }
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func presentLogoutAlert() {
        let configurator = BottomInformationBundle(
            title: "settings-logout-title".localized,
            image: img("icon-settings-logout"),
            explanation: "settings-logout-detail".localized,
            actionTitle: "node-settings-action-delete-title".localized,
            actionImage: img("bg-button-red")
        ) {
            self.logout()
        }
        
        open(
            .bottomInformation(mode: .action, configurator: configurator),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: bottomModalPresenter
            )
        )
    }
    
    private func logout() {
        session?.reset(isContactIncluded: true)
        NotificationCenter.default.post(name: .ContactDeletion, object: self, userInfo: nil)
        pushNotificationController.revokeDevice()
        open(.introduction(flow: .initializeAccount(mode: .none)), by: .launch, animated: false)
     }
}

extension SettingsViewController: CurrencySelectionViewControllerDelegate {
    func currencySelectionViewControllerDidSelectCurrency(_ currencySelectionViewController: CurrencySelectionViewController) {
        settingsView.collectionView.reloadItems(at: [IndexPath(item: 3, section: 1)])
    }
}

extension SettingsViewController: AppearanceSelectionViewControllerDelegate {
    func appearanceSelectionViewControllerDidUpdateUserInterfaceStyle(
        _ appearanceSelectionViewController: AppearanceSelectionViewController
    ) {
        guard #available(iOS 13.0, *) else {
            return
        }

        settingsView.collectionView.reloadItems(at: [IndexPath(item: 4, section: 1)])
    }
}
