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
    private var transitionToSlippageToleranceInfo: BottomSheetTransition?
    private var transitionToPriceImpactInfo: BottomSheetTransition?
    private var transitionToExchangeFeeInfo: BottomSheetTransition?
    private var transitionToOptInAsset: BottomSheetTransition?
    private var transitionToAdjustAmount: BottomSheetTransition?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?
    private var transitionToEditAmount: BottomSheetTransition?
    private var transitionToEditSlippage: BottomSheetTransition?

    private var loadingScreen: LoadingScreen?

    private let dataStore: SwapDataStore
    private let analytics: ALGAnalytics
    private let api: ALGAPI
    private let sharedDataController: SharedDataController
    private let bannerController: BannerController
    private unowned let presentingScreen: UIViewController
    private var account: Account?
    private let asset: Asset?

    init(
        dataStore: SwapDataStore,
        analytics: ALGAnalytics,
        api: ALGAPI,
        sharedDataController: SharedDataController,
        bannerController: BannerController,
        presentingScreen: UIViewController,
        asset: Asset? = nil
    ) {
        self.dataStore = dataStore
        self.analytics = analytics
        self.api = api
        self.sharedDataController = sharedDataController
        self.bannerController = bannerController
        self.presentingScreen = presentingScreen
        self.asset = asset
    }

    deinit {
        sharedDataController.remove(self)
    }
}

extension SwapAssetFlowCoordinator {
    func launch(account: Account?) {
        dataStore.reset()

        self.account = account

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
        let draft = SwapIntroductionDraft(provider: .tinyman)

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
        if let account = account {
            openSwapAsset(
                from: account,
                by: .present
            )
            return
        }

        openSelectAccount()
    }
}

extension SwapAssetFlowCoordinator {
    private func openSelectAccount() {
        let screen = Screen.swapAccountSelection {
             [unowned self] event, screen in
             switch event {
             case .didSelect(let accountHandle):
                 self.account = accountHandle.value

                 openSwapAsset(
                    from: accountHandle.value,
                    by: .push
                 )
             }
         }

         presentingScreen.open(
             screen,
             by: .present
         )
    }
}

extension SwapAssetFlowCoordinator {
    private func openSwapAsset(
        from account: Account,
        by style: Screen.Transition.Open
    ) {
        let transactionSigner = SwapTransactionSigner(
            api: api,
            analytics: analytics
        )
        let swapController = ALGSwapController(
            account: account,
            userAsset: asset ?? account.algo,
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
            case .didFailTransaction:
                guard let quote = swapController.quote else { return }

                if !(self.visibleScreen is LoadingScreen) {
                    return
                }

                self.analytics.track(
                    .swapFailed(
                        quote: quote,
                        currency: self.sharedDataController.currency
                    )
                )

                let viewModel = SwapUnexpectedErrorViewModel(quote)
                self.openError(
                    swapController,
                    viewModel: viewModel
                ) {
                    [weak self] in
                    guard let self = self else { return }
                    
                    self.goBackToScreen(SwapAssetScreen.self)
                }
            case .didFailNetwork(let error):
                guard let quote = swapController.quote else { return }

                if !(self.visibleScreen is LoadingScreen) {
                    return
                }

                self.analytics.track(
                    .swapFailed(
                        quote: quote,
                        currency: self.sharedDataController.currency
                    )
                )

                let message: String
                switch error {
                case .client(_, let apiError):
                    message = apiError?.message ?? apiError.debugDescription
                case .server(_, let apiError):
                    message = apiError?.message ?? apiError.debugDescription
                case .connection:
                    message = "title-internet-connection".localized
                case .unexpected:
                    message = "title-generic-api-error".localized
                }

                let viewModel = SwapAPIErrorViewModel(
                    quote: quote,
                    message: message
                )
                self.openError(
                    swapController,
                    viewModel: viewModel
                ) {
                    [weak self] in
                    guard let self = self else { return }

                    self.goBackToScreen(SwapAssetScreen.self)
                }
            case .didCancelTransaction:
                break
            case .didFailSigning(let error):
                switch error {
                case .api(let apiError):
                    self.displaySigningError(apiError)
                case .ledger(let ledgerError):                    
                    self.displayLedgerError(ledgerError)
                }
            case .didLedgerRequestUserApproval(let ledger, let transactionGroups):
                self.openSignWithLedgerProcess(
                    transactionSigner: transactionSigner,
                    swapController: swapController,
                    ledger: ledger,
                    transactionGroups: transactionGroups
                )
            case .didFinishTiming:
                break
            case .didLedgerReset:
                break
            case .didLedgerRejectSigning:
                if self.visibleScreen is SignWithLedgerProcessScreen {
                    self.signWithLedgerProcessScreen?.dismissScreen()
                    self.signWithLedgerProcessScreen = nil
                }
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
                self.openAlgoExplorerForSwapTransaction(swapController)
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

    private func goBackToScreen<T: UIViewController>(_ screen: T.Type) {
        guard var viewControllers = visibleScreen.navigationController?.viewControllers else { return }
        let lastVC = viewControllers.removeLast()

        if !lastVC.isKind(of: screen) {
            visibleScreen.navigationController?.viewControllers = viewControllers
            goBackToScreen(screen)
        }
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
            body: body
        )

        let signTransactionsAction = UISheetAction(
            title: "swap-sign-with-ledger-action-title".localized,
            style: .default
        ) { [weak self] in
            guard let self = self else { return }

            self.visibleScreen.dismissScreen()
            swapController.signTransactions(transactionGroups)
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

    private func openSignWithLedgerProcess(
        transactionSigner: SwapTransactionSigner,
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
                self.visibleScreen.dismissScreen()
            }
        }

        signWithLedgerProcessScreen = transition.perform(
            .swapSignWithLedgerProcess(
                transactionSigner: transactionSigner,
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
            message: error.localizedDescription
        )
    }

    private func displayLedgerError(
        _ ledgerError: LedgerOperationError
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
            body:"swap-slippage-tolerance-info-body".localized.bodyRegular()
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
            body:"swap-price-impact-info-body".localized.bodyRegular()
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
            body: "swap-confirm-exchange-fee-detail".localized.bodyRegular()
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

    private func openAlgoExplorerForSwapTransaction(
        _ swapController: SwapController
    ) {
        let transactionGroupID = swapController.parsedTransactions.first { !$0.groupID.isEmpty }?.groupID
        guard let formattedGroupID = transactionGroupID?.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
              let url = AlgorandWeb.AlgoExplorer.group(
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
                self.openOptInAsset(
                    assetDecoration,
                    swapController: swapController
                )
            case .didOptInToAsset(let asset):
                self.visibleScreen.popScreen()
                self.publish(.didSelectPoolAsset(asset))
            }
        }
    }

    private func openOptInAsset(
        _ asset: AssetDecoration,
        swapController: SwapController
    ) {
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        let account = swapController.account
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
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            updateAccountIfNeeded()
        }
    }

    private func updateAccountIfNeeded() {
        guard let account else { return }

        guard let updatedAccount = sharedDataController.accountCollection[account.address] else { return }

        if !updatedAccount.isAvailable { return }

        self.account = updatedAccount.value
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
