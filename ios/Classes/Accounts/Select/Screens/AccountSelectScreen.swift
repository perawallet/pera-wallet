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
//   AccountSelectScreen.swift


import Foundation
import UIKit
import MacaroonUIKit

final class AccountSelectScreen: BaseViewController {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var assetDetailTitleView = AssetDetailTitleView()
    private lazy var accountView = SelectAccountView()
    private lazy var theme = Theme()

    private lazy var listLayout = AccountSelectScreenListLayout(
        listDataSource: listDataSource,
        theme: Theme()
    )
    private lazy var listDataSource = AccountSelectScreenDataSource(accountView.listView)

    private lazy var currencyFormatter = CurrencyFormatter()

    private let dataController: AccountSelectScreenListDataController

    private var draft: SendTransactionDraft

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

    private lazy var modalTransition = BottomSheetTransition(presentingViewController: self)

    private var ledgerApprovalViewController: LedgerApprovalViewController?

    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }

    private var transactionSendController: TransactionSendController?

    init(
        draft: SendTransactionDraft,
        dataController: AccountSelectScreenListDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.draft = draft
        self.dataController = dataController
        super.init(configuration: configuration)
    }

    override func linkInteractors() {
        accountView.searchInputView.delegate = self
        accountView.listView.delegate = self
        accountView.listView.dataSource = listDataSource

        accountView.clipboardView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapCopy))
        )
        transactionController.delegate = self
    }

    override func prepareLayout() {
        addAccountView()
        addTitleView()
    }

    override func bindData() {
        super.bindData()

        guard let address = UIPasteboard.general.validAddress else {
            accountView.displayClipboard(isVisible: false)
            return
        }

        accountView.displayClipboard(isVisible: true)
        accountView.clipboardView.bindData(AccountClipboardViewModel(address))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let snapshot):
                self.listDataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            }
        }
        dataController.load()
    }

    private func routePreviewScreen() {
        loadingController?.startLoadingWithMessage("title-loading".localized)

        transactionSendController = TransactionSendController(
            draft: draft,
            api: api!,
            analytics: analytics
        )

        transactionSendController?.delegate = self
        transactionSendController?.validate()
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
}

extension AccountSelectScreen {
    private func addAccountView() {
        view.addSubview(accountView)
        accountView.snp.makeConstraints {
            $0.top.safeEqualToTop(of: self)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func addTitleView() {
        assetDetailTitleView.customize(AssetDetailTitleViewTheme())
        assetDetailTitleView.bindData(AssetDetailTitleViewModel(draft.asset))

        navigationItem.titleView = assetDetailTitleView
    }
}

extension AccountSelectScreen: TransactionControllerDelegate {
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
                        image: "icon-info-green".uiImage,
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

extension AccountSelectScreen {
    @objc
    private func didTapCopy() {
        if let address = UIPasteboard.general.validAddress {
            accountView.searchInputView.setText(address)
        }
    }
}

extension AccountSelectScreen: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)

        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .account(let accountItem):
            switch accountItem {
            case .contactCell:
                draft.toContact = dataController.contact(at: indexPath)
                draft.toAccount = nil
                draft.nameService = nil
            case .accountCell:
                draft.toAccount = dataController.account(at: indexPath)
                draft.toContact = nil
                draft.nameService = nil
            case .searchAccountCell:
                draft.toAccount = dataController.searchedAccount(at: indexPath)
                draft.toContact = nil
                draft.nameService = nil
            case .matchedAccountCell:
                let nameService = dataController.matchedAccount(at: indexPath)
                draft.toAccount = nameService?.account.value
                draft.toContact = nil
                draft.nameService = nameService
            default:
                return
            }
        default:
            return
        }

        routePreviewScreen()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if let loadingCell = cell as? LoadingCell {
            loadingCell.startAnimating()
        }
    }
}

extension AccountSelectScreen: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        dataController.search(query: view.text)
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }

    func searchInputViewDidTapRightAccessory(_ view: SearchInputView) {
        let qrScannerViewController = open(.qrScanner(canReadWCSession: false), by: .push) as? QRScannerViewController
        qrScannerViewController?.delegate = self
    }
}

extension AccountSelectScreen: QRScannerViewControllerDelegate {
    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didRead qrText: QRText,
        completionHandler: EmptyHandler?
    ) {
        defer {
            completionHandler?()
        }

        guard let qrAddress = qrText.address,
              qrAddress.isValidatedAddress else {
                  return
              }

        accountView.searchInputView.setText(qrAddress)
    }

    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didFail error: QRScannerError,
        completionHandler: EmptyHandler?
    ) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            completionHandler?()
        }
    }
}

extension AccountSelectScreen: TransactionSendControllerDelegate {
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

extension AccountSelectScreen {
    enum Event {
        case didCompleteTransaction
    }
}
