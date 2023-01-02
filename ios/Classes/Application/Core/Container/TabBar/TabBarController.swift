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
//  TabBarController.swift

import Foundation
import MacaroonUIKit
import UIKit

final class TabBarController: TabBarContainer {
    var route: Screen?

    var selectedTab: TabBarItemID? {
        get {
            let item = items[safe: selectedIndex]
            return item.unwrap { TabBarItemID(rawValue: $0.id) }
        }
        set {
            selectedIndex = newValue.unwrap { items.index(of: $0) }
        }
    }

    private lazy var toggleTransactionOptionsActionView = Button()

    private lazy var buyAlgoAction = TransactionOptionListAction(
        viewModel: BuyAlgoTransactionOptionListItemButtonViewModel()
    ) {
        [weak self] _ in
        guard let self = self else { return }
        self.navigateToBuyAlgo()
    }

    private lazy var swapActionViewModel = createSwapActionViewModel()
    private lazy var swapAction = createSwapListAction()

    private lazy var sendAction = TransactionOptionListAction(
        viewModel: SendTransactionOptionListItemButtonViewModel()
    ) {
        [weak self] _ in
        guard let self = self else { return }
        self.navigateToSendTransaction()
    }

    private lazy var receiveAction = TransactionOptionListAction(
        viewModel: ReceiveTransactionOptionListItemButtonViewModel()
    ) {
        [weak self] _ in
        guard let self = self else { return }
        self.navigateToReceiveTransaction()
    }

    private lazy var scanQRCodeAction = TransactionOptionListAction(
        viewModel: ScanQRCodeTransactionOptionListItemButtonViewModel()
    ) {
        [weak self] _ in
        guard let self = self else { return }
        self.navigateToQRScanner()
    }

    private lazy var transactionOptionsView = createTransactionOptions()

    private lazy var buyAlgoFlowCoordinator = BuyAlgoFlowCoordinator(presentingScreen: self)
    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(),
        dataStore: swapDataStore,
        analytics: analytics,
        api: api,
        sharedDataController: sharedDataController,
        loadingController: loadingController,
        bannerController: bannerController,
        presentingScreen: self
    )
    private lazy var sendTransactionFlowCoordinator = SendTransactionFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )
    private lazy var receiveTransactionFlowCoordinator = ReceiveTransactionFlowCoordinator(presentingScreen: self)
    private lazy var scanQRFlowCoordinator = ScanQRFlowCoordinator(
        analytics: analytics,
        api: api,
        bannerController: bannerController,
        loadingController: loadingController,
        presentingScreen: self,
        session: session,
        sharedDataController: sharedDataController
    )

    private lazy var buyAlgoResultTransition = BottomSheetTransition(presentingViewController: self)
    
    private var isTransactionOptionsVisible: Bool = false
    private var currentTransactionOptionsAnimator: UIViewPropertyAnimator?

    /// <todo>
    /// Normally, we shouldn't retain data store or create flow coordinator here but our currenct
    /// routing approach hasn't been refactored yet.
    private let swapDataStore: SwapDataStore
    private let analytics: ALGAnalytics
    private let api: ALGAPI
    private let bannerController: BannerController
    private let loadingController: LoadingController
    private let session: Session
    private let sharedDataController: SharedDataController

    init(
        swapDataStore: SwapDataStore,
        analytics: ALGAnalytics,
        api: ALGAPI,
        bannerController: BannerController,
        loadingController: LoadingController,
        session: Session,
        sharedDataController: SharedDataController
    ) {
        self.swapDataStore = swapDataStore
        self.analytics = analytics
        self.api = api
        self.bannerController = bannerController
        self.loadingController = loadingController
        self.session = session
        self.sharedDataController = sharedDataController
        super.init()
    }

    deinit {
        sharedDataController.remove(self)
    }

    override func addTabBar() {
        super.addTabBar()

        tabBar.customizeAppearance(
            [
                .backgroundColor(Colors.Defaults.background)
            ]
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.appConfiguration?.session.isValid = true
    }

    override func updateLayoutWhenItemsDidChange() {
        super.updateLayoutWhenItemsDidChange()

        if items.isEmpty {
            removeShowTransactionOptionsAction()
        } else {
            addShowTransactionOptionsAction()
        }
    }

    override func setListeners() {
        super.setListeners()

        self.sharedDataController.add(self)

        self.observeNetworkChanges()
        observeWhenUserIsOnboardedToSwap()
    }
}

extension TabBarController {
    private func build() {
        addBackground()

        if !items.isEmpty {
            addShowTransactionOptionsAction()
        }
    }

    private func addBackground() {
        customizeViewAppearance(
            [
                .backgroundColor(Colors.Defaults.background)
            ]
        )
    }

    private func addShowTransactionOptionsAction() {
        toggleTransactionOptionsActionView.customizeAppearance(
            [
                .icon([
                    .normal("tabbar-icon-transaction"),
                    .selected("tabbar-icon-transaction-selected")
                ])
            ]
        )

        tabBar.addSubview(toggleTransactionOptionsActionView)
        toggleTransactionOptionsActionView.fitToIntrinsicSize()
        toggleTransactionOptionsActionView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == 8
        }

        toggleTransactionOptionsActionView.addTouch(
            target: self,
            action: #selector(toggleTransactionOptions))

        toggleTransactionOptionsActionView.isUserInteractionEnabled = false
    }

    private func removeShowTransactionOptionsAction() {
        toggleTransactionOptionsActionView.removeFromSuperview()
    }

    private func createTransactionOptions() -> TransactionOptionsView {
        var theme = TransactionOptionsViewTheme()
        theme.contentSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBar.bounds.height, right: 0)

        let aView = TransactionOptionsView(
            actions: [
                buyAlgoAction,
                swapAction,
                sendAction,
                receiveAction,
                scanQRCodeAction
            ]
        )
        aView.customize(theme)

        aView.startObserving(event: .performClose) {
            [weak self] in
            guard let self = self else { return }
            self.toggleTransactionOptions()
        }

        return aView
    }

    private func addTransactionOptions() {
        if transactionOptionsView.isDescendant(of: view) {
            return
        }

        view.insertSubview(
            transactionOptionsView,
            belowSubview: tabBar
        )
        transactionOptionsView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func removeTransactionOptions() {
        transactionOptionsView.removeFromSuperview()
    }
}

extension TabBarController {
    @objc
    private func toggleTransactionOptions() {
        toggleTransactionOptionsActionView.isSelected.toggle()
        setTabBarItemsEnabled(!toggleTransactionOptionsActionView.isSelected)

        if !toggleTransactionOptionsActionView.isSelected {
            setNeedsDiscoverTabBarItemUpdateIfNeeded()
        }

        if let currentTransactionOptionsAnimator = currentTransactionOptionsAnimator,
           currentTransactionOptionsAnimator.isRunning {
            currentTransactionOptionsAnimator.isReversed.toggle()
            return
        }

        if isTransactionOptionsVisible {
            hideTransactionOptionsAnimated()
        } else {
            showTransactionOptionsAnimated()
        }
    }

    private func showTransactionOptionsAnimated() {
        addTransactionOptions()
        view.layoutIfNeeded()

        currentTransactionOptionsAnimator = makeTransactionOptionsAnimator(for: .end)
        currentTransactionOptionsAnimator?.addCompletion { [weak self] position in
            guard let self = self else { return }

            switch position {
            case .start:
                self.transactionOptionsView.updateBeforeAnimations(for: .start)
            case .end:
                self.isTransactionOptionsVisible = true
            default:
                break
            }
        }
        currentTransactionOptionsAnimator?.startAnimation()
    }

    private func hideTransactionOptionsAnimated() {
        currentTransactionOptionsAnimator = makeTransactionOptionsAnimator(for: .start)
        currentTransactionOptionsAnimator?.addCompletion { [weak self] position in
            guard let self = self else { return }

            switch position {
            case .start:
                self.transactionOptionsView.updateBeforeAnimations(for: .end)
            case .end:
                self.removeTransactionOptions()
                self.isTransactionOptionsVisible = false
            default:
                break
            }
        }
        currentTransactionOptionsAnimator?.startAnimation()
    }

    private func makeTransactionOptionsAnimator(
        for position: TransactionOptionsView.Position
    ) -> UIViewPropertyAnimator {
        transactionOptionsView.updateBeforeAnimations(for: position)

        return UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8) {
            [unowned self] in

            self.transactionOptionsView.updateAlongsideAnimations(for: position)
            self.view.layoutIfNeeded()
        }
    }
}

extension TabBarController {
    private func navigateToSwapAssetFlow() {
        toggleTransactionOptions()
        swapAssetFlowCoordinator.resetDraft()
        swapAssetFlowCoordinator.launch()

        analytics.track(.tapSwapInQuickAction())
    }

    private func navigateToSendTransaction() {
        toggleTransactionOptions()
        sendTransactionFlowCoordinator.launch()

        analytics.track(.tapSendTab())
    }

    private func navigateToReceiveTransaction() {
        toggleTransactionOptions()
        receiveTransactionFlowCoordinator.launch()

        analytics.track(.tapReceiveTab())
    }

    private func navigateToBuyAlgo() {
        toggleTransactionOptions()
        buyAlgoFlowCoordinator.launch()

        analytics.track(.moonpay(type: .tapBottomsheetBuy))
    }

    private func navigateToQRScanner() {
        toggleTransactionOptions()
        scanQRFlowCoordinator.launch()
    }
}

extension TabBarController {
    private func observeWhenUserIsOnboardedToSwap() {
        observe(notification: SwapDisplayStore.isOnboardedToSwapNotification) {
            [weak self] _ in
            guard let self = self else { return }

            self.updateSwapAction()
        }
    }

    private func updateSwapAction() {
        swapActionViewModel = createSwapActionViewModel()
        swapAction = createSwapListAction()
        transactionOptionsView = createTransactionOptions()
    }

    private func createSwapActionViewModel() -> SwapTransactionOptionListItemButtonViewModel {
        let swapDisplayStore = SwapDisplayStore()
        let isOnboardedToSwap = swapDisplayStore.isOnboardedToSwap
        return SwapTransactionOptionListItemButtonViewModel(isBadgeVisible: !isOnboardedToSwap)
    }

    private func createSwapListAction() -> TransactionOptionListAction {
        return TransactionOptionListAction(
            viewModel: swapActionViewModel
        ) {
            [weak self] actionView in
            guard let self = self else { return }

            let swapDisplayStore = SwapDisplayStore()
            let isOnboardedToSwap = swapDisplayStore.isOnboardedToSwap

            self.swapActionViewModel.bindIsBadgeVisible(!isOnboardedToSwap)
            actionView.bindData(self.swapActionViewModel)

            self.navigateToSwapAssetFlow()
        }
    }
}

extension TabBarController {
    private func observeNetworkChanges() {
        observe(notification: NodeSettingsViewController.didUpdateNetwork) {
            [unowned self] _ in
            setNeedsDiscoverTabBarItemUpdateIfNeeded()
        }
    }

    func setNeedsDiscoverTabBarItemUpdateIfNeeded() {
        /// <note>
        /// In staging app, the discover tab is always enabled, but in store app, it is enabled only
        /// on mainnet.
        let isEnabled = !ALGAppTarget.current.isProduction || !api.isTestNet

        setTabBarItemEnabled(
            isEnabled,
            forItemID: .discover
        )
    }
}

extension Array where Element == TabBarItem {
    func index(
        of itemId: TabBarItemID
    ) -> Int? {
        return firstIndex { $0.id == itemId.rawValue }
    }
}

extension TabBarContainer {
    func setTabBarItemEnabled(
        _ isEnabled: Bool,
        forItemID itemID: TabBarItemID
    ) {
        guard let index = items.index(of: itemID) else {
            return
        }

        let barButton = tabBar.barButtons[index]

        if barButton.isEnabled == isEnabled {
            return
        }

        barButton.isEnabled = isEnabled
    }
}

extension TabBarController: SharedDataControllerObserver {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didFinishRunning:
            toggleTransactionOptionsActionView.isUserInteractionEnabled = sharedDataController.isAvailable
        default:
            break
        }
    }
}
