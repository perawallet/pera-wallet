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

//   SwapAssetFlowCoordinator.swift

import Foundation
import MacaroonUtils
import UIKit

/// <todo>
/// This should be removed after the routing refactor.
final class SwapAssetFlowCoordinator:
    SwapIntroductionAlertItemDelegate,
    SharedDataControllerObserver,
    WeakPublisher {
    var observations: [ObjectIdentifier: WeakObservation] = [:]

    private lazy var displayStore = SwapDisplayStore()
    private lazy var currencyFormatter = CurrencyFormatter()

    private var visibleScreen: UIViewController {
        return presentingScreen.findVisibleScreen()
    }

    private var alertTransitionToSwapIntroduction: AlertUITransition?
    private var transitionToSignWithLedger: BottomSheetTransition?
    private var transitionToLedgerSigningProcess: BottomSheetTransition?
    private var transitionToLedgerConnection: BottomSheetTransition?
    private var transitionToLedgerConnectionIssuesWarning: BottomSheetTransition?
    private var transitionToSlippageToleranceInfo: BottomSheetTransition?
    private var transitionToPriceImpactInfo: BottomSheetTransition?
    private var transitionToExchangeFeeInfo: BottomSheetTransition?
    private var transitionToOptInAsset: BottomSheetTransition?
    private var transitionToAdjustAmount: BottomSheetTransition?
    private var transitionToEditAmount: BottomSheetTransition?
    private var transitionToEditSlippage: BottomSheetTransition?

    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?

    private lazy var assetCacher = MobileAPIAssetCache(
        api: api,
        loadingController: loadingController,
        sharedDataController: sharedDataController
    )

    private var loadingScreen: LoadingScreen?

    private var draft: SwapAssetFlowDraft
    private let dataStore: SwapDataStore
    private let analytics: ALGAnalytics
    private let api: ALGAPI
    private let sharedDataController: SharedDataController
    private let loadingController: LoadingController
    private let bannerController: BannerController
    private unowned let presentingScreen: UIViewController

    init(
        draft: SwapAssetFlowDraft,
        dataStore: SwapDataStore,
        analytics: ALGAnalytics,
        api: ALGAPI,
        sharedDataController: SharedDataController,
        loadingController: LoadingController,
        bannerController: BannerController,
        presentingScreen: UIViewController
    ) {
        self.dataStore = dataStore
        self.analytics = analytics
        self.api = api
        self.sharedDataController = sharedDataController
        self.loadingController = loadingController
        self.bannerController = bannerController
        self.presentingScreen = presentingScreen
        self.draft = draft
    }

    deinit {
        sharedDataController.remove(self)
    }

    func resetDraft() {
        draft.reset()
    }

    func updateDraft(_ draft: SwapAssetFlowDraft) {
        self.draft = draft
    }

    func checkAssetsLoaded() {
        if let userAsset = draft.assetIn {
            self.publish(.didSelectUserAsset(userAsset))
        }

        if let poolAsset = draft.assetOut {
            self.publish(.didSelectPoolAsset(poolAsset))
        }
    }
}

extension SwapAssetFlowCoordinator {
    func launch() {
        dataStore.reset()

        sharedDataController.add(self)

        if !displayStore.isOnboardedToSwap {
            displayStore.isOnboardedToSwap = true

            notifyIsOnboardedToSwapObservers()
        }

        if !displayStore.isConfirmedSwapUserAgreement {
            openSwapIntroduction()
            return
        }

        startSwapFlow()
    }
}

extension SwapAssetFlowCoordinator {
    private func notifyIsOnboardedToSwapObservers() {
        NotificationCenter.default.post(
            name: SwapDisplayStore.isOnboardedToSwapNotification,
            object: nil
        )
    }
}

extension SwapAssetFlowCoordinator {
    private func openSwapIntroduction() {
        let draft = SwapIntroductionDraft(provider: .vestige)

        let screen = Screen.swapIntroduction(draft: draft) {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performPrimaryAction:
                self.displayStore.isConfirmedSwapUserAgreement = true
                self.visibleScreen.dismissScreen {
                    [weak self] in
                    guard let self = self else { return }

                    self.startSwapFlow()
                }
            case .performCloseAction:
                self.visibleScreen.dismissScreen()
            }
        }

        visibleScreen.open(
            screen,
            by: .present
        )
    }
}

extension SwapAssetFlowCoordinator {
    private func startSwapFlow() {
        if draft.account != nil {
            openSwapAsset(by: .present)
            return
        }

        openSelectAccount()
    }
}

extension SwapAssetFlowCoordinator {
    private func openSelectAccount() {
        let screen = Screen.swapAccountSelection(swapAssetFlowCoordinator: self) {
             [unowned self] event, screen in
             switch event {
             case .didSelect(let accountHandle):
                 let account = accountHandle.value
                 self.draft.account = account

                 if !draft.isOptedInToAssetIn {
                     bannerController.presentErrorBanner(
                        title: "title-error".localized,
                        message: "swap-asset-not-opted-in-error".localized
                     )
                     return
                 }

                 if draft.shouldOptInToAssetOut {
                     self.cacheAndOptInToAssetIfNeeded(draft.assetOutID)
                     return
                 }

                 self.openSwapAsset(by: .push)
             case .didOptInToAsset(let asset):
                 let asset = StandardAsset(decoration: asset)
                 self.draft.account?.append(asset)
                 self.openSwapAsset(by: .push)
             }
         }

         presentingScreen.open(
             screen,
             by: .present
         )
    }

    private func cacheAndOptInToAssetIfNeeded(
        _ assetID: AssetID?
    ) {
        guard let assetID else { return }

        assetCacher.eventHandler = {
            [unowned self] event in
            switch event {
            case .didCacheAsset(let asset):
                self.openOptInAsset(asset)
            case .didFailCachingAsset:
                break
            }
        }

        assetCacher.cacheAssetDetail(assetID)
    }
}

extension SwapAssetFlowCoordinator {
    private func openSwapAsset(
        by style: Screen.Transition.Open
    ) {
        guard let account = draft.account else { return }

        let transactionSigner = SwapTransactionSigner(
            api: api,
            analytics: analytics
        )
        let swapControllerDraft = ALGSwapControllerDraft(
            account: account,
            assetIn: draft.assetIn ?? account.algo,
            assetOut: draft.assetOut
        )
        let swapController = ALGSwapController(
            draft: swapControllerDraft,
            api: api,
            transactionSigner: transactionSigner
        )

        swapController.eventHandler = {
            [weak self, weak swapController] event in
            guard let self = self,
                  let swapController = swapController else {
                return
            }

            switch event {
            case .didSignTransaction:
                if account.requiresLedgerConnection(),
                   let signWithLedgerProcessScreen = self.signWithLedgerProcessScreen {
                    signWithLedgerProcessScreen.increaseProgress()

                    if signWithLedgerProcessScreen.isProgressFinished {
                        self.stopLoading()

                        self.visibleScreen.dismissScreen {
                            [weak self] in
                            guard let self = self else { return }

                            self.openSwapLoading(swapController)
                        }
                    }
                }
            case .didSignAllTransactions:
                if account.requiresLedgerConnection() {
                    return
                }

                self.stopLoading()
                self.openSwapLoading(swapController)
            case .didCompleteSwap:
                if let quote = swapController.quote {
                    self.analytics.track(
                        .swapCompleted(
                            quote: quote,
                            parsedTransactions: swapController.parsedTransactions,
                            currency: self.sharedDataController.currency
                        )
                    )
                }

                self.openSwapSuccess(swapController)
            case .didFailTransaction(let txnID):
                guard let quote = swapController.quote else { return }

                if !(self.visibleScreen is LoadingScreen) {
                    return
                }

                swapController.clearTransactions()
                self.stopLoading()

                logFailedSwap(
                    quote: quote,
                    txnID: txnID
                )

                let viewModel = SwapUnexpectedErrorViewModel(quote)
                self.openError(
                    swapController,
                    viewModel: viewModel
                ) {
                    [weak self] in
                    guard let self = self else { return }
                    
                    let screen = self.goBackToScreen(SwapAssetScreen.self)
                    screen?.getSwapQuoteForCurrentInput()
                }
            case .didFailNetwork(let error):
                guard let quote = swapController.quote else { return }

                if !(self.visibleScreen is LoadingScreen) {
                    return
                }

                swapController.clearTransactions()
                self.stopLoading()

                logFailedSwap(
                    quote: quote,
                    error: error
                )

                let viewModel = SwapAPIErrorViewModel(
                    quote: quote,
                    error: error
                )
                self.openError(
                    swapController,
                    viewModel: viewModel
                ) {
                    [weak self] in
                    guard let self = self else { return }

                    let screen = self.goBackToScreen(SwapAssetScreen.self)
                    screen?.getSwapQuoteForCurrentInput()
                }
            case .didCancelTransaction:
                swapController.clearTransactions()
                self.stopLoading()
            case .didFailSigning(let error):
                switch error {
                case .api(let apiError):
                    self.displaySigningError(apiError)
                case .ledger(let ledgerError):                    
                    self.displayLedgerError(
                        swapController: swapController,
                        ledgerError: ledgerError
                    )
                }
            case .didLedgerRequestUserApproval(let ledger, let transactionGroups):
                self.ledgerConnectionScreen?.dismiss(animated: true) {
                    self.ledgerConnectionScreen = nil

                    self.openSignWithLedgerProcess(
                        swapController: swapController,
                        ledger: ledger,
                        transactionGroups: transactionGroups
                    )
                }
            case .didFinishTiming:
                break
            case .didLedgerReset:
                swapController.clearTransactions()
                self.stopLoading()

                if self.visibleScreen is LedgerConnectionScreen {
                    self.ledgerConnectionScreen?.dismissScreen()
                    self.ledgerConnectionScreen = nil
                    return
                }

                if self.visibleScreen is SignWithLedgerProcessScreen {
                    self.signWithLedgerProcessScreen?.dismissScreen()
                    self.signWithLedgerProcessScreen = nil
                }
            case .didLedgerResetOnSuccess:
                break
            case .didLedgerRejectSigning:
                break
            }
        }

        let swapAssetScreen = visibleScreen.open(
            .swapAsset(
                dataStore: dataStore,
                swapController: swapController,
                coordinator: self
            ),
            by: style
        ) as? SwapAssetScreen

        swapAssetScreen?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didTapSwap:
                self.openConfirmAsset(swapController)
            case .didTapUserAsset:
                self.openUserAssetSelection(swapController)
            case .editAmount:
                self.openEditAmount()
            case .didTapPoolAsset:
                self.openPoolAssetSelection(swapController)
            }
        }
    }

    private func openConfirmAsset(
        _ swapController: SwapController
    ) {
        let dataController = ConfirmSwapAPIDataController(
            swapController: swapController,
            api: api
        )

        let eventHandler: ConfirmSwapScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didTapConfirm(let swapTransactionPreparation):
                let transactionGroups = swapTransactionPreparation.transactionGroups
                if swapController.account.requiresLedgerConnection() {
                    self.openSignWithLedgerConfirmation(
                        swapController: swapController,
                        transactionGroups: transactionGroups
                    )
                    return
                }

                self.startLoading()
                swapController.signTransactions(transactionGroups)
            case .didTapPriceImpactInfo:
                self.openPriceImpactInfo()
            case .didTapSlippageInfo:
                self.openSlippageToleranceInfo()
            case .didTapSlippageAction:
                self.openEditSlippage()
            case .didTapExchangeFeeInfo:
                self.openExchangeFeeInfo()
            }
        }
        let screen: Screen = .confirmSwap(
            dataStore: dataStore,
            dataController: dataController,
            eventHandler: eventHandler
        )

        visibleScreen.open(
            screen,
            by: .push
        )
    }

    private func openSwapLoading(
        _ swapController: SwapController
    ) {
        guard let quote = swapController.quote else { return }

        let viewModel = SwapAssetLoadingScreenViewModel(
            quote: quote,
            currencyFormatter: currencyFormatter
        )

        loadingScreen = visibleScreen.open(
            .loading(viewModel: viewModel),
            by: .push
        ) as? LoadingScreen
    }

    private func openSwapSuccess(
        _ swapController: SwapController
    ) {
        let swapSuccessScreen = loadingScreen?.open(
            .swapSuccess(swapController: swapController),
            by: .push,
            animated: false
        ) as? SwapAssetSuccessScreen

        swapSuccessScreen?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didTapViewDetailAction:
                self.openPeraExplorerForSwapTransaction(swapController)
            case .didTapDoneAction:
                self.visibleScreen.dismissScreen()
            case .didTapSummaryAction:
                self.openSwapSummary(swapController)
            }
        }
    }

    private func openSwapSummary(
        _ swapController: SwapController
    ) {
        visibleScreen.open(
            .swapSummary(swapController: swapController),
            by: .present
        )
    }

    private func openError(
        _ swapController: SwapController,
        viewModel: ErrorScreenViewModel,
        primaryaction: @escaping EmptyHandler
    ) {
        let errorScreen = visibleScreen.open(
            .error(viewModel: viewModel),
            by: .push,
            animated: false
        ) as? ErrorScreen

        errorScreen?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didTapPrimaryAction:
                primaryaction()
            case .didTapSecondaryAction:
                self.visibleScreen.dismissScreen()
            }
        }
    }

    private func goBackToScreen<T: UIViewController>(_ screen: T.Type) -> T? {
        guard var viewControllers = visibleScreen.navigationController?.viewControllers else { return nil }
        let lastVC = viewControllers.removeLast()

        if !lastVC.isKind(of: screen) {
            visibleScreen.navigationController?.viewControllers = viewControllers
            return goBackToScreen(screen)
        }

        return lastVC as? T
    }
}

extension SwapAssetFlowCoordinator {
     private func openSignWithLedgerConfirmation(
        swapController: SwapController,
        transactionGroups: [SwapTransactionGroup]
     ) {
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        let totalTransactionCountToSign = transactionGroups.reduce(0, { $0 + $1.transactionsToSign.count })

        let title =
            "swap-sign-with-ledger-title"
                .localized
                .bodyLargeMedium(alignment: .center)
        let highlightedBodyPart =
            "swap-sign-with-ledger-body-highlighted"
                .localized(params: "\(totalTransactionCountToSign)")
        let body =
            "swap-sign-with-ledger-body"
                .localized(params: "\(totalTransactionCountToSign)")
                .bodyRegular(alignment: .center)
                .addAttributes(
                    to: highlightedBodyPart,
                    newAttributes: Typography.bodyMediumAttributes(alignment: .center)
                )

        let uiSheet = UISheet(
            image: "icon-ledger-48",
            title: title,
            body: UISheetBodyTextProvider(text: body)
        )

        let signTransactionsAction = UISheetAction(
            title: "swap-sign-with-ledger-action-title".localized,
            style: .default
        ) { [weak self] in
            guard let self = self else { return }

            self.visibleScreen.dismissScreen() {
                self.startLoading()

                self.openLedgerConnection(swapController)

                swapController.signTransactions(transactionGroups)
            }
        }
        uiSheet.addAction(signTransactionsAction)

         transition.perform(
            .sheetAction(
                sheet: uiSheet,
                theme: UISheetActionScreenImageTheme()
            ),
            by: .presentWithoutNavigationController
        )

        transitionToSignWithLedger = transition
    }

    private func openLedgerConnection(_ swapController: SwapController) {
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        let eventHandler: LedgerConnectionScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancel:
                swapController.clearTransactions()
                swapController.disconnectFromLedger()

                self.ledgerConnectionScreen?.dismissScreen()
                self.ledgerConnectionScreen = nil

                self.stopLoading()
            }
        }

        ledgerConnectionScreen = transition.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )

        transitionToLedgerConnection = transition
    }

    private func openLedgerConnectionIssues() {
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
    
    private func openSignWithLedgerProcess(
        swapController: SwapController,
        ledger: String,
        transactionGroups: [SwapTransactionGroup]
    ) {
        if visibleScreen is SignWithLedgerProcessScreen {
            return
        }

        let transition = BottomSheetTransition(
            presentingViewController: visibleScreen,
            interactable: false
        )

        let totalTransactionCount = transactionGroups.reduce(0, { $0 + $1.transactionsToSign.count })

        let draft = SignWithLedgerProcessDraft(
            ledgerDeviceName: ledger,
            totalTransactionCount: totalTransactionCount
        )

        let eventHandler: SignWithLedgerProcessScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancelApproval:
                swapController.clearTransactions()
                swapController.disconnectFromLedger()

                self.visibleScreen.dismissScreen()
                self.signWithLedgerProcessScreen = nil

                self.stopLoading()
            }
        }

        signWithLedgerProcessScreen = transition.perform(
            .signWithLedgerProcess(
                draft: draft,
                eventHandler: eventHandler
            ),
            by: .present
        ) as? SignWithLedgerProcessScreen

        transitionToLedgerSigningProcess = transition
    }

    private func displaySigningError(
        _ error: HIPTransactionError
    ) {
        bannerController.presentErrorBanner(
            title: "title-error".localized,
            message: error.debugDescription
        )
    }

    private func displayLedgerError(
        swapController: SwapController,
        ledgerError: LedgerOperationError
    ) {
        switch ledgerError {
        case .cancelled:
            bannerController.presentErrorBanner(
                title: "ble-error-transaction-cancelled-title".localized,
                message: "ble-error-fail-sign-transaction".localized
            )
        case .closedApp:
            bannerController.presentErrorBanner(
                title: "ble-error-ledger-connection-title".localized,
                message: "ble-error-ledger-connection-open-app-error".localized
            )
        case .failedToFetchAddress:
            bannerController.presentErrorBanner(
                title: "ble-error-transmission-title".localized,
                message: "ble-error-fail-fetch-account-address".localized
            )
        case .failedToFetchAccountFromIndexer:
            bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: "ledger-account-fetct-error".localized
            )
        case .custom(let title, let message):
            bannerController.presentErrorBanner(
                title: title,
                message: message
            )
        case .failedBLEConnectionError(let state):
            guard let errorTitle = state.errorDescription.title,
                  let errorSubtitle = state.errorDescription.subtitle else {
                return
            }

            swapController.clearTransactions()
            stopLoading()

            if visibleScreen is LedgerConnectionScreen {
                ledgerConnectionScreen?.dismissScreen()
                ledgerConnectionScreen = nil
            } else if visibleScreen is SignWithLedgerProcessScreen {
                signWithLedgerProcessScreen?.dismissScreen()
                signWithLedgerProcessScreen = nil
            }

            bannerController.presentErrorBanner(
                title: errorTitle,
                message: errorSubtitle
            )
        case .ledgerConnectionWarning:
            ledgerConnectionScreen?.dismiss(animated: true) {
                self.ledgerConnectionScreen = nil

                swapController.clearTransactions()
                self.stopLoading()

                self.bannerController.presentErrorBanner(
                    title: "ble-error-connection-title".localized,
                    message: ""
                )

                self.openLedgerConnectionIssues()
            }
        default:
            break
        }
    }
}

extension SwapAssetFlowCoordinator {
    private func openSlippageToleranceInfo() {
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        let uiSheet = UISheet(
            title: "swap-slippage-tolerance-info-title".localized.bodyLargeMedium(),
            body: UISheetBodyTextProvider(text: "swap-slippage-tolerance-info-body".localized.bodyRegular())
        )

        let closeAction = UISheetAction(
            title: "title-close".localized,
            style: .cancel
        ) { [unowned self] in
            self.visibleScreen.dismiss(animated: true)
        }
        uiSheet.addAction(closeAction)

        transition.perform(
            .sheetAction(sheet: uiSheet),
            by: .presentWithoutNavigationController
        )

        transitionToSlippageToleranceInfo = transition
    }

    private func openEditSlippage() {
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)
        let screen: Screen = .editSwapSlippage(dataStore: dataStore) {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didComplete:
                /// <todo>
                /// How can we be sure which screen we should return when the event occurs?
                self.visibleScreen.dismissScreen()
            }
        }

        transition.perform(
            screen,
            by: .present
        )

        transitionToEditSlippage = transition
    }

    private func openPriceImpactInfo() {
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        let uiSheet = UISheet(
            title: "swap-price-impact-info-title".localized.bodyLargeMedium(),
            body: UISheetBodyTextProvider(text: "swap-price-impact-info-body".localized.bodyRegular())
        )

        let closeAction = UISheetAction(
            title: "title-close".localized,
            style: .cancel
        ) { [unowned self] in
            self.visibleScreen.dismiss(animated: true)
        }
        uiSheet.addAction(closeAction)

        transition.perform(
            .sheetAction(sheet: uiSheet),
            by: .presentWithoutNavigationController
        )

        transitionToPriceImpactInfo = transition
    }

    private func openExchangeFeeInfo() {
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        let uiSheet = UISheet(
            title: "swap-confirm-exchange-fee-title".localized.bodyLargeMedium(),
            body: UISheetBodyTextProvider(text: "swap-confirm-exchange-fee-detail".localized.bodyRegular())
        )

        let closeAction = UISheetAction(
            title: "title-close".localized,
            style: .cancel
        ) { [unowned self] in
            self.visibleScreen.dismiss(animated: true)
        }
        uiSheet.addAction(closeAction)

        transition.perform(
            .sheetAction(sheet: uiSheet),
            by: .presentWithoutNavigationController
        )

        transitionToExchangeFeeInfo = transition
    }

    private func openPeraExplorerForSwapTransaction(
        _ swapController: SwapController
    ) {
        let transactionGroupID = swapController.parsedTransactions.first { !$0.groupID.isEmpty }?.groupID
        guard let formattedGroupID = transactionGroupID?.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
              let url = AlgorandWeb.PeraExplorer.group(
                isMainnet: api.network == .mainnet,
                param: formattedGroupID
              ).link else {
            return
        }

        visibleScreen.open(url)
    }
}

extension SwapAssetFlowCoordinator {
    private func openUserAssetSelection(
        _ swapController: SwapController
    ) {
        var filters: [AssetFilterAlgorithm] = [AssetZeroBalanceFilterAlgorithm()]

        if let poolAsset = swapController.poolAsset {
            filters.append(AssetExcludeFilterAlgorithm(excludedList: [poolAsset]))
        }

        let dataController = SelectLocalAssetDataController(
            account: swapController.account,
            filters: filters,
            api: api,
            sharedDataController: sharedDataController
        )

        let selectAssetScreen = visibleScreen.open(
            .selectAsset(
                dataController: dataController,
                coordinator: self,
                title: "swap-asset-from".localized
            ),
            by: .push
        ) as? SelectAssetScreen

        selectAssetScreen?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didSelectAsset(let asset):
                self.visibleScreen.popScreen()
                self.publish(.didSelectUserAsset(asset))
            case .didOptInToAsset: break
            }
        }
    }

    private func openEditAmount() {
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)
        let screen: Screen = .editSwapAmount(dataStore: dataStore) {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didComplete:
                /// <todo>
                /// How can we be sure which screen we should return when the event occurs?
                self.visibleScreen.dismissScreen()
            }
        }

        transition.perform(
            screen,
            by: .present
        )

        transitionToEditAmount = transition
    }

    private func openPoolAssetSelection(
        _ swapController: SwapController
    ) {
        let dataController = SelectSwapPoolAssetDataController(
            account: swapController.account,
            userAsset: swapController.userAsset.id,
            swapProviders: swapController.providers,
            api: api,
            sharedDataController: sharedDataController
        )

        let selectAssetScreen = visibleScreen.open(
            .selectAsset(
                dataController: dataController,
                coordinator: self,
                title: "swap-asset-to".localized
            ),
            by: .push
        ) as? SelectAssetScreen

        selectAssetScreen?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didSelectAsset(let asset):
                if swapController.account.isOptedIn(to: asset.id) {
                    self.visibleScreen.popScreen()
                    self.publish(.didSelectPoolAsset(asset))
                    return
                }

                let assetDecoration = AssetDecoration(asset: asset)
                self.openOptInAsset(assetDecoration)
            case .didOptInToAsset(let asset):
                self.visibleScreen.popScreen()
                self.publish(.didSelectPoolAsset(asset))
            }
        }
    }

    private func openOptInAsset(
        _ asset: AssetDecoration
    ) {
        guard let account = draft.account else { return }

        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        let draft = OptInAssetDraft(
            account: account,
            asset: asset
        )

        let screen = Screen.optInAsset(draft: draft) {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performApprove:
                self.visibleScreen.dismissScreen()
                self.publish(.didApproveOptInToAsset(asset))
            case .performClose:
                self.visibleScreen.dismissScreen()
            }
        }

        transition.perform(
            screen,
            by: .present
        )

        transitionToOptInAsset = transition
    }
}

extension SwapAssetFlowCoordinator {
    func swapIntroductionAlertItemDidPerformTrySwap(
        _ item: SwapIntroductionAlertItem
    ) {
        visibleScreen.dismiss(animated: true) {
            [unowned self] in
            self.analytics.track(.swapBannerTry())
            self.openSwapIntroduction()
        }
    }

    func swapIntroductionAlertItemDidPerformLaterAction(
        _ item: SwapIntroductionAlertItem
    ) {
        analytics.track(.swapBannerLater())
        visibleScreen.dismiss(animated: true)
    }
}

extension SwapAssetFlowCoordinator {
    private func logFailedSwap(
        quote: SwapQuote,
        txnID: String
    ) {
        analytics.track(
            .swapFailed(
                quote: quote,
                currency: sharedDataController.currency
            )
        )

        updateSwapQuote(
            quote,
            exception: "didFailTransaction: \(txnID)"
        )
    }

    private func logFailedSwap(
        quote: SwapQuote,
        error: SwapController.Error
    ) {
        analytics.track(
            .swapFailed(
                quote: quote,
                currency: sharedDataController.currency
            )
        )

        let message: String
        switch error {
        case .client(_, let apiError):
            message = apiError?.message ?? apiError.debugDescription
        case .server(_, let apiError):
            message = apiError?.message ?? apiError.debugDescription
        case .connection(let error):
            message = error.debugDescription
        case .unexpected(let error):
            message = error.debugDescription
        }

        updateSwapQuote(
            quote,
            exception: message
        )
    }

    private func updateSwapQuote(
        _ quote: SwapQuote,
        exception: String
    ) {
        let draft = UpdateSwapQuoteDraft(
            id: quote.id,
            exception: exception
        )
        api.updateSwapQuote(draft)
    }
}

extension SwapAssetFlowCoordinator {
    private func startLoading() {
        loadingController.startLoadingWithMessage("title-loading".localized)
    }

    private func stopLoading() {
        loadingController.stopLoading()
    }
}

extension SwapAssetFlowCoordinator {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            updateAccountIfNeeded()
        }
    }

    private func updateAccountIfNeeded() {
        guard let account = draft.account else { return }

        guard let updatedAccount = sharedDataController.accountCollection[account.address] else { return }

        if !updatedAccount.isAvailable { return }

        draft.account = updatedAccount.value
    }
}

extension SwapAssetFlowCoordinator {
    func add(
        _ observer: SwapAssetFlowCoordinatorObserver
    ) {
        let id = ObjectIdentifier(observer as AnyObject)
        observations[id] = WeakObservation(observer)
    }

    private func publish(
        _ event: SwapAssetFlowCoordinatorEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }

            self.notifyObservers {
                $0.swapAssetFlowCoordinator(
                    self,
                    didPublish: event
                )
            }
        }
    }
}

extension SwapAssetFlowCoordinator {
    final class WeakObservation: WeakObservable {
        weak var observer: SwapAssetFlowCoordinatorObserver?

        init(
            _ observer: SwapAssetFlowCoordinatorObserver
        ) {
            self.observer = observer
        }
    }
}

protocol SwapAssetFlowCoordinatorObserver: AnyObject {
    func swapAssetFlowCoordinator(
        _ swapAssetFlowCoordinator: SwapAssetFlowCoordinator,
        didPublish event: SwapAssetFlowCoordinatorEvent
    )
}

enum SwapAssetFlowCoordinatorEvent {
    case didSelectUserAsset(Asset)
    case didSelectPoolAsset(Asset)
    case didApproveOptInToAsset(AssetDecoration)
}
