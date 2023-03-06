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

//   ScanQRFlowCoordinator.swift

import Foundation
import UIKit

/// <todo>
/// This should be removed after the routing refactor.
final class ScanQRFlowCoordinator:
    QRScannerViewControllerDelegate,
    SelectAccountViewControllerDelegate,
    TransactionControllerDelegate {
    private lazy var currencyFormatter = CurrencyFormatter()
    private lazy var accountExportCoordinator = AccountExportFlowCoordinator(
        presentingScreen: presentingScreen,
        api: api,
        session: session
    )

    private lazy var transactionController = TransactionController(
        api: api,
        sharedDataController: sharedDataController,
        bannerController: bannerController,
        analytics: analytics
    )

    private var assetConfirmationTransition: BottomSheetTransition?
    private var accountQRTransition: BottomSheetTransition?
    private var optInRequestTransition: BottomSheetTransition?

    private var ledgerApprovalViewController: LedgerApprovalViewController?

    private unowned let presentingScreen: UIViewController
    private let analytics: ALGAnalytics
    private let api: ALGAPI
    private let bannerController: BannerController
    private let loadingController: LoadingController
    private let session: Session
    private let sharedDataController: SharedDataController

    init(
        analytics: ALGAnalytics,
        api: ALGAPI,
        bannerController: BannerController,
        loadingController: LoadingController,
        presentingScreen: UIViewController,
        session: Session,
        sharedDataController: SharedDataController
    ) {
        self.analytics = analytics
        self.api = api
        self.bannerController = bannerController
        self.loadingController = loadingController
        self.presentingScreen = presentingScreen
        self.session = session
        self.sharedDataController = sharedDataController
    }
}

extension ScanQRFlowCoordinator {
    func launch() {
        let screen: Screen = .qrScanner(canReadWCSession: true)
        let qrScannerViewController = presentingScreen.open(
            screen,
            by: .present
        ) as? QRScannerViewController
        qrScannerViewController?.delegate = self
    }
}

/// <mark>
/// QRScannerViewControllerDelegate
extension ScanQRFlowCoordinator {
    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didRead qrText: QRText,
        completionHandler: EmptyHandler?
    ) {
        switch qrText.mode {
        case .address:
            qrScanner(
                controller,
                accountAddressWasDetected: qrText
            )
        case .algosRequest:
            qrScanner(
                controller,
                algosTransactionWasDetected: qrText
            )
        case .assetRequest:
            qrScanner(
                controller,
                assetTransactionWasDetected: qrText
            )
        case .mnemonic:
            qrScanner(
                controller,
                accountMnemonicWasDetected: qrText
            )
        case .optInRequest:
            qrScanner(
                controller,
                assetOptInWasDetected: qrText
            )
        }
    }

    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didFail error: QRScannerError,
        completionHandler: EmptyHandler?
    ) {
        let visibleScreen = presentingScreen.findVisibleScreen()
        visibleScreen.displaySimpleAlertWith(
            title: "title-error".localized,
            message: "qr-scan-should-scan-valid-qr".localized
        ) { _ in
            if let handler = completionHandler {
                handler()
            }
        }
    }

    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didRead qrExportInformations: QRExportInformations,
        completionHandler: EmptyHandler?
    ) {
        accountExportCoordinator.populate(qrExportInformations: qrExportInformations)
        accountExportCoordinator.launch()
    }
}

/// <mark>
/// SelectAccountViewControllerDelegate
extension ScanQRFlowCoordinator {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for draft: SelectAccountDraft
    ) {
        switch draft.transactionAction {
        case .optIn(let assetID):
            requestOptingInToAsset(
                assetID,
                to: account
            )
        default:
            if draft.requiresAssetSelection {
                openAssetSelection(
                    with: account,
                    on: selectAccountViewController,
                    receiver: draft.receiver
                )
                return
            }

            sendTransaction(
                from: selectAccountViewController,
                for: account,
                with: draft.transactionDraft
            )
        }
    }

    private func requestOptingInToAsset(
        _ assetID: AssetID,
        to account: Account
    ) {
        if account.containsAsset(assetID) {
            bannerController.presentInfoBanner("asset-you-already-own-message".localized)
            return
        }

        loadingController.startLoadingWithMessage("title-loading".localized)

        api.fetchAssetDetails(
            AssetFetchQuery(ids: [assetID]),
            queue: .main,
            ignoreResponseOnCancelled: false
        ) { [weak self] response in
            guard let self = self else {
                return
            }

            self.loadingController.stopLoading()

            switch response {
            case let .success(assetResponse):
                if assetResponse.results.isEmpty {
                    self.bannerController.presentErrorBanner(
                        title: "title-error".localized,
                        message: "asset-confirmation-not-found".localized
                    )
                    return
                }

                if let asset = assetResponse.results.first {
                    self.openOptInAsset(
                        asset: asset,
                        account: account
                    )
                }
            case .failure:
                self.bannerController.presentErrorBanner(
                    title: "title-error".localized,
                    message: "asset-confirmation-not-fetched".localized
                )
            }
        }
    }

    private func openOptInAsset(
        asset: AssetDecoration,
        account: Account
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
        optInRequestTransition = BottomSheetTransition(presentingViewController: visibleScreen)

        optInRequestTransition?.perform(
            screen,
            by: .present
        )
    }

    private func sendTransaction(
        from selectAccountViewController: SelectAccountViewController,
        for account: Account,
        with transactionDraft: TransactionSendDraft?
    ) {
        guard let transactionDraft = transactionDraft as? SendTransactionDraft else {
            return
        }

        let transactionMode = updateTransactionModeIfNeeded(
            transactionDraft,
            for: account
        )

        var draft = SendTransactionDraft(
            from: account,
            toAccount: transactionDraft.from,
            amount: transactionDraft.amount,
            transactionMode: transactionMode
        )
        draft.note = transactionDraft.note
        draft.lockedNote = transactionDraft.lockedNote

        let screen: Screen = .sendTransaction(draft: draft)

        selectAccountViewController.open(
            screen,
            by: .push
        )
    }

    private func updateTransactionModeIfNeeded(
        _ draft: SendTransactionDraft,
        for account: Account
    ) -> TransactionMode {
        var transactionMode = draft.transactionMode
        switch transactionMode {
        case .asset(let asset):
            if let updatedAsset = account.allAssets.someArray.first(matching: (\.id, asset.id)) {
                transactionMode = .asset(updatedAsset)
            }
        default:
            break
        }

        return transactionMode
    }

    private func openAssetSelection(
        with account: Account,
        on screen: UIViewController,
        receiver: String?
    ) {
        let assetSelectionScreen: Screen = .assetSelection(
            account: account,
            receiver: receiver
        )

        screen.open(
            assetSelectionScreen,
            by: .push
        )
    }
}

/// <todo>
/// Should be handled for each specific transaction separately.
extension ScanQRFlowCoordinator {
    private func continueToOptInAsset(
        asset: AssetDecoration,
        account: Account
    ) {
        let visibleScreen = presentingScreen.findVisibleScreen()

        visibleScreen.dismiss(animated: true) {
            [weak self] in
            guard let self = self else { return }

            guard !account.isWatchAccount() else {
                return
            }

            let monitor = self.sharedDataController.blockchainUpdatesMonitor
            let request = OptInBlockchainRequest(account: account, asset: asset)
            monitor.startMonitoringOptInUpdates(request)

            let assetTransactionDraft = AssetTransactionSendDraft(
                from: account,
                assetIndex: asset.id
            )

            self.loadingController.startLoadingWithMessage("title-loading".localized)

            self.transactionController.delegate = self
            self.transactionController.setTransactionDraft(assetTransactionDraft)
            self.transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)

            if account.requiresLedgerConnection() {
                self.transactionController.initializeLedgerTransactionAccount()
                self.transactionController.startTimer()
            }
        }
    }

    private func cancelOptInAsset() {
        let visibleScreen = presentingScreen.findVisibleScreen()

        visibleScreen.dismiss(animated: true)
    }
}

/// <todo>
/// Should be handled for each specific transaction separately.
extension ScanQRFlowCoordinator {
    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        loadingController.stopLoading()

        if let assetID = transactionController.assetTransactionDraft?.assetIndex,
           let account = transactionController.assetTransactionDraft?.from {
            let monitor = sharedDataController.blockchainUpdatesMonitor
            monitor.cancelMonitoringOptInUpdates(
                forAssetID: assetID,
                for: account
            )
        }

        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            break
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedTransaction error: HIPTransactionError
    ) {
        loadingController.stopLoading()

        if let assetID = transactionController.assetTransactionDraft?.assetIndex,
           let account = transactionController.assetTransactionDraft?.from {
            let monitor = sharedDataController.blockchainUpdatesMonitor
            monitor.cancelMonitoringOptInUpdates(
                forAssetID: assetID,
                for: account
            )
        }

        switch error {
        case let .network(apiError):
            bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: apiError.debugDescription
            )
        default:
            bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: error.localizedDescription
            )
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        loadingController.stopLoading()

        let visibleScreen = presentingScreen.findVisibleScreen()
        visibleScreen.dismissScreen()
    }

    private func displayTransactionError(from transactionError: TransactionError) {
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
            let visibleScreen = presentingScreen.findVisibleScreen()
            let bottomTransition = BottomSheetTransition(presentingViewController: visibleScreen)

            bottomTransition.perform(
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
        default:
            break
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didRequestUserApprovalFrom ledger: String
    ) {
        let visibleScreen = presentingScreen.findVisibleScreen()
        let ledgerApprovalTransition = BottomSheetTransition(
            presentingViewController: visibleScreen,
            interactable: false
        )
        ledgerApprovalViewController = ledgerApprovalTransition.perform(
            .ledgerApproval(mode: .approve, deviceName: ledger),
            by: .present
        )

        ledgerApprovalViewController?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .didCancel:
                self.ledgerApprovalViewController?.dismissScreen()
                self.loadingController.stopLoading()
            }
        }
    }

    func transactionControllerDidResetLedgerOperation(
        _ transactionController: TransactionController
    ) {
        ledgerApprovalViewController?.dismissScreen()
    }

    func transactionController(
        _ transactionController: TransactionController,
        didCompletedTransaction id: TransactionID
    ) { }

    func transactionControllerDidFailToSignWithLedger(
        _ transactionController: TransactionController
    ) { }

    func transactionControllerDidRejectedLedgerOperation(
        _ transactionController: TransactionController
    ) { }
}

extension ScanQRFlowCoordinator {
    private func qrScanner(
        _ qrScannerScreen: QRScannerViewController,
        accountAddressWasDetected qr: QRText
    ) {
        guard let address = qr.address else {
            return
        }

        let eventHandler: QRScanOptionsViewController.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .transaction:
                let draft = SelectAccountDraft(
                    transactionAction: .send,
                    requiresAssetSelection: true,
                    transactionDraft: self.composeAlgosTransactionDraft(from: qr),
                    receiver: address
                )

                self.startSendTransactionFlow(qr, draft: draft)
            case .watchAccount:
                self.openAddWatchAccount(qr)
            case .contact:
                self.openAddContact(qr)
            }
        }

        accountQRTransition = BottomSheetTransition(presentingViewController: presentingScreen)

        accountQRTransition?.perform(
            .qrScanOptions(
                address: address,
                eventHandler: eventHandler
            ),
            by: .present
        )
    }

    private func openAddWatchAccount(_ qr: QRText) {
        if let authenticatedUser = session.authenticatedUser,
           authenticatedUser.hasReachedTotalAccountLimit {
            bannerController.presentErrorBanner(
                title: "user-account-limit-error-title".localized,
                message: "user-account-limit-error-message".localized
            )
            return
        }

        guard let address = qr.address else {
            return
        }

        let screen: Screen = .watchAccountAddition(
            flow: .addNewAccount(
                mode: .add(
                    type: .watch
                )
            ),
            address: address
        )

        presentingScreen.open(
            screen,
            by: .present
        )
    }

    private func openAddContact(_ qr: QRText) {
        let screen: Screen = .addContact(
            address: qr.address,
            name: qr.label
        )

        presentingScreen.open(
            screen,
            by: .present
        )
    }

    private func qrScanner(
        _ qrScannerScreen: QRScannerViewController,
        algosTransactionWasDetected qr: QRText
    ) {
        let draft = SelectAccountDraft(
            transactionAction: .send,
            requiresAssetSelection: false,
            transactionDraft: composeAlgosTransactionDraft(from: qr)
        )

        startSendTransactionFlow(qr, draft: draft)
    }

    private func startSendTransactionFlow(
        _ qr: QRText,
        draft: SelectAccountDraft
    ) {
        let screen: Screen = .accountSelection(
            draft: draft,
            delegate: self
        )

        presentingScreen.open(
            screen,
            by: .present
        )
    }

    private func qrScanner(
        _ qrScannerScreen: QRScannerViewController,
        assetTransactionWasDetected qr: QRText
    ) {
        guard let assetID = qr.asset else {
            return
        }

        guard let asset = findCachedAsset(for: assetID) else {
            let draft = AssetAlertDraft(
                account: nil,
                assetId: assetID,
                asset: nil,
                title: "asset-support-your-add-title".localized,
                detail: "asset-support-your-add-message".localized,
                cancelTitle: "title-close".localized
            )
            let screen: Screen = .assetActionConfirmation(
                assetAlertDraft: draft,
                delegate: nil,
                theme: .secondaryActionOnly
            )

            assetConfirmationTransition =
                BottomSheetTransition(presentingViewController: presentingScreen)
            assetConfirmationTransition?.perform(
                screen,
                by: .presentWithoutNavigationController
            )

            return
        }

        let draft = SelectAccountDraft(
            transactionAction: .send,
            requiresAssetSelection: false,
            transactionDraft: composeAssetTransactionDraft(asset, from: qr)
        )

        let shouldFilterAccount: (Account) -> Bool = {
            !$0.containsAsset(assetID)
        }

        let screen: Screen = .accountSelection(
            draft: draft,
            delegate: self,
            shouldFilterAccount: shouldFilterAccount
        )

        presentingScreen.open(
            screen,
            by: .present
        )
    }

    private func qrScanner(
        _ qrScannerScreen: QRScannerViewController,
        accountMnemonicWasDetected qr: QRText
    ) {
        if let authenticatedUser = session.authenticatedUser,
           authenticatedUser.hasReachedTotalAccountLimit {
            bannerController.presentErrorBanner(
                title: "user-account-limit-error-title".localized,
                message: "user-account-limit-error-message".localized
            )
            return
        }

        guard let mnemonic = qr.mnemonic else {
            return
        }

        let screen: Screen = .accountRecover(
            flow: .addNewAccount(
                mode: .recover(
                    type: .passphrase
                )
            ),
            initialMnemonic: mnemonic
        )

        presentingScreen.open(
            screen,
            by: .present
        )
    }

    private func qrScanner(
        _ qrScannerScreen: QRScannerViewController,
        assetOptInWasDetected qr: QRText
    ) {
        guard let assetID = qr.asset else {
            return
        }

        let draft = SelectAccountDraft(
            transactionAction: .optIn(asset: assetID),
            requiresAssetSelection: false
        )

        let screen: Screen = .accountSelection(
            draft: draft,
            delegate: self
        )

        presentingScreen.open(
            screen,
            by: .present
        )
    }

    private func composeAlgosTransactionDraft(
        from qr: QRText
    ) -> SendTransactionDraft? {
        guard let address = qr.address else {
            return nil
        }

        let amount = qr.amount ?? 0

        var draft = SendTransactionDraft(
            from: Account(address: address, type: .standard),
            transactionMode: .algo
        )
        draft.note = qr.note
        draft.lockedNote = qr.lockedNote
        draft.amount = amount.toAlgos
        return draft
    }

    private func composeAssetTransactionDraft(
        _ asset: Asset,
        from qr: QRText
    ) -> SendTransactionDraft? {
        guard
            let address = qr.address,
            let amount = qr.amount
        else {
            return nil
        }

        var draft = SendTransactionDraft(
            from: Account(address: address, type: .standard),
            transactionMode: .asset(asset)
        )
        draft.amount = amount.assetAmount(fromFraction: asset.decimals)
        draft.note = qr.note
        draft.lockedNote = qr.lockedNote
        return draft
    }

    private func findCachedAsset(
        for id: AssetID
    ) -> Asset? {
        for account in sharedDataController.accountCollection where !account.value.isWatchAccount() {
            if let asset = account.value[id] {
                return asset
            }
        }

        return nil
    }
}
