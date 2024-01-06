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
//   SecuritySettingsViewController.swift

import UIKit

final class SecuritySettingsViewController: BaseViewController {
    private lazy var theme = Theme()
    private lazy var securitySettingsView = SecuritySettingsView()
    
    private lazy var settings: [[SecuritySettings]] = [[.pinCodeActivation]]
    private lazy var pinActiveSettings: [SecuritySettings] = [.pinCodeChange, .localAuthentication]

    private lazy var localAuthenticator = LocalAuthenticator(session: session!)
    
    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        title = "security-settings-title".localized
    }

    override func linkInteractors() {
        securitySettingsView.collectionView.delegate = self
        securitySettingsView.collectionView.dataSource = self
    }
    
    override func prepareLayout() {
        addSecuritySettingsView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        checkPINCodeActivation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !isViewFirstLoaded else {
            return
        }

        checkPINCodeActivation()
    }
}

extension SecuritySettingsViewController {
    private func addSecuritySettingsView() {
        view.addSubview(securitySettingsView)
        
        securitySettingsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.safeEqualToTop(of: self)
            $0.bottom.safeEqualToBottom(of: self)
        }
    }
}

extension SecuritySettingsViewController {
    private func checkPINCodeActivation() {
        let hasPassword = session?.hasPassword() ?? false

        if hasPassword {
            createSettingsWithPreferences()
        } else {
            createSettingsWithoutPreferences()
        }
    }
    
    private func createSettingsWithPreferences() {
        settings = [[.pinCodeActivation], [.pinCodeChange, .localAuthentication]]
        securitySettingsView.collectionView.reloadData()
    }
    
    private func createSettingsWithoutPreferences() {
        settings = [[.pinCodeActivation]]
        securitySettingsView.collectionView.reloadData()
    }
}

extension SecuritySettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(theme.cellSize)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if section == 1 {
            return CGSize(theme.headerSize)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = settings[safe: indexPath.section],
              let setting = section[safe: indexPath.item] else {
            fatalError("Index path is out of bounds")
        }
        
        if setting == .pinCodeChange {
            open(
                .choosePassword(mode: .verifyOld, flow: nil),
                by: .push
            )
        }
    }
}

extension SecuritySettingsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let section = settings[safe: indexPath.section], let setting = section[safe: indexPath.item] {
            switch setting {
            case .pinCodeActivation:
                let cell = collectionView.dequeue(SettingsToggleCell.self, at: indexPath)
                cell.delegate = self
                let hasPassword = session?.hasPassword() ?? false
                cell.bindData(SettingsToggleViewModel(setting: setting, isOn: hasPassword))
                return cell
            case .pinCodeChange:
                let cell = collectionView.dequeue(SettingsDetailCell.self, at: indexPath)
                cell.bindData(SettingsDetailViewModel(settingsItem: setting))
                return cell
            case .localAuthentication:
                let hasBiometricAuthentication = localAuthenticator.hasAuthentication()
                let cell = collectionView.dequeue(SettingsToggleCell.self, at: indexPath)
                cell.delegate = self
                cell.bindData(SettingsToggleViewModel(setting: setting, isOn: hasBiometricAuthentication))
                return cell
            }
        }
        
        fatalError("Index path is out of bounds")
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueHeader(SingleGrayTitleHeaderSuplementaryView.self, at: indexPath)
            headerView.bindData(SingleGrayTitleHeaderViewModel("security-settings-section".localized))
            return headerView
        }
        
        fatalError("Unexpected element kind")
    }
}

extension SecuritySettingsViewController: SettingsToggleCellDelegate {
    func settingsToggleCell(_ settingsToggleCell: SettingsToggleCell, didChangeValue value: Bool) {
        guard let indexPath = securitySettingsView.collectionView.indexPath(for: settingsToggleCell),
            let section = settings[safe: indexPath.section],
            let setting = section[safe: indexPath.item] else {
            return
        }
        
        switch setting {
        case .pinCodeActivation:
            let mode: ChoosePasswordViewController.Mode = value ? .resetPassword(flow: .initial) : .deletePassword
            open(
                .choosePassword(mode: mode, flow: nil),
                by: .push
            )
        case .localAuthentication:
            if !value {
                let controller = open(
                    .choosePassword(mode: .confirm(flow: .settings), flow: nil),
                    by: .push
                ) as? ChoosePasswordViewController
                controller?.delegate = self
                return
            }

            do {
                try localAuthenticator.setBiometricPassword()
            } catch let error as LAError {
                defer {
                    settingsToggleCell.contextView.setToggleOn(false, animated: true)
                }

                switch error {
                case .unexpected:
                    presentDisabledLocalAuthenticationAlert()
                default:
                    break
                }
            } catch {
                presentDisabledLocalAuthenticationAlert()
                settingsToggleCell.contextView.setToggleOn(false, animated: true)
            }

        default:
            return
        }
    }
}

extension SecuritySettingsViewController: ChoosePasswordViewControllerDelegate {
    func choosePasswordViewController(
        _ choosePasswordViewController: ChoosePasswordViewController,
        didConfirmPassword isConfirmed: Bool
    ) {
        choosePasswordViewController.popScreen()

        let indexPath = IndexPath(item: 1, section: 1)
        guard let cell =
                securitySettingsView.collectionView.cellForItem(at: indexPath) as? SettingsToggleCell else {
                    return
                }

        if isConfirmed {
            do {
                try localAuthenticator.removeBiometricPassword()
                cell.contextView.setToggleOn(false, animated: true)
            } catch {
                bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "local-authentication-disabled-error-message".localized
                )
                cell.contextView.setToggleOn(true, animated: false)
            }
        } else {
            cell.contextView.setToggleOn(true, animated: true)
        }
    }
}

extension SecuritySettingsViewController {
    private func presentDisabledLocalAuthenticationAlert() {
        let alertController = UIAlertController(
            title: "local-authentication-go-settings-title".localized,
            message: "local-authentication-go-settings-text".localized,
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "title-go-to-settings".localized, style: .default) { _ in
            UIApplication.shared.openAppSettings()
        }
        
        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel) { [weak self] _ in
            guard let self = self else {
                return
            }

            let indexPath = IndexPath(item: 1, section: 0)
            guard let cell = self.securitySettingsView.collectionView.cellForItem(at: indexPath) as? SettingsToggleCell else {
                return
            }
            
            cell.contextView.setToggleOn(!cell.contextView.isToggleOn, animated: true)
        }
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
