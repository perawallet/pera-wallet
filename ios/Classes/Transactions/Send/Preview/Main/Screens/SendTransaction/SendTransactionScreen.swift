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
//   SendTransactionScreen.swift


import Foundation
import UIKit
import SnapKit
import MagpieHipo
import Alamofire
import MacaroonUIKit
import MacaroonUtils

final class SendTransactionScreen: BaseViewController {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private(set) lazy var modalTransition = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToInsufficientAlgoBalance = BottomSheetTransition(presentingViewController: self)

    private lazy var navigationTitleView = AccountNameTitleView()
    private lazy var nextButton = Button()
    private lazy var accountContainerView = TripleShadowView()
    private lazy var accountView = PrimaryListItemView()
    private lazy var numpadView = NumpadView(mode: .decimal)
    private lazy var noteButton = Button()
    private lazy var maxButton = Button()
    private lazy var currencyValueLabel = UILabel()
    private lazy var valueLabel = UILabel()

    private lazy var currencyFormatter = CurrencyFormatter()

    private let theme = Theme()
    private var draft: SendTransactionDraft
    private let copyToClipboardController: CopyToClipboardController

    private var transactionParams: TransactionParams?

    private var amount: String = "0"
    private var isAmountResetted: Bool = true

    private lazy var amountValidator = TransactionAmountValidator(account: draft.from)

    private var note: String? {
        didSet {
            if draft.lockedNote != nil {
                noteButton.setTitle("send-transaction-show-note-title".localized, for: .normal)
                return
            }

            if !note.isNilOrEmpty {
                noteButton.setTitle("send-transaction-edit-note-title".localized, for: .normal)
            } else {
                noteButton.setTitle("send-transaction-add-note-title".localized, for: .normal)
            }
        }
    }

    private var isMaxTransaction: Bool {
        guard let decimalAmount = amount.decimalAmount else {
            return false
        }
        return draft.from.algo.amount == decimalAmount.toMicroAlgos
    }

    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(
            api: api,
            bannerController: bannerController,
            analytics: analytics
        )
    }()

    private var ledgerApprovalViewController: LedgerApprovalViewController?

    private var transactionSendController: TransactionSendController?

    init(
        draft: SendTransactionDraft,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.draft = draft
        self.copyToClipboardController = copyToClipboardController
        super.init(configuration: configuration)

        guard let amount = draft.amount else {
            return
        }

        switch draft.transactionMode {
        case .algo:
            self.amount = amount.toNumberStringWithSeparatorForLabel ?? "0"
        case .asset(let asset):
            self.amount = amount.toNumberStringWithSeparatorForLabel(fraction: asset.decimals) ?? "0"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getTransactionParams()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isViewFirstAppeared {
            presentTransactionTutorialIfNeeded()
        }
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.backgroundColor = theme.backgroundColor

        if draft.fractionCount <= 0 {
            numpadView.leftButtonIsHidden = true
        }
    }

    override func configureNavigationBarAppearance() {
        addNavigationTitle()
        addNavigationActions()
    }

    override func prepareLayout() {
        super.prepareLayout()

        addNextButton()
        addAccountView()
        addNumpad()
        addButtons()
        addLabels()
    }

    override func bindData() {
        super.bindData()

        bindAssetPreview()
        bindAmount()

        self.note = draft.lockedNote ?? draft.note
    }

    override func linkInteractors() {
        super.linkInteractors()

        numpadView.linkInteractors()
        numpadView.delegate = self

        maxButton.addTarget(self, action: #selector(didTapMax), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        noteButton.addTarget(self, action: #selector(didTapNote), for: .touchUpInside)

        transactionController.delegate = self
    }
}

extension SendTransactionScreen {
    private func presentTransactionTutorialIfNeeded() {
        let transactionTutorialStorage = TransactionTutorialStorage()

        if transactionTutorialStorage.isTransactionTutorialDisplayed {
            return
        }

        transactionTutorialStorage.setTransactionTutorialDisplayed()

        displayTransactionTutorial(isInitialDisplay: true)
    }
}

extension SendTransactionScreen {
    private func bindAssetPreview() {
        let currency = sharedDataController.currency

        let viewModel: PrimaryListItemViewModel

        switch draft.transactionMode {
        case .algo:
            let algoAssetItem = AssetItem(
                asset: draft.from.algo,
                currency: sharedDataController.currency,
                currencyFormatter: currencyFormatter,
                currencyFormattingContext: .standalone()
            )
            viewModel = AssetListItemViewModel(algoAssetItem)
        case .asset(let asset):
            let assetItem = AssetItem(
                asset: asset,
                currency: currency,
                currencyFormatter: currencyFormatter,
                currencyFormattingContext: .standalone()
            )
            viewModel = AssetListItemViewModel(assetItem)
        }

        accountView.bindData(viewModel)
    }

    private func bindAmount() {
        let amountValue = self.amount
        var showingValue = ""

        valueLabel.customizeAppearance(theme.valueLabelStyle)

        if let decimalStrings = amountValue.decimalStrings() {
            switch draft.transactionMode {
            case .algo:
                showingValue = (amountValue.replacingOccurrences(of: decimalStrings, with: "")
                    .decimalAmount?.toNumberStringWithSeparatorForLabel ?? amountValue)
                    .appending(decimalStrings)
            case .asset(let asset):
                showingValue = (amountValue.replacingOccurrences(of: decimalStrings, with: "")
                    .decimalAmount?.toNumberStringWithSeparatorForLabel(fraction: asset.decimals) ?? amountValue)
                    .appending(decimalStrings)
            }
        } else {
            showingValue = amountValue.decimalAmount?.toNumberStringWithSeparatorForLabel ?? amountValue

            if self.amount.decimal.number.intValue == 0 && isAmountResetted {
                if let string = self.amount.decimal.toFractionStringForLabel(fraction: 2) {
                    showingValue = string
                }
                valueLabel.customizeAppearance(theme.disabledValueLabelStyle)
            }
        }

        valueLabel.text = showingValue

        bindCurrencyAmount(amountValue)
    }
    
    private func bindCurrencyAmount(_ amountValue: String) {
        guard let amount = amountValue.decimalAmount else {
            currencyValueLabel.text = nil
            return
        }

        let currency = sharedDataController.currency

        switch draft.transactionMode {
        case .algo:
            guard let currencyValue = currency.fiatValue else {
                currencyValueLabel.text = nil
                return
            }

            do {
                let rawCurrency = try currencyValue.unwrap()

                let exchanger = CurrencyExchanger(currency: rawCurrency)
                let amountInCurrency = try exchanger.exchangeAlgo(amount: amount)

                currencyFormatter.formattingContext = .standalone()
                currencyFormatter.currency = rawCurrency

                currencyValueLabel.text = currencyFormatter.format(amountInCurrency)
            } catch {
                currencyValueLabel.text = nil
            }
        case let .asset(asset):
            guard let currencyValue = currency.primaryValue else {
                currencyValueLabel.text = nil
                return
            }

            do {
                let rawCurrency = try currencyValue.unwrap()

                let exchanger = CurrencyExchanger(currency: rawCurrency)
                let amountInCurrency = try exchanger.exchange(
                    asset,
                    amount: amount
                )

                currencyFormatter.formattingContext = .standalone()
                currencyFormatter.currency = rawCurrency

                currencyValueLabel.text = currencyFormatter.format(amountInCurrency)
            } catch {
                currencyValueLabel.text = nil
            }
        }
    }
}

extension SendTransactionScreen {
    private func displayTransactionTutorial(isInitialDisplay: Bool) {
        modalTransition.perform(
            .transactionTutorial(
                isInitialDisplay: isInitialDisplay
            ),
            by: .presentWithoutNavigationController
        )
    }
}

// MARK: - Layout
extension SendTransactionScreen {
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
        let draft = SendTransactionAccountNameTitleDraft(
            transactionMode: draft.transactionMode,
            account: draft.from
        )
        let viewModel = AccountNameTitleViewModel(draft)
        navigationTitleView.bindData(viewModel)
    }

    private func addNavigationActions() {
        let infoBarButtonItem = ALGBarButtonItem(kind: .info) {
            [unowned self] in
            self.displayTransactionTutorial(isInitialDisplay: false)
        }

        rightBarButtonItems = [ infoBarButtonItem ]
    }

    private func addNextButton() {
        nextButton.customize(theme.nextButtonStyle)
        nextButton.setTitle("title-next".localized, for: .normal)

        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(theme.defaultBottomInset)
            make.leading.trailing.equalToSuperview().inset(theme.defaultLeadingInset)
            make.height.equalTo(theme.nextButtonHeight)
        }
    }

    private func addAccountView() {
        accountView.customize(AssetListItemTheme())

        accountContainerView.drawAppearance(shadow: theme.accountContainerFirstShadow)
        accountContainerView.drawAppearance(secondShadow: theme.accountContainerSecondShadow)
        accountContainerView.drawAppearance(thirdShadow: theme.accountContainerThirdShadow)

        view.addSubview(accountContainerView)
        accountContainerView.snp.makeConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).offset(theme.defaultBottomInset)
            make.leading.trailing.equalToSuperview().inset(theme.defaultLeadingInset)
        }

        accountContainerView.addSubview(accountView)
        accountView.snp.makeConstraints { make in
            make.setPaddings(theme.accountPaddings)
        }
    }

    private func addNumpad() {
        numpadView.customize(TransactionNumpadViewTheme())
        numpadView.deleteButtonIsHidden = self.amount == "0"

        view.addSubview(numpadView)
        numpadView.snp.makeConstraints { make in
            make.bottom.equalTo(accountView.snp.top).offset(theme.numpadBottomInset)
            make.leading.trailing.equalToSuperview()
        }
    }

    private func addButtons() {
        let stackView = HStackView()
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = theme.buttonsSpacing

        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.bottom.equalTo(numpadView.snp.top).offset(theme.buttonsBottomInset)
            make.leading.trailing.equalToSuperview().inset(theme.buttonsLeadingInset)
            make.height.equalTo(theme.buttonsHeight)
        }

        noteButton.setTitle("send-transaction-add-note-title".localized, for: .normal)
        maxButton.setTitle("send-transaction-max-button-title".localized, for: .normal)

        maxButton.customize(TransactionShadowButtonTheme())
        noteButton.customize(TransactionShadowButtonTheme())

        stackView.addArrangedSubview(noteButton)
        stackView.addArrangedSubview(maxButton)
    }

    private func addLabels() {
        let labelStackView = VStackView()
        labelStackView.alignment = .center
        labelStackView.distribution = .equalCentering

        currencyValueLabel.customizeAppearance(theme.currencyValueLabelStyle)
        valueLabel.customizeAppearance(theme.disabledValueLabelStyle)

        view.addSubview(labelStackView)
        labelStackView.snp.makeConstraints { make in
            make.height.equalTo(theme.labelsContainerHeight)
            make.bottom.equalTo(maxButton.snp.top).offset(theme.labelsContainerBottomInset)
            make.leading.trailing.equalToSuperview().inset(theme.defaultLeadingInset)
        }

        labelStackView.addArrangedSubview(valueLabel)
        labelStackView.addArrangedSubview(currencyValueLabel)
    }
}

// MARK: - Actions
extension SendTransactionScreen: TransactionSignChecking {
    @objc
    private func didTapNext() {
        if !canSignTransaction(for: &draft.from) {
            return
        }

        let validation = validate(value: amount)

        switch validation {
        case .success:
            handleSuccessAmountValidation()
        case .failure(let validationError):
            handleFailureAmountError(validationError)
        }
    }

    @objc
    private func didTapMax() {
        numpadView.deleteButtonIsHidden = false

        switch draft.transactionMode {
        case .algo:
            self.amount = draft.from.algo.amount.toAlgos.toNumberStringWithSeparatorForLabel ?? "0"
        case .asset(let asset):
            self.amount = asset.amountWithFraction.toNumberStringWithSeparatorForLabel(fraction: asset.decimals) ?? "0"
        }
        isAmountResetted = false
        bindAmount()
    }

    @objc
    private func didTapNote() {
        let isLocked = draft.lockedNote != nil
        let editNote = draft.lockedNote ?? draft.note
        modalTransition.perform(
            .editNote(note: editNote, isLocked: isLocked, delegate: self),
            by: .present
        )
    }

    private func redirectToPreview() {
        loadingController?.startLoadingWithMessage("title-loading".localized)

        transactionSendController = TransactionSendController(
            draft: draft,
            api: api!,
            analytics: analytics
        )

        transactionSendController?.delegate = self
        transactionSendController?.validate()
    }

    @objc
    private func copyAccountAddress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            copyToClipboardController.copyAddress(draft.from)
        }
    }
}

// MARK: - Validation
extension SendTransactionScreen {
    private func handleSuccessAmountValidation() {
        draft.amount = amount.decimalAmount

        if draft.hasReceiver {
            redirectToPreview()
            return
        }

        let controller = open(
            .transactionAccountSelect(draft: draft),
            by: .push
        ) as? AccountSelectScreen

        controller?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .didCompleteTransaction:
                self.eventHandler?(.didCompleteTransaction)
            }
        }
    }

    private func handleFailureAmountError(_ validation: TransactionAmountValidationError) {
        switch validation {
        case .asset(let assetTransactionAmountError):
            handleFailureAssetAmountError(assetTransactionAmountError)
        case .algo(let algoTransactionAmountError):
            handleFailureAlgoAmountError(algoTransactionAmountError)
        case .transactionParamsMissing, .unexpected:
            handleErrorMessage("default-error-message".localized)
        }
    }

    private func handleFailureAssetAmountError(_ validation: TransactionAmountAssetError) {
        switch validation {
        case .exceededLimit:
            handleErrorMessage("send-asset-amount-error".localized)
        case .requiredMinimumBalance:
            displayRequiredMinAlgoWarning()
        }
    }

    private func handleFailureAlgoAmountError(_ validation: TransactionAmountAlgoError) {
        switch validation {
        case .exceededLimit:
            handleErrorMessage("send-algos-amount-error".localized)
        case .requiredMinimumBalance:
            displayMaxTransactionWarning()
        case .participationKey:
            presentParticipationKeyWarningForMaxTransaction()
        case .lowBalance:
            displayRequiredMinAlgoWarning()
        }
    }

    private func handleErrorMessage(_ errorMessage: String) {
        let errorTitle = "title-error".localized

        bannerController?.presentErrorBanner(
            title: errorTitle,
            message: errorMessage
        )
    }
}

extension SendTransactionScreen {
    private func displayRequiredMinAlgoWarning() {
        let algoAssetItem = AssetItem(
            asset: draft.from.algo,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter,
            currencyFormattingContext: .standalone()
        )

        let draft = InsufficientAlgoBalanceDraft(algoAssetItem: algoAssetItem)

        let screen = Screen.insufficientAlgoBalance(draft: draft) {
            [unowned self] event in
            self.dismiss(animated: true)
        }

        transitionToInsufficientAlgoBalance.perform(
            screen,
            by: .presentWithoutNavigationController
        )
    }
}

extension SendTransactionScreen {
    private func displayMaxTransactionWarning() {
        guard let transactionParams = transactionParams else {
            return
        }

        let viewModel = MaximumBalanceWarningViewModel(draft.from, transactionParams)

        var bottomWarningDescription: BottomWarningViewConfigurator.BottomWarningDescription?

        if let description = viewModel.description {
            bottomWarningDescription = .plain(description)
        }

        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-red".uiImage,
            title: "min-balance-title".localized,
            description: bottomWarningDescription,
            primaryActionButtonTitle: "title-continue".localized,
            secondaryActionButtonTitle: "title-cancel".localized,
            primaryAction: {
                [weak self] in
                guard let self = self else {
                    return
                }

                self.amount = self.draft.from.algo.amount.toAlgos.toNumberStringWithSeparatorForLabel ?? "0"
                self.handleSuccessAmountValidation()
            }
        )

        modalTransition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
    }
}

// MARK: - NumpadViewDelegate
extension SendTransactionScreen: NumpadViewDelegate {
    func numpadView(_ numpadView: NumpadView, didSelect value: NumpadButton.NumpadKey) {
        var newValue = amount

        let hasDraftFraction = draft.fractionCount > 0

        if hasDraftFraction &&
            newValue.fractionCount >= draft.fractionCount &&
            value != .delete {
            return
        }

        switch value {
        case .number(let numberValue):
            if amount == "0" {
                isAmountResetted = false
                newValue = numberValue
            } else {
                newValue.append(contentsOf: numberValue)
            }
        case .spacing:
            return
        case .delete:
            if amount.count == 1 {
                isAmountResetted = true
                newValue = "0"
            } else if amount == "0" {
                return
            } else {
                newValue.removeLast(1)
            }
        case .decimalSeparator:
            guard hasDraftFraction else {
                return
            }

            let decimalSeparator = Locale.current.decimalSeparator?.first ?? "."

            if amount.contains(decimalSeparator) {
                return
            }
            newValue.append(decimalSeparator)
        }

        amount = newValue
        numpadView.deleteButtonIsHidden = amount == "0" && isAmountResetted
        bindAmount()
    }

    private func validate(value: String) -> TransactionAmountValidation {
        guard let decimalAmount = value.decimalAmount else {
            return .failure(.unexpected)
        }

        let asset: Asset?

        switch draft.transactionMode {
        case .algo:
            asset = nil
        case .asset(let selectedAsset):
            asset = selectedAsset
        }

        return amountValidator.validate(amount: decimalAmount, on: asset)
    }

    private func presentParticipationKeyWarningForMaxTransaction() {
        let alertController = UIAlertController(
            title: "send-algos-account-delete-title".localized,
            message: "send-algos-account-delete-body".localized,
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel)

        let proceedAction = UIAlertAction(title: "title-proceed".localized, style: .destructive) { _ in
            self.displayMaxTransactionWarning()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(proceedAction)

        present(alertController, animated: true, completion: nil)
    }

    private func getTransactionParams() {
        api?.getTransactionParams { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .success(params):
                self.transactionParams = params
                self.amountValidator.setTransactionParams(params)
            case .failure:
                break
            }
        }
    }
}

// MARK: - EditNoteScreenDelegate
extension SendTransactionScreen: EditNoteScreenDelegate {
    func editNoteScreen(
        _ editNoteScreen: EditNoteScreen,
        didUpdateNote note: String?
    ) {
        self.note = note
        self.draft.note = note
    }
}

// MARK: - TransactionControllerDelegate
extension SendTransactionScreen: TransactionControllerDelegate {
    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        loadingController?.stopLoading()

        switch error {
        case .network:
            displaySimpleAlertWith(title: "title-error".localized, message: "title-internet-connection".localized)
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        loadingController?.stopLoading()

        guard let draft = draft else {
            return
        }

        let controller = open(
            .sendTransactionPreview(
                draft: draft,
                transactionController: transactionController
            ),
            by: .push
        ) as? SendTransactionPreviewScreen

        controller?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .didCompleteTransaction:
                self.eventHandler?(.didCompleteTransaction)
            }
        }
    }

    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let amountText = currencyFormatter.format(amount.toAlgos)

            bannerController?.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "send-algos-minimum-amount-custom-error".localized(
                    params: amountText.someString
                )
            )
        case .invalidAddress:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "send-algos-receiver-address-validation".localized
            )
        case let .sdkError(error):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.debugDescription
            )
        case .ledgerConnection:
            let bottomTransition = BottomSheetTransition(presentingViewController: self)

            bottomTransition.perform(
                .bottomWarning(
                    configurator: BottomWarningViewConfigurator(
                        image: "img-warning-circle".uiImage,
                        title: "ledger-pairing-issue-error-title".localized,
                        description: .plain("ble-error-fail-ble-connection-repairing".localized),
                        secondaryActionButtonTitle: "title-ok".localized
                    )
                ),
                by: .presentWithoutNavigationController
            )
        default:
            displaySimpleAlertWith(
                title: "title-error".localized,
                message: "title-internet-connection".localized
            )
        }
    }

    func transactionController(_ transactionController: TransactionController, didRequestUserApprovalFrom ledger: String) {
        let ledgerApprovalTransition = BottomSheetTransition(
            presentingViewController: self,
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
                self.loadingController?.stopLoading()
            }
        }
    }
    func transactionControllerDidResetLedgerOperation(_ transactionController: TransactionController) {
        ledgerApprovalViewController?.dismissScreen()
    }

    func transactionControllerDidRejectedLedgerOperation(
        _ transactionController: TransactionController
    ) {
        loadingController?.stopLoading()
    }
}

// MARK: - TransactionSendControllerDelegate
extension SendTransactionScreen: TransactionSendControllerDelegate {
    func transactionSendControllerDidValidate(_ controller: TransactionSendController) {
        stopLoadingIfNeeded { [weak self] in
            guard let self = self else {
                return
            }

            switch self.draft.transactionMode {
            case .algo:
                self.composeAlgosTransactionData()
            case .asset:
                self.composeAssetTransactionData()
            }
        }
    }

    func transactionSendController(
        _ controller: TransactionSendController,
        didFailValidation error: TransactionSendControllerError
    ) {
        stopLoadingIfNeeded { [weak self] in
            guard let self = self else {
                return
            }

            switch error {
            case .closingSameAccount:
                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "send-transaction-max-same-account-error".localized
                )
            case .algo(let algoError):
                switch algoError {
                case .algoAddressNotSelected:
                    self.bannerController?.presentErrorBanner(
                        title: "title-error".localized,
                        message: "send-algos-address-not-selected".localized
                    )
                case .invalidAddressSelected:
                    self.bannerController?.presentErrorBanner(
                        title: "title-error".localized,
                        message: "send-algos-receiver-address-validation".localized
                    )
                case .minimumAmount:
                    let configurator = BottomWarningViewConfigurator(
                        image: "icon-info-red".uiImage,
                        title: "send-algos-minimum-amount-error-new-account-title".localized,
                        description: .plain("send-algos-minimum-amount-error-new-account-description".localized),
                        secondaryActionButtonTitle: "title-i-understand".localized
                    )

                    self.modalTransition.perform(
                        .bottomWarning(configurator: configurator),
                        by: .presentWithoutNavigationController
                    )
                }
            case .asset(let assetError):
                switch assetError {
                case .assetNotSupported(let address):
                    self.presentAssetNotSupportedAlert(receiverAddress: address)
                case .minimumAmount:
                    self.bannerController?.presentErrorBanner(
                        title: "title-error".localized,
                        message: "send-asset-amount-error".localized
                    )
                }
            case .amountNotSpecified, .mismatchReceiverAddress:
                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "send-algos-receiver-address-validation".localized
                )
            case .internetConnection:
                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "title-internet-connection".localized
                )
            }
        }
    }

    private func stopLoadingIfNeeded(execute: @escaping () -> Void) {
        guard !draft.from.requiresLedgerConnection() else {
            execute()
            return
        }

        loadingController?.stopLoadingAfter(seconds: 0.3, on: .main) {
            execute()
        }
    }
}

// MARK: - Compose Transaction
extension SendTransactionScreen {
    private func composeAlgosTransactionData() {
        var transactionDraft = AlgosTransactionSendDraft(
            from: draft.from,
            toAccount: draft.toAccount,
            amount: draft.amount,
            fee: nil,
            isMaxTransaction: draft.isMaxTransaction,
            identifier: nil,
            note: draft.note
        )
        transactionDraft.toContact = draft.toContact
        transactionDraft.nameService = draft.nameService

        transactionController.delegate = self
        transactionController.setTransactionDraft(transactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .algosTransaction)

        if draft.from.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }

    private func composeAssetTransactionData() {
        guard let asset = draft.asset else {
            return
        }

        var transactionDraft = AssetTransactionSendDraft(
            from: draft.from,
            toAccount: draft.toAccount,
            amount: draft.amount,
            assetIndex: asset.id,
            assetDecimalFraction: asset.decimals,
            isVerifiedAsset: asset.verificationTier.isVerified,
            note: draft.note
        )
        transactionDraft.toContact = draft.toContact
        transactionDraft.asset = asset
        transactionDraft.nameService = draft.nameService

        transactionController.delegate = self
        transactionController.setTransactionDraft(transactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetTransaction)

        if draft.from.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }

    private func presentAssetNotSupportedAlert(receiverAddress: String?) {
        guard let asset = draft.asset else {
            return
        }

        let assetAlertDraft = AssetAlertDraft(
            account: draft.from,
            assetId: asset.id,
            asset: AssetDecoration(asset: asset),
            title: "asset-support-title".localized,
            detail: "asset-support-error".localized,
            actionTitle: "title-ok".localized
        )

        let senderAddress = draft.from.address
        if let receiverAddress = receiverAddress {
            let draft = AssetSupportDraft(
                sender: senderAddress,
                receiver: receiverAddress,
                assetId: asset.id
            )
            api?.sendAssetSupportRequest(draft)
        }

        modalTransition.perform(
            .assetActionConfirmation(assetAlertDraft: assetAlertDraft, delegate: nil),
            by: .presentWithoutNavigationController
        )
    }
}

extension SendTransactionScreen {
    enum Event {
        case didCompleteTransaction
    }
}
