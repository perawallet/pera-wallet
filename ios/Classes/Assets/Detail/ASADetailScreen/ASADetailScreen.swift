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

//   ASADetailScreen.swift

import Foundation
import MacaroonUIKit
import MacaroonUtils
import SnapKit
import UIKit

final class ASADetailScreen:
    BaseViewController,
    Container {
    private lazy var navigationTitleView = AccountNameTitleView()
    private lazy var loadingView = makeLoading()
    private lazy var errorView = makeError()
    private lazy var profileView = ASAProfileView()
    private lazy var quickActionsView = ASADetailQuickActionsView()
    private lazy var marketInfoView = ASADetailMarketView()

    private lazy var pagesFragmentScreen = PageContainer(configuration: configuration)
    private lazy var activityFragmentScreen = ASAActivityScreen(
        account: dataController.account,
        asset: dataController.asset,
        copyToClipboardController: copyToClipboardController,
        configuration: configuration
    )
    private lazy var aboutFragmentScreen = ASAAboutScreen(
        asset: dataController.asset,
        copyToClipboardController: copyToClipboardController,
        configuration: configuration
    )

    private lazy var meldFlowCoordinator = MeldFlowCoordinator(
        analytics: analytics,
        presentingScreen: self
    )
    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(
            account: dataController.account,
            assetInID: dataController.asset.id
        ),
        dataStore: swapDataStore,
        analytics: analytics,
        api: api!,
        sharedDataController: sharedDataController,
        loadingController: loadingController!,
        bannerController: bannerController!,
        presentingScreen: self
    )
    private lazy var sendTransactionFlowCoordinator = SendTransactionFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController,
        account: dataController.account,
        asset: dataController.asset
    )
    private lazy var receiveTransactionFlowCoordinator =
        ReceiveTransactionFlowCoordinator(presentingScreen: self)
    private lazy var undoRekeyFlowCoordinator = UndoRekeyFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )
    private lazy var rekeyToStandardAccountFlowCoordinator = RekeyToStandardAccountFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )
    private lazy var rekeyToLedgerAccountFlowCoordinator = RekeyToLedgerAccountFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )
    private lazy var accountInformationFlowCoordinator = AccountInformationFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )

    private lazy var currencyFormatter = CurrencyFormatter()
    private lazy var rekeyingValidator = RekeyingValidator(
        session: session!,
        sharedDataController: sharedDataController
    )

    private var lastDisplayState = DisplayState.normal
    private var lastFrameOfFoldableArea = CGRect.zero

    private var isDisplayStateInteractiveTransitionInProgress = false
    private var displayStateInteractiveTransitionInitialFractionComplete: CGFloat = 0
    private var displayStateInteractiveTransitionScrollableAreaInitialContentOffsetY: CGFloat = 0
    private var displayStateInteractiveTransitionAnimator: UIViewPropertyAnimator?

    private var pagesFragmentHeightConstraint: Constraint!
    private var pagesFragmentTopEdgeConstraint: Constraint!
    private var isViewLayoutLoaded = false

    private var selectedPageFragmentScreen: ASADetailPageFragmentScreen? {
        return pagesFragmentScreen.selectedScreen as? ASADetailPageFragmentScreen
    }

    private var isDisplayStateTransitionAnimationInProgress: Bool {
        return displayStateInteractiveTransitionAnimator?.state == .active
    }

    private var shouldDisplayMarketInfo: Bool {
        dataController.asset.isAvailableOnDiscover
    }

    /// <todo>
    /// Normally, we shouldn't retain data store or create flow coordinator here but our currenct
    /// routing approach hasn't been refactored yet.
    private let swapDataStore: SwapDataStore
    private let dataController: ASADetailScreenDataController
    private let copyToClipboardController: CopyToClipboardController

    private let theme = ASADetailScreenTheme()

    init(
        swapDataStore: SwapDataStore,
        dataController: ASADetailScreenDataController,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.swapDataStore = swapDataStore
        self.dataController = dataController
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addNavigationTitle()
        addNavigationActions()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
        loadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty { return }

        if !isViewLayoutLoaded {
            updateUIWhenViewLayoutDidChangeIfNeeded()
            isViewLayoutLoaded = true
        }

        updateUIWhenViewDidLayoutSubviewsIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switchToHighlightedNavigationBarAppearance()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if presentedViewController == nil {
            switchToDefaultNavigationBarAppearance()
        }
    }

    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        super.preferredUserInterfaceStyleDidChange(to: userInterfaceStyle)
        bindUIDataWhenPreferredUserInterfaceStyleDidChange()
    }
}

extension ASADetailScreen {
    func optionsViewControllerDidUndoRekey(_ optionsViewController: OptionsViewController) {
        let sourceAccount = dataController.account
        undoRekeyFlowCoordinator.launch(sourceAccount)
    }
    
    func optionsViewControllerDidOpenRekeyingToLedger(_ optionsViewController: OptionsViewController) {
        let sourceAccount = dataController.account
        rekeyToLedgerAccountFlowCoordinator.launch(sourceAccount)
    }
    
    func optionsViewControllerDidOpenRekeyingToStandardAccount(_ optionsViewController: OptionsViewController) {
        let sourceAccount = dataController.account
        rekeyToStandardAccountFlowCoordinator.launch(sourceAccount)
    }
}

extension ASADetailScreen {
    private func addNavigationTitle() {
        navigationTitleView.customize(theme.navigationTitle)

        navigationItem.titleView = navigationTitleView

        let recognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(copyAccountAddress(_:))
        )
        navigationTitleView.addGestureRecognizer(recognizer)

        bindNavigationTitle()
    }

    private func bindNavigationTitle() {
        let account = dataController.account
        let viewModel = AccountNameTitleViewModel(account)
        navigationTitleView.bindData(viewModel)
    }

    private func addNavigationActions() {
        var rightBarButtonItems: [ALGBarButtonItem] = []

        if dataController.configuration.shouldDisplayAccountActionsBarButtonItem {
            let accountActionsBarButtonItem = makeAccountActionsBarButtonItem()
            rightBarButtonItems.append(accountActionsBarButtonItem)
        }

        if rightBarButtonItems.isEmpty {
            let flexibleSpaceItem = ALGBarButtonItem.flexibleSpace()
            rightBarButtonItems.append(flexibleSpaceItem)
        }

        self.rightBarButtonItems = rightBarButtonItems
    }

    private func makeAccountActionsBarButtonItem() ->  ALGBarButtonItem {
        let account = dataController.account
        let accountActionsItem = ALGBarButtonItem(kind: .account(account)) {
            [unowned self] in
            openAccountInformationScreen()
        }

        return accountActionsItem
    }

    private func openAccountInformationScreen() {
        let sourceAccount = dataController.account
        accountInformationFlowCoordinator.launch(sourceAccount)
    }

    private func addUI() {
        addBackground()
        addProfile()

        if dataController.configuration.shouldDisplayQuickActions {
            addQuickActions()
        }

        addMarketInfo()

        addPagesFragment()
    }

    private func updateUIWhenViewLayoutDidChangeIfNeeded() {
        if isDisplayStateInteractiveTransitionInProgress { return }
        if isDisplayStateTransitionAnimationInProgress { return }
        if !isViewLayoutLoaded { return }
        if !profileView.isLayoutLoaded { return }

        if dataController.configuration.shouldDisplayQuickActions && !quickActionsView.isLayoutLoaded {
            return
        }

        lastFrameOfFoldableArea = calculateFrameOfFoldableArea()

        updatePagesFragmentWhenViewLayoutDidChange()

        if pagesFragmentScreen.items.isEmpty {
            addPages()
        }
    }

    private func updateUIWhenViewDidLayoutSubviewsIfNeeded() {
        if isDisplayStateInteractiveTransitionInProgress { return }
        if isDisplayStateTransitionAnimationInProgress { return }

        updatePagesWhenViewDidLayoutSubviews()
    }

    private func updateUIWhenAccountDidRename() {
        bindNavigationTitle()
    }

    private func updateUIWhenDataWillLoad() {
        addLoading()
        removeError()
    }

    private func updateUIWhenDataDidLoad() {
        bindUIData()
        removeLoading()
        removeError()
        removeMarketInfoIfNeeded()
        updateUIWhenViewLayoutDidChangeIfNeeded()
    }

    private func updateUIWhenDataDidFailToLoad(_ error: ASADetailScreenDataController.Error) {
        addError()
        removeLoading()
    }

    private func updateUI(for state: DisplayState) {
        updateProfile(for: state)
        updateQuickActions(for: state)
        updateMarketInfo(for: state)
        updatePagesFragment(for: state)
    }

    private func bindUIData() {
        bindProfileData()
        bindMarketData()
        bindPagesFragmentData()
    }

    private func bindUIDataWhenPreferredUserInterfaceStyleDidChange() {
        bindProfileDataWhenPreferredUserInterfaceStyleDidChange()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func makeLoading() -> ASADetailLoadingView {
        let loadingView = ASADetailLoadingView()
        loadingView.customize(theme.loading)
        return loadingView
    }

    private func addLoading() {
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        loadingView.startAnimating()
    }

    private func removeLoading() {
        loadingView.removeFromSuperview()
        loadingView.stopAnimating()
    }

    private func makeError() -> NoContentWithActionView {
        let errorView = NoContentWithActionView()
        errorView.customizeAppearance(theme.errorBackground)
        errorView.customize(theme.error)
        return errorView
    }

    private func addError() {
        view.addSubview(errorView)
        errorView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        errorView.startObserving(event: .performPrimaryAction) {
            [weak self] in
            guard let self = self else { return }

            self.dataController.loadData()
        }

        /// <todo>
        /// Why don't we take as a reference the error for the view.
        errorView.bindData(ListErrorViewModel())
    }

    private func removeError() {
        errorView.removeFromSuperview()
    }

    private func addProfile() {
        profileView.customize(theme.profile)

        view.addSubview(profileView)
        profileView.snp.makeConstraints {
            $0.top == theme.normalProfileVerticalEdgeInsets.top
            $0.leading == theme.profileHorizontalEdgeInsets.leading
            $0.trailing == theme.profileHorizontalEdgeInsets.trailing
        }

        profileView.startObserving(event: .layoutChanged) {
            [unowned self] in

            self.updateUIWhenViewLayoutDidChangeIfNeeded()
        }
        profileView.startObserving(event: .copyAssetID) {
            [unowned self] in

            self.copyToClipboardController.copyID(self.dataController.asset)
        }

        bindProfileData()
    }

    private func bindProfileData() {
        let asset = dataController.asset
        let viewModel = ASADetailProfileViewModel(
            asset: asset,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
        profileView.bindData(viewModel)
    }

    private func bindProfileDataWhenPreferredUserInterfaceStyleDidChange() {
        let asset = dataController.asset

        var viewModel = ASADiscoveryProfileViewModel()
        viewModel.bindIcon(asset: asset)
        profileView.bindIcon(viewModel)
    }

    private func updateProfile(for state: DisplayState) {
        switch state {
        case .normal:
            profileView.expand()
            profileView.snp.updateConstraints {
                $0.top == theme.normalProfileVerticalEdgeInsets.top
            }
        case .folded:
            profileView.compress()
            profileView.snp.updateConstraints {
                $0.top == theme.foldedProfileVerticalEdgeInsets.top
            }
        }
    }

    private func addQuickActions() {
        if !dataController.configuration.shouldDisplayQuickActions {
            return
        }

        quickActionsView.customize(theme.quickActions)

        view.addSubview(quickActionsView)
        quickActionsView.snp.makeConstraints {
            $0.top == profileView.snp.bottom + theme.spacingBetweenProfileAndQuickActions
            $0.leading >= theme.profileHorizontalEdgeInsets.leading
            $0.trailing <= theme.profileHorizontalEdgeInsets.trailing
            $0.centerX == 0
        }

        let asset = dataController.asset
        let swapDisplayStore = SwapDisplayStore()
        let isOnboardedToSwap = swapDisplayStore.isOnboardedToSwap
        var viewModel = ASADetailQuickActionsViewModel(
            asset: asset,
            isSwapBadgeVisible: !isOnboardedToSwap
        )

        quickActionsView.startObserving(event: .layoutChanged) {
            [unowned self] in

            self.updateUIWhenViewLayoutDidChangeIfNeeded()
        }
        quickActionsView.startObserving(event: .buy) {
            [unowned self] in
            self.navigateToBuyAlgoIfPossible()
        }
        quickActionsView.startObserving(event: .swap) {
            [unowned self, unowned quickActionsView] in

            if !isOnboardedToSwap {
                viewModel.bindIsSwapBadgeVisible(isSwapBadgeVisible: false)
                quickActionsView.bindData(viewModel)
            }

            self.navigateToSwapAssetIfPossible()
        }
        quickActionsView.startObserving(event: .send) {
            [unowned self] in

            self.navigateToSendTransactionIfPossible()
        }
        quickActionsView.startObserving(event: .receive) {
            [unowned self] in

            self.navigateToReceiveTransaction()
        }

        quickActionsView.bindData(viewModel)
    }

    private func updateQuickActions(for state: DisplayState) {
        quickActionsView.alpha = state.isFolded ? 0 : 1
    }

    private func updateMarketInfo(for state: DisplayState) {
        marketInfoView.alpha = state.isFolded ? 0 : 1
    }

    private func addPagesFragment() {
        pagesFragmentScreen.view.customizeAppearance(theme.pagesFragmentBackground)

        addContent(pagesFragmentScreen) {
            fragmentView in

            view.addSubview(fragmentView)
            fragmentView.snp.makeConstraints {
                $0.leading == 0
                $0.trailing == 0

                pagesFragmentHeightConstraint = $0.matchToHeight(of: view)
                pagesFragmentTopEdgeConstraint = $0.top == 0
            }
        }
    }

    private func updatePagesFragmentWhenViewLayoutDidChange() {
        updatePagesFragment(for: lastDisplayState)
    }

    private func updatePagesFragment(for state: DisplayState) {
        let normalTopEdgeInset = calculateSpacingOverPagesFragment(for: .folded)
        pagesFragmentHeightConstraint.update(offset: -normalTopEdgeInset)

        updatePagesFragmentPosition(for: state)
    }

    private func updatePagesFragmentPosition(for state: DisplayState) {
        let topEdgeInset = calculateSpacingOverPagesFragment(for: state)
        pagesFragmentTopEdgeConstraint.update(inset: topEdgeInset)
    }

    private func bindPagesFragmentData() {
        bindPagesData()
    }

    private func addPages() {
        pagesFragmentScreen.items = [
            ActivityPageBarItem(screen: activityFragmentScreen),
            AboutPageBarItem(screen: aboutFragmentScreen)
        ]

        activityFragmentScreen.scrollView.panGestureRecognizer.addTarget(
            self,
            action: #selector(updateUIWhenPagesScrollableAreaDidChange(_:))
        )
        aboutFragmentScreen.scrollView.panGestureRecognizer.addTarget(
            self,
            action: #selector(updateUIWhenPagesScrollableAreaDidChange(_:))
        )
    }

    private func updatePagesWhenPagesScrollableAreaDidChange() {
        updatePagesWhenViewDidLayoutSubviews()
    }

    private func updatePagesWhenViewDidLayoutSubviews() {
        /// <note>
        /// The area within the last point means the pages fragment is folded. So, the pages can be
        /// scrolled inside.
        var frameOfFoldingArea = lastFrameOfFoldableArea
        frameOfFoldingArea.origin.y += 1

        /// <note>
        /// If the pages fragment is being animated, then `presentation()` gives us its actual frame
        /// which the animations are applied.
        let frameOfPagesFragment =
            pagesFragmentScreen.view.layer.presentation()?.frame ?? pagesFragmentScreen.view.frame
        let positionOfPagesFragment = frameOfPagesFragment.origin
        let isFolding = frameOfFoldingArea.contains(positionOfPagesFragment)

        setPagesScrollAnchoredOnTop(!isFolding)
    }

    private func setPagesScrollAnchoredOnTop(_ enabled: Bool) {
        activityFragmentScreen.isScrollAnchoredOnTop = !enabled
        aboutFragmentScreen.isScrollAnchoredOnTop = !enabled
    }

    private func bindPagesData() {
        bindAboutPageData()
    }

    private func bindAboutPageData() {
        let asset = dataController.asset
        aboutFragmentScreen.bindData(asset: asset)
    }

    private func addMarketInfo() {
        marketInfoView.customize(theme.marketInfo)

        let topView: UIView

        if dataController.configuration.shouldDisplayQuickActions {
            topView = quickActionsView
        } else {
            topView = profileView
        }

        view.addSubview(marketInfoView)
        marketInfoView.snp.makeConstraints {
            $0.top == topView.snp.bottom + theme.spacingBetweenProfileAndQuickActions
            $0.leading == theme.profileHorizontalEdgeInsets.leading
            $0.trailing == theme.profileHorizontalEdgeInsets.trailing
        }

        marketInfoView.startObserving(event: .market) {
            [unowned self] in
            let asset = self.dataController.asset

            let assetDetail = DiscoverAssetParameters(asset: asset)
            self.open(
                .discoverAssetDetail(assetDetail),
                by: .push
            )
        }

        bindMarketData()
    }

    private func bindMarketData() {
        let asset = dataController.asset
        let viewModel = ASADetailMarketViewModel(
            assetItem: .init(
                asset: asset,
                currency: sharedDataController.currency,
                currencyFormatter: currencyFormatter
            )
        )
        marketInfoView.bindData(viewModel)
    }

    private func removeMarketInfoIfNeeded() {
        guard !shouldDisplayMarketInfo else {
            return
        }
        marketInfoView.removeFromSuperview()
    }
}

extension ASADetailScreen {
    private func calculateSpacingOverPagesFragment(for state: DisplayState) -> CGFloat {
        switch state {
        case .normal: return lastFrameOfFoldableArea.maxY
        case .folded: return lastFrameOfFoldableArea.minY
        }
    }

    private func calculateFrameOfFoldableArea() -> CGRect {
        let width = view.bounds.width
        let minHeight =
            theme.foldedProfileVerticalEdgeInsets.top +
            profileView.intrinsicCompressedContentSize.height +
            theme.foldedProfileVerticalEdgeInsets.bottom
        var maxHeight =
            theme.normalProfileVerticalEdgeInsets.top +
            profileView.intrinsicExpandedContentSize.height +
            theme.normalProfileVerticalEdgeInsets.bottom

        if dataController.configuration.shouldDisplayQuickActions {
            let quickActionsHeight =
                theme.spacingBetweenProfileAndQuickActions +
                quickActionsView.bounds.height
            maxHeight += quickActionsHeight
        }

        if shouldDisplayMarketInfo {
            let marketInfoHeight =
                theme.spacingBetweenProfileAndQuickActions +
                marketInfoView.bounds.height
            maxHeight += marketInfoHeight
        }

        let height = maxHeight - minHeight

        return CGRect(x: 0, y: minHeight, width: width, height: height)
    }
}

extension ASADetailScreen {
    @objc
    private func copyAccountAddress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            copyToClipboardController.copyAddress(dataController.account)
        }
    }
}

extension ASADetailScreen {
    private func loadData() {
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .willLoadData: self.updateUIWhenDataWillLoad()
            case .didLoadData: self.updateUIWhenDataDidLoad()
            case .didFailToLoadData(let error): self.updateUIWhenDataDidFailToLoad(error)
            case .didUpdateAccount(let old): self.updateNavigationItemsIfNeededWhenAccountDidUpdate(old: old)
            }
        }
        dataController.loadData()
    }
}

extension ASADetailScreen {
    private func updateNavigationItemsIfNeededWhenAccountDidUpdate(old: Account) {
        if old.authorization == dataController.account.authorization {
            return
        }

        addNavigationActions()
        bindNavigationTitle()
        setNeedsRightBarButtonItemsUpdate()
    }
}

extension ASADetailScreen {
    @objc
    private func updateUIWhenPagesScrollableAreaDidChange(_ recognizer: UIPanGestureRecognizer) {
        updatePagesWhenPagesScrollableAreaDidChange()

        switch recognizer.state {
        case .began: startDisplayStateInteractiveTransition(recognizer)
        case .changed: updateDisplayStateInteractiveTransition(recognizer)
        case .ended: completeDisplayStateInteractiveTransition(recognizer)
        case .failed: reverseDisplayStateInteractiveTransition(recognizer)
        case .cancelled: reverseDisplayStateInteractiveTransition(recognizer)
        default: break
        }
    }

    private func startDisplayStateInteractiveTransition(_ recognizer: UIPanGestureRecognizer) {
        isDisplayStateInteractiveTransitionInProgress = true

        if !isDisplayStateTransitionAnimationInProgress {
            let nextDisplayState = lastDisplayState.reversed()
            displayStateInteractiveTransitionAnimator =
                startDisplayStateTransitionAnimation(to: nextDisplayState)
        }

        displayStateInteractiveTransitionAnimator?.pauseAnimation()

        let fractionComplete = displayStateInteractiveTransitionAnimator?.fractionComplete ?? 0
        displayStateInteractiveTransitionInitialFractionComplete = fractionComplete

        let scrollView = selectedPageFragmentScreen?.scrollView
        let contentOffsetY = scrollView?.contentOffset.y ?? 0
        let contentInsetTop = scrollView?.adjustedContentInset.top ?? 0
        displayStateInteractiveTransitionScrollableAreaInitialContentOffsetY = contentOffsetY + contentInsetTop
    }

    private func updateDisplayStateInteractiveTransition(_ recognizer: UIPanGestureRecognizer) {
        guard let animator = displayStateInteractiveTransitionAnimator else { return }

        animator.pauseAnimation()

        let translation = recognizer.translation(in: view)
        let normalSpacing = calculateSpacingOverPagesFragment(for: .normal)
        let foldedSpacing = calculateSpacingOverPagesFragment(for: .folded)
        let distance = normalSpacing - foldedSpacing
        let initialContentOffsetY = displayStateInteractiveTransitionScrollableAreaInitialContentOffsetY
        /// <note>
        /// In order to switch between the normal and folded states, the scroll should be on top for
        /// the selected page; therefore, the translation is projected on the content offset of the
        /// page, and determine whether or not there is still space to be scrolled over before
        /// switching the next display state.
        let scrollFraction = (translation.y - initialContentOffsetY) / distance
        let nextDisplayState = lastDisplayState.reversed()
        let scrollDirectionMultiplier: CGFloat = nextDisplayState.isFolded ? -1 : 1
        let reverseMultiplier: CGFloat = animator.isReversed ? -1 : 1
        /// <note>
        /// While the translation is negative, the fraction should be positive on scrolling down.
        let fraction =
            scrollFraction *
            scrollDirectionMultiplier *
            reverseMultiplier

        var fractionComplete: CGFloat = 0
        fractionComplete += displayStateInteractiveTransitionInitialFractionComplete
        fractionComplete += fraction

        animator.fractionComplete = fractionComplete.clamped(0...1)
    }

    private func completeDisplayStateInteractiveTransition(_ recognizer: UIPanGestureRecognizer) {
        guard let animator = displayStateInteractiveTransitionAnimator else { return }

        let isReversed = isDisplayStateInteractiveTransitionReversed(recognizer)
        if isReversed == animator.isReversed {
            animator.startAnimation()
        } else {
            reverseDisplayStateInteractiveTransition(recognizer)
        }
    }

    private func reverseDisplayStateInteractiveTransition(_ recognizer: UIPanGestureRecognizer) {
        guard let animator = displayStateInteractiveTransitionAnimator else { return }

        animator.isReversed.toggle()
        animator.continueAnimation(
            withTimingParameters: nil,
            durationFactor: 0
        )
    }

    private func isDisplayStateInteractiveTransitionReversed(_ recognizer: UIPanGestureRecognizer) -> Bool {
        guard let animator = displayStateInteractiveTransitionAnimator else {
            return false
        }

        let nextDisplayState = lastDisplayState.reversed()
        let contentOffsetYOnTop = -(selectedPageFragmentScreen?.scrollView.adjustedContentInset.top ?? 0)
        let contentOffsetY = selectedPageFragmentScreen?.scrollView.contentOffset.y ?? 0
        let velocityY = recognizer.velocity(in: recognizer.view).y

        /// <note>
        /// If there is still space to be scrolled over before switching the next display state,
        /// the animation should be reversed so that the pages fragment can't change its position.
        switch nextDisplayState {
        case .normal:
            if contentOffsetY > contentOffsetYOnTop {
                return true
            }

            if velocityY == 0 {
                return animator.isReversed
            }

            return velocityY < 0
        case .folded:
            if contentOffsetY < contentOffsetYOnTop {
                return true
            }

            if velocityY == 0 {
                return animator.isReversed
            }

            return velocityY > 0
        }
    }
}

extension ASADetailScreen {
    private func startDisplayStateTransitionAnimation(to state: DisplayState) -> UIViewPropertyAnimator {
        let animator = makeTransitionAnimator(for: state)
        animator.startAnimation()
        return animator
    }

    private func makeTransitionAnimator(for state: DisplayState) -> UIViewPropertyAnimator {
        switch state {
        case .normal: return makeTransitionAnimatorForNormalDisplayState()
        case .folded: return makeTransitionAnimatorForFoldedDisplayState()
        }
    }

    private func makeTransitionAnimatorForNormalDisplayState() -> UIViewPropertyAnimator {
        let animator = makeTransitionAnimatorForAnyDisplayState()
        animator.addAnimations {
            [unowned self] in

            let state = DisplayState.normal

            self.updateProfile(for: state)
            self.updatePagesFragment(for: state)

            UIView.animateKeyframes(
                withDuration: 0,
                delay: 0
            ) {
                UIView.addKeyframe(
                    withRelativeStartTime: 0.75,
                    relativeDuration: 0.25
                ) { [unowned self] in
                    self.updateQuickActions(for: state)
                    self.updateMarketInfo(for: state)
                }
            }

            self.view.layoutIfNeeded()
        }
        return animator
    }

    private func makeTransitionAnimatorForFoldedDisplayState() -> UIViewPropertyAnimator {
        let animator = makeTransitionAnimatorForAnyDisplayState()
        animator.addAnimations {
            [unowned self] in

            let state = DisplayState.folded

            self.updateProfile(for: state)
            self.updatePagesFragment(for: state)

            UIView.animateKeyframes(
                withDuration: 0,
                delay: 0
            ) {
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 0.25
                ) { [unowned self] in
                    self.updateQuickActions(for: state)
                    self.updateMarketInfo(for: state)
                }
            }

            self.view.layoutIfNeeded()
        }
        return animator
    }

    private func makeTransitionAnimatorForAnyDisplayState() -> UIViewPropertyAnimator {
        let timingParameters = UISpringTimingParameters(
            mass: 1.8,
            stiffness: 707,
            damping: 56,
            initialVelocity: .zero
        )
        let animator = UIViewPropertyAnimator(duration: 0.386, timingParameters: timingParameters)
        animator.addCompletion {
            [weak self] position in
            guard let self = self else { return }

            if position == .end {
                self.lastDisplayState.reverse()
            }

            self.updateUI(for: self.lastDisplayState)
            self.view.setNeedsLayout()

            self.displayStateInteractiveTransitionInitialFractionComplete = 0
            self.displayStateInteractiveTransitionScrollableAreaInitialContentOffsetY =
            self.selectedPageFragmentScreen?.scrollView.contentOffset.y ?? 0
            self.isDisplayStateInteractiveTransitionInProgress = false
        }
        return animator
    }
}

extension ASADetailScreen {
    private func navigateToBuyAlgoIfPossible() {
        let account = dataController.account
        if account.authorization.isNoAuth {
            presentActionsNotAvailableForAccountBanner()
            return
        }

        meldFlowCoordinator.launch(account)
    }

    private func navigateToSwapAssetIfPossible() {
        let account = dataController.account
        if account.authorization.isNoAuth {
            presentActionsNotAvailableForAccountBanner()
            return
        }

        analytics.track(.tapSwapInAlgoDetail())
        swapAssetFlowCoordinator.launch()
    }

    private func navigateToSendTransactionIfPossible() {
        let account = dataController.account
        if account.authorization.isNoAuth {
            presentActionsNotAvailableForAccountBanner()
            return
        }

        sendTransactionFlowCoordinator.launch()
        analytics.track(.tapSendInDetail(account: dataController.account))
    }

    private func navigateToReceiveTransaction() {
        receiveTransactionFlowCoordinator.launch(dataController.account)
        analytics.track(.tapReceiveAssetInDetail(account: dataController.account))
    }
}

extension ASADetailScreen {
    private func presentActionsNotAvailableForAccountBanner() {
        bannerController?.presentErrorBanner(
            title: "action-not-available-for-account-type".localized,
            message: ""
        )
    }
}

extension ASADetailScreen {
    private enum DisplayState: CaseIterable {
        case normal
        case folded

        var isFolded: Bool {
            return self == .folded
        }

        mutating func reverse() {
            self = reversed()
        }

        func reversed() -> DisplayState {
            switch self {
            case .normal: return .folded
            case .folded: return .normal
            }
        }
    }
}
