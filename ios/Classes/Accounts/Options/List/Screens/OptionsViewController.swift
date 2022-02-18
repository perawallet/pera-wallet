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
//  OptionsViewController.swift

import UIKit
import MagpieCore
import MagpieHipo
import MagpieExceptions
import MacaroonBottomSheet
import MacaroonUIKit

final class OptionsViewController: BaseViewController {
    weak var delegate: OptionsViewControllerDelegate?

    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var theme = Theme()
    private lazy var optionsView = OptionsView()

    private let account: Account
    private var options: [Options]
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        
        if account.isThereAnyDifferentAsset {
            options = Options.allOptions
        } else {
            options = Options.optionsWithoutRemoveAsset
        }
        
        if account.requiresLedgerConnection() {
            _ = options.removeAll { option in
                option == .viewPassphrase
            }
        }
        
        if !account.isRekeyed() {
            _ = options.removeAll { option in
                option == .rekeyInformation
            }
        }
        
        if account.isWatchAccount() {
            options = Options.watchAccountOptions
        }
        
        super.init(configuration: configuration)
    }
    
    override func linkInteractors() {
        optionsView.optionsCollectionView.delegate = self
        optionsView.optionsCollectionView.dataSource = self
    }
    
    override func prepareLayout() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        view.addSubview(optionsView)
        optionsView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.safeEqualToBottom(of: self)
        }
    }
}

extension OptionsViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return .preferred(theme.modalHeight)
    }
}

extension OptionsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(OptionsCell.self, at: indexPath)
        cell.bind(OptionsViewModel(option: options[indexPath.item], account: account))
        return cell
    }
}

extension OptionsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let isCopyAddressCell = indexPath.row == 0
        return CGSize(isCopyAddressCell ? theme.copyAddressCellSize : theme.defaultCellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedOption = options[indexPath.item]
        
        switch selectedOption {
        case .copyAddress:
            dismissScreen()
            delegate?.optionsViewControllerDidCopyAddress(self)
        case .rekey:
            dismissScreen()
            delegate?.optionsViewControllerDidOpenRekeying(self)
        case .removeAsset:
            dismissScreen()
            delegate?.optionsViewControllerDidRemoveAsset(self)
        case .viewPassphrase:
            closeScreen(by: .dismiss) { [weak self] in
                guard let self = self else {
                    return
                }

                self.delegate?.optionsViewControllerDidViewPassphrase(self)
            }
        case .rekeyInformation:
            dismissScreen()
            delegate?.optionsViewControllerDidViewRekeyInformation(self)
        case .muteNotifications:
            updateNotificationStatus()
        case .renameAccount:
            let controller = open(.editAccount(account: account), by: .push) as? EditAccountViewController
            controller?.delegate = self
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

        loadingController?.startLoadingWithMessage("title-loading".localized)

        let draft = NotificationFilterDraft(
            deviceId: deviceId,
            accountAddress: account.address,
            receivesNotifications: !account.receivesNotification
        )

        api?.updateNotificationFilter(draft) { response in
            switch response {
            case let .success(result):
                self.updateNotificationFiltering(with: result)
            case let .failure(_, hipApiError):
                self.displayNotificationFilterError(hipApiError)
            }
        }
    }

    private func updateNotificationFiltering(with result: NotificationFilterResponse) {
        account.receivesNotification = result.receivesNotification
        loadingController?.stopLoading()
        updateAccountForNotificationFilters()
        updateNotificationFilterCell()
    }

    private func updateAccountForNotificationFilters() {
        guard let localAccount = api?.session.accountInformation(from: account.address) else {
            return
        }

        localAccount.receivesNotification = account.receivesNotification
        api?.session.authenticatedUser?.updateAccount(localAccount)
    }

    private func updateNotificationFilterCell() {
        if let index = options.firstIndex(of: .muteNotifications),
           let cell = optionsView.optionsCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? OptionsCell {
            cell.bind(OptionsViewModel(option: .muteNotifications, account: self.account))
        }
    }

    private func displayNotificationFilterError(_ error: HIPAPIError?) {
        loadingController?.stopLoading()
        bannerController?.presentErrorBanner(
            title: "title-error".localized, message: error?.fallbackMessage ?? "transaction-filter-error-title".localized
        )
    }
}

extension OptionsViewController: EditAccountViewControllerDelegate {
    func editAccountViewControllerDidTapDoneButton(_ viewController: EditAccountViewController) {
        delegate?.optionsViewControllerDidRenameAccount(self)
    }
}

extension OptionsViewController {
    enum Options: Int, CaseIterable {
        case copyAddress = 0
        case rekey = 1
        case viewPassphrase = 2
        case muteNotifications = 3
        case rekeyInformation = 4
        case renameAccount = 5
        case removeAsset = 6
        case removeAccount = 7

        static var optionsWithoutRemoveAsset: [Options] {
            return [.copyAddress, .rekey, .rekeyInformation, .viewPassphrase, .muteNotifications, .renameAccount, .removeAccount]
        }

        static var optionsWithoutPassphrase: [Options] {
            return [.copyAddress, .rekey, .rekeyInformation, .muteNotifications, .renameAccount, .removeAsset, .removeAccount]
        }
        
        static var optionsWithoutPassphraseAndRemoveAsset: [Options] {
            return [.copyAddress, .rekey, .rekeyInformation, .muteNotifications, .renameAccount, .removeAccount]
        }
        
        static var allOptions: [Options] {
            return allCases
        }
        
        static var watchAccountOptions: [Options] {
            return [.muteNotifications, .renameAccount, .removeAccount]
        }
    }
}

protocol OptionsViewControllerDelegate: AnyObject {
    func optionsViewControllerDidCopyAddress(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidOpenRekeying(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidRemoveAsset(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidViewPassphrase(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidViewRekeyInformation(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidRenameAccount(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidRemoveAccount(_ optionsViewController: OptionsViewController)
}
