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

final class SendCollectibleViewController: BaseScrollViewController {
    lazy var uiInteractions = SendCollectibleUIInteractions()

    private lazy var  bottomTransition = BottomSheetTransition(presentingViewController: self)

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
    private let transactionController: TransactionController

    let theme: SendCollectibleViewControllerTheme

    private var ledgerApprovalViewController: LedgerApprovalViewController?
    private var askRecipientToOptInViewController: BottomWarningViewController?

    private var ongoingFetchAccountsEnpoint: EndpointOperatable?

    init(
        draft: SendCollectibleDraft,
        transactionController: TransactionController,
        theme: SendCollectibleViewControllerTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.draft = draft
        self.transactionController = transactionController
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

        sendCollectibleActionView.observe(event: .performTransfer) {
            [weak self] in
            self?.makeTransfer()
        }

        sendCollectibleActionView.observe(event: .performSelectReceiverAccount) {
            [weak self] in
            self?.openSelectReceiver()
        }

        sendCollectibleActionView.observe(event: .performScanQR) {
            [weak self] in
            self?.openScanQR()
        }

        sendCollectibleActionView.observe(event: .performClose) {
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
        cancelOngoingFetchAccountsEnpoint()

        guard let recipientAddress = sendCollectibleActionView.addressInputViewText else {
            return
        }

        let accountInShared = sharedDataController
            .accountCollection
            .account(for: recipientAddress)

        if let accountInShared = accountInShared {

            if draft.fromAccount.address == recipientAddress,
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

        ongoingFetchAccountsEnpoint =
        api?.fetchAccount(
            AccountFetchDraft(publicKey: recipientAddress),
            queue: .main,
            ignoreResponseOnCancelled: true
        ) {
            [weak self] response in
            guard let self = self else { return }
            self.sendCollectibleActionView.stopLoading()

            switch response {
            case .success(let accountResponse):
                let fetchedAccount = accountResponse.account

                if !fetchedAccount.isSameAccount(with: recipientAddress) {
                    UIApplication.shared.firebaseAnalytics?.record(
                        MismatchAccountErrorLog(
                            requestedAddress: recipientAddress,
                            receivedAddress: fetchedAccount.address
                        )
                    )
                    return
                }

                self.sendTransaction(
                    to: fetchedAccount
                )
            case .failure(let error, _):
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
            openAskRecipientToOptIn()
            return
        }

        let isNotOwned = (collectibleAsset.amount == 0)

        if isNotOwned {
            composeCollectibleAssetTransactionData()
        }
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
            .sendCollectibleAccountList(
                dataController: SendCollectibleAccountListAPIDataController(
                    sharedDataController,
                    addressInputViewText: sendCollectibleActionView.addressInputViewText
                )
            ),
            by: .present
        ) as? SendCollectibleAccountListViewController
        screen?.eventHandler = {
            [weak self] event in
            guard let self = self else {
                return
            }
            self.sendCollectibleActionView.recustomizeTransferActionButtonAppearance(
                self.theme.sendCollectibleViewTheme.actionViewTheme,
                isEnabled: true
            )

            switch event {
            case .didSelectAccount(let account):
                self.sendCollectibleActionView.addressInputViewText = account.address
                self.draft.toAccount = account

                screen?.dismissScreen()
            case .didSelectContact(let contact):
                self.sendCollectibleActionView.addressInputViewText = contact.address
                self.draft.toContact = contact

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
        let screen = bottomTransition.perform(
            .approveCollectibleTransaction(
                draft: draft,
                transactionController: transactionController
            ),
            by: .presentWithoutNavigationController
        ) as? ApproveCollectibleTransactionViewController

        screen?.handlers.didSendTransactionSuccessfully = {
            [unowned self] _ in
            /// <todo> Dismiss screen properly.
            self.openSuccessScreen()
        }
    }

    private func openSuccessScreen() {
        let controller = open(
            .tutorial(flow: .none, tutorial: .collectibleTransferConfirmed),
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            ),
            then: {
                [unowned self] in
                self.uiInteractions.didCompleteTransaction?(self)
            }
        ) as? TutorialViewController

        controller?.uiHandlers.didTapButtonPrimaryActionButton = {
            controller in
            controller.dismissScreen()
        }
    }

    private func openAskRecipientToOptIn() {
        let asset = draft.collectibleAsset
        let title = asset.title.fallback(asset.name.fallback("#\(String(asset.id))"))
        let to = draft.toContact?.address ?? draft.toAccount?.address

        let description = "collectible-recipient-opt-in-description".localized(title, to!)

        let configuratorDescription =
        BottomWarningViewConfigurator.BottomWarningDescription.custom(
            description: (description, [title, to!]),
            markedWordWithHandler: (
                word: "collectible-recipient-opt-in-description-marked".localized,
                handler: {
                    [weak self] in
                    guard let self = self else {
                        return
                    }

                    self.askRecipientToOptInViewController?.dismissScreen {
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

                self.requestOptInToRecipeint()
            }
        )

        askRecipientToOptInViewController = bottomTransition.perform(
            .bottomWarning(
                configurator: configurator
            ),
            by: .presentWithoutNavigationController
        ) as? BottomWarningViewController
    }

    private func openOptInInformation() {
        let configurator = BottomWarningViewConfigurator(
            title: "collectible-opt-in-info-title".localized,
            description: .plain("collectible-opt-in-info-description".localized),
            secondaryActionButtonTitle: "title-close".localized
        )

        bottomTransition.perform(
            .bottomWarning(
                configurator: configurator
            ),
            by: .presentWithoutNavigationController
        )
    }

    private func openTransferFailed(
        title: String = "collectible-transfer-failed-title".localized,
        description: String = "collectible-transfer-failed-verify-algo-desription".localized
    ) {
        let configurator = BottomWarningViewConfigurator(
            title: title,
            description: .plain(description),
            secondaryActionButtonTitle: "title-close".localized
        )

        bottomTransition.perform(
            .bottomWarning(
                configurator: configurator
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension SendCollectibleViewController {
    private func requestOptInToRecipeint() {
        let receiverAddress = sendCollectibleActionView.addressInputViewText

        if let receiverAddress = receiverAddress {
            let draft = AssetSupportDraft(
                sender: draft.fromAccount.address,
                receiver: receiverAddress,
                assetId: draft.collectibleAsset.id
            )

            api?.sendAssetSupportRequest(
                draft
            )
        }
    }
}

extension SendCollectibleViewController {
    private func composeCollectibleAssetTransactionData() {
        let transactionDraft = AssetTransactionSendDraft(
            from: draft.fromAccount,
            toAccount: draft.toAccount,
            amount: 1,
            assetIndex: draft.collectibleAsset.id,
            assetDecimalFraction: draft.collectibleAsset.presentation.decimals,
            isVerifiedAsset: draft.collectibleAsset.presentation.isVerified,
            note: nil,
            toContact: draft.toContact,
            asset: draft.collectibleAsset
        )

        transactionController.setTransactionDraft(transactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetTransaction)
        
        if draft.fromAccount.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }
}

extension SendCollectibleViewController: TransactionControllerDelegate {
    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        loadingController?.stopLoading()

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

    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        loadingController?.stopLoading()
        self.draft.fee = draft?.fee
        openApproveTransaction()
    }

    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            openTransferFailed(
                description: "send-algos-minimum-amount-custom-error".localized(params: amount.toAlgos.toAlgosStringForLabel ?? "")
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
            bottomTransition.perform(
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
        ledgerApprovalViewController = bottomTransition.perform(
            .ledgerApproval(mode: .approve, deviceName: ledger),
            by: .present
        )
    }

    func transactionControllerDidResetLedgerOperation(
        _ transactionController: TransactionController
    ) {
        ledgerApprovalViewController?.dismissScreen()
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

extension SendCollectibleViewController: SendCollectibleActionViewDelegate {
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

extension SendCollectibleViewController: UIScrollViewDelegate {
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

extension SendCollectibleViewController: KeyboardControllerDataSource {
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

extension SendCollectibleViewController {
    struct SendCollectibleUIInteractions {
        var didCompleteTransaction: ((SendCollectibleViewController) -> Void)?
    }
}
