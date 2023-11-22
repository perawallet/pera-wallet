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

//   SendCollectibleViewController.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage
import SnapKit
import MagpieCore

final class SendCollectibleViewController:
    BaseScrollViewController,
    TransactionControllerDelegate,
    SendCollectibleActionViewDelegate,
    UIScrollViewDelegate,
    KeyboardControllerDataSource {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return api!.isTestNet ? .darkContent : .lightContent
    }

    var eventHandler: ((SendCollectibleViewControllerEvent) -> Void)?

    private lazy var transitionToTransferFailedWithRetryWarning = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToApproveTransaction = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToAskReceiverToOptIn = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToOptInInformation = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )

    private var transitionToLedgerConnection: BottomSheetTransition?
    private var transitionToSignWithLedgerProcess: BottomSheetTransition?
    private var transitionToLedgerConnectionIssuesWarning: BottomSheetTransition?
    private var transitionToTransferFailedWarning: BottomSheetTransition?

    private(set) lazy var sendCollectibleView = SendCollectibleView()

    var imageView: URLImageView {
        sendCollectibleView.imageView
    }

    var sendCollectibleActionView: SendCollectibleActionView {
        sendCollectibleView.actionView
    }

    lazy var backgroundStartStyle: ViewStyle = []
    lazy var backgroundEndStyle: ViewStyle = []

    private lazy var keyboardController = KeyboardController()
    private(set) lazy var keyboardHeight: CGFloat = .zero

    lazy var actionViewHeightDiff: CGFloat = .zero

    private var draft: SendCollectibleDraft
    private lazy var transactionController = TransactionController(
        api: api!,
        sharedDataController: sharedDataController,
        bannerController: bannerController,
        analytics: analytics
    )

    private lazy var currencyFormatter = CurrencyFormatter()

    let theme: SendCollectibleViewControllerTheme

    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?
    private var approveCollectibleTransactionViewController: ApproveCollectibleTransactionViewController?

    private var ongoingFetchAccountsEnpoint: EndpointOperatable?

    /// <todo> Recreating of the transaction should be refactored when the transaction structure is changed so that it can be separated from the view controller.
    private var isRecreatingTransaction = false

    init(
        draft: SendCollectibleDraft,
        theme: SendCollectibleViewControllerTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.draft = draft
        self.theme = theme
        super.init(configuration: configuration)
    }

    deinit {
        keyboardController.endTracking()
    }

    override var shouldShowNavigationBar: Bool {
        return false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        animateBottomSheetLayout()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        transactionController.stopBLEScan()
        transactionController.stopTimer()
    }

    override func linkInteractors() {
        linkTransactionControllerInteractors()
        linkScrollViewInteractors()
        linkKeyboardInteractors()
        linkBottomSheetInteractors()
        linkViewInteractors()
    }

    override func prepareLayout() {
        super.prepareLayout()

        build()
    }

    private func build() {
        addBackground()
        addContext()
    }

    override func bindData() {
        sendCollectibleView.bindData(
            SendCollectibleViewModel(
                imageSize: sendCollectibleView.imageSize,
                draft: draft
            )
        )
    }
}

extension SendCollectibleViewController {
    private func linkTransactionControllerInteractors() {
        transactionController.delegate = self
    }

    private func linkScrollViewInteractors() {
        scrollView.delegate = self
        scrollView.isScrollEnabled = false
    }

    private func linkKeyboardInteractors() {
        keyboardController.dataSource = self
        keyboardController.beginTracking()

        keyboardController.notificationHandlerWhenKeyboardShown = {
            [weak self] keyboard in
            self?.keyboardHeight = keyboard.height
        }

        keyboardController.notificationHandlerWhenKeyboardHidden = {
            [weak self] _ in
            self?.keyboardHeight = .zero
        }
    }

    private func linkBottomSheetInteractors() {
        sendCollectibleActionView.delegate = self

        sendCollectibleActionView.handlers.didHeightChange = {
            [weak self] bottomSheetNewHeight in
            self?.handleActionViewHeightChange(bottomSheetNewHeight)
        }

        sendCollectibleActionView.startObserving(event: .performTransfer) {
            [weak self] in
            self?.makeTransfer()
        }

        sendCollectibleActionView.startObserving(event: .performSelectReceiverAccount) {
            [weak self] in
            self?.openSelectReceiver()
        }

        sendCollectibleActionView.startObserving(event: .performScanQR) {
            [weak self] in
            self?.openScanQR()
        }

        sendCollectibleActionView.startObserving(event: .performClose) {
            [weak self] in
            self?.dismissWithAnimation()
        }
    }

    private func linkViewInteractors() {
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self, action: #selector(closeKeyboard)
            )
        )
    }
}

extension SendCollectibleViewController {
    @objc
    private func closeKeyboard() {
        sendCollectibleActionView.endEditing()
    }
}

extension SendCollectibleViewController {
    private func makeTransfer() {
        closeKeyboard()

        cancelOngoingFetchAccountsEnpoint()

        guard let receiverAddress = sendCollectibleActionView.addressInputViewText else {
            return
        }

        let accountInShared = sharedDataController
            .accountCollection
            .account(for: receiverAddress)

        if let accountInShared = accountInShared {

            if draft.fromAccount.address == receiverAddress,
               accountInShared.containsCollectibleAsset(draft.collectibleAsset.id) {
                bannerController?.presentErrorBanner(
                    title: "asset-you-already-own-message".localized,
                    message: .empty
                )
                return
            }

            sendTransaction(
                to: accountInShared
            )

            return
        }

        sendCollectibleActionView.startLoading()

        let draft = AccountAssetFetchDraft(
            publicKey: receiverAddress,
            assetID: draft.collectibleAsset.id
        )
        ongoingFetchAccountsEnpoint = api?.fetchAccountAssetFromNode(
            draft,
            queue: .main,
            ignoreResponseOnCancelled: true
        ) {
            [weak self] response in
            guard let self = self else { return }
            self.sendCollectibleActionView.stopLoading()

            switch response {
            case let .success(accountAssetInformation):
                self.draft.toAccount = Account(address: receiverAddress)

                let isNotOwned = accountAssetInformation.amount == 0
                if isNotOwned {
                    composeCollectibleAssetTransactionData(isOptingOut: false)
                }
            case .failure(let error, _):
                if error.isHttpNotFound {
                    self.draft.toAccount = Account(address: receiverAddress)

                    self.openAskReceiverToOptIn()
                    return
                }

                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: error.description
                )
            }
        }
    }

    private func sendTransaction(
        to account: Account
    ) {
        draft.toAccount = account

        guard let collectibleAsset =
                account.assets?.first(matching: (\.id, draft.collectibleAsset.id)) else {
            openAskReceiverToOptIn()
            return
        }

        let isNotOwned = (collectibleAsset.amount == 0)

        if isNotOwned {
            composeCollectibleAssetTransactionData(
                isOptingOut: false
            )
        }
    }

    private func openAskReceiverToOptIn() {
        let asset = draft.collectibleAsset
        let title = asset.title.fallback(asset.name.fallback("#\(String(asset.id))"))
        let to = draft.toContact?.address ?? draft.toNameService?.name ?? draft.toAccount?.address

        let description = "collectible-recipient-opt-in-description".localized(title, to!)

        let configuratorDescription =
        BottomWarningViewConfigurator.BottomWarningDescription.custom(
            description: (description, [title, to!]),
            markedWordWithHandler: (
                word: "collectible-recipient-opt-in-description-marked".localized,
                handler: {
                    [weak self] in
                    guard let self else { return }

                    self.dismiss(animated: true) {
                        [weak self] in
                        guard let self else { return }

                        self.openOptInInformation()
                    }
                }
            )
        )

        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-green".uiImage,
            title: "collectible-recipient-opt-in-title".localized,
            description: configuratorDescription,
            primaryActionButtonTitle: "collectible-recipient-opt-in-action-title".localized,
            secondaryActionButtonTitle: "title-close".localized,
            primaryAction: {
                [weak self] in
                guard let self = self else {
                    return
                }

                self.sendOptInRequestToReceiver()
            }
        )

        transitionToAskReceiverToOptIn.perform(
            .bottomWarning(
                configurator: configurator
            ),
            by: .presentWithoutNavigationController
        )
    }

    private func cancelOngoingFetchAccountsEnpoint() {
        ongoingFetchAccountsEnpoint?.cancel()
        ongoingFetchAccountsEnpoint = nil
    }
}

extension SendCollectibleViewController {
    private func openSelectReceiver() {
        closeKeyboard()

        let screen = open(
            .sendCollectibleReceiverAccountSelectionList(
                addressInputViewText: sendCollectibleActionView.addressInputViewText
            ),
            by: .present
        ) as? ReceiverAccountSelectionListScreen
        screen?.eventHandler = {
            [weak self, weak screen] event in
            guard let self = self else { return }
            self.sendCollectibleActionView.recustomizeTransferActionButtonAppearance(
                self.theme.sendCollectibleViewTheme.actionViewTheme,
                isEnabled: true
            )

            switch event {
            case .didSelectAccount(let account):
                self.draft.resetReceiver()

                self.sendCollectibleActionView.addressInputViewText = account.address
                self.draft.toAccount = account

                screen?.dismissScreen()
            case .didSelectContact(let contact):
                self.draft.resetReceiver()

                self.sendCollectibleActionView.addressInputViewText = contact.address
                self.draft.toContact = contact

                screen?.dismissScreen()
            case .didSelectNameService(let nameService):
                self.draft.resetReceiver()

                self.sendCollectibleActionView.addressInputViewText = nameService.address
                self.draft.toAccount = nameService.account.value
                self.draft.toNameService = nameService

                screen?.dismissScreen()
            }
        }
    }

    private func openScanQR() {
        closeKeyboard()

        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displaySimpleAlertWith(
                title: "qr-scan-error-title".localized,
                message: "qr-scan-error-message".localized
            )
            return
        }

        let qrScannerViewController = open(
            .qrScanner(canReadWCSession: false)
            , by: .push
        ) as? QRScannerViewController

        qrScannerViewController?.delegate = self
    }

    private func openApproveTransaction() {
        approveCollectibleTransactionViewController = transitionToApproveTransaction.perform(
            .approveCollectibleTransaction(
                draft: draft
            ),
            by: .presentWithoutNavigationController
        ) as? ApproveCollectibleTransactionViewController

        approveCollectibleTransactionViewController?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .approvedSendAndOptOut:
                self.isRecreatingTransaction = true
                self.composeCollectibleAssetTransactionData(
                    isOptingOut: true
                )
            case .approvedSend:
                self.isRecreatingTransaction = false
                self.transactionController.uploadTransaction()
            case .cancelledSend:
                self.isRecreatingTransaction = false
                self.approveCollectibleTransactionViewController?.dismiss(animated: true)
                self.approveCollectibleTransactionViewController = nil
            }
        }
    }

    private func openSuccessScreen() {
        let controller = open(
            .tutorial(flow: .none, tutorial: .collectibleTransferConfirmed),
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            )
        ) as? TutorialViewController

        controller?.uiHandlers.didTapButtonPrimaryActionButton = {
            [weak self, controller] _ in
            guard let self = self else { return }
            self.eventHandler?(.didCompleteTransaction)
            controller?.dismissScreen()
        }
    }
}

extension SendCollectibleViewController {
    private func composeCollectibleAssetTransactionData(
        isOptingOut: Bool
    ) {
        let fromAccount = draft.fromAccount
        
        if !transactionController.canSignTransaction(for: fromAccount) { return }

        sendCollectibleActionView.startLoading()

        let creatorAddress = isOptingOut ? draft.collectibleAsset.creator?.address ?? "" : ""

        let transactionDraft = AssetTransactionSendDraft(
            from: fromAccount,
            toAccount: draft.toAccount,
            amount: 1,
            assetIndex: draft.collectibleAsset.id,
            assetCreator: creatorAddress,
            toContact: draft.toContact,
            toNameService: draft.toNameService
        )

        transactionController.setTransactionDraft(transactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetTransaction)

        if fromAccount.requiresLedgerConnection() {
            openLedgerConnection()

            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }

    private func openOptInInformation() {
        let uiSheet = UISheet(
            title: "collectible-opt-in-info-title".localized.bodyLargeMedium(),
            body: UISheetBodyTextProvider(text: "collectible-opt-in-info-description".localized.bodyRegular())
        )

        let closeAction = UISheetAction(
            title: "title-close".localized,
            style: .cancel
        ) { [weak self] in
            guard let self else { return }
            self.dismiss(animated: true)
        }
        uiSheet.addAction(closeAction)

        transitionToOptInInformation.perform(
            .sheetAction(sheet: uiSheet),
            by: .presentWithoutNavigationController
        )
    }

    private func sendOptInRequestToReceiver() {
        if let receiverAddress = draft.receiverAddress {
            let draft = AssetSupportDraft(
                sender: draft.fromAccount.address,
                receiver: receiverAddress,
                assetId: draft.collectibleAsset.id
            )

            api?.sendAssetSupportRequest(draft) {
                [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success:
                    return
                case let .failure(apiError, errorModel):
                    self.bannerController?.presentErrorBanner(
                        title: "title-error".localized,
                        message: errorModel?.message() ?? apiError.description
                    )
                }
            }
        }
    }
}

extension SendCollectibleViewController {
    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        sendCollectibleActionView.stopLoading()

        self.draft.fee = draft?.fee

        if isRecreatingTransaction {
            transactionController.uploadTransaction()
            return
        }

        openApproveTransaction()
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        sendCollectibleActionView.stopLoading()
        approveCollectibleTransactionViewController?.stopLoading()

        switch error {
        case .network:
            displaySimpleAlertWith(
                title: "title-error".localized,
                message: "title-internet-connection".localized
            )
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        }
    }

    private func displayTransactionError(
        from transactionError: TransactionError
    ) {
        switch transactionError {
        case let .minimumAmount(amount):
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let amountText = currencyFormatter.format(amount.toAlgos)

            openTransferFailed(
                title: "collectible-transfer-failed-title".localized,
                description: "send-algos-minimum-amount-custom-error".localized(
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
            ledgerConnectionScreen?.dismiss(animated: true) {
                self.ledgerConnectionScreen = nil

                self.openLedgerConnectionIssues()
            }
        default:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "title-internet-connection".localized
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

        sendCollectibleActionView.stopLoading()
        approveCollectibleTransactionViewController?.stopLoading()
    }

    func transactionController(
        _ transactionController: TransactionController,
        didCompletedTransaction id: TransactionID
    ) {
        analytics.track(.completeCollectibleTransaction(draft: draft, transactionId: id))

        NotificationCenter.default.post(
            name: CollectibleListLocalDataController.didSendCollectible,
            object: self
        )

        let monitor = sharedDataController.blockchainUpdatesMonitor
        let request = SendPureCollectibleAssetBlockchainRequest(
            account: draft.fromAccount,
            asset: draft.collectibleAsset
        ) 
        monitor.startMonitoringSendPureCollectibleAssetUpdates(request)

        approveCollectibleTransactionViewController?.stopLoading()
        approveCollectibleTransactionViewController?.dismissScreen {
            [weak self] in
            guard let self else { return }

            self.approveCollectibleTransactionViewController = nil

            self.openSuccessScreen()
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedTransaction error: HIPTransactionError
    ) {
        sendCollectibleActionView.stopLoading()
        approveCollectibleTransactionViewController?.stopLoading()

        switch error {
        case let .network(apiError):
            switch apiError {
            case .connection:
                bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "title-internet-connection".localized
                )
            case .client(let error, _):
                bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: error.localizedDescription
                )
            default:
                openTransferFailedWithRetry()
            }
        default:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.localizedDescription
            )
        }
    }
}

extension SendCollectibleViewController {
    private func openLedgerConnection() {
        let transition = BottomSheetTransition(
            presentingViewController: self,
            interactable: false
        )
        let eventHandler: LedgerConnectionScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancel:
                self.transactionController.stopBLEScan()
                self.transactionController.stopTimer()

                self.ledgerConnectionScreen?.dismissScreen()
                self.ledgerConnectionScreen = nil

                self.sendCollectibleActionView.stopLoading()
            }
        }

        ledgerConnectionScreen = transition.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )

        transitionToLedgerConnection = transition
    }
}

extension SendCollectibleViewController {
    private func openLedgerConnectionIssues() {
        let visibleScreen = findVisibleScreen()
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
}

extension SendCollectibleViewController {
    private func openSignWithLedgerProcess(
        transactionController: TransactionController,
        ledgerDeviceName: String
    ) {
        let visibleScreen = findVisibleScreen()
        let transition = BottomSheetTransition(
            presentingViewController: visibleScreen,
            interactable: false
        )

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

                self.sendCollectibleActionView.stopLoading()
                self.approveCollectibleTransactionViewController?.stopLoading()
            }
        }
        signWithLedgerProcessScreen = transition.perform(
            .signWithLedgerProcess(
                draft: draft,
                eventHandler: eventHandler
            ),
            by: .present
        ) as? SignWithLedgerProcessScreen

        transitionToSignWithLedgerProcess = transition
    }
}

extension SendCollectibleViewController {
    private func openTransferFailed(
        title: String,
        description: String
    ) {
        let visibleScreen = findVisibleScreen()
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        let configurator = BottomWarningViewConfigurator(
            title: title,
            description: .plain(description),
            secondaryActionButtonTitle: "title-close".localized
        )

        transition.perform(
            .bottomWarning(
                configurator: configurator
            ),
            by: .presentWithoutNavigationController
        )

        transitionToTransferFailedWarning = transition
    }

    private func openTransferFailedWithRetry() {
        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-red".uiImage,
            title: "collectible-transfer-failed-title".localized,
            description: .plain("collectible-transfer-failed-retry-desription".localized),
            primaryActionButtonTitle: "title-retry".localized,
            secondaryActionButtonTitle: "title-close".localized,
            primaryAction: {
                [weak self] in
                guard let self else { return }

                self.approveCollectibleTransactionViewController?.startLoading()

                self.transactionController.uploadTransaction()
            }
        )

        approveCollectibleTransactionViewController?.dismissScreen {
            [weak self] in
            guard let self = self else { return }

            self.approveCollectibleTransactionViewController = nil

            self.transitionToTransferFailedWithRetryWarning.perform(
                .bottomWarning(
                    configurator: configurator
                ),
                by: .presentWithoutNavigationController
            )
        }
    }
}

extension SendCollectibleViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didRead qrText: QRText,
        completionHandler: EmptyHandler?
    ) {
        guard qrText.mode == .address,
              let qrAddress = qrText.address else {
            displaySimpleAlertWith(
                title: "title-error".localized,
                message: "qr-scan-should-scan-address-message".localized
            ) { _ in
                completionHandler?()
            }
            return
        }

        if qrAddress.isValidatedAddress {
            sendCollectibleActionView.recustomizeTransferActionButtonAppearance(
                theme.sendCollectibleViewTheme.actionViewTheme,
                isEnabled: true
            )
        }

        sendCollectibleActionView.addressInputViewText = qrAddress
    }

    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didFail error: QRScannerError,
        completionHandler: EmptyHandler?
    ) {
        displaySimpleAlertWith(
            title: "title-error".localized,
            message: "qr-scan-should-scan-valid-qr".localized
        ) { _ in
            completionHandler?()
        }
    }
}

extension SendCollectibleViewController {
    func sendCollectibleActionViewDidEdit(
        _ view: SendCollectibleActionView
    ) {
        sendCollectibleActionView.recustomizeTransferActionButtonAppearance(
            theme.sendCollectibleViewTheme.actionViewTheme,
            isEnabled: isTransferActionButtonEnabled(view)
        )
    }

    func sendCollectibleActionViewShouldChangeCharactersIn(
        _ view: SendCollectibleActionView,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = view.addressInputViewText else {
            return true
        }

        let newText = text.replacingCharacters(
            in: range,
            with: string
        )

        return newText.count <= validatedAddressLength
    }

    private func isTransferActionButtonEnabled(
        _ view: SendCollectibleActionView
    ) -> Bool {
        if let input = view.addressInputViewText,
           input.hasValidAddressLength &&
            input.isValidatedAddress {
            return true
        }

        return false
    }
}

extension SendCollectibleViewController {
    func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {
        handleScrollViewDidScroll(
            scrollView
        )
    }
}

extension SendCollectibleViewController {
    private func dismissWithAnimation() {
        sendCollectibleActionView.endEditing()

        updateImageBeforeAnimations(for: .initial)
        sendCollectibleActionView.updateContentBeforeAnimations(for: .start)

        animateContentLayout(view) {
            [weak self] in
            self?.dismissScreen(
                animated: true,
                completion: nil
            )
        }
    }
}

extension SendCollectibleViewController {
    func updateBackground(
        for position: SendCollectibleActionView.Position
    ) {
        let style: ViewStyle

        switch position {
        case .start: style = backgroundStartStyle
        case .end: style = backgroundEndStyle
        }

        view.customizeAppearance(style)
    }
}

extension SendCollectibleViewController {
    func bottomInsetWhenKeyboardPresented(
        for keyboardController: KeyboardController
    ) -> CGFloat {
        return .zero
    }

    func firstResponder(
        for keyboardController: KeyboardController
    ) -> UIView? {
        return sendCollectibleActionView
    }

    func containerView(
        for keyboardController: KeyboardController
    ) -> UIView {
        return contentView
    }

    func bottomInsetWhenKeyboardDismissed(
        for keyboardController: KeyboardController
    ) -> CGFloat {
        return .zero
    }
}

enum SendCollectibleViewControllerEvent {
    case didCompleteTransaction
}
