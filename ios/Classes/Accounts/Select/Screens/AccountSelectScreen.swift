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
import MacaroonUtils

final class AccountSelectScreen:
    BaseViewController,
    NotificationObserver {
    var notificationObservations: [NSObjectProtocol] = []

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

    private lazy var modalTransition = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToAskReceiverToOptIn = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToOptInInformation = BottomSheetTransition(presentingViewController: self)

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
            UITapGestureRecognizer(
                target: self,
                action: #selector(didTapCopyAddress)
            )
        )

        observe(notification: UIPasteboard.changedNotification) {
            [weak self] _ in
            guard let self = self else { return }

            self.displayClipboardIfNeeded()
        }

        observeWhenApplicationWillEnterForeground {
            [weak self] _ in
            guard let self = self else { return }

            self.displayClipboardIfNeeded()
        }
    }

    override func prepareLayout() {
        addAccountView()
        addTitleView()
    }

    override func bindData() {
        super.bindData()

        displayClipboardIfNeeded()
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

extension AccountSelectScreen {
    private func displayClipboardIfNeeded() {
        let address = UIPasteboard.general.validAddress
        let isVisible = address != nil

        if isVisible {
            accountView.clipboardView.bindData(
                AccountClipboardViewModel(address!)
            )
        }

        accountView.displayClipboard(isVisible: isVisible)
    }

    @objc
    private func didTapCopyAddress() {
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: section
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
        stopLoading { [weak self] in
            guard let self = self else {
                return
            }

            let controller = self.open(
                .sendTransactionPreview(
                    draft: self.draft
                ),
                by: .push
            ) as? SendTransactionPreviewScreen
            controller?.eventHandler = {
                [weak self] event in
                guard let self = self else { return }
                switch event {
                case .didCompleteTransaction: self.eventHandler?(.didCompleteTransaction)
                case .didEditNote(let note): self.eventHandler?(.didEditNote(note: note))
                default: break
                }
            }
        }
    }

    func transactionSendController(
        _ controller: TransactionSendController,
        didFailValidation error: TransactionSendControllerError
    ) {
        stopLoading { [weak self] in
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
                    self.presentAskReceiverToOptIn(receiverAddress: address)
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

    private func stopLoading(execute: @escaping () -> Void) {
        loadingController?.stopLoadingAfter(seconds: 0.3, on: .main) {
            execute()
        }
    }
}

extension AccountSelectScreen {
    private func presentAskReceiverToOptIn(receiverAddress: String) {
        guard let asset = draft.asset else {
            return
        }

        let title: String

        if let asset = asset as? CollectibleAsset {
            title =
                asset.title.unwrapNonEmptyString() ??
                asset.name.unwrapNonEmptyString() ??
                "#\(String(asset.id))"
        } else {
            title =
                asset.naming.unitName.unwrapNonEmptyString() ??
                asset.naming.name.unwrapNonEmptyString() ??
                "#\(String(asset.id))"
        }

        let description = "collectible-recipient-opt-in-description".localized(title, receiverAddress)

        let configuratorDescription = BottomWarningViewConfigurator.BottomWarningDescription.custom(
            description: (description, [title, receiverAddress]),
            markedWordWithHandler: (
                word: "collectible-recipient-opt-in-description-marked".localized,
                handler: {
                    [weak self] in
                    guard let self = self else {
                        return
                    }

                    self.dismiss(animated: true) {
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

                self.sendOptInRequestToReceiver(receiverAddress)
            }
        )

        transitionToAskReceiverToOptIn.perform(
            .bottomWarning(
                configurator: configurator
            ),
            by: .presentWithoutNavigationController
        )
    }

    private func sendOptInRequestToReceiver(_ receiverAddress: String) {
        let draft = AssetSupportDraft(
            sender: draft.from.address,
            receiver: receiverAddress,
            assetId: draft.asset!.id
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

    private func openOptInInformation() {
        let uiSheet = UISheet(
            title: "collectible-opt-in-info-title".localized.bodyLargeMedium(),
            body: "collectible-opt-in-info-description".localized.bodyRegular()
        )

        let closeAction = UISheetAction(
            title: "title-close".localized,
            style: .cancel
        ) { [unowned self] in
            self.dismiss(animated: true)
        }
        uiSheet.addAction(closeAction)

        transitionToOptInInformation.perform(
            .sheetAction(sheet: uiSheet),
            by: .presentWithoutNavigationController
        )
    }
}

extension AccountSelectScreen {
    enum Event {
        case didCompleteTransaction
        case didEditNote(note: String?)
    }
}
