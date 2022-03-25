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
//   AccountDetailViewController.swift

import Foundation
import UIKit

final class AccountDetailViewController: PageContainer {
    typealias EventHandler = (Event) -> Void
    
    var eventHandler: EventHandler?
    
    private lazy var theme = Theme()
    private lazy var modalTransition = BottomSheetTransition(presentingViewController: self)

    private lazy var assetListScreen = AccountAssetListViewController(
        accountHandle: accountHandle,
        configuration: configuration
    )

    private lazy var nftListScreen = AccountNFTListViewController(
        account: accountHandle.value,
        configuration: configuration
    )

    private lazy var transactionListScreen = AccountTransactionListViewController(
        draft: AccountTransactionListing(accountHandle: accountHandle),
        configuration: configuration
    )

    private lazy var localAuthenticator = LocalAuthenticator()

    private lazy var accountTitleView = ImageWithTitleView()

    private var accountHandle: AccountHandle

    init(accountHandle: AccountHandle, configuration: ViewControllerConfiguration) {
        self.accountHandle = accountHandle
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setPageBarItems()
        addTitleView()
    }

    override func configureNavigationBarAppearance() {
        addOptionsBarButton()
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func linkInteractors() {
        super.linkInteractors()
        linkInteractors(assetListScreen)
    }
}

extension AccountDetailViewController {
    private func linkInteractors(
        _ screen: AccountAssetListViewController
    ) {
        screen.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let accountHandle):
                self.accountHandle = accountHandle
            }
        }
    }
}

extension AccountDetailViewController {
    private func addOptionsBarButton() {
        let optionsBarButtonItem = ALGBarButtonItem(kind: .options) { [weak self] in
            guard let self = self else {
                return
            }

            self.modalTransition.perform(
                .options(account: self.accountHandle.value, delegate: self),
                by: .presentWithoutNavigationController
            )
        }

        rightBarButtonItems = [optionsBarButtonItem]
    }

    private func setPageBarItems() {
        items = [
            AssetListPageBarItem(screen: assetListScreen),
            NFTListPageBarItem(screen: nftListScreen),
            TransactionListPageBarItem(screen: transactionListScreen)
        ]
    }

    private func addTitleView() {
        accountTitleView.customize(AccountNameViewSmallTheme())
        accountTitleView.bindData(AccountNameViewModel(account: accountHandle.value))

        navigationItem.titleView = accountTitleView
    }
}

extension AccountDetailViewController: OptionsViewControllerDelegate {
    func optionsViewControllerDidCopyAddress(_ optionsViewController: OptionsViewController) {
        log(ReceiveCopyEvent(address: accountHandle.value.address))
        UIPasteboard.general.string = accountHandle.value.address
        bannerController?.presentInfoBanner("qr-creation-copied".localized)
    }

    func optionsViewControllerDidOpenRekeying(_ optionsViewController: OptionsViewController) {
        open(
            .rekeyInstruction(account: accountHandle.value),
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            )
        )
    }
    
    func optionsViewControllerDidViewRekeyInformation(_ optionsViewController: OptionsViewController) {
        guard let authAddress = accountHandle.value.authAddress else {
            return
        }

        let draft = QRCreationDraft(address: authAddress, mode: .address, title: accountHandle.value.name)
        open(.qrGenerator(title: "options-auth-account".localized, draft: draft, isTrackable: true), by: .present)
    }

    func optionsViewControllerDidViewPassphrase(_ optionsViewController: OptionsViewController) {
        guard let session = session else {
            return
        }

        if !session.hasPassword() {
            presentPassphraseView()
            return
        }

        if localAuthenticator.localAuthenticationStatus != .allowed {
            let controller = open(
                .choosePassword(mode: .confirm(flow: .viewPassphrase), flow: nil),
                by: .present
            ) as? ChoosePasswordViewController
            controller?.delegate = self
            return
        }

        localAuthenticator.authenticate { [weak self] error in
            guard let self = self,
                  error == nil else {
                return
            }

            self.presentPassphraseView()
        }
    }

    private func presentPassphraseView() {
        modalTransition.perform(
            .passphraseDisplay(address: accountHandle.value.address),
            by: .present
        )
    }

    func optionsViewControllerDidRenameAccount(_ optionsViewController: OptionsViewController) {
        open(
            .editAccount(account: accountHandle.value, delegate: self),
            by: .present
        )
    }
    
    func optionsViewControllerDidRemoveAsset(_ optionsViewController: OptionsViewController) {
        let controller = open(.removeAsset(account: accountHandle.value), by: .present) as? ManageAssetsViewController
        controller?.delegate = self
    }

    func optionsViewControllerDidRemoveAccount(_ optionsViewController: OptionsViewController) {
        displayRemoveAccountAlert()
    }

    private func displayRemoveAccountAlert() {
        let account = accountHandle.value
        let configurator = BottomWarningViewConfigurator(
            image: "icon-trash-red".uiImage,
            title: "options-remove-account".localized,
            description: .plain(
                account.isWatchAccount()
                ? "options-remove-watch-account-explanation".localized
                : "options-remove-main-account-explanation".localized
            ),
            primaryActionButtonTitle: "title-remove".localized,
            secondaryActionButtonTitle: "title-keep".localized,
            primaryAction: { [weak self] in
                self?.removeAccount()
            }
        )

        modalTransition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
    }

    private func removeAccount() {
        sharedDataController.resetPollingAfterRemoving(accountHandle.value)
        eventHandler?(.didRemove)
    }
}

extension AccountDetailViewController: ChoosePasswordViewControllerDelegate {
    func choosePasswordViewController(
        _ choosePasswordViewController: ChoosePasswordViewController,
        didConfirmPassword isConfirmed: Bool
    ) {
        choosePasswordViewController.dismissScreen()
        if isConfirmed {
            presentPassphraseView()
        }
    }
}

extension AccountDetailViewController: EditAccountViewControllerDelegate {
    func editAccountViewControllerDidTapDoneButton(_ viewController: EditAccountViewController) {
        accountTitleView.bindData(AccountNameViewModel(account: accountHandle.value))
    }
}

extension AccountDetailViewController: ManageAssetsViewControllerDelegate {
    func manageAssetsViewController(
        _ assetRemovalViewController: ManageAssetsViewController,
        didRemove assetDetail: AssetInformation,
        from account: Account
    ) {
        assetListScreen.removeAsset(assetDetail)
    }
}

extension AccountDetailViewController {
    struct AssetListPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = AccountDetailPageBarItemID.assets.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: "accounts-title-assets".localized)
            self.screen = screen
        }
    }

    struct NFTListPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = AccountDetailPageBarItemID.nfts.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: "accounts-title-nfts".localized)
            self.screen = screen
        }
    }

    struct TransactionListPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = AccountDetailPageBarItemID.transactions.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: "accounts-title-history".localized)
            self.screen = screen
        }
    }


    enum AccountDetailPageBarItemID: String {
        case assets
        case nfts
        case transactions
    }
}

extension AccountDetailViewController {
    enum Event {
        case didRemove
    }
}
