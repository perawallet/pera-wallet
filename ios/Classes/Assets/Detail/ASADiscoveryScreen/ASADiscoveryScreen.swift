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

//   ASADiscoveryScreen.swift

import Foundation
import MacaroonUIKit
import MagpieCore
import MagpieHipo
import SnapKit
import UIKit

final class ASADiscoveryScreen:
    BaseViewController,
    Container,
    SelectAccountViewControllerDelegate,
    TransactionControllerDelegate {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var loadingView = makeLoading()
    private lazy var errorView = makeError()
    private lazy var profileView = ASAProfileView()

    private lazy var aboutFragmentScreen =
        ASAAboutScreen(
            asset: dataController.asset,
            copyToClipboardController: copyToClipboardController,
            configuration: configuration
        )

    private lazy var assetQuickActionView = AssetQuickActionView()

    private lazy var currencyFormatter = CurrencyFormatter()

    private var lastDisplayState = DisplayState.normal
    private var lastFrameOfFoldableArea = CGRect.zero

    private lazy var transactionController: TransactionController = {
        return TransactionController(
            api: api!,
            sharedDataController: sharedDataController,
            bannerController: bannerController,
            analytics: analytics
        )
    }()

    private lazy var transitionToOptInAsset = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToSignWithLedgerProcess = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToLedgerConnection = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToLedgerConnectionIssuesWarning = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToTransferAssetBalance = BottomSheetTransition(presentingViewController: self)

    private var isDisplayStateInteractiveTransitionInProgress = false
    private var displayStateInteractiveTransitionInitialFractionComplete: CGFloat = 0
    private var displayStateInteractiveTransitionScrollableAreaInitialContentOffsetY: CGFloat = 0
    private var displayStateInteractiveTransitionAnimator: UIViewPropertyAnimator?

    private var aboutFragmentHeightConstraint: Constraint!
    private var aboutFragmentTopEdgeConstraint: Constraint!
    private var isViewLayoutLoaded = false

    private var isDisplayStateTransitionAnimationInProgress: Bool {
        return displayStateInteractiveTransitionAnimator?.state == .active
    }

    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?

    private let quickAction: AssetQuickAction?
    private let dataController: ASADiscoveryScreenDataController
    private let copyToClipboardController: CopyToClipboardController

    private let theme = ASADiscoveryScreenTheme()

    init(
        quickAction: AssetQuickAction?,
        dataController: ASADiscoveryScreenDataController,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.quickAction = quickAction
        self.dataController = dataController
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)

        isModalInPresentation = true
    }

    override func configureNavigationBarAppearance() {
        addNavigationTitle()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
        loadData()
    }

    override func setListeners() {
        super.setListeners()
        transactionController.delegate = self
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

        if presentedViewController == nil && isMovingFromParent {
            switchToDefaultNavigationBarAppearance()
        }
    }

    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        super.preferredUserInterfaceStyleDidChange(to: userInterfaceStyle)
        bindUIDataWhenPreferredUserInterfaceStyleDidChange()
    }
}

extension ASADiscoveryScreen {
    private func addNavigationTitle() {
        let asset = dataController.asset
        navigationItem.title = asset.naming.unitName ?? asset.naming.name
    }

    private func addUI() {
        addBackground()
        addProfile()

        addAboutFragment()
        addAssetQuickActionIfNeeded()
    }

    private func updateUIWhenViewLayoutDidChangeIfNeeded() {
        if isDisplayStateInteractiveTransitionInProgress { return }
        if isDisplayStateTransitionAnimationInProgress { return }
        if !isViewLayoutLoaded { return }
        if !profileView.isLayoutLoaded { return }

        lastFrameOfFoldableArea = calculateFrameOfFoldableArea()

        updateAboutFragmentWhenViewLayoutDidChange()
    }

    private func updateUIWhenViewDidLayoutSubviewsIfNeeded() {
        if isDisplayStateInteractiveTransitionInProgress { return }
        if isDisplayStateTransitionAnimationInProgress { return }

        updateAboutFragmentWhenViewDidLayoutSubviews()
    }

    private func updateUI(for state: DisplayState) {
        updateProfile(for: state)
        updateAboutFragment(for: state)
    }

    private func updateUIWhenDataWillLoad() {
        addLoading()
        removeError()
    }

    private func updateUIWhenDataDidLoad() {
        bindUIData()
        removeLoading()
        removeError()
    }

    private func updateUIWhenDataDidFailToLoad(_ error: ASADiscoveryScreenDataController.Error) {
        addError()
        removeLoading()
    }

    private func updateUIWhenAssetWasOptedIn() {
        removeAssetQuickAction()
    }

    private func bindUIData() {
        bindProfileData()
        bindAboutFragmentData()
    }

    private func bindUIDataWhenPreferredUserInterfaceStyleDidChange() {
        bindProfileDataWhenPreferredUserInterfaceStyleDidChange()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func makeLoading() -> ASADiscoveryLoadingView {
        let loadingView = ASADiscoveryLoadingView()
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

            let asset = dataController.asset
            self.copyToClipboardController.copyID(asset)
        }

        bindProfileData()
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

    private func bindProfileData() {
        let asset = dataController.asset
        let viewModel = ASADiscoveryProfileViewModel(
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

    private func addAboutFragment() {
        addContent(aboutFragmentScreen) {
            fragmentView in

            view.addSubview(fragmentView)
            fragmentView.snp.makeConstraints {
                $0.leading == 0
                $0.trailing == 0

                aboutFragmentHeightConstraint = $0.matchToHeight(of: view)
                aboutFragmentTopEdgeConstraint = $0.top == 0
            }
        }

        aboutFragmentScreen.scrollView.panGestureRecognizer.addTarget(
            self,
            action: #selector(updateUIWhenPagesScrollableAreaDidChange(_:))
        )
    }

    private func updateAboutFragment(for state: DisplayState) {
        let normalTopEdgeInset = calculateSpacingOverAboutFragment(for: .folded)
        aboutFragmentHeightConstraint.update(offset: -normalTopEdgeInset)

        updateAboutFragmentPosition(for: state)
    }

    private func updateAboutFragmentPosition(for state: DisplayState) {
        let topEdgeInset = calculateSpacingOverAboutFragment(for: state)
        aboutFragmentTopEdgeConstraint.update(inset: topEdgeInset)
    }

    private func updateAboutFragmentWhenViewLayoutDidChange() {
        updateAboutFragment(for: lastDisplayState)
    }

    private func updateAboutFragmentWhenPagesScrollableAreaDidChange() {
        updateAboutFragmentWhenViewDidLayoutSubviews()
    }

    private func updateAboutFragmentWhenViewDidLayoutSubviews() {
        /// <note>
        /// The area within the last point means the about fragment is folded. So, the about can be
        /// scrolled inside.
        var frameOfFoldingArea = lastFrameOfFoldableArea
        frameOfFoldingArea.origin.y += 1

        /// <note>
        /// If the about fragment is being animated, then `presentation()` gives us its actual frame
        /// which the animations are applied.
        let frameOfAboutFragment =
            aboutFragmentScreen.view.layer.presentation()?.frame ?? aboutFragmentScreen.view.frame
        let positionOfAboutFragment = frameOfAboutFragment.origin
        let isFolding = frameOfFoldingArea.contains(positionOfAboutFragment)

        aboutFragmentScreen.isScrollAnchoredOnTop = isFolding

        let aboutFragmentScrollView = aboutFragmentScreen.scrollView
        if assetQuickActionView.isDescendant(of: view) {
            let assetQuickActionHeight = assetQuickActionView.bounds.height
            let aboutFragmentContentHeight = aboutFragmentScreen.contentSize.height + assetQuickActionHeight
            let aboutFragmentHeight = aboutFragmentScreen.view.bounds.height
            let aboutFragmentScrollableAreaHeight = aboutFragmentContentHeight - aboutFragmentHeight
            let bottom = aboutFragmentScrollableAreaHeight.clamped(0...assetQuickActionHeight)
            aboutFragmentScrollView.setContentInset(bottom: bottom)
        } else {
            aboutFragmentScrollView.setContentInset(bottom: 0)
        }
    }

    private func bindAboutFragmentData() {
        let asset = dataController.asset
        aboutFragmentScreen.bindData(asset: asset)
    }

    private func addAssetQuickActionIfNeeded() {
        guard let quickAction = quickAction else { return }
        switch quickAction {
        case .optIn:
            let optInStatus = dataController.hasOptedIn()

            if optInStatus != .rejected { return }

            addAssetQuickAction()

            if let account = dataController.account {
                bindAssetOptInAction(with: account)
            } else {
                bindAssetOptInAction()
            }
        case .optOut:
            let optInStatus = dataController.hasOptedIn()
            let optOutStatus = dataController.hasOptedOut()

            /// <note>
            /// It has already been opted out or not opted in.
            if optOutStatus != .rejected || optInStatus == .rejected {
                return
            }

            addAssetQuickAction()

            if let account = dataController.account {
                bindAssetOptOutAction(from: account)
            }
        }
    }

    private func addAssetQuickAction() {
        assetQuickActionView.customize(AssetQuickActionViewTheme())

        view.addSubview(assetQuickActionView)
        assetQuickActionView.snp.makeConstraints {
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func removeAssetQuickAction() {
        assetQuickActionView.removeFromSuperview()
    }

    private func bindAssetOptInAction(with account: Account) {
        let viewModel = AssetQuickActionViewModel(
            asset: dataController.asset,
            type: .optIn(with: account)
        )
        assetQuickActionView.bindData(viewModel)

        assetQuickActionView.startObserving(event: .performAction) {
            [weak self] in
            guard let self = self else { return }

            self.linkOptInAssetInteractions(with: account)
        }
    }

    private func bindAssetOptInAction() {
        let viewModel = AssetQuickActionViewModel(
            asset: dataController.asset,
            type: .optInWithoutAccount
        )
        assetQuickActionView.bindData(viewModel)

        assetQuickActionView.startObserving(event: .performAction) {
            [weak self] in
            guard let self = self else { return }

            self.linkOptInAssetInteractions()
        }
    }

    private func bindAssetOptOutAction(from account: Account) {
        let viewModel = AssetQuickActionViewModel(
            asset: dataController.asset,
            type: .optOut(from: account)
        )
        assetQuickActionView.bindData(viewModel)

        assetQuickActionView.startObserving(event: .performAction) {
            [weak self] in
            guard let self = self else { return }

            self.linkOptOutAssetInteractions(with: account)
        }
    }
}

extension ASADiscoveryScreen {
    private func calculateSpacingOverAboutFragment(for state: DisplayState) -> CGFloat {
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
        let maxHeight =
            theme.normalProfileVerticalEdgeInsets.top +
            profileView.intrinsicExpandedContentSize.height +
            theme.normalProfileVerticalEdgeInsets.bottom
        let height = maxHeight - minHeight
        return CGRect(x: 0, y: minHeight, width: width, height: height)
    }
}

extension ASADiscoveryScreen {
    private func loadData() {
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .willLoadData: self.updateUIWhenDataWillLoad()
            case .didLoadData: self.updateUIWhenDataDidLoad()
            case .didFailToLoadData(let error): self.updateUIWhenDataDidFailToLoad(error)
            }
        }
        dataController.loadData()
    }
}

extension ASADiscoveryScreen {
    @objc
    private func updateUIWhenPagesScrollableAreaDidChange(_ recognizer: UIPanGestureRecognizer) {
        updateAboutFragmentWhenPagesScrollableAreaDidChange()

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

        let scrollView = aboutFragmentScreen.scrollView
        let contentOffsetY = scrollView.contentOffset.y
        let contentInsetTop = scrollView.adjustedContentInset.top
        displayStateInteractiveTransitionScrollableAreaInitialContentOffsetY = contentOffsetY + contentInsetTop
    }

    private func updateDisplayStateInteractiveTransition(_ recognizer: UIPanGestureRecognizer) {
        guard let animator = displayStateInteractiveTransitionAnimator else { return }

        animator.pauseAnimation()

        let translation = recognizer.translation(in: view)
        let normalSpacing = calculateSpacingOverAboutFragment(for: .normal)
        let foldedSpacing = calculateSpacingOverAboutFragment(for: .folded)
        let distance = normalSpacing - foldedSpacing
        let initialContentOffsetY = displayStateInteractiveTransitionScrollableAreaInitialContentOffsetY
        /// <note>
        /// In order to switch between the normal and folded states, the scroll should be on top for
        /// the about screen; therefore, the translation is projected on the content offset of the
        /// screen, and determine whether or not there is still space to be scrolled over before
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
        let contentOffsetYOnTop = -aboutFragmentScreen.scrollView.adjustedContentInset.top
        let contentOffsetY = aboutFragmentScreen.scrollView.contentOffset.y
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

extension ASADiscoveryScreen {
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
            self.updateUI(for: state)

            self.view.layoutIfNeeded()
        }
        return animator
    }

    private func makeTransitionAnimatorForFoldedDisplayState() -> UIViewPropertyAnimator {
        let animator = makeTransitionAnimatorForAnyDisplayState()
        animator.addAnimations {
            [unowned self] in

            let state = DisplayState.folded
            self.updateUI(for: state)

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
                self.aboutFragmentScreen.scrollView.contentOffset.y
            self.isDisplayStateInteractiveTransitionInProgress = false
        }
        return animator
    }
}

extension ASADiscoveryScreen {
    private func linkOptInAssetInteractions(
        with account: Account
    ) {
        let assetDecoration = AssetDecoration(asset: dataController.asset)
        let draft = OptInAssetDraft(
            account: account,
            asset: assetDecoration
        )
        let screen = Screen.optInAsset(draft: draft) {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performApprove: self.continueToOptInAsset()
            case .performClose: self.cancelOptInAsset()
            }
        }
        transitionToOptInAsset.perform(
            screen,
            by: .present
        )
    }

    private func continueToOptInAsset() {
        dismiss(animated: true) {
            [weak self] in
            guard let self = self else { return }

            guard let account = self.dataController.account else { return }
            
            if !self.transactionController.canSignTransaction(for: account) { return }

            let asset = self.dataController.asset
            let monitor = self.sharedDataController.blockchainUpdatesMonitor
            let request = OptInBlockchainRequest(account: account, asset: asset)
            monitor.startMonitoringOptInUpdates(request)

            let assetTransactionDraft = AssetTransactionSendDraft(
                from: account,
                assetIndex: asset.id
            )
            self.transactionController.setTransactionDraft(assetTransactionDraft)
            self.transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)

            self.loadingController?.startLoadingWithMessage("title-loading".localized)

            if account.requiresLedgerConnection() {
                self.openLedgerConnection()

                self.transactionController.initializeLedgerTransactionAccount()
                self.transactionController.startTimer()
            }
        }
    }

    private func cancelOptInAsset() {
        dismiss(animated: true)
    }

    private func linkOptInAssetInteractions() {
        let draft = SelectAccountDraft(
            transactionAction: .optIn(asset: dataController.asset.id),
            requiresAssetSelection: false
        )

        let screen: Screen = .accountSelection(
            draft: draft,
            delegate: self
        )

        open(
            screen,
            by: .present
        )
    }
}

extension ASADiscoveryScreen {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for draft: SelectAccountDraft
    ) {
        dataController.account = account
        continueToOptInAsset()
    }
}

extension ASADiscoveryScreen {
    private func linkOptOutAssetInteractions(
        with account: Account
    ) {
        if let asset = account[dataController.asset.id],
           asset.amountWithFraction != 0 {
            openTransferAssetBalance(
                with: account,
                for: asset
            )
            return
        }

        let draft = OptOutAssetDraft(
            account: account,
            asset: dataController.asset
        )

        let screen = Screen.optOutAsset(draft: draft) {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performApprove: self.continueToOptOutFromAsset()
            case .performClose: self.cancelOptOutAsset()
            }
        }

        transitionToOptInAsset.perform(
            screen,
            by: .present
        )
    }

    private func continueToOptOutFromAsset() {
        dismiss(animated: true) {
            [weak self] in
            guard let self = self,
                  let account = self.dataController.account else {
                return
            }
            
            if !self.transactionController.canSignTransaction(for: account) { return }

            let asset = self.dataController.asset

            guard let creator = asset.creator else { return }

            let monitor = self.sharedDataController.blockchainUpdatesMonitor
            let request = OptOutBlockchainRequest(account: account, asset: asset)
            monitor.startMonitoringOptOutUpdates(request)
            
            let assetTransactionDraft = AssetTransactionSendDraft(
                from: account,
                toAccount: Account(address: creator.address),
                amount: 0,
                assetIndex: asset.id,
                assetCreator: creator.address
            )

            self.transactionController.setTransactionDraft(assetTransactionDraft)
            self.transactionController.getTransactionParamsAndComposeTransactionData(for: .assetRemoval)

            self.loadingController?.startLoadingWithMessage("title-loading".localized)

            if account.requiresLedgerConnection() {
                self.openLedgerConnection()

                self.transactionController.initializeLedgerTransactionAccount()
                self.transactionController.startTimer()
            }
        }
    }

    private func cancelOptOutAsset() {
        dismiss(animated: true)
    }
}

extension ASADiscoveryScreen {
    private func openTransferAssetBalance(
        with account: Account,
        for asset: Asset
    ) {
        let draft = TransferAssetBalanceDraft(
            account: account,
            asset: asset
        )

        let screen = Screen.transferAssetBalance(draft: draft) {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performApprove:
                self.continueToTransferAssetBalance(
                    asset: asset,
                    account: account
                )
            case .performClose:
                self.cancelTransferAssetBalance()
            }
        }

        transitionToTransferAssetBalance.perform(
            screen,
            by: .present
        )
    }

    private func continueToTransferAssetBalance(
        asset: Asset,
        account: Account
    ) {
        dismiss(animated: true) {
            [weak self] in
            guard let self = self else { return }

            var draft = SendTransactionDraft(
                from: account,
                transactionMode: .asset(asset)
            )
            draft.amount = asset.amountWithFraction

            self.open(
                .sendTransaction(draft: draft),
                by: .push
            )
        }
    }

    private func cancelTransferAssetBalance() {
        dismiss(animated: true)
    }
}

extension ASADiscoveryScreen {
    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        loadingController?.stopLoading()

        updateUIWhenAssetWasOptedIn()

        guard let action = quickAction else { return }

        switch action {
        case .optIn:
            eventHandler?(.didOptInToAsset)
        case .optOut:
            eventHandler?(.didOptOutFromAsset)
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        cancelMonitoringOptInOutUpdates(for: transactionController)

        loadingController?.stopLoading()
        
        switch error {
        case let .inapp(transactionError):
            displayTransactionError(transactionError)
        default:
            break
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedTransaction error: HIPTransactionError
    ) {
        cancelMonitoringOptInOutUpdates(for: transactionController)

        loadingController?.stopLoading()

        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: apiError.debugDescription
            )
        default:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.localizedDescription
            )
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didRequestUserApprovalFrom ledger: String
    ) {
        ledgerConnectionScreen?.dismiss(animated: true) {
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

        cancelMonitoringOptInOutUpdates(for: transactionController)

        loadingController?.stopLoading()
    }

    func transactionControllerDidResetLedgerOperationOnSuccess(_ transactionController: TransactionController) {
        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil

        loadingController?.stopLoading()
    }

    private func displayTransactionError(
        _ transactionError: TransactionError
    ) {
        switch transactionError {
        case let .minimumAmount(amount):
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let amountText = currencyFormatter.format(amount.toAlgos)

            bannerController?.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(
                    params: amountText.someString
                )
            )
        case let .sdkError(error):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.debugDescription
            )
        case .ledgerConnection:
            ledgerConnectionScreen?.dismiss(animated: true) {
                self.ledgerConnectionScreen = nil

                self.openLedgerConnectionIssues()
            }
        case .optOutFromCreator:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "asset-creator-opt-out-error-message".localized
            )
        default:
            break
        }
    }

    private func cancelMonitoringOptInOutUpdates(for transactionController: TransactionController) {
        if let account = dataController.account,
           let transactionType = transactionController.currentTransactionType {
            let monitor = sharedDataController.blockchainUpdatesMonitor
            let assetID = dataController.asset.id

            switch transactionType {
            case .assetAddition:
                monitor.cancelMonitoringOptInUpdates(
                    forAssetID: assetID,
                    for: account
                )
            case .assetRemoval:
                monitor.cancelMonitoringOptOutUpdates(
                    forAssetID: assetID,
                    for: account
                )
            default:
                break
            }
        }
    }
}

extension ASADiscoveryScreen {
    private func openSignWithLedgerProcess(
        transactionController: TransactionController,
        ledgerDeviceName: String
    ) {
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

                self.cancelMonitoringOptInOutUpdates(for: transactionController)

                self.loadingController?.stopLoading()
            }
        }
        signWithLedgerProcessScreen = transitionToSignWithLedgerProcess.perform(
            .signWithLedgerProcess(
                draft: draft,
                eventHandler: eventHandler
            ),
            by: .present
        ) as? SignWithLedgerProcessScreen
    }
}

extension ASADiscoveryScreen {
    private func openLedgerConnection() {
        let eventHandler: LedgerConnectionScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancel:
                self.transactionController.stopBLEScan()
                self.transactionController.stopTimer()
                self.cancelMonitoringOptInOutUpdates(for: self.transactionController)

                self.ledgerConnectionScreen?.dismissScreen()
                self.ledgerConnectionScreen = nil

                self.loadingController?.stopLoading()
            }
        }

        ledgerConnectionScreen = transitionToLedgerConnection.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }
}

extension ASADiscoveryScreen {
    private func openLedgerConnectionIssues() {
        transitionToLedgerConnectionIssuesWarning.perform(
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
    }
}

extension ASADiscoveryScreen {
    enum Event {
        case didOptInToAsset
        case didOptOutFromAsset
    }
}

extension ASADiscoveryScreen {
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

enum AssetQuickAction {
    case optIn
    case optOut
}
