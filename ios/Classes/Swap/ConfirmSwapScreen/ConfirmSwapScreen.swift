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

//   ConfirmSwapScreen.swift

import MacaroonUIKit
import MagpieExceptions
import MagpieHipo
import UIKit

final class ConfirmSwapScreen:
    BaseScrollViewController,
    SwapSlippageTolerancePercentageStoreObserver {
    typealias DataStore = SwapSlippageTolerancePercentageStore
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var navigationTitleView = AccountNameTitleView()
    private lazy var userAssetView = SwapAssetAmountView()
    private lazy var toSeparatorView = TitleSeparatorView()
    private lazy var poolAssetView = SwapAssetAmountView()
    private lazy var priceInfoView = SwapInfoActionItemView()
    private lazy var slippageInfoView = SwapInfoActionItemView()
    private var poolAssetBottomSeparator: UIView?
    private lazy var priceImpactInfoView = SwapInfoItemView()
    private lazy var minimumReceivedInfoView = SwapInfoItemView()
    private lazy var exchangeFeeInfoView = SwapInfoItemView()
    private lazy var peraFeeInfoView = SwapInfoItemView()
    private lazy var warningView = SwapErrorView()
    private lazy var confirmActionView: LoadingButton = {
        let loadingIndicator = ViewLoadingIndicator()
        loadingIndicator.applyStyle(theme.confirmActionIndicator)
        return LoadingButton(loadingIndicator: loadingIndicator)
    }()

    private lazy var transitionToHighPriceImpactWarning = BottomSheetTransition(presentingViewController: self)

    private var viewModel: ConfirmSwapScreenViewModel?  {
        didSet { updateWarningConstraintsIfNeeded(old: oldValue) }
    }

    private var isPriceReversed = false

    private let dataStore: DataStore
    private let currencyFormatter: CurrencyFormatter
    private let dataController: ConfirmSwapDataController
    private let copyToClipboardController: CopyToClipboardController
    private let theme: ConfirmSwapScreenTheme

    init(
        dataStore: DataStore,
        dataController: ConfirmSwapDataController,
        copyToClipboardController: CopyToClipboardController,
        theme: ConfirmSwapScreenTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.dataStore = dataStore
        self.currencyFormatter = CurrencyFormatter()
        self.dataController = dataController
        self.copyToClipboardController = copyToClipboardController
        self.theme = theme
        super.init(configuration: configuration)

        dataStore.add(self)
    }

    deinit {
        dataStore.remove(self)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        addNavigationTitle()

        let flexibleSpaceItem = ALGBarButtonItem.flexibleSpace()
        self.rightBarButtonItems = [ flexibleSpaceItem ]
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeAppearance(theme.background)
    }

    override func setListeners() {
        super.setListeners()
        registerDataControllerEvents()
    }

    override func prepareLayout() {
        super.prepareLayout()
        addUserAsset()
        addToSeparator()
        addWarning()
        addPeraFeeInfo()
        addExchangeFeeInfo()
        addMinimumReceivedInfo()
        addPriceImpactInfo()
        addSlippageInfo()
        addPriceInfo()
        addPoolAsset()
        addConfirmAction()
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

    override func bindData() {
        super.bindData()
        bindData(dataController.quote)
    }
}

/// <mark>
/// SwapSlippageTolerancePercentageStoreObserver
extension ConfirmSwapScreen {
    func swapSlippageTolerancePercentageDidChange() {
        dataController.updateSlippageTolerancePercentage(percentage: dataStore.slippageTolerancePercentage)
    }
}

extension ConfirmSwapScreen {
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
            title: "swap-confirm-title".localized,
            account: dataController.account
        )

        let viewModel = AccountNameTitleViewModel(draft)
        navigationTitleView.bindData(viewModel)
    }
}

extension ConfirmSwapScreen {
    private func registerDataControllerEvents() {
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .willUpdateSlippage:
                self.updateUIWhenWillUpdateSlippage()
            case .didUpdateSlippage(let quote):
                self.updateUIWhenDidUpdateSlippage(quote)
            case .didFailToUpdateSlippage(let error):
                self.updateUIWhenDidFailToUpdateSlippage(error)
            case .willPrepareTransactions:
                self.updateUIWhenWillPrepareTransactions()
            case .didPrepareTransactions(let swapTransactionPreparation):
                self.updateUIWhenDidPrepareTransactions(swapTransactionPreparation)
            case .didFailToPrepareTransactions(let error):
                self.updateUIWhenDidFailToPrepareTransactions(error)
            }
        }
    }
}

extension ConfirmSwapScreen {
    private func addUserAsset() {
        userAssetView.customize(theme.userAsset)

        contentView.addSubview(userAssetView)
        userAssetView.fitToIntrinsicSize()
        userAssetView.snp.makeConstraints {
            $0.top <= theme.userAssetTopInset
            $0.top >= theme.minimumUserAssetTopInset
            $0.leading == theme.assetHorizontalInset
            $0.trailing == theme.assetHorizontalInset
        }
    }

    private func addToSeparator() {
        toSeparatorView.customize(theme.toSeparator)

        contentView.addSubview(toSeparatorView)
        toSeparatorView.fitToIntrinsicSize()
        toSeparatorView.snp.makeConstraints {
            $0.top == userAssetView.snp.bottom + theme.toSeparatorTopInset
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addConfirmAction() {
        confirmActionView.customizeAppearance(theme.confirmAction)

        footerView.addSubview(confirmActionView)
        confirmActionView.contentEdgeInsets = theme.confirmActionContentEdgeInsets
        confirmActionView.fitToIntrinsicSize()
        confirmActionView.snp.makeConstraints {
            $0.fitToHeight(theme.confirmActionHeight)
            $0.top ==  theme.confirmActionEdgeInsets.top
            $0.leading == theme.confirmActionEdgeInsets.leading
            $0.bottom == theme.confirmActionEdgeInsets.bottom
            $0.trailing == theme.confirmActionEdgeInsets.trailing
         }

        confirmActionView.addTouch(
            target: self,
            action: #selector(didTapConfirmSwap)
        )
    }

    private func addWarning() {
        warningView.customize(theme.warning)

        contentView.addSubview(warningView)
        warningView.fitToIntrinsicSize()
        warningView.snp.makeConstraints {
            $0.leading == theme.infoSectionPaddings.leading
            $0.bottom == 0
            $0.trailing == theme.infoSectionPaddings.trailing
        }

        warningView.eventHandlers.messageHyperlinkHandler = {
            [unowned self] url in
            self.open(url)
        }
    }

    private func addPeraFeeInfo() {
        peraFeeInfoView.customize(theme.infoItem)

        contentView.addSubview(peraFeeInfoView)
        peraFeeInfoView.fitToIntrinsicSize()
        peraFeeInfoView.snp.makeConstraints {
            $0.leading == theme.infoSectionPaddings.leading
            $0.bottom == warningView.snp.top
            $0.trailing == theme.infoSectionPaddings.trailing
        }
    }

    private func addExchangeFeeInfo() {
        exchangeFeeInfoView.customize(theme.infoItem)

        contentView.addSubview(exchangeFeeInfoView)
        exchangeFeeInfoView.fitToIntrinsicSize()
        exchangeFeeInfoView.snp.makeConstraints {
            $0.leading == theme.infoSectionPaddings.leading
            $0.bottom == peraFeeInfoView.snp.top - theme.infoSectionItemSpacing
            $0.trailing == theme.infoSectionPaddings.trailing
        }

        exchangeFeeInfoView.startObserving(event: .didTapInfo) {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(.didTapExchangeFeeInfo)
        }
    }

    private func addMinimumReceivedInfo() {
        minimumReceivedInfoView.customize(theme.infoItem)

        contentView.addSubview(minimumReceivedInfoView)
        minimumReceivedInfoView.fitToIntrinsicSize()
        minimumReceivedInfoView.snp.makeConstraints {
            $0.leading == theme.infoSectionPaddings.leading
            $0.bottom == exchangeFeeInfoView.snp.top - theme.infoSectionItemSpacing
            $0.trailing == theme.infoSectionPaddings.trailing
        }
    }

    private func addPriceImpactInfo() {
        priceImpactInfoView.customize(theme.infoItem)

        contentView.addSubview(priceImpactInfoView)
        priceImpactInfoView.fitToIntrinsicSize()
        priceImpactInfoView.snp.makeConstraints {
            $0.leading == theme.infoSectionPaddings.leading
            $0.bottom == minimumReceivedInfoView.snp.top - theme.infoSectionItemSpacing
            $0.trailing == theme.infoSectionPaddings.trailing
        }

        priceImpactInfoView.startObserving(event: .didTapInfo) {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(.didTapPriceImpactInfo)
        }
    }

    private func addSlippageInfo() {
        slippageInfoView.customize(theme.infoActionItem)

        contentView.addSubview(slippageInfoView)
        slippageInfoView.fitToIntrinsicSize()
        slippageInfoView.snp.makeConstraints {
            $0.leading == theme.infoSectionPaddings.leading
            $0.bottom == priceImpactInfoView.snp.top - theme.infoSectionItemSpacing
            $0.trailing == theme.infoSectionPaddings.trailing
        }

        slippageInfoView.startObserving(event: .didTapInfo) {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(.didTapSlippageInfo)
        }

        slippageInfoView.startObserving(event: .didTapAction) {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(.didTapSlippageAction)
        }
    }

    private func addPriceInfo() {
        priceInfoView.customize(theme.infoActionItem)

        contentView.addSubview(priceInfoView)
        priceInfoView.fitToIntrinsicSize()
        priceInfoView.snp.makeConstraints {
            $0.leading == theme.infoSectionPaddings.leading
            $0.bottom == slippageInfoView.snp.top - theme.infoSectionItemSpacing
            $0.trailing == theme.infoSectionPaddings.trailing
        }

        priceInfoView.startObserving(event: .didTapAction) {
            [weak self] in
            guard let self = self else { return }

            self.switchPriceValuePresentation()
        }

        poolAssetBottomSeparator = contentView.attachSeparator(
            theme.assetSeparator,
            to: priceInfoView,
            margin: theme.infoSectionPaddings.top
        )
    }

    private func addPoolAsset() {
        guard let poolAssetBottomSeparator else { return }

        poolAssetView.customize(theme.poolAsset)

        contentView.addSubview(poolAssetView)
        poolAssetView.fitToIntrinsicSize()
        poolAssetView.snp.makeConstraints {
            $0.top == toSeparatorView.snp.bottom + theme.poolAssetTopInset
            $0.leading == theme.assetHorizontalInset
            $0.bottom == poolAssetBottomSeparator.snp.top - theme.spacingBetweenToPoolAssetAndInfoSeparator
            $0.trailing == theme.assetHorizontalInset
        }
    }
}

extension ConfirmSwapScreen {
    private func updateUIWhenWillUpdateSlippage() {
        confirmActionView.startLoading()
    }

    private func updateUIWhenDidUpdateSlippage(
        _ quote: SwapQuote
    ) {
        confirmActionView.stopLoading()
        bannerController?.presentSuccessBanner(title: "swap-confirm-slippage-updated-title".localized)
        bindData(quote)
    }

    private func updateUIWhenDidFailToUpdateSlippage(
        _ error: HIPNetworkError<HIPAPIError>
    ) {
        confirmActionView.stopLoading()
        displayError(error)
    }

    private func updateUIWhenWillPrepareTransactions() {
        confirmActionView.startLoading()
    }

    private func updateUIWhenDidPrepareTransactions(
        _ swapTransactionPreparation: SwapTransactionPreparation
    ) {
        confirmActionView.stopLoading()
        analytics.track(.tapConfirmSwap())
        eventHandler?(.didTapConfirm(swapTransactionPreparation))
    }

    private func updateUIWhenDidFailToPrepareTransactions(
        _ error: HIPNetworkError<HIPAPIError>
    ) {
        confirmActionView.stopLoading()
        displayError(error)
    }
}

extension ConfirmSwapScreen {
    func bindData(
        _ quote: SwapQuote
    ) {
        viewModel = ConfirmSwapScreenViewModel(
            account: dataController.account,
            quote: quote,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
        userAssetView.bindData(viewModel?.userAsset)
        toSeparatorView.bindData(viewModel?.toSeparator)
        poolAssetView.bindData(viewModel?.poolAsset)
        priceInfoView.bindData(viewModel?.priceInfo)
        slippageInfoView.bindData(viewModel?.slippageInfo)
        priceImpactInfoView.bindData(viewModel?.priceImpactInfo)
        minimumReceivedInfoView.bindData(viewModel?.minimumReceivedInfo)
        exchangeFeeInfoView.bindData(viewModel?.exchangeFeeInfo)
        peraFeeInfoView.bindData(viewModel?.peraFeeInfo)
        warningView.bindData(viewModel?.warning)
        confirmActionView.isEnabled = viewModel?.isConfirmActionEnabled ?? true
    }

    private func switchPriceValuePresentation() {
        guard var priceInfoViewModel = viewModel?.priceInfo as? SwapConfirmPriceInfoViewModel else { return }

        isPriceReversed.toggle()

        priceInfoViewModel.bindDetail(
            quote: dataController.quote,
            isPriceReversed: isPriceReversed,
            currencyFormatter: currencyFormatter
        )
        priceInfoView.bindData(priceInfoViewModel)
    }

    private func displayError(
        _ error: HIPNetworkError<HIPAPIError>
    ) {
        switch error {
        case .client(_, let apiError):
            if apiError?.type == APIErrorType.tinymanExcessAmount.rawValue {
                displayError(apiError?.fallbackMessage ?? error.prettyDescription) {
                    [weak self] in
                    guard let self = self else { return }

                    guard let tinymanURL = AlgorandWeb.tinymanSwapMain.link else { return }
                    self.openInBrowser(tinymanURL)
                }
                return
            }

            displayError(apiError?.fallbackMessage ?? error.prettyDescription)
        case .server(_, let apiError):
            displayError(apiError?.fallbackMessage ?? error.prettyDescription)
        case .connection:
            displayError("title-internet-connection".localized)
        case .unexpected:
            displayError("title-generic-api-error".localized)
        }
    }

    private func displayError(
        _ message: String,
        _ completion: (() -> Void)? = nil
    ) {
        bannerController?.presentErrorBanner(
            title: "swap-confirm-failed-title".localized,
            message: message,
            completion
        )
    }
}

extension ConfirmSwapScreen {
    private func updateWarningConstraintsIfNeeded(old: ConfirmSwapScreenViewModel?) {
        let isOldWarningVisible = old?.warning != nil
        let isNewWarningVisible = viewModel?.warning != nil

        if isOldWarningVisible == isNewWarningVisible {
            return
        }

        peraFeeInfoView.snp.updateConstraints {
            let topInset = isNewWarningVisible ? theme.warningTopInset : .zero
            $0.bottom == warningView.snp.top - topInset
        }
    }
}

extension ConfirmSwapScreen {
    @objc
    private func copyAccountAddress(
        _ recognizer: UILongPressGestureRecognizer
    ) {
        if recognizer.state == .began {
            copyToClipboardController.copyAddress(dataController.account)
        }
    }

    @objc
    private func didTapConfirmSwap() {
        if let priceImpact = dataController.quote.priceImpact,
           priceImpact > PriceImpactLimit.tenPercent && priceImpact <= PriceImpactLimit.fifteenPercent {
            presentWarningForHighPriceImpact()
            return
        }

        confirmSwap()
    }

    private func confirmSwap() {
        dataController.confirmSwap()
    }
}

extension ConfirmSwapScreen {
    private func presentWarningForHighPriceImpact() {
        let title =
            "swap-high-price-impact-warning-title"
                .localized
                .bodyLargeMedium(alignment: .center)
        let body = makeHighPriceImpactWarningBody()

        let uiSheet = UISheet(
            image: "icon-info-red",
            title: title,
            body: body
        )

        uiSheet.bodyHyperlinkHandler = {
            [unowned self] in
            let visibleScreen = self.findVisibleScreen()
            visibleScreen.open(AlgorandWeb.tinymanSwapPriceImpact.link)
        }

        let confirmAction = makeHighPriceImpactWarningConfirmAction()
        uiSheet.addAction(confirmAction)

        let cancelAction = makeHighPriceImpactWarningCancelAction()
        uiSheet.addAction(cancelAction)

        transitionToHighPriceImpactWarning.perform(
            .sheetAction(
                sheet: uiSheet,
                theme: UISheetActionScreenImageTheme()
            ),
            by: .presentWithoutNavigationController
        )
    }

    private func makeHighPriceImpactWarningBody() -> UISheetBodyTextProvider {
        let body = "swap-high-price-impact-warning-body".localized
        let bodyHighlightedText = "swap-high-price-impact-warning-body-highlighted-text".localized

        var bodyHighlightedTextAttributes = Typography.bodyMediumAttributes(alignment: .center)
        bodyHighlightedTextAttributes.insert(.textColor(Colors.Helpers.positive.uiColor))

        let uiSheetBodyHighlightedText = UISheet.HighlightedText(
            text: bodyHighlightedText,
            attributes: bodyHighlightedTextAttributes
        )
        let uiSheetBody = UISheetBodyTextProvider(
            text: body.bodyRegular(alignment: .center),
            highlightedText: uiSheetBodyHighlightedText
        )

        return uiSheetBody
    }

    private func makeHighPriceImpactWarningConfirmAction() -> UISheetAction {
        return UISheetAction(
            title: "swap-confirm-title".localized,
            style: .default
        ) { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true) {
                self.confirmSwap()
            }
        }
    }

    private func makeHighPriceImpactWarningCancelAction() -> UISheetAction {
        return UISheetAction(
            title: "title-cancel".localized,
            style: .cancel
        ) { [unowned self] in
            self.dismiss(animated: true)
        }
    }
}

extension ConfirmSwapScreen {
    enum Event {
        case didTapConfirm(SwapTransactionPreparation)
        case didTapSlippageInfo
        case didTapSlippageAction
        case didTapPriceImpactInfo
        case didTapExchangeFeeInfo
    }
}
