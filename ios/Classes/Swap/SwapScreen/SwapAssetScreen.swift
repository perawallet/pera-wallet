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

//   SwapAssetScreen.swift

import MacaroonForm
import MacaroonUIKit
import MacaroonUtils
import MagpieExceptions
import MagpieHipo
import UIKit

final class SwapAssetScreen:
    BaseScrollViewController,
    MacaroonForm.KeyboardControllerDataSource,
    SwapAssetAmountViewDelegate,
    SwapAmountPercentageStoreObserver,
    SwapAssetFlowCoordinatorObserver {
    typealias DataStore = SwapAmountPercentageStore
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var keyboardController = MacaroonForm.KeyboardController(
        scrollView: scrollView,
        screen: self
    )

    private lazy var navigationTitleView = AccountNameTitleView()
    private lazy var contextView = VStackView()
    private lazy var userAssetView = SwapAssetAmountView()
    private lazy var errorView = SwapErrorView()
    private lazy var quickActionsView = SwapQuickActionsView(theme.quickActions)
    private lazy var emptyPoolAssetView = SwapAssetSelectionEmptyView(theme: theme.emptyPoolAsset)
    private lazy var poolAssetView = SwapAssetAmountView()
    private lazy var swapActionView: MacaroonUIKit.LoadingButton = {
        let loadingIndicator = ViewLoadingIndicator()
        loadingIndicator.applyStyle(theme.swapActionIndicator)
        return MacaroonUIKit.LoadingButton(loadingIndicator: loadingIndicator)
    }()

    private var swapQuickActionsViewModel: SwapQuickActionsViewModel?

    private lazy var swapAssetValueFormatter = SwapAssetValueFormatter()
    private lazy var swapAssetInputValidator = SwapAssetInputValidator()

    private let currencyFormatter: CurrencyFormatter
    private let dataController: SwapAssetDataController
    private weak var swapAssetFlowCoordinator: SwapAssetFlowCoordinator?
    private let copyToClipboardController: CopyToClipboardController
    private var userAssetViewModel: SwapAssetAmountViewModel
    private var poolAssetViewModel: SwapAssetAmountViewModel?

    private var currentInputAsInt: UInt64? {
        if let userAmountString = userAssetView.currentAmount,
           let amountInDecimal = Formatter.decimalFormatter(maximumFractionDigits: dataController.userAsset.decimals).number(from: userAmountString)?.decimalValue {
            return amountInDecimal.toFraction(of: dataController.userAsset.decimals)
        }

        return nil
    }

    private let dataStore: DataStore

    private let theme: SwapAssetScreenTheme = .init()

    init(
        dataStore: DataStore,
        dataController: SwapAssetDataController,
        coordinator: SwapAssetFlowCoordinator,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataStore = dataStore
        self.dataController = dataController
        self.swapAssetFlowCoordinator = coordinator
        self.copyToClipboardController = copyToClipboardController
        self.currencyFormatter = CurrencyFormatter()
        self.userAssetViewModel = SwapAssetAmountInViewModel(
            asset: dataController.userAsset,
            quote: nil,
            currency: configuration.sharedDataController.currency,
            currencyFormatter: currencyFormatter,
            customAmount: nil
        )
        super.init(configuration: configuration)

        if let poolAsset = dataController.poolAsset {
            self.poolAssetViewModel = SwapAssetAmountOutViewModel(
                asset: poolAsset,
                quote: nil,
                currency: configuration.sharedDataController.currency,
                currencyFormatter: currencyFormatter
            )
        }

        dataStore.add(self)
        swapAssetFlowCoordinator?.add(self)

        keyboardController.activate()
    }

    deinit {
        dataStore.remove(self)
        swapAssetFlowCoordinator?.remove(self)

        keyboardController.deactivate()
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
        addNavigationTitle()
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeAppearance(theme.background)
    }

    override func prepareLayout() {
        super.prepareLayout()
        addBackground()
        addContext()
        addSwapAction()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        beginEditing()
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }

    override func setListeners() {
        super.setListeners()
        userAssetView.delegate = self
        poolAssetView.delegate = self
        performKeyboardActions()
    }

    override func bindData() {
        super.bindData()
        userAssetView.bindData(userAssetViewModel)

        if let poolAssetViewModel = poolAssetViewModel {
            poolAssetView.bindData(poolAssetViewModel)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUIWhenViewDidLayoutSubviews()
    }
}

extension SwapAssetScreen {
    private func beginEditing() {
        userAssetView.beginEditing()
    }
}

extension SwapAssetScreen {
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
        let draft = AccountNameTitleDraft(
            title: "title-swap".localized,
            account: dataController.account
        )

        let viewModel = AccountNameTitleViewModel(draft)
        navigationTitleView.bindData(viewModel)
    }

    private func addBarButtons() {
        let infoBarButtonItem = ALGBarButtonItem(kind: .info) {
            [weak self] in
            guard let self = self else { return }

            self.open(AlgorandWeb.tinymanSwap.link)
        }

        rightBarButtonItems = [infoBarButtonItem]
    }
}

extension SwapAssetScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContext() {
        contentView.addSubview(contextView)
        contextView.spacing = theme.contextSpacing
        contextView.directionalLayoutMargins = theme.contextContentEdgeInsets
        contextView.isLayoutMarginsRelativeArrangement = true
        contextView.snp.makeConstraints {
            $0.top == theme.contextTopInset
            $0.leading == 0
            $0.trailing == 0
        }

        addUserAsset()
        addError()
        addQuickActions()
        addEmptyPoolAsset()
        addPoolAsset()
    }

    private func addUserAsset() {
        userAssetView.customize(theme.userAsset)
        contextView.addArrangedSubview(userAssetView)

        userAssetView.startObserving(event: .didSelectAsset) {
            [weak self] in
            guard let self = self else { return }
            self.didTapUserAsset()
        }
    }

    private func addError() {
        errorView.customize(theme.error)
        
        contextView.addArrangedSubview(errorView)
        errorView.isHidden = true
    }

    private func addQuickActions() {
        contextView.addArrangedSubview(quickActionsView)

        quickActionsView.setLeftQuickActionsHidden(true)
        quickActionsView.setRightQuickActionsHidden(true)

        quickActionsView.startObserving(event: .switchAssets) {
            [unowned self] in
            self.switchAssets()
        }
        quickActionsView.startObserving(event: .editAmount) {
            [unowned self] in
            self.eventHandler?(.editAmount)
        }
        quickActionsView.startObserving(event: .setMaxAmount) {
            [unowned self] in
            self.dataController.saveAmountPercentage(.maxPercentage())
        }

        contextView.attachSeparator(
            theme.quickActionsSeparator,
            to: quickActionsView
        )

        bindQuickActions()
    }

    private func addEmptyPoolAsset() {
        emptyPoolAssetView.customize()

        contextView.addArrangedSubview(emptyPoolAssetView)

        emptyPoolAssetView.isHidden = dataController.poolAsset != nil

        emptyPoolAssetView.startObserving(event: .didSelectAsset) {
            [weak self] in
            guard let self = self else { return }

            self.didTapPoolAsset()
        }

        let draft = SwapAssetSelectionEmptyViewDraft(title: "title-to".localized)
        emptyPoolAssetView.bindData(SwapAssetSelectionEmptyViewModel(draft))
    }

    private func addPoolAsset() {
        poolAssetView.customize(theme.poolAsset)

        poolAssetView.isHidden = dataController.poolAsset == nil
        contextView.addArrangedSubview(poolAssetView)

        poolAssetView.startObserving(event: .didSelectAsset) {
            [weak self] in
            guard let self = self else { return }
            self.didTapPoolAsset()
        }
    }

    private func addSwapAction() {
        swapActionView.customizeAppearance(theme.swapAction)

        footerView.addSubview(swapActionView)
        swapActionView.contentEdgeInsets = theme.swapActionContentEdgeInsets
        swapActionView.snp.makeConstraints {
            $0.fitToHeight(theme.swapActionHeight)
            $0.top ==  theme.swapActionEdgeInsets.top
            $0.leading == theme.swapActionEdgeInsets.leading
            $0.bottom == theme.swapActionEdgeInsets.bottom
            $0.trailing == theme.swapActionEdgeInsets.trailing
         }

        swapActionView.addTouch(
             target: self,
             action: #selector(swap)
         )

        swapActionView.isEnabled = false

        swapAssetFlowCoordinator?.checkAssetsLoaded()
    }

    private func updateUIWhenViewDidLayoutSubviews() {
        updateScreenWhenViewDidLayoutSubviews()
    }
}

extension SwapAssetScreen {
    /// <todo>
    /// Maybe, we can set `AmountPercentageDidChange` kind of things as enum cases???
    private func bindDataWhenAmountPercentageDidChange() {
        bindQuickActions()
    }

    private func bindQuickActions() {
        let percentage = dataStore.amountPercentage
        self.swapQuickActionsViewModel = SwapQuickActionsViewModel(amountPercentage: percentage)
        quickActionsView.bind(swapQuickActionsViewModel)
    }
}

extension SwapAssetScreen {
    func swapAssetFlowCoordinator(
        _ swapAssetFlowCoordinator: SwapAssetFlowCoordinator,
        didPublish event: SwapAssetFlowCoordinatorEvent
    ) {
        switch event {
        case .didSelectUserAsset(let asset):
            updateUserAsset(asset)
        case .didSelectPoolAsset(let asset):
            updatePoolAsset(asset)
        case .didApproveOptInToAsset: break
        }
    }

    private func performKeyboardActions() {
        keyboardController.performAlongsideWhenKeyboardIsShowing(animated: true) {
            [weak self] keyboard in
            guard let self = self else { return }
            self.updateFooterWhenKeyboardIsShowing(keyboard)
        }

        keyboardController.performAlongsideWhenKeyboardIsHiding(animated: true) {
            [weak self] keyboard in
            guard let self = self else { return }
            self.updateFooterWhenKeyboardIsHiding(keyboard)
        }
    }

    @objc
    private func swap() {
        analytics.track(.tapSwapAsset())
        eventHandler?(.didTapSwap)
    }
}

extension SwapAssetScreen {
    private func getSwapQuote(
        for amount: UInt64
    ) {
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .willLoadQuote: self.updateUIWhenDataWillLoad()
            case .didLoadQuote(let quote): self.validateFromQuote(quote)
            case .didFailToLoadQuote(let error): self.updateUIWhenDataDidFailToLoad(error)
            }
        }

        dataController.loadQuote(swapAmount: amount)
    }

    private func updateUIWhenDataWillLoad() {
        swapActionView.isEnabled = false
        startLoading()
        poolAssetView.startAnimatingAmountView()
        hideError()

        updatePoolAssetAmount(
            with: nil,
            quote: nil
        )
    }

    private func validateFromQuote(
        _ quote: SwapQuote
    ) {
        var quoteValidator = SwapAvailableBalanceQuoteValidator(
            account: dataController.account,
            quote: quote
        )

        quoteValidator.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .validated:
                self.updateUIWhenDataDidLoad(quote)
            case .failure(let error):
                self.updateUIWhenDataDidLoad(quote)

                switch error {
                case .amountInNotAvailable,
                     .amountOutNotAvailable:
                    self.showError("swap-asset-not-available".localized)
                case .insufficientAlgoBalance(let minBalance):
                    self.showInsufficientAlgoBalanceErrorForQuoteValidation(minBalance)
                case .insufficientAssetBalance:
                    self.showInsufficientAssetBalanceErrorForQuoteValidation(quote: quote)
                case .unavailablePeraFee: break
                }
            }
        }

        quoteValidator.validateAvailableSwapBalance()
    }

    private func updateUIWhenDataDidFailToLoad(
        _ error: SwapAssetDataController.Error
    ) {
        switch error {
        case .client(_, let apiError):
            showError(apiError?.fallbackMessage ?? error.prettyDescription)
        case .server(_, let apiError):
            showError(apiError?.fallbackMessage ?? error.prettyDescription)
        case .connection:
            showError("title-internet-connection".localized)
        case .unexpected:
            showError("title-generic-api-error".localized)
        }
    }
}

extension SwapAssetScreen {
    private func updateUIWhenDataDidLoad(
        _ swapQuote: SwapQuote
    ) {
        stopLoading()
        updateSwapActionUIWhenDataDidLoad(quote: swapQuote)
        updateUserAssetViewModel(quote: swapQuote)
        updateUserAssetSelectionUI()
        updatePoolAssetViewModel(quote: swapQuote)
        updatePoolAssetSelectionUI()
    }

    private func updateSwapActionUIWhenDataDidLoad(
        quote: SwapQuote
    ) {
        swapActionView.isEnabled =
            quote.amountIn != nil &&
            quote.assetOut != nil &&
            quote.assetOut != nil
    }

    private func updateUserAssetViewModel(
        quote: SwapQuote? = nil,
        customAmount: UInt64? = nil
    ) {
        userAssetViewModel = SwapAssetAmountInViewModel(
            asset: dataController.userAsset,
            quote: quote,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter,
            customAmount: customAmount
        )
    }

    private func updateUserAssetSelectionUI() {
        userAssetView.bindData(userAssetViewModel)
    }

    private func updatePoolAssetViewModel(
        quote: SwapQuote? = nil
    ) {
        guard let poolAsset = dataController.poolAsset else { return }

        poolAssetViewModel = SwapAssetAmountOutViewModel(
            asset: poolAsset,
            quote: quote,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
    }

    private func updatePoolAssetSelectionUI() {
        emptyPoolAssetView.isHidden = true
        poolAssetView.isHidden = false
        poolAssetView.bindData(poolAssetViewModel)
    }

    private func updateQuickActions() {
        updateQuickActionsAccessibility()
        
        if let poolAsset = dataController.poolAsset {
            if let poolAssetInAccount = dataController.account[poolAsset.id],
               poolAssetInAccount.amount > 0 {
                quickActionsView.setLeftQuickActionsHidden(false)
            } else {
                quickActionsView.setLeftQuickActionsHidden(true)
            }

            quickActionsView.setRightQuickActionsHidden(false)
        }
    }
    
    private func updateQuickActionsAccessibility() {
        updateLeftQuickActionsAccessibility()
    }
    
    private func updateLeftQuickActionsAccessibility() {
        let verificationStatus = dataController.userAsset.verificationTier
        let isEnabled = !(verificationStatus.isSuspicious || verificationStatus.isUnverified)
        quickActionsView.setLeftQuickActionsEnabled(isEnabled)
    }

    private func showInsufficientAlgoBalanceErrorForQuoteValidation(
        _ minBalance: UInt64
    ) {
        guard let amountText = swapAssetValueFormatter.getFormattedAlgoAmount(
            decimalAmount: minBalance.toAlgos,
            currencyFormatter: currencyFormatter
        ) else {
            stopLoading()
            return
        }

        showError("swap-asset-algo-min-balance-error".localized(params: amountText))
    }

    private func showInsufficientAssetBalanceErrorForQuoteValidation(
        quote: SwapQuote
    ) {
        guard let assetIn = quote.assetIn else {
            stopLoading()
            return
        }

        let assetDisplayValue = swapAssetValueFormatter.getAssetDisplayName(assetIn)
        showError("swap-asset-min-balance-error".localized(params: assetDisplayValue))
    }

    private func showError(
        _ message: String
    ) {
        stopLoading()
        swapActionView.isEnabled = false

        errorView.isHidden = false
        let viewModel = SwapAssetErrorViewModel(message: message)
        errorView.bindData(viewModel)
    }

    private func hideError() {
        errorView.isHidden = true
    }

    private func startLoading() {
        swapActionView.startLoading()
        swapQuickActionsViewModel?.bindSwitchAssetsQuickActionItemEnabled(false)
        quickActionsView.bind(swapQuickActionsViewModel)
    }

    private func stopLoading() {
        if swapActionView.isLoading {
            swapActionView.stopLoading()
        }

        swapQuickActionsViewModel?.bindSwitchAssetsQuickActionItemEnabled(true)
        quickActionsView.bind(swapQuickActionsViewModel)
        
        updateQuickActionsAccessibility()
        
        poolAssetView.stopAnimatingAmountView()
    }
}

extension SwapAssetScreen {
    @objc
    private func copyAccountAddress(
        _ recognizer: UILongPressGestureRecognizer
    ) {
        if recognizer.state == .began {
            copyToClipboardController.copyAddress(dataController.account)
        }
    }

    private func switchAssets() {
        guard let poolAsset = dataController.poolAsset else { return }

        dataController.poolAsset = dataController.userAsset
        dataController.userAsset = poolAsset

        clearAmountPercentageIfNeeded()
        let amountOut = getAmountOutForSwitchedAsset()
        updateUserAssetViewModel(customAmount: amountOut == 0 ? nil : amountOut)
        updatePoolAssetViewModel()
        updateQuoteAfterSwitchingAssetIfNeeded()
        updateUserAssetSelectionUI()
        updatePoolAssetSelectionUI()
    }

    private func updateQuoteAfterSwitchingAssetIfNeeded() {
        if let amountOut = getAmountOutForSwitchedAsset() {
            if amountOut == 0 {
                hideError()
                swapActionView.isEnabled = false
                stopLoading()
            } else {
                getSwapQuote(for: amountOut)
            }
        }
    }

    private func getAmountOutForSwitchedAsset() -> UInt64? {
        /// <note>
        /// Used user asset to get the current output since assets are switched.
        return getAmountOut(for: dataController.userAsset)
    }

    private func didTapUserAsset() {
        eventHandler?(.didTapUserAsset)
    }

    private func updateUserAsset(
        _ asset: Asset,
        for quote: SwapQuote? = nil
    ) {
        dataController.userAsset = asset
        updateUserAssetViewModel(quote: quote)
        updateUserAssetSelectionUI()
        updateQuickActions()
        getNewSwapQuoteAfterAssetUpdateIfNeeded()
    }

    private func didTapPoolAsset() {
        eventHandler?(.didTapPoolAsset)
    }

    private func updatePoolAsset(
        _ asset: Asset,
        for quote: SwapQuote? = nil
    ) {
        dataController.poolAsset = asset
        updatePoolAssetViewModel(quote: quote)
        updatePoolAssetSelectionUI()
        updateQuickActions()
        getNewSwapQuoteAfterAssetUpdateIfNeeded()
    }

    private func getNewSwapQuoteAfterAssetUpdateIfNeeded() {
        if let currentInputAsInt,
           currentInputAsInt > 0 {
            getSwapQuote(for: currentInputAsInt)
        }
    }

    private func getAmountOut(
        for asset: Asset
    ) -> UInt64? {
        if let poolAmountString = poolAssetView.currentAmount,
           let amountOutDecimal =
            Formatter.decimalFormatter(
                maximumFractionDigits: asset.decimals,
                groupingSeparator: ""
            ).number(
                from: poolAmountString
            )?.decimalValue {
                return amountOutDecimal.toFraction(of: asset.decimals)
        }

        return nil
    }
}

extension SwapAssetScreen {
    private func validateFromBalancePercentage(
        _ amount: UInt64
    ) {
        var balancePercentageValidator = SwapAvailableBalancePercentageValidator(
            account: dataController.account,
            userAsset: dataController.userAsset,
            poolAsset: dataController.poolAsset,
            amount: amount,
            api: api!
        )

        startLoading()

        balancePercentageValidator.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .validated(let availableBalance):
                self.updateUserAssetAmount(
                    with: availableBalance,
                    quote: nil
                )
                self.getSwapQuote(for: availableBalance)
            case .failure(let error):
                switch error {
                case .amountInNotAvailable,
                     .amountOutNotAvailable:
                    break
                case .insufficientAlgoBalance(let minBalance):
                    self.updateUserAssetAmount(
                        with: minBalance,
                        quote: nil
                    )
                    self.showError("swap-asset-min-balance-error-without-amount".localized)
                case .insufficientAssetBalance(let minBalance):
                    self.updateUserAssetAmount(
                        with: minBalance,
                        quote: nil
                    )
                    self.showError("swap-asset-min-balance-error-fee".localized)
                case .unavailablePeraFee(let feeError):
                    self.showError(feeError?.prettyDescription ?? "swap-asset-fee-unavailable-error".localized)
                }
            }
        }

        balancePercentageValidator.validateAvailableSwapBalance()
    }

    private func resetUserAndPoolAssetAmounts() {
        updateUserAssetAmount(
            with: nil,
            quote: nil
        )
        updatePoolAssetAmount(
            with: nil,
            quote: nil
        )

        hideError()
        swapActionView.isEnabled = false
        stopLoading()
    }

    private func updateUserAssetAmount(
        with amount: UInt64?,
        quote: SwapQuote?
    ) {
        if var viewModel = userAssetViewModel as? SwapAssetAmountInViewModel {
            viewModel.bindAssetAmountValue(
                asset: dataController.userAsset,
                quote: quote,
                currency: configuration.sharedDataController.currency,
                currencyFormatter: currencyFormatter,
                customAmount: amount
            )

            userAssetView.bindData(viewModel)
        }
    }

    private func updatePoolAssetAmount(
        with amount: UInt64?,
        quote: SwapQuote?
    ) {
        guard let selectedPoolAsset = dataController.poolAsset else { return }

        if var viewModel = poolAssetViewModel as? SwapAssetAmountOutViewModel {
            viewModel.bindAssetAmountValue(
                asset: selectedPoolAsset,
                quote: quote,
                currency: configuration.sharedDataController.currency,
                currencyFormatter: currencyFormatter
            )

            poolAssetView.bindData(viewModel)
        }
    }
}

extension SwapAssetScreen {
    func keyboardController(
        _ keyboardController: MacaroonForm.KeyboardController,
        editingRectIn view: UIView
    ) -> CGRect? {
        return getEditingRectOfCurrentAmountInputField()
    }

    func bottomInsetOverKeyboardWhenKeyboardDidShow(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        return theme.swapActionEdgeInsets.bottom
    }

    func additionalBottomInsetOverKeyboardWhenKeyboardDidShow(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        return calculateEmptySpacingToScrollCurrentAmountInputFieldToTop()
    }

    func bottomInsetUnderKeyboardWhenKeyboardDidShow(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        return keyboardController.keyboard?.height ?? 0
    }

    func bottomInsetWhenKeyboardDidHide(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        /// <note>
        /// It doesn't scroll to the bottom during the transition to another screen. When the
        /// screen is back, it will show the keyboard again anyway.
        if isViewDisappearing {
            return scrollView.contentInset.bottom
        }

        return theme.swapActionEdgeInsets.bottom
    }

    func spacingBetweenEditingRectAndKeyboard(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        return calculateSpacingToScrollCurrentAmountInputFieldToTop()
    }
}

extension SwapAssetScreen {
    private func calculateEmptySpacingToScrollCurrentAmountInputFieldToTop() -> CGFloat {
        guard let editingRectOfCurrentAmountInputField = getEditingRectOfCurrentAmountInputField() else {
            return 0
        }

        let editingOriginYOfCurrentAmountInputField = editingRectOfCurrentAmountInputField.minY
        let visibleHeight = view.bounds.height
        let minContentHeight =
            editingOriginYOfCurrentAmountInputField +
            visibleHeight
        let keyboardHeight = keyboardController.keyboard?.height ?? 0
        let contentHeight = scrollView.contentSize.height
        let maybeEmptySpacing =
            minContentHeight -
            contentHeight -
            keyboardHeight
        return max(maybeEmptySpacing, 0)
    }

    private func calculateMinEmptySpacingToScrollCurrentAmountInputFieldToTop() -> CGFloat {
        let visibleHeight = view.bounds.height
        let editingRectOfCurrentAmountInputField = getEditingRectOfCurrentAmountInputField()
        let editingHeightOfCurrentAmountInputField = editingRectOfCurrentAmountInputField?.height ?? 0
        return visibleHeight - editingHeightOfCurrentAmountInputField
    }

    private func calculateSpacingToScrollCurrentAmountInputFieldToTop() -> CGFloat {
        guard let editingRectOfCurrentAmountInputField = getEditingRectOfCurrentAmountInputField() else {
            return 8
        }

        let visibleHeight = view.bounds.height
        let editingHeightOfCurrentAmountInputField = editingRectOfCurrentAmountInputField.height
        let keyboardHeight = keyboardController.keyboard?.height ?? 0
        return
            visibleHeight -
            editingHeightOfCurrentAmountInputField -
            keyboardHeight
    }

    private func getEditingRectOfCurrentAmountInputField() -> CGRect? {
        if userAssetView.isFirstResponder {
            return userAssetView.frame
        }

        return nil
    }

    private func updateFooterWhenKeyboardIsShowing(
        _ keyboard: MacaroonForm.Keyboard
    ) {
        footerBackgroundView.snp.updateConstraints {
            let bottomInsetUnderKeyboard = bottomInsetUnderKeyboardWhenKeyboardDidShow(keyboardController)
            $0.bottom == bottomInsetUnderKeyboard
        }
    }

    private func updateFooterWhenKeyboardIsHiding(
        _ keyboard: MacaroonForm.Keyboard
    ) {
        footerBackgroundView.snp.updateConstraints {
            let bottomInsetUnderKeyboard = bottomInsetUnderKeyboardWhenKeyboardDidShow(keyboardController)
            $0.bottom == bottomInsetUnderKeyboard
        }
    }

    private func updateScreenWhenViewDidLayoutSubviews() {
        if keyboardController.isKeyboardVisible {
            return
        }

        let bottom = bottomInsetWhenKeyboardDidHide(keyboardController)
        scrollView.setContentInset(bottom: bottom)
    }
}

extension SwapAssetScreen {
    /// <note>
    /// Request the new quote whent the user types an amount.
    func swapAssetAmountView(
        _ swapAssetAmountView: SwapAssetAmountView,
        didChangeTextIn textField: TextField
    ) {
        guard let input = textField.text else { return }
        getSwapQuoteIfNeeded(for: input)
    }

    func getSwapQuoteForCurrentInput() {
        guard let input = userAssetView.currentAmount else { return }
        getSwapQuoteIfNeeded(for: input)
    }

    private func getSwapQuoteIfNeeded(for input: String) {
        if swapAssetInputValidator.isTheInputDecimalSeparator(input) {
            return
        }

        clearAmountPercentageIfNeeded()

        if input.isEmpty {
            dataController.cancelLoadingQuote()
            resetUserAndPoolAssetAmounts()
            return
        }

        let formatter = Formatter.decimalFormatter(maximumFractionDigits: dataController.userAsset.decimals)
        guard let inputAsDecimal = formatter.number(from: input)?.decimalValue else { return }

        let inputAsFractionUnit = inputAsDecimal.toFraction(of: dataController.userAsset.decimals)
        getSwapQuote(for: inputAsFractionUnit)
    }

    private func clearAmountPercentageIfNeeded() {
        if dataStore.amountPercentage != nil {
            dataController.saveAmountPercentage(nil)
        }
    }

    func swapAssetAmountView(
        _ swapAssetAmountView: SwapAssetAmountView,
        didBeginEditingIn textField: TextField
    ) {  }

    func swapAssetAmountView(
        _ swapAssetAmountView: SwapAssetAmountView,
        didEndEditingIn textField: TextField
    ) { }

    func swapAssetAmountView(
        _ swapAssetAmountView: SwapAssetAmountView,
        shouldChangeCharactersIn textField: TextField,
        with range: NSRange,
        replacementString string: String
    ) -> Bool {
        return swapAssetInputValidator.validateInput(
            shouldChangeCharactersIn: textField,
            with: range,
            replacementString: string,
            for: dataController.userAsset
        )
    }
}

/// <mark>
/// SwapAmountPercentageStoreObserver
extension SwapAssetScreen {
    func swapAmountPercentageDidChange() {
        bindDataWhenAmountPercentageDidChange()

        /// <todo>
        /// We should handle the nil case properly because the user can discard the last change to
        /// the amount percentage
        guard let amountPercentage = dataStore.amountPercentage else { return }

        let amount = getAmountFromPercentage(amountPercentage.value).toFraction(of: dataController.userAsset.decimals)

        updateUserAssetAmount(
            with: amount,
            quote: nil
        )

        if dataController.poolAsset != nil {
            validateFromBalancePercentage(amount)
        }
    }

    private func getAmountFromPercentage(
        _ percentage: Decimal
    ) -> Decimal {
        if dataController.userAsset.isAlgo {
            return dataController.account.algo.amount.toAlgos * percentage
        }

        let userAsset = AssetDecoration(asset: dataController.userAsset)
        guard let assetBalance = dataController.account[userAsset.id]?.amount else {
            return 0
        }

        let decimalValue = swapAssetValueFormatter.getDecimalAmount(
            of: assetBalance,
            for: userAsset
        )

        return decimalValue * percentage
    }
}

extension SwapAssetScreen {
    enum Event {
        case didTapUserAsset
        case editAmount
        case didTapPoolAsset
        case didTapSwap
    }
}
