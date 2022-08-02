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
import MacaroonUIKit
import UIKit

final class AccountDetailViewController: PageContainer {
    typealias EventHandler = (Event) -> Void
    
    var eventHandler: EventHandler?
    
    private lazy var theme = Theme()
    private lazy var modalTransition = BottomSheetTransition(presentingViewController: self)

    private lazy var assetListScreen = AccountAssetListViewController(
        accountHandle: accountHandle,
        copyToClipboardController: copyToClipboardController,
        configuration: configuration
    )

    private lazy var collectibleListScreen = AccountCollectibleListViewController(
        account: accountHandle,
        copyToClipboardController: copyToClipboardController,
        configuration: configuration
    )
    
    private lazy var transactionListScreen = AccountTransactionListViewController(
        draft: AccountTransactionListing(accountHandle: accountHandle),
        copyToClipboardController: copyToClipboardController,
        configuration: configuration
    )

    private lazy var buyAlgoFlowCoordinator = BuyAlgoFlowCoordinator(presentingScreen: self)
    private lazy var sendTransactionFlowCoordinator =
    SendTransactionFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController,
        account: accountHandle.value
    )
    private lazy var receiveTransactionFlowCoordinator =
    ReceiveTransactionFlowCoordinator(presentingScreen: self, account: accountHandle.value)

    private lazy var localAuthenticator = LocalAuthenticator()

    private lazy var accountNamePreviewTitleView = AccountNamePreviewView()
    private lazy var accountActionsMenuActionView = FloatingActionItemButton(hasTitleLabel: false)

    private var accountHandle: AccountHandle

    private let copyToClipboardController: CopyToClipboardController

    init(
        accountHandle: AccountHandle,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.accountHandle = accountHandle
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setPageBarItems()
        addTitleView()

        if !accountHandle.value.isWatchAccount() {
            addAccountActionsMenuAction()
            updateSafeAreaWhenAccountActionsMenuActionWasAdded()
        }
    }

    override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(animated)
        switchToHighlightedNavigationBarAppearance()
    }

    override func viewWillDisappear(
        _ animated: Bool
    ) {
        super.viewWillDisappear(animated)

        if presentedViewController == nil {
            switchToDefaultNavigationBarAppearance()
        }
    }

    override func configureNavigationBarAppearance() {
        addOptionsBarButton()
    }

    override func customizePageBarAppearance() {
        super.customizePageBarAppearance()

        pageBar.customizeAppearance([
            .backgroundColor(AppColors.Shared.Helpers.heroBackground)
        ])
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func linkInteractors() {
        super.linkInteractors()
        linkInteractors(assetListScreen)
    }

    override func itemDidSelect(
        _ index: Int
    ) {
        endEditing()
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
            case .manageAssets(let isWatchAccount):
                self.assetListScreen.endEditing()

                self.modalTransition.perform(
                    .managementOptions(
                        managementType: isWatchAccount ? .watchAccountAssets : .assets,
                        delegate: self
                    ),
                    by: .present
                )
            case .addAsset:
                self.assetListScreen.endEditing()

                let controller = self.open(.addAsset(account: self.accountHandle.value), by: .push) as? AssetAdditionViewController
                controller?.delegate = self
            case .buyAlgo:
                self.assetListScreen.endEditing()

                self.buyAlgoFlowCoordinator.launch()
            case .send:
                self.assetListScreen.endEditing()

                self.sendTransactionFlowCoordinator.launch()
            case .address:
                self.assetListScreen.endEditing()

                self.receiveTransactionFlowCoordinator.launch()
            case .more:
                self.assetListScreen.endEditing()

                self.presentOptionsScreen()
            }
        }
    }
}

extension AccountDetailViewController: TransactionOptionsScreenDelegate {
    func transactionOptionsScreenDidBuyAlgo(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [weak self] in
            self?.buyAlgoFlowCoordinator.launch()
        }
    }

    func transactionOptionsScreenDidSend(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [weak self] in
            self?.sendTransactionFlowCoordinator.launch()
        }
    }

    func transactionOptionsScreenDidReceive(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [weak self] in
            self?.receiveTransactionFlowCoordinator.launch()
        }
    }

    func transactionOptionsScreenDidMore(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [weak self] in
            self?.presentOptionsScreen()
        }
    }
}

extension AccountDetailViewController {
    private func addOptionsBarButton() {
        let optionsBarButtonItem = ALGBarButtonItem(kind: .account(accountHandle.value.typeImage)) { [weak self] in
            guard let self = self else {
                return
            }

            self.endEditing()

            self.presentOptionsScreen()
        }

        rightBarButtonItems = [optionsBarButtonItem]
    }

    private func presentOptionsScreen() {
        modalTransition.perform(
            .options(account: self.accountHandle.value, delegate: self),
            by: .presentWithoutNavigationController
        )
    }

    private func setPageBarItems() {
        items = [
            AssetListPageBarItem(screen: assetListScreen),
            CollectibleListPageBarItem(screen: collectibleListScreen),
            TransactionListPageBarItem(screen: transactionListScreen)
        ]
    }

    private func addTitleView() {
        accountNamePreviewTitleView.customize(AccountNamePreviewViewTheme())
        accountNamePreviewTitleView.bindData(
            AccountNamePreviewViewModel(
                account: accountHandle.value,
                with: .center
            )
        )

        accountNamePreviewTitleView.addGestureRecognizer(
            UILongPressGestureRecognizer(
                target: self,
                action: #selector(didLongPressToAccountNamePreviewTitleView)
            )
        )

        navigationItem.titleView = accountNamePreviewTitleView
    }

    private func addAccountActionsMenuAction() {
        accountActionsMenuActionView.image = theme.accountActionsMenuActionIcon

        view.addSubview(accountActionsMenuActionView)

        accountActionsMenuActionView.snp.makeConstraints {
            let safeAreaBottom = view.compactSafeAreaInsets.bottom
            let bottom = safeAreaBottom + theme.accountActionsMenuActionBottomPadding

            $0.fitToSize(theme.accountActionsMenuActionSize)
            $0.trailing == theme.accountActionsMenuActionTrailingPadding
            $0.bottom == bottom
        }

        accountActionsMenuActionView.addTouch(
            target: self,
            action: #selector(openAccountActionsMenu)
        )
    }

    private func updateSafeAreaWhenAccountActionsMenuActionWasAdded() {
        let listSafeAreaBottom =
            theme.spacingBetweenListAndAccountActionsMenuAction +
            theme.accountActionsMenuActionSize.h +
            theme.accountActionsMenuActionBottomPadding
        assetListScreen.additionalSafeAreaInsets.bottom = listSafeAreaBottom
        collectibleListScreen.additionalSafeAreaInsets.bottom = listSafeAreaBottom
        transactionListScreen.additionalSafeAreaInsets.bottom = listSafeAreaBottom
    }
}

extension AccountDetailViewController {
    @objc
    private func didLongPressToAccountNamePreviewTitleView(
        _ gesture: UILongPressGestureRecognizer
    ) {
        guard gesture.state == .began else {
            return
        }

        copyToClipboardController.copyAddress(accountHandle.value)
    }

    @objc
    private func openAccountActionsMenu() {
        view.endEditing(true)

        self.modalTransition.perform(
            .transactionOptions(delegate: self),
            by: .presentWithoutNavigationController
        )
    }
}

extension AccountDetailViewController: OptionsViewControllerDelegate {
    func optionsViewControllerDidCopyAddress(_ optionsViewController: OptionsViewController) {
        log(ReceiveCopyEvent(address: accountHandle.value.address))
        copyToClipboardController.copyAddress(accountHandle.value)
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
        accountNamePreviewTitleView.bindData(
            AccountNamePreviewViewModel(
                account: accountHandle.value,
                with: .center
            )
        )

        eventHandler?(.didEdit)
    }
}

extension AccountDetailViewController: AssetAdditionViewControllerDelegate {
    func assetAdditionViewController(_ assetAdditionViewController: AssetAdditionViewController, didAdd asset: AssetDecoration) {
        let standardAsset = StandardAsset(asset: ALGAsset(id: asset.id), decoration: asset)
        standardAsset.state = .pending(.add)
        assetListScreen.addAsset(standardAsset)
    }
}

extension AccountDetailViewController: ManageAssetsViewControllerDelegate {
    func manageAssetsViewController(
        _ assetRemovalViewController: ManageAssetsViewController,
        didRemove asset: StandardAsset
    ) {
        assetListScreen.removeAsset(asset)
    }

    func manageAssetsViewController(
        _ assetRemovalViewController: ManageAssetsViewController,
        didRemove asset: CollectibleAsset
    ) {
        NotificationCenter.default.post(
            name: CollectibleListLocalDataController.didRemoveCollectible,
            object: self,
            userInfo: [
                CollectibleListLocalDataController.accountAssetPairUserInfoKey: (accountHandle.value, asset)
            ]
        )
    }
}

extension AccountDetailViewController: ManagementOptionsViewControllerDelegate {
    func managementOptionsViewControllerDidTapSort(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {
        let eventHandler: SortAccountAssetListViewController.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            self.dismiss(animated: true) {
                [weak self] in
                guard let self = self else { return }

                switch event {
                case .didComplete: self.assetListScreen.reload()
                }
            }
        }

        open(
            .sortAccountAsset(
                dataController: SortAccountAssetListLocalDataController(
                    session: session!,
                    sharedDataController: sharedDataController
                ),
                eventHandler: eventHandler
            ),
            by: .present
        )
    }

    func managementOptionsViewControllerDidTapFilter(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {}

    func managementOptionsViewControllerDidTapRemove(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {
        let dataController = ManageAssetsListLocalDataController(
            account: accountHandle.value,
            sharedDataController: sharedDataController
        )

        let controller = open(
            .removeAsset(dataController: dataController),
            by: .present
        ) as? ManageAssetsViewController
        controller?.delegate = self
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

    struct CollectibleListPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = AccountDetailPageBarItemID.collectibles.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: "accounts-title-collectibles".localized)
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
        case collectibles
        case transactions
    }
}

extension AccountDetailViewController {
    enum Event {
        case didEdit
        case didRemove
    }
}
