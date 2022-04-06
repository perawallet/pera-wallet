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

    private var transactionSendController: TransactionSendController?

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
        loadingController?.startLoadingWithMessage("title-loading".localized)

        transactionSendController = TransactionSendController(
            draft: draft,
            api: api!
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

extension AccountSelectScreen: AccountSelectScreenDataSourceDelegate {
    func accountSelectScreenDataSourceDidLoad(_ dataSource: AccountSelectScreenDataSource) {
        accountView.listView.reloadData()
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
