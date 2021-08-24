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
//  OptionsViewController.swift

import UIKit
import SVProgressHUD
import Magpie

class OptionsViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var optionsView = OptionsView()

    private var account: Account
    
    weak var delegate: OptionsViewControllerDelegate?
    
    private var options: [Options]
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        
        if account.isThereAnyDifferentAsset() {
            options = Options.allOptions
        } else {
            options = Options.optionsWithoutRemoveAsset
        }
        
        if account.requiresLedgerConnection() {
            options.removeAll { option -> Bool in
                option == .passphrase
            }
        }
        
        if !account.isRekeyed() {
            options.removeAll { option -> Bool in
                option == .rekeyInformation
            }
        }
        
        if account.isWatchAccount() {
            options = Options.watchAccountOptions
        }
        
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.secondary
    }
    
    override func linkInteractors() {
        optionsView.optionsCollectionView.delegate = self
        optionsView.delegate = self
        optionsView.optionsCollectionView.dataSource = self
    }
    
    override func prepareLayout() {
        setupOptionsViewLayout()
    }
}

extension OptionsViewController {
    private func setupOptionsViewLayout() {
        view.addSubview(optionsView)
        
        optionsView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.safeEqualToBottom(of: self)
        }
    }
}

extension OptionsViewController: OptionsViewDelegate {
    func optionsViewDidTapCancelButton(_ optionsView: OptionsView) {
        dismissScreen()
    }
}

extension OptionsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OptionsCell.reusableIdentifier,
            for: indexPath) as? OptionsCell else {
                fatalError("Index path is out of bounds")
        }
        
        let option = options[indexPath.item]
        cell.bind(OptionsViewModel(option: option, account: account))
        return cell
    }
}

extension OptionsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: view.frame.width, height: layout.current.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedOption = options[indexPath.item]
        
        switch selectedOption {
        case .rekey:
            dismissScreen()
            delegate?.optionsViewControllerDidOpenRekeying(self)
        case .removeAsset:
            dismissScreen()
            delegate?.optionsViewControllerDidRemoveAsset(self)
        case .passphrase:
            dismissScreen()
            delegate?.optionsViewControllerDidViewPassphrase(self)
        case .rekeyInformation:
            dismissScreen()
            delegate?.optionsViewControllerDidViewRekeyInformation(self)
        case .notificationSetting:
            updateNotificationStatus()
        case .edit:
            open(.editAccount(account: account), by: .push)
        case .removeAccount:
            dismissScreen()
            delegate?.optionsViewControllerDidRemoveAccount(self)
        }
    }
}

extension OptionsViewController {
    private func updateNotificationStatus() {
        guard let deviceId = api?.session.authenticatedUser?.deviceId else {
            return
        }

        SVProgressHUD.show(withStatus: "title-loading".localized)

        let draft = NotificationFilterDraft(
            deviceId: deviceId,
            accountAddress: account.address,
            receivesNotifications: !account.receivesNotification
        )

        api?.updateNotificationFilter(with: draft) { response in
            switch response {
            case let .success(result):
                self.updateNotificationFiltering(with: result)
            case let .failure(_, hipApiError):
                self.displayNotificationFilterError(hipApiError)
            }
        }
    }

    private func updateNotificationFiltering(with result: NotificationFilterResponse) {
        self.account.receivesNotification = result.receivesNotification
        SVProgressHUD.showSuccess(withStatus: "title-done".localized)
        SVProgressHUD.dismiss()
        updateAccountForNotificationFilters()
        updateNotificationFilterCell()
    }

    private func updateAccountForNotificationFilters() {
        guard let localAccount = api?.session.accountInformation(from: account.address) else {
            return
        }

        localAccount.receivesNotification = account.receivesNotification
        api?.session.authenticatedUser?.updateAccount(localAccount)
        api?.session.updateAccount(account)
    }

    private func updateNotificationFilterCell() {
        if let index = options.firstIndex(of: .notificationSetting),
           let cell = optionsView.optionsCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? OptionsCell {
            cell.bind(OptionsViewModel(option: .notificationSetting, account: self.account))
        }
    }

    private func displayNotificationFilterError(_ error: HIPAPIError?) {
        SVProgressHUD.showError(withStatus: nil)
        SVProgressHUD.dismiss()
        NotificationBanner.showError(
            "title-error".localized,
            message: error?.fallbackMessage ?? "transaction-filter-error-title".localized
        )
    }
}

extension OptionsViewController {
    enum Options: Int, CaseIterable {
        case rekey = 0
        case passphrase = 1
        case rekeyInformation = 2
        case notificationSetting = 3
        case edit = 4
        case removeAsset = 5
        case removeAccount = 6
        
        static var optionsWithoutRemoveAsset: [Options] {
            return [.rekey, .rekeyInformation, .passphrase, .notificationSetting, .edit, .removeAccount]
        }

        static var optionsWithoutPassphrase: [Options] {
            return [.rekey, .rekeyInformation, .notificationSetting, .edit, .removeAsset, .removeAccount]
        }
        
        static var optionsWithoutPassphraseAndRemoveAsset: [Options] {
            return [.rekey, .rekeyInformation, .notificationSetting, .edit, .removeAccount]
        }
        
        static var allOptions: [Options] {
            return [.rekey, .passphrase, .rekeyInformation, .notificationSetting, .edit, .removeAsset, .removeAccount]
        }
        
        static var watchAccountOptions: [Options] {
            return [.notificationSetting, .edit, .removeAccount]
        }
    }
}

extension OptionsViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let cellHeight: CGFloat = 56.0
    }
}

protocol OptionsViewControllerDelegate: AnyObject {
    func optionsViewControllerDidOpenRekeying(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidRemoveAsset(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidViewPassphrase(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidViewRekeyInformation(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidRemoveAccount(_ optionsViewController: OptionsViewController)
}
