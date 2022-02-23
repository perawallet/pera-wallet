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
    private lazy var assetDetailTitleView = AssetDetailTitleView()
    private lazy var accountView = SelectAccountView()
    private lazy var searchNoContentView = NoContentView()
    private lazy var theme = Theme()

    private lazy var dataSource = AccountSelectScreenDataSource(sharedDataController: sharedDataController)

    private var draft: SendTransactionDraft

    private let algorandSDK = AlgorandSDK()

    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(api: api, bannerController: bannerController)
    }()

    private lazy var modalTransition = BottomSheetTransition(presentingViewController: self)

    private var ledgerApprovalViewController: LedgerApprovalViewController?

    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }

    init(draft: SendTransactionDraft, configuration: ViewControllerConfiguration) {
        self.draft = draft
        super.init(configuration: configuration)
    }

    override func linkInteractors() {
        dataSource.delegate = self
        accountView.searchInputView.delegate = self
        accountView.listView.delegate = self
        accountView.listView.dataSource = dataSource

        accountView.clipboardView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapCopy))
        )
        transactionController.delegate = self
    }

    override func configureAppearance() {
        super.configureAppearance()
        searchNoContentView.customize(NoContentViewTopAttachedTheme())
        searchNoContentView.bindData(AccountSelectSearchNoContentViewModel())
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

        dataSource.loadData()
    }

    private func routePreviewScreen() {
        if isClosingToSameAccount {
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "send-transaction-max-same-account-error".localized
            )
            return
        }

        switch draft.transactionMode {
        case .algo:
            routeForAlgoTransaction()
        case .assetDetail:
            routeForAssetTransaction()
        }
    }

    private func routeForAlgoTransaction() {
        let selectedAccount = draft.from

        guard let amount = draft.amount else {
            return
        }

        if amount.toMicroAlgos < minimumTransactionMicroAlgosLimit {
            var receiverAddress: String?

            if let contact = draft.toContact {
                receiverAddress = contact.address
            } else {
                receiverAddress = draft.toAccount?.address
            }

            guard var receiverAddress = receiverAddress else {
                self.displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-address-not-selected".localized)
                return
            }


            receiverAddress = receiverAddress.trimmingCharacters(in: .whitespacesAndNewlines)

            if !AlgorandSDK().isValidAddress(receiverAddress) {
                bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "send-algos-receiver-address-validation".localized
                )
                return
            }

            let receiverFetchDraft = AccountFetchDraft(publicKey: receiverAddress)

            loadingController?.startLoadingWithMessage("title-loading".localized)
            api?.fetchAccount(
                receiverFetchDraft,
                queue: .main,
                ignoreResponseOnCancelled: true
            ) { [weak self] accountResponse in
                guard let self = self else { return }
                if !selectedAccount.requiresLedgerConnection() {
                    self.loadingController?.stopLoading()
                }

                switch accountResponse {
                case let .failure(error, _):
                    if error.isHttpNotFound {
                        let configurator = BottomWarningViewConfigurator(
                            image: "icon-info-red".uiImage,
                            title: "send-algos-minimum-amount-error-new-account-title".localized,
                            description: "send-algos-minimum-amount-error-new-account-description".localized,
                            secondaryActionButtonTitle: "title-i-understand".localized
                        )

                        self.modalTransition.perform(
                            .bottomWarning(configurator: configurator),
                            by: .presentWithoutNavigationController
                        )
                    } else {
                        self.displaySimpleAlertWith(
                            title: "title-error".localized,
                            message: "title-internet-connection".localized
                        )
                    }
                case let .success(accountWrapper):
                    if !accountWrapper.account.isSameAccount(with: receiverAddress) {
                        UIApplication.shared.firebaseAnalytics?.record(
                            MismatchAccountErrorLog(requestedAddress: receiverAddress, receivedAddress: accountWrapper.account.address)
                        )
                        return
                    }

                    accountWrapper.account.assets = accountWrapper.account.nonDeletedAssets()
                    if accountWrapper.account.amount == 0 {
                        self.displaySimpleAlertWith(
                            title: "title-error".localized,
                            message: "send-algos-minimum-amount-error-new-account".localized
                        )
                    } else {
                        self.composeAlgosTransactionData()
                    }
                }
            }
            return
        } else {
            loadingController?.startLoadingWithMessage("title-loading".localized)
            composeAlgosTransactionData()
        }
    }

    private func routeForAssetTransaction() {
        if let contact = draft.toContact, let contactAddress = contact.address {
            checkIfAddressIsValidForTransaction(contactAddress)
        } else if let address = draft.toAccount?.address {
            checkIfAddressIsValidForTransaction(address)
        }
    }

    private func checkIfAddressIsValidForTransaction(_ address: String) {
        guard let assetDetail = draft.assetDetail else {
            return
        }

        if !AlgorandSDK().isValidAddress(address) {
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "send-algos-receiver-address-validation".localized
            )
            return
        }

        loadingController?.startLoadingWithMessage("title-loading".localized)
        api?.fetchAccount(
            AccountFetchDraft(publicKey: address),
            queue: .main,
            ignoreResponseOnCancelled: true
        ) { [weak self] fetchAccountResponse in
            guard let self = self else { return }
            if !self.draft.from.requiresLedgerConnection() {
                self.loadingController?.stopLoading()
            }

            switch fetchAccountResponse {
            case let .success(receiverAccountWrapper):
                if !receiverAccountWrapper.account.isSameAccount(with: address) {
                    UIApplication.shared.firebaseAnalytics?.record(
                        MismatchAccountErrorLog(requestedAddress: address, receivedAddress: receiverAccountWrapper.account.address)
                    )
                    return
                }

                receiverAccountWrapper.account.assets = receiverAccountWrapper.account.nonDeletedAssets()
                let receiverAccount = receiverAccountWrapper.account

                if let assets = receiverAccount.assets {
                    if assets.contains(where: { asset -> Bool in
                        assetDetail.id == asset.id
                    }) {
                        self.validateAssetTransaction()
                    } else {
                        self.presentAssetNotSupportedAlert(receiverAddress: address)
                    }
                } else {
                    self.presentAssetNotSupportedAlert(receiverAddress: address)
                }
            case let .failure(error, _):
                if error.isHttpNotFound {
                    self.presentAssetNotSupportedAlert(receiverAddress: address)
                } else {
                    self.loadingController?.stopLoading()
                }
            }
        }
    }

    private func presentAssetNotSupportedAlert(receiverAddress: String?) {
        guard let assetDetail = draft.assetDetail else {
            return
        }

        let assetAlertDraft = AssetAlertDraft(
            account: draft.from,
            assetIndex: assetDetail.id,
            assetDetail: assetDetail,
            title: "asset-support-title".localized,
            detail: "asset-support-error".localized,
            actionTitle: "title-ok".localized
        )

        let senderAddress = draft.from.address
        if let receiverAddress = receiverAddress {
            let draft = AssetSupportDraft(
                sender: senderAddress,
                receiver: receiverAddress,
                assetId: assetDetail.id
            )
            api?.sendAssetSupportRequest(draft)
        }

        modalTransition.perform(
            .assetActionConfirmation(assetAlertDraft: assetAlertDraft, delegate: nil),
            by: .presentWithoutNavigationController
        )
    }

    private func validateAssetTransaction() {
        guard let amount = self.draft.amount, let assetDetail = draft.assetDetail else {
            return
        }

        guard let assetAmount = draft.from.amount(for: assetDetail) else {
            displaySimpleAlertWith(
                title: "send-algos-alert-incomplete-title".localized,
                message: "send-algos-alert-message-address".localized
            )
            return
        }

        if assetAmount < amount {
            self.displaySimpleAlertWith(title: "title-error".localized, message: "send-asset-amount-error".localized)
            return
        }

        composeAssetTransactionData()
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

        transactionController.delegate = self
        transactionController.setTransactionDraft(transactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .algosTransaction)

        if draft.from.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }

    private func composeAssetTransactionData() {
        guard let assetDetail = draft.assetDetail else {
            return
        }

        var transactionDraft = AssetTransactionSendDraft(
            from: draft.from,
            toAccount: draft.toAccount,
            amount: draft.amount,
            assetIndex: assetDetail.id,
            assetDecimalFraction: assetDetail.decimals,
            isVerifiedAsset: assetDetail.isVerified,
            note: draft.note
        )
        transactionDraft.toContact = draft.toContact
        transactionDraft.assetDetail = assetDetail

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
        assetDetailTitleView.bindData(AssetDetailTitleViewModel(assetDetail: draft.assetDetail))

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

        open(
            .sendTransactionPreview(draft: draft, transactionController: transactionController),
            by: .push
        )
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
            let warningModalTransition = BottomSheetTransition(presentingViewController: self)

             let warningAlert = WarningAlert(
                 title: "ledger-pairing-issue-error-title".localized,
                 image: img("img-warning-circle"),
                 description: "ble-error-fail-ble-connection-repairing".localized,
                 actionTitle: "title-ok".localized
             )

             warningModalTransition.perform(
                 .warningAlert(warningAlert: warningAlert),
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

extension AccountSelectScreen {
    @objc
    private func didTapCopy() {
        if let address = UIPasteboard.general.validAddress {
            accountView.searchInputView.setText(address)
        }
    }

    @objc
    private func didTapNext() {
        guard let address = accountView.searchInputView.text,
              algorandSDK.isValidAddress(address) else {
                  return
        }

        draft.toAccount = Account(address: address, type: .standard)
        draft.toContact = nil

        routePreviewScreen()
    }
}

extension AccountSelectScreen: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: theme.cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)

        if let contact = dataSource.item(at: indexPath) as? Contact {
            draft.toContact = contact
            draft.toAccount = nil
        } else if let account = dataSource.item(at: indexPath) as? AccountHandle {
            draft.toAccount = account.value
            draft.toContact = nil
        } else if let account = dataSource.item(at: indexPath) as? Account {
            draft.toAccount = account
            draft.toContact = nil
        } else {
            return
        }

        routePreviewScreen()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if dataSource.list[section].isEmpty {
            return .zero
        }
        
        return CGSize(
            width: collectionView.frame.size.width,
            height: theme.headerHeight
        )
    }
}

extension AccountSelectScreen: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        if dataSource.isEmpty {
            accountView.listView.contentState = .empty(searchNoContentView)
            return
        }

        guard let query = view.text,
            !query.isEmpty else {
                accountView.listView.contentState = .none
                dataSource.search(keyword: nil)
                accountView.listView.reloadData()
                return
        }

        dataSource.search(keyword: query)


        if dataSource.isListEmtpy {
            accountView.listView.contentState = .empty(searchNoContentView)
        } else {
            accountView.listView.contentState = .none
        }

        accountView.listView.reloadData()
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

        guard let qrAddress = qrText.address else {
            return
        }

        guard algorandSDK.isValidAddress(qrAddress) else {
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

extension AccountSelectScreen: AccountSelectScreenDataSourceDelegate {
    func accountSelectScreenDataSourceDidLoad(_ dataSource: AccountSelectScreenDataSource) {
        accountView.listView.reloadData()
    }
}

extension AccountSelectScreen {
    var isClosingToSameAccount: Bool {
        if let receiverAddress = draft.toAccount?.address {
            return draft.isMaxTransaction && receiverAddress == draft.from.address
        }

        if let contactAddress = draft.toContact?.address {
            return draft.isMaxTransaction && contactAddress == draft.from.address
        }

        return false
    }
}
