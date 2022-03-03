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

import Foundation
import MacaroonBottomSheet
import MacaroonUIKit
import MagpieExceptions
import UIKit

final class OptionsViewController:
    BaseScrollViewController,
    BottomSheetPresentable {
    weak var delegate: OptionsViewControllerDelegate?

    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var contextView = VStackView()
    
    private var muteNotificationsView: ListActionView?

    private let account: Account
    private let options: [Option]
    
    private let theme: OptionsViewControllerTheme
    
    init(
        account: Account,
        configuration: ViewControllerConfiguration,
        theme: OptionsViewControllerTheme = .init()
    ) {
        self.account = account
        self.options = Option.makeOptions(for: account)
        self.theme = theme
        
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }
    
    private func build() {
        addBackground()
        addContext()
        addActions()
    }
}

extension OptionsViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }
    
    private func addContext() {
        contentView.addSubview(contextView)
        contextView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.contentPaddings.top,
            leading: theme.contentPaddings.leading,
            bottom: theme.contentPaddings.bottom,
            trailing: theme.contentPaddings.trailing
        )
        contextView.isLayoutMarginsRelativeArrangement = true
        contextView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
    
    private func addActions() {
        options.forEach {
            switch $0 {
            case .copyAddress:
                addAction(
                    CopyAddressListActionViewModel(account),
                    #selector(copyAddress)
                )
            case .rekey:
                addAction(
                    RekeyAccountListActionViewModel(),
                    #selector(rekeyAccount)
                )
            case .rekeyInformation:
                addAction(
                    ShowQrCodeListActionViewModel(),
                    #selector(showQRCode)
                )
            case .viewPassphrase:
                addAction(
                    ViewPassphraseListActionViewModel(),
                    #selector(viewPassphrase)
                )
            case .muteNotifications:
                muteNotificationsView = addAction(
                    MuteNotificationsListActionViewModel(account),
                    #selector(muteNotifications)
                )
            case .renameAccount:
                addAction(
                    RenameAccountListActionViewModel(),
                    #selector(renameAccount)
                )
            case .removeAsset:
                addAction(
                    ManageAssetsListActionViewModel(),
                    #selector(manageAssets)
                )
            case .removeAccount:
                addAction(
                    RemoveAccountListActionViewModel(),
                    #selector(removeAccount)
                )
            }
        }
    }
    
    @discardableResult
    private func addAction(
        _ viewModel: ListActionViewModel,
        _ selector: Selector
    ) -> ListActionView {
        let actionView = ListActionView()
        
        actionView.customize(theme.action)
        actionView.bindData(viewModel)
        
        contextView.addArrangedSubview(actionView)
        
        actionView.addTouch(
            target: self,
            action: selector
        )
        
        return actionView
    }
}

extension OptionsViewController {
    @objc
    private func copyAddress() {
        dismissScreen()
        delegate?.optionsViewControllerDidCopyAddress(self)
    }
    
    @objc
    private func rekeyAccount() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }
            
            self.delegate?.optionsViewControllerDidOpenRekeying(self)
        }
    }
    
    @objc
    private func showQRCode() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }
            
            self.delegate?.optionsViewControllerDidViewRekeyInformation(self)
        }
    }
    
    @objc
    private func viewPassphrase() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }

            self.delegate?.optionsViewControllerDidViewPassphrase(self)
        }
    }
    
    @objc
    private func muteNotifications() {
        updateNotificationStatus()
    }
    
    @objc
    private func renameAccount() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }

            self.delegate?.optionsViewControllerDidRenameAccount(self)
        }
    }
    
    @objc
    private func manageAssets() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }
            
            self.delegate?.optionsViewControllerDidRemoveAsset(self)
        }
    }
    
    @objc
    private func removeAccount() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }
            
            self.delegate?.optionsViewControllerDidRemoveAccount(self)
        }
    }
}

extension OptionsViewController {
    private func updateNotificationStatus() {
        guard let deviceId = session?.authenticatedUser?.deviceId else {
            return
        }

        loadingController?.startLoadingWithMessage("title-loading".localized)

        let draft = NotificationFilterDraft(
            deviceId: deviceId,
            accountAddress: account.address,
            receivesNotifications: !account.receivesNotification
        )

        api?.updateNotificationFilter(draft) {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.didUpdateNotificationStatus(response)
            case .failure(_, let apiErrorDetail):
                self.didFailToUpdateNotificationStatus(apiErrorDetail)
            }
            
            self.loadingController?.stopLoading()
        }
    }

    private func didUpdateNotificationStatus(
        _ response: NotificationFilterResponse
    ) {
        account.receivesNotification = response.receivesNotification
        
        if let localAccount = session?.accountInformation(from: account.address) {
            localAccount.receivesNotification = response.receivesNotification
            session?.authenticatedUser?.updateAccount(localAccount)
        }

        muteNotificationsView?.bindData(MuteNotificationsListActionViewModel(account))
    }

    private func didFailToUpdateNotificationStatus(
        _ apiErrorDetail: HIPAPIError?
    ) {
        bannerController?.presentErrorBanner(
            title: "title-error".localized,
            message: apiErrorDetail?.fallbackMessage ?? "transaction-filter-error-title".localized
        )
    }
}

extension OptionsViewController {
    enum Option {
        case copyAddress
        case rekey
        case rekeyInformation
        case viewPassphrase
        case muteNotifications
        case renameAccount
        case removeAsset
        case removeAccount
        
        static func makeOptions(
            for account: Account
        ) -> [Option] {
            return account.isWatchAccount()
                ? makeOptions(forWatchAccount: account)
                : makeOptions(forNonWatchAccount: account)
        }
        
        private static func makeOptions(
            forWatchAccount account: Account
        ) -> [Option] {
            return [
                .muteNotifications,
                .renameAccount,
                .removeAccount
            ]
        }
        
        private static func makeOptions(
            forNonWatchAccount account: Account
        ) -> [Option] {
            var options: [Option] = []
            
            options.append(.copyAddress)
            options.append(.rekey)
            
            if account.isRekeyed() {
                options.append(.rekeyInformation)
            }
            
            if !account.requiresLedgerConnection() {
                options.append(.viewPassphrase)
            }
            
            options.append(.muteNotifications)
            options.append(.renameAccount)
            
            if account.hasAnyAssets() {
                options.append(.removeAsset)
            }
            
            options.append(.removeAccount)
            
            return options
        }
    }
}

protocol OptionsViewControllerDelegate: AnyObject {
    func optionsViewControllerDidCopyAddress(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidOpenRekeying(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidRemoveAsset(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidViewPassphrase(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidViewRekeyInformation(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidRenameAccount(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidRemoveAccount(
        _ optionsViewController: OptionsViewController
    )
}
