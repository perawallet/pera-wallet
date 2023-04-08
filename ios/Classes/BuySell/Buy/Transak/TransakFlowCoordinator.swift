// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   TransakFlowCoordinator.swift

import Foundation
import UIKit

final class TransakFlowCoordinator:
    TransactionControllerDelegate,
    SharedDataControllerObserver {
    private lazy var currencyFormatter = CurrencyFormatter()
    private lazy var transactionController = TransactionController(
        api: api,
        sharedDataController: sharedDataController,
        bannerController: bannerController,
        analytics: analytics
    )

    private var transitionToAssetActionConfirmation: BottomSheetTransition?
    private var transitionToOptInAsset: BottomSheetTransition?
    private var transitionToLedgerConnection: BottomSheetTransition?
    private var transitionToLedgerConnectionIssuesWarning: BottomSheetTransition?
    private var transitionToSignWithLedgerProcess: BottomSheetTransition?

    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?

    private unowned let presentingScreen: UIViewController
    private let api: ALGAPI
    private let sharedDataController: SharedDataController
    private let bannerController: BannerController
    private let loadingController: LoadingController
    private let analytics: ALGAnalytics

    private var selectedAccountAddress: PublicKey?

    private var usdcAssetID: AssetID {
        return ALGAsset.usdcAssetID(api.network)
    }

    init(
        presentingScreen: UIViewController,
        api: ALGAPI,
        sharedDataController: SharedDataController,
        bannerController: BannerController,
        loadingController: LoadingController,
        analytics: ALGAnalytics
    ) {
        self.presentingScreen = presentingScreen
        self.api = api
        self.sharedDataController = sharedDataController
        self.bannerController = bannerController
        self.loadingController = loadingController
        self.analytics = analytics
    }

    deinit {
        sharedDataController.remove(self)
    }
}

// MARK: SharedDataControllerObserver
extension TransakFlowCoordinator {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event,
           let address = selectedAccountAddress,
           let upToDateAccount = getUpToDateAccount(for: address) {

            let optedInStatus = sharedDataController.hasOptedIn(
                assetID: usdcAssetID,
                for: upToDateAccount.value
            )
            guard optedInStatus == .optedIn else { return }

            openDappDetailAfterOptingIn(to: upToDateAccount)
        }
    }
}

extension TransakFlowCoordinator {
    private func openDappDetailAfterOptingIn(to account: AccountHandle) {
        finishObservingOptInUpdates()

        loadingController.stopLoading()

        /// <todo>
        /// This code should be refactored after routing refactor.
        /// Firstly it dismisses the opt-in sheet, after that it pushes the `TransakDappDetailScreen` from
        /// the visible screen (`TransakIntroductionScreen` or `TransakAccountSelectionScreen`).
        let visibleScreen = presentingScreen.findVisibleScreen()
        visibleScreen.dismiss(animated: true) {
            let visibleScreen = self.presentingScreen.findVisibleScreen()
            self.openDappDetail(
                account: account,
                from: visibleScreen
            )
        }
    }
}

extension TransakFlowCoordinator {
    /// When an account is not passed to the function, the account selection flow is triggered within the overall flow.
    func launch(_ account: AccountHandle? = nil) {
        openIntroduction(account)
    }
}

extension TransakFlowCoordinator {
    private func openIntroduction(_ account: AccountHandle?) {
        let screen = presentingScreen.open(
            .transakIntroduction,
            by: .present
        ) as? TransakIntroductionScreen
        screen?.eventHandler = {
            [weak self, weak screen] event in
            guard let self,
                  let screen else { return }

            switch event {
            case .performCloseAction:
                self.presentingScreen.dismiss(animated: true)
            case .performPrimaryAction:
                guard self.isAvailable else {
                    self.presentNotAvailableAlert(on: screen)
                    return
                }

                guard let account = account else {
                    self.openAccountSelection(from: screen)
                    return
                }

                self.openDappDetailIfPossible(
                    account: account,
                    from: screen
                )
            }
        }
    }
}

extension TransakFlowCoordinator {
    /// <note>
    /// In staging app, the Transak is always enabled, but in store app, it is enabled only
    /// on mainnet.
    private var isAvailable: Bool {
        return !ALGAppTarget.current.isProduction || !api.isTestNet
    }

    private func presentNotAvailableAlert(on screen: UIViewController) {
        screen.displaySimpleAlertWith(
            title: "title-not-available".localized,
            message: "transak-not-available-description".localized
        )
    }
}

extension TransakFlowCoordinator {
    private func openAccountSelection(from screen: UIViewController) {
        let accountSelectionScreen = Screen.transakAccountSelection {
            [weak self] event, screen in
            guard let self else { return }

            switch event {
            case .didSelect(let selectedAccount):
                self.openDappDetailIfPossible(
                    account: selectedAccount,
                    from: screen
                )
            default:
                break
            }
        }

        screen.open(
            accountSelectionScreen,
            by: .push
        )
    }

    private func openDappDetailIfPossible(
        account: AccountHandle,
        from screen: UIViewController
    ) {
        let upToDateAccount = getUpToDateAccount(for: account.value.address)
        guard let upToDateAccount else {
            presentAccountNotFoundError()
            return
        }

        if hasPendingOptInRequest(upToDateAccount) {
            presentTryingToActForAssetWithPendingOptInRequestError(upToDateAccount)
            return
        }

        if hasPendingOptOutRequest(upToDateAccount) {
            presentTryingToActForAssetWithPendingOptOutRequestError(upToDateAccount)
            return
        }

        let isOptedInToUSDC = isOptedInToUSDC(upToDateAccount)
        guard isOptedInToUSDC else {
            self.openAssetActionConfirmation(
                account: upToDateAccount,
                from: screen
            )
            return
        }

        openDappDetail(
            account: upToDateAccount,
            from: screen
        )
    }
}

extension TransakFlowCoordinator {
    private func hasPendingOptInRequest(_ account: AccountHandle) -> Bool {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        let hasPendingOptInRequest = monitor.hasPendingOptInRequest(
            assetID: usdcAssetID,
            for: account.value
        )
        return hasPendingOptInRequest
    }

    private func hasPendingOptOutRequest(_ account: AccountHandle) -> Bool {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        let hasPendingOptOutRequest = monitor.hasPendingOptOutRequest(
            assetID: usdcAssetID,
            for: account.value
        )
        return hasPendingOptOutRequest
    }

    private func presentTryingToActForAssetWithPendingOptInRequestError(_ account: AccountHandle) {
        let accountName = account.value.primaryDisplayName
        bannerController.presentErrorBanner(
            title: "title-error".localized,
            message: "ongoing-opt-in-request-description".localized(params: accountName)
        )
    }

    private func presentTryingToActForAssetWithPendingOptOutRequestError(_ account: AccountHandle) {
        let accountName = account.value.primaryDisplayName
        bannerController.presentErrorBanner(
            title: "title-error".localized,
            message: "ongoing-opt-out-request-description".localized(params: accountName)
        )
    }
}

extension TransakFlowCoordinator {
    private func presentAccountNotFoundError() {
        bannerController.presentErrorBanner(
            title: "notifications-account-not-found-title".localized,
            message: "notifications-account-not-found-description".localized
        )
    }
}

extension TransakFlowCoordinator {
    private func openAssetActionConfirmation(
        account: AccountHandle,
        from screen: UIViewController
    ) {
        let draft = AssetAlertDraft(
            account: account.value,
            assetId: usdcAssetID,
            asset: nil,
            title: "asset-support-your-add-title-singular".localized,
            detail: "asset-support-your-add-message".localized,
            actionTitle: "opt-in-to-usdc".localized,
            cancelTitle: "title-close".localized
        )
        let assetActionConfirmationScreen = Screen.assetActionConfirmation(
            assetAlertDraft: draft,
            delegate: self
        )

        transitionToAssetActionConfirmation = BottomSheetTransition(presentingViewController: screen)
        transitionToAssetActionConfirmation?.perform(
            assetActionConfirmationScreen,
            by: .presentWithoutNavigationController
        )
    }
}

extension TransakFlowCoordinator: AssetActionConfirmationViewControllerDelegate {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmAction asset: AssetDecoration
    ) {
        guard let account = assetActionConfirmationViewController.draft.account else {
            assertionFailure("Draft's account should be set.")
            return
        }

        openOptInAsset(
            account: account,
            asset: asset
        )
    }
}

extension TransakFlowCoordinator {
    private func openOptInAsset(
        account: Account,
        asset: AssetDecoration
    ) {
        let draft = OptInAssetDraft(
            account: account,
            asset: asset
        )
        let screen = Screen.optInAsset(draft: draft) {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .performApprove:
                self.continueToOptInAsset(
                    asset: asset,
                    account: account
                )
            case .performClose:
                self.cancelOptInAsset()
            }
        }

        let visibleScreen = presentingScreen.findVisibleScreen()
        transitionToOptInAsset = BottomSheetTransition(presentingViewController: visibleScreen)
        transitionToOptInAsset?.perform(
            screen,
            by: .present
        )
    }

    private func continueToOptInAsset(
        asset: AssetDecoration,
        account: Account
    ) {
        if !self.transactionController.canSignTransaction(for: account) { return }

        loadingController.startLoadingWithMessage("title-loading".localized)

        let monitor = sharedDataController.blockchainUpdatesMonitor
        let request = OptInBlockchainRequest(
            account: account,
            asset: asset
        )
        monitor.startMonitoringOptInUpdates(request)

        let assetTransactionDraft = AssetTransactionSendDraft(
            from: account,
            assetIndex: asset.id
        )

        transactionController.delegate = self
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)

        if account.requiresLedgerConnection() {
            openLedgerConnection()

            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }

    private func cancelOptInAsset() {
        let visibleScreen = presentingScreen.findVisibleScreen()
        visibleScreen.dismiss(animated: true)
    }
}

extension TransakFlowCoordinator {
    private func openLedgerConnection() {
        let visibleScreen = presentingScreen.findVisibleScreen()
        let transition = BottomSheetTransition(
            presentingViewController: visibleScreen,
            interactable: false
        )

        let eventHandler: LedgerConnectionScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancel:
                self.transactionController.stopBLEScan()
                self.transactionController.stopTimer()
                self.cancelMonitoringOptInUpdates(for: self.transactionController)

                self.ledgerConnectionScreen?.dismissScreen()
                self.ledgerConnectionScreen = nil

                self.loadingController.stopLoading()
            }
        }

        ledgerConnectionScreen = transition.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )

        transitionToLedgerConnection = transition
    }
}

extension TransakFlowCoordinator {
    private func openLedgerConnectionIssues() {
        let visibleScreen = presentingScreen.findVisibleScreen()
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        transition.perform(
            .bottomWarning(
                configurator: BottomWarningViewConfigurator(
                    image: "icon-info-green".uiImage,
                    title: "ledger-pairing-issue-error-title".localized,
                    description: .plain("ble-error-fail-ble-connection-repairing".localized),
                    secondaryActionButtonTitle: "title-ok".localized
                )
            ),
            by: .presentWithoutNavigationController
        )

        transitionToLedgerConnectionIssuesWarning = transition
    }
}

extension TransakFlowCoordinator {
    private func openSignWithLedgerProcess(
        transactionController: TransactionController,
        ledgerDeviceName: String
    ) {
        let visibleScreen = presentingScreen.findVisibleScreen()
        let transition = BottomSheetTransition(
            presentingViewController: visibleScreen,
            interactable: false
        )

        let draft = SignWithLedgerProcessDraft(
            ledgerDeviceName: ledgerDeviceName,
            totalTransactionCount: 1
        )
        let eventHandler: SignWithLedgerProcessScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .performCancelApproval:
                transactionController.stopBLEScan()
                transactionController.stopTimer()

                self.signWithLedgerProcessScreen?.dismissScreen()
                self.signWithLedgerProcessScreen = nil

                self.cancelMonitoringOptInUpdates(for: transactionController)

                self.loadingController.stopLoading()
            }
        }
        signWithLedgerProcessScreen = transition.perform(
            .signWithLedgerProcess(
                draft: draft,
                eventHandler: eventHandler
            ),
            by: .present
        ) as? SignWithLedgerProcessScreen

        transitionToSignWithLedgerProcess = transition
    }
}

extension TransakFlowCoordinator {
    private func openDappDetail(
        account: AccountHandle,
        from screen: UIViewController
    ) {
        screen.open(
            .transakDappDetail(account: account),
            by: .push
        )
    }
}

// MARK: TransactionControllerDelegate
extension TransakFlowCoordinator {
    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        cancelMonitoringOptInUpdates(for: transactionController)

        loadingController.stopLoading()

        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        case let .network(apiError):
            bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: apiError.prettyDescription
            )
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedTransaction error: HIPTransactionError
    ) {
        cancelMonitoringOptInUpdates(for: transactionController)

        loadingController.stopLoading()

        switch error {
        case let .network(apiError):
            bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: apiError.prettyDescription
            )
        default:
            bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: error.debugDescription
            )
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        /// <warning>
        /// Don't stop the loading process here, as it is managed within the observing method of the `SharedDataControllerObserver.`

        guard let account = transactionController.assetTransactionDraft?.from else {
            assertionFailure("assetTransactionDraft's shouldn't be nil.")
            return
        }

        startObservingOptInUpdates(for: account)
    }

    private func displayTransactionError(
        from transactionError: TransactionError
    ) {
        switch transactionError {
        case let .minimumAmount(amount):
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let amountText = currencyFormatter.format(amount.toAlgos)

            bannerController.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(
                    params: amountText.someString
                )
            )
        case .invalidAddress:
            bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: "send-algos-receiver-address-validation".localized
            )
        case let .sdkError(error):
            bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: error.debugDescription
            )
        case .ledgerConnection:
            ledgerConnectionScreen?.dismiss(animated: true) {
                [weak self] in
                guard let self else { return }

                self.ledgerConnectionScreen = nil
                self.openLedgerConnectionIssues()
            }
        default:
            break
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didRequestUserApprovalFrom ledger: String
    ) {
        ledgerConnectionScreen?.dismiss(animated: true) {
            [weak self] in
            guard let self else { return }

            self.ledgerConnectionScreen = nil

            self.openSignWithLedgerProcess(
                transactionController: transactionController,
                ledgerDeviceName: ledger
            )
        }
    }
    
    func transactionControllerDidResetLedgerOperation(
        _ transactionController: TransactionController
    ) {
        ledgerConnectionScreen?.dismissScreen()
        ledgerConnectionScreen = nil

        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil

        cancelMonitoringOptInUpdates(for: transactionController)

        loadingController.stopLoading()
    }

    func transactionControllerDidFailToSignWithLedger(
        _ transactionController: TransactionController
    ) {}

    func transactionControllerDidRejectedLedgerOperation(
        _ transactionController: TransactionController
    ) {}

    func transactionController(
        _ transactionController: TransactionController,
        didCompletedTransaction id: TransactionID
    ) {}

    func transactionControllerDidResetLedgerOperationOnSuccess(
        _ transactionController: TransactionController
    ) {
        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil
    }
}

extension TransakFlowCoordinator {
    private func startObservingOptInUpdates(for account: Account) {
        selectedAccountAddress = account.address

        sharedDataController.add(self)
    }

    private func finishObservingOptInUpdates() {
        selectedAccountAddress = nil

        sharedDataController.remove(self)
    }

    private func cancelMonitoringOptInUpdates(
        for transactionController: TransactionController
    ) {
        if let assetID = getAssetID(from: transactionController),
           let account = getAccount(from: transactionController) {
            let monitor = sharedDataController.blockchainUpdatesMonitor
            monitor.cancelMonitoringOptInUpdates(
                forAssetID: assetID,
                for: account
            )
        }
    }

    private func getAssetID(
        from transactionController: TransactionController
    ) -> AssetID? {
        return transactionController.assetTransactionDraft?.assetIndex
    }

    private func getAccount(
        from transactionController: TransactionController
    ) -> Account? {
        return transactionController.assetTransactionDraft?.from
    }
}

extension TransakFlowCoordinator {
    private func isOptedInToUSDC(_ account: AccountHandle) -> Bool {
        return account.value.isOptedIn(to: usdcAssetID)
    }

    private func getUpToDateAccount(for address: PublicKey) -> AccountHandle? {
        return sharedDataController.accountCollection[address]
    }
}
