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

final class SendTransactionScreen: BaseViewController {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private(set) lazy var modalTransition = BottomSheetTransition(presentingViewController: self)

    private lazy var nextButton = Button()
    private lazy var accountContainerView = TripleShadowView()
    private lazy var accountView = AssetPreviewView()
    private lazy var numpadView = NumpadView(mode: .decimal)
    private lazy var noteButton = Button()
    private lazy var maxButton = Button()
    private lazy var currencyValueLabel = UILabel()
    private lazy var valueLabel = UILabel()

    private let theme = Theme()
    private var draft: SendTransactionDraft

    private var transactionParams: TransactionParams?

    private var amount: String = "0"
    private var isAmountResetted: Bool = true

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
        return draft.from.amount == decimalAmount.toMicroAlgos
    }

    private var isViewFirstAppeared = true

    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(api: api, bannerController: bannerController)
    }()

    private var ledgerApprovalViewController: LedgerApprovalViewController?

    private var transactionSendController: TransactionSendController?

    init(draft: SendTransactionDraft, configuration: ViewControllerConfiguration) {
        self.draft = draft
        super.init(configuration: configuration)

        guard let amount = draft.amount else {
            return
        }

        switch draft.transactionMode {
        case .algo:
            self.amount = amount.toNumberStringWithSeparatorForLabel ?? "0"
        case .asset(let asset):
            self.amount = amount.toNumberStringWithSeparatorForLabel(fraction: asset.presentation.decimals) ?? "0"
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
            isViewFirstAppeared = false
        }
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.backgroundColor = theme.backgroundColor

        switch draft.transactionMode {
        case .asset(let asset):
            title = "send-transaction-title".localized(asset.presentation.displayNames.primaryName)
        case .algo:
            title = "send-transaction-title".localized("asset-algos-title".localized)
        }

        if draft.fractionCount <= 0 {
            numpadView.leftButtonIsHidden = true
        }
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        addBarButtons()
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
        let currency = sharedDataController.currency.value

        let viewModel: AssetPreviewViewModel

        switch draft.transactionMode {
        case .algo:
            viewModel = AssetPreviewViewModel(
                AssetPreviewModelAdapter.adapt((draft.from, currency))
            )
        case .asset(let asset):

            if let collectibleAsset = asset as? CollectibleAsset {
                let draft = CollectibleAssetSelectionDraft(
                    currency: currency,
                    asset: collectibleAsset
                )
                viewModel = AssetPreviewViewModel(draft)
            } else {
                viewModel = AssetPreviewViewModel(
                    AssetPreviewModelAdapter.adaptAssetSelection((asset, currency))
                )
            }
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
                    .decimalAmount?.toNumberStringWithSeparatorForLabel(fraction: asset.presentation.decimals) ?? amountValue)
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

        bindCurrencyAmount(amountValue, currency: sharedDataController.currency.value)
        valueLabel.text = showingValue
    }
    
    private func bindCurrencyAmount(_ amountValue: String, currency: Currency?) {
        guard let currency = currency,
              let currencyPriceValue = currency.priceValue,
              let amount = amountValue.decimalAmount  else {
            currencyValueLabel.text = nil
            return
        }

        switch draft.transactionMode {
        case let .asset(asset):
            if let standardAsset = asset as? StandardAsset,
               let assetUSDValue = standardAsset.usdValue,
               let currencyUsdValue = currency.usdValue {
                let currencyValue = assetUSDValue * amount * currencyUsdValue
                currencyValueLabel.text = currencyValue.toCurrencyStringForLabel(with: currency.symbol)
            } else {
                currencyValueLabel.text = nil
            }
        case .algo:
            if let algoCurrency = currency as? AlgoCurrency {
                bindCurrencyAmount(amountValue, currency: algoCurrency.currency)
                return
            }
            
            let currencyValue = currencyPriceValue * amount
            currencyValueLabel.text = currencyValue.toCurrencyStringForLabel(with: currency.symbol)
        }
    }
}

extension SendTransactionScreen {
    private func addBarButtons() {
        let infoBarButtonItem = ALGBarButtonItem(kind: .info) { [weak self] in
            self?.displayTransactionTutorial(isInitialDisplay: false)
        }

        rightBarButtonItems = [infoBarButtonItem]
    }
    
    private func displayTransactionTutorial(isInitialDisplay: Bool) {
        modalTransition.perform(
            .transactionTutorial(
                isInitialDisplay: isInitialDisplay
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension SendTransactionScreen {
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
        accountView.customize(AssetPreviewViewTheme())

        accountContainerView.draw(corner: theme.accountContainerCorner)
        accountContainerView.drawAppearance(border: theme.accountContainerBorder)

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

        maxButton.drawAppearance(border: theme.accountContainerBorder)
        noteButton.drawAppearance(border: theme.accountContainerBorder)
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

extension SendTransactionScreen: TransactionSignChecking {
    @objc
    private func didTapNext() {
        if !canSignTransaction(for: &draft.from) {
            return
        }

        let validation = validate(value: amount)

        let errorTitle: String
        let errorMessage: String

        switch validation {
        case .otherAlgo:
            errorTitle = "title-error".localized
            errorMessage = "send-algos-minimum-amount-error".localized
        case .minimumAmountAlgoError:
            errorTitle = "title-error".localized
            errorMessage = "send-algos-minimum-amount-error".localized
        case .maximumAmountAlgoError:
            errorTitle = "title-error".localized
            errorMessage = "send-algos-amount-error".localized
        case .minimumAmountAssetError:
            errorTitle = "title-error".localized
            errorMessage = "send-asset-amount-error".localized
        case .otherAsset:
            errorTitle = "title-error".localized
            errorMessage = "send-asset-amount-error".localized
        case .valid:
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
            return
        case .algoParticipationKeyWarning:
            self.presentParticipationKeyWarningForMaxTransaction()
            return
        case .maxAlgo:
            self.displayMaxTransactionWarning()
            return
        case .requiredMinAlgo:
            self.displayRequiredMinAlgoWarning()
            return
        }

        bannerController?.presentErrorBanner(
            title: errorTitle,
            message: errorMessage
        )
    }

    @objc
    private func didTapMax() {
        numpadView.deleteButtonIsHidden = false

        switch draft.transactionMode {
        case .algo:
            self.amount = draft.from.amount.toAlgos.toNumberStringWithSeparatorForLabel ?? "0"
        case .asset(let asset):
            self.amount = asset.amountNumberWithAutoFraction ?? "0"
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
            api: api!
        )

        transactionSendController?.delegate = self
        transactionSendController?.validate()
    }
}

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

            let decimalSeparator = Locale.preferred().decimalSeparator?.first ?? "."

            if amount.contains(decimalSeparator) {
                return
            }
            newValue.append(decimalSeparator)
        }

        amount = newValue
        numpadView.deleteButtonIsHidden = amount == "0" && isAmountResetted
        bindAmount()
    }

    private func validate(value: String) -> TransactionValidation {
        switch draft.transactionMode {
        case .algo:
            return validateAlgo(for: value)
        case .asset(let asset):
            return validateAsset(for: value, on: asset)
        }

    }

    private func validateAlgo(for value: String) -> TransactionValidation {
        guard let decimalAmount = value.decimalAmount else {
            return .otherAlgo
        }

        if draft.from.amount < UInt64(decimalAmount.toMicroAlgos) {
            return .maximumAmountAlgoError
        }

        if Int(draft.from.amount) - Int(decimalAmount.toMicroAlgos) - Int(minimumFee) < calculateMininmumAmount(for: draft.from) {
            
            if Int(decimalAmount.toMicroAlgos) <= Int(calculateMininmumAmount(for: draft.from)) + Int(minimumFee) {
                return .requiredMinAlgo
            }
            
            return .maxAlgo
        }

        if isMaxTransaction {
            if draft.from.doesAccountHasParticipationKey() {
                return .algoParticipationKeyWarning
            } else if draft.from.hasMinAmountFields || draft.from.isRekeyed() {
                displayMaxTransactionWarning()
                return .maxAlgo
            }
        }

        return .valid
    }

    private func validateAsset(for value: String, on asset: Asset) -> TransactionValidation {
        guard let decimalAmount = value.decimalAmount else {
            return .otherAsset
        }

        let assetAmount = asset.amountWithFraction

        if assetAmount < decimalAmount {
            return .minimumAmountAssetError
        }

        return .valid
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
            case .failure:
                break
            }
        }
    }
    
    private func displayRequiredMinAlgoWarning() {
        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-red".uiImage,
            title: "required-min-balance-title".localized,
            description: .plain("required-min-balance-description".localized),
            secondaryActionButtonTitle: "title-got-it".localized
        )

        self.modalTransition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
    }

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

                let maxAmount = self.draft.from.amount.toAlgos.toNumberStringWithSeparatorForLabel ?? "0"
                self.draft.amount = maxAmount.decimalAmount
                
                self.open(.transactionAccountSelect(draft: self.draft), by: .push)
            }
        )

        modalTransition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
    }

    private func calculateMininmumAmount(for account: Account) -> UInt64 {
        let feeCalculator = TransactionFeeCalculator(transactionDraft: nil, transactionData: nil, params: transactionParams)
        let calculatedFee = transactionParams?.getProjectedTransactionFee() ?? Transaction.Constant.minimumFee
        let minimumAmountForAccount = feeCalculator.calculateMinimumAmount(
            for: account,
               with: .algosTransaction,
               calculatedFee: calculatedFee,
               isAfterTransaction: true
        ) - calculatedFee
        return minimumAmountForAccount
    }
}

extension SendTransactionScreen: EditNoteScreenDelegate {
    func editNoteScreen(
        _ editNoteScreen: EditNoteScreen,
        didUpdateNote note: String?
    ) {
        self.note = note
        self.draft.note = note
    }
}

extension SendTransactionScreen {
    enum TransactionValidation {
        case otherAlgo
        case otherAsset
        case minimumAmountAlgoError
        case maximumAmountAlgoError
        case minimumAmountAssetError
        case valid
        case algoParticipationKeyWarning
        case maxAlgo
        case requiredMinAlgo
    }
}

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
            bannerController?.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "send-algos-minimum-amount-custom-error".localized(params: amount.toAlgos.toAlgosStringForLabel ?? ""
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
        let ledgerApprovalTransition = BottomSheetTransition(presentingViewController: self)
        ledgerApprovalViewController = ledgerApprovalTransition.perform(
            .ledgerApproval(mode: .approve, deviceName: ledger),
            by: .present
        )
    }
    func transactionControllerDidResetLedgerOperation(_ transactionController: TransactionController) {
        ledgerApprovalViewController?.dismissScreen()
    }
}

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
            assetDecimalFraction: asset.presentation.decimals,
            isVerifiedAsset: asset.presentation.isVerified,
            note: draft.note
        )
        transactionDraft.toContact = draft.toContact
        transactionDraft.asset = asset

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
